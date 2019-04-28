import 'dart:async';
import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayer/audioplayer.dart';
// import 'package:audioplayer2/audioplayer2.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: new Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Home();
  }
}

// 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'
// 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'
class _Home extends State<Home> {
  List<Musique> maListeMusique = [
    new Musique('titreOne', 'artisteOne', 'assets/un.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Musique('titredeux', 'artistedeux', 'assets/deux.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
  ];

//variables
  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;

  Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  Playerstate status = Playerstate.stopped;

// pour le forward et rewind
  int index = 0;

//Musique
  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeMusique[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: Text(
          'Music',
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              child: Container(
                width: MediaQuery.of(context).size.width / 2.5,
                child: Image.asset(
                  maMusiqueActuelle.imagePath,
                ),
              ),
            ),
            textAvecStyle(maMusiqueActuelle.titre, 1.5),
            textAvecStyle(maMusiqueActuelle.artiste, 0.8),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                bouton(Icons.fast_rewind, 40.0, Actionmusic.rewind),
                bouton(
                    (status == Playerstate.playing)
                        ? Icons.pause
                        : Icons.play_arrow,
                    40.0,
                    (status == Playerstate.playing)
                        ? Actionmusic.pause
                        : Actionmusic.play),
                bouton(Icons.fast_forward, 40.0, Actionmusic.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textAvecStyle(fromDuration(position), 0.6),
                textAvecStyle(fromDuration(duree), 0.6)
              ],
            ),
            new Slider(
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: 30.0,
              inactiveColor: Colors.white,
              activeColor: Colors.blue,
              onChanged: (double d) {
                setState(() {
                  //Duration nouvelleduration = new Duration(seconds: d.toInt());
                  //position = nouvelleduration;
                  audioPlayer.seek(d);
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Text textAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        letterSpacing: 2.0,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  IconButton bouton(IconData icone, double taille, Actionmusic action) {
    return new IconButton(
        iconSize: taille,
        color: Colors.white,
        icon: new Icon(icone),
        onPressed: () {
          switch (action) {
            case Actionmusic.play:
              play();
              break;
            case Actionmusic.pause:
              pause();
              break;
            case Actionmusic.rewind:
              rewind();
              break;
            case Actionmusic.forward:
              forward();
              break;
          }
        });
  }

//AudioPlayer initialise

  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          status = Playerstate.stopped;
        });
      }
    }, onError: (message) {
      print('erreur : $message');
      setState(() {
        status = Playerstate.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      status = Playerstate.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      status = Playerstate.paused;
    });
  }

  //-----------------------------Forward

  void forward() {
    if (index == maListeMusique.length - 1) {
      index = 0;
    } else {
      index++;
    }
    maMusiqueActuelle = maListeMusique[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = maListeMusique.length - 1;
      } else {
        index--;
      }
      maMusiqueActuelle = maListeMusique[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }

  // changer texte
  String fromDuration(Duration duree) {
    return duree.toString().split('.').first;
  }

  // void rewind() {
  //   if (index == 0) {
  //     index = maListeMusique.length - 1;
  //   } else {
  //     index--;
  //   }
  //   maMusiqueActuelle = maListeMusique[index];
  //   audioPlayer.stop();
  //   configurationAudioPlayer();
  //   play();
  // }
} //fin de class principale

// Class exterieur
enum Actionmusic { play, pause, rewind, forward }
enum Playerstate { playing, stopped, paused }
