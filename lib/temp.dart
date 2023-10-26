//아이템 추가/수정 폼
//이름, 가격, 사진, 옵션, 매진여부, 제품설명
import 'package:flutter/material.dart';
import 'package:flutter_cafe_admin/cafe_item.dart';

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
  var options = {};

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
                  'itemName': controllerTitle.text,
                  'itemPrice': int.parse(controllerPrice.text),
                  'itemDesc': controllerDesc.text,
                  'itemIsSoldOut': isSoldOut
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
              setState(() {
                options[controllerOptionName.text] = controllerOptionValue.text;
                option = ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        //map타입으로 속성을 쓰는 방법!
                        title: Text(options.keys.toList()[index]),
                        subtitle: Text(options[options.keys.toList()[index]]
                            .replaceAll('\n', ' / ')),
                        trailing: IconButton(
                            onPressed: () {}, icon: const Icon(Icons.close)),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: options.length);
              });
              controllerOptionName.clear();
              controllerOptionValue.clear();
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
