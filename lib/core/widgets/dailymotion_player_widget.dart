import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/dailymotion_utils.dart';

class DailymotionPlayerWidget extends StatefulWidget {
  final String videoUrlOrId;
  final bool autoPlay;
  final VoidCallback? onReady;

  const DailymotionPlayerWidget({
    super.key,
    required this.videoUrlOrId,
    this.autoPlay = true,
    this.onReady,
  });

  @override
  State<DailymotionPlayerWidget> createState() => _DailymotionPlayerWidgetState();
}

class _DailymotionPlayerWidgetState extends State<DailymotionPlayerWidget> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final htmlData = DailymotionUtils.getEmbedHtml(
      widget.videoUrlOrId,
      autoplay: widget.autoPlay,
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
            onLoadStop: (controller, url) {
              if (mounted) {
                setState(() => _isLoading = false);
                widget.onReady?.call();
              }
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
