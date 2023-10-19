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
  Future<dynamic> get(
      //? 를 붙여서 널일 수도 있다고 설정
      {required String collectionPath,
      required String? id,
      required String? filedName,
      required String? filedValue}) async {
    try {
      if (id == null && filedName == null) {
        return db.collection(collectionPath).get();
      } else if (id != null) {
        //고유 아이디로 찾아서 리턴
        return db.collection(collectionPath).doc(id).get();
      } else if (filedName != null) {
        return db
            .collection(collectionPath)
            .where(filedName, isEqualTo: filedValue)
            .get();
      }
    } catch (e) {
      return null;
    }
    return null;
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
