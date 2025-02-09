
# 主题自定义 :id=theme-custom

> Glidea 提供了强大的主题自定义能力，你可以自行设计自定义配置提供给主题使用者

每一个主题都可选地搭配一个 `config.json` 配置文件和一个 `style-override.dart` 样式覆盖文件


## 示例 :id=example

### config.json :id=config

```json
{
  "name": "Notes",
  "version": "1.0.0",
  "author": "EryouHao",
  "customConfig": [
    {
      "name": "skin",
      "label": "皮肤",
      "group": "皮肤",
      "value": "white",
      "type": "select",
      "options": [
        {
          "label": "简约白",
          "value": "white"
        },
        {
          "label": "低调黑",
          "value": "black"
        }
      ]
    },
    {
      "name": "contentMaxWidth",
      "label": "内容区最大宽度",
      "group": "布局",
      "value": "800px",
      "type": "input",
      "note": "可填像素类型(如: 320px)或百分比类型(如: 38.2%)"
    },
    {
      "name": "textSize",
      "label": "正文内容文字大小",
      "group": "布局",
      "value": "16px",
      "type": "input",
      "note": "px 或 rem(如 16px 或 1rem)"
    },
    {
      "name": "pageBgColor",
      "label": "网页背景色",
      "group": "颜色",
      "value": "#ffffff",
      "type": "input",
      "card": "color",
      "note": "颜色字符串:(如：#EEEEEE、rgba(255, 255, 255, 0.9))"
    },
    {
      "name": "github",
      "label": "Github",
      "group": "社交",
      "value": "",
      "type": "input",
      "note": "链接地址"
    },
    {
      "name": "twitter",
      "label": "Twitter",
      "group": "社交",
      "value": "",
      "type": "input",
      "note": "链接地址"
    },
    {
      "name": "weibo",
      "label": "微博",
      "group": "社交",
      "value": "",
      "type": "input",
      "note": "链接地址"
    },
    {
      "name": "customCss",
      "label": "自定义CSS",
      "group": "自定义样式",
      "value": "",
      "type": "textarea",
      "note": ""
    },
    {
      "name": "ga",
      "label": "跟踪 ID",
      "group": "谷歌统计",
      "value": "",
      "type": "input",
      "note": "UA-xxxxxxxxx-x"
    }
  ]
}
``` 

### style-override.j2 :id=style-override

```django
{# 暗黑皮肤 #}
{% if skin and skin != "white" %}
  body{
    color: #dee2e6;
  }
  a, .link{
    color: #e9ecef;
  }
{% endif %}

{# 内容区最大宽度 - contentMaxWidth #}
{% if contentMaxWidth and contentMaxWidth != "800px" %}
  .main{
    max-width: {{ contentMaxWidth }};
  }
{% endif %}

{# 正文内容文字大小 - textSize #}
{% if textSize and textSize != "16px" %}
  .post-detail.post.post-content{
    font-size: {{ textSize }};
  }
{% endif %}

{# 网页背景色 - pageBgColor #}
{% if pageBgColor and pageBgColor != "#ffffff" %}
  body{
    background: {{ pageBgColor }};
  }
{% endif %}

{# 文字颜色 - textColor #}
{% if textColor and textColor != "#333333" %}
  body{
  color: {{ textColor }};
  }
{% endif %}

{# 自定义CSS - customCss #}
{% if customCss %}
  {{ customCss }}
{% endif %}
```

是的，如你所见，自定义配置就是这么简单，清晰。下面让我们详细了解一下具体字段和使用方法：


## 字段类型配置 :id=field-config

每个主题的根目录可包含一个 config.json 的文件。

此文件中包含了主题的基本信息如：`name`, `version`, `author`, `repository` 等，\
其中有一个特殊的字段 `customConfig`，这便是自定义配置字段了，类型为数组，\
每项元素的格式如下：

```json
{
  "name": "字段变量名称，可在模版或样式覆盖文件中使用",
  "label": "字段展示名称，在软件中显示的名称",
  "group": "字段所属分组，在软件中显示的分组名称",
  "value": "字段默认值",
  "type": "字段输入类型，可选值：'input', 'select', 'textarea', 'radio', 'switch', 'picture', 'array', 'slider'",
  "note": "输入框 placeholder 提示文案，展示在表单空间下面",
  "hint": "type 为 input 或 textarea 时可用",
  "card": "字段附属 Card, 可选值: 'color'（提供一个推荐颜色卡片快捷选择），'post'（提供文章数据卡片提供选择), type 为 'input' 时可用",
  "options": [ // type 为 'select'， 'radio' 时可用
    {
      "label": "选项显示名称",
      "value": "选项对应值"
    }
  ]
}
```


## 图片类型配置 :id=image-config

```json
{
  "name": "sidebarBgImage",
  "label": "侧边栏背景图",
  "group": "图片",
  "value": "/media/images/sidebar-bg.jpg",
  "type": "picture",
  "note": ""
}
```


## 滑块类型配置 :id=slider-config

```json
{
  "name": "slider",
  "label": "数量",
  "group": "滑块",
  "value": 10, //整数
  "max": 100, // min = 0, max > 1, 整数
  "type": "slider",
  "note": ""
}
```


## 数组类型配置 :id=array-config

```json
{

  "name": "friends",
  "label": "友链",
  "group": "友链",
  "type": "array",
  "value": [
    {
      "siteName": "海岛心",
      "siteLink": "https://haidaoxin.com",
      "siteLogo": "",
      "description": "一个前端"
    },
    {
      "siteName": "Glidea 官网",
      "siteLink": "https://glidea.nianian.cn",
      "siteLogo": "",
      "description": "一个静态博客写作客户端"
    }
  ], 
  // 若无默认数据，可写成 []
  // 子项为其它字段类型配置
  "arrayItems": [
    {
      "label": "名称",
      "name": "siteName",
      "type": "input",
      "value": ""
    },
    {
      "label": "链接",
      "name": "siteLink",
      "type": "input",
      "value": ""
    },
    {
      "label": "Logo",
      "name": "siteLogo",
      "type": "picture-upload",
      "value": ""
    },
    {
      "label": "描述",
      "name": "description",
      "type": "textarea",
      "value": ""
    }
  ],
  "note": ""
}
```

大部分情况下，使用 input 类型的就够用了


这些字段都可以在模版中（对应: [`site.customConfig.自定义字段`](#config)）或样式覆盖文件（对应：入参）中使用

在模版中使用时，你可以尽情发挥你的想象，社交、统计、友链、外链背景图、背景音乐...


## 样式覆盖配置 :id=style-override

当然，在样式覆盖文件中也可以使用：

```django
{# 当前上下文即为 customConfig #}
{# 正文内容文字大小 - textSize #}
{% if textSize and textSize != "16px" %}
  .post-detail.post.post-content{
    font-size: {{ textSize }};
  }
{% endif %}
{# 最终结果会放在 `main.css` 的文件末尾 #}
```

 到这里，相信你已经搞清楚如何给主题增加自定义配置能力了，快去开发一个属于自己的主题吧，分享给其他人会更佳呦！

 若还是不清楚，可参考应用内置主题代码结构：

[Github themes zip](https://github.com/wonder-light/glidea/tree/main/assets/public/default-files.zip)