import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class GeminiChatException implements Exception {
  const GeminiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiChatService {
  GeminiChatService({http.Client? client}) : _client = client ?? http.Client();

  static const defaultModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );

  final http.Client _client;

  Future<String> sendMessage({
    required String apiKey,
    required String model,
    required List<ChatMessage> conversation,
  }) async {
    final trimmedKey = apiKey.trim();
    final trimmedModel = model.trim().isEmpty ? defaultModel : model.trim();
    if (trimmedKey.isEmpty) {
      throw const GeminiChatException(
        'Bạn chưa thêm Gemini API key. Dán key vào ô API key hoặc chạy với '
        '--dart-define=GEMINI_API_KEY=YOUR_KEY.',
      );
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$trimmedModel:generateContent',
    );

    final contents = conversation
        .where((message) => message.text.trim().isNotEmpty)
        .takeLast(16)
        .map(
          (message) => {
            'role': message.geminiRole,
            'parts': [
              {'text': message.text.trim()},
            ],
          },
        )
        .toList();

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': trimmedKey,
      },
      body: jsonEncode({
        'systemInstruction': {
          'parts': [
            {
              'text': 'Bạn là trợ lý hữu ích trong ứng dụng Flutter. '
                  'Ưu tiên trả lời bằng tiếng Việt, rõ ràng và thực tế.',
            },
          ],
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'topP': 0.9,
          'maxOutputTokens': 1024,
        },
      }),
    );

    final responseBody = utf8.decode(response.bodyBytes);
    final data = jsonDecode(responseBody);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _readErrorMessage(data) ??
          'Gemini trả về lỗi ${response.statusCode}. Kiểm tra API key/model.';
      throw GeminiChatException(message);
    }

    final text = _readCandidateText(data) ?? '';
    if (text.trim().isEmpty) {
      throw const GeminiChatException(
        'Gemini không trả về nội dung. Hãy thử lại với câu hỏi khác.',
      );
    }

    return text.trim();
  }

  String? _readCandidateText(Object? data) {
    if (data is! Map) return null;
    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;

    final firstCandidate = candidates.first;
    if (firstCandidate is! Map) return null;

    final content = firstCandidate['content'];
    if (content is! Map) return null;

    final parts = content['parts'];
    if (parts is! List) return null;

    return parts
        .whereType<Map>()
        .map((part) => part['text']?.toString() ?? '')
        .where((text) => text.isNotEmpty)
        .join('\n');
  }

  String? _readErrorMessage(Object? data) {
    if (data is! Map) return null;
    final error = data['error'];
    if (error is! Map) return null;
    return error['message']?.toString();
  }

  void dispose() {
    _client.close();
  }
}

extension _TakeLast<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final list = toList(growable: false);
    if (list.length <= count) return list;
    return list.skip(list.length - count);
  }
}
