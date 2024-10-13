import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:mayer_wm/model/currency_entity.dart';
import 'package:mayer_wm/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/cupertino.dart';
import 'package:mayer_wm/views/purchase/purchase_return_detail.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';
import 'purchase_warehousing_detail.dart';

class PurchaseReturnPage extends StatefulWidget {
  var tranType;
  PurchaseReturnPage({Key ?key,@required this.tranType}) : super(key: key);

  @override
  _PurchaseReturnPageState createState() => _PurchaseReturnPageState(tranType);
}

class _PurchaseReturnPageState extends State<PurchaseReturnPage> {
  //搜索字段
  String keyWord = '';
  String startDate = '';
  String endDate = '';
  var isScan = false;
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  var tranType;
  static const scannerPlugin =
  const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription ?_subscription;
  var _code;

  List<dynamic> orderDate = [];
  final controller = TextEditingController();
  _PurchaseReturnPageState(tranType) {
    this.tranType = tranType;
  }
  @override
  void initState() {
    super.initState();
    DateTime dateTime = DateTime.now().add(Duration(days: -30));
    DateTime newDate = DateTime.now();
    _dateSelectText = "${dateTime.year}-${dateTime.month.toString().padLeft(2,'0')}-${dateTime.day.toString().padLeft(2,'0')} 00:00:00.000 - ${newDate.year}-${newDate.month.toString().padLeft(2,'0')}-${newDate.day.toString().padLeft(2,'0')} 00:00:00.000";
    EasyLoading.dismiss();
    /// 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
  }
  _initState() {
    isScan = false;
    EasyLoading.show(status: 'loading...');
    this.getOrderList();
    /// 开启监听
    _subscription = scannerPlugin
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }
  @override
  void dispose() {
    this.controller.dispose();
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }

  // 集合
  List hobby = [];

  getOrderList() async {
    EasyLoading.show(status: 'loading...');
    Map<String, dynamic> userMap = Map();
    var scanCode = keyWord.split(",");
    userMap['pageNum'] = 1;
    userMap['pageSize'] = 20;
    userMap['tranType'] = this.tranType;
    userMap['type'] = 2;
    if (this._dateSelectText != "") {
      this.startDate = this._dateSelectText.substring(0, 10);
      this.endDate = this._dateSelectText.substring(26, 36);

    }
    if(this.isScan){
      if (this.keyWord != '') {
        userMap['billNo'] = this.keyWord;
      }
    }else{
      if (this.keyWord != '') {
        userMap['billNo'] = this.keyWord;
      }else{
        userMap['startDate'] = startDate;
        userMap['endDate'] = endDate;
      }
    }
    this.isScan = false;
    String order = await CurrencyEntity.polling(userMap);
    if (!jsonDecode(order)['success']) {
      ToastUtil.errorDialog(context,
          jsonDecode(order)['msg']);
        return;
    }
    orderDate = [];
    orderDate = jsonDecode(order)['data']['list'];
    hobby = [];

    if (orderDate.length > 0) {
      orderDate.forEach((value) {
        List arr = [];
        arr.add({
          "title": "单据编号",
          "name": "FBillNo",
          "isHide": false,
          "value": {"label": value["FBillNo"], "value": value["FBillNo"]}
        });
        arr.add({
          "title": "采购组织",
          "name": "FPurchaseOrgId",
          "isHide": true,
          "value": {"label": "", "value": ""}

        });
        arr.add({
          "title": "单据日期",
          "name": "FDate",
          "isHide": false,
          "value": {"label": value["Fdate"], "value": value["Fdate"]}
        });
        arr.add({
          "title": "物料名称",
          "name": "FMaterial",
          "isHide": false,
           "value": {"label": value['FItemName'] + "- (" + value['FItemNumber'] + ")", "value": value["FItemNumber"]}
        });
        arr.add({
          "title": "规格型号",
          "name": "FMaterialIdFSpecification",
          "isHide": false,
          "value": {"label": value["FItemModel"], "value": value["FItemModel"]}
        });
        arr.add({
          "title": "单位名称",
          "name": "FUnitId",
          "isHide": false,
          "value": {"label": value["FUnitName"], "value": value["FUnitID"]}
        });
        arr.add({
          "title": "数量",
          "name": "FQty",
          "isHide": false,
          "value": {"label": value["FAuxQty"], "value": value["FAuxQty"]}
        });
        arr.add({
          "title": "供应商",
          "name": "FSupplierID",
          "isHide": false,
          "value": {"label": value["FSupplyName"], "value": value["FSupplyNumber"]}
        });
        hobby.add(arr);
      });
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
    } else {
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      ToastUtil.showInfo('无数据');
    }

  }

  void _onEvent(event) async {
    EasyLoading.show(status: 'loading...');

    if(event == ""){
      return;
    }

    _code = event;
    keyWord = _code;
    this.controller.text = _code;
      await this.getOrderList();
      print("ChannelPage: $event");

    EasyLoading.dismiss();
  }

  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
    });
  }

  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
        if (!this.hobby[i][j]['isHide']) {
          comList.add(
            Column(children: [
              Container(
                color: Colors.white,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PurchaseReturnDetail(
                              FBillNo: this.hobby[i][0]['value'],
                              tranType: this.tranType
                            // 路由参数
                          );
                        },
                      ),
                    ).then((data) {
                      //延时500毫秒执行
                      Future.delayed(
                          const Duration(milliseconds: 500),
                              () {
                            setState(() {
                              //延时更新状态
                              this._initState();
                            });
                          });
                    });
                  },
                  title: Text(this.hobby[i][j]["title"] +
                      '：' +
                      this.hobby[i][j]["value"]["label"].toString()),
                  trailing:
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    /* MyText(orderDate[i][j],
                        color: Colors.grey, rightpadding: 18),*/
                  ]),
                ),
              ),
              divider,
            ]),
          );
        }
      }
      tempList.add(
        SizedBox(height: 10),
      );
      tempList.add(
        Column(
          children: comList,
        ),
      );
    }
    return tempList;
  }

