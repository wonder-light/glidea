import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/image.dart';
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
    if (image == null) return false;
    return await image.compressImage(target);
  }
}

/// config class for image, tag: img
class ImageConfig {
  /// 构建图片
  static Widget builderImg(String url, {Map<String, String>? attributes, BoxFit fit = BoxFit.cover}) {
    if (url.isEmpty) {
      return Image.asset('assets/images/upload_image.jpg', errorBuilder: buildError);
    }
    // 网络图片
    if (url.startsWith('http')) {
      return Image.network(url, fit: fit, errorBuilder: buildError);
    }
    // 网络图片
    if (url.startsWith('assets')) {
      Image.asset(url, fit: fit, errorBuilder: buildError);
    }
    // post 中的本地图片
    if (url.startsWith(featurePrefix)) {
      url = url.substring(featurePrefix.length);
    }
    return Image(image: FileImageExpansion.file(url), fit: fit, errorBuilder: buildError);
  }

  /// 图片加载失败时的占位图
  static Widget buildError(BuildContext context, Object error, StackTrace? stacktrace) {
    return Image.asset('assets/images/loading_error.png');
  }
}
