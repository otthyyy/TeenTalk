import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/functions_service.dart';
import '../core/firebase_bootstrap.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final FunctionsService _functionsService = FunctionsService();
  
  final List<String> _logs = [];
  bool _isRunning = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 20) {
        _logs.removeAt(0);
      }
    });
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    try {
      _addLog('Starting Firebase tests...');

      // Test Auth
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.user != null) {
        _addLog('✓ Auth: User is authenticated (${authService.user!.uid})');
      } else {
        _addLog('✗ Auth: No authenticated user');
      }

      // Test Firestore
      try {
        await _firestoreService.setDocument('test', 'test-doc', {
          'timestamp': DateTime.now().toIso8601String(),
          'test': true,
        });
        _addLog('✓ Firestore: Document write successful');

        final doc = await _firestoreService.getDocument('test', 'test-doc');
        if (doc.exists) {
          _addLog('✓ Firestore: Document read successful');
        } else {
          _addLog('✗ Firestore: Document not found');
        }

        await _firestoreService.deleteDocument('test', 'test-doc');
        _addLog('✓ Firestore: Document delete successful');
      } catch (e) {
        _addLog('✗ Firestore: $e');
      }

      // Test Storage
      try {
        final testBytes = 'Test data for Firebase Storage'.codeUnits;
        final downloadUrl = await _storageService.uploadBytes(
          testBytes,
          'test/test-file.txt',
          contentType: 'text/plain',
        );
        _addLog('✓ Storage: File upload successful');

        final retrievedUrl = await _storageService.getDownloadUrl('test/test-file.txt');
        if (retrievedUrl == downloadUrl) {
          _addLog('✓ Storage: Download URL retrieval successful');
        } else {
          _addLog('✗ Storage: Download URL mismatch');
        }

        await _storageService.deleteFile('test/test-file.txt');
        _addLog('✓ Storage: File delete successful');
      } catch (e) {
        _addLog('✗ Storage: $e');
      }

      // Test Functions (this will fail if no functions are deployed, which is expected)
      try {
        await _functionsService.callFunction('testFunction');
        _addLog('✓ Functions: Test function call successful');
      } catch (e) {
        _addLog('⚠ Functions: Test function not deployed (expected in development)');
      }

      // Test FCM Token
      try {
        final fcmToken = await FirebaseBootstrap.getFCMToken();
        if (fcmToken != null) {
          _addLog('✓ FCM: Token retrieved successfully');
          _addLog('FCM Token: ${fcmToken.substring(0, 20)}...');
        } else {
          _addLog('⚠ FCM: No token available');
        }
      } catch (e) {
        _addLog('✗ FCM: $e');
      }

      _addLog('Firebase tests completed!');
    } catch (e) {
      _addLog('Test suite error: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Services Test',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will test all Firebase services to ensure they are properly configured and working.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _runTests,
                        child: _isRunning
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Running Tests...'),
                                ],
                              )
                            : const Text('Run Firebase Tests'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Test Logs',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _logs.clear();
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _logs.isEmpty
                            ? const Center(
                                child: Text(
                                  'No tests run yet. Click "Run Firebase Tests" to start.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  Color color = Colors.black;
                                  if (log.contains('✓')) {
                                    color = Colors.green;
                                  } else if (log.contains('✗')) {
                                    color = Colors.red;
                                  } else if (log.contains('⚠')) {
                                    color = Colors.orange;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        color: color,
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}