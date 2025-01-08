import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, Trans, BoolExtension;
import 'package:glidea/components/Common/animated.dart';
import 'package:glidea/components/Common/dropdown.dart';
import 'package:glidea/components/Common/loading.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/render/array.dart';
import 'package:glidea/components/render/group.dart';
import 'package:glidea/components/render/input.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class RemoteView extends StatefulWidget {
  const RemoteView({super.key});

  @override
  State<RemoteView> createState() => _RemoteViewState();
}

class _RemoteViewState extends State<RemoteView> {
  static const _domain = 'domain';
  static const _platform = 'platform';
  static const _email = 'email';
  static const _cname = 'cname';
  static const _token = 'token';
  static const _port = 'port';
  static const _branch = 'branch';
  static const _username = 'username';
  static const _repository = 'repository';
  static const _tokenUsername = 'tokenUsername';
  static const _server = 'server';
  static const _remotePath = 'remotePath';
  static const _password = 'password';
  static const _privateKey = 'privateKey';
  static const _proxyPath = 'proxyPath';
  static const _proxyPort = 'proxyPort';
  static const _enabledProxy = 'enabledProxy';
  static const _siteId = 'siteId';
  static const _accessToken = 'accessToken';
  static const _commentPlatform = 'commentPlatform';
  static const _showComment = 'showComment';
  static const _api = 'api';
  static const _apikey = 'apikey';
  static const _shortname = 'shortname';
  static const _owner = 'owner';
  static const _clientId = 'clientId';
  static const _clientSecret = 'clientSecret';

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 当前选择的平台
  final RxObject<DeployPlatform> platform = DeployPlatform.github.obs;

  /// 当前选择的评论平台
  final RxObject<CommentPlatform> commentPlatform = CommentPlatform.gitalk.obs;

  /// 域名的文本控制器
  final TextEditingController domainController = TextEditingController();

  /// 域名前缀
  String domainPrefix = '';

  /// 代理方式
  final proxyWay = ProxyWay.direct.obs;

  /// 检测是否可以进行发布
  ///
  /// [true] - 可以进行发布
  final checkPublish = false.obs;

  /// 字段名称列表
  late final TMaps<Object, FieldType> nameLists;

  /// 字段配置
  final fieldConfigs = <Object, TMap<ConfigBase>>{}.obs;

  // 字段的左下角提示
  final fieldNotes = const {
    _privateKey: Tran.privateKeyTip,
    _remotePath: Tran.remotePathTip,
  };

  // 字段的内部提示
  final fieldHints = const {
    _branch: Tran.branch,
    _domain: 'my_domain.com',
    _cname: 'my_domain.com',
  };

  /// 字段选项
  late final TMapList<String, SelectOption> fieldOptions = _getConfigOptions();

  /// 需要隐藏密码的字段
  final hidePasswords = {
    _password: true.obs,
    _privateKey: true.obs,
    _accessToken: true.obs,
    _token: true.obs,
  };

  @override
  void initState() {
    super.initState();
    // 初始化配置
    Future(() async {
      // 命名列表
      nameLists = _getNameList();
      await _initConfig();
      // 域名
      _updateDomainField();
    });
  }

