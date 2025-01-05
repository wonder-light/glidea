
# 页面变量 :id=variables 

> 在创建页面时引入的变量，不同的页面引入的变量也会有所不同

## 页面变量示例 :id=page-example
  
### index 页面 :id=index-page

- [posts](#posts)
- [menus](#menus)
- [pagination](#pagination)
- [themeConfig](#themeconfig)
- [site](#site)

### post 页面 :id=post-page

- [post](#post)
- [menus](#menus)
- [themeConfig](#themeconfig)
- [commentSetting](#commentsetting)
- [site](#site)

### archives 页面 :id=archives-page

- [posts](#posts)
- [menus](#menus)
- [pagination](#pagination)
- [themeConfig](#themeconfig)
- [site](#site)

### tags 页面 :id=tags-page

- [tags](#tags)
- [menus](#menus)
- [themeConfig](#themeconfig)
- [site](#site)

### tag 页面 :id=tag-page

- [tag](#tag)
- [posts](#posts)
- [menus](#menus)
- [pagination](#pagination)
- [themeConfig](#themeconfig)
- [site](#site)

### 自定义模板 :id=custom-template

可以在 templates 文件夹创建自定义模版，\
例如 `friends.j2`, `about.j2`, `projects.j2`, `404.j2` 等等，\
最终生成的访问路径为\
`http(s)://域名/friends`,\
`http(s)://域名/about`,\
`http(s)://域名/projects`,\
`http(s)://域名/404`

可用变量如下:

- [menus](#menus)
- [themeConfig](#themeconfig)
- [commentSetting](#commentsetting)
- [site](#site)

?> 注：若主题包含自定义模版，若自定义渲染模板的 URL 与文章 URL 产生冲突，自定义渲染模版优先级高于文章 URL

## 变量值示例 :id=variable-example

?> @ 符号为引用其他字段标志，仅作为此文档字段说明使用

### menus

菜单数组，具体 Menu 字段可见 [menu](#menu)

```js
menus: [
  @menu, 
  @menu, 
  @menu
]
```

### posts

文章数组，具体 Post 字段可见 [post](#post)

```js
posts: [
  @post, 
  @post, 
  @post
]
```

### tags

标签数组，具体 Tag 字段可见 [tag](#tag)

```js
tags: [
  @tag, 
  @tag, 
  @tag
]
```

### pagination

文章列表的分页字段

```js
pagination: {
  prev: '', // 上一页的链接
  next: '', // 下一页的链接
}
```

### menu

菜单字段

```js
menu: {
  name: '首页',
  link: '/',
  openType: 'internal', // 打开类型: 内链或外链
}
```

### post

文章字段

```js
post: {
  content: '<p><strong>Glidea</strong> 一个静态博客写作客户端 </p>',
  fileName: 'hello-glidea',
  abstract: '',
  description: '一个静态博客写作客户端 欢迎使用 Glidea', // 智能截取文章开始内容填充此字段，可用作未设置摘要时备用字段
  title: 'Hello Glidea',
  tags: ['Glidea', 'dev', 'test'], // 文章 tag 数组，具体可见下面 tag 字段
  date: 'December 12o 2018, am',
  dateFormat: '2018-12-12', // 依据 Glidea 应用内日期格式化后字段
  feature: 'post-images/hello-glidea.png', // 若无封面图，则为''
  link: 'https://xxx.com/post/hello-glidea',
  hideInList: false, // 仅对未设置标签文章生效
  isTop: false, // 是否是置顶文章
  toc: '<ul class="markdownIt-TOC"><li><ul><li><a href="#demo" class="">DEMO</a></li></ul></li></ul>', // 文章目录字段
  prevPost: @post, // 若是为第一篇文章，则无此字段
  nextPost: @post, // 若是为最后一篇文章，则无此字段
}
```

### tag

标签字段

```js
tag: {
  name: 'Glidea',
  use: true,
  count: 1,
  slug: 'glidea',
  link: 'https://xxx.com/tag/glidea',
}
```

### themeConfig

主题配置字段

```js
themeConfig: {
  selectTheme: "tech",
  domain: "https://github.com",
  archivesPageSize: 50,
  archivesPath: "archives", // 归档页路径前缀，应用内可自定义，例如 'blog', 'news' 等
  dateFormat: "yyyy-MM-dd HH:mm:ss",
  feedCount: 10,
  useFeed: false,
  footerInfo: "Powered by <a href=\"https://github.com/wonder-light/glidea\" target=\"_blank\">Glidea</a>",
  postPageSize: 12,
  postPath: "post",
  postUrlFormat: "slug",
  showFeatureImage: true,
  siteDescription: "Every 🐦 has an 🦅's dream.",
  siteName: "海岛心hey",
  tagPath: "tag",
  tagUrlFormat: "shortId",
  generateSiteMap: true,
  robotsText: "",
}
```

### site

site 字段

```js
site: {
  posts: @posts,
  tags: @tags,
  menus: @menus,
  themeConfig: @themeConfig,
  isHomepage: false, // 是否为首页，使用 index.j2 渲染，且为第一页的时候为 true
  customConfig: {}, // 主题自定义配置字段，若无则为 {}
  utils: {
    now: "1577006772710", // Date.now()
  },
};
```

### commentSetting

评论字段

```js
commentSetting: {
  commentPlatform: 'disqus',
  disqusSetting: {
    api: '',
    apikey: 'Dme6Hy8bOI2xxxxUtdY8V',
    shortname: 'glidea',
  },
  gitalkSetting: {
    clientId: 'd92dxxxxxxxxxx9b4',
    clientSecret: '861947exxxx365d33',
    owner: 'EryouHao',
    repository: 'EryouHao.github.io'
  },
  showComment: false // 是否显示评论，可根据此字段进行评论的展示与否
}
```


## 其它 :id=other

### 头像 :id=avatar

```html
<img class="avatar" src="{{ themeConfig.domain }}/images/avatar.png" alt="" width="32px" height="32px">
```

### 网页图标 :id=favicon

```html
<link rel="shortcut icon" href="{{ themeConfig.domain }}/favicon.ico">
```

### 样式文件 :id=main.css

```html
<link rel="stylesheet" href="{{ themeConfig.domain }}/styles/main.css">
```
