# 自定义渲染模板 :id=template

!> 由于使用的是由命令来启动程序, 所以存在着部分设备不怎么支持的情况,\
请各位小伙伴说明好使用办法哦!

## 设置自定义 :id=custom

在 `config.json` 中添加 `process` 字段即可, 接下来以 node.js 示例

```json
// <主题目录>/config.json
{
  "name": "fog",
  "version": "1.0",
  "author": "wonder-light",
  "repository": "https://github.com/wonder-light/glidea-theme-fog",
  "process": "node ./index.js",
  "customConfig": {}
}
```

### 参数 :id=params

在启动程序前会在命令的后面注入记录数据的路径, 也会在 `env` 中注入

```shell
node ./index.js  
#=>
node ./index.js C:/.../render/paths.json
```

### 环境 :id=env

```js
console.log(process.argv[process.argv.length - 1]);
// C:/.../render/paths.json

console.log(process.env['dataPath']);
// C:/.../render/paths.json
```

### 变量值 :id=value

```json
{
  "dataPath": "C:/.../render/config.json", // 渲染模板所需要的数据的路径
  "buildDir": "C:/.../output", // 渲染完成后的文件需要输出的目录
  "appDir": "C:/.../site",   // 站点文件所在的源目录
}
```