import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'my_cafe.dart';

var myCafe = MyCafe();
String categoryCollectionName = 'cafe-category';
String itemCollectionName = 'cafe-item';

class CafeItem extends StatefulWidget {
  const CafeItem({super.key});

  @override
  State<CafeItem> createState() => _CafeItemState();
}

class _CafeItemState extends State<CafeItem> {
  dynamic body =
      const Text('Loading...'); //로딩 - 즉 로드는 하드디스크의 정보를 메모리(렘)에 올리는 시간

  //동기, 비동기 - 동기는 싱크로 / 비동기는 따로따로
  Future<void> getCategory() async {
    //비동기로 받아오기
    var datas = myCafe.get(
        collectionPath: categoryCollectionName,
        id: null,
        filedName: null,
        filedValue: null);
    //Listview Builder 등을 이용해서 뿌려주기
    setState(() {
      body = FutureBuilder(
        future: datas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var datas = snapshot.data!.docs; //혹시 나 무조건 있다니까!
            if (datas.isEmpty) {
              return const Center(child: Text('empty'));
            } else {
              //진짜 데이터가 있을 때
              //데이터가 리스트 형태이기 때문에 리스트뷰를 이용해서 하나씩 뿌려줌
              return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = datas[index];
                    return ListTile(
                      title: Text(data['categoryName']),
                      trailing: PopupMenuButton(
                        onSelected: (value) async {
                          switch (value) {
                            case 'modify':
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CafeCategoryAddForm(id: data.id),
                                  ));
                              if (result) {
                                getCategory();
                              }
                              break;
                            case 'delete':
                              var result = await myCafe.delete(
                                  collectionPath: categoryCollectionName,
                                  id: data.id);
                              if (result) {
                                getCategory();
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'modify',
                            child: Text('수정'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제'),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: datas.length);
            }
          } else {
            //아직 기다리는중
            return const Center(child: Text('로딩중'));
          }
        },
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //result에 true가 보관(저장완료)
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CafeCategoryAddForm(),
              ));

          //카테고리 목록을 출력
          if (result == true) {
            getCategory();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CafeCategoryAddForm extends StatefulWidget {
  String? id;
  CafeCategoryAddForm({super.key, this.id});

  @override
  State<CafeCategoryAddForm> createState() => _CafeCategoryAddFormState();
}

class _CafeCategoryAddFormState extends State<CafeCategoryAddForm> {
  TextEditingController controller = TextEditingController();
  var isUsed = true;
  String? id;

  Future<dynamic> getData({required String id}) async {
    var data = await myCafe.get(collectionPath: categoryCollectionName, id: id);
    setState(() {
      controller.text = data['categoryName'];
      isUsed = data['isUsed'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    if (id != null) {
      getData(id: id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Add Form'),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () async {
                var data = {'categoryName': controller.text, 'isUsed': isUsed};
                if (id != null) {
                  if (controller.text.isNotEmpty) {
                    if (await myCafe.update(
                        collectionPath: categoryCollectionName,
                        data: data,
                        id: id!)) {
                      print('asdwd');
                      Navigator.pop(context, true);
                    }
                  }
                } else {
                  if (controller.text.isNotEmpty) {
                    if (await myCafe.insert(
                        collectionPath: categoryCollectionName, data: data)) {
                      Navigator.pop(context, true);
                    }
                  }
                }
              },
              child: const Text('Save',
                  style: TextStyle(
                    color: Colors.white,
                  )))
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Text('Category Name'),
              border: OutlineInputBorder(),
            ),
            controller: controller,
          ),
          SwitchListTile(
            title: const Text('used?'),
            value: isUsed,
            onChanged: (value) {
              setState(() {
                isUsed = value;
              });
            },
          )
        ],
      ),
    );
  }
}
