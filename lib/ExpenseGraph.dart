import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import './db/Database.dart';
import './EditorState.dart';
import './EditExpense.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';

class ExpenseGraphPage extends StatefulWidget {
  @override
  _ExpenseGraphPageState createState() => new _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  final categoryListKey = new GlobalKey<_CategoryListState>();
  final expenseGraphKey = new GlobalKey<_ExpenseGraphState>();
  List<Map<String, dynamic>> loadedExpenseList;
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
    oCategories=[];
    oTotalPrices=[];
    oPercentages=[];
    oTotalPrice=0;
    iCategories=[];
    iTotalPrices=[];
    iPercentages=[];
    iTotalPrice=0;
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
  }

  void setGraphAndList(){
    if(EditorInputtedData.outOrInBool){
      categoryListKey.currentState.buildCategoryTiles(
        categories: oCategories,
        totalPrices:oTotalPrices,
        percentages:oPercentages,
      );
      expenseGraphKey.currentState.setGraphData(
        categories: oCategories,
        totalPrices:oTotalPrices,
        percentages:oPercentages,
      );
    }else{
      categoryListKey.currentState.buildCategoryTiles(
        categories: iCategories,
        totalPrices:iTotalPrices,
        percentages:iPercentages,
      );
      expenseGraphKey.currentState.setGraphData(
        categories: iCategories,
        totalPrices:iTotalPrices,
        percentages:iPercentages,
      );
    }
  }

  @override
  void initState() {
    loadDB(EditorInputtedData.graphSelectedDay).then((value){
      setGraphAndList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        GraphHeader(setGraphAndList,loadDB),
        GraphInOrOutButton(setGraphAndList),
        SizedBox(
          height: 250.0,
          child: Center(
            child: ExpenseGraph(key: expenseGraphKey,),
          )
        ),
        Expanded(
          child: CategoryList(loadDB,key: categoryListKey,)
        )
      ],
    );
  }
}

class GraphHeader extends StatefulWidget{
  GraphHeader(this.setGraphAndList,this.reloadDB,{Key key}):super(key:key);
  final Function setGraphAndList;
  final Function reloadDB;
  @override
  _GraphHeaderState createState()=> new _GraphHeaderState(setGraphAndList,this.reloadDB);
}

class _GraphHeaderState extends State<GraphHeader>{
  _GraphHeaderState(this.setGraphAndList,this.reloadDB);
  Function setGraphAndList;
  Function reloadDB;
  String dateLabel='';

  Future setDateLabel()async{
    String formatSt;
    switch(EditorInputtedData.ternNum){
      case 0:{
        //１日間のデータ
        formatSt='yyyy/MM/dd(E)';
        break;
      }
      case 1:{
        //１月間のデータ
        formatSt='yyyy/MM';
        break;}
      case 2:{
        //１年間のデータ
        formatSt='yyyy';
        break;}
    }
    await initializeDateFormatting("ja_JP");
    var formatter = new DateFormat(formatSt, "ja_JP");
    setState(() {
      dateLabel = formatter.format(EditorInputtedData.graphSelectedDay);
    });
  }

  void changeDate(bool addDay)async{
    int durationTern;
    if(addDay){
      durationTern=1;
    }else{
      durationTern=-1;
    }
    switch(EditorInputtedData.ternNum){
      case 0:{
        //１日間のデータ
        EditorInputtedData.graphSelectedDay=
            EditorInputtedData.graphSelectedDay.add(new Duration(days: durationTern));
        break;
      }
      case 1:{
        //１月間のデータ
        DateTime oldDate=EditorInputtedData.graphSelectedDay;
        EditorInputtedData.graphSelectedDay=
        new DateTime(oldDate.year,oldDate.month+durationTern,1);
        break;}
      case 2:{
        //１年間のデータ
        DateTime oldDate=EditorInputtedData.graphSelectedDay;
        EditorInputtedData.graphSelectedDay=
        new DateTime(oldDate.year+durationTern,oldDate.month,oldDate.day);
        break;}
    }
  }


