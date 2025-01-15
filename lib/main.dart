import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mayer_wm/model/login_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mayer_wm/utils/routes.dart';
import 'package:mayer_wm/views/login/login_page.dart';
import 'package:mayer_wm/views/index/index_page.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'http/httpUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mayer_wm/utils/toast_util.dart';
import 'package:mayer_wm/server/api.dart';
import 'package:mayer_wm/http/api_response.dart';
import 'model/authorize_entity.dart';
import 'model/currency_entity.dart';

import 'package:flutter_downloader/flutter_downloader.dart';

import 'model/submit_entity.dart';
const Color _primaryColor = Colors.blue;

void main(List<String> args) async {
  HttpUtils.init(
    baseUrl: "https://gzlcsign.ik3cloud.com/k3cloud",
  );
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true
  );
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  //不显示 debug标签

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //不显示 debug标签
      debugShowCheckedModeBanner: false,
      //当前运行环境配置
      locale: Locale("zh","CH"),
      //程序支持的语言环境配置
      supportedLocales: [Locale("zh","CH")],
      //Material 风格代理配置
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      onGenerateRoute: MenuRouts.getRouts(),
      theme: ThemeData(
        primaryColor: _primaryColor,
        // primaryTextTheme: ThemeData.dark().primaryTextTheme,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _primaryColor,
        ),
        appBarTheme: AppBarTheme(
          // appBar背景色
          // color: Colors.white,
          // 浅色背景，深色字体
          brightness: Brightness.light,
          // appBar文字主题
          // textTheme: TextTheme(
          //   headline6: TextStyle(color: Colors.black),
          // ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State {
  var _getaname = "";
  var _getpsw = "";
  var username = "";
  var password = "";
  var message = "";
  var isLogin = true;

  @override
  void initState() {
    super.initState();
    int count = 0;
    const period = const Duration(seconds: 1);
    print('currentTime=' + DateTime.now().toString());
    Timer.periodic(period, (timer) {
//到时回调
      print('afterTimer=' + DateTime.now().toString());
      count++;
      if (count >= 3) {
//取消定时器，避免无限回调
        timer.cancel();
        /*timer = null;*/
        toLoing();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  /**
   * 验证用户名
   */
  bool validateUserName(value) {
    // 正则匹配手机号
    /*RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');*/
    if (value == null) {
      return false;
    } else if (value.trim().length < 3 || value.trim().length > 16) {
      return false;
    }
    return true;
  }
  /**
   * 验证密码
   */
  bool validatePassWord(value) {
    if (value == null) {
      return false;
    } else if (value.trim().length < 6 || value.trim().length > 18) {
      return false;
    }
    return true;
  }
  //AlertDialog
  Future showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("温馨提示"),
          content: Text("$message"),
          actions: <Widget>[
            FlatButton(
              child: Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop();
                ToastUtil.showInfo('登录成功');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return IndexPage();
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  void toLoing() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString('FStaffNumber');
    password = sharedPreferences.getString('FPwd');
    if (validateUserName(username) &&
        validatePassWord(password) && isLogin) {
      Map<String, dynamic> map = Map();
      map['account'] = username;
      map['password'] =  password;
      map['type'] =  2;
      String entity = await LoginEntity.login(map);
      print(entity);
      print(jsonDecode(entity));
      var entityRes = jsonDecode(entity);
      if (entityRes['success']) {
        Map<String, dynamic> menuMap = Map();
        menuMap['id'] = "-1";
        menuMap['type'] = 2;
        String author = await SubmitEntity.permissions(menuMap);
        var authorRes = jsonDecode(author);
        if (authorRes['success']) {
          var parentData= List.from(authorRes['data']);
          for(var authorData in authorRes['data']){
            Map<String, dynamic> childMenuMap = Map();
            childMenuMap['id'] = authorData['id'].toString();
            childMenuMap['type'] = 2;
            String authorChild = await SubmitEntity.permissions(childMenuMap);
            var authorChildRes = jsonDecode(authorChild);
            if (authorChildRes['success']) {
              parentData.addAll(authorChildRes['data']);
            }else{
              ToastUtil.showInfo(authorChildRes['msg']);
            }
          }
          var listData = jsonEncode(parentData);
          sharedPreferences.setString('menuList', jsonEncode(parentData));
          sharedPreferences.setString('MenuPermissions', jsonEncode(entityRes['data']));
          ToastUtil.showInfo('登录成功');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return IndexPage();
              },
            ),
          );
        }else{
          ToastUtil.showInfo(authorRes['msg']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return LoginPage();
              },
            ),
          );
        }
      } else {
        ToastUtil.showInfo('登录失败，重新登录');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginPage();
            },
          ),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/splash.png"),
                fit: BoxFit.fill)));
    /* child: Image.network("https://i.postimg.cc/nh1TyksR/12133.png"),
       child:Image.network("https://i.postimg.cc/J4rL1ZpB/splash.png"),*/
  }
}
