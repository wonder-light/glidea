part of 'site.dart';

/// 混合 - 远程
mixin RemoteSite on DataProcess, ThemeSite {
  /// 发布的网址
  String get domain => state.remote.domain;

  /// 远程
  RemoteSetting get remote => state.remote;

  /// 评论
  CommentSetting get comment => state.comment;

  /// 检测是否可以进行发布
  ///
  /// [true] - 可以进行发布
  bool get checkPublish {
    return switch (remote.platform) {
      DeployPlatform.github => _isCheckGitPublish(remote.github),
      DeployPlatform.gitee => _isCheckGitPublish(remote.gitee),
      DeployPlatform.coding => _isCheckGitPublish(remote.coding),
      DeployPlatform.sftp => _isCheckSftpPublish(),
      DeployPlatform.netlify => _isCheckNetlifyPublish(),
    };
  }

  /// 评论选项
  final List<SelectOption> _commentOptions = [];

  /// 评论选项
  final TMapLists<SelectOption> _remoteOptions = {};

  /// 远程的控件配置
  final TMaps<Object, ConfigBase> remoteWidgetConfigs = {};

  /// 评论的控件配置
  final TMaps<Object, ConfigBase> commentWidgetConfigs = {};

  @override
  void initState() {
    super.initState();
    loadRemoteConfig();
    loadCommentConfig();
  }

  /// 发布站点
  Future<Notif> publishSite() async {
    try {
      // 检测主题是否有效
      if (!selectThemeValid) {
        return Notif(hint: Tran.noValidCurrentTheme);
      }
      // 检测是否可以发布
      if (!checkPublish) {
        return Notif(hint: Tran.syncWarning);
      }
      // 在后台进行发布
      await Background.instance.publishSite(state);
      // 成功
      return Notif(hint: Tran.syncSuccess, success: true);
    } catch (e, s) {
      Log.e('publish site failed', error: e, stackTrace: s);
      return Notif(hint: Tran.syncError1);
    }
  }

  /// 预览站点
  Future<Notif> previewSite() async {
    try {
      if (!selectThemeValid) {
        return Notif(hint: Tran.noValidCurrentTheme);
      }
      // 在后台进行操作
      await Background.instance.previewSite(state);
      // 成功
      return Notif(hint: Tran.renderSuccess, success: true);
    } catch (e, s) {
      Log.e('preview site failed', error: e, stackTrace: s);
      return Notif(hint: Tran.renderError);
    }
  }

  /// 更新远程配置
  Future<bool> saveRemoteConfig() async {
    try {
      await saveSiteData(callback: () async {
        // 获取配置
        TJsonMap remotes = _getConfig(remoteWidgetConfigs);
        TJsonMap comments = _getConfig(commentWidgetConfigs);
        // 远程
        state.remote = state.remote.copyWith<RemoteSetting>(remotes)!;
        // 合并
        state.comment = state.comment.copyWith<CommentSetting>(comments)!;
      });
      return true;
    } catch (e, s) {
      Log.e('remote detect failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 远程检测
  Future<bool> remoteDetect() async {
    try {
      await Background.instance.remoteDetect(state.remote, state.appDir, state.buildDir);
      return true;
    } catch (e, s) {
      Log.e('remote detect failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 加载远程设置
  Future<void> loadRemoteConfig() async {
    // 设置选项
    if (_remoteOptions.isEmpty) {
      _remoteOptions[platformField] = _getOptions(DeployPlatform.values);
      _remoteOptions[enabledProxyField] = _getOptions(ProxyWay.values);
    }
    remoteWidgetConfigs.clear();
    // 设置配置
    final remote = state.remote.toMap()!;
    // domain 提示
    final domainNote = 'netlify: https://{site}.netlify.app    Github: https://<user>.github.io/<repo>';
    // 字段的左下角提示
    final notes = {privateKeyField: Tran.privateKeyTip, remotePathField: Tran.remotePathTip, domainField: domainNote};
    // 字段的内部提示
    final hints = {branchField: Tran.branch, domainField: 'https://my_domain.com', cnameField: 'my_domain.com'};
    // 各个平台
    for (var key in DeployPlatform.values) {
      final values = remote.remove(key.name) as TJsonMap;
      remoteWidgetConfigs[key] = createRenderConfig(
        fields: {for (var item in values.keys) item: FieldType.input},
        fieldValues: values,
        fieldHints: hints,
        fieldNotes: notes,
      );
    }
    remoteWidgetConfigs[RemoteProxy] = createRenderConfig(
      fields: {enabledProxyField: FieldType.radio, proxyPortField: FieldType.input, proxyPathField: FieldType.input},
      fieldValues: remote,
      options: _remoteOptions,
    );
    remoteWidgetConfigs[RemoteBase] = createRenderConfig(
      fields: {platformField: FieldType.select, domainField: FieldType.input},
      fieldValues: remote,
      fieldNotes: notes,
      fieldHints: hints,
      options: _remoteOptions,
    );
  }

  /// 加载评论设置
  Future<void> loadCommentConfig() async {
    // 添加选项
    if (_commentOptions.isEmpty) {
      _commentOptions.addAll(_getOptions(CommentPlatform.values));
    }
    commentWidgetConfigs.clear();
    // 配置
    final comment = state.comment.toMap()!;
    // 各个评论
    for (var key in CommentPlatform.values) {
      final values = comment.remove(key.name) as TJsonMap;
      commentWidgetConfigs[key] = createRenderConfig(
        fields: {for (var item in values.keys) item: FieldType.input},
        fieldValues: values,
      );
    }
    // 基础
    commentWidgetConfigs[CommentBase] = createRenderConfig(
      fields: {commentPlatformField: FieldType.radio, showCommentField: FieldType.toggle},
      fieldValues: comment,
      options: {commentPlatformField: _commentOptions},
    );
  }

  /// 检测 github, gitee, coding
  bool _isCheckGitPublish(RemoteGithub github) {
    return github.username.isNotEmpty && github.branch.isNotEmpty && remote.domain.isNotEmpty && github.token.isNotEmpty && github.repository.isNotEmpty;
  }

  /// 检测 sftp
  bool _isCheckSftpPublish() {
    final sftp = remote.sftp;
    return sftp.port.isNotEmpty && sftp.server.isNotEmpty && sftp.username.isNotEmpty && sftp.password.isNotEmpty;
  }

  /// 检测 netlify
  bool _isCheckNetlifyPublish() {
    final netlify = remote.netlify;
    return netlify.siteId.isNotEmpty && netlify.accessToken.isNotEmpty;
  }

  /// 从枚举设置选项
  List<SelectOption> _getOptions(List<Enum> enums) {
    return [
      for (var t in enums) SelectOption().setValues(label: t.name.tr, value: t.name),
    ];
  }

  // 提取配置的值
  TJsonMap _getConfig(Map<Object, TMap<ConfigBase>>? configs) {
    if (configs?.isEmpty ?? true) return {};
    return {
      for (var MapEntry(:key, :value) in configs!.entries)
        if (key is Enum)
          key.name: {
            for (var entry in value.entries) entry.key: entry.value.value,
          }
        else
          for (var entry in value.entries) entry.key: entry.value.value,
    };
  }
}
