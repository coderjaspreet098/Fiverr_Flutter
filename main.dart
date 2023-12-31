import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_work/user_state.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBnxtsj7_WoiLmFQJfFSaoxhDG52bUs1hU",
        appId: "1:665739111875:android:abc7e18e5e0152caefe176",
        messagingSenderId: "665739111875",
        projectId: "flutterwork-d5305",
      storageBucket: "flutterwork-d5305.appspot.com"
    )
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:UserState(),
    );
  }
}

