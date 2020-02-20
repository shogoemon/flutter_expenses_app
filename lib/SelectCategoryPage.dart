import 'package:flutter/material.dart';
import './EditorState.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectCategoryPage extends StatefulWidget{
  @override
  _SelectCategoryPageState createState()=> new _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage>{
  List<Widget> categoryTiles=[];
  SharedPreferences prefs;
  List<String> loadedList;

  @override
  void initState() {
    super.initState();
    loadSavedList().then((materialList){
      buildCategoryTiles(materialList);
    });
  }

  Future loadSavedList()async{
    List<String> materialList;
    loadedList=null;
    prefs=await SharedPreferences.getInstance();
    if(EditorInputtedData.outOrInBool){
      loadedList=prefs.getStringList('outCategoryList');
      materialList=EditorInputtedData.outCategoryList;
      if(loadedList!=null){
        materialList+=loadedList;
      }
    }else{
      loadedList=prefs.getStringList('inCategoryList');
      materialList=EditorInputtedData.inCategoryList;
      if(loadedList!=null){
        materialList+=loadedList;
      }
    }
    return materialList;
  }

  void buildCategoryTiles(List<String> materialList){
    List<ListTile> _categoryTiles=[];
    materialList.forEach((label) {
      _categoryTiles.add(
          ListTile(
            title: Text(label),
            onTap: (){
              if(EditorInputtedData.outOrInBool){
                EditorInputtedData.outSelectedCategory=label;
              }else{
                EditorInputtedData.inSelectedCategory=label;
              }
              Navigator.of(context).pop();
            },
          ));
    });
    _categoryTiles.add(
        ListTile(
          onTap: (){
            showDialog(
                context: context,
                builder: (context) {
                  return AddCategoryForm(loadedList);
                }
            );
          },
            title: Row(
              children: <Widget>[
                Icon(Icons.build),
                Text('追加する'),
              ],
            )
        )
    );
    setState(() {
      categoryTiles=_categoryTiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('カテゴリー選択'),),
      body: ListView(
          children: categoryTiles
      ),
    );
  }
}

class AddCategoryForm extends StatefulWidget{
  AddCategoryForm(this.loadedList);
  final List<String> loadedList;
  @override
  _AddCategoryFormState createState()=>new _AddCategoryFormState(loadedList);
}

class _AddCategoryFormState extends State<AddCategoryForm>{
  _AddCategoryFormState(this.loadedList);
  List<String> loadedList;
  SharedPreferences prefs;
  TextEditingController txtCtrl=new TextEditingController();
  Function onPressedFunc;

  void addLabelFunction()async{
    prefs=await SharedPreferences.getInstance();
    loadedList.add(txtCtrl.text);
    if(EditorInputtedData.outOrInBool){
      prefs.setStringList('outCategoryList',loadedList);
      EditorInputtedData.outSelectedCategory=txtCtrl.text;
    }else{
      prefs.setStringList('inCategoryList', loadedList);
      EditorInputtedData.inSelectedCategory=txtCtrl.text;
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    if(loadedList==null){
      loadedList=[];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AlertDialog(
            title: Text("カテゴリーを追加する"),
            content: Container(
                child: TextField(
                  onChanged: (value){
                    if(value==''||loadedList.indexOf(value)!=-1){
                      setState(() {
                        onPressedFunc=null;
                      });
                      //文字がない場合、すでに保存されている文字と同じ場合は無効にする
                    }else{
                      setState(() {
                        onPressedFunc=addLabelFunction;
                      });
                    }
                  },
                  controller: txtCtrl,
                )
            ),
            actions: [
              FlatButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                  child: Text("OK"),
                  onPressed: onPressedFunc
              )
            ]
        ),
      ],
    );
  }
}