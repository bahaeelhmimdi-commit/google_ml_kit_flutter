import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      home: VideoScreen(),
    );
  }
}

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}
class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(

        Uri.parse(
        'https://showstream-32id.onrender.com/current_event_show'),

    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {

    setState(() {_controller.play();});
    });

    _controller.setLooping(true);
    _controller.initialize();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player Demo'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
