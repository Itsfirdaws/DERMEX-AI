import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

// Screens
import 'splash_screen.dart';
import 'profile.dart';
import 'settings_screen.dart';
import 'details_screen.dart';
import 'history_screen.dart';
import 'faq_screen.dart';
import 'admin/admindashboard_screen.dart';
import 'admin/add_users.dart';

// قائمة الكاميرات متاحة عالميًا
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp();

  // طلب صلاحية الكاميرا
  await Permission.camera.request();

  // الحصول على الكاميرات
  try {
    cameras = await availableCameras();
  } catch (e) {
    print("حدث خطأ أثناء تحميل الكاميرات: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
