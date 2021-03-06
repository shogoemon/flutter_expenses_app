import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';
import './db/Database.dart';
import './ReEditExpense.dart';
import './EditorState.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';

class ExpenseCalendarPage extends StatefulWidget {
  ExpenseCalendarPage(this.onTapBottomNavigation);
  final Function onTapBottomNavigation;
  @override
  _CalendarState createState() => _CalendarState(onTapBottomNavigation);
}

class _CalendarState extends State<ExpenseCalendarPage>
    with TickerProviderStateMixin {
  _CalendarState(this.onTapBottomNavigation);
  final Function onTapBottomNavigation;
  CalendarController calendarCtrl;
  AnimationController _animationController;
  List<Map<String, dynamic>> monthExpenseDB;
  Map<DateTime, List<List<String>>> expenseSetMap = {};
  final expenseListKey = new GlobalKey<_ExpenseListState>();

  @override
  void initState() {
    super.initState();
    calendarCtrl = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    loadDB(EditorInputtedData.calendarSelectedDay).then((selectedDay) {
      List<dynamic> events = expenseSetMap[
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];
      events ??= [];
      expenseListKey.currentState.buildListTiles(selectedDay, events);
    });
  }

  Future loadDB(DateTime selectedDay) async {
    await initializeDateFormatting("ja_JP");
    int sameDayNum = 0;
    await ExpensesTableDB.connectDB();
    expenseSetMap = {};
    monthExpenseDB = await ExpensesTableDB.getDataFromCalendar(
        year:selectedDay.year.toString(), month:selectedDay.month.toString());
    monthExpenseDB.forEach((expenses) {
      //monthExpenseDBはList<Map<String, dynamic>>で、マップ形式で保存した一つの品目のデータが複数入ったリスト。
      //カレンダーからイベントとして取り出せるのはMap<DateTime,List>のため,monthExpenseDBからデータを取り出して形を変える。
      // keyが日付、valueがその１日分の品目をまとめたList<List>で
      //一つの品目のデータをListに置き換え、それらをまた一つのリストにする。
      if (sameDayNum == int.parse(expenses['day'])) {
        //monthExpenseDBは日付順
        // 一つ前に取り出したデータの日付と同じ日付の場合
        expenseSetMap[
                DateTime(int.parse(expenses['year']), int.parse(expenses['month']), int.parse(expenses['day']))]
            .add([expenses['createTime'],expenses['category'],expenses['inOrOut'],expenses['price']]);
      } else {
        expenseSetMap.addAll({
          DateTime(int.parse(expenses['year']), int.parse(expenses['month']), int.parse(expenses['day'])): [[
            expenses['createTime'],expenses['category'],expenses['inOrOut'],expenses['price']
          ]]
        });
      }
      sameDayNum = int.parse(expenses['day']);
    });
    setState(() {
      expenseSetMap = expenseSetMap;
    });
    return selectedDay;
  }

  Map<DateTime, List> expenseSetMapGetter() => expenseSetMap;

  @override
  void dispose() {
    calendarCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TableCalendar(
                initialSelectedDay: EditorInputtedData.calendarSelectedDay,
                onVisibleDaysChanged: (firstDay, lastDay, format) {
                  if (firstDay.day > 20) {
                    loadDB(lastDay);
                  } else {
                    loadDB(firstDay);
                  }
                },
                calendarStyle: CalendarStyle(
                  todayColor: Colors.blue,
                  outsideDaysVisible: false,
                ),
                headerStyle:
                HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonVisible: false,
                ),
                formatAnimation: FormatAnimation.slide,
                calendarController: calendarCtrl,
                locale: 'ja_JP',
                events: expenseSetMap,
                builders: CalendarBuilders(
                    dayBuilder: (context, date, _) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.0),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    alignment: Alignment(0, -1.0),
                    child: Column(
                      children: <Widget>[
                        Text('${date.day}',
                            style: TextStyle().copyWith(fontSize: 14.0)),
                      ],
                    ),
                  );
                },
                    todayDayBuilder: (context, date, _) {
                  return Container(
                    decoration: BoxDecoration(
                      //color: Colors.blue[200],
                      border: Border.all(width: 0.0),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    alignment: Alignment(0, -1.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(date.day.toString(),
                              style: TextStyle().copyWith(fontSize: 14.0)
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              color: Colors.blue[100]
                          ),
                        )
                      ],
                    ),
                  );
                }, selectedDayBuilder: (context, date, _) {
                  return FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[200],
                        border: Border.all(width: 0.0),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      alignment: Alignment(0, -1.0),
                      child: Column(
                        children: <Widget>[
                          Text('${date.day}',
                              style: TextStyle().copyWith(fontSize: 14.0)),
                        ],
                      ),
                    ),
                  );
                }, markersBuilder: (context, date, expenseSet, holidays) {
                  final children = <Widget>[];
                  int oneDayIncome = 0;
                  int oneDayOutgo = 0;
                  String dayTotalLabel = '';
                  expenseSet.forEach((element) {
                    List<String> anExpense = element;
                    if (anExpense[2] == 'true') {
                      oneDayOutgo += int.parse(anExpense[3]);
                    } else {
                      oneDayIncome += int.parse(anExpense[3]);
                    }
                  });
                  if (oneDayIncome != 0 || expenseSet.toString().indexOf('.:.0]')!=-1) {
                    dayTotalLabel += '+' + oneDayIncome.toString() + '\n';
                  }
                  if (oneDayOutgo != 0 || expenseSet.toString().indexOf('.:.0]')!=-1) {
                    dayTotalLabel += '-' + oneDayOutgo.toString();
                  }
                  if (expenseSet.isNotEmpty) {
                    children.add(Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.0),
                            borderRadius: BorderRadius.circular(7.0),
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
                  EditorInputtedData.calendarSelectedDay=day;
                  EditorInputtedData.graphSelectedDay=day;
                  EditorInputtedData.selectedDay=day;
                  //_animationController.forward(from: 0.4);
                  expenseListKey.currentState.buildListTiles(day, events);
                },
                onDayLongPressed: (day, events){
                  EditorInputtedData.selectedDay=day;
                  onTapBottomNavigation(1);
                },
              ),
              ExpenseList(loadDB, expenseSetMapGetter, key: expenseListKey),
            ],
          )
      )
    );
  }
}

