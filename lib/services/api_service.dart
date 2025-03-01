/*
 * @Author: yangrenshi yangrenshi@gmail.com
 * @Date: 2025-02-27 15:11:00
 * @LastEditors: yangrenshi yangrenshi@gmail.com
 * @LastEditTime: 2025-03-01 20:36:16
 * @FilePath: \bs\lib\services\api_service.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://api.dify.ai/v1';
  static const String apiKey = 'app-N0jm0M8x5i7vqAFPRu3XnPgx';
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

  Stream<String> getAnswer(String question,
      {List<Map<String, dynamic>>? files}) async* {
    try {
      final response = await _dio.post(
        '/chat-messages',
        data: {
          'inputs': {},
          'query': question,
          'response_mode': 'streaming',
          'conversation_id': '',
          'user': 'user',
          'files': files ?? []
        },
        options: Options(responseType: ResponseType.stream),
      );

      final Stream<List<int>> stream = response.data.stream;
      final StringBuffer buffer = StringBuffer();
      String previousText = '';

      await for (final data in stream) {
        buffer.write(utf8.decode(data));
        final String text = buffer.toString();
        final lines = text.split('\n');

        for (var i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.startsWith('data:')) {
            final jsonStr = line.substring(5).trim();
            if (jsonStr.isNotEmpty) {
              try {
                final Map<String, dynamic> eventData = json.decode(jsonStr);
                if (eventData['event'] == 'message') {
                  final String answer = eventData['answer'] ?? '';
                  if (answer.length > previousText.length) {
                    yield answer.substring(previousText.length);
                    previousText = answer;
                  }
                }
              } catch (e) {
                yield jsonStr;
              }
            }
          }
        }

        if (lines.length > 1) {
          buffer.clear();
          buffer.write(lines.last);
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
