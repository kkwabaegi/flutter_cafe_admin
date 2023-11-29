//cafe_incomplete.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var firestore = FirebaseFirestore.instance;
var orderCollectionName = 'cafe-order';

class CafeInComplete extends StatefulWidget {
  const CafeInComplete({super.key});

  @override
  State<CafeInComplete> createState() => _CafeIncompleteState();
}

class _CafeIncompleteState extends State<CafeInComplete> {
  bool init = true;
  List<dynamic> orderDataList = [];
  dynamic body = const Text('로딩중...');

  Future<void> getOrders() async {
    //스트림 형태로 데이터 베이스가 바뀔 때마다 업데이트 된다.
    firestore
        .collection(orderCollectionName)
        .orderBy('orderNumber', descending: true)
        .snapshots()
        .listen((event) {
      //docChanges = 새로 생긴 데이터만
      //docs = 전체
      setState(() {
        if (init) {
          //처음 데이터 = 전체 불러오기
          orderDataList = event.docs;
          init = false; //다음부터는 새로운 것만
        } else {
          //새로운 데이터만
          List<dynamic> newData =
              event.docChanges.map((change) => change.doc).toList();
          orderDataList.insertAll(0, newData + event.docs);
        }
      });
      showOrderList();
    });
  }

  void showOrderList() {
    setState(() {
      body = ListView.separated(
          itemBuilder: (context, index) {
            var order = orderDataList[index];
            return ListTile(
              leading: Text('${order['orderNumber']}'),
              title: Text('${order['orderName']}'),
            );
          },
          separatorBuilder: (c, i) => const Divider(),
          itemCount: orderDataList.length);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orderDataList.isEmpty ? const Text('없음') : body,
    );
  }
}


//남은 과제는 프론트 꾸미고 +push기능(알림)