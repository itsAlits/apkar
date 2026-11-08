import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/balinese_mask.dart';

class GeminiService {
  static const String _apiKeyPrefKey = 'gemini_api_key';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPrefKey) ?? '';
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, key);
  }

  Future<String> askQuestion(
    String question,
    List<Map<String, String>> history, {
    BalineseMask? activeMask,
  }) async {
    final apiKey = await getApiKey();

    // Mode demo cerdas khusus Budaya Topeng Bali jika API Key belum diisi
    if (apiKey.isEmpty) {
      return _generateBalineseDemoResponse(question, activeMask);
    }

    final maskName = activeMask?.name ?? 'Topeng Tradisional Bali';
    final maskDesc = activeMask?.description ?? 'Kesenian topeng sakral Bali';
    final maskPhil = activeMask?.philosophy ?? 'Keseimbangan Rwa Bhineda';

    // System Prompt bertemakan Taksu Topeng Bali
    final systemPrompt =
        'Anda adalah "Taksu AR", kurator cerdas dan budayawan ahli Topeng Tradisional Bali. '
        'Saat ini pengguna sedang memindai objek 3D: $maskName ($maskDesc). '
        'Filosofinya adalah: $maskPhil. '
        'Jawablah pertanyaan pengguna seputar topeng Bali, karakter tari, makna ukiran, kayu pule, '
        'upacara sakral, dan mitologi Bali secara santun, mendalam, dan ringkas (maksimal 2-3 kalimat) '
        'dalam Bahasa Indonesia yang alami agar nyaman didengar saat dibacakan oleh suara (TTS).';

    final List<Map<String, dynamic>> contents = [];

    // Add history (skip the last item which is the current question)
    for (int i = 0; i < history.length - 1; i++) {
      final item = history[i];
      contents.add({
        'role': item['role'] == 'user' ? 'user' : 'model',
        'parts': [
          {'text': item['text']},
        ],
      });
    }

    // Add current question
    contents.add({
      'role': 'user',
      'parts': [
        {'text': question},
      ],
    });

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 256,
      },
    };

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text ?? 'Om Swastyastu, tidak ada respon yang diterima.';
    } else {
      final error = jsonDecode(response.body);
      final message = error['error']?['message'] ?? 'Unknown error';
      throw Exception('Gemini API: $message');
    }
  }

  String _generateBalineseDemoResponse(String question, BalineseMask? mask) {
    final q = question.toLowerCase();
    final name = mask?.name ?? 'Topeng Bali';

    if (q.contains('filosofi') || q.contains('makna')) {
      if (mask != null) {
        return 'Filosofi ${mask.name}: ${mask.philosophy} Ini mencerminkan kearifan lokal Bali yang sangat luhur.';
      }
      return 'Topeng Bali mengandung taksu sakral dan konsep Rwa Bhineda, yaitu keseimbangan abadi antara kebaikan dan kejahatan di alam semesta.';
    } else if (q.contains('kayu') || q.contains('pule') || q.contains('bahan')) {
      return 'Topeng Bali umumnya dipahat dari Kayu Pule keramat karena seratnya halus, tahan lama, dan dipercaya memiliki getaran spiritual magis.';
    } else if (q.contains('barong') || q.contains('rangda')) {
      return 'Pertarungan Barong dan Rangda adalah pertarungan tanpa akhir antara Dharma dan Adharma. Keduanya saling melengkapi demi keharmonisan kosmos.';
    } else if (q.contains('upacara') || q.contains('tari') || q.contains('kapan')) {
      return '$name biasa ditarikan pada upacara Piodalan di Pura sebagai sarana persembahan suci dan pembersihan spiritual desa (Panglukatan).';
    } else if (q.contains('halo') || q.contains('siapa')) {
      return 'Om Swastyastu! Saya Taksu AR, pemandu budaya Topeng Bali Anda. Anda sedang mengamati $name. Silakan tanyakan sejarah atau filosofinya!';
    } else {
      return 'Pertanyaan tentang $name: "$question" telah dicatat. Masukkan Gemini API Key Anda di Pengaturan untuk eksplorasi AI tanpa batas!';
    }
  }
}
