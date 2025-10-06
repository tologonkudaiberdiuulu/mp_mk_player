import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  // Инициализация MediaKit без параметра bufferSize
  MediaKit.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MP_MK Player',
      theme: ThemeData.dark(),
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  // Теперь bufferSize установлен здесь, в конфигурации плеера:
  final player = Player(
      // configuration: const PlayerConfiguration(
      //   bufferSize: 500 * 1024 * 1024, // 128 MB
      // ),
      );
  late final videoController = VideoController(
    player,
    // configuration: VideoControllerConfiguration(
    // androidAttachSurfaceAfterVideoParameters: true,
    // vo: 'gpu',
    // enableHardwareAcceleration: true,
    // ),
  );

  final playlist = {
    'Example MP4 (H.264)': 'asset:///assets/videos/example.mp4',
    'Sample AV1 MP4': 'asset:///assets/videos/sample_av1.mp4',
    'Sample MPEG2 TS': 'asset:///assets/videos/sample_mpeg2.ts',
    'Sample H265 MP4': 'asset:///assets/videos/sample_h265.mp4',
    'Hd-60': 'asset:///assets/videos/hd-60.mp4',
    'Sport': 'asset:///assets/videos/sport.MP4',
    'Utrk': 'asset:///assets/videos/utrk.MP4',
    //sample_h264
  };

  String? currentTitle;

  @override
  void initState() {
    super.initState();
    currentTitle = playlist.keys.first;
    player.open(Media(playlist[currentTitle]!));
  }

  void _openPlaylistDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Выбери видео'),
        children: playlist.entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() {
                currentTitle = entry.key;
              });
              player.open(Media(entry.value));
              Navigator.pop(context);
            },
            child: Text(entry.key),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle ?? 'MP_MK Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: _openPlaylistDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Video(
                controller: videoController,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    final currentIndex =
                        playlist.keys.toList().indexOf(currentTitle!);
                    if (currentIndex > 0) {
                      setState(() {
                        currentTitle =
                            playlist.keys.elementAt(currentIndex - 1);
                      });
                      player.open(Media(playlist[currentTitle]!));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () {
                    player.seek(
                        player.state.position - const Duration(seconds: 10));
                  },
                ),
                IconButton(
                  icon: Icon(
                    player.state.playing ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    player.playOrPause();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () {
                    player.seek(
                        player.state.position + const Duration(seconds: 10));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    final currentIndex =
                        playlist.keys.toList().indexOf(currentTitle!);
                    if (currentIndex < playlist.length - 1) {
                      setState(() {
                        currentTitle =
                            playlist.keys.elementAt(currentIndex + 1);
                      });
                      player.open(Media(playlist[currentTitle]!));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
