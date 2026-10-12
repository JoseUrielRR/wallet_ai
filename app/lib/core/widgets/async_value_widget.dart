import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_state_view.dart';
import 'shimmer_loading.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading?.call() ??
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CardShimmerPlaceholder(),
          ),
      error: (e, st) =>
          error?.call(e, st) ??
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ErrorStateView(
              message: e.toString(),
              onRetry: onRetry,
            ),
          ),
    );
  }
}
