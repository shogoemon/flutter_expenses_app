import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './EditorState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_action.dart';
import './db/Database.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class EditExpensePage extends StatefulWidget {
  @override
  _EditExpenseState createState() => _EditExpenseState();
}

class _EditExpenseState extends State<EditExpensePage> {


  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future insetData()async{
    await ExpensesTableDB.insertData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            InOrOutButtonForm(),
            PriceInputForm(),
            CategorySelectorForm(),
            DataSelectorForm(),
            Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Center(
                child: RaisedButton(
                  child: Text(
                    '保存',
                    style: TextStyle().copyWith(
                      fontSize: 30.0,
                    ),
                  ),
                  onPressed: () {
                    print(
                        EditorInputtedData.inputPrice.toString()+''+
                            EditorInputtedData.outOrInBool.toString()+''+
                            EditorInputtedData.inputPrice.toString()+''+
                            EditorInputtedData.selectedCategory+''+
                            EditorInputtedData.selectedDay.toString()
                    );
                  },
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class PriceInputForm extends StatefulWidget {
  @override
  _PriceInputFormState createState() => new _PriceInputFormState();
}

class _PriceInputFormState extends State<PriceInputForm> {
  TextEditingController moneyTxtCtrl = TextEditingController();
  final FocusNode txtFocus = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        nextFocus: false,
        keyboardBarColor: Colors.grey,
        actions: [
          KeyboardAction(focusNode: txtFocus, displayDoneButton: true),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.of(context).size.height / 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: KeyboardActions(
                config: _buildConfig(context),
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  style: TextStyle().copyWith(
                    fontSize: 30.0,
                  ),
                  controller: moneyTxtCtrl,
                  focusNode: txtFocus,
                  onChanged: (value) {
                    // EditorInputtedData.inputPrice=value;
                  },
                )),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '¥',
                style: TextStyle().copyWith(
                  fontSize: 30.0,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class InOrOutButtonForm extends StatefulWidget {
  @override
  _InOrOutButtonFormState createState() => new _InOrOutButtonFormState();
}

class _InOrOutButtonFormState extends State<InOrOutButtonForm> {
  Color inButtonColor = Colors.grey;
  Color outButtonColor = Colors.blue;
  Color trueColor = Colors.blue;
  Color falseColor = Colors.grey;

  @override
  void initState() {
    if (EditorInputtedData.outOrInBool) {
      setState(() {
        inButtonColor = falseColor;
        outButtonColor = trueColor;
      });
    }
    super.initState();
  }

  void switchBool(bool whichButton) {
    print(EditorInputtedData.outOrInBool);
    if (EditorInputtedData.outOrInBool != whichButton) {
      EditorInputtedData.outOrInBool = !EditorInputtedData.outOrInBool;
      if (EditorInputtedData.outOrInBool) {
        setState(() {
          inButtonColor = falseColor;
          outButtonColor = trueColor;
        });
      } else {
        setState(() {
          inButtonColor = trueColor;
          outButtonColor = falseColor;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.grey,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(
                '収入',
                style: TextStyle(color: Colors.white),
              ),
              color: inButtonColor,
              onPressed: () {
                switchBool(false);
              },
            ),
            RaisedButton(
              child: Text(
                '支出',
                style: TextStyle(color: Colors.white),
              ),
              color: outButtonColor,
              onPressed: () {
                switchBool(true);
              },
            ),
          ],
        ),
      ),
      height: MediaQuery.of(context).size.height / 8,
    );
  }
}

class CategorySelectorForm extends StatefulWidget {
  @override
  _CategorySelectorFormState createState() => new _CategorySelectorFormState();
}

class _CategorySelectorFormState extends State<CategorySelectorForm> {
  SharedPreferences prefs;

  List<Widget> categoryListTiles = [];
  String categoryLabel = '';
  int categoryIndex;

  Widget createListTile(String label) {
    return ListTile(
      title: Text(label),
    );
  }

  @override
  void initState() {
    EditorInputtedData.loadCategoryList(false).then((categoryList){
      categoryList.forEach((element) {
        categoryListTiles.add(createListTile(element));
      });
      EditorInputtedData.selectedCategory ??= EditorInputtedData.categoryList[0];
      categoryLabel=EditorInputtedData.selectedCategory;
      categoryIndex=EditorInputtedData.categoryList.indexOf(categoryLabel);
      if(categoryIndex==-1){
        EditorInputtedData.categoryList.add(EditorInputtedData.selectedCategory);
        categoryListTiles.add(createListTile(EditorInputtedData.selectedCategory));
        categoryIndex=EditorInputtedData.categoryList.length;
      }
      setCategoryLabel(categoryLabel);
    });
    super.initState();
  }

  void setCategoryLabel(String label) {
    setState(() {
      categoryLabel = label;
    });
    EditorInputtedData.selectedCategory=label;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('分類:' + categoryLabel),
      trailing: Icon(Icons.expand_more),
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: MediaQuery.of(context).size.height / 3,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                      initialItem: categoryIndex),
                  useMagnifier: true,
                  itemExtent: 50.0,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      setCategoryLabel(EditorInputtedData.categoryList[value]);
                      categoryIndex = value;
                    });
                  },
                  children: categoryListTiles,
                ),
              );
            });
        //changeSubNumLabel('');
      },
    );
  }
}

class DataSelectorForm extends StatefulWidget {
  @override
  _DataSelectorFormState createState() => new _DataSelectorFormState();
}

class _DataSelectorFormState extends State<DataSelectorForm> {
  String selectDayLabel='';

  @override
  void initState() {
    setDayLabel(EditorInputtedData.selectedDay);
    super.initState();
  }

  void setDayLabel(DateTime selectDay){
    setState(() {
      selectDayLabel=
          selectDay.year.toString()+'年'+
              selectDay.month.toString()+'月'+
              selectDay.day.toString()+'日';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(selectDayLabel),
      trailing: Icon(Icons.expand_more),
      onTap: () {
        DatePicker.showDatePicker(
            context,
            showTitleActions: false,
            minTime: DateTime(2018, 1, 1),
            maxTime: DateTime(2023, 12, 31),
            onChanged: (date) {
              EditorInputtedData.selectedDay=date;
              setDayLabel(date);
            }, onConfirm: (date) {
              print('confirm $date');
            },
            currentTime: EditorInputtedData.selectedDay,
            locale: LocaleType.jp);
      },
    );
  }
}