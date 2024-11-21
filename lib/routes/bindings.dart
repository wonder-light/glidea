import 'package:get/get.dart' show Binding, Bind;
import 'package:glidea/controller/site.dart';

/// 站点 bind
class SiteBind extends Binding {
  static final bings = [
    Bind.put<SiteController>(SiteController(), tag: 'site', permanent: true),
  ];

  @override
  List<Bind> dependencies() => bings;
}
