import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import '../../../app/core/constants/env.dart';
import '../../../app/di/service_locator.dart';

class OpenAiService implements AiService {
  final http.Client _client;

  OpenAiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Stream<String> sendMessageStream({
    required String systemPrompt,
    required String userMessage,
  }) async* {
    print("systemPrompt: $systemPrompt");
    print("userMessage: $userMessage");
    final uri = Uri.parse("${Env.openAiBaseUrl}/chat/completions");

    final request = http.Request("POST", uri);
    request.headers.addAll({
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Env.openAiApiKey}",
    });

    request.body = jsonEncode({
      "model": Env.openAiModel,
      "stream": true,
      "messages": [
        {
          "role": "system",
          "content": systemPrompt,
        },
        {
          "role": "user",
          "content": userMessage,
        }
      ]
    });

    try {
      final response = await _client.send(request);

      // Stream chunk by chunk
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        if (chunk.trim().isEmpty) continue;

        final lines = chunk.split("\n");

        for (final line in lines) {
          if (!line.startsWith("data:")) continue;

          if (line.contains("[DONE]")) break;

          final jsonStr = line.replaceFirst("data: ", "").trim();

          if (jsonStr.isEmpty) continue;

          try {
            final data = jsonDecode(jsonStr);

            final delta = data?["choices"]?[0]?["delta"]?["content"];

            if (delta is String) {
              yield delta;
            }
          } catch (_) {
            // ignore malformed chunks
          }
        }
      }
    } catch (e) {
      yield "\n${"ai_stream_error".tr(args: ["$e"])}";
    }
  }

  /// Eğer ileride normal (non-streaming) mesaj göndermek istersek diye kalsın.
  @override
  Future<String> sendMessage(String message,
      {Map<String, dynamic>? context}) async {
    final uri = Uri.parse("${Env.openAiBaseUrl}/chat/completions");

    try {
      final response = await _client.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Env.openAiApiKey}"
        },
        body: jsonEncode({
          "model": Env.openAiModel,
          "messages": [
            {
              "role": "system",
              'content': 'You are Ares AI, a helpful and context-aware assistant.'
            },
            {"role": "user", "content": message}
          ]
        }),
      );

      print(message);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);

        final choices = json["choices"];
        if (choices == null || choices.isEmpty) {
          return "ai_no_choices".tr();
        }

        final content = choices[0]["message"]["content"];
        if (content is String && content.isNotEmpty) {
          return content;
        }

        return "ai_empty_response".tr();
      }

      return "ai_request_failed"
          .tr(args: ["${response.statusCode}"]);
    } catch (e) {
      return "ai_error_occurred".tr(args: ["$e"]);
    }
  }
}
