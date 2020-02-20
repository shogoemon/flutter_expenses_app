import 'package:flutter/material.dart';
import './EditExpense.dart';
import './EditorState.dart';
import './db/DataBase.dart';

class ReEditExpensePage extends StatefulWidget{
  ReEditExpensePage(this.updateData);
  final String updateData;
  @override
  _ReEditExpensePageState createState() => new _ReEditExpensePageState(updateData);
}

class _ReEditExpensePageState extends State<ReEditExpensePage>{
  _ReEditExpensePageState(this.updateData);
  final String updateData;

  @override
  void initState() {
    ExpensesTableDB.connectDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('編集'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                ExpensesTableDB.deleteData(updateData);
                Navigator.of(context).pop(true);
                EditorInputtedData.outOrInBool=true;
                EditorInputtedData.inputPrice=0;
                EditorInputtedData.inSelectedCategory='給与';
                EditorInputtedData.outSelectedCategory='未分類';
                EditorInputtedData.selectedDay=DateTime.now();
              }
          ),
        ],
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: (){
              Navigator.of(context).pop(false);
              EditorInputtedData.outOrInBool=true;
              EditorInputtedData.inputPrice=0;
              EditorInputtedData.inSelectedCategory='給与';
              EditorInputtedData.outSelectedCategory='未分類';
              EditorInputtedData.selectedDay=DateTime.now();
            }
            ),
      ),
      body:EditExpensePage(updateData: updateData)
      );
  }
}