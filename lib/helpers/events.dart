import 'package:flutter/foundation.dart' show AsyncValueSetter;
import 'package:glidea/interfaces/types.dart';

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

/// 事件总线
mixin class EventBus {
  ///私有构造函数
  EventBus._internal();

  ///保存单例
  static final EventBus _singleton = EventBus._internal();

  /// 工厂构造函数
  factory EventBus() => _singleton;

  /// 保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  final TEventMap _queue = {};

  /// 保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列 - 一次性订阅
  final TEventMap _once = {};

  /// 添加订阅者
  void on(Object eventName, AsyncValueSetter<dynamic> f) {
    _queue[eventName] ??= [];
    _queue[eventName]!.add(f);
  }

  /// 添加一次性订阅者
  void once(Object eventName, AsyncValueSetter<dynamic> f) {
    _once[eventName] ??= [];
    _once[eventName]!.add(f);
  }

  /// 移除订阅者
  void off(Object eventName, [AsyncValueSetter<dynamic>? f]) {
    _offEvent(_queue, eventName, f);
    _offEvent(_once, eventName, f);
  }

  /// 移除订阅者
  void _offEvent(TEventMap queue, Object eventName, [AsyncValueSetter<dynamic>? f]) {
    var list = queue[eventName];
    if (list == null) return;
    if (f == null) {
      queue.remove(eventName);
    } else {
      list.remove(f);
    }
  }

  /// 触发事件，事件触发后该事件所有订阅者会被调用
  Future<void> emit(Object eventName, [dynamic arg]) async {
    await Future.wait(await _emitEvent(_once, eventName, arg).toList());
    // 移除 once 对应的事件
    _once.remove(eventName);
    await Future.wait(await _emitEvent(_queue, eventName, arg).toList());
  }

  /// 触发事件
  Stream<Future<void>> _emitEvent(TEventMap queue, Object eventName, [dynamic arg]) async* {
    var list = queue[eventName];
    if (list == null) return;
    int len = list.length - 1;
    //反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (var i = len; i >= 0; --i) {
      yield list[i](arg);
    }
  }
}
