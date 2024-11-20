import 'package:get/get.dart';
import 'package:glidea/controller/site.dart';

/// 站点 bind
class SiteBind extends Binding {
  @override
  List<Bind> dependencies() => [
        Bind.lazyPut<SiteController>(() => SiteController()),
      ];
}
