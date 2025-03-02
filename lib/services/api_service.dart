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

/// API配置常量
class ApiConstants {
  static const String baseUrl = 'https://api.dify.ai/v1';
}

/// 智能体配置类
class AgentConfig {
  final String name;
  final String baseUrl;
  final String apiKey;
  final String description;

  const AgentConfig({
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.description,
  });
}

/// 智能体配置管理
class AgentConfigs {
  static const teachingAssistant = AgentConfig(
    name: '液压教学智能助手',
    baseUrl: ApiConstants.baseUrl,
    apiKey: 'app-N0jm0M8x5i7vqAFPRu3XnPgx',
    description: '专业的液压知识问答系统，为您解答液压相关问题',
  );

  static const principleTeacher = AgentConfig(
    name: '液压原理讲解',
    baseUrl: ApiConstants.baseUrl,
    apiKey: 'app-N0jm0M8x5i7vqAFPRu3XnPgx',
    description: '深入浅出地讲解液压系统的基本原理和工作机制',
  );

  static const componentIdentifier = AgentConfig(
    name: '液压元件识别',
    baseUrl: ApiConstants.baseUrl,
    apiKey: 'app-N0jm0M8x5i7vqAFPRu3XnPgx',
    description: '帮助您快速识别和了解各种液压元件的功能与特点',
  );

  static const troubleshooter = AgentConfig(
    name: '液压故障诊断',
    baseUrl: ApiConstants.baseUrl,
    apiKey: 'app-N0jm0M8x5i7vqAFPRu3XnPgx',
    description: '智能分析液压系统故障，提供解决方案',
  );

  static const systemDesigner = AgentConfig(
    name: '液压系统设计',
    baseUrl: ApiConstants.baseUrl,
    apiKey: 'app-N0jm0M8x5i7vqAFPRu3XnPgx',
    description: '辅助设计液压系统，提供专业建议和优化方案',
  );

  static AgentConfig getConfigByName(String name) {
    switch (name) {
      case '液压教学智能助手':
        return teachingAssistant;
      case '液压原理讲解':
        return principleTeacher;
      case '液压元件识别':
        return componentIdentifier;
      case '液压故障诊断':
        return troubleshooter;
      case '液压系统设计':
        return systemDesigner;
      default:
        throw Exception('未找到对应的智能体配置：$name');
    }
  }
}

class ApiService {
  late final Dio _dio;
  late final AgentConfig _currentConfig;

  ApiService({String? agentName}) {
    _currentConfig = agentName != null
        ? AgentConfigs.getConfigByName(agentName)
        : AgentConfigs.teachingAssistant;

    _dio = Dio();
    _dio.options.baseUrl = _currentConfig.baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer ${_currentConfig.apiKey}';
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


  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
