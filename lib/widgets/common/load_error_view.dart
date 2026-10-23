import 'package:flutter/material.dart';
import 'package:inspireui/extensions/string_extension.dart';

import '../../generated/l10n.dart';

/// Takes the place of content that failed to load, so a screen whose request
/// was refused, timed out or never left the device says so and offers a retry,
/// instead of rendering blank.
///
/// Not [NoInternetConnection]: that one always reads "No internet connection",
/// which is wrong when the server answered but refused to serve the content,
/// and its spinner is a file-level flag shared by every instance on screen.
class LoadErrorView extends StatefulWidget {
  const LoadErrorView({super.key, required this.onRetry, this.error});

  /// Re-issues the request that failed. The button shows a spinner until the
  /// returned future completes, whether it succeeds or fails again.
  final Future<void> Function() onRetry;

  /// What went wrong. Only used to pick the message: a connection that never
  /// left the device reads differently from a server that answered but would
  /// not serve the content.
  final Object? error;

  @override
  State<LoadErrorView> createState() => _LoadErrorViewState();
}

class _LoadErrorViewState extends State<LoadErrorView> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await widget.onRetry();
    } catch (_) {
      // The caller re-renders this view from its own error state; a second
      // failure has nothing more to say here.
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offline = '${widget.error ?? ''}'.isNoInternetError;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.55),
          ),
          const SizedBox(height: 16),
          Text(
            offline
                ? S.of(context).noInternetConnection
                : S.of(context).couldNotLoadContent,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: _retrying
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                // Colours come from the app's elevatedButtonTheme, so the
                // button is olive on cream in light mode and the light olive
                // in dark mode, like every other primary action.
                : ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: Text(S.of(context).retry),
                  ),
          ),
        ],
      ),
    );
  }
}
