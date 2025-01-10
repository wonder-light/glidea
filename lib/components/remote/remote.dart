import 'dart:async' show Completer;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Inst, Obx, Trans, BoolExtension;
import 'package:glidea/components/Common/dropdown.dart';
import 'package:glidea/components/Common/loading.dart';
import 'package:glidea/components/render/array.dart';
import 'package:glidea/components/render/input.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';

/// 远程设置控件
class RemoteSettingWidget extends StatefulWidget {
  const RemoteSettingWidget({super.key});

  @override
  State<RemoteSettingWidget> createState() => RemoteSettingWidgetState();
}

class RemoteSettingWidgetState extends State<RemoteSettingWidget> {
  static const _domain = 'domain';
  static const _platform = 'platform';
  static const _cname = 'cname';
  static const _token = 'token';
  static const _branch = 'branch';
  static const _remotePath = 'remotePath';
  static const _privateKey = 'privateKey';
  static const _password = 'password';
  static const _proxyPath = 'proxyPath';
  static const _proxyPort = 'proxyPort';
  static const _enabledProxy = 'enabledProxy';
  static const _accessToken = 'accessToken';

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 初始化时的任务
  Completer initTask = Completer();

  /// 字段配置
  final configs = <Object, TMap<ConfigBase>>{}.obs;

  /// 当前选择的平台
  late final platform = site.remote.platform.obs;

  /// 代理方式
  late final proxyWay = site.remote.enabledProxy.obs;

  /// 域名的文本控制器
  final TextEditingController domainController = TextEditingController();

  /// 字段的左下角提示
  final notes = {_privateKey: Tran.privateKeyTip, _remotePath: Tran.remotePathTip};

  /// 字段的内部提示
  final hints = {_branch: Tran.branch, _domain: 'my_domain.com', _cname: 'my_domain.com'};

  /// 字段选项
  TMapList<String, SelectOption>? options;

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
    initConfig();
  }

  @override
  void dispose() {
    domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initTask.future,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingWidget());
        }
        return Obx(() {
          final items = {...?configs.value[RemoteBase], ...?configs.value[platform.value]};
          // 代理
          if (platform.value != DeployPlatform.sftp) {
            // 代理, 全部加进去
            items.addAll(configs.value[RemoteProxy] ?? {});
            // 直连
            if (proxyWay.value == ProxyWay.direct) {
              items.remove(_proxyPath);
              items.remove(_proxyPort);
            }
          }
          // 构建列表
          return ListView.separated(
            shrinkWrap: true,
            padding: kVer12Hor24,
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              final key = items.keys.elementAt(index);
              // 设置域名
              if (key == _domain) {
                return _buildDomainField();
              }
              return ArrayWidget.create(
                config: items[key] as ConfigBase,
                isVertical: false,
                usePassword: hidePasswords[key],
                onChanged: switch (key) {
                  _platform => _changePlatform,
                  _enabledProxy => _changeProxy,
                  _ => null,
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Padding(padding: kVerPadding8),
          );
        });
      },
    );
  }

  /// 构建域名字段
  Widget _buildDomainField() {
    final domain = configs.value[RemoteBase]![_domain] as InputConfig;
    final isHttps = domain.value.startsWith('https://');
    return InputWidget(
      controller: domainController,
      config: domain.obs,
      isVertical: false,
      prefixIcon: Padding(
        padding: kRightPadding8,
        child: DropdownWidget(
          initValue: isHttps ? 'https://' : 'http://',
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
          onSelected: (str) => domain.value = str + domainController.text,
        ),
      ),
      onChanged: (str) {
        final isHttps = domain.value.startsWith('https://');
        domain.value = (isHttps ? 'https://' : 'http://') + domainController.text;
      },
    );
  }

  /// 初始化字段
  Future<void> initConfig() async {
    initTask = Completer();
    // 设置配置
    final remote = site.remote.toMap()!;
    options ??= {
      for (var MapEntry(:key, :value) in {_platform: DeployPlatform.values, _enabledProxy: ProxyWay.values}.entries)
        key: [
          for (var t in value)
            SelectOption()
              ..label = t.name.tr
              ..value = t.name,
        ],
    };
    configs.value = {
      for (var key in DeployPlatform.values)
        key: site.createRenderConfig(
          fields: {for (var item in (remote[key.name] as Map).keys) item: FieldType.input},
          fieldValues: remote[key.name],
          fieldNotes: notes,
          fieldHints: hints,
        ),
      RemoteProxy: site.createRenderConfig(
        fields: {_enabledProxy: FieldType.radio, _proxyPort: FieldType.input, _proxyPath: FieldType.input},
        fieldValues: remote,
        options: options,
      ),
      RemoteBase: site.createRenderConfig(
        fields: {_platform: FieldType.select, _domain: FieldType.input},
        fieldValues: remote,
        options: options,
      ),
    };
    // 设置域名字段
    final domain = site.remote.domain;
    final prefix = RegExp(r'https?://').stringMatch(domain);
    domainController.text = prefix != null ? domain.substring(prefix.length) : domain;
    // 完成
    initTask.complete(true);
  }

  /// 字段变化时调用
  void _changePlatform(dynamic str) {
    platform.value = DeployPlatform.values.firstWhereOrNull((t) => t.name == str) ?? DeployPlatform.github;
    site.remote.platform = platform.value;
  }

  void _changeProxy(dynamic str) {
    proxyWay.value = ProxyWay.values.firstWhereOrNull((t) => t.name == str) ?? ProxyWay.direct;
    site.remote.enabledProxy = proxyWay.value;
  }
}
