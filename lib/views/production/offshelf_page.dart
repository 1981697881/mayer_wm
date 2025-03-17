import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:decimal/decimal.dart';
import 'package:mayer_wm/model/currency_entity.dart';
import 'package:mayer_wm/model/submit_entity.dart';
import 'package:mayer_wm/utils/handler_order.dart';
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

class OffshelfPage extends StatefulWidget {
  var FBillNo;
  var tranType;

  OffshelfPage({Key? key, @required this.FBillNo, @required this.tranType})
      : super(key: key);

  @override
  _OffshelfPageState createState() =>
      _OffshelfPageState(FBillNo, tranType);
}

class _OffshelfPageState extends State<OffshelfPage> {
  var _remarkContent = new TextEditingController();
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();

  final _textNumber = TextEditingController();
  final _positionContent = TextEditingController();
  final _labelContent = TextEditingController();

  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String FNumber = '';
  String FDate = '';
  String locationPath = '';
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
  var checkData;
  var checkDataChild;

  var selectData = {
    DateMode.YMD: "",
  };
  var departmentList = [];
  var recommendedPathList = [];
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
  var sourceTranType;

  _OffshelfPageState(FBillNo, tranType) {
    this.tranType = tranType;
    if (FBillNo != null) {
      this.fBillNo = FBillNo['value'];
      this.sourceTranType = FBillNo['fTranType'];
      this.getOrderList();
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
    getStockList();
    //_onEvent("2502110083");
    // getBillNo();
    //_onEvent("2502191054");
    EasyLoading.dismiss();
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
    var resdata = json.encode([paramsMap]);
    String res = await CurrencyEntity.getRecomentSPPath([paramsMap]);
    if (jsonDecode(res)['success']) {
      setState(() {
        this.locationPath = jsonDecode(res)['msg'];
      });
    }else{
      ToastUtil.errorDialog(context,
          jsonDecode(res)['msg']);
    }
  }//历史库位
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
  //获取仓库
  getStockList() async {
    Map<String, dynamic> userMap = Map();
    String res = await CurrencyEntity.getStock(userMap);
    if (jsonDecode(res)['success']) {
      stockListObj = jsonDecode(res)['data'];
      stockListObj.forEach((element) {
        stockList.add(element['FName']);
      });
    }else{
      ToastUtil.errorDialog(context,
          jsonDecode(res)['msg']);
    }

  }
  //获取单号
  getBillNo() async {
    String res = await CurrencyEntity.getBillNo("24");
    if (jsonDecode(res)['success']) {
      setState(() {
        this.orderNo = jsonDecode(res)['data'];
      });
      return jsonDecode(res)['data'];
    }else{
      ToastUtil.errorDialog(context,
          jsonDecode(jsonDecode(res))['msg']);
      return "";
    }

  }

  void getWorkShop() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.getString('FWorkShopName') != null) {
        FName = sharedPreferences.getString('FWorkShopName');
        FNumber = sharedPreferences.getString('FWorkShopNumber');
        isScanWork = true;
      } else {
        isScanWork = false;
      }
    });
  }

  @override
  void dispose() {
    this._textNumber.dispose();
    this._positionContent.dispose();
    this._labelContent.dispose();
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription!.cancel();
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
    userMap['tranType'] = 72;
    userMap['type'] = 2;
    userMap['billNo'] = this.sourceTranType+'-'+this.fBillNo;
    String order = await CurrencyEntity.polling(userMap);
    if (!jsonDecode(order)['success']) {
      ToastUtil.errorDialog(context,
          jsonDecode(order)['msg']);
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
        List arr = [];
        arr.add({
          "title": "物料名称",
          "name": "FMaterial",
          "isHide": false,
          "value": {
            "label": value['FItemName'] + "- (" + value['FItemNumber'] + ")", "value": value["FItemNumber"],
            "barcode": [],
            "kingDeeCode": [],
            "scanCode": []
          }
        });
        arr.add({
          "title": "规格型号",
          "isHide": false,
          "name": "FMaterialIdFSpecification",
          "value": {"label": value['FItemModel'], "value": value['FItemModel']}
        });
        arr.add({
          "title": "重量",
          "name": "FUnitId",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "数量",
          "name": "FRealQty",
          "isHide": false,
          /*value[12]*/
          "value": {"label": "0", "value": "0"}
        });
        arr.add({
          "title": "仓库",
          "name": "FStockID",
          "isHide": true,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "批号",
          "name": "FLot",
          "isHide": true,
          "value": {"label": '', "value": ''}
        });
        arr.add({
          "title": "库位",
          "name": "FStockLocID",
          "isHide": true,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "操作",
          "name": "",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "备注",
          "name": "",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "实到数量",
          "name": "",
          "isHide": false,
          "value": {
            "label": double.parse(value["Fauxqty"]),
            "value": double.parse(value["Fauxqty"]),
            "rateValue": double.parse(value["Fauxqty"])
          } /*+value[12]*0.1*/
        });
        arr.add({
          "title": "最后扫描数量",
          "name": "FLastQty",
          "isHide": true,
          "value": {"label": "0", "value": "0","remainder": "0","representativeQuantity": "0"}
        });
        arr.add({
          "title": "明细",
          "name": "",
          "isHide": false,
          "value": {"label": "", "value": "", "itemList": []}
        });
        hobby.add(arr);
      });
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      await this.getRecomentSPPath();
      await this.getRecomentStockPlace();
    } else {
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      ToastUtil.showInfo('无数据');
    }
    //_onEvent("202407040436");
  }
  void _onEvent(event) async {
    if (event == "" || this.checkItem == "FScan") {
      return;
    }
    _code = event;
    this.getMaterialList("", _code, "");
    /* if (this._positionContent.text == '') {
      Map<String, dynamic> userMap = Map();
      userMap['number'] = _code;
      String order = await CurrencyEntity.geStockPlace(userMap);
      if (jsonDecode(order)['success']) {
        this._positionContent.text = _code;
        if(jsonDecode(order)['data'].length == 0){
          ToastUtil.showInfo("库位不存在");
        }
        //_onEvent("PAS1120070011;;;30;;1909374290;0;1");
      } else {
        ToastUtil.showInfo(jsonDecode(order)['msg']);
      }
    } else {
      if(_code == this._positionContent.text){
        this._positionContent.text = '';
        this._labelContent.text = '';
      }else{
        if(materialCode.indexOf(_code) == -1){
          await this.getMaterialList("", _code, this._positionContent.text);
        }else{
          ToastUtil.showInfo("该条码已被扫描");
        }

        //_onEvent("8011");
      }
    }*/
  }

  getMaterialList(barcodeData, code, str) async {
    Map<String, dynamic> userMap = Map();
    userMap['uuid'] = code;
    String order = await CurrencyEntity.barcodeScan(userMap);
    if(!jsonDecode(order)['success']){
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
      this.productNumber = materialDate['number'];
      this.productName = materialDate['name'];
      this.productSpecs = materialDate['model'];
      Map<String, dynamic> paramsMap = Map();
      //paramsMap['ftranType'] = this.tranType;
      paramsMap['finBillNo'] = "";
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
      var number = 0;
      var barCodeScan = materialDate;
      var barcodeNum = materialDate['quantity'].toString();
      var barcodeQuantity = materialDate['quantity'].toString();
      var msg = "";
      var orderIndex = 0;
      var fsn = (materialDate['defaultStockNumber']==null?"":materialDate['defaultStockNumber'])+"/"+(materialDate['location']==null?"":materialDate['location']);
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
        var residue = 0.0;
        //判断是否启用批号
        if (element[5]['isHide']) {
          //不启用
          if (element[0]['value']['value'] == barCodeScan['number'] && element[4]['value']['value'] == barCodeScan['defaultStockNumber'] && element[6]['value']['value'] == barCodeScan['location']) {
            if (element[0]['value']['barcode'].indexOf(code) == -1) {
              element[0]['value']['barcode'].add(code);
              //判断扫描数量是否大于单据数量
              if (double.parse(element[3]['value']['label']) >=
                  element[9]['value']['rateValue']) {
                continue;
              } else {
                //判断条码数量
                if ((double.parse(element[3]['value']['label']) +
                    double.parse(barcodeNum)) >
                    0 &&
                    double.parse(barcodeNum) > 0) {
                  if ((double.parse(element[3]['value']['label']) +
                      double.parse(barcodeNum)) >=
                      element[9]['value']['rateValue']) {
                    //判断条码是否重复
                    if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                      var item = code +
                          "-" +
                          (element[9]['value']['rateValue'] -
                              double.parse(element[3]['value']['label']))
                              .toStringAsFixed(2)
                              .toString() +
                          "-" +
                          fsn;
                      element[10]['value']['label'] = (element[9]['value']
                      ['label'] -
                          double.parse(element[3]['value']['label']))
                          .toString();
                      element[10]['value']['value'] = (element[9]['value']
                      ['label'] -
                          double.parse(element[3]['value']['label']))
                          .toString();
                      element[3]['value']['remainder'] = (
                          double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                          .toString();
                      element[3]['value']['representativeQuantity'] = barcodeQuantity;
                      barcodeNum = (double.parse(barcodeNum) -
                          (element[9]['value']['rateValue'] -
                              double.parse(element[3]['value']['label'])))
                          .toString();
                      element[3]['value']['label'] = (double.parse(
                          element[3]['value']['label']) +
                          (element[9]['value']['rateValue'] -
                              double.parse(element[3]['value']['label'])))
                          .toString();
                      element[3]['value']['value'] =
                      element[3]['value']['label'];
                      residue = element[9]['value']['rateValue'] -
                          double.parse(element[3]['value']['label']);
                      element[0]['value']['kingDeeCode'].add(item);
                      if(barCodeScan['isEnable'] == 1){
                        element[0]['value']['scanCode'].add(code);
                      }
                    }
                  } else {
                    //数量不超出
                    //判断条码是否重复
                    if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                      element[3]['value']['label'] =
                          (double.parse(element[3]['value']['label']) +
                              double.parse(barcodeNum))
                              .toString();
                      element[3]['value']['value'] =
                      element[3]['value']['label'];
                      var item = code +
                          "-" +
                          barcodeNum +
                          "-" +
                          fsn;
                      element[10]['value']['label'] = barcodeNum.toString();
                      element[10]['value']['value'] = barcodeNum.toString();
                      element[3]['value']['remainder'] = "0";
                      element[3]['value']['representativeQuantity'] = barcodeQuantity;
                      element[0]['value']['kingDeeCode'].add(item);
                      if(barCodeScan['isEnable'] == 1){
                        element[0]['value']['scanCode'].add(code);
                      }
                      barcodeNum =
                          (double.parse(barcodeNum) - double.parse(barcodeNum))
                              .toString();
                    }
                  }
                }
              }
            } else {
              ToastUtil.showInfo('该标签已扫描');
              break;
            }
          }
        } else {
          //启用批号
          if (element[0]['value']['value'] == barCodeScan['number'] && element[4]['value']['value'] == barCodeScan['defaultStockNumber'] && element[6]['value']['value'] == barCodeScan['location']) {
            if (element[0]['value']['barcode'].indexOf(code) == -1 ) {
              element[0]['value']['barcode'].add(code);
              if (element[5]['value']['value'] == barCodeScan['batchNo']) {
                //判断扫描数量是否大于单据数量
                if (double.parse(element[3]['value']['label']) >=
                    element[9]['value']['rateValue']) {
                  continue;
                } else {
                  //判断条码数量
                  if ((double.parse(element[3]['value']['label']) +
                      double.parse(barcodeNum)) >
                      0 &&
                      double.parse(barcodeNum) > 0) {
                    if ((double.parse(element[3]['value']['label']) +
                        double.parse(barcodeNum)) >=
                        element[9]['value']['rateValue']) {
                      //判断条码是否重复
                      if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                        var item = code +
                            "-" +
                            (element[9]['value']['rateValue'] -
                                double.parse(element[3]['value']['label']))
                                .toStringAsFixed(2)
                                .toString() +
                            "-" +
                            fsn;
                        element[10]['value']['label'] = (element[9]['value']
                        ['label'] -
                            double.parse(element[3]['value']['label']))
                            .toString();
                        element[10]['value']['value'] = (element[9]['value']
                        ['label'] -
                            double.parse(element[3]['value']['label']))
                            .toString();
                        element[3]['value']['remainder'] = (
                            double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                            .toString();
                        element[3]['value']['representativeQuantity'] = barcodeQuantity;
                        barcodeNum = (double.parse(barcodeNum) -
                            (element[9]['value']['rateValue'] -
                                double.parse(element[3]['value']['label'])))
                            .toString();
                        element[3]['value']['label'] = (double.parse(
                            element[3]['value']['label']) +
                            (element[9]['value']['rateValue'] -
                                double.parse(element[3]['value']['label'])))
                            .toString();
                        element[3]['value']['value'] =
                        element[3]['value']['label'];
                        residue = element[9]['value']['rateValue'] -
                            double.parse(element[3]['value']['label']);
                        element[0]['value']['kingDeeCode'].add(item);
                        if(barCodeScan['isEnable'] == 1){
                          element[0]['value']['scanCode'].add(code);
                        }
                      }
                    } else {
                      //数量不超出
                      //判断条码是否重复
                      if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                        element[3]['value']['label'] =
                            (double.parse(element[3]['value']['label']) +
                                double.parse(barcodeNum))
                                .toString();
                        element[3]['value']['value'] =
                        element[3]['value']['label'];
                        var item = code +
                            "-" +
                            barcodeNum +
                            "-" +
                            fsn;
                        element[10]['value']['label'] = barcodeNum.toString();
                        element[10]['value']['value'] = barcodeNum.toString();
                        element[3]['value']['remainder'] = "0";
                        element[3]['value']['representativeQuantity'] = barcodeQuantity;
                        element[0]['value']['kingDeeCode'].add(item);
                        if(barCodeScan['isEnable'] == 1){
                          element[0]['value']['scanCode'].add(code);
                        }
                        barcodeNum = (double.parse(barcodeNum) -
                            double.parse(barcodeNum))
                            .toString();
                      }
                    }
                  }
                }
              } else {
                if (element[5]['value']['value'] == "") {
                  element[5]['value']['label'] = barCodeScan['batchNo'] == null? "":barCodeScan['batchNo'];
                  element[5]['value']['value'] = barCodeScan['batchNo'] == null? "":barCodeScan['batchNo'];
                  //判断扫描数量是否大于单据数量
                  if (double.parse(element[3]['value']['label']) >=
                      element[9]['value']['rateValue']) {
                    continue;
                  } else {
                    //判断条码数量
                    if ((double.parse(element[3]['value']['label']) +
                        double.parse(barcodeNum)) >
                        0 &&
                        double.parse(barcodeNum) > 0) {
                      if ((double.parse(element[3]['value']['label']) +
                          double.parse(barcodeNum)) >=
                          element[9]['value']['rateValue']) {
                        //判断条码是否重复
                        if (element[0]['value']['scanCode'].indexOf(code) ==
                            -1) {
                          var item = code +
                              "-" +
                              (element[9]['value']['rateValue'] -
                                  double.parse(
                                      element[3]['value']['label']))
                                  .toStringAsFixed(2)
                                  .toString() +
                              "-" +
                              fsn;
                          element[10]['value']['label'] = (element[9]['value']
                          ['label'] -
                              double.parse(element[3]['value']['label']))
                              .toString();
                          element[10]['value']['value'] = (element[9]['value']
                          ['label'] -
                              double.parse(element[3]['value']['label']))
                              .toString();
                          element[3]['value']['remainder'] = (
                              double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                              .toString();
                          element[3]['value']['representativeQuantity'] = barcodeQuantity;
                          barcodeNum = (double.parse(barcodeNum) -
                              (element[9]['value']['rateValue'] -
                                  double.parse(
                                      element[3]['value']['label'])))
                              .toString();
                          element[3]['value']['label'] =
                              (double.parse(element[3]['value']['label']) +
                                  (element[9]['value']['rateValue'] -
                                      double.parse(
                                          element[3]['value']['label'])))
                                  .toString();
                          element[3]['value']['value'] =
                          element[3]['value']['label'];
                          residue = element[9]['value']['rateValue'] -
                              double.parse(element[3]['value']['label']);
                          element[0]['value']['kingDeeCode'].add(item);
                          if(barCodeScan['isEnable'] == 1){
                            element[0]['value']['scanCode'].add(code);
                          }
                        }
                      } else {
                        //数量不超出
                        //判断条码是否重复
                        if (element[0]['value']['scanCode'].indexOf(code) ==
                            -1) {
                          element[3]['value']['label'] =
                              (double.parse(element[3]['value']['label']) +
                                  double.parse(barcodeNum))
                                  .toString();
                          element[3]['value']['value'] =
                          element[3]['value']['label'];
                          var item = code +
                              "-" +
                              barcodeNum +
                              "-" +
                              fsn;
                          element[10]['value']['label'] = barcodeNum.toString();
                          element[10]['value']['value'] = barcodeNum.toString();
                          element[3]['value']['remainder'] = "0";
                          element[3]['value']['representativeQuantity'] = barcodeQuantity;
                          element[0]['value']['kingDeeCode'].add(item);
                          if(barCodeScan['isEnable'] == 1){
                            element[0]['value']['scanCode'].add(code);
                          }
                          barcodeNum = (double.parse(barcodeNum) -
                              double.parse(barcodeNum))
                              .toString();
                        }
                      }
                    }
                  }
                }
              }
            } else {
              ToastUtil.showInfo('该标签已扫描');
              break;
            }
          }
        }
      }
      if (number == 0 && this.fBillNo == "") {
        List arr = [];
        arr.add({
          "title": "物料名称",
          "name": "FMaterial",
          "isHide": false,
          "value": {
            "label": materialDate["name"] + "- (" + materialDate["number"] + ")",
            "value": materialDate["number"],
            "barcode": [code],
            "kingDeeCode": [code + "-" + barcodeNum + "-" + fsn],
            "scanCode": [code]
          }
        });
        arr.add({
          "title": "规格型号",
          "isHide": false,
          "name": "FMaterialIdFSpecification",
          "value": {"label": materialDate["model"], "value": materialDate["model"]}
        });
        arr.add({
          "title": "单位名称",
          "name": "FUnitId",
          "isHide": false,
          "value": {"label": materialDate["unitName"], "value": materialDate["unitNumber"]}
        });
        arr.add({
          "title": "数量",
          "name": "FRealQty",
          "isHide": false,
          /*value[12]*/
          "value": {"label": materialDate["quantity"].toString(), "value": materialDate["quantity"].toString(),"remainder": "0","representativeQuantity": materialDate["quantity"].toString()}
        });
        arr.add({
          "title": "仓库",
          "name": "FStockID",
          "isHide": false,
          "value": {"label": materialDate["defaultStockName"], "value": materialDate["defaultStockNumber"]}
        });
        arr.add({
          "title": "批号",
          "name": "FLot",
          "isHide": true,//!materialDate["batchManager"]
          "value": {
            "label": materialDate["batchNo"],
            "value": materialDate["batchNo"]
          }
        });
        arr.add({
          "title": "库位",
          "name": "FStockLocID",
          "isHide": false,
          "value": {"label": materialDate["location"] == null?"":materialDate["location"], "value": materialDate["location"] == null?"":materialDate["location"], "hide": false}
        });
        arr.add({
          "title": "操作",
          "name": "",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "库存单位",
          "name": "",
          "isHide": true,
          "value": {"label": materialDate["unitName"], "value": materialDate["unitNumber"]}
        });
        arr.add({
          "title": "实到数量",
          "name": "",
          "isHide": true,
          "value": {
            "label": "",
            "value": "",
            "rateValue": ""
          } /*+value[12]*0.1*/
        });
        arr.add({
          "title": "最后扫描数量",
          "name": "FLastQty",
          "isHide": true,
          "value": {"label": materialDate["quantity"].toString(), "value": materialDate["quantity"].toString(),"remainder": "0","representativeQuantity": materialDate["quantity"].toString()}
        });
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
  //调出弹窗 扫码
  void scanNumberDialog() {
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
                              if(double.parse(_FNumber) <= double.parse(this.hobby[checkData][checkDataChild]["value"]['representativeQuantity'])){
                                if (this.hobby[checkData][0]['value']['kingDeeCode'].length > 0) {
                                  var kingDeeCode = this.hobby[checkData][0]['value']['kingDeeCode'][this.hobby[checkData][0]['value']['kingDeeCode'].length - 1].split("-");
                                  var realQty = 0.0;
                                  this.hobby[checkData][0]['value']['kingDeeCode'].forEach((item) {
                                    var qty = item.split("-")[1];
                                    realQty += double.parse(qty);
                                  });
                                  realQty = realQty - double.parse(this.hobby[checkData][10]
                                  ["value"]["label"]);
                                  realQty = realQty + double.parse(_FNumber);
                                  this.hobby[checkData][3]["value"]["remainder"] = (Decimal.parse(this.hobby[checkData][3]["value"]["representativeQuantity"]) - Decimal.parse(_FNumber)).toString();
                                  this.hobby[checkData][3]["value"]["value"] = realQty.toString();
                                  this.hobby[checkData][3]["value"]["label"] = realQty.toString();
                                  this.hobby[checkData][checkDataChild]["value"]["label"] = _FNumber;
                                  this.hobby[checkData][checkDataChild]['value']["value"] = _FNumber;
                                } else {
                                  ToastUtil.showInfo('无条码信息，输入失败');
                                }
                              }else{
                                ToastUtil.showInfo('输入数量大于条码可用数量');
                              }
                            }else{
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
                          double.parse(this.hobby[i][j]["value"]["label"]).toInt().toString()+'剩余('+this.hobby[i][j]["value"]["remainder"].toString()+')'),
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
                                checkItem = 'FLastQty';
                                this.show = false;
                                checkData = i;
                                checkDataChild = j;
                                scanNumberDialog();
                                print(this.hobby[i][j]["value"]["label"]);
                                if (this.hobby[i][j]["value"]["label"] != 0) {
                                  this._textNumber.value =
                                      _textNumber.value.copyWith(
                                        text: this
                                            .hobby[i][j]["value"]["label"]
                                            .toString(),
                                      );
                                }
                                // _onEvent("8011");
                              },
                            ),
                          ])),
                ),
                divider,
              ]),
            );
          } else if (j == 4) {
            comList.add(
              _item('库别:', stockList, this.hobby[i][j]['value']['label'],
                  this.hobby[i][j],
                  stock: this.hobby[i]),
            );
          } else if (j == 6) {
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
                              icon: new Icon(Icons.filter_center_focus),
                              tooltip: '点击扫描',
                              onPressed: () {
                                this._textNumber.text = this
                                    .hobby[i][j]["value"]["label"]
                                    .toString();
                                this._FNumber = this
                                    .hobby[i][j]["value"]["label"]
                                    .toString();
                                checkItem = 'FPosition';
                                this.show = false;
                                checkData = i;
                                checkDataChild = j;
                                scanNumberDialog();
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
          } else if (j == 7) {
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
                            new FlatButton(
                              color: Colors.red,
                              textColor: Colors.white,
                              child: new Text('删除'),
                              onPressed: () {
                                this.hobby.removeAt(i);
                                setState(() {});
                              },
                            )
                          ])),
                ),
                divider,
              ]),
            );
          } else if ( j == 11) {
            var itemList = this.hobby[i][0]["value"]['kingDeeCode'];
            List<Widget> listTitle = [];
            var listTitleNum = 1;
            for(var dataItem in itemList){
              listTitle.add(
                ListTile(
                  title: Text(listTitleNum.toString() +
                      '：' +
                      dataItem.split('-')[0]),
                ),
              );
              listTitleNum++;
            }
            comList.add(
              Column(children: [
                ExpansionTile(
                  title: Text(this.hobby[i][j]["title"] +
                      '：' +
                      listTitle.length.toString()),
                  children: listTitle,
                ),
                divider,
              ]),
            );
          }else {
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
      barrierDismissible: true,
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
                              keyboardType: TextInputType.text,
                              controller: this._positionContent,
                              decoration: InputDecoration(hintText: "库别/库位"),
                              onSubmitted: (value) {
                                _onEvent(value);
                              },
                            ),
                          ]))),
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Card(
                          child: Column(children: <Widget>[
                            TextField(
                              style: TextStyle(color: Colors.black87),
                              keyboardType: TextInputType.text,
                              controller: this._labelContent,
                              decoration: InputDecoration(hintText: "商品"),
                              onSubmitted: (value) {
                                if (_positionContent.text != '') {
                                  _onEvent(value);
                                } else {
                                  ToastUtil.showInfo('请扫描库位或输入');
                                }
                              },
                            ),
                          ]))),
                  /*Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 8),
                    child: FlatButton(
                        color: Colors.grey[100],
                        onPressed: () {
                          // 关闭 Dialog
                          Navigator.pop(context);
                          setState(() {
                            this.hobby[checkData][checkDataChild]["value"]
                            ["label"] = _FNumber;
                            this.hobby[checkData][checkDataChild]['value']
                            ["value"] = _FNumber;
                          });
                        },
                        child: Text(
                          '完成',
                        )),
                  )*/
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
      Map<String, dynamic> Model = Map();
      Model['fpostyle'] = this.fOrgID;
      Model['fdeptId'] = this.departmentNumber;
      Model['fsupplyId'] = this.supplierNumber;
      var FEntity = [];
      var hobbyIndex = 0;
      this.hobby.forEach((element) {
        if (element[3]['value']['value'] != '0') {
          Map<String, dynamic> FEntityItem = Map();
          FEntityItem['fauxqty'] = element[3]['value']['value'];
          FEntityItem['fqty'] = element[3]['value']['value'];
          FEntityItem['fentryId'] = hobbyIndex+1;
          FEntityItem['finBillNo'] = this.orderNo;
          var kingDeeCode = element[0]['value']['kingDeeCode'];
          for (int subj = 0; subj < kingDeeCode.length; subj++) {
            Map<String, dynamic> subObj = Map();
            var itemCode = kingDeeCode[subj].split("-");
            subObj['type'] = 2;
            subObj['billNo'] = "";//this.sourceTranType+'-'+this.fBillNo+"-"+orderDate[hobbyIndex]['FEntryID']
            subObj['date'] = FDate;
            subObj['srcPositions'] = element[6]['value']['value'];
            subObj['srcStockNumber'] = element[4]['value']['value'];
            subObj['uuid'] = itemCode[0];
            FEntity.add(subObj);
          }
          //FEntity.add(FEntityItem);
        }
        hobbyIndex++;
      });
      if (FEntity.length == 0) {
        this.isSubmit = false;
        ToastUtil.showInfo('请输入数量');
        return;
      }
      Model['items'] = FEntity;
      /*Model['FDescription'] = this._remarkContent.text;*/
      var saveData = jsonEncode(Model);
      ToastUtil.showInfo('保存');
      String order = await SubmitEntity.underFrame(FEntity);
      var res = jsonDecode(order);
      print(res);
      if (res['success']) {
        //提交清空页面
        setState(() {
          this.hobby = [];
          this.orderDate = [];
          this.FBillNo = '';
          this.productNumber = '';
          this.productName = '';
          this.recommendedPathList = [];
          this.isSubmit = false;
          ToastUtil.showInfo('提交成功');
          //Navigator.of(context).pop("refresh");
        });
      } else {
        setState(() {
          this.isSubmit = false;
          ToastUtil.errorDialog(context,
              res['msg']);
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
            title: Text("下架"),
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
                          title: Text("单号：$fBillNo"),
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
