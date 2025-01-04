
# Theme development :id=theme

> Glidea uses Jinja as the theme's template engine

You can view the Default theme of the app here [Default Themes](https://github.com/wonder-light/glidea/tree/main/public/default-files.zip)

You can quickly develop a custom theme based on Jinja's syntax

🎉 We have prepared a theme development template for you, [check it out](https://github.com/wonder-light/glidea-theme-fog)！

## Appoint :id=agreement

We recommend that you name the theme `glidea-theme-`**\<name\>** so that users can search better，\
such as **glidea-theme-notes**，\
we also recommend that you submit your topic to GitHub and set up the **topic**，\
So that users can directly click on the **topic** to search for your topic **glidea-theme-notes**

Example:

![topic](../../../assets/images/glidea-theme-topic.jpg ':class=img-cover')


## Jinja basic introduction :id=Jinja

Here are just a few of the most common syntax you will use to develop your theme. \
Of course, if you want the most comprehensive syntax, \
you can check the [Jinja](https://docs.jinkan.org/docs/jinja2/templates.html) documentation. \
Support for Jinja can be found in the [jinja|dart](https://pub.dev/packages/jinja) documentation

Example:

```json
{
  "themeConfig": {
    "footerInfo": "Powered by Glidea",
    "pageSize": 10,
    "showFeatureImage": true,
    "siteDescription": "Review the old and learn the new",
    "siteName": "Glidea",
    "themeName": "notes"
  },
  "posts": [
    {
      "abstract": "<strong>Glidea</strong> A static blog writing client ",
      "content": "<strong>Glidea</strong> A static blog writing client <!-- more -->↵↵👏 Welcome to use <strong>Glidea</strong> ！",
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

### Tag :id=tag

- `{​{ ... }​}` Used to print the result of an expression to a template
``` django
{{ themeConfig.siteName }}
{{ themeConfig.siteName|e }} // Escape it
```



- `{% ... %}` Used to execute statements such as for loops or assignments
``` django
{% for item in posts %}
  <li>
    <a href="{{ item.feature }}">{{ item.content }}</a>
  </li>
{% endfor %}
```

### Include :id=include

The `include` statement is used to include a template，\
And return the result of rendering the contents of that file in the current namespace:

``` django
{% include 'header.html' %}
  Body
{% include 'footer.html' %}
```

### Conditional judgment :id=if

You can use `if` and `elif` and `else` to build multiple branches

``` django
{% if themeConfig.sick %}
  Kenny is sick.
{% elif themeConfig.dead %}
  You killed Kenny!  You bastard!!!
{% else %}
  Kenny looks okay --- so far
{% endif %}
```

### Macro :id=macro

It is used to make common behaviors reusable functions instead of manual repetitive work\
Here is a small example of macros rendering form elements:

``` django
{% macro input(name, value='', type='text', size=20) -%}
  <input type="{{ type }}" name="{{ name }}" value="{{ value|e }}" size="{{ size }}">
{%- endmacro %}
```

Macros can then be called like functions:

``` django
<p>{{ input('username') }}</p>
<p>{{ input('password', type='password') }}</p
```