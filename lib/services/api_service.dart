import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1/v1';
  static const String apiKey = 'app-mEztySL014WbjqE6547Wmt0b';
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $apiKey';
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
    ));
  }

  Stream<Map<String, dynamic>> getAnswer(String question) async* {
    try {
      final response = await _dio.post(
        '/chat-messages',
        data: {
          'inputs': {},
          'query': question,
          'response_mode': 'streaming',
          'conversation_id': '',
          'user': 'user',
          'files': []
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      await for (final chunk
          in stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.startsWith('data:')) {
          try {
            final jsonStr = chunk.substring(5).trim();
            if (jsonStr.isEmpty) continue;

            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            final event = data['event'] as String?;
            if (event == null) continue;

            switch (event) {
              case 'agent_thought':
                yield {
                  'type': 'thought',
                  'content': data['content'] ?? '',
                };
                break;

              case 'agent_message':
                yield {
                  'type': 'message',
                  'content': data['content'] ?? '',
                  'role': 'assistant',
                };
                break;

              case 'message_file':
                if (data['content'] != null) {
                  yield {
                    'type': 'file',
                    'content': data['content'],
                    'file_name': data['file_name'] ?? '未命名文件',
                  };
                }
                break;

              case 'message_end':
                yield {
                  'type': 'end',
                  'content': data['content'] ?? '',
                };
                break;
            }
          } catch (e) {
            print('数据解析错误: $chunk');
            continue;
          }
        }
      }
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getKnowledgePoint(String topic) async {
    try {
      final response = await _dio.post(
        '/messages',
        data: {
          'inputs': {'topic': topic},
          'query': '请详细讲解液压相关的知识点：$topic',
          'response_mode': 'blocking',
          'user': 'user',
          'files': []
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
