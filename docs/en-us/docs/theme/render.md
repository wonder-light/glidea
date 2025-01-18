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

The path to the recorded data is injected \
at the end of the command before starting the program, and also in 'env'

```shell
node ./index.js  
#=>
node ./index.js C:/.../render/paths.json
```

### Environment :id=env

```js
console.log(process.argv[process.argv.length - 1]);
// C:/.../render/paths.json

console.log(process.env['dataPath']);
// C:/.../render/paths.json
```

### Variable value :id=value

```json
{
  "dataPath": "C:/.../render/config.json", // The path to the data needed to render the template
  "buildDir": "C:/.../output", // The directory where the rendered file needs to be output
  "appDir": "C:/.../site",   // The source directory where the site files are located
}