import 'package:flutter/material.dart';
import './ExpenseOrganizePage.dart';
import './EditExpense.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageCtrl;
  int currentPageNum=0;

  @override
  void initState() {
    super.initState();
    pageCtrl=new PageController();
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    super.dispose();
  }

  void onTapBottomNavigation(int page) {
    pageCtrl.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("家計簿"),),
      body: new PageView(
        physics:new NeverScrollableScrollPhysics(),
        controller: pageCtrl,
        onPageChanged: (int tappedPageNum){
          setState(() {
            this.currentPageNum=tappedPageNum;
          });
        },
        children: <Widget>[
          ExpenseOrganizePage(),
          EditExpensePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentPageNum,
          onTap: onTapBottomNavigation,
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.home),
                title: new Text("ホーム")
            ),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.add),
                title: new Text("入力")
            ),
          ]
      ),
    );
  }
}

class ExpenseList extends StatefulWidget{
  @override
  _ExpenseListState createState()=> new _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList>{
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(title: Text('abc'),),
        ListTile(title: Text('abc'),),
      ],
    );
  }
}