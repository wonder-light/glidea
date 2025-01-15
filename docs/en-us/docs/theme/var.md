
# Page Variable :id=variables 

> The variables introduced during the creation of the page will vary from page to page

## Page variable example :id=page-example
  
### index page :id=index-page

- [posts](#posts)
- [menus](#menus)
- [pagination](#pagination)
- [themeConfig](#themeconfig)
- [site](#site)

### post page :id=post-page

- [post](#post)
- [menus](#menus)
- [themeConfig](#themeconfig)
- [commentSetting](#commentsetting)
- [site](#site)

### archives page :id=archives-page

- [posts](#posts)
- [menus](#menus)
- [pagination](#pagination)
- [themeConfig](#themeconfig)
- [site](#site)

### tags page :id=tags-page

- [tags](#tags)
- [menus](#menus)
- [themeConfig](#themeconfig)
- [site](#site)

### tag page :id=tag-page

- [tag](#tag)
- [posts](#posts)
- [menus](#menus)
- [pagination](#pagination)
- [themeConfig](#themeconfig)
- [site](#site)

### custom template :id=custom-template

You can create a custom template in the templates folder，\
for example, `friends.j2`, `about.j2`, `projects.j2`, `404.j2` and so on，\
the resulting access path is\
`http(s)://域名/friends`,\
`http(s)://域名/about`,\
`http(s)://域名/projects`,\
`http(s)://域名/404`

Available variables are as follows:

- [menus](#menus)
- [themeConfig](#themeconfig)
- [commentSetting](#commentsetting)
- [site](#site)

?> Note: If the theme contains a custom template, \
if the URL of the custom rendering template conflicts with the article URL, \
the custom rendering template takes precedence over the article URL


## Variable value example :id=variable-example

?> The @ symbol is a reference to another field flag and is used only as a field description for this document

### menus

Menu array, specific menu field visible [menu](#menu)

```js
menus: [
  @menu,
  @menu,
  @menn
]
```

### posts

Article array, specific Post field visible [post](#post)

```js
posts: [
  @post, 
  @post, 
  @post
]
```

### tags

Tag array, specific tag field visible [tag](#tag)

```js
tags: [
  @tag, 
  @tag, 
  @tag
]
```

### pagination

Page field for the article list

```js
pagination: {
  base: '',    // Current base link
  prev: '',    // Link to previous page
  next: '',    // Link to next page
  total: 0,    // Total pages
  current: 0,  // Current page count 
}
```

### menu

Menu field

```js
menu: {
  name: '首页',
  link: '/',
  openType: 'internal', // Open type: internal or external
}
```

### post

Article field

```js
post: {
  content: '<p><strong>Glidea</strong> A static blog writing client </p>',
  fileName: 'hello-glidea',
  abstract: '',
  description: 'A static blog writing client, welcome to Glidea',
  title: 'Hello Glidea',
  tags: ['Glidea', 'dev', 'test'], // Article tag array, specifically see the tag field below
  date: 'December 12o 2018, am',
  dateFormat: '2018-12-12', // Fields formatted according to Glidea in-app dates
  feature: 'post-images/hello-glidea.png', // If there is no cover picture, it is ''
  link: 'https://xxx.com/post/hello-glidea',
  hideInList: false, // Takes effect only for articles with no label set
  isTop: false, // Whether the top article
  toc: '<ul class="markdownIt-TOC"><li><ul><li><a href="#demo" class="">DEMO</a></li></ul></li></ul>', // 文章目录字段
  prevPost: @post, // If it is the first article, this field is not available
  nextPost: @post, // If it is the last article, this field is not available
}
```

### tag

Tag field

```js
tag: {
  name: 'Glidea', 
  used: true,
  count: 1,
  slug: 'glidea',
  link: 'https://xxx.com/tag/glidea',
}
```

### themeConfig

Theme configuration field

```js
themeConfig: {
  selectTheme: "tech",
  domain: "https://github.com",
  archivesPageSize: 50,
  archivesPath: "archives", // Archive page path prefix, which can be customized within the application, such as 'blog', 'news', etc
  dateFormat: "yyyy-MM-dd HH:mm:ss",
  feedCount: 10,
  useFeed: false,
  footerInfo: "Powered by <a href=\"https://github.com/wonder-light/glidea\" target=\"_blank\">Glidea</a>",
  postPageSize: 12,
  postPath: "post",
  postUrlFormat: "slug",
  showFeatureImage: true,
  siteDescription: "Every 🐦 has an 🦅's dream.",
  siteName: "hey",
  tagPath: "tag",
  tagUrlFormat: "shortId",
  generateSiteMap: true,
  robotsText: "",
}
```

### site

Site field

```js
site: {
  posts: @posts,
  tags: @tags,
  menus: @menus,
  themeConfig: @themeConfig,
  isHomepage: false, // Whether it is the home page, it is rendered using index.j2, and it is true when it is the first page
  customConfig: {}, // Topic Custom configuration field, if none {}
  utils: {
    now: "1577006772710", // Date.now()
  },
};
```

### commentSetting

Comment setting

```js
commentSetting: {
  commentPlatform: 'disqus',
  disqusSetting: {
    api: '',
    apikey: 'Dme6Hy8bOI2xxxxUtdY8V',
    shortname: 'glidea',
  },
  gitalkSetting: {
    clientId: 'd92dxxxxxxxxxx9b4',
    clientSecret: '861947exxxx365d33',
    owner: 'EryouHao',
    repository: 'EryouHao.github.io'
  },
  showComment: false // Whether to display comments. You can display comments according to this field
}
```


## Other :id=other

### Avatar :id=avatar

```html
<img class="avatar" src="{{ themeConfig.domain }}/images/avatar.png" alt="" width="32px" height="32px">
```

### Web icon :id=favicon

```html
<link rel="shortcut icon" href="{{ themeConfig.domain }}/favicon.ico">
```

### Style file :id=main.css

```html
<link rel="stylesheet" href="{{ themeConfig.domain }}/styles/main.css">
```
