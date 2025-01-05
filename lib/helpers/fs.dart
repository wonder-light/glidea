import 'dart:convert' show base64;
import 'dart:io' show Directory, File, FileMode, FileSystemEntity;

import 'package:archive/archive_io.dart' show Archive, InputFileStream, OutputFileStream, ZipDecoder;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
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

  /// 以字节列表的形式读取整个文件内容。 - 异步
  static Future<Uint8List> readAsBytes(String path) => File(path).readAsBytes();

  /// 以字节列表的形式读取整个文件内容。
  static Uint8List readAsBytesSync(String path) => File(path).readAsBytesSync();

  /// 使用给定的Encoding以字符串的形式同步读取整个文件内容 - 异步
  static Future<String> readString(String path) => File(path).readAsString();

  /// 使用给定的Encoding以字符串的形式同步读取整个文件内容
  static String readStringSync(String path) => File(path).readAsStringSync();

  /// 方法将整个文件内容作为 base64 字符串读取 - 异步
  static Future<String> readAsBase64(String path) => File(path).readAsBase64();

  /// 方法将整个文件内容作为 base64 字符串读取
  static String readAsBase64Sync(String path) => File(path).readAsBase64Sync();

  /// 同步地将字符串写入文件 - 异步
  static Future<File> writeString(String path, String content) => File(path).writeAsString(content);

  /// 同步地将字符串写入文件
  static void writeStringSync(String path, String content, {FileMode mode = FileMode.write}) => File(path).writeAsStringSync(content, mode: mode);

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

  /// 所有目录下的所有文件和目录 - 异步迭代
  static Stream<T> getEntity<T extends FileSystemEntity>(String path, {bool recursive = true}) async* {
    final entities = Directory(path).list(recursive: recursive);
    await for (var item in entities) {
      if (item is T) yield item;
    }
  }

  /// 所有目录下的所有文件和目录
  static List<T> getEntitySync<T extends FileSystemEntity>(String path, {bool recursive = true}) {
    final entities = Directory(path).listSync(recursive: recursive);
    if (T is FileSystemEntity) {
      return entities as List<T>;
    }
    return entities.whereType<T>().toList();
  }

  /// 所有目录下的所有文件 - 异步迭代
  static Stream<File> getFiles(String path, {bool recursive = true}) => getEntity<File>(path, recursive: recursive);

  /// 所有目录下的所有文件
  static List<File> getFilesSync(String path, {bool recursive = true}) => getEntitySync<File>(path, recursive: recursive);

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
  static List<Directory> subDirInfo(String path) => getEntitySync<Directory>(path, recursive: false);

  /// 获取指定文件夹中子目录的名称
  static List<String> subDir(String path) => subDirInfo(path).map((f) => p.basename(f.path)).toList();

  /// 链接路径
  ///
  ///     join('path', 'to', 'foo'); // -> 'path/to/foo'
  ///     join('path', '/to', 'foo'); // -> 'path/to/foo'
  ///     join('path', '/to', '/foo'); // -> 'path/to/foo'
  static String join(String part1, [String? part2, String? part3, String? part4, String? part5]) {
    Uri;
    return FS.normalize(p.join(part1, _remove(part2), _remove(part3), _remove(part4), _remove(part5)));
  }

  /// 路径序列化
  static String normalize(String path) => Uri.parse(path).normalizePath().toString();

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

  /// 获取[path]在最后一个分隔符之后的部分, 带有扩展名
  ///
  ///     basename('path/to/foo.dart'); // -> 'foo.dart'
  ///     basename('path/to');          // -> 'to'
  static String basenameExt(String path) => p.basename(path);

  /// 获取[path]在最后一个分隔符之后的部分, 不带扩展名
  ///
  ///     basename('path/to/foo.dart'); // -> 'foo'
  ///     basename('path/to');          // -> 'to'
  static String basename(String path) => p.basenameWithoutExtension(path);

  // 去除开头的 /
  static String? _remove(String? str) {
    if (str?.startsWith('/') ?? false) {
      return str!.substring(1);
    }
    return str;
  }

  /// 获取压缩存档
  static Future<Archive> getZipArchive(String src, {bool isAsset = false}) async {
    final zip = ZipDecoder();
    Archive archive;
    if (isAsset) {
      // 获取2进制内容
      Uint8List bytes = (await rootBundle.load(src)).buffer.asUint8List();
      // 解压
      archive = zip.decodeBytes(bytes);
    } else {
      // 获取输入流
      final inputStream = InputFileStream(src);
      // 解压
      archive = zip.decodeStream(inputStream);
    }
    return archive;
  }

  /// 解压缩文件到指定路径
  ///
  /// [src] 压缩文件来源
  ///
  /// [target] 解压位置
  ///
  /// [isAsset] 是否是资源文件
  ///
  /// [cover] 是否覆盖已有的文件
  static Future<void> unzip(String src, String target, {bool isAsset = false, bool cover = false}) async {
    final archive = await getZipArchive(src, isAsset: isAsset);
    // 创建目录
    createDirSync(target);
    // 循环
    for (final entry in archive) {
      // 路径
      final filePath = join(target, entry.name);
      // 判断是否不需要覆盖
      if (!cover && pathExistsSync(filePath)) continue;
      // 文件
      if (entry.isFile) {
        final outputStream = OutputFileStream(filePath);
        entry.writeContent(outputStream);
        await outputStream.close();
      } else {
        createDirSync(filePath);
      }
    }
    await archive.clear();
  }
}

extension FileExt on File {
  /// 获取 hash 值
  Future<String> getHash() => Crypto.cryptoFile(this);

  /// 方法将整个文件内容作为 base64 字符串读取
  ///
  /// 如果操作失败，抛出[FileSystemException]
  Future<String> readAsBase64() async => base64.encode(await readAsBytes());

  /// 方法将整个文件内容作为 base64 字符串读取
  ///
  /// 如果操作失败，抛出[FileSystemException]
  String readAsBase64Sync() => base64.encode(readAsBytesSync());
}
