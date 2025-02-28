﻿part of 'site.dart';

/// 混合 - 文章
mixin PostSite on DataProcess, TagSite {
  /// 菜单
  List<Post> get posts => state.posts;

  @override
  void initState() {
    super.initState();
    updateTagUsedField();
  }

  /// 获取 [fileName] 对应的 post, 不然返回新的 [Post] 实例
  Post getPostOrDefault(String fileName) {
    // 没有时返回新的实例
    return state.posts.firstWhere((p) => p.fileName == fileName, orElse: () => Post());
  }

  /// 获取文章封面图片的路径
  String getFeaturePath(Post data, {bool usePrefix = true}) {
    var feature = data.feature.isNotEmpty ? data.feature : defaultPostFeaturePath;
    if (feature.startsWith('http')) {
      return feature;
    }
    feature = FS.join(state.appDir, feature);
    // 加上 file:// 前缀
    if (usePrefix) {
      feature = featurePrefix + feature;
    }
    return feature;
  }

  /// 筛选文章
  ///
  /// [include]
  ///
  ///     false: 从 [Post.title] 中搜索数据
  ///     true: 从 [Post.title] 和 [Post.content] 中搜索数据
  List<Post> filterPost(String data, {bool include = false}) {
    Iterable<Post> posts;
    if (data.isEmpty) {
      posts = [...state.posts];
    } else {
      // 比较
      bool compare(Post p) {
        final reg = RegExp(data, caseSensitive: false, multiLine: true);
        return p.title.contains(reg) || (include && p.content.contains(reg));
      }

      // 筛选
      posts = state.posts.where(compare);
    }
    // 排序
    int compare(Post p1, Post p2) {
      // true==true || false==false
      if (p2.isTop == p1.isTop) {
        return p2.date.compareTo(p1.date);
      }
      return p2.isTop ? 1 : -1;
    }

    return posts.sorted(compare).toList();
  }

  /// 获取文章的链接
  List<TLinkData> getPostLink() {
    final postPath = '/${state.themeConfig.postPath}/';
    // 文章的链接
    return [
      for (var post in state.posts)
        // 文章的链接
        (name: post.title, link: '$postPath${post.fileName}'),
    ];
  }

  /// 更新或者添加 post
  Future<bool> updatePost({required Post newData, Post? oldData, String fileContent = '', PictureConfig? picture}) async {
    try {
      // 旧文件名
      String? oldFileName;
      final index = oldData == null ? -1 : state.posts.indexOf(oldData);
      // 添加或更新 post
      newData
        ..content = ''
        // 摘要, 以 <!--\s*more\s*--> 进行分割, 获取被分割的第一个字符串, 否则返回 ''
        ..abstract = summaryRegExp.stringMatch(newData.content) ?? '';
      // oldData 在 post 中存在
      if (index >= 0) {
        oldFileName = oldData!.fileName;
        state.posts[index] = newData;
      } else {
        // 插入到开头
        state.posts.insert(0, newData);
      }
      // 更新标签
      updateTagUsedField();
      // 保存
      if(picture != null) {
        await Background.instance.saveThemeImage(picture);
      }
      await saveSiteData();
      // 路径
      final path = FS.join(state.appDir, 'posts');
      // 文件名不同时先移除再保存内容
      if (oldFileName != null && oldFileName != newData.fileName) {
        FS.deleteDirSync(FS.join(path, '$oldFileName.md'));
      }
      await FS.writeString(FS.join(path, '${newData.fileName}.md'), fileContent);
      return true;
    } catch (e, s) {
      Log.e('update or add post failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 删除 post
  Future<bool> removePost(Post data) async {
    try {
      if (!state.posts.remove(data)) {
        return false;
      }
      // 标签
      updateTagUsedField();
      // 保存
      await saveSiteData();
      // 移除文件
      FS.deleteDirSync(FS.join(state.appDir, 'posts', '${data.fileName}.md'));
      return true;
    } catch (e, s) {
      Log.e('delete post failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 检测 [Post] 的命名是否添加或者更新
  ///
  /// true: 可以加入
  ///
  /// false: 文章的 URL 与其他文章重复
  bool checkPost(Post data, [Post? oldData]) {
    // 必须要有标题和内容
    if (data.title.trim().isEmpty) {
      return false;
    }
    // fileName
    if (data.fileName.trim().isEmpty || data.fileName.contains('/')) {
      return false;
    }
    // 判断 fileName 是否有重复的
    return !state.posts.any((p) => p.fileName == data.fileName && p != oldData);
  }

  /// 比较 post 是否相等
  bool equalPost(Post prev, Post next) {
    // 标签
    // 其它
    return prev.title == next.title &&
        prev.fileName == next.fileName &&
        prev.date == next.date &&
        prev.feature == next.feature &&
        prev.hideInList == next.hideInList &&
        prev.isTop == next.isTop &&
        equalPostTags(prev.tags, next.tags);
  }

  /// 比较 post 中的 tags 是否相等
  bool equalPostTags(List<String> prev, List<String> next) {
    final tag1 = prev.toSet();
    final tag2 = next.toSet();
    final tag3 = tag1.union(tag2);
    return tag1.length == tag3.length && tag3.length == tag2.length;
  }
}
