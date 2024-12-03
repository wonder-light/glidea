import 'package:get/get.dart' show Get, StateController;
import 'package:glidea/controller/mixin/data.dart';
import 'package:glidea/controller/mixin/theme.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/deploy.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/tag.dart';

/// 混合 - 远程
mixin RemoteSite on StateController<Application>, DataProcess, ThemeSite {
  /// 检测是否可以进行发布
  bool get checkPublish {
    final remote = state.remote;
    return switch (remote.platform) {
      DeployPlatform.github ||
      DeployPlatform.gitee ||
      DeployPlatform.coding =>
        remote.branch.isNotEmpty && remote.domain.isNotEmpty && remote.token.isNotEmpty && remote.repository.isNotEmpty,
      // TODO: Handle this case.
      DeployPlatform.sftp => throw UnimplementedError(),
      DeployPlatform.netlify => remote.netlifySiteId.isNotEmpty && remote.netlifyAccessToken.isNotEmpty,
    };
  }

  /// 匹配 feature 本地图片路径的正则
  RegExp get featureReg => RegExp(r'file.*/post-images/', multiLine: true);

  /// 渲染 post 的数据
  List<PostRender> _postsData = [];

  /// 渲染 tag 的数据
  List<TagRender> _tagsData = [];

  /// 发布站点
  Future<void> publishSite() async {
    // 检测主题是否有效
    if (!selectThemeValid) {
      Get.error('noValidCurrentTheme');
      return;
    }
    // 检测是否可以发布
    if (!checkPublish) {
      Get.error('syncWarning');
      return;
    }
    try {
      // render
      await renderAll();
      var result = await Deploy.create(state).publish();
      if (result != Incident.success) {
        Get.error(result.message);
        return;
      }
      // 成功
      Get.success('syncSuccess');
    } catch (e) {
      Get.error('syncError1');
    }
  }

  /// 预览站点
  Future<void> previewSite() async {
    if (!selectThemeValid) {
      Get.error('noValidCurrentTheme');
      return;
    }
    // 设置域名
    state.themeConfig.domain = 'http://localhost:${state.previewPort}';
    await renderAll();
  }

  /// 渲染所有
  Future<void> renderAll() async {
    await _clearOutputFolder();
  }

  /// 清理输出目录
  Future<void> _clearOutputFolder() async {
    try {
      FS.deleteDirSync(state.buildDir);
      FS.createDirSync(state.buildDir);
    } catch (e) {
      Log.i('Delete file error: $e');
    }
  }

  /// 为呈现页面格式化数据
  Future<void> _formatDataForRender() async {
    // 标签
    _tagsData = state.tags.map(_tagToRender).toList();
    // 标签 slug - 对象
    final Map<String, TagRender> tagsMap = {
      for (var item in _tagsData) item.slug: item,
    };
    // 已经发布的 post
    var publishPost = state.posts.where((p) => _filterPublishPost(p, tagsMap));
    // post 数据
    _postsData = publishPost.map((item) {
      // 变换标签
      var currentTags = item.tags.map((t) => tagsMap[t.slug]!);
      // 返回数据
      return item.copyWith<PostRender>({
        'tags': currentTags,
      })!;
    }).toList();
  }

  /// Tag to TagRender
  TagRender _tagToRender(Tag tag) {
    final link = FS.joinR(themeConfig.domain, themeConfig.tagPath, tag.slug, '/');
    return tag.copyWith<TagRender>({'link': link})!;
  }

  /// 筛选发布的文章并移除文章中无效的标签
  bool _filterPublishPost(Post post, Map<String, TagRender> tagsMap) {
    for (var i = post.tags.length - 1; i >= 0; i--) {
      var tag = post.tags[i];
      var value = tagsMap[tag.slug];
      // 需要移除的标签, 确保标签都是有效的
      if (value == null) {
        post.tags.removeAt(i);
        continue;
      }
      // 设置 tag 的 count 值
      value.count++;
    }

    return post.published;
  }

  /// Post to PostRender
  PostRender _postToRender(Post post, Map<String, TagRender> tagsMap) {
    // 变换标签
    var currentTags = post.tags.map((t) => tagsMap[t.slug]!);
    // TOC 目录
    var toc = '';
    // 将文章中本地图片路径，变更为线上路径
    var content = post.content.replaceAll(featureReg, '${themeConfig.domain}/post-images/');
    content = Markdown.markdownToHtml(content, tocCallback: (data) => toc = data);
    // 渲染 MarkDown to HTML
    // 返回数据
    return post.copyWith<PostRender>({
      'tags': currentTags,
      'toc': toc,
    })!;
  }
}
