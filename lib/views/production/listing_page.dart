import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:decimal/decimal.dart';
import 'package:mayer_wm/model/currency_entity.dart';
import 'package:mayer_wm/model/submit_entity.dart';
import 'package:mayer_wm/utils/handler_order.dart';
import 'package:mayer_wm/utils/muittext.dart';
import 'package:mayer_wm/utils/refresh_widget.dart';
import 'package:mayer_wm/utils/text.dart';
import 'package:mayer_wm/utils/toast_util.dart';
import 'package:mayer_wm/views/login/login_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/more_pickers/init_data.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:flutter_pickers/time_picker/model/suffix.dart';
import 'dart:io';
import 'package:flutter_pickers/utils/check.dart';
import 'package:flutter/cupertino.dart';
import 'package:mayer_wm/components/my_text.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qrscan/qrscan.dart' as scanner;
class ListingPage extends StatefulWidget {
  var FBillNo;
  var tranType;

  ListingPage(
      {Key? key, @required this.FBillNo, @required this.tranType})
      : super(key: key);

  @override
  _ListingPageState createState() =>
      _ListingPageState(FBillNo, tranType);
}

class _ListingPageState
    extends State<ListingPage> {
  var _remarkContent = new TextEditingController();
  var _positionContent = new TextEditingController();
  var _labelContent = new TextEditingController();
  var _locationPathContent = new TextEditingController();
  var _recommendedPathContent = new TextEditingController();
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();

  final _textNumber = TextEditingController();
  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String FNumber = '';
  String FDate = '';
  String locationPath = '';
  String recommendedPath = '';
  String productNumber = '';
  String productName = '';
  String productSpecs = '';
  var supplierName;
  var supplierNumber;
  var departmentName;
  var departmentNumber;
  var typeName;
  var typeNumber;
  var show = false;
  var isSubmit = false;
  var isScanWork = false;
  var listingType = false;
  var checkData;
  var checkDataChild;

  var selectData = {
    DateMode.YMD: "",
  };
  var recommendedPathList = [];
  var departmentList = [];
  List<dynamic> departmentListObj = [];
  var supplierList = [];
  List<dynamic> supplierListObj = [];
  var stockList = [];
  var typeList = [];
  List<dynamic> typeListObj = [];
  List<dynamic> stockListObj = [];
  List<dynamic> orderDate = [];
  List<dynamic> materialDate = [];
  List<dynamic> collarOrderDate = [];
  List<dynamic> materialCode = [];
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  static const scannerPlugin =
  const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription? _subscription;
  var _code;
  var _FNumber;
  var fBillNo;

  var orderNo;
  var tranType;
  var fOrgID;
  var fBarCodeList;

  _ListingPageState(FBillNo, tranType) {
    this.tranType = tranType;
    if (FBillNo != null) {
      //this.fBillNo = '12333';
      this.fBillNo = FBillNo['value'];
      //this.getOrderList();
      isScanWork = true;
    } else {
      isScanWork = false;
      this.fBillNo = '';
    }
  }

  @override
  void initState() {
    super.initState();
    DateTime dateTime = DateTime.now();
    var nowDate = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    selectData[DateMode.YMD] = nowDate;

    /// 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
    //_onEvent("2408100015");
    //_onEvent("PGS1126050411;;;80;;1547418307;0;1");
    EasyLoading.dismiss();
  }

  @override
  void dispose() {
    this._textNumber.dispose();
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }
  //推荐路径
  getRecomentSPPath() async {
    Map<String, dynamic> paramsMap = Map();
    paramsMap['ftranType'] = this.tranType;
    paramsMap['finBillNo'] = this.fBillNo;
    List<dynamic> params = [];
    fNumber.forEach((value) {
      Map<String, dynamic> userMap = Map();
      userMap['fitemId'] = value;
      params.add(userMap);
    });
    paramsMap['items'] = params;
    String res = await CurrencyEntity.getRecomentSPPath([paramsMap]);
    if (jsonDecode(res)['success']) {
      setState(() {
        this.locationPath = jsonDecode(res)['msg'];
      });
    }else{
      ToastUtil.errorDialog(context,
          jsonDecode(res)['msg']);
    }
  }
  //历史库位
  getRecomentStockPlace() async {
    Map<String, dynamic> paramsMap = Map();
    paramsMap['ftranType'] = this.tranType;
    paramsMap['finBillNo'] = this.fBillNo;
    List<dynamic> params = [];
    fNumber.forEach((value) {
      Map<String, dynamic> userMap = Map();
      userMap['fitemId'] = value;
      params.add(userMap);
    });
    paramsMap['items'] = params;
    var resdata = json.encode([paramsMap]);
    String res = await CurrencyEntity.getRecomentStockPlace([paramsMap]);
    if (jsonDecode(res)['success']) {
      this.recommendedPathList = jsonDecode(res)['data'];
    }else{
      ToastUtil.errorDialog(context,
          jsonDecode(res)['msg']);
    }
  }
  // 查询数据集合
  List hobby = [];
  List fNumber = [];

  getOrderList() async {
    Map<String, dynamic> userMap = Map();
    print(fBillNo);
    userMap['pageNum'] = 1;
    userMap['pageSize'] = 100;
    userMap['tranType'] = this.tranType;
    userMap['type'] = 2;
    userMap['billNo'] = this.fBillNo;
    String order = await CurrencyEntity.polling(userMap);
    if (!jsonDecode(order)['success']) {
      ToastUtil.errorDialog(context, jsonDecode(order)['msg']);
      return;
    }
    orderDate = [];
    orderDate = jsonDecode(order)['data']['list'];
    FDate = formatDate(DateTime.now(), [
      yyyy,
      "-",
      mm,
      "-",
      dd,
    ]);
    selectData[DateMode.YMD] = formatDate(DateTime.now(), [
      yyyy,
      "-",
      mm,
      "-",
      dd,
    ]);
    hobby = [];
    if (orderDate.length > 0) {
      this.fOrgID = orderDate[0]["FPOStyle"];
      this.supplierName = orderDate[0]["FSupplyName"];
      this.supplierNumber = orderDate[0]["FSupplyNumber"];
      orderDate.forEach((value) {
        fNumber.add(value['FItemNumber']);
        /*List arr = [];
        arr.add({
          "title": "物料名称",
          "name": "FMaterial",
          "isHide": false,
          "value": {
             "value": {"label": value['FItemName'] + "- (" + value['FItemNumber'] + ")", "value": value["FItemNumber"]}
            "value": value['FItemNumber'],
            "barcode": [],
            "kingDeeCode": [],
            "scanCode": []
          }
        });
        arr.add({
          "title": "实收数量",
          "name": "FRealQty",
          "isHide": false,
          *//*value[12]*//*
          "value": {"label": "0", "value": "0"}
        });
        arr.add({
          "title": "实到数量",
          "name": "",
          "isHide": false,
          "value": {
            "label": value["Fauxqty"],
            "value": value["Fauxqty"],
            "rateValue": value["Fauxqty"]
          } *//*+value[12]*0.1*//*
        });
        hobby.add(arr);*/
      });
      /*await this.getRecomentSPPath();*/
      //await this.getRecomentStockPlace();
      /*setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });*/
    } else {
      /*setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });*/
      ToastUtil.showInfo('无数据');
    }

  }

  void _onEvent(event) async {
    this.listingType = false;
    if (event == "") {
      return;
    }
    _code = event;
    print(this._positionContent.text);
    Map<String, dynamic> goodsMap = Map();
    goodsMap['uuid'] = _code;
    String goodsOrder = await CurrencyEntity.barcodeScan(goodsMap);
    Map<String, dynamic> materialDate = Map();
    materialDate = jsonDecode(goodsOrder)['data'];
    if (materialDate != null && jsonDecode(goodsOrder)['success'] && this._positionContent.text == '') {
      if(materialDate["flag"] != 0){
        ToastUtil.showInfo('条码已失效，请检查');
        return;
      }
      this.listingType = true;
      await this.getMaterialList("", _code, "");
    }else{
      this.listingType = false;
      if (this._positionContent.text == '') {
        Map<String, dynamic> userMap = Map();
        userMap['number'] = _code;
        String order = await CurrencyEntity.geStockPlace(userMap);
        if (jsonDecode(order)['success']) {
          if(jsonDecode(order)['data'].length == 0){
            ToastUtil.showInfo("库位不存在");
          }else{
            this._positionContent.text = _code;
          }
          //_onEvent("PFS6181070000;;;250;;1758244124;0;2407100002");
        } else {
          ToastUtil.showInfo(jsonDecode(order)['msg']);
        }
      } else {
        if(_code == this._positionContent.text){
          this._positionContent.text = '';
          this._labelContent.text = '';
        }else{
          if(materialCode.indexOf(_code) == -1){
            await this.getMaterialList("", _code, "");
          }else{
            ToastUtil.showInfo("该条码已装扫描");
          }
          //_onEvent("8011");
        }
      }
    }
    /*this.getMaterialList("", _code, "");*/
  }

  getMaterialList(barcodeData, code, str) async {

    Map<String, dynamic> userMap = Map();
    userMap['uuid'] = code;
    String order = await CurrencyEntity.barcodeScan(userMap);
    if (!jsonDecode(order)['success']) {
      ToastUtil.showInfo(jsonDecode(order)['msg']);
      return;
    }
    Map<String, dynamic> materialDate = Map();
    materialDate = jsonDecode(order)['data'];
    FDate = formatDate(DateTime.now(), [
      yyyy,
      "-",
      mm,
      "-",
      dd,
    ]);
    selectData[DateMode.YMD] = formatDate(DateTime.now(), [
      yyyy,
      "-",
      mm,
      "-",
      dd,
    ]);
    if (materialDate != null) {
      if(materialDate["flag"] != 0){
        ToastUtil.showInfo('条码已失效，请检查');
        return;
      }
          Map<String, dynamic> paramsMap = Map();
          //paramsMap['ftranType'] = this.tranType;
          paramsMap['finBillNo'] = this.fBillNo;
          List<dynamic> params = [];
          params.add({"fitemId": materialDate['number']});
          paramsMap['items'] = params;
          var resdata = json.encode([paramsMap]);
          String res = await CurrencyEntity.getRecomentStockPlace([paramsMap]);
          if (jsonDecode(res)['success']) {
            this.recommendedPathList = jsonDecode(res)['data'];
          }else{
            this.recommendedPathList = [];
          }
          setState(() {
            this.productNumber = materialDate['number'];
            this.productName = materialDate['name'];
            this.productSpecs = materialDate['model'];
          });
          /*if (this.fBillNo == '') {
            this.fBillNo = materialDate["name"];
            return;
          }*/
          this._labelContent.text = code;
          var number = 0;
          var barCodeScan = materialDate;
          if(materialDate['quantity'] == null || materialDate['quantity']<0){
            ToastUtil.showInfo("条码无剩余数量");
            return;
          }
          if(listingType && (materialDate['location'] == null || materialDate['location'] == "")){
            ToastUtil.showInfo("扫描条码无库位信息");
            return;
          }
          var barcodeNum = materialDate['quantity'].toString();
          var barcodeQuantity = materialDate['quantity'].toString();
          var fsn = barcodeNum;
          /*var msg = "";
      var orderIndex = 0;
      for (var value in orderDate) {
        if (value['FItemNumber'] == materialDate['number']) {
          msg = "";
          if (fNumber.lastIndexOf(materialDate['number']) == orderIndex) {
            break;
          }
        } else {
          msg = '条码不在单据物料中';
        }
        orderIndex++;
      };
      if (msg != "") {
        ToastUtil.showInfo(msg);
        return;
      }
      for (var element in hobby) {
        if (element[0]['value']['value'] == barCodeScan['number']) {
          if (element[0]['value']['barcode'].indexOf(code) == -1) {
              element[0]['value']['barcode'].add(code);
            //判断扫描数量是否大于单据数量
            if (double.parse(element[1]['value']['value']) >=
                element[2]['value']['rateValue']) {
              continue;
            } else {
              var item = code +
                  "-" +
                  (element[9]['value']['rateValue'] -
                      double.parse(element[3]['value']['label']))
                      .toStringAsFixed(2)
                      .toString() +
                  "-" +
                  fsn;
              barcodeNum = (double.parse(barcodeNum) -
                  (element[9]['value']['rateValue'] -
                      double.parse(element[3]['value']['label'])))
                  .toString();
              element[3]['value']['label'] = ((double.parse(element[3]['value']['label'])+1).toString());
              element[3]['value']['value'] = element[3]['value']['label'];
              element[0]['value']['kingDeeCode'].add(item);
              element[0]['value']['scanCode'].add(code);
            }
          } else {
            ToastUtil.showInfo('该标签已扫描');
            break;
          }
        } else {
          ToastUtil.showInfo('物料信息不存在当前单据中');
          break;
        }
      }*/
          if (number == 0) {
            /* && this.fBillNo == ""*/
            List arr = [];
            if(listingType){
              arr.add({
                "title": "库位号",
                "name": "FMaterial",
                "isHide": false,
                "value": {
                  "label": materialDate['location'],
                  "value": materialDate['location'],
                  "barcode": [code],
                  "kingDeeCode": [code + "-" + barcodeNum + "-" + fsn],
                  "scanCode": [code]
                }
              });
              arr.add({
                "title": "条码",
                "name": "FRealQty",
                "isHide": false,
                "value": {
                  "label": code,
                  "value": code
                }
              });
              arr.add({
                "title": "上架数量",
                "name": "FRealQty",
                "isHide": false,
                "value": {
                  "label": barcodeNum,
                  "value": barcodeNum
                }
              });
              arr.add({
                "title": "加入数量",
                "name": "FRealQty",
                "isHide": false,
                "value": {
                  "label": 0,
                  "value": 0
                }
              });
              arr.add({
                "title": "剩余数量",
                "name": "FRealQty",
                "isHide": false,
                "value": {
                  "label": materialDate['remainQty'],
                  "value": materialDate['remainQty']
                }
              });
              materialCode.add(code);
            }else{
              Map<String, dynamic> inventoryMap = Map();
              inventoryMap['number'] = materialDate['number'];
              inventoryMap['spNumber'] = this._positionContent.text;
              inventoryMap['pageNum'] = 1;
              inventoryMap['pageSize'] = 50;
              var saveData = jsonEncode(inventoryMap);
              String inventoryOrder = await CurrencyEntity.getInventory(inventoryMap);
              if (jsonDecode(inventoryOrder)['success']) {
                if (jsonDecode(inventoryOrder)['data']['list'].length > 1) {
                  showDialog(context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("温馨提示"),
                          content: const Text("要上架的产编和库存产编不一致，是否继续？"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("取消"),
                            ),
                            TextButton(
                              onPressed: () async{
                                arr.add({
                                  "title": "库位号",
                                  "name": "FMaterial",
                                  "isHide": false,
                                  "value": {
                                    "label": this._positionContent.text,
                                    "value": this._positionContent.text,
                                    "barcode": [code],
                                    "kingDeeCode": [code + "-" + barcodeNum + "-" + fsn],
                                    "scanCode": [code]
                                  }
                                });
                                arr.add({
                                  "title": "条码",
                                  "name": "FRealQty",
                                  "isHide": false,
                                  "value": {
                                    "label": this._labelContent.text,
                                    "value": this._labelContent.text
                                  }
                                });
                                arr.add({
                                  "title": "上架数量",
                                  "name": "FRealQty",
                                  "isHide": false,
                                  "value": {
                                    "label": barcodeNum,
                                    "value": barcodeNum
                                  }
                                });
                                arr.add({
                                  "title": "加入数量",
                                  "name": "FRealQty",
                                  "isHide": false,
                                  "value": {
                                    "label": barcodeNum,
                                    "value": barcodeNum
                                  }
                                });
                                arr.add({
                                  "title": "剩余数量",
                                  "name": "FRealQty",
                                  "isHide": false,
                                  "value": {
                                    "label": materialDate['remainQty'],
                                    "value": materialDate['remainQty']
                                  }
                                });
                                materialCode.add(this._labelContent.text);
                              },
                              child: const Text("确定"),
                            ),
                          ],
                        );
                      }
                  );
                }else{
                  arr.add({
                    "title": "库位号",
                    "name": "FMaterial",
                    "isHide": false,
                    "value": {
                      "label": this._positionContent.text,
                      "value": this._positionContent.text,
                      "barcode": [code],
                      "kingDeeCode": [code + "-" + barcodeNum + "-" + fsn],
                      "scanCode": [code]
                    }
                  });
                  arr.add({
                    "title": "条码",
                    "name": "FRealQty",
                    "isHide": false,
                    "value": {
                      "label": this._labelContent.text,
                      "value": this._labelContent.text
                    }
                  });
                  arr.add({
                    "title": "上架数量",
                    "name": "FRealQty",
                    "isHide": false,
                    "value": {
                      "label": barcodeNum,
                      "value": barcodeNum
                    }
                  });
                  arr.add({
                    "title": "加入数量",
                    "name": "FRealQty",
                    "isHide": false,
                    "value": {
                      "label": barcodeNum,
                      "value": barcodeNum
                    }
                  });
                  arr.add({
                    "title": "剩余数量",
                    "name": "FRealQty",
                    "isHide": false,
                    "value": {
                      "label": materialDate['remainQty'],
                      "value": materialDate['remainQty']
                    }
                  });
                  materialCode.add(this._labelContent.text);
                }
              }else{
                ToastUtil.errorDialog(context,
                    jsonDecode(inventoryOrder)['msg']);
              }
            }
            hobby.add(arr);
          }
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

  Widget _dateItem(title, model) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () {
              _onDateClickItem(model);
            },
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              PartRefreshWidget(globalKey, () {
                //2、使用 创建一个widget
                return MyText(
                    (PicketUtil.strEmpty(selectData[model])
                        ? '暂无'
                        : selectData[model])!,
                    color: Colors.grey,
                    rightpadding: 18);
              }),
              rightIcon
            ]),
          ),
        ),
        divider,
      ],
    );
  }

  void _onDateClickItem(model) {
    Pickers.showDatePicker(
      context,
      mode: model,
      suffix: Suffix.normal(),
      // selectDate: PDuration(month: 2),
      minDate: PDuration(year: 2020, month: 2, day: 10),
      maxDate: PDuration(second: 22),
      selectDate: (FDate == '' || FDate == null
          ? PDuration(year: 2021, month: 2, day: 10)
          : PDuration.parse(DateTime.parse(FDate))),
      // minDate: PDuration(hour: 12, minute: 38, second: 3),
      // maxDate: PDuration(hour: 12, minute: 40, second: 36),
      onConfirm: (p) {
        print('longer >>> 返回数据：$p');
        setState(() {
          switch (model) {
            case DateMode.YMD:
              selectData[model] = formatDate(
                  DateFormat('yyyy-MM-dd')
                      .parse('${p.year}-${p.month}-${p.day}'),
                  [
                    yyyy,
                    "-",
                    mm,
                    "-",
                    dd,
                  ]);
              FDate = formatDate(
                  DateFormat('yyyy-MM-dd')
                      .parse('${p.year}-${p.month}-${p.day}'),
                  [
                    yyyy,
                    "-",
                    mm,
                    "-",
                    dd,
                  ]);
              break;
          }
        });
      },
      // onChanged: (p) => print(p),
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
          if (hobby == 'supplier') {
            supplierName = p;
            var elementIndex = 0;
            data.forEach((element) {
              if (element == p) {
                supplierNumber = supplierListObj[elementIndex]['FNumber'];
              }
              elementIndex++;
            });
          } else if (hobby == 'department') {
            departmentName = p;
            var elementIndex = 0;
            data.forEach((element) {
              if (element == p) {
                departmentNumber = departmentListObj[elementIndex]['FNumber'];
              }
              elementIndex++;
            });
          } else {
            setState(() {
              hobby['value']['label'] = p;
            });
            var elementIndex = 0;
            data.forEach((element) {
              if (element == p) {
                hobby['value']['value'] = stockListObj[elementIndex]['FNumber'];
              }
              elementIndex++;
            });
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
        if (!this.hobby[i][j]['isHide']) {
          if (j == 3) {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                      title: Text(this.hobby[i][j]["title"] +
                          '：' +
                          this.hobby[i][j]["value"]["label"].toString()),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: new Icon(Icons.mode_edit),
                              tooltip: '点击扫描',
                              onPressed: () {
                                this._textNumber.text = this
                                    .hobby[i][j]["value"]["label"]
                                    .toString();
                                this._FNumber = this
                                    .hobby[i][j]["value"]["label"]
                                    .toString();
                                checkItem = 'FNumber';
                                this.show = false;
                                checkData = i;
                                checkDataChild = j;
                                scanDialog();
                                print(this.hobby[i][j]["value"]["label"]);
                                if (this.hobby[i][j]["value"]["label"] != 0) {
                                  this._textNumber.value =
                                      _textNumber.value.copyWith(
                                        text: this
                                            .hobby[i][j]["value"]["label"]
                                            .toString(),
                                      );
                                }
                              },
                            ),
                          ])),
                ),
                divider,
              ]),
            );
          }else{
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
          }
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

  //调出弹窗 扫码
  void scanDialog() {
    showDialog<Widget>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  /*  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('输入数量',
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.none)),
                  ),*/
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Card(
                          child: Column(children: <Widget>[
                            TextField(
                              style: TextStyle(color: Colors.black87),
                              keyboardType: TextInputType.number,
                              controller: this._textNumber,
                              decoration: InputDecoration(hintText: "输入"),
                              onChanged: (value) {
                                setState(() {
                                  this._FNumber = value;
                                });
                              },
                            ),
                          ]))),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 8),
                    child: FlatButton(
                        color: Colors.grey[100],
                        onPressed: () {
                          // 关闭 Dialog
                          Navigator.pop(context);
                          setState(() {
                            if (checkItem == "FLastQty") {
                              if (double.parse(_FNumber) <=
                                  double.parse(this.hobby[checkData]
                                  [checkDataChild]["value"]
                                  ['representativeQuantity'])) {
                                if (this
                                    .hobby[checkData][0]['value']
                                ['kingDeeCode']
                                    .length >
                                    0) {
                                  var kingDeeCode = this
                                      .hobby[checkData][0]['value']
                                  ['kingDeeCode'][this
                                      .hobby[checkData][0]['value']
                                  ['kingDeeCode']
                                      .length -
                                      1]
                                      .split("-");
                                  var realQty = 0.0;
                                  this
                                      .hobby[checkData][0]['value']
                                  ['kingDeeCode']
                                      .forEach((item) {
                                    var qty = item.split("-")[1];
                                    realQty += double.parse(qty);
                                  });
                                  realQty = realQty -
                                      double.parse(this.hobby[checkData][10]
                                      ["value"]["label"]);
                                  realQty = realQty + double.parse(_FNumber);
                                  this.hobby[checkData][10]["value"]
                                  ["remainder"] = (Decimal.parse(
                                      this.hobby[checkData][10]["value"]
                                      ["representativeQuantity"]) -
                                      Decimal.parse(_FNumber))
                                      .toString();
                                  this.hobby[checkData][3]["value"]["value"] =
                                      realQty.toString();
                                  this.hobby[checkData][3]["value"]["label"] =
                                      realQty.toString();
                                  this.hobby[checkData][checkDataChild]["value"]
                                  ["label"] = _FNumber;
                                  this.hobby[checkData][checkDataChild]['value']
                                  ["value"] = _FNumber;
                                  this.hobby[checkData][0]['value']
                                  ['kingDeeCode'][this
                                      .hobby[checkData][0]['value']
                                  ['kingDeeCode']
                                      .length -
                                      1] =
                                      kingDeeCode[0] +
                                          "-" +
                                          _FNumber +
                                          "-" +
                                          kingDeeCode[2];
                                } else {
                                  ToastUtil.showInfo('无条码信息，输入失败');
                                }
                              } else {
                                ToastUtil.showInfo('输入数量大于条码可用数量');
                              }
                            } else {
                              this.hobby[checkData][checkDataChild]["value"]
                              ["label"] = _FNumber;
                              this.hobby[checkData][checkDataChild]['value']
                              ["value"] = _FNumber;
                            }
                          });
                        },
                        child: Text(
                          '确定',
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ).then((val) {
      print(val);
    });
  }

  //保存
  saveOrder() async {
    //获取登录信息
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var menuData = sharedPreferences.getString('MenuPermissions');
    var userId = jsonDecode(menuData)['userId'];
    if (this.hobby.length > 0) {
      setState(() {
        this.isSubmit = true;
      });
      var FEntity = [];
      var hobbyIndex = 0;
      this.hobby.forEach((element) {
        Map<String, dynamic> FEntityItem = Map();
        FEntityItem['uuid'] = element[0]['value']['scanCode'][0];
        FEntityItem['positions'] = element[0]['value']['value'];
        FEntityItem['type'] = 1;
        /*var fSerialSub = [];
        var fSerialSubIndexOf = [];
        var kingDeeCode = element[0]['value']['kingDeeCode'];
        for (int subj = 0; subj < kingDeeCode.length; subj++) {
          Map<String, dynamic> subObj = Map();
          var itemCode = kingDeeCode[subj].split("-");
          if (fSerialSubIndexOf.indexOf(itemCode[0]) == -1) {
            subObj['uuid'] = itemCode[0];
            subObj['quantity'] = itemCode[1];
            subObj['packNum'] = itemCode[2];
            fSerialSubIndexOf.add(itemCode[0]);
            fSerialSub.add(subObj);
          } else {
            for (var sub in fSerialSub) {
              if (sub['uuid'] == itemCode[0]) {
                sub['quantity'] = (Decimal.parse(sub['quantity']) +
                        Decimal.parse(itemCode[1]))
                    .toString();
              }
            }
          }
        }
        FEntityItem['barcodeList'] = fSerialSub;*/
        FEntity.add(FEntityItem);
        hobbyIndex++;
      });
      /*Model['FDescription'] = this._remarkContent.text;*/
      var saveData = jsonEncode(FEntity);
      ToastUtil.showInfo('保存');
      String order = await SubmitEntity.onFrame(FEntity);
      var res = jsonDecode(order);
      print(res);
      if (res['success']) {
        //提交清空页面
        setState(() {
          this.hobby = [];
          this.orderDate = [];
          this.FBillNo = '';
          ToastUtil.showInfo('提交成功');
          Navigator.of(context).pop("refresh");
        });
      } else {
        setState(() {
          this.isSubmit = false;
          ToastUtil.errorDialog(context, res['msg']);
        });
      }
    } else {
      ToastUtil.showInfo('无提交数据');
    }
  }

  /// 确认提交提示对话框
  Future<void> _showSumbitDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("是否提交"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('不了'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                  saveOrder();
                },
              )
            ],
          );
        });
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
  Future<List<int>?> _showModalBottomSheet(
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
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            height: MediaQuery.of(context).size.height / 2.0,
            child: Column(children: [
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(options[index]),//+';仓库:'+options[index][3]+';数量:'+options[index][4].toString()+';包装规格:'+options[index][6]
                          onTap: () {

                            // Do something
                          },
                        ),
                        Divider(height: 1.0),
                      ],
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
      child: Scaffold(
        /*floatingActionButton: FloatingActionButton(
            onPressed: scan,
            tooltip: 'Increment',
            child: Icon(Icons.filter_center_focus),
          ),*/
          appBar: AppBar(
            title: Text("上架"),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop("refresh");
                }),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView(children: <Widget>[
                  /*Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          *//* title: TextWidget(FBillNoKey, '生产订单：'),*//*
                          title: Text("到货单号：$fBillNo"),
                        ),
                      ),
                      divider,
                    ],
                  ),*/
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          /* title: TextWidget(FBillNoKey, '生产订单：'),*/
                          title: TextField(
                            decoration: InputDecoration(
                                labelText: "库位号", border: OutlineInputBorder()),
                            controller: this._positionContent,
                            //改变回调
                            onChanged: (value) {
                              setState(() {

                              });
                            },
                            onSubmitted: (value) {
                              _onEvent(value);
                            },
                          ),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: TextField(
                            decoration: InputDecoration(
                                labelText: "商品条码",
                                border: OutlineInputBorder()),
                            controller: this._labelContent,
                            //改变回调
                            onChanged: (value) {
                              setState(() {
                                _labelContent.value = TextEditingValue(
                                    text: value,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: value.length)));
                              });
                            },
                            onSubmitted: (value) {
                              if (_positionContent.text != '') {
                                _onEvent(value);
                              } else {
                                ToastUtil.showInfo('请扫描库位或输入');
                              }
                            },
                          ),
                        ),
                      ),
                      divider,
                    ],
                  ),

                  /*Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                            title: Text("历史库位："),
                            trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                              new MaterialButton(
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: new Text('查看'),
                                onPressed: () async {
                                  await _showModalBottomSheet(
                                      context, this.recommendedPathList);
                                },
                              ),
                            ])
                        ),
                      ),
                      divider,
                    ],
                  ),*/
                  /*Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: TextField(
                            //最多输入行数
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: "历史库位",
                              //给文本框加边框
                            ),
                            enabled: false,
                            controller: this._locationPathContent,
                            //改变回调
                            onChanged: (value) {
                              setState(() {
                                _locationPathContent.value = TextEditingValue(
                                    text: value,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: value.length)));
                              });
                            },
                          ),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: TextField(
                            //最多输入行数
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: "路径推荐",
                              //给文本框加边框
                            ),
                            enabled: false,
                            controller: this._recommendedPathContent,
                            //改变回调
                            onChanged: (value) {
                              setState(() {
                                _recommendedPathContent.value = TextEditingValue(
                                    text: value,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: value.length)));
                              });
                            },
                          ),
                        ),
                      ),
                      divider,
                    ],
                  ),*/
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("产编：$productNumber"),
                        ),
                      ),
                      divider,
                    ],
                  ),Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("品名：$productName"),
                        ),
                      ),
                      divider,
                    ],
                  ),Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("规格：$productSpecs"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("库存库位：$recommendedPathList"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  /* _dateItem('日期：', DateMode.YMD),

                  _item('部门', this.departmentList, this.departmentName,
                      'department'),*/
                  /*  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: TextField(
                            //最多输入行数
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: "路径推荐",
                              //给文本框加边框
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                            controller: this._remarkContent,
                            //改变回调
                            onChanged: (value) {
                              setState(() {
                                _remarkContent.value = TextEditingValue(
                                    text: value,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: value.length)));
                              });
                            },
                          ),
                        ),
                      ),
                      divider,
                    ],
                  ),*/
                  Column(
                    children: this._getHobby(),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text("保存"),
                        color: this.isSubmit
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async =>
                        this.isSubmit ? null : _showSumbitDialog(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
