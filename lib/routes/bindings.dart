import 'package:glidea/controller/site.dart';
import 'package:get/get.dart' show Binding, Bind;

/// 站点 bind
class SiteBind extends Binding {
  @override
  List<Bind> dependencies() => [
        Bind.lazyPut<SiteController>(() => SiteController()),
      ];
}
