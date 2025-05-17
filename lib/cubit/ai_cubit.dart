import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:replay_bloc/replay_bloc.dart';

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAiContent {
  final String type;
  final String text;
  final List annotations;

  OpenAiContent({
    required this.type,
    required this.text,
    required this.annotations,
  });

  factory OpenAiContent.fromJson(Map<String, dynamic> json) {
    return OpenAiContent(
      type: json['type'] as String,
      text: json['text'] as String,
      annotations: json['annotations'] as List,
    );
  }
}

class OpenAiOutput {
  final String id;
  final String role;
  final String status;
  final String type;
  final List<OpenAiContent> content;

  OpenAiOutput({
    required this.id,
    required this.role,
    required this.status,
    required this.type,
    required this.content,
  });

  factory OpenAiOutput.fromJson(Map<String, dynamic> json) {
    return OpenAiOutput(
      id: json['id'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      content: parseOpenAiContentList(json['content']),
    );
  }
}

List<OpenAiOutput> parseOpenAiOutputList(List<dynamic> json) {
  final output = List<OpenAiOutput>.empty(growable: true);

  for (final unparsedOutput in json) {
    output.add(OpenAiOutput.fromJson(unparsedOutput as Map<String, dynamic>));
  }

  return output;
}

List<OpenAiContent> parseOpenAiContentList(List<dynamic> json) {
  final output = List<OpenAiContent>.empty(growable: true);

  for (final unparsedOutput in json) {
    output.add(OpenAiContent.fromJson(unparsedOutput as Map<String, dynamic>));
  }

  return output;
}

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
  final List<OpenAiOutput> output;
  final bool parallelToolCalls;
  final String? previousResponseId;
  final Object? reasoning;
  final String status;
  final double? temperature;
  final Object? text;
  final double? topP;
  final String? truncation;
  final Object usage;
  final String? user;

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
      output: parseOpenAiOutputList(json['output']),
      parallelToolCalls: json['parallel_tool_calls'] as bool,
      previousResponseId: json['previous_response_id'] as String?,
      reasoning: json['reasoning'] as Object?,
      status: json['status'] as String,
      temperature: json['temperature'] as double?,
      text: json['text'] as Object?,
      topP: json['top_p'] as double?,
      truncation: json['truncation'] as String?,
      usage: json['usage'] as Object,
      user: json['user'] as String?,
    );
  }
}

enum ContextSource { message, ai, page }

class AiChatModel {
  String text;
  ContextSource source;
  DateTime created;

  AiChatModel({
    required this.text,
    required this.source,
    required this.created,
  });
}

var testmodel = [AiChatModel(created: DateTime.now(), source: ContextSource.message, text: 'test')];

class AiServiceState {
  final String apiToken;
  final String model;
  final List<String> availableModels;
  final List<AiChatModel> chatHistory;

  AiServiceState(
    this.apiToken, {
    this.model = "gpt-4.1-nano",
    this.availableModels = const [],
    this.chatHistory = const [],
  });

  AiServiceState copyWith({String? newApiToken, String? newModel, List<String>? newAvailableModels, List<AiChatModel>? newChatHistory}) {
    return AiServiceState(newApiToken ?? apiToken,
        model: newModel ?? model, availableModels: newAvailableModels ?? availableModels, chatHistory: newChatHistory ?? chatHistory);
  }
}

class AiServiceCubit extends Cubit<AiServiceState> {
  static const storage = FlutterSecureStorage();

  AiServiceCubit({
    required String apiToken,
    String? model,
  }) : super(AiServiceState(apiToken, model: model ?? "gpt-4.1-nano", chatHistory: testmodel)) {
    init();
  }

  Future<void> init() async {
    final storedModel = await storage.read(key: 'model');
    final storedApiToken = await storage.read(key: 'apiToken');

    if (storedModel != null) {
      model = storedModel;
    }
    if (storedApiToken != null) {
      apiToken = storedApiToken;
    }
  }

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

  List<AiChatModel> get chatHistory {
    return state.chatHistory;
  }

  void resetHistory() {
    emit(state.copyWith(newChatHistory: []));
  }

  Future<void> sendMessage(String message) async {
    _addToChatHistory(message, ContextSource.message);

    final response = await request(message);

    if (response != null && response.output.isNotEmpty && response.output[0].content.isNotEmpty) {
      _addToChatHistory(response.output[0].content[0].text, ContextSource.ai);
    } else {
      _addToChatHistory('error', ContextSource.ai);
    }
  }

  Future<OpenAiResponse?> request(String input) async {
    final url = Uri.https('api.openai.com', '/v1/responses');

    final Map<String, String> headers = <String, String>{};
    headers["Content-Type"] = "application/json";
    headers["Authorization"] = "Bearer $apiToken";

    try {
      final response = await http.post(url, headers: headers, body: jsonEncode({'model': model, 'input': input}));

      return OpenAiResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      // todo better logging
      return null;
    }
  }

  void _addToChatHistory(String text, ContextSource source) {
    final chatHistory = List.of(state.chatHistory, growable: true);
    final model = AiChatModel(text: text, source: source, created: DateTime.now());
    chatHistory.add(model);
    emit(state.copyWith(newChatHistory: chatHistory));
  }
}
