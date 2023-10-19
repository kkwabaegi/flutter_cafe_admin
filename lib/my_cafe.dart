import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class MyCafe {
  var db = FirebaseFirestore.instance;

  Future<bool> insert(
      {required String collectionPath,
      required Map<String, dynamic> data}) async {
    try {
      var result = await db.collection(collectionPath).add(data);
      return true;
    } catch (e) {
      return false;
    }
  }

//JsonQuerySnapshot 형태는 json보다 더 많은 정보를 가지고 있는 형식이다
  Future<QuerySnapshot<Map<String, dynamic>>?> get(
      //? 를 붙여서 널일 수도 있다고 설정
      {required String collectionPath}) async {
    try {
      var result = db.collection(collectionPath).get();
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<bool> delete(
      {required String collectionPath, required String id}) async {
    try {
      var result = await db.collection(collectionPath).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
