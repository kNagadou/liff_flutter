import 'package:flutter/material.dart';
import 'dart:developer';
import 'liff_service.dart';

class LiffPage extends StatefulWidget {
  final String liffId;

  const LiffPage({super.key, required this.liffId});

  @override
  State<LiffPage> createState() => _LiffPageState();
}

class _LiffPageState extends State<LiffPage> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _profile;
  String? _errorMessage;
  String _environment = 'Unknown';
  final TextEditingController _messageController = TextEditingController();
  Map<String, dynamic>? _locationData;

  @override
  void initState() {
    super.initState();
    _initializeLiff();
  }

  Future<void> _initializeLiff() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // LIFF初期化
      final success = await LiffService.init();
      if (!success) {
        throw Exception('LIFF初期化に失敗しました');
      }

      // 状態を更新
      await _updateStatus();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus() async {
    try {
      final isLoggedIn = LiffService.isLoggedIn();
      final profile = LiffService.getProfile();
      final environment = await LiffService.getLiffEnvironment();

      setState(() {
        _isLoggedIn = isLoggedIn;
        _profile = profile;
        _environment = environment;
      });
    } catch (e) {
      log('ステータス更新エラー: $e');
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await LiffService.login();
      if (success) {
        await _updateStatus();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ログインしました')));
        }
      } else {
        throw Exception('ログインに失敗しました');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ログインエラー: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await LiffService.logout();
      await _updateStatus();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ログアウトしました')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ログアウトエラー: $e')));
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('メッセージを入力してください')));
      return;
    }

    try {
      final success = await LiffService.sendMessage(message);
      if (success) {
        _messageController.clear();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('メッセージを送信しました')));
        }
      } else {
        throw Exception('メッセージ送信に失敗しました');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('送信エラー: $e')));
      }
    }
  }

  Future<void> _scanQrCode() async {
    try {
      final result = await LiffService.scanQrCode();
      if (result != null && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('QRコード結果'),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('QRスキャンエラー: $e')));
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationData = await LiffService.getCurrentLocation();
      setState(() {
        _locationData = locationData;
      });

      if (locationData != null && locationData.containsKey('error')) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(locationData['error'])));
        }
      } else if (locationData != null && mounted) {
        final latitude = locationData['latitude'];
        final longitude = locationData['longitude'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('位置情報を取得しました\n緯度: $latitude\n経度: $longitude'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('位置情報取得エラー: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _closeWindow() async {
    try {
      await LiffService.closeWindow();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIFF App'),
        backgroundColor: const Color(0xFF00B900),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: _closeWindow),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildMainView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeLiff,
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ステータスカード
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
                  _buildStatusItem('LIFF ID', widget.liffId),
                  _buildStatusItem('環境', _environment),
                  _buildStatusItem('ログイン状態', _isLoggedIn ? 'ログイン済み' : '未ログイン'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ログイン/ログアウトボタン
          if (!_isLoggedIn)
            ElevatedButton.icon(
              onPressed: _login,
              icon: const Icon(Icons.login),
              label: const Text('LINEでログイン'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B900),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

          // ユーザー情報とアクション
          if (_isLoggedIn && _profile != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ユーザー情報',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildProfileItem('名前', _profile!['displayName']),
                    _buildProfileItem('ユーザーID', _profile!['userId']),
                    if (_profile!['statusMessage'] != null)
                      _buildProfileItem('ステータス', _profile!['statusMessage']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // メッセージ送信カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'メッセージ送信',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'メッセージ',
                        hintText: '送信するメッセージを入力',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send),
                        label: const Text('送信'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 位置情報カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '位置情報',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (_locationData != null &&
                        !_locationData!.containsKey('error')) ...[
                      _buildLocationItem(
                        '緯度',
                        _locationData!['latitude']?.toString(),
                      ),
                      _buildLocationItem(
                        '経度',
                        _locationData!['longitude']?.toString(),
                      ),
                      _buildLocationItem(
                        '精度',
                        '${_locationData!['accuracy']?.toStringAsFixed(1)}m',
                      ),
                      _buildLocationItem(
                        '高度',
                        '${_locationData!['altitude']?.toStringAsFixed(1)}m',
                      ),
                      if (_locationData!['speed'] != null &&
                          _locationData!['speed'] > 0)
                        _buildLocationItem(
                          '速度',
                          '${(_locationData!['speed'] * 3.6).toStringAsFixed(1)}km/h',
                        ),
                      if (_locationData!['timestamp'] != null)
                        _buildLocationItem(
                          '取得時刻',
                          DateTime.parse(
                            _locationData!['timestamp'],
                          ).toLocal().toString().split('.')[0],
                        ),
                    ] else ...[
                      const Text('位置情報が取得されていません'),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.location_on),
                        label: const Text('現在地を取得'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // アクションボタン
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'アクション',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _scanQrCode,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('QRコードスキャン'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('ログアウト'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildLocationItem(String label, String? value) {
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
          Expanded(child: Text(value ?? '未取得')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
