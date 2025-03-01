/*
 * @Author: yangrenshi yangrenshi@gmail.com
 * @Date: 2025-02-27 15:11:00
 * @LastEditors: yangrenshi yangrenshi@gmail.com
 * @LastEditTime: 2025-03-01 23:42:42
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

  Future<String> getAnswer(String question,
      {List<Map<String, dynamic>>? files}) async {
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

      await for (final data in stream) {
        // 将字节数据解码为字符串
        final decodedData = utf8.decode(data);

        // 移除 JSON 数据前的额外字符并分割数据流
        List<String> jsonData = decodedData.split('data: ');

        // 移除空字符串
        jsonData = jsonData.where((element) => element.isNotEmpty).toList();

        // 遍历每个数据块
        for (var element in jsonData) {
          // 判断是否结束
          if (element.trim() == '[DONE]') {
            return buffer.toString();
          }

          try {
            // 解析 JSON 数据
            final json = jsonDecode(element);

            // 获取当前阶段的对话结果
            if (json['event'] == 'message') {
              final String answer = json['answer'] ?? '';
              if (answer.isNotEmpty) {
                // 将新内容添加到缓冲区
                buffer.write(answer);
              }
            }
          } catch (e) {
            // 如果JSON解析失败，直接添加原始数据到缓冲区
            if (element.isNotEmpty) {
              buffer.write(element);
            }
          }
        }
      }

      // 如果没有收到[DONE]标记但流结束，返回累积的内容
      return buffer.toString();
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
