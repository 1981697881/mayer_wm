import 'dart:convert';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
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

class WarehousingDetail extends StatefulWidget {
  var FBillNo;
  var tranType;

  WarehousingDetail({Key? key, @required this.FBillNo, @required this.tranType})
      : super(key: key);

  @override
  _WarehousingDetailState createState() =>
      _WarehousingDetailState(FBillNo, tranType);
}

class _WarehousingDetailState extends State<WarehousingDetail> {
  var _remarkContent = new TextEditingController();
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();

  final _textNumber = TextEditingController();
  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String FNumber = '';
  String FDate = '';
  String prevPosition = '';
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
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  final ScrollController _scrollController = ScrollController();
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
  var orderTranType;

  _WarehousingDetailState(FBillNo, tranType) {
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
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache();
  String url = 'images/14247.mp3';
  playLocal() async {
    audioPlayer = await audioCache.play(url);      //audio play function
  }

  pauseAudio() async {                 // audio pause
    await audioPlayer.pause();
  }

  resumeAudio() async {
    await audioPlayer.resume();                 //audio resume

  }
  stopAudio() async {
    if (audioPlayer != null) {
      await audioPlayer.stop(); //audio srope
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
    /*getWorkShop();*/
    /*getDepartmentList();
    getSupplierList();*/
    getStockList();
    getBillNo();
    getTypeList();
    //_onEvent("urjKKnXu");
    EasyLoading.dismiss();
  }
//获取单别
  getTypeList() async {
    Map<String, dynamic> userMap = Map();
    userMap['TranType'] = "2";
    String res = await CurrencyEntity.getTypeList(userMap);
    if (jsonDecode(res)['success']) {
      typeListObj = jsonDecode(res)['data'];
      typeListObj.forEach((element) {
        typeList.add(element['FBillTypeName']);
      });
    }else{
      ToastUtil.errorDialog(context,
          jsonDecode(res)['msg']);
    }
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

  //获取供应商
  getSupplierList() async {
    Map<String, dynamic> userMap = Map();
    String res = await CurrencyEntity.getSupplier(userMap);
    if (jsonDecode(res)['success']) {
      supplierListObj = jsonDecode(res)['data'];
      supplierListObj.forEach((element) {
        supplierList.add(element['FName']);
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

  }
  //获取单号
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
    _scrollController.dispose();
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
    userMap['tranType'] = this.tranType;
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
    fNumber = [];
    if (orderDate.length > 0) {
      this.fOrgID = orderDate[0]["FPOStyle"];
      this.supplierName = orderDate[0]["FSupplyName"];
      this.supplierNumber = orderDate[0]["FSupplyNumber"];
      this.orderTranType = orderDate[0]["FTranType"];
      for(var value in orderDate){
        if(fNumber.lastIndexOf(value['FPrdItemNumber']) == -1){
          fNumber.add(value['FPrdItemNumber']);
          List arr = [];
          arr.add({
            "title": "物料名称",
            "name": "FMaterial",
            "isHide": false,
            "value": {
              "label": value['FPrdItemName'] + "- (" + value['FPrdItemNumber'] + ")",
              "value": value['FPrdItemNumber'],
              "barcode": [],
              "kingDeeCode": [],
              "scanCode": []
            }
          });
          arr.add({
            "title": "规格型号",
            "isHide": false,
            "name": "FMaterialIdFSpecification",
            "value": {"label": value['FPrdModel'], "value": value['FPrdModel']}
          });
          arr.add({
            "title": "重量",
            "name": "FUnitId",
            "isHide": false,
            "value": {"label": "", "value": ""}
          });
          arr.add({
            "title": "生产数量",
            "name": "",
            "isHide": false,
            "value": {
              "label": value["FPrdQty"],
              "value": value["FPrdQty"],
              "rateValue": value["FPrdQty"]
            } /*+value[12]*0.1*/
          });
          arr.add({
            "title": "仓库",
            "name": "FStockID",
            "isHide": false,
            "value": {"label": "管件成品仓", "value": "31"}
          });
          arr.add({
            "title": "批号",
            "name": "FLot",
            "isHide": true,
            "value": {"label": '', "value": ''}
          });
          Map<String, dynamic> paramsMap = Map();
          paramsMap['ftranType'] = this.tranType;
          paramsMap['finBillNo'] = this.fBillNo;
          List<dynamic> params = [];
          params.add({"fitemId": value['FItemNumber']});
          paramsMap['items'] = params;
          var resdata = json.encode([paramsMap]);
          String res = await CurrencyEntity.getRecomentStockPlace([paramsMap]);
          if (jsonDecode(res)['success']) {
            arr.add({
              "title": "库存库位",
              "name": "",
              "isHide": false,
              "value": {"label": jsonDecode(res)['data'], "value": jsonDecode(res)['data']}
            });
          }else{
            arr.add({
              "title": "库存库位",
              "name": "",
              "isHide": false,
              "value": {"label": "", "value": ""}
            });
          }
          arr.add({
            "title": "操作",
            "name": "",
            "isHide": true,
            "value": {"label": "", "value": ""}
          });
          arr.add({
            "title": "备注",
            "name": "",
            "isHide": false,
            "value": {"label": "", "value": ""}
          });
          arr.add({
            "title": "入库数量",
            "name": "FRealQty",
            "isHide": false,
            /*value[12]*/
            "value": {"label": "0", "value": "0"}
          });
          arr.add({
            "title": "最后扫描数量",
            "name": "FLastQty",
            "isHide": true,
            "value": {"label": "0", "value": "0","remainder": "0","representativeQuantity": "0"}
          });
          arr.add({
            "title": "条码列表",
            "name": "",
            "isHide": false,
            "value": {"label": "", "value": "", "itemList": []}
          });
          hobby.add(arr);
        }
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
    //_onEvent("PFS1083070000;;;250;;1757432737;0;2407100002");
    //_onEvent("PAS111A070712;;;20;;1818057924;0;1");
  }

  void _onEvent(event) async {
    if (event == "") {
      return;
    }
    if(checkItem == "FPosition"){
      Map<String, dynamic> userMap = Map();
      userMap['number'] = event;
      String order = await CurrencyEntity.geStockPlace(userMap);
      if (jsonDecode(order)['success']) {
        if(jsonDecode(order)['data'].length == 0){
          ToastUtil.showInfo("库位不存在");
        }else{
          this._textNumber.text = event;
          this._FNumber = event;
          prevPosition = event;
        }
      } else {
        ToastUtil.showInfo(jsonDecode(order)['msg']);
      }
    }else{
      _code = event;
      this.getMaterialList("", _code, '');
      print("ChannelPage: $event");
    }
    print("ChannelPage: $event");
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
      var number = 0;
      var barCodeScan = materialDate;
      var barcodeNum;
      var barcodeQuantity;
      var fsn;
      if(materialDate['packDetail'] != null && materialDate['packDetail'] != ""){
        var packMsg = "";
        var packDetail = materialDate['packDetail'].split(";");
        for(var packItem in packDetail){
            var packData = packItem.split(",");
            if(packData[0]==(this.orderTranType+"-"+this.fBillNo)){
              packMsg = "";
              barcodeNum = packData[1].toString();
              barcodeQuantity = packData[1].toString();
              fsn = packData[1].toString();
              break;
            }else{
              packMsg = "该标签当前工单没有包装数量，不可用";
            }
        }
        if(packMsg != ""){
          ToastUtil.showInfo(packMsg);
          return;
        }
      }else{
         barcodeNum = materialDate['quantity'].toString();
         barcodeQuantity = materialDate['quantity'].toString();
         fsn = materialDate['quantity'].toString();
        if(materialDate['quantity'] == null || materialDate['quantity']<1){
          ToastUtil.showInfo("条码数量为0");
          return;
        }
      }
      var msg = "";
      var orderIndex = 0;
      for (var value in orderDate) {
        if (value['FPrdItemNumber'] == materialDate['number']) {
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
        await this.playLocal();
        ToastUtil.showInfo(msg);
        return;
      }
      var listIndex = 0;
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
              if (double.parse(element[9]['value']['label']) >=
                  element[3]['value']['rateValue']) {
                continue;
              } else {
                //判断条码数量
                if ((double.parse(element[9]['value']['label']) +
                    double.parse(barcodeNum)) >
                    0 &&
                    double.parse(barcodeNum) > 0) {
                  if ((double.parse(element[9]['value']['label']) +
                      double.parse(barcodeNum)) >=
                      element[3]['value']['rateValue']) {
                    //判断条码是否重复
                    if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                      var item = code +
                          "-" +
                          (element[3]['value']['rateValue'] -
                              double.parse(element[9]['value']['label']))
                              .toStringAsFixed(2)
                              .toString() +
                          "-" +
                          fsn;
                      element[10]['value']['label'] = (element[3]['value']
                      ['label'] -
                          double.parse(element[9]['value']['label']))
                          .toString();
                      element[10]['value']['value'] = (element[3]['value']
                      ['label'] -
                          double.parse(element[9]['value']['label']))
                          .toString();
                      element[10]['value']['remainder'] = (
                          double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                          .toString();
                      element[10]['value']['representativeQuantity'] = barcodeQuantity;
                      barcodeNum = (double.parse(barcodeNum) -
                          (element[3]['value']['rateValue'] -
                              double.parse(element[9]['value']['label'])))
                          .toString();
                      element[9]['value']['label'] = (double.parse(
                          element[9]['value']['label']) +
                          (element[3]['value']['rateValue'] -
                              double.parse(element[9]['value']['label'])))
                          .toString();
                      element[9]['value']['value'] =
                      element[9]['value']['label'];
                      residue = element[3]['value']['rateValue'] -
                          double.parse(element[9]['value']['label']);
                      element[0]['value']['kingDeeCode'].add(item);

                      var itemList = element[0]['value']['kingDeeCode'];
                      var dataItem =  element[0]['value']['kingDeeCode'][itemList.length-1];
                      if(dataItem.split('-').length>3){
                        this._textNumber.text = dataItem.split('-')[3].toString();
                        this._FNumber = dataItem.split('-')[3].toString();
                        this._textNumber.value =
                            _textNumber.value.copyWith(
                              text: dataItem.split('-')[3].toString(),
                            );
                      }else{
                        this._textNumber.value =
                            _textNumber.value.copyWith(
                              text: "",
                            );
                      }
                      if(prevPosition != ""){
                        this._textNumber.text = prevPosition.toString();
                        this._FNumber = prevPosition.toString();
                        this._textNumber.value =
                            _textNumber.value.copyWith(
                              text: prevPosition.toString(),
                            );
                      }
                      checkItem = 'FPosition';
                      this.show = false;
                      checkData = listIndex;
                      checkDataChild = itemList.indexOf(dataItem);
                      scanBoxDialog();

                      if(barCodeScan['isEnable'] == 1){
                        element[0]['value']['scanCode'].add(code);
                      }
                    }
                  } else {
                    //数量不超出
                    //判断条码是否重复
                    if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                      element[9]['value']['label'] =
                          (double.parse(element[9]['value']['label']) +
                              double.parse(barcodeNum))
                              .toString();
                      element[9]['value']['value'] =
                      element[9]['value']['label'];
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

                      var itemList = element[0]['value']['kingDeeCode'];
                      var dataItem =  element[0]['value']['kingDeeCode'][itemList.length-1];
                      if(dataItem.split('-').length>3){
                        this._textNumber.text = dataItem.split('-')[3].toString();
                        this._FNumber = dataItem.split('-')[3].toString();
                        this._textNumber.value =
                            _textNumber.value.copyWith(
                              text: dataItem.split('-')[3].toString(),
                            );
                      }else{
                        this._textNumber.value =
                            _textNumber.value.copyWith(
                              text: "",
                            );
                      }
                      if(prevPosition != ""){
                        this._textNumber.text = prevPosition.toString();
                        this._FNumber = prevPosition.toString();
                        this._textNumber.value =
                            _textNumber.value.copyWith(
                              text: prevPosition.toString(),
                            );
                      }
                      checkItem = 'FPosition';
                      this.show = false;
                      checkData = listIndex;
                      checkDataChild = itemList.indexOf(dataItem);
                      scanBoxDialog();

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
                if (double.parse(element[9]['value']['label']) >=
                    element[3]['value']['rateValue']) {
                  continue;
                } else {
                  //判断条码数量
                  if ((double.parse(element[9]['value']['label']) +
                      double.parse(barcodeNum)) >
                      0 &&
                      double.parse(barcodeNum) > 0) {
                    if ((double.parse(element[9]['value']['label']) +
                        double.parse(barcodeNum)) >=
                        element[3]['value']['rateValue']) {
                      //判断条码是否重复
                      if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                        var item = code +
                            "-" +
                            (element[3]['value']['rateValue'] -
                                double.parse(element[9]['value']['label']))
                                .toStringAsFixed(2)
                                .toString() +
                            "-" +
                            fsn;
                        element[10]['value']['label'] = (element[3]['value']
                        ['label'] -
                            double.parse(element[9]['value']['label']))
                            .toString();
                        element[10]['value']['value'] = (element[3]['value']
                        ['label'] -
                            double.parse(element[9]['value']['label']))
                            .toString();
                        element[10]['value']['remainder'] = (
                            double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                            .toString();
                        element[10]['value']['representativeQuantity'] = barcodeQuantity;
                        barcodeNum = (double.parse(barcodeNum) -
                            (element[3]['value']['rateValue'] -
                                double.parse(element[9]['value']['label'])))
                            .toString();
                        element[9]['value']['label'] = (double.parse(
                            element[9]['value']['label']) +
                            (element[3]['value']['rateValue'] -
                                double.parse(element[9]['value']['label'])))
                            .toString();
                        element[9]['value']['value'] =
                        element[9]['value']['label'];
                        residue = element[3]['value']['rateValue'] -
                            double.parse(element[9]['value']['label']);
                        element[0]['value']['kingDeeCode'].add(item);


                        var itemList = element[0]['value']['kingDeeCode'];
                        var dataItem =  element[0]['value']['kingDeeCode'][itemList.length-1];
                        if(dataItem.split('-').length>3){
                          this._textNumber.text = dataItem.split('-')[3].toString();
                          this._FNumber = dataItem.split('-')[3].toString();
                          this._textNumber.value =
                              _textNumber.value.copyWith(
                                text: dataItem.split('-')[3].toString(),
                              );
                        }else{
                          this._textNumber.value =
                              _textNumber.value.copyWith(
                                text: "",
                              );
                        }
                        if(prevPosition != ""){
                          this._textNumber.text = prevPosition.toString();
                          this._FNumber = prevPosition.toString();
                          this._textNumber.value =
                              _textNumber.value.copyWith(
                                text: prevPosition.toString(),
                              );
                        }
                        checkItem = 'FPosition';
                        this.show = false;
                        checkData = listIndex;
                        checkDataChild = itemList.indexOf(dataItem);
                        scanBoxDialog();

                        if(barCodeScan['isEnable'] == 1){
                          element[0]['value']['scanCode'].add(code);
                        }
                      }
                    } else {
                      //数量不超出
                      //判断条码是否重复
                      if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                        element[9]['value']['label'] =
                            (double.parse(element[9]['value']['label']) +
                                double.parse(barcodeNum))
                                .toString();
                        element[9]['value']['value'] =
                        element[9]['value']['label'];
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

                        var itemList = element[0]['value']['kingDeeCode'];
                        var dataItem =  element[0]['value']['kingDeeCode'][itemList.length-1];
                        if(dataItem.split('-').length>3){
                          this._textNumber.text = dataItem.split('-')[3].toString();
                          this._FNumber = dataItem.split('-')[3].toString();
                          this._textNumber.value =
                              _textNumber.value.copyWith(
                                text: dataItem.split('-')[3].toString(),
                              );
                        }else{
                          this._textNumber.value =
                              _textNumber.value.copyWith(
                                text: "",
                              );
                        }
                        if(prevPosition != ""){
                          this._textNumber.text = prevPosition.toString();
                          this._FNumber = prevPosition.toString();
                          this._textNumber.value =
                              _textNumber.value.copyWith(
                                text: prevPosition.toString(),
                              );
                        }
                        checkItem = 'FPosition';
                        this.show = false;
                        checkData = listIndex;
                        checkDataChild = itemList.indexOf(dataItem);
                        scanBoxDialog();

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
                  if (double.parse(element[9]['value']['label']) >=
                      element[3]['value']['rateValue']) {
                    continue;
                  } else {
                    //判断条码数量
                    if ((double.parse(element[9]['value']['label']) +
                        double.parse(barcodeNum)) >
                        0 &&
                        double.parse(barcodeNum) > 0) {
                      if ((double.parse(element[9]['value']['label']) +
                          double.parse(barcodeNum)) >=
                          element[3]['value']['rateValue']) {
                        //判断条码是否重复
                        if (element[0]['value']['scanCode'].indexOf(code) ==
                            -1) {
                          var item = code +
                              "-" +
                              (element[3]['value']['rateValue'] -
                                  double.parse(
                                      element[9]['value']['label']))
                                  .toStringAsFixed(2)
                                  .toString() +
                              "-" +
                              fsn;
                          element[10]['value']['label'] = (element[3]['value']
                          ['label'] -
                              double.parse(element[9]['value']['label']))
                              .toString();
                          element[10]['value']['value'] = (element[3]['value']
                          ['label'] -
                              double.parse(element[9]['value']['label']))
                              .toString();
                          element[10]['value']['remainder'] = (
                              double.parse(element[10]['value']['value']) - double.parse(barcodeNum))
                              .toString();
                          element[10]['value']['representativeQuantity'] = barcodeQuantity;
                          barcodeNum = (double.parse(barcodeNum) -
                              (element[3]['value']['rateValue'] -
                                  double.parse(
                                      element[9]['value']['label'])))
                              .toString();
                          element[9]['value']['label'] =
                              (double.parse(element[9]['value']['label']) +
                                  (element[3]['value']['rateValue'] -
                                      double.parse(
                                          element[9]['value']['label'])))
                                  .toString();
                          element[9]['value']['value'] =
                          element[9]['value']['label'];
                          residue = element[3]['value']['rateValue'] -
                              double.parse(element[9]['value']['label']);
                          element[0]['value']['kingDeeCode'].add(item);

                          var itemList = element[0]['value']['kingDeeCode'];
                          var dataItem =  element[0]['value']['kingDeeCode'][itemList.length-1];
                          if(dataItem.split('-').length>3){
                            this._textNumber.text = dataItem.split('-')[3].toString();
                            this._FNumber = dataItem.split('-')[3].toString();
                            this._textNumber.value =
                                _textNumber.value.copyWith(
                                  text: dataItem.split('-')[3].toString(),
                                );
                          }else{
                            this._textNumber.value =
                                _textNumber.value.copyWith(
                                  text: "",
                                );
                          }
                          if(prevPosition != ""){
                            this._textNumber.text = prevPosition.toString();
                            this._FNumber = prevPosition.toString();
                            this._textNumber.value =
                                _textNumber.value.copyWith(
                                  text: prevPosition.toString(),
                                );
                          }
                          checkItem = 'FPosition';
                          this.show = false;
                          checkData = listIndex;
                          checkDataChild = itemList.indexOf(dataItem);
                          scanBoxDialog();

                          if(barCodeScan['isEnable'] == 1){
                            element[0]['value']['scanCode'].add(code);
                          }
                        }
                      } else {
                        //数量不超出
                        //判断条码是否重复
                        if (element[0]['value']['scanCode'].indexOf(code) ==
                            -1) {
                          element[9]['value']['label'] =
                              (double.parse(element[9]['value']['label']) +
                                  double.parse(barcodeNum))
                                  .toString();
                          element[9]['value']['value'] = element[9]['value']['label'];
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

                          var itemList = element[0]['value']['kingDeeCode'];
                          var dataItem =  element[0]['value']['kingDeeCode'][itemList.length-1];
                          if(dataItem.split('-').length>3){
                            this._textNumber.text = dataItem.split('-')[3].toString();
                            this._FNumber = dataItem.split('-')[3].toString();
                            this._textNumber.value =
                                _textNumber.value.copyWith(
                                  text: dataItem.split('-')[3].toString(),
                                );
                          }else{
                            this._textNumber.value =
                                _textNumber.value.copyWith(
                                  text: "",
                                );
                          }
                          if(prevPosition != ""){
                            this._textNumber.text = prevPosition.toString();
                            this._FNumber = prevPosition.toString();
                            this._textNumber.value =
                                _textNumber.value.copyWith(
                                  text: prevPosition.toString(),
                                );
                          }
                          checkItem = 'FPosition';
                          this.show = false;
                          checkData = listIndex;
                          checkDataChild = itemList.indexOf(dataItem);
                          scanBoxDialog();

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
        listIndex++;
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
          "isHide": false,
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
    _scrollToIndex(fNumber.indexOf(materialDate['number']),this.hobby[fNumber.indexOf(materialDate['number'])][0]["value"]["kingDeeCode"].length);
  }
  void _scrollToIndex(index,addIndex) {
    // 计算列表中特定索引的位置
    double scrollTo = ((index)* 523.0) + 300.0;  // 假设每个列表项的高度是56.0
    // 使用animateTo滚动到该位置，动画时长200毫秒
    _scrollController.animateTo(
      scrollTo,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
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
          } else if (hobby == 'type') {
            typeName = p;
            var elementIndex = 0;
            data.forEach((element) {
              if (element == p) {
                typeNumber = typeListObj[elementIndex]['FBillType'];
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
//调出弹窗 扫码
  void scanBoxDialog() {
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
                    Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(this.checkItem=="FPosition"?"库位":"数量",
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.none)),
                  ),
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
                          setState(() async{
                            if (checkItem == "FPosition"){
                              if (this.hobby[checkData][0]['value']['kingDeeCode'].length > 0) {
                                Map<String, dynamic> userMap = Map();
                                userMap['number'] = _FNumber;
                                String order = await CurrencyEntity.geStockPlace(userMap);
                                if (jsonDecode(order)['success']) {
                                  if (jsonDecode(order)['data'].length == 0) {
                                    ToastUtil.showInfo("库位不存在");
                                  } else {
                                    setState((){
                                      prevPosition = _FNumber;
                                      var kingDeeCode = this.hobby[checkData][0]['value']['kingDeeCode'][checkDataChild].split("-");
                                      this.hobby[checkData][0]['value']['kingDeeCode'][checkDataChild] = kingDeeCode[0] + "-" + kingDeeCode[1] + "-" + kingDeeCode[2] + "-" + _FNumber;
                                    });
                                  }
                                }
                              } else {
                                ToastUtil.showInfo('无条码信息，输入失败');
                              }
                              checkItem = "";
                            }else if (checkItem == "FLastQty") {
                              if(_FNumber == 0 || _FNumber == "" || _FNumber == null){
                                return;
                              }
                              if(double.parse(_FNumber) <= double.parse(this.hobby[checkData][10]["value"]['representativeQuantity'])){
                                if (this.hobby[checkData][0]['value']['kingDeeCode'].length > 0) {
                                  var kingDeeCode = this.hobby[checkData][0]['value']['kingDeeCode'][checkDataChild].split("-");
                                  var realQty = 0.0;
                                  this.hobby[checkData][0]['value']['kingDeeCode'].forEach((item) {
                                    var qty = item.split("-")[1];
                                    realQty += double.parse(qty);
                                  });
                                  realQty = realQty - double.parse(this.hobby[checkData][10]
                                  ["value"]["label"]);
                                  realQty = realQty + double.parse(_FNumber);
                                  this.hobby[checkData][10]["value"]["remainder"] = (Decimal.parse(this.hobby[checkData][10]["value"]["representativeQuantity"]) - Decimal.parse(_FNumber)).toString();
                                  this.hobby[checkData][9]["value"]["value"] = realQty.toString();
                                  this.hobby[checkData][9]["value"]["label"] = realQty.toString();
                                  this.hobby[checkData][10]["value"]["label"] = _FNumber;
                                  this.hobby[checkData][10]['value']["value"] = _FNumber;
                                  if(kingDeeCode.length>3){
                                    this.hobby[checkData][0]['value']['kingDeeCode'][checkDataChild] = kingDeeCode[0] + "-" + _FNumber + "-" + kingDeeCode[2] + "-" + kingDeeCode[3] + "-" + kingDeeCode[4] + "-" + kingDeeCode[5];
                                  }else{
                                    this.hobby[checkData][0]['value']['kingDeeCode'][checkDataChild] = kingDeeCode[0] + "-" + _FNumber + "-" + kingDeeCode[2];
                                  }
                                } else {
                                  ToastUtil.showInfo('无条码信息，输入失败');
                                }
                              }else{
                                ToastUtil.showInfo('输入数量大于条码可用数量');
                              }
                            }
                          });
                        },
                        child: Text(
                          '完成',
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
  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
        if (!this.hobby[i][j]['isHide']) {
          /*if (j == 3 || j == 5) {
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
          } else*/ if (j == 4) {
            comList.add(
              _item('收货仓库:', stockList, this.hobby[i][j]['value']['label'],
                  this.hobby[i][j],
                  stock: this.hobby[i]),
            );
          } /*else if (j == 6) {
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
                                checkItem = 'FPosition';
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
          }*/ else if (j == 7) {
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
          } else if (j == 10) {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                      title: Text(this.hobby[i][j]["title"] +
                          '：' +
                          this.hobby[i][j]["value"]["label"].toString()+'剩余('+this.hobby[i][j]["value"]["remainder"].toString()+')'),
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
          }/* else if ( j == 11) {
            var itemList = this.hobby[i][0]["value"]['kingDeeCode'];
            List<Widget> listTitle = [];
            var listTitleNum = 1;
            for(var dataItem in itemList){
              listTitle.add(
                ListTile(
                  title: Text(listTitleNum.toString() +
                      '：' +
                      dataItem.split('-')[0]),
                  trailing:IconButton(
                    icon: new Icon(Icons.delete),
                    onPressed: () {
                      this.hobby[i][0]["value"]['kingDeeCode'].removeAt(listTitleNum-1);
                    },
                  ),
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
          }*/else if ( j == 11) {
            var itemList = this.hobby[i][0]["value"]['kingDeeCode'];
            List<Widget> listTitle = [];
            var itemNumber = 1;
            for(var dataItem in itemList){
              listTitle.add(
                SizedBox(height: 6, width: 320, child: ColoredBox(color: Colors.grey)),
              );
              listTitle.add(
                  Center(child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(1), // 第一列宽度占比1
                      1: FlexColumnWidth(1), // 第二列宽度占比2
                    },
                    border: TableBorder.all(
                        color: Colors.blue, width: 1.0, style: BorderStyle.solid),
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(itemNumber.toString()),
                            ),
                          ),Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text("条码："+dataItem.split('-')[0].toString()),
                            ),
                          ),
                        ],
                      ),TableRow(
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            child: ListTile(
                                title: Text("数量："+double.parse(dataItem.split('-')[1]).toInt().toString()),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        icon: new Icon(Icons.mode_edit),
                                        tooltip: '点击扫描',
                                        onPressed: () {
                                          this._textNumber.text = double.parse(dataItem.split('-')[1]).toInt().toString();
                                          this._FNumber = double.parse(dataItem.split('-')[1]).toInt().toString();
                                          checkItem = 'FLastQty';
                                          this.show = false;
                                          checkData = i;
                                          checkDataChild = itemList.indexOf(dataItem);
                                          scanBoxDialog();
                                          if (dataItem.split('-')[1] != 0) {
                                            this._textNumber.value =
                                                _textNumber.value.copyWith(
                                                  text:  double.parse(dataItem.split('-')[1]).toInt().toString(),
                                                );
                                          }
                                        },
                                      ),
                                    ])),
                          ),
                          Container(
                            color: Colors.white,
                            child: ListTile(
                                title: Text("库位："+(dataItem.split('-').length>3?dataItem.split('-')[3].toString():"")),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        icon: new Icon(Icons.mode_edit),
                                        tooltip: '点击扫描',
                                        onPressed: () {
                                          if(dataItem.split('-').length>3){
                                            this._textNumber.text = dataItem.split('-')[3].toString();
                                            this._FNumber = dataItem.split('-')[3].toString();
                                            this._textNumber.value =
                                                _textNumber.value.copyWith(
                                                  text: dataItem.split('-')[3].toString(),
                                                );
                                          }else{
                                            this._textNumber.value =
                                                _textNumber.value.copyWith(
                                                  text: "",
                                                );
                                          }
                                          checkItem = 'FPosition';
                                          this.show = false;
                                          checkData = i;
                                          checkDataChild = itemList.indexOf(dataItem);
                                          scanBoxDialog();
                                        },
                                      ),
                                    ])),
                          ),
                        ],
                      ),
                    ],
                  ),
                  )
              );
              itemNumber++;
            }
            comList.add(
              Column(children: [
                ExpansionTile(
                  title: Text(this.hobby[i][j]["title"] +
                      '：' +
                      (listTitle.length/2).truncate().toString()),
                  children: listTitle,
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
                                  this.hobby[checkData][10]["value"]["remainder"] = (Decimal.parse(this.hobby[checkData][10]["value"]["representativeQuantity"]) - Decimal.parse(_FNumber)).toString();
                                  this.hobby[checkData][9]["value"]["value"] = realQty.toString();
                                  this.hobby[checkData][9]["value"]["label"] = realQty.toString();
                                  this.hobby[checkData][checkDataChild]["value"]["label"] = _FNumber;
                                  this.hobby[checkData][checkDataChild]['value']["value"] = _FNumber;
                                  this.hobby[checkData][0]['value']['kingDeeCode'][this.hobby[checkData][0]['value']['kingDeeCode'].length - 1] = kingDeeCode[0] + "-" + _FNumber + "-" + kingDeeCode[2];
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
      Model['ftranType'] = 2;
      Model['finBillNo'] = await getBillNo();
      Model['fdate'] = FDate;
      Model['fbillerID'] = userId;
      //Model['fpostyle'] = this.fOrgID;
      Model['fdeptId'] = this.departmentNumber;
      if (this.typeNumber == null) {
        this.isSubmit = false;
        ToastUtil.showInfo('请选择单别');
        return;
      }
      Model['fbilltypeid'] = this.typeNumber;
      var FEntity = [];
      var FrameList = [];
      var hobbyIndex = 0;
      var number = 0;
      this.hobby.forEach((element) {
        if (element[9]['value']['value'] != '0' && element[9]['value']['value'] != '' &&
            element[4]['value']['value'] != '') {
          Map<String, dynamic> FEntityItem = Map();

          FEntityItem['fauxqty'] = element[9]['value']['value'];
          FEntityItem['fqty'] = element[9]['value']['value'];
          FEntityItem['fentryId'] = hobbyIndex+1;
          FEntityItem['finBillNo'] = Model['finBillNo'];
          FEntityItem['billType'] = 2;
          if (this.isScanWork) {

            FEntityItem['fauxprice'] = orderDate[hobbyIndex]['Fauxprice'] == null?"0":orderDate[hobbyIndex]['Fauxprice'];
            FEntityItem['famount'] = orderDate[hobbyIndex]['Fauxprice'] == null?"0":orderDate[hobbyIndex]['Fauxprice'];
            FEntityItem['fsourceBillNo'] = orderDate[hobbyIndex]['FBillNo'];
           // FEntityItem['fsourceEntryId'] = orderDate[hobbyIndex]['FEntryID'];
            FEntityItem['fsourceTranType'] = orderDate[hobbyIndex]['FTranType'];
          }else{
            FEntityItem['fauxprice'] = 0;
            FEntityItem['famount'] = 0;
          }
          FEntityItem['fdCSPId'] = "";
          FEntityItem['fitemId'] = element[0]['value']['value'];
          FEntityItem['fbatchNo'] = element[5]['value']['value'];
          FEntityItem['fdCStockId'] = element[4]['value']['value'];
          var fSerialSub = [];
          var fSerialSubIndexOf = [];
          var kingDeeCode = element[0]['value']['kingDeeCode'];
          for (int subj = 0; subj < kingDeeCode.length; subj++) {
            Map<String, dynamic> FrameItem = Map();
            Map<String, dynamic> subObj = Map();
            var itemCode = kingDeeCode[subj].split("-");
            if(itemCode[3] == ""){
              number++;
            }
            FrameItem['uuid'] = itemCode[0];
            FrameItem['positions'] = itemCode[3];
            FrameItem['srcBillNo'] = this.orderTranType + "-"+ this.fBillNo;
            FrameItem['type'] = 1;
            FrameList.add(FrameItem);
            if(fSerialSubIndexOf.indexOf(itemCode[0]) == -1){
              subObj['uuid'] = itemCode[0];
              subObj['quantity'] = itemCode[1];
              subObj['packNum'] = itemCode[2];
              fSerialSubIndexOf.add(itemCode[0]);
              fSerialSub.add(subObj);
            }else{
              for(var sub in fSerialSub){
                if(sub['uuid'] == itemCode[0]){
                  sub['quantity'] = (Decimal.parse(sub['quantity']) + Decimal.parse(itemCode[1])).toString();
                }
              }
            }
          }
          FEntityItem['barcodeList'] = fSerialSub;
          FEntity.add(FEntityItem);
        }
        hobbyIndex++;
      });
      if (FEntity.length == 0 || number>0) {
        this.isSubmit = false;
        ToastUtil.showInfo('请输入数量和库位');
        return;
      }
      Model['items'] = FEntity;
      /*Model['FDescription'] = this._remarkContent.text;*/
      var saveData = jsonEncode(Model);
      ToastUtil.showInfo('保存');
      String order = await SubmitEntity.saveProduct(Model);
      var res = jsonDecode(order);
      print(res);
      if (res['success']) {
        String frameOrder = await SubmitEntity.onFrame(FrameList);
        var frameRes = jsonDecode(frameOrder);
        if (frameRes['success']) {
          //提交清空页面
          setState(() {
            this.hobby = [];
            this.orderDate = [];
            this.FBillNo = '';
            ToastUtil.showInfo('提交成功');
            Navigator.of(context).pop("refresh");
          });
        }else{
          setState(() {
            this.isSubmit = false;
            ToastUtil.errorDialog(context,
                frameRes['msg']);
          });
        }
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
            title: Text("成品入库"),
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
                child: ListView(
                    controller: _scrollController,
                    children: <Widget>[
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          /* title: TextWidget(FBillNoKey, '生产订单：'),*/
                          title: Text("入库单号：$orderNo"),
                        ),
                      ),
                      divider,
                    ],
                  ),Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          /* title: TextWidget(FBillNoKey, '生产订单：'),*/
                          title: Text("到货单号：$fBillNo"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  _item('单别', this.typeList, this.typeName,
                      'type'),
                  _dateItem('日期：', DateMode.YMD),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: TextField(
                            //最多输入行数
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: "备注",
                              //给文本框加边框
                              border: OutlineInputBorder(),
                            ),
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
