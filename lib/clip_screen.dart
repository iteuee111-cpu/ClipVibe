import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';

class ClipScreen extends StatefulWidget {
  const ClipScreen({super.key});

  @override
  State<ClipScreen> createState() => _ClipScreenState();
}

class _ClipScreenState extends State<ClipScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // FFmpeg clipping function
  Future<void> _exportClip() async {
    setState(() {
      _isProcessing = true;
    });

    // Sample FFmpeg command to trim first 5 seconds of the video
    String inputUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
    // For demonstration, we set up a trimming command structure
    String command = "-y -i $inputUrl -ss 00:00:00 -t 00:00:05 -c copy output.mp4";

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      setState(() {
        _isProcessing = false;
      });

      if (ReturnCode.isSuccess(returnCode)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clip exported successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export clip.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClipVibe - Video Clipper'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 250,
                    child: VideoPlayer(_controller),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isPlaying = !_isPlaying;
                            _isPlaying ? _controller.play() : _controller.pause();
                          });
                        },
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        label: Text(_isPlaying ? 'Pause' : 'Play'),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _exportClip,
                        icon: const Icon(Icons.cut),
                        label: Text(_isProcessing ? 'Processing...' : 'Export Clip'),
                      ),
                    ],
                  ),
                  if (_isProcessing) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ]
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
