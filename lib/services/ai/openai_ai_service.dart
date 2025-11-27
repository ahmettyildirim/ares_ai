import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import '../../app/core/constants/env.dart';
import '../../app/di/service_locator.dart';

class OpenAiService implements AiService {
  final http.Client _client;

  OpenAiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<String> sendMessage(String message,
      {Map<String, dynamic>? context}) async {
    final uri = Uri.parse('${Env.openAiBaseUrl}/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Env.openAiApiKey}',
    };

    final body = {
      'model': Env.openAiModel,
      'messages': [
        {
          'role': 'system',
          'content': 'You are Ares AI, a helpful and context-aware assistant.'
        },
        {
          'role': 'user',
          'content': message,
        },
      ],
      'temperature': 0.7,
      'max_tokens': 512,
    };

    try {
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        final choices = data['choices'] as List?;
        if (choices == null || choices.isEmpty) {
          return "ai_no_choices".tr();
        }

        final content = choices.first['message']?['content'];
        if (content is String && content.isNotEmpty) {
          return content;
        }

        return "ai_empty_response".tr();
      } else {
        return "ai_request_failed".tr(args: ["${response.statusCode}"]);
      }
    } catch (e) {
      return "ai_error_occurred".tr(args: ["$e"]);
    }
  }

  @override
  Stream<String> sendMessageStream(String message,
      {Map<String, dynamic>? context}) async* {
    final uri = Uri.parse('${Env.openAiBaseUrl}/chat/completions');

    final request = http.Request("POST", uri);
    request.headers.addAll({
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Env.openAiApiKey}",
    });

    request.body = jsonEncode({
      "model": Env.openAiModel,
      "stream": true,
      "messages": [
        {"role": "user", "content": message}
      ]
    });

    final response = await _client.send(request);

    // Chunk reading
    await for (var chunk in response.stream.transform(utf8.decoder)) {
      if (chunk.trim().isEmpty) continue;

      final lines = chunk.split("\n");
      for (var line in lines) {
        if (!line.startsWith("data:")) continue;
        if (line.contains("[DONE]")) break;

        final jsonStr = line.replaceFirst("data: ", "");
        final data = jsonDecode(jsonStr);

        final delta = data?["choices"]?[0]?["delta"]?["content"];
        if (delta is String) {
          yield delta;
        }
      }
    }
  }
}
