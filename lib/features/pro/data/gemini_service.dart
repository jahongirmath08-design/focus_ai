import 'dart:convert';

import 'package:http/http.dart' as http;

/// Gemini API xatosi (status kodi bilan) — UI mos xabar ko'rsatishi uchun.
class GeminiException implements Exception {
  GeminiException(this.code, this.detail);
  final int code;
  final String detail;

  /// API xato matnini qisqa, o'qiladigan ko'rinishda qaytaradi (diagnostika).
  String shortDetail() {
    try {
      final d = jsonDecode(detail);
      if (d is Map && d['error'] is Map && d['error']['message'] is String) {
        final m = d['error']['message'] as String;
        return m.length > 160 ? '${m.substring(0, 160)}…' : m;
      }
    } catch (_) {}
    final s = detail.replaceAll('\n', ' ').trim();
    return s.length > 160 ? '${s.substring(0, 160)}…' : s;
  }

  @override
  String toString() => 'GeminiException($code): $detail';
}

/// Bitta suhbat xabari (UI'dan keladi).
typedef ChatTurn = ({bool fromUser, String text});

/// Google Gemini API'ga jonli so'rov yuboruvchi yengil xizmat.
/// REST `generateContent`. Kalit URL'da emas, `x-goog-api-key` sarlavhasida.
///
/// ISHONCHLILIK — MODEL FALLBACK: modellar ketma-ket sinaladi. Agar flash-lite
/// band (503) yoki kvotasi tugagan (429) bo'lsa, avtomatik `flash`ga o'tadi
/// (alohida quvvat va kvota). Ikkalasi bir vaqtda yiqilishi juda kam — shuning
/// uchun deyarli har doim javob keladi.
class GeminiService {
  GeminiService(this.apiKey);
  final String apiKey;

  // Ketma-ketlik: avval yuqori limitli flash-lite (1000/kun, multimodal),
  // band bo'lsa flash (alohida kvota). Sifati ham, ishonchliligi ham yaxshi.
  static const _models = ['gemini-2.5-flash-lite', 'gemini-2.5-flash'];

  Future<String> chat({
    required String systemPrompt,
    required List<ChatTurn> history,
    List<int>? imageBytes,
    String imageMime = 'image/jpeg',
  }) async {
    final contents = <Map<String, dynamic>>[];
    for (var i = 0; i < history.length; i++) {
      final m = history[i];
      final parts = <Map<String, dynamic>>[
        {'text': m.text},
      ];
      // Rasm faqat OXIRGI foydalanuvchi xabariga biriktiriladi (multimodal).
      if (imageBytes != null && m.fromUser && i == history.length - 1) {
        parts.add({
          'inline_data': {
            'mime_type': imageMime,
            'data': base64Encode(imageBytes),
          },
        });
      }
      contents.add({'role': m.fromUser ? 'user' : 'model', 'parts': parts});
    }

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
        // gemini-2.5 "o'ylash" rejimi chiqish tokenlarini yeb, javobni yarmida
        // uzib qo'yardi. Uni o'chiramiz — javob to'liq va tezroq.
        'thinkingConfig': {'thinkingBudget': 0},
      },
    });

    GeminiException? lastErr;
    for (final model in _models) {
      final endpoint = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
      );
      // Har bir model uchun 2 urinish (vaqtinchalik 5xx/tarmoq uchun).
      for (var attempt = 0; attempt < 2; attempt++) {
        if (attempt > 0) {
          await Future.delayed(const Duration(milliseconds: 1200));
        }
        http.Response res;
        try {
          res = await http
              .post(
                endpoint,
                headers: {
                  'Content-Type': 'application/json',
                  'x-goog-api-key': apiKey,
                },
                body: payload,
              )
              .timeout(const Duration(seconds: 40));
        } catch (e) {
          lastErr = GeminiException(-1, e.toString());
          continue; // tarmoq — shu modelni qayta urinamiz
        }
        if (res.statusCode == 200) return _parse(res);
        lastErr = GeminiException(res.statusCode, res.body);
        // 400/401/403 — so'rov/kalit xatosi: boshqa model ham yordam bermaydi.
        if (res.statusCode == 400 ||
            res.statusCode == 401 ||
            res.statusCode == 403) {
          throw lastErr;
        }
        // 429 (kvota/limit) yoki 503 (band) — keyingi MODELga o'tamiz.
        if (res.statusCode == 429 || res.statusCode == 503) break;
        // boshqa 5xx — shu modelni qayta urinamiz (attempt davom etadi).
      }
    }
    throw lastErr ?? GeminiException(0, 'No response');
  }

  String _parse(http.Response res) {
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
