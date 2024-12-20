import 'dart:convert' show utf8;
import 'dart:io' show File, RandomAccessFile;

import 'package:convert/convert.dart' show AccumulatorSink;
import 'package:crypto/crypto.dart' show Digest, Hash, sha1;
import 'package:flutter/foundation.dart' show AsyncCallback, Uint8List;
import 'package:glidea/helpers/constants.dart';

typedef AsyncGetterValue<T> = Future<T> Function(int start, int length);

/// 编码
class Crypto {
  /// 编码字符串
  static Future<String> cryptoStr(String src, {Hash hash = sha1}) async {
    var bytes = utf8.encode(src);
    int strLength = bytes.length;
    bool useSegment = strLength > fileSize10M;
    return _crypto(
      hash: hash,
      length: strLength,
      getter: (index, length) async {
        if (!useSegment) bytes;
        return bytes.sublist(index, length);
      },
    );
  }

  /// 编码字节
  static Future<String> cryptoBytes(List<int> bytes, {Hash hash = sha1}) async {
    int length = bytes.length;
    bool useSegment = length > fileSize10M;
    return _crypto(
      hash: hash,
      length: length,
      getter: (index, length) async {
        if (!useSegment) return bytes;
        return bytes.sublist(index, length);
      },
    );
  }

  /// 编码文件
  static Future<String> cryptoFile(File file, {Hash hash = sha1}) async {
    RandomAccessFile? xFile;
    int length = file.lengthSync();
    if (length > fileSize10M) {
      xFile = await file.open();
    }
    return _crypto(
      hash: hash,
      length: length,
      getter: (index, length) async {
        if (xFile == null) return file.readAsBytesSync();
        return xFile.readSync(length);
      },
      close: () async => await xFile?.close(),
    );
  }

  /// 编码
  ///
  /// [hash] 加密哈希函数的接口
  ///
  /// [length] 加密字节的长度
  ///
  /// [segmentSize] 需要进行分段的大小
  ///
  /// [getter] 获取字节的方法
  ///
  /// [close] 完成后关闭字节的方法
  static Future<String> _crypto({
    required Hash hash,
    required int length,
    int segmentSize = fileSize10M,
    required AsyncGetterValue<List<int>> getter,
    AsyncCallback? close,
  }) async {
    try {
      if (length <= segmentSize) {
        return hash.convert(await getter(0, length)).toString();
      }
      // 大文件分块获取
      // 输出块
      final output = AccumulatorSink<Digest>();
      final input = hash.startChunkedConversion(output);
      int x = 0;
      while (x < segmentSize) {
        final tmpLen = segmentSize - x > fileSize10M ? fileSize10M : segmentSize - x;
        // 分块获取
        input.add(await getter(x, tmpLen));
        x += tmpLen;
      }
      input.close();

      return output.events.single.toString();
    } finally {
      await close?.call();
    }
  }
}
