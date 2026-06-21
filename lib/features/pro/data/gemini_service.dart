import 'dart:convert';

import 'package:http/http.dart' as http;

/// Gemini API xatosi (status kodi bilan) — UI mos xabar ko'rsatishi uchun.
class GeminiException implements Exception {
  GeminiException(this.code, this.detail);
  final int code;
  final String detail;

  @override
  String toString() => 'GeminiException($code): $detail';
}

/// Bitta suhbat xabari (UI'dan keladi).
typedef ChatTurn = ({bool fromUser, String text});

/// Google Gemini API'ga jonli so'rov yuboruvchi yengil xizmat.
/// REST `generateContent` — model: gemini-2.5-flash (bepul tier).
/// Kalit URL'da emas, `x-goog-api-key` sarlavhasida ketadi (xavfsizroq).
class GeminiService {
  GeminiService(this.apiKey);
  final String apiKey;

  static const _model = 'gemini-2.5-flash';
  static final Uri _endpoint = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
  );

  Future<String> chat({
    required String systemPrompt,
    required List<ChatTurn> history,
  }) async {
    final contents = [
      for (final m in history)
        {
          'role': m.fromUser ? 'user' : 'model',
          'parts': [
            {'text': m.text},
          ],
        },
    ];

    final payload = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.8,
        'maxOutputTokens': 2048,
        // gemini-2.5-flash "o'ylash" rejimi chiqish tokenlarini yeb, javobni
        // yarmida uzib qo'yardi. Uni o'chiramiz — javob to'liq va tezroq.
        'thinkingConfig': {'thinkingBudget': 0},
      },
    });

    final http.Response res;
    try {
      res = await http
          .post(
            _endpoint,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: payload,
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      // Tarmoq/timeout — internet muammosi sifatida yuqoriga uzatamiz.
      throw GeminiException(-1, e.toString());
    }

    if (res.statusCode != 200) {
      throw GeminiException(res.statusCode, res.body);
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is! Map) throw GeminiException(0, 'Bad response');
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw GeminiException(0, 'No candidates');
    }
    final content = (candidates.first as Map)['content'];
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List) throw GeminiException(0, 'No parts');
    final buffer = StringBuffer();
    for (final p in parts) {
      if (p is Map && p['text'] is String) buffer.write(p['text']);
    }
    return buffer.toString().trim();
  }
}
