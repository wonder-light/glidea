import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, Trans, BoolExtension;
import 'package:glidea/components/Common/animated.dart';
import 'package:glidea/components/Common/dropdown.dart';
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
  static const _remotePlatform = 'platform';
  static const _commentPlatform = 'commentPlatform';
  static const _enabledProxy = 'enabledProxy';
  static const _connectType = 'connectType';
  static const _password = 'password';
  static const _privateKey = 'privateKey';
  static const _remotePath = 'remotePath';
  static const _tokenUsername = 'tokenUsername';
  static const _showComment = 'showComment';
  static const _branch = 'branch';
  static const _cname = 'cname';
  static const _token = 'token';
  static const _netlifyAccessToken = 'netlifyAccessToken';

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

  /// SFTP 的链接方式
  ///
  /// password, key
  final sftpIsKey = false.obs;

  /// 检测是否可以进行发布
  ///
  /// [true] - 可以进行发布
  final checkPublish = false.obs;

  /// 字段名称列表
  late final TMapList<Object, String> nameLists;

  /// 字段名字
  late final TMaps<Type, FieldType> fieldNames;

  /// 字段配置
  final RxObject<TMaps<Type, ConfigBase>> fieldConfigs = <Type, TMap<ConfigBase>>{}.obs;

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
  late final TMapList<String, SelectOption> fieldOptions;

  /// 需要隐藏密码的字段
  final hidePasswords = {
    _password: true.obs,
    _privateKey: true.obs,
    _netlifyAccessToken: true.obs,
    _token: true.obs,
  };

  @override
  void initState() {
    super.initState();
    // 命名列表
    nameLists = _getNameList();
    // 命名
    fieldNames = {
      RemoteSetting: _getRemoteConfigMap(),
      CommentSetting: {
        _commentPlatform: FieldType.radio,
        _showComment: FieldType.toggle,
      },
      GitalkSetting: _getConfigMap<GitalkSetting>(),
      DisqusSetting: _getConfigMap<DisqusSetting>(),
    };
    // 选项
    fieldOptions = _getConfigOptions();
    // 初始化配置
    _initConfig();
    // 域名
    _updateDomainField();
  }

  @override
  void dispose() {
    platform.dispose();
    proxyWay.dispose();
    sftpIsKey.dispose();
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
        childWidget = _buildConfig(isRemote: false);
      } else {
        arg = Tran.remoteSetting;
        childWidget = _buildConfig(isRemote: true);
      }
      return Scaffold(
        appBar: AppBar(title: Text(arg.tr), actions: getActionButton()),
        body: childWidget,
      );
    }
    // 远程和评论的分组
    childWidget = GroupWidget(
      isTop: true,
      groups: const {Tran.basicSetting, Tran.commentSetting},
      children: [
        _buildConfig(isRemote: true),
        _buildConfig(isRemote: false),
      ],
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
          _buildBottom(),
        ],
      ),
    );
  }

  /// 包裹 [Padding]
  Widget _buildConfig({bool isRemote = true}) {
    return Padding(
      padding: kTopPadding16,
      child: isRemote ? _buildRemoteConfig() : _buildCommentConfig(),
    );
  }

  /// 构建远程设置
  Widget _buildRemoteConfig() {
    return Obx(() {
      // 字段名称
      final Set<String> names = {
        ...nameLists[RemoteBase]!,
        ...nameLists[platform.value]!,
      };
      // 代理
      if (platform.value != DeployPlatform.sftp) {
        // 直连
        if (proxyWay.value == ProxyWay.direct) {
          names.add(_enabledProxy);
        } else {
          // 代理, 全部加进去
          names.addAll(nameLists[RemoteProxy]!);
        }
      } else {
        // SFTP
        names.remove(sftpIsKey.value ? _password : _privateKey);
      }

      final configs = fieldConfigs.value[RemoteSetting] ?? {};
      // 构建列表
      return _buildContent(
        items: {
          for (var item in names)
            if (configs[item] case ConfigBase config)
              // entry
              item: config,
        },
        over: {_domain: _buildDomainField()},
      );
    });
  }

  /// 构建评论设置
  Widget _buildCommentConfig() {
    return Obx(() {
      // CommentSetting 的字段
      TMap<ConfigBase> configs = {};
      // 评论类型
      final type = commentPlatform.value == CommentPlatform.gitalk ? GitalkSetting : DisqusSetting;
      // 基础
      configs.addAll(fieldConfigs.value[CommentSetting] ?? {});
      // 添加对应评论的字段
      configs.addAll(fieldConfigs.value[type] ?? {});
      // 构建
      return _buildContent(items: configs);
    });
  }

  /// 构建字段列表
  ///
  /// [items] 字段配置
  ///
  /// [over] 需要进行覆盖的字段控件
  Widget _buildContent({required TMap<ConfigBase> items, TMap<Widget>? over}) {
    List<Widget> children = [];
    for (var entry in items.entries) {
      final key = entry.key;
      children.add(
        over?[key] ??
            ArrayWidget.create(
              config: entry.value,
              isVertical: false,
              usePassword: hidePasswords[key],
              onChanged: (str) => _fieldChange(str, field: key),
            ),
      );
    }
    // 构建列表
    return ListView.builder(
      shrinkWrap: true,
      itemCount: children.length,
      itemBuilder: (ctx, index) {
        return Padding(
          padding: kVer12Hor24,
          child: children[index],
        );
      },
    );
  }

  /// 构建底部按钮
  Widget _buildBottom() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 0.4,
            color: Get.theme.colorScheme.outlineVariant,
          ),
        ),
      ),
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
      IconButton(
        onPressed: _resetConfig,
        icon: const Icon(PhosphorIconsRegular.clockCounterClockwise),
        tooltip: Tran.reset.tr,
      ),
      IconButton(
        onPressed: _saveConfig,
        icon: const Icon(PhosphorIconsRegular.boxArrowDown),
        tooltip: Tran.save.tr,
      ),
    ];
  }

  /// 构建域名字段
  Widget _buildDomainField() {
    InputConfig domain = fieldConfigs.value[RemoteSetting]![_domain] as InputConfig;
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
    return {
      _remotePlatform: [
        for (var item in DeployPlatform.values)
          SelectOption()
            ..label = item.name.tr
            ..value = item.name,
      ],
      _enabledProxy: [
        for (var item in ProxyWay.values) SelectOption().setValues(label: item.name.tr, value: item.name),
      ],
      _connectType: [
        for (var item in nameLists[_connectType]!) SelectOption().setValues(label: item.tr, value: item),
      ],
      _commentPlatform: [
        for (var item in CommentPlatform.values) SelectOption().setValues(label: item.name.tr, value: item.name),
      ],
    };
  }

  /// 获取 [T] 对应的 [FieldType] 映射
  TMap<FieldType> _getConfigMap<T>({TMap<FieldType>? fieldTypes}) {
    final values = '{}'.fromJson<T>()!.toMap()!;
    return values.map((key, value) => MapEntry(key, fieldTypes?[key] ?? FieldType.input));
  }

  /// 获取 [RemoteSetting] 映射
  TMap<FieldType> _getRemoteConfigMap() {
    final TMap<FieldType> maps = _getConfigMap<RemoteSetting>();
    maps.addAll({
      _remotePlatform: FieldType.select,
      _enabledProxy: FieldType.radio,
      _connectType: FieldType.radio,
    });
    return maps;
  }

  /// 获取远程配置所需要的命名列表
  TMapList<Object, String> _getNameList() {
    List<String> getKeys<T>() => '{}'.fromJson<T>()!.toMap()!.keys.toList();
    // DeployPlatform.coding
    final codingNames = getKeys<RemoteCoding>();
    // DeployPlatform.github
    final githubNames = List.of(codingNames);
    githubNames.remove(_tokenUsername);
    // DeployPlatform.sftp
    final sftpNames = getKeys<RemoteSftp>();
    final index = sftpNames.indexOf(_password);
    // 插入
    sftpNames.insert(index, _connectType);
    return {
      RemoteBase: getKeys<RemoteBase>(),
      RemoteProxy: getKeys<RemoteProxy>(),
      DeployPlatform.github: githubNames,
      DeployPlatform.gitee: githubNames,
      DeployPlatform.coding: codingNames,
      DeployPlatform.netlify: getKeys<RemoteNetlify>(),
      DeployPlatform.sftp: sftpNames,
      _connectType: [_password, _privateKey],
    };
  }

  /// 获取 [FieldType] 对应的 [ConfigBase] 配置
  TMaps<Type, ConfigBase> _getFieldConfig() {
    try {
      TMaps<Type, ConfigBase> configs = {};
      for (var MapEntry(:key, :value) in fieldNames.entries) {
        // 值
        TMap<dynamic>? values;
        if (key == RemoteSetting) {
          // 远程
          values = site.remote.toMap();
          final strList = nameLists[_connectType]!;
          values?.addAll({_connectType: sftpIsKey.value ? strList.last : strList.first});
        } else if (key == CommentSetting) {
          // 基础评论
          values = site.comment.toMap();
        } else if (key == GitalkSetting) {
          // gitalk 评论
          values = site.comment.gitalkSetting.toMap();
        } else if (key == DisqusSetting) {
          // disqus 评论
          values = site.comment.disqusSetting.toMap();
        }
        configs[key] = site.createRenderConfig(
          fields: value,
          fieldValues: values,
          fieldNotes: fieldNotes,
          fieldHints: fieldHints,
          options: fieldOptions,
        );
      }
      return configs;
    } catch (e) {
      Log.w('remoteWidget._getFieldConfig: remote.toMap failed: \n$e');
      return {};
    }
  }

  /// 更新域名字段
  void _updateDomainField() {
    InputConfig field = fieldConfigs.value[RemoteSetting]![_domain]! as InputConfig;
    if (field.value.startsWith('https://')) {
      domainPrefix = 'https://';
    } else {
      domainPrefix = 'http://';
    }
    domainController.text = field.value.substring(domainPrefix.length);
  }

  /// 字段变化时调用
  void _fieldChange(dynamic str, {String? field}) {
    switch (field) {
      case _remotePlatform:
        platform.value = DeployPlatform.values.firstWhereOrNull((t) => t.name == str) ?? DeployPlatform.github;
        site.remote.platform = platform.value;
        checkPublish.value = site.checkPublish;
        break;
      case _commentPlatform:
        commentPlatform.value = CommentPlatform.values.firstWhereOrNull((t) => t.name == str) ?? CommentPlatform.gitalk;
        site.comment.commentPlatform = commentPlatform.value;
        break;
      case _enabledProxy:
        proxyWay.value = ProxyWay.values.firstWhereOrNull((t) => t.name == str) ?? ProxyWay.direct;
        site.remote.enabledProxy = proxyWay.value;
        break;
      case _connectType:
        sftpIsKey.value = nameLists[_connectType]!.last == str;
        break;
    }
  }

  /// 初始化配置
  void _initConfig() {
    final remote = site.remote;
    platform.value = remote.platform;
    commentPlatform.value = site.comment.commentPlatform;
    checkPublish.value = site.checkPublish;
    proxyWay.value = remote.enabledProxy;
    sftpIsKey.value = remote.privateKey.isNotEmpty;
    // 配置
    fieldConfigs.value = _getFieldConfig();
  }

  /// 重置配置
  void _resetConfig() => _initConfig();

  /// 保持配置
  void _saveConfig() async {
    try {
      final configs = fieldConfigs.value;
      final remotes = configs[RemoteSetting]!.values.toList();
      final comments = configs[CommentSetting]!.values.toList();
      comments.addAll(configs[GitalkSetting]!.values);
      comments.addAll(configs[DisqusSetting]!.values);
      site.updateRemoteConfig(remotes: remotes, comments: comments);
    } catch (e) {
      Get.error(Tran.saveError);
    }
  }

  /// 检测远程连接
  void _testConnection() async {
    await site.remoteDetect();
  }
}
