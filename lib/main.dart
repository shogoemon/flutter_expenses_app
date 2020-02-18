import 'package:flutter/material.dart';
import './ExpenseOrganizePage.dart';
import './EditExpense.dart';
import './ExpenseGraph.dart';

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
  String appBarLabel='';
  List<Widget> widgetPages=[];
  List<Widget> appbarIcons=[];
  Widget appbarIconData=Icon(Icons.swap_vertical_circle);
  bool appbarIconBool=true;

  @override
  void initState() {
    super.initState();
    pageCtrl=new PageController();
    if(this.currentPageNum==0){
      setState(() {
        this.appBarLabel='家計簿';
        appbarIcons=buildAppbarIcon();
      });
    }else{
      setState(() {
        this.appBarLabel='追加';
        appbarIcons=[];
      });
    }
    widgetPages=[
      ExpenseCalendarPage(),
      EditExpensePage(onTapBottomNavigation:onTapBottomNavigation),
    ];
    appbarIcons=buildAppbarIcon();
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    super.dispose();
  }

  void switchHomePage({bool isGraph}){
    if(isGraph){
      setState(() {
        widgetPages=[
          ExpenseGraphPage(),
          EditExpensePage(onTapBottomNavigation:onTapBottomNavigation)
        ];
      });
    }else{
      setState(() {
        widgetPages=[
          ExpenseCalendarPage(),
          EditExpensePage(onTapBottomNavigation:onTapBottomNavigation)
        ];
      });
    }
  }

  void switchAppbarIcon(){
    if(appbarIconBool){
        appbarIconData=Icon(Icons.calendar_today);
    }else{
        appbarIconData=Icon(Icons.swap_vertical_circle);
    }
    setState(() {
      appbarIcons=buildAppbarIcon();
    });
  }

  void onTapBottomNavigation(int page) {
    pageCtrl.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
  }

  List<Widget> buildAppbarIcon(){
    return [IconButton(
      icon: appbarIconData,
      onPressed: (){
        switchAppbarIcon();
        switchHomePage(isGraph:appbarIconBool);
        appbarIconBool=!appbarIconBool;
      },
    )];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarLabel),
        actions: appbarIcons,
      ),
      body: new PageView(
        physics:new NeverScrollableScrollPhysics(),
        controller: pageCtrl,
        onPageChanged: (int tappedPageNum){
          setState(() {
            this.currentPageNum=tappedPageNum;
          });
          if(this.currentPageNum==0){
            setState(() {
              this.appBarLabel='家計簿';
              appbarIcons=buildAppbarIcon();
            });
          }else{
            setState(() {
              this.appBarLabel='追加';
              appbarIcons=[];
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