class ExpenseList extends StatefulWidget {
  ExpenseList(this.reLoadDB, this.expenseSetMapGetter, {Key key})
      : super(key: key);
  final Function reLoadDB;
  final Function expenseSetMapGetter;
  @override
  _ExpenseListState createState() =>
      new _ExpenseListState(reLoadDB, expenseSetMapGetter);
}

class _ExpenseListState extends State<ExpenseList> {
  _ExpenseListState(this.reLoadDB, this.expenseSetMapGetter);
  Function reLoadDB;
  final Function expenseSetMapGetter;
  DateTime selectedDay;
  List<Widget> dayExpensesTiles = [];

  void buildListTiles(DateTime selectedDay, List<dynamic> tileInfos) {
    List<Widget> listTiles = [];
    String inOrOutLabel;
    int oneDayIncome = 0;
    int oneDayOutgo = 0;
    tileInfos.forEach((element) {
      List<String> tileLabels = element;
      if (tileLabels[2] == 'true') {
        inOrOutLabel = '-';
        oneDayOutgo += int.parse(tileLabels[3]);
      } else {
        inOrOutLabel = "+";
        oneDayIncome += int.parse(tileLabels[3]);
      }
      listTiles.add(ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(tileLabels[1]),
            ),
            Expanded(
              flex: 1,
              child: Text(inOrOutLabel + tileLabels[3] + '円'),
            ),
          ],
        ),
        onTap: () {
          EditorInputtedData.outOrInBool = (tileLabels[2] == 'true');
          EditorInputtedData.inputPrice = int.parse(tileLabels[3]);
          if(EditorInputtedData.outOrInBool){
            EditorInputtedData.outSelectedCategory = tileLabels[1];
          }else{
            EditorInputtedData.inSelectedCategory = tileLabels[1];
          }
          EditorInputtedData.selectedDay = selectedDay;
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => ReEditExpensePage(tileLabels[0])))
              .then((value) {
            if (value) {
              reLoadDB(selectedDay).then((selectedDay) {
                List<dynamic> events = expenseSetMapGetter()[DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day)];
                events ??= [];
                buildListTiles(selectedDay, events);
              });
            }
            // buildListTiles(selectedDay,);
          });
        },
      ));
      listTiles.add(Divider());
    });
    var formatter = new DateFormat('yyyy/MM/dd(E)', "ja_JP");
    listTiles = <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(formatter.format(selectedDay)),
        ),
        color: Colors.grey[300],
      ),
          ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text('収入:+' + oneDayIncome.toString() + '円'),
                ),
                Expanded(
                  flex: 1,
                  child: Text('支出:-' + oneDayOutgo.toString() + '円'),
                ),
              ],
            ),
          ),
      Divider(color: Colors.black,)
        ] +
        listTiles;
    setState(() {
      dayExpensesTiles = listTiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: dayExpensesTiles,
    );
  }
}
