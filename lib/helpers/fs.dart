import 'dart:io';

import 'package:path/path.dart' as p;

class FS {
  /// 同步查询该路径下的文件系统实体是否存在
  static bool pathExistsSync(String path) => Directory(path).existsSync();

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

  /// 链接路径
  static String join(String part1, [String? part2, String? part3, String? part4, String? part5]) {
    return FS.normalize(p.join(part1, part2, part3, part4, part5));
  }

  /// 路径序列化
  static String normalize(String path) => p.normalize(path).replaceAll('\\', '/');
}
