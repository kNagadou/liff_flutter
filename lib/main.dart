import 'package:flutter/material.dart';
import 'liff_service.dart';
import 'liff_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIFF Flutter Sample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B900)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'LIFF Flutter Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _initializeLiff();
  }

  Future<void> _initializeLiff() async {
    try {
      final success = await LiffService.init();
      setState(() {
        _isInitialized = success;
        _isLoggedIn = LiffService.isLoggedIn();
        _profile = LiffService.getProfile();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('初期化エラー: $e')));
      }
    }
  }

  void _openLiffApp() {
    final liffId = LiffService.getLiffId();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LiffPage(liffId: liffId)),
    ).then((_) {
      // LIFF画面から戻ってきた時にステータスを更新
      _refreshStatus();
    });
  }

  void _refreshStatus() {
    setState(() {
      _isLoggedIn = LiffService.isLoggedIn();
      _profile = LiffService.getProfile();
    });
  }

  Future<void> _logout() async {
    await LiffService.logout();
    _refreshStatus();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ログアウトしました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LIFF設定',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIFF ID',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              LiffService.getLiffId(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Text(
                              '固定設定',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openLiffApp,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('LIFFアプリを開く'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B900),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ステータス',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildStatusItem(
                        'LIFF初期化',
                        _isInitialized ? '完了' : '未完了',
                        _isInitialized ? Colors.green : Colors.orange,
                      ),
                      _buildStatusItem(
                        'ログイン状態',
                        _isLoggedIn ? 'ログイン済み' : '未ログイン',
                        _isLoggedIn ? Colors.green : Colors.grey,
                      ),
                      if (_isLoggedIn && _profile != null) ...[
                        const Divider(),
                        Text(
                          'ユーザー情報',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前', _profile!['displayName']),
                        _buildProfileItem('ユーザーID', _profile!['userId']),
                        if (_profile!['statusMessage'] != null)
                          _buildProfileItem(
                            'ステータス',
                            _profile!['statusMessage'],
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('ログアウト'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '使用方法',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. LINE Developers コンソールでLIFFアプリを作成\n'
                        '2. 取得したLIFF IDを上記に入力\n'
                        '3. "LIFFアプリを開く"ボタンをタップ\n'
                        '4. LINEでログインしてアプリを使用',
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshStatus,
        tooltip: 'ステータス更新',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? '未設定')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
