import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/addMap.dart';
import 'package:web/dashboard.dart';
import 'login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web/MyStatefulWidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb)
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: "AIzaSyAe9jaAIGhaP2gl-qjxezdSqUh51d3z7-E",
      appId: "1:3404171949:web:8847a21a342bf49d31d424",
      messagingSenderId: "3404171949",
      projectId: "dollani-app",
    ));
  //
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("ar", "AE"), // OR Locale('ar', 'AE') OR Other RTL locales
      ],
      locale: Locale("ar", "AE"),
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}
