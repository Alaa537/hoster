import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'premium_dialogs.dart';

/// Backward-compatible wrappers that use the premium dialog system.

Future<bool> confirm(
  BuildContext ctx,
  String title, {
  String? msg,
  bool danger = false,
  bool default_ = false,
}) async {
  final r = await showConfirmDialog(
    ctx,
    title: title,
    message: msg,
    danger: danger,
    confirmLabel: danger ? 'نعم، متأكد' : 'تأكيد',
  );
  return r || default_;
}

Future<String?> promptText(
  BuildContext ctx,
  String title, {
  String? hint,
  String initial = '',
  bool obscure = false,
  int maxLines = 1,
}) {
  return showPromptDialog(
    ctx,
    title: title,
    hint: hint,
    initial: initial,
    obscure: obscure,
    maxLines: maxLines,
  );
}

Future<int?> promptInt(
  BuildContext ctx,
  String title, {
  String? hint,
  int? initial,
}) async {
  final r = await promptText(ctx, title,
      hint: hint, initial: initial?.toString() ?? '');
  if (r == null || r.trim().isEmpty) return null;
  return int.tryParse(r.trim());
}

void snack(BuildContext ctx, String msg, {bool error = false}) {
  ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(
      children: [
        Icon(
          error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
          color: error ? Colors.white : Colors.black,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            msg,
            style: TextStyle(
              color: error ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: error ? C.danger : C.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    duration: const Duration(seconds: 3),
    elevation: 8,
  ));
}

void snackInfo(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(
      children: [
        const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            msg,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: C.info,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    duration: const Duration(seconds: 3),
  ));
}
