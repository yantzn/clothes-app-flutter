import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showDatePickerSheet(
  BuildContext context, {
  required DateTime initial,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) async {
  DateTime selected = initial;
  final result = await showModalBottomSheet<DateTime?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (ctx) {
      return SafeArea(
        child: SizedBox(
          height: 320,
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, null),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, selected),
                      child: const Text('完了'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.light),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: minimumDate ?? DateTime(1900),
                    maximumDate: maximumDate,
                    onDateTimeChanged: (DateTime d) => selected = d,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result;
}
