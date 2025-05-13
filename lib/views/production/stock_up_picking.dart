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
import 'package:mayer_wm/views/index/print_page.dart';
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

class StockUpPicking extends StatefulWidget {
  var FBillNo;
  var tranType;

  StockUpPicking({Key? key, @required this.FBillNo, @required this.tranType})
      : super(key: key);

  @override
  _StockUpPickingState createState() =>
      _StockUpPickingState(FBillNo, tranType);
}

class _StockUpPickingState extends State<StockUpPicking> {

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
  var packNo = 1;
  var bulkPackNo = 1;
  var isPack = false;
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
  List<dynamic> printData = [];
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
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  StreamSubscription? _subscription;
  var _code;
  var _FNumber;
  var fBillNo;
  var sourceTranType;
  var orderNo;
  var tranType;
  var fOrgID;
  var fBarCodeList;
  var orderTranType;
  _StockUpPickingState(FBillNo, tranType) {
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
    //getStockList();
   // getBillNo();
    getTypeList();

    //_onEvent("urjKKnXu");
    EasyLoading.dismiss();
  }
  //获取单别
  getTypeList() async {
    Map<String, dynamic> userMap = Map();
    userMap['TranType'] = "21";
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
    String res = await CurrencyEntity.getBillNo("21");
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
  //获取单号
  getResBillNo(type) async {
    String res = await CurrencyEntity.getBillNo(type);
    if (jsonDecode(res)['success']) {
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
    _scrollController.dispose();
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }
  void _scrollToIndex(index,addIndex) {
    // 计算列表中特定索引的位置
    double scrollTo = ((index)* 466.0) + 175.0;  // 假设每个列表项的高度是56.0
    // 使用animateTo滚动到该位置，动画时长200毫秒
    _scrollController.animateTo(
      scrollTo,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
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
    if (orderDate.length > 0) {
      this.fOrgID = orderDate[0]["FPOStyle"];
      this.supplierName = orderDate[0]["FSupplyName"];
      this.supplierNumber = orderDate[0]["FSupplyNumber"];
      this.orderTranType = orderDate[0]["FTranType"];
      for(var value in orderDate){
        fNumber.add(value['FItemNumber']);
        List arr = [];
        Map<String, dynamic> pickMap = Map();
        pickMap['tranType'] = 721;
        pickMap['itemNumber'] = value['FItemNumber'];
        pickMap['billNo'] = this.fBillNo;
        String pickRes = await CurrencyEntity.pollingPick(pickMap);
        var stocks = jsonDecode(pickRes);
        if (jsonDecode(pickRes)['success']) {
          print(jsonDecode(pickRes)['data']);
          if(jsonDecode(pickRes)['data']['list'].length>0){
            var pickDataList = jsonDecode(pickRes)['data']['list'];
            var barcodeList = [];
            var kingDeeCodeList = [];
            var pickNum = 0;
            for(var pickItem in pickDataList){
              barcodeList.add(pickItem['FBarcode']);
              pickNum = pickNum + int.parse(pickItem['FQty']);
              var warePosi = (pickItem['defaultStockNumber']==null?"":pickItem['defaultStockNumber'])+"/"+(pickItem['location']==null?"":pickItem['location']);
              var item = pickItem['FBarcode'].toString() +
                  "-" +
                  pickItem['FQty'].toString() +
                  "-" +
                  warePosi +
                  "-" +
                  pickItem['FPackNum'].toString() +
                  "-" +
                  (pickItem['FMix']=="N"?"否":"是") +
                  "-" +
                  pickItem['FBillNo'];
              kingDeeCodeList.add(item);
            }
            arr.add({
              "title": "物料名称",
              "name": "FMaterial",
              "isHide": false,
              "value": {
                "label": value['FItemName'] + "- (" + value['FItemNumber'] + ")",
                "value": value['FItemNumber'],
                "barcode": barcodeList,
                "kingDeeCode": kingDeeCodeList,
                "scanCode": barcodeList
              }
            });
            arr.add({
              "title": "规格型号",
              "isHide": false,
              "name": "FMaterialIdFSpecification",
              "value": {"label": value['FModel'], "value": value['FModel']}
            });
            arr.add({
              "title": "重量",
              "name": "FUnitId",
              "isHide": false,
              "value": {"label": "", "value": ""}
            });
            arr.add({
              "title": "数量",
              "name": "",
              "isHide": false,
              "value": {
                "label": value["Fauxqty"],
                "value": value["Fauxqty"],
                "rateValue": value["Fauxqty"]
              } /*+value[12]*0.1*/
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
              "title": "拣货数量",
              "name": "FRealQty",
              "isHide": false,
              /*value[12]*/
              "value": {"label": pickNum.toString(), "value": pickNum.toString()}
            });
          }else{
            arr.add({
              "title": "物料名称",
              "name": "FMaterial",
              "isHide": false,
              "value": {
                "label": value['FItemName'] + "- (" + value['FItemNumber'] + ")",
                "value": value['FItemNumber'],
                "barcode": [],
                "kingDeeCode": [],
                "scanCode": []
              }
            });
            arr.add({
              "title": "规格型号",
              "isHide": false,
              "name": "FMaterialIdFSpecification",
              "value": {"label": value['FModel'], "value": value['FModel']}
            });
            arr.add({
              "title": "重量",
              "name": "FUnitId",
              "isHide": false,
              "value": {"label": "", "value": ""}
            });
            arr.add({
              "title": "数量",
              "name": "",
              "isHide": false,
              "value": {
                "label": value["Fauxqty"],
                "value": value["Fauxqty"],
                "rateValue": value["Fauxqty"]
              } /*+value[12]*0.1*/
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
              "title": "拣货数量",
              "name": "FRealQty",
              "isHide": false,
              /*value[12]*/
              "value": {"label": "0", "value": "0"}
            });
          }
        }

        arr.add({
          "title": "最后扫描数量",
          "name": "FLastQty",
          "isHide": true,
          "value": {"label": "0", "value": "0","remainder": "0","representativeQuantity": "0"}
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
          "title": "明细",
          "name": "",
          "isHide": false,
          "value": {"label": "", "value": "", "itemList": []}
        });
        hobby.add(arr);
      };
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      await this.getRecomentSPPath();
      /*await this.getRecomentStockPlace();*/
    } else {
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      ToastUtil.showInfo('无数据');
    }

  /* _onEvent("PAS6435100211");
   _onEvent("PAS6435100211");*/
    /* _onEvent("2501150090");
    _onEvent("2501150092");*/

  }

  void _onEvent(event) async {
    if (event == "" || this.checkItem == "FScan") {
      return;
    }
    if(checkItem == "BoxNo"){
      this._textNumber.text = event;
      this._FNumber = event;
    }else{
      _code = event;
      this.getMaterialList("", _code, '');
      print("ChannelPage: $event");
    }
    checkItem = "";
    /*if (this._positionContent.text == '') {
      Map<String, dynamic> userMap = Map();
      userMap['number'] = _code;
      String order = await CurrencyEntity.geStockPlace(userMap);
      if (jsonDecode(order)['success']) {
        this._positionContent.text = _code;
        if(jsonDecode(order)['data'].length == 0){
          ToastUtil.showInfo("库位不存在");
        }
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
      var number = 0;
      var barCodeScan = materialDate;
      if(materialDate['remainQty'] == null || materialDate['remainQty']<1){
        ToastUtil.showInfo("条码未入库或已出库，无剩余数量");
        return;
      }
      var codeRemainQty = materialDate['remainQty'];
      //循环查询重复条码项
      for (var withinElement in hobby) {
        for(var withinCode in withinElement[0]['value']['kingDeeCode']){
          var codeItem = withinCode.split("-");
          if(codeItem[0] == code && (codeRemainQty - double.parse(codeItem[1])) > 0){
            codeRemainQty = (codeRemainQty - double.parse(codeItem[1]));
          }
        }
      }
      //获取计算后的数量
      materialDate['remainQty'] = codeRemainQty;
      var barcodeNum = materialDate['remainQty'].toInt().toString();
      var barcodeQuantity = materialDate['remainQty'].toInt().toString();
      var backBillNo = materialDate['billNo'];
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
      }
      if (msg != "") {
        await this.playLocal();
        ToastUtil.showInfo(msg);
        return;
      }
      //判断首次
      var firstPack = true;
      for(var item in this.hobby){
        print(item[0]['value']['kingDeeCode'].length);
        if(item[0]['value']['kingDeeCode'].length>0){
          firstPack = false;
          break;
        }
      }
      for (var element in hobby) {
        var residue = 0.0;
        //判断是否启用批号
        if (element[5]['isHide']) {
          //不启用
          if (element[0]['value']['value'] == barCodeScan['number'] ) {
            if (element[0]['value']['barcode'].indexOf(code) == -1) {
              //if(materialDate['remainQty'] != materialDate['packNum']){
                if((!isPack && !firstPack && (materialDate['remainQty'] != materialDate['packNum'] || (element[3]['value']['rateValue'] - double.parse(element[9]['value']['label'])) < double.parse(barcodeNum)))){
                  var codeNumber = 0;
                  var fPrevPackNo = 0;
                  var tPrevPackNo = 0;
                  for (var withinElement in hobby) {
                    for(var code in withinElement[0]['value']['kingDeeCode']){
                      var codeItem = code.split("-");
                      if(codeItem[4] == "否"){
                        codeNumber++;
                        if(int.parse(codeItem[3]) > fPrevPackNo){
                          fPrevPackNo = int.parse(codeItem[3]);
                        }
                      }else{
                        if(int.parse(codeItem[3]) > tPrevPackNo){
                          tPrevPackNo = int.parse(codeItem[3]);
                        }
                      }
                    }
                  }
                  if(codeNumber == 0){
                    isPack = true;
                    bulkPackNo = packNo;
                    packNo++;
                  }else{
                    showDialog(context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("温馨提示"),
                            content: const Text("箱号确认"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  isPack = true;
                                  Navigator.of(context).pop();
                                  this.getMaterialList(barcodeData, code, str);
                                },
                                child: const Text("否"),
                              ),
                              TextButton(
                                onPressed: () async{
                                  if(tPrevPackNo > fPrevPackNo){
                                    bulkPackNo = tPrevPackNo;
                                    bulkPackNo++;
                                    packNo = bulkPackNo;
                                  }else{
                                    bulkPackNo = fPrevPackNo;
                                    bulkPackNo++;
                                    packNo = bulkPackNo;
                                  }
                                  isPack = true;
                                  Navigator.of(context).pop();
                                  this.getMaterialList(barcodeData, code, str);

                                },
                                child: const Text("新箱"),
                              ),
                            ],
                          );
                        }
                    );
                    break;
                  }
                }else{
                  if(materialDate['remainQty'] != materialDate['packNum'] || (element[3]['value']['rateValue'] - double.parse(element[9]['value']['label'])) < double.parse(barcodeNum)){
                    isPack = true;
                  }else{
                    if(!firstPack && packNo == 1){
                      packNo++;
                    }
                    isPack = false;
                  }
                }
             // }
                element[0]['value']['barcode'].add(code);
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
                      print(isPack);
                      var item = code +
                          "-" +
                          (element[3]['value']['rateValue'] -
                              double.parse(element[9]['value']['label']))
                              .toStringAsFixed(2)
                              .toString() +
                          "-" +
                          fsn +
                          "-" +
                          (isPack?bulkPackNo.toString():packNo.toString()) +
                          "-" +
                          (isPack?"否":"是") +
                          "-" +
                          backBillNo;
                      if(!isPack){
                        packNo++;
                      }
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
                      if(barCodeScan['isEnable'] == 1){
                        element[0]['value']['scanCode'].add(code);
                      }
                    }
                  } /*else if((double.parse(element[9]['value']['label']) +
                      double.parse(barcodeNum)) >
                      element[3]['value']['rateValue']){
                    showDialog(context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("温馨提示"),
                            content: const Text("超出单据数量，是否继续"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("取消"),
                              ),
                              TextButton(
                                onPressed: () async{
                                  Navigator.of(context).pop();
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
                                        fsn +
                                        "-" +
                                    packNo.toString() +
                                        "-" +
                                        (isPack?"否":"是") +
                                        "-" +
                                        backBillNo;
                                    packNo++;
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
                                  element[3]['value']['label'] = element[9]['value']['value'];
                                  setState(() {

                                  });
                                },
                                child: const Text("确定"),
                              ),
                            ],
                          );
                        }
                    );
                  }*/ else {
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
                          fsn +
                          "-" +
                          (isPack?bulkPackNo.toString():packNo.toString()) +
                          "-" +
                          (isPack?"否":"是") +
                          "-" +
                          backBillNo;
                      if(!isPack){
                        packNo++;
                      }
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
            } else {
              //ToastUtil.showInfo('该标签已扫描或剩余数量为零');
              continue;
            }
          }
        } else {
          //启用批号
          if (element[0]['value']['value'] == barCodeScan['number'] ) {
            if (element[0]['value']['barcode'].indexOf(code) == -1 ) {
              //if(materialDate['remainQty'] != materialDate['packNum']){
              if((!isPack && !firstPack && (materialDate['remainQty'] != materialDate['packNum'] || (element[3]['value']['rateValue'] - double.parse(element[9]['value']['label'])) < double.parse(barcodeNum)))){
                var codeNumber = 0;
                var fPrevPackNo = 0;
                var tPrevPackNo = 0;
                for (var withinElement in hobby) {
                  for(var code in withinElement[0]['value']['kingDeeCode']){
                    var codeItem = code.split("-");
                    if(codeItem[4] == "否"){
                      codeNumber++;
                      if(int.parse(codeItem[3]) > fPrevPackNo){
                        fPrevPackNo = int.parse(codeItem[3]);
                      }
                    }else{
                      if(int.parse(codeItem[3]) > tPrevPackNo){
                        tPrevPackNo = int.parse(codeItem[3]);
                      }
                    }
                  }
                }
                if(codeNumber == 0){
                  isPack = true;
                  bulkPackNo = packNo;
                  packNo++;
                }else{
                  showDialog(context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("温馨提示"),
                          content: const Text("箱号确认"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                isPack = true;
                                Navigator.of(context).pop();
                                this.getMaterialList(barcodeData, code, str);
                              },
                              child: const Text("否"),
                            ),
                            TextButton(
                              onPressed: () async{
                                if(tPrevPackNo > fPrevPackNo){
                                  bulkPackNo = tPrevPackNo;
                                  bulkPackNo++;
                                  packNo = bulkPackNo;
                                }else{
                                  bulkPackNo = fPrevPackNo;
                                  bulkPackNo++;
                                  packNo = bulkPackNo;
                                }
                                isPack = true;
                                Navigator.of(context).pop();
                                this.getMaterialList(barcodeData, code, str);

                              },
                              child: const Text("新箱"),
                            ),
                          ],
                        );
                      }
                  );
                  break;
                }
              }else{
                if(materialDate['remainQty'] != materialDate['packNum'] || (element[3]['value']['rateValue'] - double.parse(element[9]['value']['label'])
                ) <
                    double.parse(barcodeNum)){
                  isPack = true;
                }else{
                  if(!firstPack && packNo == 1){
                    packNo++;
                  }
                  isPack = false;
                }
              }
              // }
                element[0]['value']['barcode'].add(code);
              if (element[5]['value']['value'] == barCodeScan['batchNo']) {
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
                            fsn +
                            "-" +
                            (isPack?bulkPackNo.toString():packNo.toString()) +
                            "-" +
                            (isPack?"否":"是") +
                            "-" +
                            backBillNo;
                        if(!isPack){
                          packNo++;
                        }
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
                        if(barCodeScan['isEnable'] == 1){
                          element[0]['value']['scanCode'].add(code);
                        }
                      }
                    } /*else if((double.parse(element[9]['value']['label']) +
                        double.parse(barcodeNum)) >
                        element[3]['value']['rateValue']){
                      showDialog(context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("温馨提示"),
                              content: const Text("超出单据数量，是否继续"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    var item = code +
                                        "-" +
                                        (element[3]['value']['rateValue'] -
                                            double.parse(element[9]['value']['label']))
                                            .toStringAsFixed(2)
                                            .toString() +
                                        "-" +
                                        fsn +
                                        "-" +
                          packNo.toString() +
                                        "-" +
                                        (isPack?"否":"是") +
                                        "-" +
                                        backBillNo;
                                    packNo++;
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
                                    if(barCodeScan['isEnable'] == 1){
                                      element[0]['value']['scanCode'].add(code);
                                    }
                                    element[3]['value']['label'] = element[9]['value']['value'];
                                    setState(() {

                                    });
                                  },
                                  child: const Text("取消"),
                                ),
                                TextButton(
                                  onPressed: () async{
                                    Navigator.of(context).pop();
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
                                          fsn +
                                          "-" +
                          packNo.toString() +
                                          "-" +
                                          (isPack?"否":"是") +
                                          "-" +
                                          backBillNo;
                                      packNo++;
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
                                    setState(() {

                                    });
                                  },
                                  child: const Text("确定"),
                                ),
                              ],
                            );
                          }
                      );
                    }*/else {
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
                            fsn +
                            "-" +
                            (isPack?bulkPackNo.toString():packNo.toString()) +
                            "-" +
                            (isPack?"否":"是") +
                            "-" +
                            backBillNo;
                        if(!isPack){
                          packNo++;
                        }
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
              } else {
                if (element[5]['value']['value'] == "") {
                  element[5]['value']['label'] = barCodeScan['batchNo'] == null? "":barCodeScan['batchNo'];
                  element[5]['value']['value'] = barCodeScan['batchNo'] == null? "":barCodeScan['batchNo'];
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
                              fsn +
                              "-" +
                              (isPack?bulkPackNo.toString():packNo.toString()) +
                              "-" +
                              (isPack?"否":"是") +
                              "-" +
                              backBillNo;
                          if(!isPack){
                            packNo++;
                          }
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
                          if(barCodeScan['isEnable'] == 1){
                            element[0]['value']['scanCode'].add(code);
                          }
                        }
                      }  /*else if((double.parse(element[9]['value']['label']) +
                          double.parse(barcodeNum)) >
                          element[3]['value']['rateValue']){
                        showDialog(context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("温馨提示"),
                                content: const Text("超出单据数量，是否继续"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
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
                                            fsn +
                                            "-" +
                          packNo.toString() +
                                            "-" +
                                            (isPack?"否":"是") +
                                            "-" +
                                            backBillNo;
                                        packNo++;
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
                                        if(barCodeScan['isEnable'] == 1){
                                          element[0]['value']['scanCode'].add(code);
                                        }
                                      }
                                      element[3]['value']['label'] = element[9]['value']['value'];
                                      setState(() {

                                      });
                                    },
                                    child: const Text("取消"),
                                  ),
                                  TextButton(
                                    onPressed: () async{
                                      Navigator.of(context).pop();
                                      //数量不超出
                                      //判断条码是否重复
                                      if (element[0]['value']['scanCode'].indexOf(code) ==
                                          -1) {
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
                                            fsn +
                                            "-" +
                          packNo.toString() +
                                            "-" +
                                            (isPack?"否":"是") +
                                            "-" +
                                            backBillNo;
                                        packNo++;
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
                                      setState(() {

                                      });
                                    },
                                    child: const Text("确定"),
                                  ),
                                ],
                              );
                            }
                        );
                      }*/ else {
                        //数量不超出
                        //判断条码是否重复
                        if (element[0]['value']['scanCode'].indexOf(code) ==
                            -1) {
                          element[9]['value']['label'] =
                              (double.parse(element[9]['value']['label']) +
                                  double.parse(barcodeNum))
                                  .toString();
                          element[9]['value']['value'] =
                          element[9]['value']['label'];
                          if(!isPack){
                            packNo++;
                          }
                          var item = code +
                              "-" +
                              barcodeNum +
                              "-" +
                              fsn +
                              "-" +
                              (isPack?bulkPackNo.toString():packNo.toString()) +
                              "-" +
                              (isPack?"否":"是") +
                              "-" +
                              backBillNo;

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
              }
            } else {
              //ToastUtil.showInfo('该标签已扫描或剩余数量为零');
              continue;
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
          "value": {"label": materialDate["remainQty"].toString(), "value": materialDate["remainQty"].toString()}
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
          "isHide": false,//!materialDate["batchManager"]
          "value": {
            "label": materialDate["batchNo"],
            "value": materialDate["batchNo"]
          }
        });
        arr.add({
          "title": "库位",
          "name": "FStockLocID",
          "isHide": false,
          "value": {"label": materialDate["location"], "value": materialDate["location"], "hide": false}
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
          "value": {"label": materialDate["remainQty"].toString(), "value": materialDate["remainQty"].toString(),"remainder": "0","representativeQuantity": materialDate["remainQty"].toString()}
        });
        hobby.add(arr);
      }
      isPack = false;
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
          } else if (hobby == 'type') {
            typeName = p;
            var elementIndex = 0;
            data.forEach((element) {
              if (element == p) {
                typeNumber = typeListObj[elementIndex]['FBillType'];
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
          /*else if (j == 6) {
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
          } else */if (j == 7) {
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
          }else if ( j == 12) {
            var itemList = this.hobby[i][0]["value"]['kingDeeCode'];
            List<Widget> listTitle = [];
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
                                title: Text("箱号："+(dataItem.split('-').length>3?dataItem.split('-')[3].toString():"") ),
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
                                          checkItem = 'BoxNo';
                                          this.show = false;
                                          checkData = i;
                                          checkDataChild = itemList.indexOf(dataItem);
                                          scanBoxDialog();

                                        },
                                      ),
                                    ])),
                          ),
                          Container(
                            color: Colors.white,
                            child: ListTile(
                                title: Text("库别/库位："+dataItem.split('-')[2].toString()),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[

                                    ])),
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            child: ListTile(
                                title: Text("条码："+dataItem.split('-')[0].toString()),
                               ),
                          ),
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
                        ],
                      ),TableRow(
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            child: ListTile(
                                title: Text("整箱："+dataItem.split('-')[4].toString()),
                               ),
                          ),
                          Container(
                            color: Colors.white,
                            child: ListTile(
                                title: Text(".No："+dataItem.split('-')[5].toString()),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  )
              );

            }
            comList.add(
              Column(children: [
                ExpansionTile(
                  initiallyExpanded: true,
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
                            }else if (checkItem == "BoxNo"){
                              if (this.hobby[checkData][0]['value']['kingDeeCode'].length > 0) {
                                var kingDeeCode = this.hobby[checkData][0]['value']['kingDeeCode'][checkDataChild].split("-");
                                this.hobby[checkData][0]['value']['kingDeeCode'][checkDataChild] = kingDeeCode[0] + "-" + kingDeeCode[1] + "-" + kingDeeCode[2] + "-" + _FNumber + "-" + kingDeeCode[4] + "-" + kingDeeCode[5];
                                var hobbySort = [];
                                for(var item in this.hobby){
                                  var hobbyList = item[0]['value']['kingDeeCode'];
                                  for(var listItem in hobbyList){
                                    var listCode = listItem.split("-");
                                    hobbySort.add(int.parse(listCode[3]));
                                  }
                                }
                                hobbySort.sort();
                                packNo = hobbySort[hobbySort.length-1];
                                checkItem = "";
                              } else {
                                ToastUtil.showInfo('无条码信息，输入失败');
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
  //保存
  saveOrder() async {
    this.printData = [];
    //获取登录信息
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var menuData = sharedPreferences.getString('MenuPermissions');
    var userId = jsonDecode(menuData)['userId'];
    if (this.hobby.length > 0) {
      setState(() {
        this.isSubmit = true;
      });
      if (this.typeNumber == null) {
        this.isSubmit = false;
        ToastUtil.showInfo('请选择单别');
        return;
      }
      Map<String, dynamic> Model = Map();
      Model['ftranType'] = 21;
      Model['finBillNo'] = await getResBillNo("21");
      Model['fdate'] = FDate;
      Model['fbillerID'] = userId;
      Model['fpostyle'] = this.fOrgID;
      Model['fdeptId'] = this.departmentNumber;
      Model['fsupplyId'] = this.supplierNumber;
      Model['fbilltypeid'] = this.typeNumber;
      var FEntity = [];
      var FSalesEntity = [];
      var PackingEntity = [];
      var PreEntity = [];
      var hobbyIndex = 0;
      var entryIndex = 0;
      for (var element in this.hobby) {
        if (element[9]['value']['value'] != '0' && element[9]['value']['value'] != '') {
          var kingDeeCode = element[0]['value']['kingDeeCode'];
          for (int subj = 0; subj < kingDeeCode.length; subj++) {
            Map<String, dynamic> subObj = Map();
            Map<String, dynamic> salesSubObj = Map();
            var fSerialSub = [];
            var itemCode = kingDeeCode[subj].split("-");
            Map<String, dynamic> FEntityItem = Map();
            FEntityItem['fauxqty'] = element[9]['value']['value'];
            FEntityItem['fqty'] = element[9]['value']['value'];
            FEntityItem['fentryId'] = entryIndex+1;
            FEntityItem['billType'] = 21;
            FEntityItem['finBillNo'] = Model['finBillNo'];
            if (this.isScanWork) {
              FEntityItem['fauxprice'] = orderDate[hobbyIndex]['Fauxprice'] == null?"0":orderDate[hobbyIndex]['Fauxprice'];
              FEntityItem['famount'] = orderDate[hobbyIndex]['Fauxprice'] == null?"0":orderDate[hobbyIndex]['Fauxprice'];
              FEntityItem['fsourceBillNo'] = orderDate[hobbyIndex]['FBillNo'];
              FEntityItem['fsourceEntryId'] = orderDate[hobbyIndex]['FEntryID'];
              FEntityItem['fsourceTranType'] = orderDate[hobbyIndex]['FTranType'];
            }else{
              FEntityItem['fauxprice'] = 0;
              FEntityItem['famount'] = 0;
            }
            FEntityItem['fdCSPId'] = itemCode[2].split("/")[1];
            FEntityItem['funitId'] = element[2]['value']['value'];
            FEntityItem['fitemId'] = element[0]['value']['value'];
            FEntityItem['fbatchNo'] = element[5]['value']['value'];
            FEntityItem['fdCStockId'] = itemCode[2].split("/")[0];
            if(itemCode[5] != fBillNo){
              salesSubObj['uuid'] = itemCode[0];
              salesSubObj['quantity'] = itemCode[1];
              fSerialSub.add(salesSubObj);
              FEntityItem['barcodeList'] = fSerialSub;
            }
            FSalesEntity.add(FEntityItem);
            if(itemCode[5] != fBillNo){
              subObj['type'] = 2;
              subObj['billNo'] = this.orderTranType + "-"+ fBillNo;
              subObj['date'] = FDate;
              subObj['srcPositions'] = itemCode[2].split("/")[1];
              subObj['srcStockNumber'] = itemCode[2].split("/")[0];
              subObj['uuid'] = itemCode[0];
              FEntity.add(subObj);
            }
            if(itemCode.length>3){
              Map<String, dynamic> PackingEntityItem = Map();
              PackingEntityItem['packNo'] = itemCode[3];
              PackingEntityItem['printBatchno'] = DateTime.now().millisecondsSinceEpoch;
              PackingEntityItem['barcode'] = itemCode[0];
              PackingEntityItem['qty'] = itemCode[1];
              PackingEntityItem['date'] = FDate;
              PackingEntityItem['orderBillNo'] = this.orderTranType + "-"+ fBillNo;
              PackingEntityItem['printCount'] = 1;
              PackingEntityItem['tranType'] = tranType;
              PackingEntity.add(PackingEntityItem);
              Map<String, dynamic> PreEntityItem = Map();
              PreEntityItem['packNo'] = itemCode[3];
              PreEntityItem['date'] = FDate;
              PreEntityItem['barcode'] = itemCode[0]+'-'+itemCode[1];
              PreEntityItem['orderBillNo'] = this.orderTranType + "-"+ fBillNo;
              PreEntityItem['qty'] = itemCode[1];
              PreEntityItem['seq'] = entryIndex+1;
              PreEntityItem['tranType'] = 102;
              PreEntityItem['billType'] = 1;
              PreEntity.add(PreEntityItem);

            }
            entryIndex++;
          }
          hobbyIndex++;
        }
      };
      if (FEntity.length == 0) {
        setState(() {
          this.isSubmit = false;
          ToastUtil.showInfo('无录入数量或数量无更改');
        });
        return;
      }
      if (PreEntity.length == 0 || PackingEntity.length == 0) {
        setState(() {
          this.isSubmit = false;
          ToastUtil.showInfo('请录入箱号');
        });
        return;
      }
      Model['items'] = FSalesEntity;
      /*Model['FDescription'] = this._remarkContent.text;*/
      var saveData = jsonEncode(Model);
      var saveData1 = jsonEncode(FEntity);
      var saveData2 = jsonEncode(PackingEntity);
      var saveData3 = jsonEncode(PreEntity);
      ToastUtil.showInfo('保存');
      String order = await SubmitEntity.underFrame(FEntity);
      var res = jsonDecode(order);
      print(res);
      if (res['success']) {
        String packOrder = await SubmitEntity.packBox(PackingEntity);
        var packRes = jsonDecode(packOrder);
        print(packRes);
        if (packRes['success']) {
          this.printData = packRes['data'];
          String preOrder = await SubmitEntity.preStockOut(PreEntity);
          var preRes = jsonDecode(preOrder);
          if (preRes['success']) {
            String orderSales = await SubmitEntity.saveSales(Model);
            var resSales = jsonDecode(orderSales);
            if (resSales['success']) {
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
                ToastUtil.errorDialog(context, resSales['msg']);
              });
            }
          }else{
            setState(() {
              this.isSubmit = false;
              ToastUtil.errorDialog(context, preRes['msg']);
            });
          }
        }else{
          setState(() {
            this.isSubmit = false;
            ToastUtil.errorDialog(context, packRes['msg']);
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
  }/// 确认打印提示对话框
  Future<void> _showPrintDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("是否打印"),
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
                  //提交清空页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PrintPage(
                            data: this.printData
                          // 路由参数
                        );
                      },
                    ),
                  ).then((data) {
                    setState(() {
                      this.hobby = [];
                      this.printData = [];
                      this.orderDate = [];
                      this.FBillNo = '';
                      this.isSubmit = false;
                      this._labelContent.text = '';
                      this._positionContent.text = '';
                    });
                  });
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
                          title: Text(options[index]),//+';仓库:'+options[index][9]+';数量:'+options[index][4].toString()+';包装规格:'+options[index][6]
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
            title: Text("拣货装箱"),
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
                child: ListView(controller: _scrollController,
                    children: <Widget>[
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("订单单号：$fBillNo"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  _item('单别', this.typeList, this.typeName,
                      'type'),
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
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("路径推荐：$locationPath"),
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
                    /*Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text("打印"),
                        color: this.printData.length == 0
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async =>
                        this.printData.length==0 ? null : _showPrintDialog(),
                      ),
                    ),*/
                  ],
                ),
              )

            ],
          )),
    );
  }
}
