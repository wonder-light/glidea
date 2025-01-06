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

在启动程序前会在命令的后面注入输出路径和渲染数据所在路径, 也会在 `env` 中注入

```shell
node ./index.js  
#=>
node ./index.js C:/.../output C:/.../render/config.json
# 在 config.json 同级目录下有一个 paths.json 可以参考路径的写法
```

### 环境 :id=env

```js
console.log(process.argv[process.argv.length - 2]);
// C:/.../output

console.log(process.argv[process.argv.length - 1]);
// C:/.../render/config.json

console.log(process.env['buildDir']);
// C:/.../output

console.log(process.env['renderData']);
// C:/.../render/config.json

console.log(process.env['renderPath']);
// C:/.../render/paths.json
```

