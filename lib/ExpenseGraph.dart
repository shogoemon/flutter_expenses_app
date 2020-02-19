import 'package:flutter/material.dart';
import 'package:infinity_page_view/infinity_page_view.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

class ExpenseGraphPage extends StatefulWidget {
  @override
  _ExpenseGraphPageState createState() => new _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  String label;
  int itemCount;
  InfinityPageController infinityPageController;
  List<Map<String, dynamic>> loadedExpenseDB;
  Map<DateTime, List> expenseSetMap = {};


  @override
  void initState() {
    infinityPageController = new InfinityPageController(initialPage: 0);
    itemCount = 3;
    label = "1/" + itemCount.toString() + "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        GraphHeader(infinityPageController),
        SizedBox(
          height: 300.0,
          child: new InfinityPageView(
            pageSnapping: true,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: ExpenseGraph(),
              );
            },
            itemCount: itemCount,
            onPageChanged: (int index) {
              print(index.toString());
              setState(() {
                label = "${index + 1}" + "/" + itemCount.toString();
              });
            },
            controller: infinityPageController,
          ),
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
  GraphHeader(this.infinityPageCtrl);
  final InfinityPageController infinityPageCtrl;
  @override
  _GraphHeaderState createState()=> new _GraphHeaderState(infinityPageCtrl);
}

class _GraphHeaderState extends State<GraphHeader>{
  _GraphHeaderState(this.infinityPageCtrl);
  InfinityPageController infinityPageCtrl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: () {
                  infinityPageCtrl
                      .jumpToPage(infinityPageCtrl.page - 1);
                }),
            Expanded(
              child: Center(
                child: Text('aa'),
              ),
            ),
            IconButton(
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  infinityPageCtrl
                      .jumpToPage(infinityPageCtrl.page + 1);
                })
          ],
        )
    );
  }
}

class ExpenseGraph extends StatefulWidget{
  @override
  _ExpenseGraphState createState()=> new _ExpenseGraphState(_ExpenseGraphState._createRandomData());
}

class _ExpenseGraphState extends State<ExpenseGraph>{
  _ExpenseGraphState(this.seriesList, {this.animate});
  final List<charts.Series> seriesList;
  final bool animate;

  factory _ExpenseGraphState.withSampleData() {
    return new _ExpenseGraphState(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  factory _ExpenseGraphState.withRandomData() {
    return new _ExpenseGraphState(
        _createRandomData(),
      animate: false
    );
  }

  static List<charts.Series<LinearSales, int>> _createRandomData() {
    final random = new Random();

    final data = [
      new LinearSales(0, random.nextInt(100)),
      new LinearSales(1, random.nextInt(100)),
      new LinearSales(2, random.nextInt(100)),
      new LinearSales(3, random.nextInt(100)),
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END


  @override
  Widget build(BuildContext context) {
    return charts.PieChart(seriesList,
        animate: animate,
        defaultRenderer: new charts.ArcRendererConfig(arcWidth: 60));
  }

  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      new LinearSales(0, 100),
      new LinearSales(1, 75),
      new LinearSales(2, 25),
      new LinearSales(3, 5),
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
