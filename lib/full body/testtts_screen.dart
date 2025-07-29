import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TestttsScreen extends StatefulWidget {
  @override
  _TestttsScreenState createState() => _TestttsScreenState();
}

class _TestttsScreenState extends State<TestttsScreen> {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speakTest() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(
        "This is a test of text to speech. If you hear this, TTS is working.");
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TTS Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: _speakTest,
          child: Text("Test Voice"),
        ),
      ),
    );
  }
}
