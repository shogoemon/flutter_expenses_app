import 'package:flutter/material.dart';
import './EditorState.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectCategoryPage extends StatefulWidget {
  @override
  _SelectCategoryPageState createState() => new _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  List<Widget> categoryTiles = [];
  SharedPreferences prefs;
  List<String> loadedList;

  @override
  void initState() {
    super.initState();
    loadSavedList().then((materialList) {
      buildCategoryTiles();
    });
  }

  Future loadSavedList() async {
    loadedList = null;
    prefs = await SharedPreferences.getInstance();
    if (EditorInputtedData.outOrInBool) {
      loadedList = prefs.getStringList('outCategoryList');
    } else {
      loadedList = prefs.getStringList('inCategoryList');
    }
  }

  void buildCategoryTiles() {
    if (loadedList == null) {
      loadedList = [];
    }
    List<Widget> _categoryTiles = [];
    if (EditorInputtedData.outOrInBool) {
      EditorInputtedData.outCategoryList.forEach((label) {
        _categoryTiles.add(ListTile(
          title: Text(label),
          onTap: () {
            if (EditorInputtedData.outOrInBool) {
              EditorInputtedData.outSelectedCategory = label;
            } else {
              EditorInputtedData.inSelectedCategory = label;
            }
            Navigator.of(context).pop();
          },
        ));
        if (label == 'その他') {
          _categoryTiles.add(Divider(
            color: Colors.black,
          ));
        } else {
          _categoryTiles.add(Divider());
        }
      });
    } else {
      EditorInputtedData.inCategoryList.forEach((label) {
        _categoryTiles.add(ListTile(
          title: Text(label),
          onTap: () {
            if (EditorInputtedData.outOrInBool) {
              EditorInputtedData.outSelectedCategory = label;
            } else {
              EditorInputtedData.inSelectedCategory = label;
            }
            Navigator.of(context).pop();
          },
        ));
        if (label == 'その他') {
          _categoryTiles.add(Divider(
            color: Colors.black,
          ));
        } else {
          _categoryTiles.add(Divider());
        }
      });
    }
    loadedList.forEach((label) {
      _categoryTiles.add(Dismissible(
          key: Key("some id"),
          direction: DismissDirection.endToStart,
          background: Container(
              color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Text('削除する'),
                  ),
                  Icon(Icons.delete),
                ],
              )),
          onDismissed: (direction) {
            loadedList.removeAt(loadedList.indexOf(label));
            if (EditorInputtedData.outOrInBool) {
              prefs.setStringList('outCategoryList', loadedList);
              EditorInputtedData.outSelectedCategory =
                  EditorInputtedData.outCategoryList[0];
            } else {
              prefs.setStringList('inCategoryList', loadedList);
              EditorInputtedData.inSelectedCategory =
                  EditorInputtedData.inCategoryList[0];
            }
            print(label);
          },
          child: ListTile(
            title: Text(label),
            onTap: () {
              if (EditorInputtedData.outOrInBool) {
                EditorInputtedData.outSelectedCategory = label;
              } else {
                EditorInputtedData.inSelectedCategory = label;
              }
              Navigator.of(context).pop();
            },
          )));
      _categoryTiles.add(Divider());
    });
    _categoryTiles.add(ListTile(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AddCategoryForm(loadedList);
            });
      },
      title: Text('追加する'),
      trailing: Icon(Icons.edit),
    ));
    setState(() {
      categoryTiles = _categoryTiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カテゴリー選択'),
      ),
      body: ListView(children: categoryTiles),
    );
  }
}

class AddCategoryForm extends StatefulWidget {
  AddCategoryForm(this.loadedList);
  final List<String> loadedList;
  @override
  _AddCategoryFormState createState() => new _AddCategoryFormState(loadedList);
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  _AddCategoryFormState(this.loadedList);
  List<String> loadedList;
  SharedPreferences prefs;
  TextEditingController txtCtrl = new TextEditingController();
  Function onPressedFunc;
  String cautionSt = '';

  void addLabelFunction() async {
    prefs = await SharedPreferences.getInstance();
    loadedList.add(txtCtrl.text);
    if (EditorInputtedData.outOrInBool) {
      prefs.setStringList('outCategoryList', loadedList);
      EditorInputtedData.outSelectedCategory = txtCtrl.text;
    } else {
      prefs.setStringList('inCategoryList', loadedList);
      EditorInputtedData.inSelectedCategory = txtCtrl.text;
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    if (loadedList == null) {
      loadedList = [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
          title: Text("カテゴリーを追加する"),
          children: <Widget>[
            Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 3 / 4,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        autofocus: true,
                        onChanged: (value) {
                          if (value == ''||RegExp('\^ |\^　').hasMatch(value)) {
                            setState(() {
                              cautionSt = '文字を入力して下さい';
                              onPressedFunc = null;
                            });
                          } else {
                            if (loadedList.indexOf(value) != -1 ||
                                EditorInputtedData.inCategoryList
                                        .indexOf(value) !=
                                    -1 ||
                                EditorInputtedData.outCategoryList
                                        .indexOf(value) !=
                                    -1) {
                              setState(() {
                                cautionSt = 'すでに登録されています。';
                                onPressedFunc = null;
                              });
                            } else {
                              setState(() {
                                cautionSt = '';
                                onPressedFunc = addLabelFunction;
                              });
                            }
                          }
                        },
                        controller: txtCtrl,
                      ),
                      Container(
                        child: Text(cautionSt),
                      )
                    ],
                  )),
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(color: Colors.grey[200]))),
                      child: FlatButton(
                        child: Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(color: Colors.grey[200]))),
                      child: FlatButton(
                          child: Text("OK"), onPressed: onPressedFunc),
                    ))
              ],
            )
          ],
        ),
      ],
    );
  }
}
