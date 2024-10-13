import 'dart:convert';
import 'dart:math';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:mayer_wm/components/my_text.dart';
import 'package:mayer_wm/model/currency_entity.dart';
import 'package:mayer_wm/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qrscan/qrscan.dart' as scanner;

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class PackingPage extends StatefulWidget {
  PackingPage({Key? key}) : super(key: key);

  @override
  _PackingPageState createState() => _PackingPageState();
}

class _PackingPageState extends State<PackingPage> {
  //搜索字段
  String keyWord = '';
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  var warehouseName;
  var warehouseNumber;
  static const scannerPlugin =
  const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription? _subscription;
  var _code;
  var fSn = "";
  var fBarCodeList;
  var warehouseList = [];
  List<dynamic> warehouseListObj = [];
  List<dynamic> orderDate = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
    //_onEvent("1014");
    EasyLoading.dismiss();
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

  getOrderList(keyWord, batchNo, fSn) async {
    print(fSn);
    print("123333");
    EasyLoading.show(status: 'loading...');
    Map<String, dynamic> userMap = Map();
    if (keyWord != '') {
      userMap['name'] = this.keyWord;
    }
    userMap['pageNum'] = 1;
    userMap['pageSize'] = 50;
    String order = await CurrencyEntity.getInventory(userMap);
    if (jsonDecode(order)['success']) {
      orderDate = [];
      orderDate = jsonDecode(order)['data']['list'];
      print(orderDate);
      hobby = [];
      if (orderDate.length > 0) {
        for (var value in orderDate) {
          List arr = [];
          arr.add({
            "title": "编码",
            "name": "FMaterialFNumber",
            "value": {"label": value['FNumber'], "value": value['FNumber']}
          });
          arr.add({
            "title": "名称",
            "name": "FMaterialFName",
            "value": {"label": value['FName'], "value": value['FName']}
          });
          arr.add({
            "title": "规格",
            "name": "FMaterialIdFSpecification",
            "value": {"label": value['FItemModel'], "value": value['FItemModel']}
          });
          arr.add({
            "title": "仓库",
            "name": "FStockIdFName",
            "value": {"label": value['FStockName'], "value": value['FStockName']}
          });
          arr.add({
            "title": "库位",
            "name": "FStockIdFName",
            "value": {"label": value['FStockPlacename'], "value": value['FStockPlacename']}
          });
          arr.add({
            "title": "库存数量",
            "name": "FBaseQty",
            "value": {"label": value['FQty'], "value": value['FQty']}
          });
          arr.add({
            "title": "批号",
            "name": "FBatchNo",
            "value": {"label": value['FBatchNo'], "value": value['FBatchNo']}
          });
          hobby.add(arr);
        };
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
    }else{
      ToastUtil.errorDialog(context,
          jsonDecode(order)['msg']);
    }

  }

  void _onEvent(event) async {
    if (event == "") {
      return;
    }
    EasyLoading.show(status: 'loading...');
    Map<String, dynamic> userMap = Map();
    userMap['packNo'] = event;
    String order = await CurrencyEntity.getBoxList(userMap);
    if (jsonDecode(order)['success']) {
      orderDate = [];
      orderDate = jsonDecode(order)['data'];
      print(orderDate);
      hobby = [];
      if (orderDate.length > 0) {
        for (var value in orderDate) {
          List arr = [];
          arr.add({
            "title": "箱号",
            "name": "packNo",
            "value": {"label": value['packNo'], "value": value['packNo']}
          });
          arr.add({
            "title": "编码",
            "name": "FMaterialFNumber",
            "value": {"label": value['itemNumber'], "value": value['itemNumber']}
          });
          arr.add({
            "title": "名称",
            "name": "FMaterialFName",
            "value": {"label": value['itemName'], "value": value['itemName']}
          });
          arr.add({
            "title": "规格",
            "name": "FMaterialIdFSpecification",
            "value": {"label": value['model'], "value": value['model']}
          });
          arr.add({
            "title": "装箱日期",
            "name": "date",
            "value": {"label": value['date'], "value": value['date']}
          });
          arr.add({
            "title": "来源单据",
            "name": "FStockIdFName",
            "value": {"label": value['orderBillNo'], "value": value['orderBillNo']}
          });
          arr.add({
            "title": "数量",
            "name": "qty",
            "value": {"label": value['qty'], "value": value['qty']}
          });
          hobby.add(arr);
        };
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
    }else{
      ToastUtil.errorDialog(context,
          jsonDecode(order)['msg']);
    }
  }

  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
    });
  }

  Widget _item(title, var data, selectData, hobby, {String? label, var stock}) {
    if (selectData == null) {
      selectData = "";
    }
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () => data.length > 0
                ? _onClickItem(data, selectData, hobby,
                label: label, stock: stock)
                : {ToastUtil.showInfo('无数据')},
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              MyText(selectData.toString() == "" ? '暂无' : selectData.toString(),
                  color: Colors.grey, rightpadding: 18),
              rightIcon
            ]),
          ),
        ),
        divider,
      ],
    );
  }

  void _onClickItem(var data, var selectData, hobby,
      {String? label, var stock}) {
    Pickers.showSinglePicker(
      context,
      data: data,
      selectData: selectData,
      pickerStyle: DefaultPickerStyle(),
      suffix: label,
      onConfirm: (p) {
        print('longer >>> 返回数据：$p');
        print('longer >>> 返回数据类型：${p.runtimeType}');
        setState(() {
          if (hobby == 'warehouse') {
            warehouseName = p;
            var elementIndex = 0;
            data.forEach((element) {
              if (element == p) {
                warehouseNumber = warehouseListObj[elementIndex][2];
              }
              elementIndex++;
            });
            if (this.keyWord != '') {
              this.getOrderList(this.keyWord, "", "");
            }
          }
        });
      },
    );
  }

  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
        /*if (j == 5) {
          comList.add(
            Column(children: [
              Container(
                color: Colors.white,
                child: ListTile(
                    title: Text(this.hobby[i][j]["title"] +
                        '：' +
                        this.hobby[i][j]["value"]["label"].toString()),
                    trailing:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      new MaterialButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: new Text('查看'),
                        onPressed: () async {
                          await _showMultiChoiceModalBottomSheet(
                              context, this.hobby[i][j]["value"]["value"]);
                          setState(() {});
                        },
                      ),
                    ])),
              ),
              divider,
            ]),
          );
        } else {*/
        comList.add(
          Column(children: [
            Container(
              color: Colors.white,
              child: ListTile(
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
        /* }*/
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

  Widget _getModalSheetHeaderWithConfirm(String title,
      {required Function onCancel, required Function onConfirm}) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              onCancel();
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.blue,
              ),
              onPressed: () {
                onConfirm();
              }),
        ],
      ),
    );
  }

  Future<List<int>?> _showMultiChoiceModalBottomSheet(
      BuildContext context, List<dynamic> options) async {
    return showModalBottomSheet<List<int>?>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, setState) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
              ),
            ),
            height: MediaQuery.of(context).size.height / 2.0,
            child: Column(children: [
              _getModalSheetHeaderWithConfirm(
                'SN',
                onCancel: () {
                  Navigator.of(context).pop();
                },
                onConfirm: () async {
                  Navigator.of(context).pop(); /*selected.toList()*/
                },
              ),
              Divider(height: 1.0),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(options[index].toString()),
                      onTap: () {
                        setState(() {});
                      },
                    );
                  },
                  itemCount: options.length,
                ),
              ),
            ]),
          );
        });
      },
    );
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
            title: Text("装箱查询"),
            centerTitle: true,
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              /*SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBarDelegate(
                  minHeight: 50, //收起的高度
                  maxHeight: 60, //展开的最大高度
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Column(
                        children: [
                          Container(
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Container(
                                height: 52.0,
                                child: new Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: new Card(
                                      child: new Container(
                                        child: new Row(
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
                                                  decoration:
                                                  new InputDecoration(
                                                      contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 12.0),
                                                      hintText: '输入关键字',
                                                      border:
                                                      InputBorder.none),
                                                  onSubmitted: (value) {
                                                    setState(() {
                                                      this.keyWord = value;
                                                      this.getOrderList(
                                                          this.keyWord, "", "");
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
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),*/
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
      {required this.minHeight, required this.maxHeight, required this.child});

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
