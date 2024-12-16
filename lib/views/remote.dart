import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show FirstWhereOrNullExt, Get, GetNavigationExt, Inst, Obx, Trans, BoolExtension;
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
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';

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
  static const _tokenUsername = 'tokenUsername';
  static const _showComment = 'showComment';
  static const _branch = 'branch';
  static const _cname = 'cname';
  static const _token = 'token';
  static const _netlifyAccessToken = 'netlifyAccessToken';

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 当前选择的平台
  late final RxObject<DeployPlatform> platform;

  /// 当前选择的评论平台
  late final RxObject<CommentPlatform> commentPlatform;

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

  /// 字段名称列表
  late final TMapList<Object, String> nameLists;

  /// 字段名字
  late final TMaps<Type, FieldType> fieldNames;

  /// 字段配置
  late final TMaps<Type, ConfigBase> fieldConfigs;

  // 字段的左下角提示
  final fieldNotes = const {
    _privateKey: 'privateKeyTip',
    'remotePath': 'remotePathTip',
  };

  // 字段的内部提示
  final fieldHints = const {
    _branch: 'branch',
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
    final remote = site.remote;
    platform = remote.platform.obs;
    commentPlatform = site.comment.commentPlatform.obs;
    proxyWay.value = remote.enabledProxy;
    sftpIsKey.value = remote.privateKey.isNotEmpty;
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
    // 配置
    fieldConfigs = _getFieldConfig();
    // 域名
    _updateDomainField();
  }

  @override
  void dispose() {
    platform.dispose();
    proxyWay.dispose();
    sftpIsKey.dispose();
    commentPlatform.dispose();
    domainController.dispose();
    for (var item in hidePasswords.values) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GroupWidget(
              isTop: true,
              groups: const {'basicSetting', 'commentSetting'},
              children: [
                Padding(
                  padding: kTopPadding16,
                  child: _buildRemoteConfig(),
                ),
                Padding(
                  padding: kTopPadding16,
                  child: _buildCommentConfig(),
                ),
              ],
            ),
          ),
          _buildBottom(),
        ],
      ),
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

      final configs = fieldConfigs[RemoteSetting] ?? {};
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
      configs.addAll(fieldConfigs[CommentSetting] ?? {});
      // 添加对应评论的字段
      configs.addAll(fieldConfigs[type] ?? {});
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
    return const Text('底部按钮');
  }

  /// 构建域名字段
  Widget _buildDomainField() {
    InputConfig domain = fieldConfigs[RemoteSetting]![_domain] as InputConfig;
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
    InputConfig field = fieldConfigs[RemoteSetting]![_domain]! as InputConfig;
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
        break;
      case _commentPlatform:
        commentPlatform.value = CommentPlatform.values.firstWhereOrNull((t) => t.name == str) ?? CommentPlatform.gitalk;
        break;
      case _enabledProxy:
        proxyWay.value = ProxyWay.values.firstWhereOrNull((t) => t.name == str) ?? ProxyWay.direct;
        break;
      case _connectType:
        sftpIsKey.value = nameLists[_connectType]!.last == str;
        break;
    }
  }
}
