/// main [Isolate] 发送的数据
base class SendData {
  SendData({required this.id, required this.invocation});

  /// 任务的 ID
  final int id;

  // 需要执行的方法
  final Invocation invocation;
}

/// main [Isolate] 接收的数据
base class ReceiveData {
  ReceiveData({required this.id, this.data, this.error, this.stackTrace});

  /// 任务的 ID
  final int id;

  // 完成后返回的数据
  final dynamic data;

  /// 错误消息
  final Object? error;

  /// 错误堆栈
  final StackTrace? stackTrace;
}
