import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../model/Song.dart';

class MusicPlayer extends StatefulWidget{

  Song song;
  MusicPlayer({required this.song});

  // static ValueNotifier<Song> selectedSong = ValueNotifier(Song(fileName: '', artist: '', title: '', path: ''));
  @override
  State<MusicPlayer> createState() => _MusicPlayerState();

}

class _MusicPlayerState extends State<MusicPlayer>{

  final audio = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState(){
    super.initState();
    playSong();
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
  void dispose(){
    audio.dispose();
    super.dispose();
  }

  Future playSong() async {
    audio.setReleaseMode(ReleaseMode.stop);
    await audio.play(DeviceFileSource(widget.song.path));
  }

  Future<void> changeSong() async {
    var song = Song(fileName: 'dorel', path:'E:\\.djLib\\Manele\\romanesti\\Dorel de la Popesti - Sunt mare mafiot (320 kbps).mp3', artist: '', title: '');
    audio.stop();
    await audio.play(DeviceFileSource(song.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [

            IconButton(
              icon: Icon(Icons.keyboard_double_arrow_left),
              iconSize: 25,
              onPressed: () async {
                changeSong();

              },
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause: Icons.play_arrow,
              ),
              iconSize: 25,
              onPressed: () async {
                if(isPlaying){
                  await audio.pause();
                }
                else{
                  await audio.resume();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.keyboard_double_arrow_right),
              iconSize: 25,
              onPressed: () async {

              },
            ),
            Text(widget.song.fileName),

          ],
        ),
        Container(
          height: 30,
          // width: 300,
          child: Row(
            children: [
              Slider(
                min:0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audio.seek(position);
                  await audio.resume();
                },
              ),
            ],
          ),
        )

      ],
    );
  }
}









