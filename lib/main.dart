import 'package:flutter/material.dart';
import './ExpenseOrganizePage.dart';
import './EditExpense.dart';
import './ExpenseGraph.dart';
import './EditorState.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final expenseGraphKey = new GlobalKey<ExpenseGraphPageState>();
  PageController pageCtrl;
  int currentPageNum = 0;
  String appBarLabel = '';
  Widget leadingIcon;
  List<Widget> widgetPages = [];
  List<Widget> appbarIcons = [];
  Widget appbarIconData = Icon(Icons.swap_vertical_circle);
  bool appbarIconBool = true;

  @override
  void initState() {
    super.initState();
    pageCtrl = new PageController();
    if (this.currentPageNum == 0) {
      setState(() {
        this.appBarLabel = '家計簿';
      });
    } else {
      setState(() {
        this.appBarLabel = '追加';
      });
    }
    widgetPages = [
      ExpenseCalendarPage(onTapBottomNavigation),
      EditExpensePage(onTapBottomNavigation: onTapBottomNavigation),
    ];
    appbarIcons = buildAppbarIcon();
    leadingIcon=null;
  }

  Widget buildLeadingIcon() {
    return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              title: Text("表示切り替え"),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: (){
                    EditorInputtedData.ternNum=0;
                    expenseGraphKey.currentState.loadDB(EditorInputtedData.graphSelectedDay).then((value){
                      expenseGraphKey.currentState.setGraphAndList();
                      expenseGraphKey.currentState.setHeaderLabel();
                    });
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    title: Text("日別"),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: (){
                    EditorInputtedData.ternNum=1;
                    expenseGraphKey.currentState.loadDB(EditorInputtedData.graphSelectedDay).then((value){
                      expenseGraphKey.currentState.setGraphAndList();
                      expenseGraphKey.currentState.setHeaderLabel();
                    });
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    title: Text("月別"),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: (){
                    EditorInputtedData.ternNum=2;
                    expenseGraphKey.currentState.loadDB(EditorInputtedData.graphSelectedDay).then((value){
                      expenseGraphKey.currentState.setGraphAndList();
                      expenseGraphKey.currentState.setHeaderLabel();
                    });
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    title: Text("年別"),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    super.dispose();
  }

  void switchHomePage({bool isGraph}) {
    if (isGraph) {
      setState(() {
        widgetPages = [
          ExpenseGraphPage(key: expenseGraphKey,),
          EditExpensePage(onTapBottomNavigation: onTapBottomNavigation)
        ];
      });
    } else {
      setState(() {
        widgetPages = [
          ExpenseCalendarPage(onTapBottomNavigation),
          EditExpensePage(onTapBottomNavigation: onTapBottomNavigation)
        ];
      });
    }
  }

  void switchAppbarIcon() {
    if (appbarIconBool) {
      appbarIconData = Icon(Icons.calendar_today);
      leadingIcon=buildLeadingIcon();
    } else {
      appbarIconData = Icon(Icons.swap_vertical_circle);
      leadingIcon=null;
    }
    setState(() {
      appbarIcons = buildAppbarIcon();
    });
  }

  void onTapBottomNavigation(int page) {
    pageCtrl.jumpToPage(page);
  }

  List<Widget> buildAppbarIcon() {
    return [
      IconButton(
        icon: appbarIconData,
        onPressed: () {
          switchAppbarIcon();
          switchHomePage(isGraph: appbarIconBool);
          appbarIconBool = !appbarIconBool;
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leadingIcon,
        title: Text(appBarLabel),
        actions: appbarIcons,
      ),
      body: new PageView(
        physics: new NeverScrollableScrollPhysics(),
        controller: pageCtrl,
        onPageChanged: (int tappedPageNum) {
          setState(() {
            this.currentPageNum = tappedPageNum;
          });
          if (this.currentPageNum == 0) {
            setState(() {
              this.appBarLabel = '家計簿';
              appbarIcons = buildAppbarIcon();
              if(widgetPages.toString().indexOf('ExpenseGraphPage')!=-1){
                leadingIcon=buildLeadingIcon();
              }
            });
          } else {
            setState(() {
              this.appBarLabel = '追加';
              appbarIcons = [];
              leadingIcon=null;
            });
          }
        },
        children: widgetPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPageNum,
          onTap: onTapBottomNavigation,
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.home), title: new Text("ホーム")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.add), title: new Text("入力")),
          ]),
    );
  }
}
