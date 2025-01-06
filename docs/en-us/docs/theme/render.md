# Custom rendering templates :id=template

!> Due to the use of commands to start the program, there are cases that some devices do not support\
Please explain how to use good friends!

## Set custom :id=custom

Add the `process` field to `config.json` and use the node.js example

```json
// <Theme Dir>/config.json
{
  "name": "fog",
  "version": "1.0",
  "author": "wonder-light",
  "repository": "https://github.com/wonder-light/glidea-theme-fog",
  "process": "node ./index.js",
  "customConfig": {}
}
```

### Argument :id=params

The output path and the path to render data are injected \
at the end of the command before starting the program, and also in 'env'

```shell
node ./index.js  
#=>
node ./index.js C:/.../output C:/.../render/config.json
# There is a path.json directory in the config.json sibling directory to refer to the path writing
```

### Environment :id=env

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

