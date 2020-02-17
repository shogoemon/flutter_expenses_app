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
  Map<DateTime, List> expenseSetList = {
    DateTime(2020, 1, 1): ['New Year\'s Day'],
    DateTime(2020, 1, 6): ['Epiphany'],
    DateTime(2020, 2, 14): ['Valentine\'s Day'],
  };

  @override
  void initState() {
    super.initState();
    calendarCtrl = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
    loadDB();
  }

  Future loadDB()async{
    await ExpensesTableDB.connectDB();

  }

  @override
  void dispose() {
    calendarCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    print('eventmakerBuilded');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: calendarCtrl.isSelected(date)
            ? Colors.brown[500]
            : calendarCtrl.isToday(date) ? Colors.brown[300] : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events[0]}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TableCalendar(
          onVisibleDaysChanged: (firstDay,lastDay,format){
            print(firstDay);
            expenseSetList.addAll({
              DateTime(2020, 3, 21): ['Easter Sunday'],
              DateTime(2020, 3, 28): ['Easter Monday'],
            });
            print('visiableDayChanged');
          },
          headerStyle:
              HeaderStyle(centerHeaderTitle: true, formatButtonVisible: false),
          calendarController: calendarCtrl,
          //locale: 'ja_JP',
          events: expenseSetList,
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
            print('todayDayBuilded!');
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
                      child: Text('合計 100円',
                          style: TextStyle().copyWith(fontSize: 12.0)),
                    )
                  ],
                ),
              )));
            }

            return children;
          }),
          onDaySelected: (day, events) {
            print(day.toString());
          },
        ),
        Expanded(
          child: ExpenseList(),
        )
      ],
    );
  }
}

class ExpenseList extends StatefulWidget {
  @override
  _ExpenseListState createState() => new _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('abc'),
        ),
        ListTile(
          title: Text('abc'),
        ),
      ],
    );
  }
}
