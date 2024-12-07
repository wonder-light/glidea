import less from 'less';
import urlJoin from 'url-join';

const fse = require('fs-extra');
const { renderFile } = require('ejs');
const { minify } = require('html-minifier');
const { robots } = require('robots-util');
const { SitemapStream, streamToPromise } = require('sitemap');
const moment = require('moment');

try {
  //const sourceData = require('./render_data.json');

  // 导入数据
  const renderDataPath = process.argv.find(t => t.endsWith('.json'));
  // TODO: 添加 appDir
  // TODO: buildDir
  // TODO: menus.link 去掉域名 => /
  // TODO: tags[0].count 指定是可以看到的文章的数量而不是总数量
  // TODO: 添加 commentSetting
  // TODO: 添加 minify 压缩 html
  const sourceData = fse.readJsonSync(renderDataPath);
  // 设置站点数据
  const siteData = {
    posts: sourceData.posts,
    tags: sourceData.tags,
    menus: sourceData.menus,
    themeConfig: sourceData.themeConfig,
    customConfig: sourceData.customConfig,
    utils: {
      now: moment.now(),
      moment: moment
    },
    isHomepage: sourceData.isHomepage
  };
  // 源目录
  const appDir = sourceData.appDir;
  // 输出目录
  const buildDir = sourceData.buildDir;
  // 主题路径
  const themePath = urlJoin(appDir, 'themes', sourceData.themeConfig.selectTheme);
  // 可以显示的 post
  const showPosts = sourceData.posts.filter(item => !item.hideInList);
  /**
   * 记录站点地图的列表
   * @type {import('sitemap/dist/lib/types').SitemapItemLoose[]}
   */
  const siteMapUrls = [];

  /**
   * 构建 css
   * @return {Promise<void>}
   */
  async function buildCss() {
    let stylesPath = urlJoin(themePath, 'assets', 'styles');
    let lessFilePath = urlJoin(stylesPath, 'main.css');
    let cssFolderPath = urlJoin(buildDir, 'styles', 'main.css');
    let result = '';

    // 先判断 css 是否存在
    if(fse.pathExistsSync(lessFilePath)) {
      result += fse.readFileSync(lessFilePath, 'utf8');
    }
    else {
      // 判断 less 是否存在
      lessFilePath = urlJoin(stylesPath, 'main.less');
      if(fse.pathExistsSync(lessFilePath)) {
        let lessString = fse.readFileSync(lessFilePath, 'utf8');
        // 解析 less
        await new Promise((resolve, reject) => {
          less.render(lessString, { filename: lessFilePath }, (err, data) => {
            if(err) {
              data = { css: '' };
            }
            result += data.css;
            resolve();
          });
        });
      }
    }
    // 覆盖 css 样式
    let styleOverridePath = urlJoin(themePath, 'style-override.js');
    if(!fse.pathExistsSync(styleOverridePath)) {
      let customCss = require(styleOverridePath)(siteData);
      result += customCss;
    }
    // 写入文件
    fse.outputFileSync(cssFolderPath, result);
  }

  /**
   * 记录 url 路径
   * @param {string} url url 路径
   */
  function recordUrl(url) {
    const { generateSiteMap, domain } = sourceData.themeConfig;
    if(!generateSiteMap) return;
    // 添加 url 记录
    siteMapUrls.push({
      url: urlJoin(domain, url, '/'),
      priority: 0.5,
      changefreq: 'daily'
    });
  }

  /**
   * Ejs 渲染模板文件
   * @param {string} path 文件路径
   * @param {any} data 渲染数据
   * @param {string} url 记录 url 网址
   * @return {Promise<string>} html 字符串
   */
  async function renderFileAction(path, data, url) {
    let html = '';
    // 渲染
    await renderFile(path, data, {}, (err, data) => {
      if(err) data = '';
      html += data;
    });
    // 记录 url
    recordUrl(url);
    // 压缩 html
    if(sourceData.minify) {
      try {
        html = minify(html, {
          collapseWhitespace: true, minifyCSS: true, minifyJS: true, removeComments: true, quoteCharacter: '\''
        });
      }
      catch(e) {
        return html;
      }
    }

    return html;
  }

  /**
   * 渲染文章列表
   * @param {string} urlPath 输出目录的部分路径, home => '', archive => '/archives', tag => '/tag/tag.slug'
   * @param {'index.ejs' | 'archives.ejs' | 'tag.ejs'} templatePath 模板路径
   * @param {number} pageSize 每一个页面中的 post 数量
   * @param {Array} postList post 列表
   * @param {null | function(value: any): any} update 更新渲染数据的函数
   * @return {Promise<void>}
   */
  async function buildPostList(urlPath = '', templatePath = 'index.ejs', pageSize = sourceData.themeConfig.postPageSize || 10, postList = null, update = null) {
    // 设置需要使用的 post 列表
    postList = postList != null ? postList : showPosts;
    // 需要渲染的模板路径
    const renderTemplatePath = urlJoin(themePath, 'templates', `${ templatePath }`);

    // 如果时归档的话需要按时间循序排列
    if(templatePath === 'archives.ejs') {
      postList = showPosts.sort((a, b) => Date.parse(b.date) - Date.parse(a.date));
    }
    // 渲染数据
    const renderData = {
      menus: sourceData.menus,
      posts: [],
      pagination: {
        prev: '',
        next: ''
      },
      themeConfig: sourceData.themeConfig,
      site: siteData
    };
    // html
    let html = '';
    // 页面的域名路径
    let domain = urlJoin(sourceData.themeConfig.domain, urlPath);
    // 当文章列表为空时是否跳过, tag 页面需要跳过
    let skipEmpty = templatePath === 'tag.ejs';

    /**
     * 条件判断函数
     * @param {number} i
     * @return {boolean}
     */
    function condition(i) {
      // tag: 没有 post 时不需要需渲染
      if(skipEmpty) {
        return (i - 1) * pageSize < postList.length;
      }
      // 没有 post 时也需要需渲染
      return (i - 1) * pageSize <= postList.length;
    }

    for(let i = 1; condition(i); i++) {
      // 以 pageSize 进行分割
      renderData.posts = postList.slice((i - 1) * pageSize, i * pageSize);
      // home 页面的 urlPath == ''
      renderData.site.isHomepage = !urlPath && i <= 1;
      // i <= 1 => urlPath
      // i > 1 => {urlPath}/page/{i}
      const currentUrlPaths = [urlPath, ...(i <= 1 ? [] : ['page', `${ i }`])];
      // i <= 1 => ''
      // i == 2 => {domain}/
      // i > 2 => {domain}/page/{i - 1}
      renderData.pagination.prev = i <= 1 ? '' : i > 2 ? urlJoin(domain, 'page', `${ i - 1 }/`) : urlJoin(domain, '/');
      // i * pageSize >= postList.length => ''
      // i * pageSize < postList.length => {domain}/page/{i + 1}
      renderData.pagination.next = i * pageSize >= postList.length ? '' : urlJoin(domain, 'page', `${ i + 1 }/`);
      // 当前路径
      const currentUrlPath = urlJoin(currentUrlPaths);
      // 创建目录
      fse.ensureDirSync(urlJoin(buildDir, currentUrlPath));
      // 渲染文件的路径
      let renderPath = urlJoin(buildDir, currentUrlPath, 'index.html');
      // 渲染模板
      html = await renderFileAction(renderTemplatePath, update ? update(renderData) : renderData, currentUrlPath);
      // 写入文件
      fse.outputFileSync(renderPath, html);
    }
  }

  /**
   * 渲染标签列表页面
   * @return {Promise<void>}
   */
  async function buildTags() {
    // tags 目录
    const tagsFolder = urlJoin(buildDir, 'tags');
    // tags 文件
    const renderPath = urlJoin(tagsFolder, 'index.html');
    // 渲染数据
    const renderData = {
      tags: sourceData.tags,
      menus: sourceData.menus,
      themeConfig: sourceData.themeConfig,
      site: siteData
    };
    // 创建 tags 目录
    fse.ensureDirSync(tagsFolder);
    // 渲染得到 HTML, 记录 tags 的网址
    const html = await renderFileAction(urlJoin(themePath, 'templates', 'tags.ejs'), renderData, 'tags');
    // 写入文件
    fse.outputFileSync(renderPath, html);
  }

  /**
   * 呈现文章详细信息页面，包括隐藏的文章
   * @return {Promise<void>}
   */
  async function buildPostDetail() {
    for(let i = 0; i < sourceData.posts.length; i++) {
      // 文章数据
      const post = { ...sourceData.posts[i] };
      // 判断文章是否隐藏
      if(!post.hideInList) {
        // 寻找 prev 和 next 文章
        let prev = sourceData.posts.slice(0, i).reverse().find(p => !p.hideInList);
        let next = sourceData.posts.slice(i + 1).find(p => !p.hideInList);
        if(prev) post.prevPost = prev;
        if(next) post.nextPost = next;
      }
      // 渲染数据
      const renderData = {
        menus: sourceData.menus,
        post,
        themeConfig: sourceData.themeConfig,
        commentSetting: sourceData.commentSetting,
        site: siteData
      };
      // post 的 url 地址
      const urlPath = urlJoin(`${ sourceData.themeConfig.postPath }`, post.fileName);
      // post 文件夹位置
      const renderFolderPath = urlJoin(buildDir, urlPath);
      // 渲染得到 HTML, 记录 post 的网址
      const html = await renderFileAction(urlJoin(themePath, 'templates', 'post.ejs'), renderData, urlPath);
      // 创建目录
      fse.ensureDirSync(renderFolderPath);
      // 写入文件
      fse.outputFileSync(urlJoin(renderFolderPath, 'index.html'), html);
    }
  }

  /**
   * 渲染标签详细页面
   * @return {Promise<void>}
   */
  async function buildTagDetail() {
    // 筛选出正在使用的标签
    const usedTags = sourceData.tags.filter(tag => tag.used);
    for(const currentTag of usedTags) {
      // 从 showPosts 中筛选出含有 currentTag.slug 的文章
      let postList = showPosts.filter(post => post.tags.find(tag => tag.slug === currentTag.slug));
      // 渲染对应的 tag 页面
      await buildPostList(
        urlJoin(sourceData.themeConfig.tagPath, currentTag.slug),
        'tag.ejs',
        sourceData.themeConfig.postPageSize,
        postList,
        (data) => {
          data.tag = currentTag;
          return data;
        }
      );
    }
  }

  /**
   * 渲染自定义页面
   * @return {Promise<void>}
   */
  async function buildCustomPage() {
    // 需要排除的模板
    const temps = new Set([
      'index.ejs', 'post.ejs', 'tag.ejs', 'tags.ejs', 'archives.ejs',
      // 👇 Glidea 保护字，因为这些文件名是 Glidea 文件夹的名称
      'images.ejs', 'media.ejs', 'post-images.ejs', 'styles.ejs', 'tag.ejs', 'tags.ejs'
    ]);
    // 获取 templates 目录下的模板文件
    const files = fse.readdirSync(urlJoin(themePath, 'templates'), { withFileTypes: true });
    // 需要渲染的自定义模板
    const customTemplates = files
      .filter(item => item.isFile() && !temps.has(item.name))
      .map(item => item.name);
    // 渲染数据
    const renderData = {
      menus: sourceData.menus,
      themeConfig: sourceData.themeConfig,
      commentSetting: sourceData.commentSetting,
      site: siteData
    };
    // 渲染
    for(const name of customTemplates) {
      // 文件名 custom.ejs => custom
      const fileName = name.substring(0, name.length - 4);
      // 模板路径
      let templatePath = urlJoin(themePath, 'templates', name);
      // 输出文件夹
      let renderFolder = urlJoin(buildDir, fileName);
      // 文件路径
      let renderPath = urlJoin(renderFolder, 'index.html');
      // 404 页面在根目录下创建
      if(name === '404.ejs') {
        renderFolder = buildDir;
        renderPath = urlJoin(renderFolder, '404.html');
      }
      // 创建目录
      fse.ensureDirSync(renderFolder);
      // 渲染 HTML
      const html = await renderFileAction(templatePath, renderData, fileName);
      // 写入文件
      fse.outputFileSync(renderPath, html);
    }
  }

  /**
   * 生成站点地图
   * @return {Promise<void>}
   */
  async function buildSiteMap() {
    const { generateSiteMap, robotsText, domain } = sourceData.themeConfig;
    // generateSiteMap == false 时返回
    if(!generateSiteMap) return;
    // 创建 Robots.txt 文件
    const robotsTxt = robots.parse(robotsText || '');
    robotsTxt.append('Sitemap', urlJoin(domain, 'sitemap.xml'));
    // 写入文件
    fse.outputFileSync(urlJoin(buildDir, 'robots.txt'), robots.serialize(robotsTxt));
    // 给定带有 url 的输入配置，创建一个站点地图对象
    const sitemap = new SitemapStream({ hostname: domain });
    for(const data of siteMapUrls) {
      sitemap.write(data, 'utf-8');
    }
    sitemap.end();
    const result = await streamToPromise(sitemap);
    // 写入文件
    fse.outputFileSync(urlJoin(buildDir, 'sitemap.xml'), result.toString());
  }

  /**
   * 构建
   * @return {Promise<void>}
   */
  async function build() {
    const { archivePath, archivesPageSize, postPageSize } = sourceData.themeConfig;
    await buildCss();
    // 渲染文章列表页面
    await buildPostList('', 'index.ejs', postPageSize);
    // 呈现归档页面
    await buildPostList(urlJoin('/', archivePath), 'archives.ejs', archivesPageSize);
    // 渲染标签列表页面
    await buildTags();
    // 渲染 post 文章
    await buildPostDetail();
    // 渲染 tag 页面
    await buildTagDetail();
    // 渲染自定义页面
    await buildCustomPage();
    // 生成站点地图
    await buildSiteMap();
  }

  build()
    .then(() => console.log(true))
    .catch((e) => console.log(false, 'build', e));


  //--------------------------- rollup.config.js ---------------------------
  /*
  import babel from '@rollup/plugin-babel'
  import commonjs from '@rollup/plugin-commonjs'
  import json from '@rollup/plugin-json'
  import { nodeResolve } from '@rollup/plugin-node-resolve'
  import { defineConfig, InputPluginOption } from 'rollup'
  import replace from '@rollup/plugin-replace';

  export default defineConfig([
    {
      input: './lib/index.js',
      output: {
        file: './dist/cjs/index.js',
        format: 'cjs'
      },
      plugins: [
        nodeResolve({preferBuiltins: true}),
        commonjs({transformMixedEsModules: true}),
        json(),
        babel({ babelHelpers: 'bundled' }),
        replace({
          preventAssignment: true,
          //'\.URL(': '.Url(',
        }),
      ],
    }
  ])*/


  //--------------------------- uglify-js ---------------------------
  /**
   * 打包时需要大 node_modules/uglify-js/tools/node.js 中 exports.FILES 给替换掉
   * 需要把 exports.FILES 中指定文件中的所有内容按顺序复制到 var fs = require("fs"); 的下面, 并且把 exports.FILES 给删除掉
   * 这是导致 rollup 打包后运行报错、ncc 打包成多文件的罪魁祸首
   */

}
catch(e) {
  console.log(false, e);
}
