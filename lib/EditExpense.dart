import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './EditorState.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_action.dart';
import './db/Database.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import './SelectCategoryPage.dart';
import 'dart:io';

class EditExpensePage extends StatefulWidget {
  EditExpensePage({this.updateData, this.onTapBottomNavigation});
  final String updateData;
  final Function onTapBottomNavigation;
  @override
  _EditExpenseState createState() => _EditExpenseState(
      updateData: updateData, onTapBottomNavigation: onTapBottomNavigation);
}

class _EditExpenseState extends State<EditExpensePage> {
  _EditExpenseState({this.updateData, this.onTapBottomNavigation});
  Function onTapBottomNavigation;
  String updateData;
  final priceFormKey = new GlobalKey<_PriceInputFormState>();
  //InOrOutButtonFormState
  final categorySelectorKey = new GlobalKey<_CategorySelectorFormState>();
  Widget priceInputFormWidget;

  void switchCategoryLabel() {
    categorySelectorKey.currentState.setCategoryLabel();
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      priceInputFormWidget = PriceFormAndroid(key: priceFormKey);
    } else {
      priceInputFormWidget = PriceFormAndroid(key: priceFormKey);
      //priceInputFormWidget = PriceInputForm(key: priceFormKey);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future insertData() async {
    String selectedCategory;
    if (EditorInputtedData.outOrInBool) {
      selectedCategory = EditorInputtedData.outSelectedCategory;
    } else {
      selectedCategory = EditorInputtedData.inSelectedCategory;
    }
    if (updateData == null) {
      //追加
      //oldData[0]
      await ExpensesTableDB.insertData(
          createTime: DateTime.now().toString(),
          year: EditorInputtedData.selectedDay.year.toString(),
          month: EditorInputtedData.selectedDay.month.toString(),
          day: EditorInputtedData.selectedDay.day.toString(),
          category: selectedCategory,
          inOrOut: EditorInputtedData.outOrInBool.toString(),
          price: EditorInputtedData.inputPrice.toString());
    } else {
      //更新
      await ExpensesTableDB.updateData(
          createTime: updateData,
          year: EditorInputtedData.selectedDay.year.toString(),
          month: EditorInputtedData.selectedDay.month.toString(),
          day: EditorInputtedData.selectedDay.day.toString(),
          category: selectedCategory,
          inOrOut: EditorInputtedData.outOrInBool.toString(),
          price: EditorInputtedData.inputPrice.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            InOrOutButtonForm(switchCategoryLabel: switchCategoryLabel),
            priceInputFormWidget,
            Divider(),
            CategorySelectorForm(key: categorySelectorKey),
            Divider(),
            DataSelectorForm(),
            Divider(),
            Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Center(
                  child: Container(
                width: MediaQuery.of(context).size.width * 2 / 3,
                child: RaisedButton(
                  color: Colors.green[300],
                  child: Text(
                    '保存',
                    style: TextStyle()
                        .copyWith(fontSize: 30.0, color: Colors.white),
                  ),
                  onPressed: () {
                    insertData();
                    FocusScope.of(context).requestFocus(FocusNode());
                    EditorInputtedData.inputPrice = 0;
                    priceFormKey.currentState.setPrice();
                    if (updateData != null) {
                      Navigator.of(context).pop(true);
                    } else {
                      onTapBottomNavigation(0);
                    }
                  },
                ),
              )),
            )
          ],
        )
      ],
    );
  }
}

class PriceInputForm extends StatefulWidget {
  PriceInputForm({Key key}) : super(key: key);
  @override
  _PriceInputFormState createState() => new _PriceInputFormState();
}

class _PriceInputFormState extends State<PriceInputForm> {
  TextEditingController moneyTxtCtrl = TextEditingController();
  final FocusNode txtFocus = FocusNode();
  TextSelectionControls txtSelectionCtrl;

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
  void initState() {
    setPrice();
    txtFocus.addListener(() {
      if (!txtFocus.hasFocus) {
        EditorInputtedData.inputPrice = int.parse(moneyTxtCtrl.text);
      }
    });
    super.initState();
  }

