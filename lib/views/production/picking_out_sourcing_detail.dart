import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:decimal/decimal.dart';
import 'package:decimal/decimal.dart';
import 'package:mayer_wm/model/currency_entity.dart';
import 'package:mayer_wm/model/submit_entity.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mayer_wm/components/my_text.dart';
import 'package:qrscan/qrscan.dart' as scanner;
final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class PickingOutSourcingDetail extends StatefulWidget {
  var FBillNo;
  var tranType;

  PickingOutSourcingDetail(
      {Key? key,
        @required this.FBillNo,
        @required this.tranType})
      : super(key: key);

  @override
  _PickingOutSourcingDetailState createState() => _PickingOutSourcingDetailState(
      FBillNo, tranType);
}

class _PickingOutSourcingDetailState extends State<PickingOutSourcingDetail> {
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  GlobalKey<TextWidgetState> FBillNoKey = GlobalKey();
  GlobalKey<TextWidgetState> FSaleOrderNoKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> FPrdOrgIdKey = GlobalKey();

  final _textNumber = TextEditingController();
  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String FNumber = '';
  String FDate = '';
  var show = false;
  var isScanWork = false;
  var isSubmit = false;
  var departmentName;
  var departmentNumber;
  var checkData;
  var fOrgID;
  var checkDataChild;
  var isTurnoff;
  var departmentList = [];
  List<dynamic> departmentListObj = [];
  //仓库
  var stockList = [];
  List<dynamic> stockListObj = [];
  var selectData = {
    DateMode.YMDHMS: '',
  };
  List<dynamic> orderDate = [];
  List<dynamic> materialDate = [];
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  static const scannerPlugin =
  const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription? _subscription;
  var _code;
  var _FNumber;
  var fBillNo;
  var fBarCodeList;
  var tranType;
  var orderNo;
  _PickingOutSourcingDetailState(FBillNo, tranType) {
    if (FBillNo != null) {
      this.fBillNo = FBillNo['value'];
      this.tranType = tranType;
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
    EasyLoading.dismiss();

    /// 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
    /* getWorkShop();*/
    getDepartmentList();
    getStockList();
    getBillNo();
  }

  //获取部门
  getDepartmentList() async {
    Map<String, dynamic> userMap = Map();
    String res = await CurrencyEntity.getDept(userMap);
    if (jsonDecode(res)['success']) {
      departmentListObj = jsonDecode(res)['data'];
      departmentListObj.forEach((element) {
        departmentList.add(element['FName']);
      });
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
  }//获取单号
  getBillNo() async {
    String res = await CurrencyEntity.getBillNo("2");
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
    userMap['pageNum'] = 1;
    userMap['pageSize'] = 100;
    userMap['tranType'] = this.tranType;
    userMap['type'] = 2;
    userMap['billNo'] = this.fBillNo;
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
    if (orderDate.length > 0) {
     // globalKey.currentState!.update();
      this.fOrgID = orderDate[0]["FPOStyle"];
      /*FBillNoKey.currentState.onPressed(orderDate[0][0]);
    FSaleOrderNoKey.currentState.onPressed(orderDate[0][4]);*/
      hobby = [];
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
          "title": "单位名称",
          "name": "FUnitId",
          "isHide": false,
          "value": {"label": value['FUnitName'], "value": value['FUnitNumber']}
        });
        arr.add({
          "title": "实收数量",
          "name": "FRealQty",
          "isHide": false,
          /*value[12]*/
          "value": {"label": "0", "value": "0"}
        });
        arr.add({
          "title": "仓库",
          "name": "FStockID",
          "isHide": false,
          "value": {"label": value['FStockName'], "value": value['FStockNumber']}
        });
        arr.add({
          "title": "批号",
          "name": "FLot",
          "isHide": false,
          "value": {"label": value['FBatchNo'], "value": value['FBatchNo']}
        });
        arr.add({
          "title": "库位",
          "name": "FStockLocID",
          "isHide": true,
          "value": {"label": "", "value": "", "hide": false}
        });
        arr.add({
          "title": "操作",
          "name": "",
          "isHide": true,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "库存单位",
          "name": "",
          "isHide": true,
          "value": {"label": value['FUnitName'], "value": value['FUnitNumber']}
        });
        arr.add({
          "title": "实到数量",
          "name": "",
          "isHide": false,
          "value": {
            "label": value["FAuxQty"],
            "value": value["FAuxQty"],
            "rateValue": value["FAuxQty"]
          } /*+value[12]*0.1*/
        });
        arr.add({
          "title": "最后扫描数量",
          "name": "FLastQty",
          "isHide": false,
          "value": {"label": "0", "value": "0","remainder": "0","representativeQuantity": "0"}
        });
        hobby.add(arr);
      });
      checkItem = '';
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
    /*_onEvent("nx29poSz");*/
    /* _onEvent("u+zeGAN0HjGOOOh3LfNGcSst+0RCbFmsR1G63psT2kLVkcuIIRcQDSTcpqu63ZW7");
    _onEvent("u+zeGAN0HjGOOOh3LfNGcSst+0RCbFmsR1G63psT2kLVkcuIIRcQDXt3X7AnjnOD");*/
  }

  void _onEvent(event) async {

    if (event == "") {
      return;
    }
    _code = event;
    this.getMaterialList("", _code, '');
    print("ChannelPage: $event");

  }

  getMaterialList(barcodeData, code, str) async {
    Map<String, dynamic> userMap = Map();
    userMap['uuid'] = code;
    String order = await CurrencyEntity.getScanBarcode(userMap);
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
      var number = 0;
      var barCodeScan = materialDate;
      if(materialDate['remainQty'] == null || materialDate['remainQty']<1){
        ToastUtil.showInfo("条码未入库或已出库，无剩余数量");
        return;
      }
      var barcodeNum = materialDate['remainQty'].toString();
      var barcodeQuantity = materialDate['remainQty'].toString();
      var fsn = barcodeNum;
      var msg = "";
      var orderIndex = 0;
      if(materialDate['batchNo'] == null){
        materialDate['batchNo'] = " ";
      }
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
          if (element[0]['value']['value'] == barCodeScan['number']) {
            if (element[0]['value']['barcode'].indexOf(code) == -1) {
              if(barCodeScan['isEnable'] != 2){
                element[0]['value']['barcode'].add(code);
              }
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
                      element[10]['value']['remainder'] = (
                          double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                          .toString();
                      element[10]['value']['representativeQuantity'] = barcodeQuantity;
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
                      element[10]['value']['remainder'] = "0";
                      element[10]['value']['representativeQuantity'] = barcodeQuantity;
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
          if (element[0]['value']['value'] == barCodeScan['number']) {
            if (element[0]['value']['barcode'].indexOf(code) == -1 ) {
              if(barCodeScan['isEnable'] != 2){
                element[0]['value']['barcode'].add(code);
              }
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
                      element[10]['value']['remainder'] = (
                          double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                          .toString();
                        element[10]['value']['representativeQuantity'] = barcodeQuantity;
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
                      element[10]['value']['remainder'] = "0";
                      element[10]['value']['representativeQuantity'] = barcodeQuantity;
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
                  ToastUtil.showInfo('单据批号为空');
                  /*element[5]['value']['label'] = barCodeScan['batchNo'] == null? "":barCodeScan['batchNo'];
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
                      element[10]['value']['remainder'] = (
                          double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                          .toString();
                          element[10]['value']['representativeQuantity'] = barcodeQuantity;
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
                      element[10]['value']['remainder'] = "0";
                      element[10]['value']['representativeQuantity'] = barcodeQuantity;
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
                  }*/
                }else{
                  ToastUtil.showInfo('批号与单据对应批号不匹配');
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
          "title": "实收数量",
          "name": "FRealQty",
          "isHide": false,
          /*value[12]*/
          "value": {"label": materialDate["quantity"].toString(), "value": materialDate["quantity"].toString()}
        });
        arr.add({
          "title": "仓库",
          "name": "FStockID",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "批号",
          "name": "FLot",
          "isHide": !materialDate["batchManager"],
          "value": {
            "label": materialDate["batchNo"],
            "value": materialDate["batchNo"]
          }
        });
        arr.add({
          "title": "库位",
          "name": "FStockLocID",
          "isHide": false,
          "value": {"label": "", "value": "", "hide": false}
        });
        arr.add({
          "title": "操作",
          "name": "",
          "isHide": true,
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
          "isHide": false,
          "value": {"label": materialDate["quantity"].toString(), "value": materialDate["quantity"].toString(),"remainder": "0","representativeQuantity": materialDate["quantity"].toString()}
        });
        hobby.add(arr);
      }
      setState(() {
        EasyLoading.dismiss();
      });
    } else {
      setState(() {
        EasyLoading.dismiss();
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
        setState(() async {
          switch (model) {
            case DateMode.YMDHMS:
              Map<String, dynamic> userMap = Map();
              selectData[model] = '${p.year}-${p.month}-${p.day}';
              FDate = '${p.year}-${p.month}-${p.day}';
              await getOrderList();
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
          if (hobby == 'department') {
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
          /*if ( j == 5) {
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
          } else if (j == 4) {
            comList.add(
              _item('仓库:', stockList, this.hobby[i][j]['value']['label'],
                  this.hobby[i][j],
                  stock: this.hobby[i]),
            );
          }  else */if (j == 6) {
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
                                checkItem = 'FStdManHour';
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
          }else if (j == 7) {
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
                            new MaterialButton(
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
          } else {
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
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('扫描',
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.none)),
                  ),
                  if (!show)
                    Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Card(
                            child: Column(children: <Widget>[
                              TextField(
                                style: TextStyle(color: Colors.black87),
                                keyboardType: TextInputType.number,
                                controller: this._textNumber,
                                decoration: InputDecoration(hintText: "输入或者扫描数量"),
                                onChanged: (value) {
                                  setState(() {
                                    this._FNumber = value;
                                  });
                                },
                              ),
                            ]))),
                  if (show)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: TextWidget(textKey, ''),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 8),
                    child: FlatButton(
                        color: Colors.grey[100],
                        onPressed: () {
                          // 关闭 Dialog
                          Navigator.pop(context);
                          if (checkItem == 'FNumber') {
                            setState(() {
                              this.hobby[checkData][checkDataChild]["value"]
                              ["label"] = _FNumber;
                              this.hobby[checkData][checkDataChild]['value']
                              ["value"] = _FNumber;
                            });
                          } else if (checkItem == 'FStdManHour') {
                            setState(() {
                              this.hobby[checkData][checkDataChild]["value"]
                              ["label"] = _FNumber;
                              this.hobby[checkData][checkDataChild]['value']
                              ["value"] = _FNumber;
                            });
                          }
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
  submitOder() async {
    //获取登录信息
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var menuData = sharedPreferences.getString('MenuPermissions');
    var userId = jsonDecode(menuData)['userId'];
    if (this.hobby.length > 0) {
      setState(() {
        this.isSubmit = true;
      });
      Map<String, dynamic> Model = Map();
      Model['ftranType'] = 88;
      Model['finBillNo'] = this.orderNo;
      Model['fdate'] = FDate;
      Model['fbillerID'] = userId;
      //判断有源单 无源单
      if (this.isScanWork) {

      } else {

      }

      var FEntity = [];
      var hobbyIndex = 0;
      for(var element in this.hobby){
        if (element[3]['value']['value'] != '0') {
         if(Decimal.parse(element[3]['value']['value']) > Decimal.parse(orderDate[hobbyIndex]['Fauxprice'])){
           this.isSubmit = false;
           ToastUtil.showInfo('第'+(hobbyIndex+1).toString()+'行，扫描数量大于订单数量');
           return;
         }else if(Decimal.parse(element[3]['value']['value']) < Decimal.parse(orderDate[hobbyIndex]['Fauxprice'])){
           this.isSubmit = false;
           ToastUtil.showInfo('第'+(hobbyIndex+1).toString()+'行，扫描数量小于订单数量');
           return;
         }
        }else{
          this.isSubmit = false;
          ToastUtil.showInfo('第'+(hobbyIndex+1).toString()+'行，投料数量为零');
          return;
        }
        hobbyIndex++;
      };
      /*Model['items'] = FEntity;
      var saveData = jsonEncode(Model);
      ToastUtil.showInfo('保存');
      String order = await SubmitEntity.savePurchase(Model);
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
          ToastUtil.errorDialog(context,
              res['msg']);
        });
      }*/
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
                  submitOder();
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
            title: Text("投料确认"),
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
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("单据编号：$fBillNo"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  /*_item('部门',  this.departmentList, this.departmentName,
                      'department'),
                  _dateItem('日期：', DateMode.YMD),Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("备注："),
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
                        child: Text("确认"),
                        color: this.isSubmit
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async =>submitOder(),
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
