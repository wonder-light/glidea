import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glidea/components/remote/comment.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';

/// 远程设置控件
class RemoteSettingWidget extends CommentSettingWidget {
  const RemoteSettingWidget({super.key});

  @override
  State<StatefulWidget> createState() => RemoteSettingWidgetState();
}

class RemoteSettingWidgetState extends CommentSettingWidgetState {
  /// 代理方式
  late ProxyWay proxyWay = site.remote.enabledProxy;

  /// 域名的文本控制器
  final TextEditingController domainController = TextEditingController();

  @override
  void dispose() {
    domainController.dispose();
    super.dispose();
  }

  @override
  Widget? buildOverride(ConfigBase item, String key, int index) => null;

  @override
  TMap<ConfigBase> getConfigs() {
    final configs = site.remoteWidgetConfigs;
    final items = {...?configs[RemoteBase], ...?configs[platform]};
    // 代理
    if (platform != DeployPlatform.sftp) {
      // 代理, 全部加进去
      items.addAll(configs[RemoteProxy] ?? {});
      // 直连
      if (proxyWay == ProxyWay.direct) {
        items.remove(proxyPathField);
        items.remove(proxyPortField);
      }
    }
    return items;
  }

  @override
  ValueChanged? getChange(String key) {
    return switch (key) {
      platformField => _changePlatform,
      enabledProxyField => _changeProxy,
      _ => null,
    };
  }

  @override
  void initConfig() {
    if (hidePasswords.isEmpty) {
      hidePasswords = {
        passwordField: true,
        privateKeyField: true,
        accessTokenField: true,
        tokenField: true,
      };
    }
    platform = site.remote.platform;
    // 设置域名字段
    domainController.text = site.remote.domain;
  }

  @override
  Future<void> resetConfig() async {
    await site.loadRemoteConfig();
    setState(initConfig);
  }

  /// 字段变化时调用
  void _changePlatform(dynamic str) {
    final value = DeployPlatform.values.firstWhereOrNull((t) => t.name == str) ?? DeployPlatform.github;
    setState(() => platform = value);
  }

  ///代理更改时调用
  void _changeProxy(dynamic str) {
    final value = ProxyWay.values.firstWhereOrNull((t) => t.name == str) ?? ProxyWay.direct;
    setState(() => proxyWay = value);
  }
}