  @override
  void dispose() {
    platform.dispose();
    proxyWay.dispose();
    fieldConfigs.dispose();
    checkPublish.dispose();
    commentPlatform.dispose();
    domainController.dispose();
    for (var item in hidePasswords.values) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget;
    // 手机端
    if (Get.isPhone) {
      // arguments 参数来自 [package:glidea/views/setting.dart] 中的 [_SettingViewState.toRouter]
      var arg = '${Get.arguments}';
      if (arg == Tran.commentSetting) {
        childWidget = _buildCommentConfig();
      } else {
        arg = Tran.remoteSetting;
        childWidget = _buildRemoteConfig();
      }
      return Scaffold(
        appBar: AppBar(title: Text(arg.tr), actions: getActionButton()),
        body: Padding(padding: kTopPadding16, child: childWidget),
      );
    }
    // 远程和评论的分组
    childWidget = GroupWidget(
      isTop: true,
      contentPadding: kTopPadding16,
      groups: const [Tran.basicSetting, Tran.commentSetting],
      itemBuilder: (ctx, index) {
        if (index <= 0) return _buildRemoteConfig();
        return _buildCommentConfig();
      },
    );
    // 返回
    return Material(
      color: Get.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: childWidget),
          const VerticalDivider(thickness: 1, width: 1),
          _buildBottom(),
        ],
      ),
    );
  }

  /// 构建远程设置
  Widget _buildRemoteConfig() {
    return Obx(() {
      final configs = fieldConfigs.value;
      // 对应平台的配置
      final items = {...configs[RemoteBase] ?? {}, ...configs[platform.value] ?? {}};
      // 代理
      if (platform.value != DeployPlatform.sftp) {
        // 代理, 全部加进去
        items.addAll(configs[RemoteProxy] ?? {});
        // 直连
        if (proxyWay.value == ProxyWay.direct) {
          items.remove(_proxyPath);
          items.remove(_proxyPort);
        }
      }
      // 构建列表
      return _buildContent(items: items, overs: {_domain: _buildDomainField()});
    });
  }

  /// 构建评论设置
  Widget _buildCommentConfig() {
    return Obx(() {
      // 评论类型
      final type = commentPlatform.value == CommentPlatform.gitalk ? GitalkSetting : DisqusSetting;
      // CommentSetting 的字段
      TMap<ConfigBase> configs = {
        ...fieldConfigs.value[CommentBase] ?? {},
        ...fieldConfigs.value[type] ?? {},
      };
      // 构建
      return _buildContent(items: configs);
    });
  }

  /// 构建字段列表
  ///
  /// [items] 字段配置
  ///
  /// [overs] 需要进行覆盖的字段控件
  Widget _buildContent({required TMap<ConfigBase> items, TMap<Widget>? overs}) {
    if (items.isEmpty) {
      return const Center(child: LoadingWidget());
    }
    // 构建列表
    return ListView.separated(
      shrinkWrap: true,
      padding: kVer12Hor24,
      itemCount: items.length,
      itemBuilder: (ctx, index) {
        final key = items.keys.elementAt(index);
        final over = overs?[key];
        if (over != null) return over;
        return ArrayWidget.create(
          config: items[key] as ConfigBase,
          isVertical: false,
          usePassword: hidePasswords[key],
          onChanged: (str) => _fieldChange(str, field: key),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Padding(padding: kVerPadding8),
    );
  }

  /// 构建底部按钮
  Widget _buildBottom() {
    return Padding(
      padding: kVer8Hor12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Obx(() {
            Widget child = Text(Tran.testConnection.tr);
            if (site.inRemoteDetect.value) {
              child = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AutoAnimatedRotation(child: Icon(PhosphorIconsRegular.arrowsClockwise)),
                  child,
                ],
              );
            }
            return OutlinedButton(
              onPressed: checkPublish.value && !site.inRemoteDetect.value ? _testConnection : null,
              child: child,
            );
          }),
          FilledButton(
            onPressed: _saveConfig,
            child: Text(Tran.save.tr),
          ),
        ],
      ),
    );
  }

  /// 手机端的 action 按钮
  List<Widget> getActionButton() {
    return [
      TipWidget.down(
        message: Tran.reset.tr,
        child: IconButton(
          onPressed: _resetConfig,
          icon: const Icon(PhosphorIconsRegular.clockCounterClockwise),
        ),
      ),
      TipWidget.down(
        message: Tran.save.tr,
        child: IconButton(
          onPressed: _saveConfig,
          icon: const Icon(PhosphorIconsRegular.boxArrowDown),
        ),
      ),
    ];
  }

  /// 构建域名字段
  Widget _buildDomainField() {
    InputConfig? domain = fieldConfigs.value[RemoteBase]?[_domain] as InputConfig?;
    if (domain == null) {
      return const SizedBox.shrink();
    }
    return InputWidget(
      controller: domainController,
      config: domain.obs,
      isVertical: false,
      prefixIcon: Padding(
        padding: kRightPadding8,
        child: DropdownWidget(
          initValue: domainPrefix,
          width: 115,
          children: [
            for (var item in ['https://', 'http://'])
              DropdownMenuItem(
                value: item,
                child: Padding(
                  padding: kHorPadding8,
                  child: Text(item),
                ),
              ),
          ],
          onSelected: (str) {
            domainPrefix = str;
            domain.value = domainPrefix + domainController.text;
          },
        ),
      ),
      onChanged: (str) {
        domain.value = domainPrefix + domainController.text;
      },
    );
  }

  /// [SelectConfig] 的选项
  TMapList<String, SelectOption> _getConfigOptions() {
    var options = {_platform: DeployPlatform.values, _enabledProxy: ProxyWay.values, _commentPlatform: CommentPlatform.values};
    return {
      for (var MapEntry(:key, :value) in options.entries)
        key: [
          for (var t in value)
            SelectOption()
              ..label = t.name.tr
              ..value = t.name,
        ],
    };
  }

  /// 获取远程配置所需要的命名列表
  TMaps<Object, FieldType> _getNameList() {
    // DeployPlatform.coding
    final codingNames = {
      for (var item in [_repository, _branch, _username, _email, _token, _cname, _tokenUsername]) item: FieldType.input,
    };
    // DeployPlatform.github
    final githubNames = Map.of(codingNames);
    githubNames.remove(_tokenUsername);
    return {
      RemoteBase: {_platform: FieldType.select, _domain: FieldType.input},
      RemoteProxy: {_enabledProxy: FieldType.radio, _proxyPort: FieldType.input, _proxyPath: FieldType.input},
      DeployPlatform.github: githubNames,
      DeployPlatform.gitee: githubNames,
      DeployPlatform.coding: codingNames,
      DeployPlatform.netlify: {_siteId: FieldType.input, _accessToken: FieldType.input},
      DeployPlatform.sftp: {
        for (var item in [_port, _server, _username, _password, _remotePath]) item: FieldType.input,
      },
      CommentBase: {_commentPlatform: FieldType.radio, _showComment: FieldType.toggle},
      DisqusSetting: {_api: FieldType.input, _apikey: FieldType.input, _shortname: FieldType.input},
      GitalkSetting: {
        for (var item in [_owner, _repository, _clientId, _clientSecret]) item: FieldType.input,
      },
    };
  }

  /// 获取 [FieldType] 对应的 [ConfigBase] 配置
  void _getFieldConfig() {
    try {
      final remote = site.remote.toMap()!;
      final comment = site.comment.toMap()!;
      TMaps<Object, ConfigBase> configs = {};
      for (var MapEntry(:key, :value) in nameLists.entries) {
        // 值
        TMap<dynamic>? values = switch (key) {
          RemoteBase || RemoteProxy => remote,
          DeployPlatform.github => remote['github'],
          DeployPlatform.gitee => remote['gitee'],
          DeployPlatform.coding => remote['coding'],
          DeployPlatform.netlify => remote['netlify'],
          DeployPlatform.sftp => remote['sftp'],
          DisqusSetting => comment['disqusSetting'],
          GitalkSetting => comment['gitalkSetting'],
          _ => comment,
        };
        fieldConfigs.update((configs) {
          return configs
            ..[key] = site.createRenderConfig(
              fields: value,
              fieldValues: values,
              fieldNotes: fieldNotes,
              fieldHints: fieldHints,
              options: fieldOptions,
            );
        });
      }
    } catch (e, s) {
      Log.e('remoteWidget._getFieldConfig: remote.toMap failed', error: e, stackTrace: s);
    }
  }

  /// 更新域名字段
  void _updateDomainField() {
    InputConfig field = fieldConfigs.value[RemoteBase]![_domain]! as InputConfig;
    final prefix = RegExp(r'https?://').stringMatch(field.value);
    if (prefix != null) {
      domainPrefix = prefix;
      domainController.text = field.value.substring(prefix.length);
    } else {
      domainPrefix = 'https://';
      domainController.text = field.value;
    }
  }

  /// 字段变化时调用
  void _fieldChange(dynamic str, {String? field}) {
    checkPublish.value = site.checkPublish;
    switch (field) {
      case _platform:
        platform.value = DeployPlatform.values.firstWhereOrNull((t) => t.name == str) ?? DeployPlatform.github;
        site.remote.platform = platform.value;
        break;
      case _commentPlatform:
        commentPlatform.value = CommentPlatform.values.firstWhereOrNull((t) => t.name == str) ?? CommentPlatform.gitalk;
        site.comment.commentPlatform = commentPlatform.value;
        break;
      case _enabledProxy:
        proxyWay.value = ProxyWay.values.firstWhereOrNull((t) => t.name == str) ?? ProxyWay.direct;
        site.remote.enabledProxy = proxyWay.value;
        break;
    }
  }

  /// 初始化配置
  Future<void> _initConfig() async {
    final remote = site.remote;
    platform.value = remote.platform;
    commentPlatform.value = site.comment.commentPlatform;
    checkPublish.value = site.checkPublish;
    proxyWay.value = remote.enabledProxy;
    // 配置
    _getFieldConfig();
  }

  /// 重置配置
  void _resetConfig() => _initConfig();

  /// 保持配置
  void _saveConfig() async {
    final configs = fieldConfigs.value;
    final remotes = [
      ...configs[RemoteBase]!.values,
      ...configs[RemoteProxy]!.values,
      for (var value in DeployPlatform.values) ...configs[value]!.values,
    ];
    final comments = [
      ...configs[CommentBase]!.values,
      ...configs[DisqusSetting]!.values,
      ...configs[GitalkSetting]!.values,
    ];
    final value = await site.updateRemoteConfig(remotes: remotes, comments: comments);
    value ? Get.success(Tran.themeConfigSaved) : Get.error(Tran.saveError);
  }

  /// 检测远程连接
  void _testConnection() async {
    final value = await site.remoteDetect();
    value ? Get.success(Tran.connectSuccess) : Get.error(Tran.connectFailed);
  }
}
