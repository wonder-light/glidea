import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/enum/enums.dart';

/// 基础远程设置
@jsonSerializable
class RemoteBase {
  /// 部署平台
  @JsonProperty()
  DeployPlatform platform = DeployPlatform.github;

  /// 域名
  @JsonProperty()
  String domain = '';
}

/// github 的远程设置
@jsonSerializable
class RemoteGithub extends RemoteBase {
  /// 仓库
  @JsonProperty()
  String repository = '';

  /// 分支
  @JsonProperty()
  String branch = '';

  /// 用户名
  @JsonProperty()
  String username = '';

  /// 邮箱
  @JsonProperty()
  String email = '';

  /// 令牌
  @JsonProperty()
  String token = '';

  /// 域名解析 DNS 解析的 cname 值
  @JsonProperty()
  String cname = '';
}

/// gitee 的远程设置
@jsonSerializable
class RemoteGitee extends RemoteGithub {}

/// coding pages 的远程设置
@jsonSerializable
class RemoteCoding extends RemoteGitee {
  /// token 用户名
  @JsonProperty()
  String tokenUsername = '';
}

/// netlify 的远程设置
@jsonSerializable
mixin class RemoteNetlify {
  /// netflix访问令牌
  @JsonProperty()
  String netlifyAccessToken = '';

  /// netflix访问密钥
  @JsonProperty()
  String netlifySiteId = '';
}

/// Sftp 的远程设置
@jsonSerializable
mixin class RemoteSftp {
  /// 端口
  @JsonProperty()
  String port = '';

  /// 服务
  @JsonProperty()
  String server = '';

  /// 用户名
  @JsonProperty()
  String username = '';

  /// 密码
  @JsonProperty()
  String password = '';

  /// 私钥
  @JsonProperty()
  String privateKey = '';

  /// 远程路径
  @JsonProperty()
  String remotePath = '';
}

/// proxy 的远程设置
@jsonSerializable
mixin class RemoteProxy {
  /// 启用代理
  @JsonProperty()
  ProxyWay enabledProxy = ProxyWay.direct;

  /// 代理路径
  @JsonProperty()
  String proxyPath = '';

  /// 代理端口
  @JsonProperty()
  String proxyPort = '';
}

/// 远程设置
@jsonSerializable
class RemoteSetting extends RemoteCoding with RemoteProxy, RemoteSftp, RemoteNetlify {}

/// disqus 评论设置
@jsonSerializable
class DisqusSetting {
  /// API 键
  @JsonProperty()
  String api = '';

  /// API 值
  @JsonProperty()
  String apikey = '';

  /// 名称
  @JsonProperty()
  String shortname = '';
}

/// gitalk 评论设置
@jsonSerializable
class GitalkSetting {
  /// ID
  @JsonProperty()
  String clientId = '';

  /// 密钥
  @JsonProperty()
  String clientSecret = '';

  /// 存储库
  @JsonProperty()
  String repository = '';

  /// 拥有者
  @JsonProperty()
  String owner = '';
}

/// 评论设置 评论设置
@jsonSerializable
class CommentSetting {
  /// 评论平台
  @JsonProperty()
  CommentPlatform commentPlatform = CommentPlatform.gitalk;

  // 显示评论
  @JsonProperty()
  bool showComment = false;

  // disqus 评论
  @JsonProperty()
  DisqusSetting disqusSetting = DisqusSetting();

  // gitalk 评论
  @JsonProperty()
  GitalkSetting gitalkSetting = GitalkSetting();
}
