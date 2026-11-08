import 'dart:developer' as developer;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  SpeechService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('id-ID'); // Support Indonesian
    await _tts.setSpeechRate(0.9);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<bool> _initSpeech() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => developer.log('Speech error: $error', name: 'SpeechService'),
        onStatus: (status) => developer.log('Speech status: $status', name: 'SpeechService'),
      );
    }
    return _isInitialized;
  }

  Future<void> startListening(
    void Function(String text) onResult, {
    required void Function() onDone,
  }) async {
    final available = await _initSpeech();
    if (!available) {
      onDone();
      return;
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onDone();
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    // Truncate very long responses for TTS
    final truncated = text.length > 300 ? '${text.substring(0, 300)}...' : text;
    await _tts.speak(truncated);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
    _speech.cancel();
  }
}
