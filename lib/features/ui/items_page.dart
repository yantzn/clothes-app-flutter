import 'package:flutter/material.dart';

// 楽天アフェリエイト機能は削除済み。プレースホルダー表示に切り替え。

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アイテム')),
      body: const Center(
        child: Text('現在、アイテム機能は未提供です。', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
