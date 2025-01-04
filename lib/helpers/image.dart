import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img show Image, copyResize, encodeJpg, writeFile, decodeImageFile;

///  扩展 FileImage, 在图片变化时可以进行更新, 包括路径变化、大小变化等
class FileImageExpansion extends FileImage {
  ///文件大小
  late final int fileSize;

  /// 创建 [FileImageExpansion],
  ///
  /// 在图片变化时可以进行更新, 包括路径变化、大小变化等
  FileImageExpansion(super.file, {super.scale}) {
    fileSize = file.lengthSync();
  }

  /// 通过路径 [path] 创建 [FileImageExpansion],
  ///
  /// 在图片变化时可以进行更新, 包括路径变化、大小变化等
  FileImageExpansion.file(String path, {double scale = 1.0}) : this(File(path), scale: scale);

  /// 除了比较路径和缩放比例以外，还要比较文件大小
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is FileImageExpansion && other.file.path == file.path && other.scale == scale && other.fileSize == fileSize;
  }
}

extension ImageExt on img.Image {
  /// 复制压缩图片到指定路径
  ///
  /// [quality] => [0, 100]
  /// [scale] => (0, 1]
  Future<bool> compressImage(String path, {int quality = 70, double scale = 1.0}) async {
    var image = img.copyResize(this, width: (width * scale).toInt(), height: (height * scale).toInt());
    var lists = img.encodeJpg(image, quality: quality);
    return img.writeFile(path, lists);
  }

  /// 将 [path] 的图片复制压缩到 [target]
  static Future<bool> compress(String path, String target) async {
    var image = await img.decodeImageFile(path);
    if(image == null) return false;
    return await image.compressImage(target);
  }
}
