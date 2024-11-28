import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;

class DialogWidget extends StatelessWidget {
  const DialogWidget({super.key, this.onConfirm, this.onCancel});

  /// 确认时的回调函数
  final VoidCallback? onConfirm;

  /// 确认时的回调函数
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    // 按钮样式
    const style = ButtonStyle(
      visualDensity: VisualDensity(horizontal: -2, vertical: -2),
      alignment: Alignment.center,
    );
    // 头部
    Widget header = Padding(
      padding: const EdgeInsets.all(18),
      child: Text('⚠️${"warning".tr}', textScaler: const TextScaler.linear(1.2)),
    );
    // 内容
    Widget content = Flexible(
      fit: FlexFit.tight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text('deleteWarning'.tr),
      ),
    );
    // 操作按钮
    Widget actions = Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 18, left: 18, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: onCancel,
            style: style,
            child: Text("cancel".tr),
          ),
          Container(width: 10),
          FilledButton(
            onPressed: onConfirm,
            style: style,
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
    // 弹窗
    Widget dialogChild = IntrinsicWidth(
      stepWidth: 60,
      stepHeight: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          content,
          actions,
        ],
      ),
    );
    // 控件
    return Dialog(
      // insetPadding: EdgeInsets.zero, 与屏幕边缘保留的距离
      child: dialogChild,
    );
  }
}
