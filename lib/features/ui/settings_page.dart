import 'package:flutter/material.dart';
import '../../app/router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // プロフィールへの導線
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.blue),
              title: const Text('プロフィール'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.pushNamed(context, AppRouter.profileView);
              },
            ),
          ),

          const SizedBox(height: 12),

          // 通知設定（既存）
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SwitchListTile(
              title: const Text('通知設定'),
              subtitle: const Text('天気や服装の更新を受け取る'),
              value: true, // TODO: Riverpod データに接続
              onChanged: (_) {},
              secondary: const Icon(Icons.notifications_none),
            ),
          ),

          const SizedBox(height: 12),

          // プライバシーポリシー
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('プライバシーポリシー'),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ),

          // 利用規約
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const ListTile(
              leading: Icon(Icons.description_outlined),
              title: Text('利用規約'),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ),

          const SizedBox(height: 40),

          Center(
            child: Text(
              'バージョン 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
