
# Theme customization

> Glidea provides powerful theme customization capabilities, you can design your own custom configuration to provide theme users

Each theme is optionally paired with a `config.json` configuration file and a `style-overriding.dart` style overlay file


## Example :id=example

### config.json

```json
{
  "name": "Notes",
  "version": "1.0.0",
  "author": "EryouHao",
  "customConfig": [
    {
      "name": "skin",
      "label": "Skin",
      "group": "Skin",
      "value": "white",
      "type": "select",
      "options": [
        {
          "label": "Simple white",
          "value": "white"
        },
        {
          "label": "Undertone black",
          "value": "black"
        }
      ]
    },
    {
      "name": "contentMaxWidth",
      "label": "Maximum width of the content area",
      "group": "Layout",
      "value": "800px",
      "type": "input",
      "note": "Fillable pixel type (e.g. 320px) or percentage type (e.g. 38.2%)"
    },
    {
      "name": "textSize",
      "label": "Text content Text size",
      "group": "Layout",
      "value": "16px",
      "type": "input",
      "note": "px or rem(16px or 1rem)"
    },
    {
      "name": "pageBgColor",
      "label": "Web background color",
      "group": "Color",
      "value": "#ffffff",
      "type": "input",
      "card": "color",
      "note": "Color string :(e.g. #EEEEEE, rgba(255, 255, 255, 0.9))"
    },
    {
      "name": "github",
      "label": "Github",
      "group": "Social",
      "value": "",
      "type": "input",
      "note": "Link address"
    },
    {
      "name": "twitter",
      "label": "Twitter",
      "group": "Social",
      "value": "",
      "type": "input",
      "note": "Link address"
    },
    {
      "name": "weibo",
      "label": "Microblog",
      "group": "Social",
      "value": "",
      "type": "input",
      "note": "Link address"
    },
    {
      "name": "customCss",
      "label": "Custom CSS",
      "group": "Custom style",
      "value": "",
      "type": "textarea",
      "note": ""
    },
    {
      "name": "ga",
      "label": "Trace ID",
      "group": "Google statistics",
      "value": "",
      "type": "input",
      "note": "UA-xxxxxxxxx-x"
    }
  ]
}
``` 

### style-override.dart

```dart
void generateOverride(Map<String, dynamic> params) {
  var result = "";
  //Dark skin
  if (params[skin] case String skin when skin != "white") {
    result += '''
      body{
        color:#dee2e6;
      }
      a,.link{
        color:#e9ecef;
      }
    ''';
  }
  //Maximum width of the content area - contentMaxWidth
  if (params[contentMaxWidth] case String value when value != "800px") {
    result += '''
      .main{
        max-width:${value};
      }
    ''';
  }
  //Text content Text size - textSize
  if (params[textSize] case String size when size != "16px") {
    result += '''
      .post-detail.post.post-contentp{
        font-size:${size};
      }
   ''';
  }
  // Page background color - pageBgColor
  if (params[pageBgColor] case String bg when bg != "#ffffff") {
    result += '''
      body{
        background:${bg};
      }
    ''';
  }
  //Text color - textColor
  if (params[textColor] case String color when color != "#333333") {
    result += '''
      body{
        color: ${color};
      }
    ''';
  }
  //Custom CSS - customCss
  if (params.customCss case String css) {
    result += css;
  }
  return result;
}
```

Yes, as you can see, custom configuration is as simple and clear as that. Let's take a look at the specific fields and how to use them:


## Field type configuration :id=field-config

The root directory of each theme can contain a config.json file.

This file contains the basic information of the theme such as: `name`, `version`, `author`, `repository`, etc.\
there is a special field `customConfig`, this is the custom configuration field, type array,\
the format for each element is as follows：

```json
{
  "name": "Field variable name, which can be used in a template or style overlay file",
  "label": "Field display name, the name displayed in the software",
  "group": "The group to which the field belongs, and the group name displayed in the software",
  "value": "Field default",
  "type": "Field input type, optional values: 'input', 'select', 'textarea', 'radio', 'switch', 'picture', 'array', 'slider'",
  "note": "The input field placeholder prompt copy is displayed below the form space",
  "hint": "This parameter is available when type is input or textarea",
  "card": "Field attached Card, optional values: 'color' (provides a quick selection of recommended color cards), 'post' (provides a selection of article data cards), available when type is 'input'",
  "options": [ // This parameter is available when type is 'select' or 'radio'
    {
      "label": "Option display name",
      "value": "Option corresponding value"
    }
  ]
}
```


 ## Picture type configuration :id=image-config

```json
{
  "name": "sidebarBgImage",
  "label": "Sidebar background image",
  "group": "Picture",
  "value": "/media/images/sidebar-bg.jpg",
  "type": "picture",
  "note": ""
}
```


## Slider type configuration :id=slider-config

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

## Array type configuration :id=array-config

```json
{

  "name": "friends",
  "label": "Friend link",
  "group": "Friend",
  "type": "array",
  "value": [
    {
      "siteName": "Heart of island hey",
      "siteLink": "https://fehey.com",
      "siteLogo": "",
      "description": "A front end"
    },
    {
      "siteName": "Glidea Official website",
      "siteLink": "https://glidea/nianian.cn",
      "siteLogo": "",
      "description": "A static blog writing client"
    }
  ], 
  // If there is no default data, write []
  // Subentries are configured for other field types
  "arrayItems": [
    {
      "label": "name",
      "name": "siteName",
      "type": "input",
      "value": ""
    },
    {
      "label": "link",
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
      "label": "Description",
      "name": "description",
      "type": "textarea",
      "value": ""
    }
  ],
  "note": ""
}
```

In most cases, using the input type is sufficient


These fields can be used either in the template (corresponding to: [`site.customconfig.customField`](#configjson)) or in the style overlay file (corresponding to: input)

When used in the template, you can play your imagination, social, statistics, friend chain, external chain background map, background music...

## Style overlay configuration :id=style-override

Of course, it can also be used in style overlay files:

```dart
void generateOverride(Map<String, dynamic> params) {
  // params are custom field objects. You can add custom css based on field values
  var result = '';
  // Text content Text size - textSize
  if (params[textSize] case String size when size != '16px') {
    result += '''
      body {
        font-size: ${size};
      }
    ''';
  }
  // The final result is placed at the end of the 'main.css' file
  return result;
}
```

Here, I believe you have figured out how to add custom configuration capabilities to the theme,
quickly develop a theme of your own, share to others will be better yo!

If still not clear, refer to the built-in theme code structure:

[Github themes zip](https://github.com/wonder-light/glidea/tree/main/assets/public/default-files.zip)