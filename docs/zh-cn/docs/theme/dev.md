
# 主题开发 :id=theme

> Glidea 采用 Jinja 作为主题的模版引擎

你可以在这里查看应用的默认主题 [Default Themes](https://github.com/wonder-light/glidea/tree/main/public/default-files.zip)

基于 Jinja 的语法你可以很快开发出一个心仪的自定义主题

🎉 我们为你准备了一个主题开发样板，[快去看看吧](https://github.com/wonder-light/glidea-theme-fog)！

## 约定 :id=agreement

我们建议你将主题命名为 `glidea-theme-`**\<name\>** 以便用户可以更好地搜索，\
例如 **glidea-theme-notes**，\
同时我们建议你将主题提交至 Github，并设置 **topic**，\
以便用户可以直接点击 **topic** 即可搜索到你的主题 **glidea-theme-notes**

示例：

![topic](../../../assets/images/glidea-theme-topic.jpg ':class=img-cover')


## Jinja 基础介绍 :id=Jinja

这里只列举了你开发主题时最常用的几个语法，当然，如果想了解最全面的语法，可以去查看 [Jinja](https://docs.jinkan.org/docs/jinja2/templates.html) 文档，对 Jinja 的支持情况可以查看 [jinja|dart](https://pub.dev/packages/jinja) 文档

示例数据:

```json
{
  "themeConfig": {
    "footerInfo": "Powered by Glidea",
    "pageSize": 10,
    "showFeatureImage": true,
    "siteDescription": "温故而知新",
    "siteName": "Glidea",
    "themeName": "notes"
  },
  "posts": [
    {
      "abstract": "<strong>Glidea</strong> 一个静态博客写作客户端 ",
      "content": "<strong>Glidea</strong> 一个静态博客写作客户端 <!-- more -->↵↵👏 欢迎使用 <strong>Glidea</strong> ！",
      "date": "2019-01-15 08:00:00",
      "dateFormat": "2019-01-15",
      "feature": "/post-images/hello-glidea.png",
      "published": true,
      "tags": ["Glidea"],
      "fileName": "hello-glidea"
    }
  ]
}
``` 

### 标签 :id=tag

- `{​{ ... }​}` 用于把表达式的结果打印到模板上
``` django
{{ themeConfig.siteName }}
{{ themeConfig.siteName|e }} // 对其进行转义
```



- `{% ... %}` 用于执行诸如 for 循环 或赋值的语句
``` django
{% for item in posts %}
  <li>
    <a href="{{ item.feature }}">{{ item.content }}</a>
  </li>
{% endfor %}
```

### 包含 :id=include

`include` 语句用于包含一个模板，\
并在当前命名空间中返回那个文件的内容渲染结果:

``` django
{% include 'header.html' %}
  Body
{% include 'footer.html' %}
```

### 条件判断 :id=if

你可以用 `if` 和 `elif` 和 `else` 来构建多个分支

``` django
{% if themeConfig.sick %}
  Kenny is sick.
{% elif themeConfig.dead %}
  You killed Kenny!  You bastard!!!
{% else %}
  Kenny looks okay --- so far
{% endif %}
```

### 宏 :id=macro

用于把常用行为作为可重用的函数，取代手动重复的工作\
这里是一个宏渲染表单元素的小例子:

``` django
{% macro input(name, value='', type='text', size=20) -%}
  <input type="{{ type }}" name="{{ name }}" value="{{ value|e }}" size="{{ size }}">
{%- endmacro %}
```

宏之后可以像函数一样调用:

``` django
<p>{{ input('username') }}</p>
<p>{{ input('password', type='password') }}</p
```

## 自定义渲染 :id=custom

需要自定义渲染模板的可以参考[这里](/zh-cn/docs/theme/render)哦!