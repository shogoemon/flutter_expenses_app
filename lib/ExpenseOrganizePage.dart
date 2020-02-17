import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';
import './db/Database.dart';

class ExpenseOrganizePage extends StatefulWidget {
  @override
  _OrganizeState createState() => _OrganizeState();
}

class _OrganizeState extends State<ExpenseOrganizePage>
    with TickerProviderStateMixin {
  CalendarController calendarCtrl;
  AnimationController _animationController;
  List<Map<String, dynamic>> monthExpenseDB;
  Map<DateTime, List> expenseSetMap = {};
  final expenseListKey = new GlobalKey<_ExpenseListState>();

  @override
  void initState() {
    super.initState();
    calendarCtrl = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
    loadDB(DateTime.now());
  }

  Future loadDB(DateTime selectedDay) async {
    int sameDayNum=0;
    await ExpensesTableDB.connectDB();
//DateTime.now()
    expenseSetMap = {};
    monthExpenseDB = await ExpensesTableDB.getMonthData(
        selectedDay.year.toString(), selectedDay.month.toString());
    monthExpenseDB.forEach((expenses) {
      if(sameDayNum==expenses['day']){
        //print(expenses['createTime']);
        expenseSetMap[
          DateTime(expenses['year'], expenses['month'], expenses['day'])]
            .add(expenses['createTime']+'.:.'+expenses['category']+'.:.'+expenses['inOrOut']+'.:.'+expenses['price']);
      }else{
        expenseSetMap.addAll({
          DateTime(expenses['year'], expenses['month'], expenses['day']): [
            expenses['createTime']+'.:.'+expenses['category']+'.:.'+expenses['inOrOut']+'.:.'+expenses['price']
          ]
        });
      }
      sameDayNum=expenses['day'];
    });
    setState(() {
      expenseSetMap = expenseSetMap;
    });
    //print(expenseSetMap);
  }

  @override
  void dispose() {
    calendarCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TableCalendar(
          onVisibleDaysChanged: (firstDay, lastDay, format) {
           // print('monthChanged');
            if (firstDay.day > 20) {
              loadDB(lastDay);
            } else {
              loadDB(firstDay);
            }
          },
          headerStyle:
              HeaderStyle(centerHeaderTitle: true, formatButtonVisible: false),
          calendarController: calendarCtrl,
          //locale: 'ja_JP',
          events: expenseSetMap,
          builders: CalendarBuilders(dayBuilder: (context, date, _) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.0),
                borderRadius: BorderRadius.circular(0.0),
              ),
              padding: const EdgeInsets.all(2.5),
              alignment: Alignment(0, -1.0),
              child: Column(
                children: <Widget>[
                  Text('${date.day}',
                      style: TextStyle().copyWith(fontSize: 14.0)),
//                  Expanded(
//                    child: Text('合計 100000000円',
//                        style: TextStyle().copyWith(fontSize: 12.0)),
//                  )
                ],
              ),
            );
          }, todayDayBuilder: (context, date, _) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue[200],
                border: Border.all(width: 0.0),
                borderRadius: BorderRadius.circular(0.0),
              ),
              padding: const EdgeInsets.all(2.5),
              alignment: Alignment(0, -1.0),
              child: Column(
                children: <Widget>[
                  Text('${date.day}',
                      style: TextStyle().copyWith(fontSize: 14.0)),
//                  Expanded(
//                    child: Text('合計 100000000円',
//                        style: TextStyle().copyWith(fontSize: 12.0)),
//                  )
                ],
              ),
            );
          }, selectedDayBuilder: (context, date, _) {
            Color selectedColor = Colors.red;
            return Container(
              decoration: BoxDecoration(
                color: selectedColor,
                border: Border.all(width: 0.0),
                borderRadius: BorderRadius.circular(0.0),
              ),
              padding: const EdgeInsets.all(2.5),
              alignment: Alignment(0, -1.0),
              child: Column(
                children: <Widget>[
                  Text('${date.day}',
                      style: TextStyle().copyWith(fontSize: 14.0)),
//                  Expanded(
//                    child: Text('合計 100000000円',
//                        style: TextStyle().copyWith(fontSize: 12.0)),
//                  )
                ],
              ),
            );
          }, markersBuilder: (context, date, expenseSet, holidays) {
            final children = <Widget>[];
            int oneDayIncome=0;
            int oneDayOutgo=0;
            String dayTotalLabel='';
            expenseSet.forEach((element) {
              List<String> anExpense=element.split('.:.');
              if(anExpense[2]=='true'){
                oneDayOutgo+=int.parse(anExpense[3]);
              }else{
                oneDayIncome+=int.parse(anExpense[3]);
              }
            });
            if(oneDayIncome!=0){
              dayTotalLabel+='+'+oneDayIncome.toString()+'\n';
            }
            if(oneDayOutgo!=0){
              dayTotalLabel+='-'+oneDayOutgo.toString();
            }
            if (expenseSet.isNotEmpty) {
              children.add(Positioned(
                  child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.0),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                padding: const EdgeInsets.all(2.5),
                alignment: Alignment(0, -1.0),
                child: Column(
                  children: <Widget>[
                    Text('${date.day}',
                        style: TextStyle().copyWith(fontSize: 14.0)),
                    Expanded(
                      child: Text(dayTotalLabel,
                          style: TextStyle().copyWith(fontSize: 12.0)),
                    )
                  ],
                ),
              )));
            }

            return children;
          }),
          onDaySelected: (day, events) {
            //print(expenseListKey.currentState.dayExpensesTiles);
            expenseListKey.currentState.buildListTiles(events);
          },
        ),
        Expanded(
          child: ExpenseList(key: expenseListKey,),
        )
      ],
    );
  }
}

class ExpenseList extends StatefulWidget {
  ExpenseList({Key key}) : super(key: key);
  @override
  _ExpenseListState createState() => new _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Widget> dayExpensesTiles=[];

  void buildListTiles(List<dynamic> tileInfos){
    List<Widget> listTiles=[];
    String inOrOutLabel;
    tileInfos.forEach((element) {
      List<String> tileLabels=element.split('.:.');
      if(tileLabels[2]=='true'){
        inOrOutLabel='-';
      }else{
        inOrOutLabel="+";
      }
      listTiles.add(
          ListTile(title: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(tileLabels[1]),
              ),
              Expanded(
                flex: 1,
                child: Text(inOrOutLabel+tileLabels[3]+'円'),
              ),
            ],
          ),)
      );
    });
    setState(() {
      dayExpensesTiles=listTiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: dayExpensesTiles,
    );
  }
}
