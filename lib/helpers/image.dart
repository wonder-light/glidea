import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img show Image, copyResize, encodeJpg, writeFile;

///  扩展FileImage
class FileImageExpansion extends FileImage {
  ///文件大小
  late final int fileSize;

  FileImageExpansion(File file, {double scale = 1.0}) : super(file, scale: scale) {
    fileSize = file.lengthSync();
  }

  /// 除了比较路径和缩放比例以外，还要比较文件大小
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is FileImageExpansion && other.file.path == file.path && other.scale == scale && other.fileSize == fileSize;
  }
}

extension ImageSaveExt on img.Image {
  /// 压缩图片
  Future<bool> compressImage(String path, {int quality = 80, int scale = 100}) async {
    var ratio = scale / 100;
    var image = img.copyResize(this, width: (width * ratio).toInt(), height: (height * ratio).toInt());
    var lists = img.encodeJpg(image, quality: quality);
    return img.writeFile(path, lists);
  }
}
