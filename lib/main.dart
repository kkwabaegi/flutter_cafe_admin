import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  //싱글톤 - 한번 선언하면 메모리에 남아서 어디에서든지 사용가능
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var db = FirebaseFirestore.instance;
            var data = {'categoryName': '커피', 'isUsed': true};
            await db.collection('cafe-category').add(data);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
