import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, StringExtension, Trans;

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
    // 控件
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(18),
        constraints: const BoxConstraints(
          minHeight: 160,
          minWidth: 300,
          maxHeight: 260,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️${"warning".tr}', textScaler: const TextScaler.linear(1.2)),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: Text('deleteWarning'.tr),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 24),
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
            ),
          ],
        ),
      ),
    );
  }
}

