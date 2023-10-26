import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'my_cafe.dart';

var myCafe = MyCafe();
String categoryCollectionName = 'cafe-category';
String itemCollectionName = 'cafe-item';

//카테고리 목록보기
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
    var datas = myCafe.get(collectionPath: categoryCollectionName);
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
                      onTap: () async {
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CafeItemList(id: data.id),
                            ));
                      },
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
                              if (result == true) {
                                getCategory();
                              }
                              break;
                            case 'delete':
                              var result = await myCafe.delete(
                                  collectionPath: categoryCollectionName,
                                  id: data.id);
                              if (result == true) {
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

//카테고리 추가-수정 폼
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
                if (controller.text.isNotEmpty) {
                  var data = {
                    'categoryName': controller.text,
                    'isUsed': isUsed
                  };
                  var result = (id != null)
                      ? await myCafe.update(
                          collectionPath: categoryCollectionName,
                          data: data,
                          id: id!)
                      : await myCafe.insert(
                          collectionPath: categoryCollectionName, data: data);
                  if (result) {
                    Navigator.pop(context, true);
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

//아이템 목록보기
class CafeItemList extends StatefulWidget {
  String id;
  CafeItemList({super.key, required this.id});

  @override
  State<CafeItemList> createState() => _CafeItemListState();
}

class _CafeItemListState extends State<CafeItemList> {
  late String id;
  dynamic dropdownMenu = const Text('Loading...');
  dynamic itemList = const Text('Loading...');

  Future<void> getCategory() async {
    var datas = myCafe.get(collectionPath: categoryCollectionName);
    List<DropdownMenuEntry> entries = [];
    setState(() {
      dropdownMenu = FutureBuilder(
        future: datas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var datas = snapshot.data.docs;
            for (var data in datas) {
              entries.add(DropdownMenuEntry(
                  value: data.id, label: data['categoryName']));
            }
            return DropdownMenu(
              dropdownMenuEntries: entries,
              initialSelection: id,
              onSelected: (value) {
                id = value;
                print('$value item list');
              },
            );
          } else {
            return const Text('Loading...');
          }
        },
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    getCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CafeItemAddForm(categoryid: id),
                    ));
              },
              child: const Text(
                '+item',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          dropdownMenu
        ],
      ),
    );
  }
}

//아이템 추가/수정 폼
//이름, 가격, 사진, 옵션, 매진여부, 제품설명
class CafeItemAddForm extends StatefulWidget {
  String categoryid;
  String? itemId;
  CafeItemAddForm({super.key, required this.categoryid, this.itemId});

  @override
  State<CafeItemAddForm> createState() => _CafeItemAddFormState();
}

class _CafeItemAddFormState extends State<CafeItemAddForm> {
  late String categoryid;
  String? itemId;
  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  TextEditingController controllerDesc = TextEditingController();
  TextEditingController controllerOptionName = TextEditingController();
  TextEditingController controllerOptionValue = TextEditingController();
  bool isSoldOut = false;
  dynamic option = const Text('옵션이없어용');
  var options = [];

  void showOptionList() {
    setState(() {
      option = ListView.separated(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(options[index]['optionName']),
            subtitle: Text(options[index]['optionValue']
                .toString()
                .replaceAll('\n', ' / ')),
            trailing: IconButton(
                onPressed: () {
                  options.removeAt(index);
                  showOptionList();
                  print(options);
                },
                icon: const Icon(Icons.close)),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: options.length,
      );
    });
    controllerOptionName.clear();
    controllerOptionValue.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryid = widget.categoryid;
    itemId = widget.itemId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('item add form'),
        actions: [
          TextButton(
              onPressed: () async {
                var data = {
                  'categoryId': categoryid,
                  'itemName': controllerTitle.text,
                  'itemPrice': int.parse(controllerPrice.text),
                  'itemDesc': controllerDesc.text,
                  'itemIsSoldOut': isSoldOut,
                  'options': options
                };
                var result = await myCafe.insert(
                    collectionPath: itemCollectionName, data: data);
                if (result) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('save', style: TextStyle(color: Colors.white)))
        ],
      ),
      body: Column(children: [
        TextFormField(
          decoration: const InputDecoration(
            label: Text('이름'),
          ),
          controller: controllerTitle,
        ),
        TextFormField(
          decoration: const InputDecoration(
            label: Text('가격'),
          ),
          controller: controllerPrice,
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          decoration: const InputDecoration(
            label: Text('설명'),
          ),
          controller: controllerDesc,
        ),
        SwitchListTile(
          value: isSoldOut,
          onChanged: (value) {
            setState(() {
              isSoldOut = value;
            });
          },
          title: const Text('sold out?'),
        ),
        //옵션 추가하기
        //옵션 이름 [1,2,3,4,5]
        //option:{'size':'1,2,3,4,5'}
        const Text('옵션'),
        Expanded(child: option),
        IconButton(
            onPressed: () {
              if (controllerOptionName.text != '' &&
                  controllerOptionValue.text != '') {
                options.add({
                  'optionName': controllerOptionName.text,
                  'optionValue': controllerOptionValue.text
                });
              }
              showOptionList();
            },
            icon: const Icon(Icons.arrow_upward_outlined)),
        TextField(
          controller: controllerOptionName,
        ),
        TextField(
          controller: controllerOptionValue,
          maxLines: 10,
        ),
      ]),
    );
  }
}
