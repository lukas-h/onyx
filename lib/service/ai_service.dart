import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAiResponse {
  final int createdAt;
  final Object? error;
  final String id;
  final Object? incompleteDetails;
  final String? instructions;
  final int? maxOutputTokens;
  final Object metadata;
  final String model;
  final String object;
  final List output;
  final bool parallelToolCalls;
  final String? previousResponseId;
  final Object? reasoning;
  final String status;
  final int? temperature;
  final Object? text;
  final int? topP;
  final String? truncation;
  final Object usage;
  final String user;

  OpenAiResponse({
    required this.createdAt,
    this.error,
    required this.id,
    this.incompleteDetails,
    this.instructions,
    this.maxOutputTokens,
    required this.metadata,
    required this.model,
    required this.object,
    required this.output,
    required this.parallelToolCalls,
    this.previousResponseId,
    this.reasoning,
    required this.status,
    this.temperature,
    this.text,
    this.topP,
    this.truncation,
    required this.usage,
    required this.user,
  });

  factory OpenAiResponse.fromJson(Map<String, dynamic> json) {
    return OpenAiResponse(
      createdAt: json['created_at'] as int,
      error: json['error'] as Object?,
      id: json['id'] as String,
      incompleteDetails: json['incomplete_details'] as Object?,
      instructions: json['instructions'] as String?,
      maxOutputTokens: json['max_output_tokens'] as int?,
      metadata: json['metadata'] as Object,
      model: json['model'] as String,
      object: json['object'] as String,
      output: json['output'] as List,
      parallelToolCalls: json['parallel_tool_calls'] as bool,
      previousResponseId: json['previous_response_id'] as String?,
      reasoning: json['reasoning'] as Object?,
      status: json['status'] as String,
      temperature: json['temperature'] as int?,
      text: json['text'] as Object?,
      topP: json['top_p'] as int?,
      truncation: json['truncation'] as String?,
      usage: json['usage'] as Object,
      user: json['user'] as String,
    );
  }
}

class AiService {
  String _apiToken;
  String _model = 'gpt-4.1-nano';

  List<String> _availableModels = ['gpt-4.1-nano'];

  AiService(this._apiToken);

  set apiToken(String token) {
    _apiToken = token;
  }

  set model(String newModel) {
    if (_availableModels.contains(newModel)) {
      _model = newModel;
    }
  }

  String get model {
    return _model;
  }

  Future<bool> updateModels() async {
    // todo get models
    _availableModels = ['gpt-4.1-nano'];
    return false;
  }

  Future<OpenAiResponse?> request(String input) async {
    final url = Uri.https('api.openai.com', '/v1/responses');

    final Map<String, String> headers = <String, String>{};
    headers["Content-Type"] = "application/json";
    headers["Authorization"] = "Barer $_apiToken";

    try {
      final response = await http.post(url, headers: headers, body: {'model': _model, 'input': input});

      return OpenAiResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      // todo better logging
      print(e);
      return null;
    }
  }
}
