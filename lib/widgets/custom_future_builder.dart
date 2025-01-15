import 'package:flutter/material.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget? onLoading;
  final Widget? onError;
  final Widget? onNoData;
  final Widget Function(BuildContext, T) builder;

  const CustomFutureBuilder({
    super.key, 
    required this.future,
    this.onLoading,
    this.onError,
    this.onNoData,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return onLoading ?? Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return onError ?? Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return onNoData ?? Text('No data Available');
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}
