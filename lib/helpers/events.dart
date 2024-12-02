const String themeSaveEvent = 'theme-save';
const String themeSavedEvent = 'theme-saved';
const String themeCustomConfigSaveEvent = 'theme-custom-config-save';
const String themeCustomConfigSavedEvent = 'theme-custom-config-saved';
const String settingSaveEvent = 'setting-save';
const String settingSavedEvent = 'setting-saved';
const String commentSettingSaveEvent = 'comment-setting-save';
const String commentSettingSavedEvent = 'comment-setting-saved';
const String faviconUploadEvent = 'favicon-upload';
const String faviconUploadedEvent = 'favicon-uploaded';
const String avatarUploadEvent = 'avatar-upload';
const String avatarUploadedEvent = 'avatar-uploaded';
const String sitePublishEvent = 'site-publish';
const String sitePublishedEvent = 'site-published';
const String remoteDetectEvent = 'remote-detect';
const String remoteDetectedEvent = 'remote-detected';
const String appPostCreateEvent = 'app-post-create';
const String appPostCreatedEvent = 'app-post-created';
const String appPostDeleteEvent = 'app-post-delete';
const String appPostDeletedEvent = 'app-post-deleted';
const String appPostListDeleteEvent = 'app-post-list-delete';
const String appPostListDeletedEvent = 'app-post-list-deleted';
const String imageUploadEvent = 'image-upload';
const String imageUploadedEvent = 'image-uploaded';
const String htmlRenderEvent = 'html-render';
const String htmlRenderedEvent = 'html-rendered';
const String menuDeleteEvent = 'menu-delete';
const String menuDeletedEvent = 'menu-deleted';
const String menuSaveEvent = 'menu-save';
const String menuSavedEvent = 'menu-saved';
const String menuSortEvent = 'menu-sort';
const String menuSortedEvent = 'menu-sorted';
const String siteReloadEvent = 'site-reload';
const String appSiteReloadEvent = 'app-site-reload';
const String appSiteLoadedEvent = 'app-site-loaded';
const String appSourceFolderSettingEvent = 'app-source-folder-setting';
const String appSourceFolderSetEvent = 'app-source-folder-set';
const String appPreviewServerPortGetEvent = 'app-preview-server-port-get';
const String appPreviewServerPortGotEvent = 'app-preview-server-port-got';
const String tagDeleteEvent = 'tag-delete';
const String tagDeletedEvent = 'tag-deleted';
const String tagSaveEvent = 'tag-save';
const String tagSavedEvent = 'tag-saved';
const String clickMenuSaveEvent = 'click-menu-save';
const String snackbarDisplayEvent = 'snackbar-display';
const String logErrorEvent = 'log-error';
const String previewEvent = 'Preview';
const String publishEvent = 'Preview';
const String clientEvent = 'Client';
const String postEvent = 'Post';
const String menuEvent = 'Menu';
const String settingEvent = 'Setting';
const String tagsEvent = 'Tags';
const String themeEvent = 'Theme';

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
