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
import 'package:glidea/models/render.dart';

class RemoteView extends StatefulWidget {
  const RemoteView({super.key});

  @override
  State<RemoteView> createState() => _RemoteViewState();
}

class _RemoteViewState extends State<RemoteView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 当前选择的平台
  late final RxObject<DeployPlatform> platform;

  /// [platform] 的字段配置
  late final SelectConfig platformField;

  /// 域名的字段配置
  late final InputConfig domainField;

  /// 域名的文本控制器
  final TextEditingController domainController = TextEditingController();

  /// 域名前缀
  String domainPrefix = '';

  /// 主题配置中变量名称与字段类型的映射
  late final Map<String, ConfigBase> fieldMaps;

  /// 代理方式
  final proxyWay = ProxyWay.direct.obs;

  /// SFTP 的链接方式
  ///
  /// password, key
  final sftpIsKey = false.obs;

  /// 字段名称列表, 都是对应着 [InputConfig]
  final fieldLists = const [
    ['repository', 'branch', 'username', 'email', 'tokenUsername', 'token', 'cname'],
    ['port', 'server', 'username', 'password', 'privateKey', 'remotePath'],
    ['netlifySiteId', 'netlifyAccessToken'],
    ['proxyPath', 'proxyPort'],
    ['password', 'privateKey'],
  ];

  // 字段的左下角提示
  final fieldNotes = const {
    'privateKey': 'privateKeyTip',
    'remotePath': 'remotePathTip',
  };

  // 字段的内部提示
  final fieldHints = const {
    'branch': 'branch',
    'domain': 'my_domain.com',
    'cname': 'my_domain.com',
  };

  /// 需要隐藏密码的字段
  final hidePasswords = {
    'password': true.obs,
    'privateKey': true.obs,
    'netlifyAccessToken': true.obs,
    'token': true.obs,
  };

  @override
  void initState() {
    super.initState();
    final remote = site.remote;
    platform = remote.platform.obs;
    proxyWay.value = remote.enabledProxy;
    sftpIsKey.value = remote.privateKey.isNotEmpty;
    domainField = _updateDomainField();
    platformField = _updatePlatformField();
    fieldMaps = _getFieldMaps();
  }

  @override
  void dispose() {
    platform.dispose();
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
              onTap: (index) => site.isThemeCustomPage = index > 0,
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
      final List<Widget> children = [];
      // 平台
      children.add(ArrayWidget.create(config: platformField, onChanged: _setPlatform, isVertical: false));
      // 域名
      children.add(_buildDomainField());
      // 其它字段
      final List<String> fields = [];
      switch (platform.value) {
        case DeployPlatform.coding || DeployPlatform.github || DeployPlatform.gitee:
          fields.addAll(fieldLists[0]);
          if (platform.value != DeployPlatform.coding) {
            fields.remove('tokenUsername');
          }
          break;
        case DeployPlatform.sftp:
          fields.addAll(fieldLists[1]);
          fields.replaceRange(3, 5, ['connectType', fieldLists[4][sftpIsKey.value ? 1 : 0]]);
          break;
        case DeployPlatform.netlify:
          fields.addAll(fieldLists[2]);
          break;
      }
      // 代理
      if (platform.value != DeployPlatform.sftp) {
        fields.add('Proxy');
        if (proxyWay.value != ProxyWay.direct) {
          fields.addAll(fieldLists[3]);
        }
      }
      // 添加
      children.addAll([
        for (var item in fields)
          ArrayWidget.create(
            config: fieldMaps[item]!,
            isVertical: false,
            onChanged: (str) => _fieldChange(str, field: item),
            usePassword: hidePasswords[item],
          ),
      ]);
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
    });
  }

  /// 构建评论设置
  Widget _buildCommentConfig() {
    return const Text('评论');
  }

  /// 构建底部按钮
  Widget _buildBottom() {
    return const Text('底部按钮');
  }

  /// 构建域名字段
  Widget _buildDomainField() {
    return InputWidget(
      controller: domainController,
      config: domainField.obs,
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
            domainField.value = domainPrefix + domainController.text;
          },
        ),
      ),
      onChanged: (str) {
        domainField.value = domainPrefix + domainController.text;
      },
    );
  }

  /// 更新域名字段
  InputConfig _updateDomainField({InputConfig? field}) {
    const key = 'domain';
    field ??= InputConfig();
    field
      ..name = key
      ..label = key.tr
      ..value = site.domain
      ..hint = fieldHints[key] ?? '';
    if (field.value.startsWith('https://')) {
      domainPrefix = 'https://';
    } else {
      domainPrefix = 'http://';
    }
    domainController.text = field.value.substring(domainPrefix.length);
    return field;
  }

  /// 更新平台字段
  SelectConfig _updatePlatformField({SelectConfig? field}) {
    field ??= SelectConfig();
    field
      ..name = 'platform'
      ..label = 'platform'.tr
      ..value = platform.value.name
      ..options = [
        for (var item in DeployPlatform.values)
          SelectOption()
            ..label = item.name.tr
            ..value = item.name,
      ];
    return field;
  }

  /// 设置字段映射
  Map<String, ConfigBase> _getFieldMaps() {
    // 初始值
    final Map<String, ConfigBase> maps = {
      for (var field in fieldLists.expand((t) => t).toSet()) field: InputConfig(),
    };
    maps.addAll({
      'Proxy': RadioConfig()
        ..value = proxyWay.value.name
        ..options = [
          for (var item in ProxyWay.values) SelectOption().setValues(label: item.name.tr, value: item.name),
        ],
      'connectType': RadioConfig()
        ..value = sftpIsKey.value ? fieldLists[4][1] : fieldLists[4][0]
        ..options = [
          for (var item in fieldLists[4]) SelectOption().setValues(label: item.tr, value: item),
        ],
    });
    // 远程设置
    final items = site.remote.toMap();
    // 设置 label、value 等等
    for (var entry in maps.entries) {
      // 存储的值
      final item = items?[entry.key];
      // 设置当前值
      entry.value
        ..value = item ?? entry.value.value
        ..name = entry.key
        ..label = entry.key.tr
        ..note = fieldNotes[entry.key] ?? '';
    }
    // 设置 hint
    for (var entry in fieldHints.entries) {
      if (maps[entry.key] case InputConfig obj) {
        obj.hint = entry.value;
      }
    }
    return maps;
  }

  /// 设置 [platform]
  void _setPlatform(dynamic str) => _fieldChange(str, field: platformField.name);

  /// 字段变化时调用
  void _fieldChange(dynamic str, {String? field}) {
    switch (field) {
      case 'platform':
        platform.value = DeployPlatform.values.firstWhereOrNull((t) => t.name == str) ?? DeployPlatform.github;
        break;
      case 'Proxy':
        proxyWay.value = ProxyWay.values.firstWhereOrNull((t) => t.name == str) ?? ProxyWay.direct;
        break;
      case 'connectType':
        sftpIsKey.value = fieldLists[4][1] == str;
        break;
    }
  }
}
