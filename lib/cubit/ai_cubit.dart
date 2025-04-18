import 'package:onyx/service/ai_service.dart';
import 'package:replay_bloc/replay_bloc.dart';

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

class AiServiceState {
  final String apiToken;
  final String model;
  final List<String> availableModels;

  AiServiceState(
    this.apiToken, {
    this.model = "gpt-4.1-nano",
    this.availableModels = const [],
  });

  AiServiceState copyWith({String? newApiToken, String? newModel, List<String>? newAvailableModels}) {
    return AiServiceState(newApiToken ?? apiToken, model: newModel ?? model, availableModels: newAvailableModels ?? availableModels);
  }
}

class AiServiceCubit extends Cubit<AiServiceState> {
  AiServiceCubit({
    required String apiToken,
    String? model,
  }) : super(AiServiceState(apiToken, model: model ?? "gpt-4.1-nano"));

  set model(String newModel) {
    if (state.availableModels.contains(newModel)) {
      emit(state.copyWith(newModel: newModel));
    }
  }

  String get model {
    return state.model;
  }

  set apiToken(String newApiToken) {
    emit(state.copyWith(newApiToken: newApiToken));
  }

  String get apiToken {
    return state.apiToken;
  }

  Future<void> updateModels() async {
    // todo get models
  }

  List<String> get availableModels {
    return state.availableModels;
  }

  Future<OpenAiResponse?> request(String input) async {
    final url = Uri.https('api.openai.com', '/v1/responses');

    final Map<String, String> headers = <String, String>{};
    headers["Content-Type"] = "application/json";
    headers["Authorization"] = "Barer $apiToken";

    try {
      final response = await http.post(url, headers: headers, body: {'model': model, 'input': input});

      return OpenAiResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      // todo better logging
      print(e);
      return null;
    }
  }
}
