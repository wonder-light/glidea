import 'dart:io';

import 'package:path/path.dart' as p;

class FS {
  /// 同步查询该路径下的文件系统实体是否存在
  static bool pathExistsSync(String path) => dirExistsSync(path) || fileExistsSync(path);

  /// 同步查询该路径下的文件是否存在
  static bool fileExistsSync(String path) => File(path).existsSync();

  /// 同步查询该路径下的目录是否存在
  static bool dirExistsSync(String path) => Directory(path).existsSync();

  /// 同步重命名此目录
  static void renameDirSync(String path, String newPath) => Directory(path).renameSync(newPath);

  /// 如果目录不存在，则同步创建该目录
  static void createDirSync(String path) => Directory(path).createSync(recursive: true);

  /// 使用给定的Encoding以字符串的形式同步读取整个文件内容
  static String readStringSync(String path) => File(path).readAsStringSync();

  /// 同步地将字符串写入文件
  static void writeStringSync(String path, String content) => File(path).writeAsStringSync(content);

  /// 拷贝文件夹
  static void copySync(String src, String target) {
    for (var file in Directory(src).listSync(recursive: true)) {
      var isFile = file is File;
      var relative = p.relative(isFile ? file.parent.path : file.path, from: src);
      FS.createDirSync(p.join(target, relative));
      if (isFile) {
        relative = p.relative(file.path, from: src);
        file.copySync(p.join(target, relative));
      }
    }
  }

  /// 同步复制此文件
  static void copyFileSync(String src, String target) => File(src).copySync(target);

  /// 获取指定文件夹中子目录的属性
  static List<Directory> subDirInfo(String path) => Directory(path).listSync().whereType<Directory>().toList();

  /// 获取指定文件夹中子目录的名称
  static List<String> subDir(String path) => subDirInfo(path).map((f) => p.basename(f.path)).toList();

  /// 链接路径
  static String join(String part1, [String? part2, String? part3, String? part4, String? part5]) {
    return FS.normalize(p.join(part1, part2, part3, part4, part5));
  }

  /// 路径序列化
  static String normalize(String path) => p.normalize(path).replaceAll('\\', '/');
}
