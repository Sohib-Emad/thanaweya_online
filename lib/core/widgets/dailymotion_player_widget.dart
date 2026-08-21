import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/dailymotion_utils.dart';

class DailymotionPlayerWidget extends StatefulWidget {
  final String videoUrlOrId;
  final bool autoPlay;
  final int startSeconds;
  final VoidCallback? onReady;
  final void Function(Duration position, Duration duration)? onProgress;

  const DailymotionPlayerWidget({
    super.key,
    required this.videoUrlOrId,
    this.autoPlay = true,
    this.startSeconds = 0,
    this.onReady,
    this.onProgress,
  });

  @override
  State<DailymotionPlayerWidget> createState() =>
      _DailymotionPlayerWidgetState();
}

class _DailymotionPlayerWidgetState extends State<DailymotionPlayerWidget> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final htmlData = DailymotionUtils.getEmbedHtml(
      widget.videoUrlOrId,
      autoplay: widget.autoPlay,
      startSeconds: widget.startSeconds,
    );

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: htmlData,
              mimeType: 'text/html',
              encoding: 'utf-8',
              baseUrl: WebUri('https://www.dailymotion.com'),
            ),
            initialSettings: InAppWebViewSettings(
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              transparentBackground: false,
              isElementFullscreenEnabled: true,
              useShouldOverrideUrlLoading: false,
              supportZoom: false,
            ),
            onWebViewCreated: (controller) {
              controller.addJavaScriptHandler(
                handlerName: 'onDailymotionProgress',
                callback: (args) {
                  if (args.isNotEmpty) {
                    final timeSec = (args[0] as num?)?.toDouble() ?? 0.0;
                    final durSec = args.length > 1
                        ? ((args[1] as num?)?.toDouble() ?? 0.0)
                        : 0.0;
                    widget.onProgress?.call(
                      Duration(milliseconds: (timeSec * 1000).round()),
                      Duration(milliseconds: (durSec * 1000).round()),
                    );
                  }
                },
              );
            },
            onLoadStop: (controller, url) {
              if (mounted) {
                setState(() => _isLoading = false);
                widget.onReady?.call();
              }
            },
            onEnterFullscreen: (controller) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            },
            onExitFullscreen: (controller) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: NotebookColors.green,
                      strokeWidth: 2.5,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'جاري تشغيل فيديو Dailymotion...',
                      style: NotebookText.note(11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
