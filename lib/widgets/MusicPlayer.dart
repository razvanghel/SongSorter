import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:song_sorter/helper/SizeHandler.dart';

import '../model/Song.dart';

class MusicPlayer extends StatefulWidget {

  Song? song;
  List<Song> songs = [];

  MusicPlayer({this.song, required this.songs, required this.current});

  int current = -1;
  bool stop = false;

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final audio = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int oldIndex = -1;

  @override
  void initState() {
    super.initState();
    audio.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audio.onDurationChanged.listen((state) {
      setState(() {
        duration = state;
      });
    });
    audio.onPositionChanged.listen((state) {
      setState(() {
        position = state;
      });
    });
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  Future playSong() async {
    audio.setReleaseMode(ReleaseMode.stop);
    await audio.play(DeviceFileSource(widget.songs[widget.current].path));
  }

  Future<void> changeSong() async {
    audio.stop();
    audio.setReleaseMode(ReleaseMode.stop);
    await audio.play(DeviceFileSource(widget.songs[widget.current].path));
  }

  Song? getCurrentSong() {
    return widget.current >= 0 ? widget.songs[widget.current] : null;
  }

  _stop() {
    audio.stop();
    return Expanded(child: SizedBox());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.current != oldIndex) {
      oldIndex = widget.current;
      playSong();
    }
    return widget.current > -1 && widget.current < widget.songs.length
        ? Container(
          child: Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.keyboard_double_arrow_left),
                          iconSize: 25,
                          onPressed: () async {
                            setState(() {
                              widget.current =
                                  (widget.songs.length + widget.current - 1) %
                                      widget.songs.length;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          iconSize: 25,
                          onPressed: () async {
                            if (isPlaying) {
                              await audio.pause();
                            } else {
                              await audio.resume();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.keyboard_double_arrow_right),
                          iconSize: 25,
                          onPressed: () async {
                            setState(() {
                              widget.current =
                                  (widget.songs.length + widget.current + 1) %
                                      widget.songs.length;
                            });
                          },
                        ),
                        Text(getCurrentSong()?.fileName ?? ""),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        child: Slider(
                          min: 0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds.toDouble(),
                          onChanged: (value) async {
                            final position = Duration(seconds: value.toInt());
                            await audio.seek(position);
                            await audio.resume();
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
        )
        : _stop();
  }
}
