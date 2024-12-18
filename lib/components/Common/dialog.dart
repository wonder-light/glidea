import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/lang/base.dart';

/// 放入 [Dialog] 显示中显示的控件
class DialogWidget extends StatelessWidget {
  const DialogWidget({
    super.key,
    this.onConfirm,
    this.onCancel,
    this.header,
    this.content,
    this.actions,
  });

  /// 确认时的回调函数
  final VoidCallback? onConfirm;

  /// 确认时的回调函数
  final VoidCallback? onCancel;

  /// 弹窗的头部控件
  final Widget? header;

  /// 弹窗的内容控件
  final Widget? content;

  /// 弹窗的操作按钮控件
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    // 按钮样式
    const style = ButtonStyle(
      visualDensity: VisualDensity(horizontal: -2, vertical: -2),
      alignment: Alignment.center,
    );
    // 头部
    Widget headerWidget = header ??
        Padding(
          padding: kAllPadding16,
          child: Text('⚠️${Tran.warning.tr}', textScaler: const TextScaler.linear(1.2)),
        );
    // 内容
    Widget contentWidget = Flexible(
      fit: FlexFit.tight,
      child: content ??
          Padding(
            padding: kAllPadding16,
            child: Text(Tran.deleteWarning.tr),
          ),
    );
    // 操作按钮
    Widget actionWidget = actions ??
        Padding(
          padding: kAllPadding16 + kTopPadding8,
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
                child: Text(Tran.confirm.tr),
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
          headerWidget,
          contentWidget,
          actionWidget,
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
