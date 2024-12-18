const String themeSaveEvent = 'theme-save';

typedef TAsyncFun<T> = Future<void> Function(T? value);
typedef TEvents = Map<Object, List<EventData>>;

/// 事件数据
class EventData<T> {
  EventData({
    required this.callback,
    this.once = false,
    this.id,
  });

  /// 回调
  final TAsyncFun<T> callback;

  /// 执行一次
  final bool once;

  /// 事件 ID
  final Object? id;
}

/// 事件总线
mixin class EventBus {
  ///私有构造函数
  EventBus._internal();

  ///保存单例
  static final EventBus _singleton = EventBus._internal();

  /// 工厂构造函数
  factory EventBus() => _singleton;

  /// 保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  final TEvents _queue = {};

  /// 添加订阅者
  void on<T>(Object event, TAsyncFun<T> callback, {bool once = false, Object? id, bool cover = false}) {
    _addEvent(event, callback, once: false, id: id);
  }

  /// 添加一次性订阅者
  void once<T>(Object event, TAsyncFun<T> callback, {Object? id, bool cover = false}) {
    _addEvent(event, callback, once: true, id: id);
  }

  void _addEvent<T>(Object event, TAsyncFun<T> callback, {bool once = false, Object? id, bool cover = false}) {
    var lists = _queue[event] ??= [];
    if (lists.isEmpty) {
      // 可以直接添加
      lists.add(EventData<T>(callback: callback, once: once, id: id));
    }
    for (var q in lists) {
      // ID 不可重复
      var result = id != null && q.id == id;
      // once 为 true 的 callback 不可重复
      result == result || once == true && q.once == true && q.callback == callback;
      // 为 true 时返回
      if (result) {
        if (cover) {
          lists.remove(q);
          lists.add(EventData<T>(callback: callback, once: once, id: id));
        }
        return;
      }
    }
    // 可以直接添加
    lists.add(EventData<T>(callback: callback, once: once, id: id));
  }

  /// 移除订阅者
  void off<T>(Object event, {TAsyncFun<T>? callback, bool once = false, Object? id, T? param}) {
    var lists = _queue[event];
    if (lists == null || lists.isEmpty) return;
    lists.removeWhere((EventData q) {
      if (id != null) {
        // 删除指定 ID
        if (q.id == id) return true;
      } else if (once) {
        // 删除 once 为 true 的 callback
        if (q.once && q.callback == callback) return true;
      } else if (callback != null) {
        // 删除相等的 callback
        if (q.callback == callback) return true;
      } else {
        // id == null && once == null && callback == null 时全部删除
        return true;
      }
      // 其它情况跳过
      return false;
    });
  }

  /// 触发事件，事件触发后该事件所有订阅者会被调用
  Future<void> emit<T>(Object event, {T? param}) async {
    var lists = _queue[event];
    if (lists == null || lists.isEmpty) return;
    List<Future<void>> tasks = [];
    //反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (var i = lists.length - 1; i >= 0; i--) {
      var item = lists[i];
      tasks.add(item.callback(param));
      if (item.once) {
        lists.removeAt(i);
      }
    }
    await Future.wait(tasks);
  }
}
