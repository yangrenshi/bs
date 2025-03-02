import 'package:flutter/material.dart';
import '../pages/chat_page.dart';

class AIModelsPage extends StatefulWidget {
  const AIModelsPage({super.key});

  @override
  State<AIModelsPage> createState() => _AIModelsPageState();
}

class _AIModelsPageState extends State<AIModelsPage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '搜索模型',
              border: InputBorder.none,
              icon: Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('液压教学'),
                  selected: true,
                  onSelected: (bool selected) {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildModelCard(
                  '液压教学智能助手',
                  '专业的液压知识问答系统，为您解答液压相关问题',
                  'assets/images/deepseek.png',
                ),
                _buildModelCard(
                  '液压原理讲解',
                  '深入浅出地讲解液压系统的基本原理和工作机制',
                  'assets/images/hydraulic_principle.png',
                ),
                _buildModelCard(
                  '液压元件识别',
                  '帮助您快速识别和了解各种液压元件的功能与特点',
                  'assets/images/hydraulic_components.png',
                ),
                _buildModelCard(
                  '液压故障诊断',
                  '智能分析液压系统故障，提供解决方案',
                  'assets/images/hydraulic_diagnosis.png',
                ),
                _buildModelCard(
                  '液压系统设计',
                  '辅助设计液压系统，提供专业建议和优化方案',
                  'assets/images/hydraulic_design.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(String title, String description, String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.auto_awesome, size: 40);
          },
        ),
        title: Text(title),
        subtitle: Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(title: title),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}