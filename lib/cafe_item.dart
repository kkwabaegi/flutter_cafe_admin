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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text('암ㄴㅇ'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CafeCategoryAddForm(),
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CafeCategoryAddForm extends StatefulWidget {
  const CafeCategoryAddForm({super.key});

  @override
  State<CafeCategoryAddForm> createState() => _CafeCategoryAddFormState();
}

class _CafeCategoryAddFormState extends State<CafeCategoryAddForm> {
  TextEditingController controller = TextEditingController();

  var isUsed = true;

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
                    'categoryname': controller.text,
                    'isUsed': isUsed
                  };
                  if (await myCafe.insert(
                      collectionPath: categoryCollectionName, data: data)) {
                    Navigator.pop(context);
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
