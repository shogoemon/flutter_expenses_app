import 'package:flutter/material.dart';
import './ExpenseCalendarPage.dart';
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
  Widget appbarIconData = Icon(Icons.data_usage);
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
                Divider(color: Colors.black,),
                SimpleDialogOption(
                  onPressed: (){
                    EditorInputtedData.ternNum=0;
                    switchAppbarLabel();
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
                Divider(color: Colors.black,),
                SimpleDialogOption(
                  onPressed: (){
                    EditorInputtedData.ternNum=1;
                    switchAppbarLabel();
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
                Divider(color: Colors.black,),
                SimpleDialogOption(
                  onPressed: (){
                    EditorInputtedData.ternNum=2;
                    switchAppbarLabel();
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
      appbarIconData = Icon(Icons.data_usage);
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
          switchAppbarLabel();
        },
      )
    ];
  }

  void switchAppbarLabel(){
    if(this.currentPageNum == 0){
      if(widgetPages.toString().indexOf('ExpenseGraphPage')==-1){
        setState(() {
          this.appBarLabel='家計簿';
        });
      }else{
        setState(() {
          switch(EditorInputtedData.ternNum){
            case 0:{
              this.appBarLabel='日別';
              break;}
            case 1:{
              this.appBarLabel='月別';
              break;}
            case 2:{
              this.appBarLabel='年別';
              break;}
          }
        });
      }
    }else{
      setState(() {
        this.appBarLabel = '追加';
      });
    }
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
          switchAppbarLabel();
          if (this.currentPageNum == 0) {
            setState(() {
              appbarIcons = buildAppbarIcon();
              if(widgetPages.toString().indexOf('ExpenseGraphPage')!=-1){
                leadingIcon=buildLeadingIcon();
              }
            });
          } else {
            setState(() {
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
