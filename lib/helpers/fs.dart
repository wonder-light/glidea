import 'dart:io' show File, Directory;

import 'package:glidea/helpers/crypto.dart';
import 'package:path/path.dart' as p;

class FS {
  /// 同步查询该路径下的文件系统实体是否存在
  static bool pathExistsSync(String path) => dirExistsSync(path) || fileExistsSync(path);

  /// 同步查询该路径下的文件是否存在
  static bool fileExistsSync(String path) => File(path).existsSync();

  /// 同步查询该路径下的目录是否存在
  static bool dirExistsSync(String path) => Directory(path).existsSync();

  /// 同步重命名此目录 - 异步
  static Future<Directory> renameDir(String path, String newPath) => Directory(path).rename(newPath);

  /// 同步重命名此目录
  static void renameDirSync(String path, String newPath) => Directory(path).renameSync(newPath);

  /// 如果目录不存在，则同步创建该目录 - 异步
  static Future<Directory> createDir(String path) => Directory(path).create(recursive: true);

  /// 如果目录不存在，则同步创建该目录
  static void createDirSync(String path) => Directory(path).createSync(recursive: true);

  /// 使用给定的Encoding以字符串的形式同步读取整个文件内容 - 异步
  static Future<String> readString(String path) => File(path).readAsString();

  /// 使用给定的Encoding以字符串的形式同步读取整个文件内容
  static String readStringSync(String path) => File(path).readAsStringSync();

  /// 同步地将字符串写入文件 - 异步
  static Future<File> writeString(String path, String content) => File(path).writeAsString(content);

  /// 同步地将字符串写入文件
  static void writeStringSync(String path, String content) => File(path).writeAsStringSync(content);

  /// 拷贝文件夹或者文件
  static void copySync(String src, String target) {
    // 如果 src 是文件
    if (File(src) case File file when file.existsSync()) {
      file.copySync(target);
      return;
    }
    // 如果 src 是目录
    if (Directory(src) case Directory directory when directory.existsSync()) {
      // 获取目录下的所有子目录包括文件
      for (var file in directory.listSync(recursive: true)) {
        var isFile = file is File;
        // 获取目录的相对路径
        var relative = p.relative(isFile ? file.parent.path : file.path, from: src);
        FS.createDirSync(p.join(target, relative));
        if (isFile) {
          // 获取文件的相对路径
          relative = p.relative(file.path, from: src);
          file.copySync(p.join(target, relative));
        }
      }
    }
  }

  /// 所有目录下的所有文件
  static List<File> getFilesSync(String path, {bool recursive = true}) {
    return Directory(path).listSync(recursive: recursive).whereType<File>().toList();
  }

  /// 移动子目录下的所有文件到指定目录, 包括文件
  static void moveSubFile(String src, String target) async {
    if (dirExistsSync(target)) createDirSync(target);
    for (var item in Directory(src).listSync()) {
      // 获取文件的相对路径
      var relative = p.relative(item.path, from: src);
      item.renameSync(p.join(target, relative));
    }
  }

  /// 复制此文件
  static Future<File> copyFile(String src, String target) => File(src).copy(target);

  /// 同步复制此文件
  static void copyFileSync(String src, String target) => File(src).copySync(target);

  /// 删除目录
  static void deleteDirSync(String src, {bool recursive = true}) => Directory(src).deleteSync(recursive: recursive);

  /// 获取指定文件夹中子目录的属性
  static List<Directory> subDirInfo(String path) => Directory(path).listSync().whereType<Directory>().toList();

  /// 获取指定文件夹中子目录的名称
  static List<String> subDir(String path) => subDirInfo(path).map((f) => p.basename(f.path)).toList();

  /// 链接路径
  ///
  ///     join('path', 'to', 'foo'); // -> 'path/to/foo'
  ///     join('path', '/to', 'foo'); // -> 'path/to/foo'
  ///     join('path', '/to', '/foo'); // -> 'path/to/foo'
  static String join(String part1, [String? part2, String? part3, String? part4, String? part5]) {
    return FS.normalize(p.join(part1, _remove(part2), _remove(part3), _remove(part4), _remove(part5)));
  }

  /// 路径序列化
  static String normalize(String path) => p.normalize(path).replaceAll('\\', '/');

  /// 获取 [path] 相对于 [from] 的相对路径
  ///
  ///     relative('/root/path/a/b.dart', from: '/root/path'); // -> 'a/b.dart'
  //      relative('/root/other.dart', from: '/root/path');    // -> '../other.dart'
  static String relative(String path, String from) => normalize(p.relative(path, from: from));

  /// 获取最后一个分隔符之前的 [path] 部分
  ///
  ///     dirname('path/to/foo.dart'); // -> 'path/to'
  ///     dirname('path/to');          // -> 'path'
  ///
  /// 尾随分隔符将被忽略
  ///
  ///     dirname('path/to/'); // -> 'path'
  static String dirname(String path) => normalize(p.dirname(path));

  /// 获取[path]的文件扩展名
  ///
  ///     extension('path/to/foo.dart');    // -> '.dart'
  ///     extension('path/to/foo');         // -> ''
  ///     extension('path.to/foo');         // -> ''
  ///     extension('path/to/foo.dart.js'); // -> '.js'
  static String extension(String path) => p.extension(path);

  // 去除开头的 /
  static String? _remove(String? str) {
    if (str?.startsWith('/') ?? false) {
      return str!.substring(1);
    }
    return str;
  }
}

extension FileExt on File {
  Future<String> getHash() => Crypto.cryptoFile(this);
/*
  Future<String> getFileHashMd5() async {
    final fileLength = lengthSync();
    // 小文件直接获取
    if (fileLength < fileSize10M) {
      return md5.convert(readAsBytesSync()).toString();
    }
    // 大文件分块获取
    final sFile = await open();
    try {
      // 输出块
      final output = AccumulatorSink<Digest>();
      final input = md5.startChunkedConversion(output);
      int x = 0;
      while (x < fileLength) {
        final tmpLen = fileLength - x > fileSize10M ? fileSize10M : fileLength - x;
        // 分块获取
        input.add(sFile.readSync(tmpLen));
        x += tmpLen;
      }
      input.close();

      final hash = output.events.single;
      return hash.toString();
    } finally {
      unawaited(sFile.close());
    }
  }

  Future<String> getFileHashSh1() async {
    final fileLength = lengthSync();
    // 小文件直接获取
    if (fileLength < fileSize10M) {
      return sha1.convert(readAsBytesSync()).toString();
    }
    // 大文件分块获取
    final sFile = await open();
    try {
      // 输出块
      final output = AccumulatorSink<Digest>();
      final input = sha1.startChunkedConversion(output);
      int x = 0;
      while (x < fileLength) {
        final tmpLen = fileLength - x > fileSize10M ? fileSize10M : fileLength - x;
        // 分块获取
        input.add(sFile.readSync(tmpLen));
        x += tmpLen;
      }
      input.close();

      final hash = output.events.single;
      return hash.toString();
    } finally {
      unawaited(sFile.close());
    }
  }
*/
}
