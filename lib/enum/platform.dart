import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;


/// 部署的平台
@jsonSerializable
enum DeployPlatform {
  github,
  coding,
  sftp,
  gitee,
  netlify,
}

/// 代理方式
@jsonSerializable
enum ProxyWay {
  direct,
  proxy,
  none,
}
