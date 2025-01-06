import 'package:flutter/material.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isDarkMode = false;

  // Hàm thay đổi chế độ sáng tối
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và chế độ sáng tối
            const Text(
              'Chế độ hiển thị',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Chế độ tối'),
              value: _isDarkMode,
              onChanged: _toggleTheme,
              secondary: const Icon(Icons.dark_mode),
            ),
            const Divider(),

            // Thông tin ứng dụng
            const SizedBox(height: 20),
            const Text(
              'Thông tin ứng dụng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('Music PM'),
              subtitle: const Text('Ứng dụng nghe nhạc thuộc nhóm PM'),
              onTap: () {
                _showAppInfoDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị thông tin chi tiết của ứng dụng
  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông tin ứng dụng'),
          content: const Text('Ứng dụng Music PM được phát triển bởi nhóm PM. Đây là ứng dụng giúp bạn nghe nhạc một cách dễ dàng và thuận tiện.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