//扫码函数,最简单的那种
  Future scan() async {
    String cameraScanResult = await scanner.scan(); //通过扫码获取二维码中的数据
    getScan(cameraScanResult); //将获取到的参数通过HTTP请求发送到服务器
    print(cameraScanResult); //在控制台打印
  }

//用于验证数据(也可以在控制台直接打印，但模拟器体验不好)
  void getScan(String scan) async {
    _onEvent(scan);
  }

  String _dateSelectText = "";

  void showDateSelect() async {
    //获取当前的时间
    DateTime dateTime = DateTime.now().add(Duration(days: -30));
    DateTime now = DateTime.now();
    DateTime start = DateTime(dateTime.year, dateTime.month, dateTime.day);
    DateTime end = DateTime(now.year, now.month, now.day);
    var seDate = _dateSelectText.split(" - ");
    //显示时间选择器
    DateTimeRange? selectTimeRange = await showDateRangePicker(
      //语言环境
        locale: Locale("zh", "CH"),
        context: context,
        //开始时间
        firstDate: DateTime(now.year-3, now.month),
        //结束时间
        lastDate: DateTime(now.year, now.month+1),
        cancelText: "取消",
        confirmText: "确定",
        //初始的时间范围选择
        initialDateRange: DateTimeRange(start: DateTime.parse(seDate[0]), end: DateTime.parse(seDate[1])));
    //结果
    if(selectTimeRange != null){
      _dateSelectText = selectTimeRange.toString();
      //选择结果中的开始时间
      DateTime selectStart = selectTimeRange.start;
      //选择结果中的结束时间
      DateTime selectEnd = selectTimeRange.end;
    }
    setState(() {});
  }
  double hc_ScreenWidth() {
    return window.physicalSize.width / window.devicePixelRatio;
  }
  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      /*child: MaterialApp(
      title: "loging",*/
      child: Scaffold(
          /*floatingActionButton: FloatingActionButton(
            onPressed: scan,
            tooltip: 'Increment',
            child: Icon(Icons.filter_center_focus),
          ),*/
          appBar: AppBar(
            /* leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),*/
            title: Text("采购退货"),
            centerTitle: true,
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBarDelegate(
                  minHeight: 50, //收起的高度
                  maxHeight: 100, //展开的最大高度
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                this.showDateSelect();
                              },
                              child: Flex(
                                direction: Axis.horizontal,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        padding: EdgeInsets.all(6.0),
                                        height: 40.0,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "开始:" +
                                                (this._dateSelectText == ""
                                                    ? ""
                                                    : this
                                                    ._dateSelectText
                                                    .substring(0, 10)),
                                            style: TextStyle(
                                                color: Colors.white,
                                                decoration:
                                                TextDecoration.none))),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        padding: EdgeInsets.all(6.0),
                                        height: 40.0,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "结束:" +
                                                (this._dateSelectText == ""
                                                    ? ""
                                                    : this
                                                    ._dateSelectText
                                                    .substring(26, 36)),
                                            style: TextStyle(
                                                color: Colors.white,
                                                decoration:
                                                TextDecoration.none))),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 52.0,
                              child: new Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(children: [
                                  Card(
                                    child: new Container(
                                        width: hc_ScreenWidth() - 80,
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 6.0,
                                            ),
                                            Icon(
                                              Icons.search,
                                              color: Colors.grey,
                                            ),
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: TextField(
                                                  controller: this.controller,
                                                  decoration: new InputDecoration(
                                                      contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 12.0),
                                                      hintText: '输入关键字',
                                                      border: InputBorder.none),
                                                  onSubmitted: (value) {
                                                    setState(() {
                                                      this.keyWord = value;
                                                      this.getOrderList();
                                                    });
                                                  },
                                                  // onChanged: onSearchTextChanged,
                                                ),
                                              ),
                                            ),
                                            new IconButton(
                                              icon: new Icon(Icons.cancel),
                                              color: Colors.grey,
                                              iconSize: 18.0,
                                              onPressed: () {
                                                this.controller.clear();
                                                // onSearchTextChanged('');
                                              },
                                            ),
                                          ],
                                        )),
                                  ),
                                  new SizedBox(
                                    width: 60.0,
                                    height: 40.0,
                                    child: new RaisedButton(
                                      color: Colors.lightBlueAccent,
                                      child: new Text('搜索',style: TextStyle(fontSize: 14.0, color: Colors.white)),
                                      onPressed: (){
                                        setState(() {
                                          EasyLoading.show(status: 'loading...');
                                          this.keyWord = this.controller.text;
                                          this.getOrderList();
                                        });
                                      },
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: ListView(children: <Widget>[
                  Column(
                    children: this._getHobby(),
                  ),
                ]),
              ),
            ],
          )),
    );
    /*);*/
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Container child;
  final double minHeight;
  final double maxHeight;

  StickyTabBarDelegate(
      {required this.minHeight,
        required this.maxHeight,
        required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
