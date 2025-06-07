import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 新增 Firebase Core
import 'firebase_options.dart'; // 新增 Firebase Options (稍後會由 FlutterFire CLI 產生)

Future<void> main() async {
  // 將 main 函數改為異步
  WidgetsFlutterBinding.ensureInitialized(); // 確保 Flutter 綁定已初始化
  await Firebase.initializeApp(
    // 初始化 Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