  void setPrice() {
    setState(() {
      moneyTxtCtrl.text = EditorInputtedData.inputPrice.toString();
    });
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
                  showCursor: false,
                  keyboardType: TextInputType.numberWithOptions(),
                  style: TextStyle().copyWith(
                    fontSize: 30.0,
                  ),
                  controller: moneyTxtCtrl,
                  focusNode: txtFocus,
                  onChanged: (value) {
                    if (RegExp('^00').hasMatch(value)) {
                      moneyTxtCtrl.text = '0';
                    }
                    if (RegExp('^0[0-9]').hasMatch(value)) {
                      moneyTxtCtrl.text =
                          RegExp('[^0]').firstMatch(value).group(0);
                    }
                    if (value == '') {
                      moneyTxtCtrl.text = '0';
                    }
                    EditorInputtedData.inputPrice = int.parse(value);
                  },
                  enableInteractiveSelection: false,
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
  InOrOutButtonForm({Key key, this.switchCategoryLabel}) : super(key: key);
  final Function switchCategoryLabel;
  @override
  InOrOutButtonFormState createState() =>
      new InOrOutButtonFormState(EditorInputtedData.outOrInBool,
          switchCategoryLabel: switchCategoryLabel);
}

class InOrOutButtonFormState extends State<InOrOutButtonForm> {
  InOrOutButtonFormState(this.outOrInBool, {this.switchCategoryLabel});
  Function switchCategoryLabel;
  Color inButtonColor = Colors.grey;
  Color outButtonColor = Colors.blue;
  Color trueColor = Colors.blue[300];
  Color falseColor = Colors.grey[400];
  bool outOrInBool;

  @override
  void initState() {
    if (outOrInBool) {
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
    super.initState();
  }

  void switchBool(bool whichButton) {
    if (outOrInBool != whichButton) {
      EditorInputtedData.outOrInBool = !EditorInputtedData.outOrInBool;
      outOrInBool = !outOrInBool;
      if (outOrInBool) {
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
    switchCategoryLabel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
  CategorySelectorForm({Key key}) : super(key: key);
  @override
  _CategorySelectorFormState createState() => new _CategorySelectorFormState();
}

class _CategorySelectorFormState extends State<CategorySelectorForm> {
  String categoryLabel = '';

  @override
  void initState() {
    setCategoryLabel();
    super.initState();
  }

  void setCategoryLabel() {
    String label = '';
    if (EditorInputtedData.outOrInBool) {
      label = EditorInputtedData.outSelectedCategory;
    } else {
      label = EditorInputtedData.inSelectedCategory;
    }
    setState(() {
      categoryLabel = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Container(
            child: Text('分類:'),
          ),
          Expanded(
            child: Center(
              child: Text(categoryLabel),
            ),
          )
        ],
      ),
      trailing: Icon(Icons.expand_more),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SelectCategoryPage()))
            .then((value) {
          setCategoryLabel();
        });
      },
    );
  }
}

class DataSelectorForm extends StatefulWidget {
  DataSelectorForm({Key key}) : super(key: key);
  @override
  _DataSelectorFormState createState() => new _DataSelectorFormState();
}

class _DataSelectorFormState extends State<DataSelectorForm> {
  String selectDayLabel = '';

  @override
  void initState() {
    setDayLabel(EditorInputtedData.selectedDay);
    super.initState();
  }

  void setDayLabel(DateTime selectDay) {
    setState(() {
      selectDayLabel = selectDay.year.toString() +
          '年' +
          selectDay.month.toString() +
          '月' +
          selectDay.day.toString() +
          '日';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Container(
            child: Text('日付:'),
          ),
          Expanded(
            child: Center(child: Text(selectDayLabel)),
          )
        ],
      ),
      trailing: Icon(Icons.expand_more),
      onTap: () {
        DatePicker.showDatePicker(context,
            showTitleActions: false,
            minTime: DateTime(2018, 1, 1),
            maxTime: DateTime(2023, 12, 31), onChanged: (date) {
          EditorInputtedData.selectedDay = date;
          setDayLabel(date);
        },
            onConfirm: (date) {},
            currentTime: EditorInputtedData.selectedDay,
            locale: LocaleType.jp);
      },
    );
  }
}

class PriceFormAndroid extends PriceInputForm {
  PriceFormAndroid({Key key}) : super(key: key);
  @override
  _PriceFormAndroidState createState() => new _PriceFormAndroidState();
}

class _PriceFormAndroidState extends _PriceInputFormState {
  int keyNum = 0;
  String inputPrice = '0';
  final priceFormKey = new GlobalKey<_PriceDisplayAndroidKeyBoardState>();

