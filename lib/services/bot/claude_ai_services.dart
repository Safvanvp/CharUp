import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ClaudeAiServices {
  //api constants
  final String _baseUrl = 'https://api.anthropic.com/v1/messages';
  final String _apiKeys = 'my api key';
  final String _apiVersion = '2023-06-01';
  final String _model = 'claude-3-opus-20240229';
  // static const int _maxTokens = 1024;

  Future<String> analyzeImage(File image) async {
    //prepare image for claude
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    //send requast to claude
    final response = await http.post(Uri.parse(_baseUrl),
        headers: {
          'contant-type': 'application/json',
          'x-api-key': _apiKeys,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens_to_sample': 50,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'typr': 'base64',
                    'media_type': 'image/jpeg',
                    'data': base64Image
                  }
                },
                {
                  'type': 'text',
                  'text': 'Plese describe what you see in the image'
                }
              ],
            }
          ]
        }));
    //seccessfull response from claude

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'];
    }

    //error...
    throw Exception('Failed to analyze image: ${response.statusCode}');
  }
}
