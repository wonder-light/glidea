import 'package:collection/collection.dart' show IterableExtension;
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/library/worker/worker.dart';

/// jinja 使用的筛选器
class RenderFilter {
  static TMap<Function> filters = {
    'sort': __doSort,
    'groupby': __doGroupBy,
    'substring': _doSubstring,
    'sublist': _doSublist,
    'dedup': _doDeduplication,
    'print': _doPrint,
  };

  /// sort 筛选器, 将列表进行排序
  static Iterable<Object?> __doSort(Iterable<Object?>? values, {bool reverse = false, String? attribute}) {
    if (attribute?.isEmpty ?? true) {
      values = values?.sorted((t1, t2) => t1.hashCode - t2.hashCode);
    } else {
      values = values?.sorted((t1, t2) => (t1 as dynamic)[attribute].hashCode - (t2 as dynamic)[attribute].hashCode);
    }
    // 反转
    if (reverse) {
      values = values?.toList().reversed;
    }

    return values ?? [];
  }

  /// 对列表 [values] 按照 [group] 属性进行分组, 如果 [group] 无效, 则使用自身值进行分组
  static Map<dynamic, Iterable<Object?>> __doGroupBy(Iterable<Object?>? values, {Object? attribute}) {
    return values?.groupListsBy((item) => attribute == null ? item : (item as dynamic)[attribute]) ?? {};
  }

  /// 如果 value 是字符串, 则返回这个字符串的子字符串从 start 开始（包括）到 end 结束
  ///
  /// 如果 value 是 Map, 则对其 attribute 属性进行操作
  static Object _doSubstring(Object value, {int start = 0, int? end, Object? attribute}) {
    if (value is String) {
      value = value.substring(start, end);
    } else if (value is Map && attribute != null) {
      value[attribute] = value[attribute].substring(start, end);
    }
    return value;
  }

  /// sublist 筛选器, 返回一个包含 start 和 end 之间元素的新列表
  static Iterable<Object?> _doSublist(Iterable<Object?>? values, {int start = 0, int? end}) {
    return values?.toList().sublist(start, end) ?? [];
  }

  /// 对列表 [values] 的属性 [attribute] 进行去重, 如果 [attribute] 无效, 则使用自身值
  static Set<Object?> _doDeduplication(Iterable<Object?>? values, {String? attribute}) {
    if (values == null) return {};
    if (attribute?.isNotEmpty ?? false) {
      Set<dynamic> sets = {};
      List<Object?> lists = [];
      for (var item in values) {
        final att = (item as dynamic)[attribute];
        if (sets.contains(att)) continue;
        sets.add(att);
        lists.add(item);
      }
      values = lists;
    }

    return values.toSet() ?? {};
  }

  /// 打印 value
  static void _doPrint(Object? value) {
    BackgroundProcess.instance?.log(value.toString());
  }
}
