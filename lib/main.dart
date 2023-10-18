import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_cafe_admin/cafe_item.dart';
import 'package:flutter_cafe_admin/cafe_order.dart';
import 'package:flutter_cafe_admin/cafe_result.dart';
import 'firebase_options.dart';

void main() async {
  //싱글톤 - 한번 선언하면 메모리에 남아서 어디에서든지 사용가능
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Navi());
}

class Navi extends StatefulWidget {
  const Navi({super.key});

  @override
  State<Navi> createState() => _NaviState();
}

class _NaviState extends State<Navi> {
  int _index = 1;
  List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.shopping_basket_outlined),
      label: 'order',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.addchart_sharp),
      label: 'items',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.show_chart),
      label: 'result',
    ),
  ];

  var pages = [const CafeOrder(), const CafeItem(), const CafeResult()];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: pages[_index],
          bottomNavigationBar: BottomNavigationBar(
              items: items,
              currentIndex: _index,
              onTap: (value) {
                setState(() {
                  _index = value;
                });
              }),
        ));
  }
}
