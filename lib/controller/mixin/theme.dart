import 'package:get/get.dart' show StateController, Trans;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/theme.dart';

/// 混合 - 主题
mixin ThemeSite on StateController<Application> {
  /// 拥有的主题名列表
  List<String> get themes => state.themes;

  /// 主题配置
  Theme get themeConfig => state.themeConfig;

  /// 自定义主题配置
  TJsonMap get themeCustomConfig => state.themeCustomConfig;

  /// 获取主题的控件配置
  List<ConfigBase> getThemeWidgetConfig() {
    var theme = state.themeConfig;
    var themes = state.themes.map((t) => SelectOption.all(t)).toList();
    var formats = [
      SelectOption(label: 'Slug'.tr, value: UrlFormats.slug.name),
      SelectOption(label: 'Short ID'.tr, value: UrlFormats.shortId.name),
    ];

    /// 主题配置
    ///
    /// 字段的类型 -- 字段的默认值
    return [
      // 选择主题
      SelectConfig()
        ..label = 'selectTheme'.tr
        ..value = theme.themeName
        ..options = themes,
      // 网页图标
      PictureConfig()
        ..label = 'faviconSetting'.tr
        ..value = theme.favicon,
      // 头像配置
      PictureConfig()
        ..label = 'avatarSetting'.tr
        ..value = theme.avatar,
      // 网站名称
      InputConfig()
        ..label = 'siteName'.tr
        ..value = theme.siteName,
      // 网站描述
      TextareaConfig()
        ..label = 'siteDescription'.tr
        ..value = theme.siteDescription
        ..note = 'htmlSupport'.tr,
      // 底部信息
      TextareaConfig()
        ..label = 'footerInfo'.tr
        ..value = theme.footerInfo
        ..note = 'htmlSupport'.tr,
      // 显示封面图
      ToggleConfig()
        ..label = 'isShowFeatureImage'.tr
        ..value = theme.showFeatureImage,
      // 首页每一页显示的文章数量
      SliderConfig()
        ..label = 'articlesPerPage'.tr
        ..value = theme.postPageSize.toDouble()
        ..max = 50
        ..isInt = true,
      // 归档每一页显示的文章数量
      SliderConfig()
        ..label = 'archivesPerPage'.tr
        ..value = theme.archivesPageSize.toDouble()
        ..isInt = true,
      // 文章 URL 默认格式
      RadioConfig()
        ..label = 'articleDefault'.tr
        ..value = theme.postUrlFormat.name
        ..options = formats,
      // 标签 URL 默认格式
      RadioConfig()
        ..label = 'tagDefault'.tr
        ..value = theme.tagUrlFormat.name
        ..options = formats,
      // 文章路径前缀
      InputConfig()
        ..label = 'articlePathPrefix'.tr
        ..value = theme.postPath,
      // 标签路径前缀
      InputConfig()
        ..label = 'tagPathPrefix'.tr
        ..value = theme.tagPath,
      // 归档路径前缀
      InputConfig()
        ..label = 'archivePathPrefix'.tr
        ..value = theme.archivesPath,
      // 日期格式
      InputConfig()
        ..label = 'dateFormat'.tr
        ..value = theme.dateFormat
        ..hint = 'YYYY-MM-DD',
      // 使用 RSS/Feed
      ToggleConfig()
        ..label = 'useRSS'.tr
        ..value = theme.useFeed,
      // Feed 的文章数量
      SliderConfig()
        ..label = 'numberArticlesRSS'.tr
        ..value = theme.feedCount.toDouble()
        ..isInt = true,
      // 创建站点地图
      ToggleConfig()
        ..label = 'isGenerateSiteMap'.tr
        ..value = theme.generateSiteMap,
      // robots 文本
      TextareaConfig()
        ..label = 'robotsText'.tr
        ..value = theme.robotsText
        ..note = 'htmlSupport'.tr,
    ];
  }
}