  @override
  void setPrice() {
    setState(() {
      inputPrice = EditorInputtedData.inputPrice.toString();
    });
  }

  @override
  void initState() {
    inputPrice = EditorInputtedData.inputPrice.toString();
    super.initState();
  }

  void showKeyboard() {
    showModalBottomSheet(
        context: context,
        elevation: 0.0,
        builder: (BuildContext context) {
          keyNum = 1;
          List<Widget> keyList = [];
          for (int i = 0; i < 3; i++) {
            keyList.add(Expanded(flex: 1, child: rowBuilder()));
          }
          keyList.add(Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  doneKey(),
                  keyBuilder('0'),
                  deleteKey(),
                ],
              )));
          keyList=<Widget>[PriceDisplayAndroidKeyBoard(inputPrice,key:priceFormKey)]+keyList;
          return Container(
            height: 350,
            child: Column(children: keyList),
          );
        });
  }

  Widget deleteKey() {
    return Expanded(
      child: InkWell(
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.0, color: Colors.white),
              color: Colors.blue.withOpacity(0.7),
            ),
            child: Center(child: Icon(Icons.backspace))),
        onTap: () {
          inputPrice = inputPrice.substring(0, inputPrice.length - 1);
          if (inputPrice == '') {
            inputPrice = '0';
          }
          setState(() {
            inputPrice = inputPrice;
          });
          priceFormKey.currentState.setLabel(inputPrice);
          EditorInputtedData.inputPrice = int.parse(inputPrice);
        },
      ),
    );
  }

  Widget doneKey() {
    return Expanded(
      child: InkWell(
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.0, color: Colors.white),
              color: Colors.blue.withOpacity(0.7),
            ),
            child: Center(
                child: Text(
              'Done',
              style: TextStyle(color: Colors.white,fontSize: 20.0),
            ))),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget rowBuilder() {
    List<Widget> rowKeys = [];
    for (int i = 0; i < 3; i++) {
      rowKeys.add(keyBuilder(keyNum.toString()));
    }
    return Row(children: rowKeys);
  }

  Widget keyBuilder(String label) {
    keyNum++;
    return Expanded(
      child: InkWell(
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.0, color: Colors.white),
              color: Colors.blue.withOpacity(0.7),
            ),
            child: Center(
                child: Text(
              label.toString(),
              style: TextStyle(color: Colors.white, fontSize: 25.0),
            ))),
        splashColor: Colors.white,
        onTap: () {
          inputPrice = inputPrice + label;
          if (RegExp('^00').hasMatch(inputPrice)) {
            inputPrice = '0';
          }
          if (RegExp('^0[0-9]').hasMatch(inputPrice)) {
            inputPrice = RegExp('[^0]').firstMatch(inputPrice).group(0);
          }
          setState(() {
            inputPrice = inputPrice;
          });
          priceFormKey.currentState.setLabel(inputPrice);
          EditorInputtedData.inputPrice = int.parse(inputPrice);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.of(context).size.height / 6,
      child: InkWell(
        child: Row(
         // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(inputPrice,
                        style: TextStyle().copyWith(
                          fontSize: 30.0,
                        ))
                  ],
                ),
              ),
            ),
            Text(
              '¥',
              style: TextStyle().copyWith(
                fontSize: 30.0,
              ),
            )
          ],
        ),
          onTap: () {
            showKeyboard();
          }
      ),
    );
  }
}

class PriceDisplayAndroidKeyBoard extends StatefulWidget{
  PriceDisplayAndroidKeyBoard(this.priceLabel,{Key key}):super(key:key);
  final String priceLabel;
  @override
  _PriceDisplayAndroidKeyBoardState createState()=> new _PriceDisplayAndroidKeyBoardState(priceLabel);
}

class _PriceDisplayAndroidKeyBoardState extends State<PriceDisplayAndroidKeyBoard>{
  _PriceDisplayAndroidKeyBoardState(this.priceLabel);
  String priceLabel='';

  void setLabel(String label){
    setState(() {
      priceLabel=label;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.white,
      child: Center(
        child: Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide())),
          width: MediaQuery.of(context).size.width*2/3,
          child: Text(
              priceLabel,
            style: TextStyle().copyWith(
              fontSize: 30.0,
            ),
          ),
        ),
      ),
    );
  }
}
