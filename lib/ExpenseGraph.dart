import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import './db/Database.dart';
import './EditorState.dart';
import './EditExpense.dart';

class ExpenseGraphPage extends StatefulWidget {
  @override
  _ExpenseGraphPageState createState() => new _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  List<Map<String, dynamic>> loadedExpenseList;
  Map<DateTime, List> expenseSetMap = {};
  List<String> oCategories=[];
  List<int> oTotalPrices=[];
  List<int> oPercentages=[];
  int oTotalPrice=0;
  List<String> iCategories=[];
  List<int> iTotalPrices=[];
  List<int> iPercentages=[];
  int iTotalPrice=0;

  Future loadDB(DateTime selectedDay)async{
    await ExpensesTableDB.connectDB();
    expenseSetMap = {};
    switch(EditorInputtedData.ternNum){
      case 0:{
        //１日間のデータ
        loadedExpenseList = await ExpensesTableDB.getDataFromGraph(
            year:selectedDay.year.toString(),month:selectedDay.month.toString(),day:selectedDay.day.toString()
        );
        break;
      }
      case 1:{
        //１月間のデータ
        loadedExpenseList = await ExpensesTableDB.getDataFromGraph(
            year:selectedDay.year.toString(),month:selectedDay.month.toString()
        );
        break;}
      case 2:{
        //１年間のデータ
        loadedExpenseList = await ExpensesTableDB.getDataFromGraph(
            year:selectedDay.year.toString()
        );
        break;}
    }
    loadedExpenseList.forEach((element) {
      int price=int.parse(element['price']);

      switch(element['inOrOut']){
        case 'true':{
          oTotalPrice+=price;
          if(oCategories.indexOf(element['category'])==-1){
            oCategories.add(element['category']);
            oTotalPrices.add(price);
          }else{
            oTotalPrices[oTotalPrices.length-1]+=price;
          }
          break;
        }
        case "false":{
          iTotalPrice+=price;
          if(iCategories.indexOf(element['category'])==-1){
            iCategories.add(element['category']);
            iTotalPrices.add(price);
          }else{
            iTotalPrices[iTotalPrices.length-1]+=price;
          }
          break;
        }
      }
    });
    oTotalPrices.forEach((price) {
      oPercentages.add(((price/oTotalPrice)*100).round());
    });
    iTotalPrices.forEach((price) {
      iPercentages.add(((price/iTotalPrice)*100).round());
    });
    print(oPercentages);
    print(iPercentages);
  }

  @override
  void initState() {
    loadDB(EditorInputtedData.calendarSelectedDay);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        GraphHeader(),
        InOrOutButtonForm(),
        SizedBox(
          height: 250.0,
          child: Center(
            child: ExpenseGraph(),
          )
        ),
        Expanded(
          child: ListView(
            children: <Widget>[

            ],
          ),
        )
      ],
    );
  }
}

class GraphHeader extends StatefulWidget{
  @override
  _GraphHeaderState createState()=> new _GraphHeaderState();
}

class _GraphHeaderState extends State<GraphHeader>{

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: () {
                  //日付を変えてデータをリロードして画面の更新
                }),
            Expanded(
              child: Center(
                child: Text('aa'),
              ),
            ),
            IconButton(
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  //日付を変えてデータをリロードして画面の更新
                })
          ],
        )
    );
  }
}

class ExpenseGraph extends StatefulWidget{
  @override
  _ExpenseGraphState createState()=> new _ExpenseGraphState(_ExpenseGraphState._createSampleData());
}

class _ExpenseGraphState extends State<ExpenseGraph>{
  _ExpenseGraphState(this.seriesList, {this.animate});
  List<charts.Series> seriesList=[];
  bool animate=true;

  factory _ExpenseGraphState.withSampleData() {
    return new _ExpenseGraphState(
      _createSampleData(),
      animate: false,
    );
  }

  @override
  void initState() {
    //animate=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(
        seriesList,
        animate: animate,
        defaultRenderer: new charts.ArcRendererConfig(arcWidth: 50,
        arcRendererDecorators: [new charts.ArcLabelDecorator(
          labelPosition: charts.ArcLabelPosition.outside,
          outsideLabelStyleSpec: new charts.TextStyleSpec(fontSize: 20),
        )]),
    );
  }

  static List<charts.Series<LinearExpenses, int>> _createSampleData() {
    final data = [
      new LinearExpenses(0, 100),
      new LinearExpenses(1, 75),
      new LinearExpenses(2, 25),
      new LinearExpenses(3, 5),
      new LinearExpenses(5, 100),
      new LinearExpenses(6, 75),
      new LinearExpenses(7, 25),
      new LinearExpenses(8, 5),
    ];

    return [
      new charts.Series<LinearExpenses, int>(
        id: 'Sales',
//        colorFn: (_, __){
//          var colorData=charts.MaterialPalette.blue.makeShades(__+1)[__];
//          print(colorData.g);
//          return colorData;
//        },
        domainFn: (LinearExpenses sales, _){return sales.year;},
        measureFn: (LinearExpenses sales, _){return sales.sales;},
        data: data,
          labelAccessorFn:(LinearExpenses row, _){
          return 'aaaaaaaaaaa';
          },
      )
    ];
  }
}

class LinearExpenses {
  final int year;
  final int sales;

  LinearExpenses(this.year, this.sales);
}