  @override
  void initState() {
    setDateLabel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: () async{
                  //日付を変えてデータをリロードして画面の更新
                  changeDate(false);
                  await setDateLabel();
                  reloadDB(EditorInputtedData.graphSelectedDay).then((value){
                    setGraphAndList();
                  });
                }),
            Expanded(
              child: Center(
                child: Text(dateLabel),
              ),
            ),
            IconButton(
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed: () async{
                  changeDate(true);
                  await setDateLabel();
                  reloadDB(EditorInputtedData.graphSelectedDay).then((value){
                    setGraphAndList();
                  });
                  //日付を変えてデータをリロードして画面の更新
                })
          ],
        )
    );
  }
}

class ExpenseGraph extends StatefulWidget{
  ExpenseGraph({Key key}) : super(key: key);
  @override
  _ExpenseGraphState createState()=> new _ExpenseGraphState(_ExpenseGraphState._createSampleData());
}

class _ExpenseGraphState extends State<ExpenseGraph>{
  _ExpenseGraphState(this.seriesList, {this.animate});
  List<charts.Series> seriesList=[];
  bool animate=true;
  static List<LinearExpenses> data;
  List<LinearExpenses> categoryData;

  factory _ExpenseGraphState.withSampleData() {
    return new _ExpenseGraphState(
      _createSampleData(),
      animate: false,
    );
  }

  void setGraphData({List<String> categories, List<int> totalPrices, List<int> percentages,}){
    bool noDataBool=(categoryData==null)||(categoryData==[]);
    categoryData=[];
    int index=0;
    percentages.forEach((percentage) {
      categoryData.add(
          LinearExpenses(index,percentage)
      );
      index++;
    });
    if(index!=0){
      animate=true;
      setState(() {
        seriesList=[
          charts.Series<LinearExpenses, int>(
            id: 'Sales',
            domainFn: (LinearExpenses sales, _){return sales.index;},
            measureFn: (LinearExpenses sales, _){return sales.sales;},
            data: categoryData,
            labelAccessorFn:(LinearExpenses row, _)=>categories[_],
          )
        ];
      });
    }else{
      animate=false;
      if(!noDataBool){
        setState(() {
          seriesList=_ExpenseGraphState._createSampleData();
        });
      }
    }
  }

  static List<charts.Series<LinearExpenses, int>> _createSampleData() {
    data = [
      new LinearExpenses(0, 100),
    ];

    return [
      new charts.Series<LinearExpenses, int>(
        id: 'Sales',
        domainFn: (LinearExpenses sales, _)=>sales.index,
        measureFn: (LinearExpenses sales, _)=>sales.sales,
        data: data,
        colorFn: (_, __)=>charts.MaterialPalette.blue.makeShades(10)[9],
        labelAccessorFn:(LinearExpenses row, _){
          return 'noData';
        },
      )
    ];
  }

  @override
  void initState() {
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
}

class LinearExpenses {
  final int index;
  final int sales;

  LinearExpenses(this.index, this.sales);
}

class CategoryList extends StatefulWidget{
  CategoryList(this.reLoadDB,{Key key}) : super(key: key);
  final Function reLoadDB;
  @override
  _CategoryListState createState()=> new _CategoryListState(reLoadDB);
}

class _CategoryListState extends State<CategoryList>{
  _CategoryListState(this.reLoadDB);
  final Function reLoadDB;
  List<Widget> categoryTiles=[];

  void buildCategoryTiles({List<String> categories, List<int> totalPrices, List<int> percentages,}){
    int index=0;
    List<Widget> listTiles = [];
    categories.forEach((category) {
      listTiles.add(ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(categories[index]),
            ),
            Expanded(
              flex: 1,
              child: Text(
                  '合計'+totalPrices[index].toString()+
                      '円('+percentages[index].toString()+
                      '%)'),
            ),
          ],
        ),
      ));
      index++;
    });
    setState(() {
      categoryTiles=listTiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: categoryTiles
    );
  }
}

class GraphInOrOutButton extends InOrOutButtonForm{
  GraphInOrOutButton(this.setGraphAndList);
  final Function setGraphAndList;
  @override
  _GraphInOrOutButtonState createState() => new _GraphInOrOutButtonState(setGraphAndList);
}

class _GraphInOrOutButtonState extends InOrOutButtonFormState{
  _GraphInOrOutButtonState(this.setGraphAndList);
  final Function setGraphAndList;
  @override
  void switchBool(bool whichButton){
    super.switchBool(whichButton);
    setGraphAndList();
  }
}
