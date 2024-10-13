import 'dart:async';
import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:mayer_wm/model/currency_entity.dart';
import 'package:mayer_wm/model/submit_entity.dart';
import 'package:mayer_wm/utils/toast_util.dart';
/*import 'package:gbk2utf8/gbk2utf8.dart';*/
import 'package:fast_gbk/fast_gbk.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';

class PrintPage extends StatefulWidget {
  var data;

  PrintPage({Key? key, @required this.data}) : super(key: key);

  @override
  _PrintPageState createState() => _PrintPageState(data);
}

class _PrintPageState extends State<PrintPage> {
  var printData;

  _PrintPageState(data) {
    if (data != null) {
      print(data);
      this.printData = data;
      this.getConnectionStatus();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  bool connected = false;
  List availableBluetoothDevices = [];

  //获取连接状态
  getConnectionStatus() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == 'true') {
      setState(() {
        ToastUtil.showInfo('已连接');
        connected = true;
      });
    } else {
      setState(() {
        ToastUtil.showInfo('连接失败');
        connected = false;
      });
    }
  }

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        ToastUtil.showInfo('连接成功');
        connected = true;
      });
    }
  }

  Future<void> printGraphics(bytes) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      print(bytes);
      // List<int> bytes = await getGraphicsTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  bool cnIsNumber(val) {
    final reg = RegExp(r'^-?[0-9.]+$');
    return reg.hasMatch(val);
  }

  Future<void> getGraphicsTicket() async {
    var dataList = [];
    if(printData.length == 1){
      dataList.add(printData);
    }else{
      for (var value in printData) {
        if(dataList.length>0){
          if(dataList.indexWhere((v)=> v[0]['packNo'] == value['packNo']) == -1){
            dataList.add([value]);
          }else{
            dataList[dataList.indexWhere((v)=> v[0]['packNo'] == value['packNo'])].add(value);
          }

        }else{
          dataList.add([value]);
        }
      }
    }
    print(dataList);
    for (var value in dataList) {
      if(value.length==1){
        var codeCont = value[0]['packNo']
            .toString(); //printData[i-1]['orderBillNo'].toString()+"-"+
        var println = 'SIZE 105.0 mm,105.0 mm\r\n' +
            'GAP 2 mm, 0 mm\r\n' +
            'CLS\r\n' +
            'TEXT 10,290,"FONT001",0,2,2,"订单号:"\r\n' +
            'TEXT 10,330,"FONT001",0,2,2,"箱号:"\r\n' +
            'TEXT 10,370,"FONT001",0,2,2,"日期:"\r\n' +
            'TEXT 10,410,"FONT001",0,2,2,"装箱总数量:"\r\n' +
            'TEXT 180,290,"FONT001",0,2,2,"${value[0]['orderBillNo']}"\r\n' +
            'TEXT 180,330,"FONT001",0,2,2,"${value[0]['packNo']}"\r\n' +
            'TEXT 180,370,"FONT001",0,2,2,"${value[0]['date'].substring(0, 10)}"\r\n' +
            'TEXT 180,410,"FONT001",0,2,2,"${value[0]['qty']}"\r\n' +
            'QRCODE 600,290,M,8,A,0,"${codeCont}"\r\n';
        println += 'PRINT 1,1\r\n';
        List<int> pkgData = [];
        pkgData.addAll(gbk.encode(println));
        await this.printGraphics(pkgData);
      }else{
        var printItem = value;
        var printNum = (printItem.length / 9).ceil();
        for (var i = 1; i <= printNum; i++) {
          var pringLength;
          if(printNum == i){
            pringLength = printItem.length;
          }else{
            pringLength = i*9;
          }
          var j = 1;
          var codeCont = printItem[i - 1]['packNo']
              .toString();
          var println = 'SIZE 105.0 mm,105.0 mm\r\n' +
              'GAP 2 mm, 0 mm\r\n' +
              'CLS\r\n' +
              'TEXT 10,10,"FONT001",0,2,2,"订单号:"\r\n' +
              'TEXT 10,50,"FONT001",0,2,2,"箱号:"\r\n' +
              'TEXT 10,90,"FONT001",0,2,2,"日期:"\r\n' +
              'TEXT 10,130,"FONT001",0,2,2,"装箱总数量:"\r\n' +
              'TEXT 180,10,"FONT001",0,2,2,"${printItem[i - 1]['orderBillNo']}"\r\n' +
              'TEXT 180,50,"FONT001",0,2,2,"${printItem[i - 1]['packNo']}"\r\n' +
              'TEXT 180,90,"FONT001",0,2,2,"${printItem[i - 1]['date'].substring(0, 10)}"\r\n' +
              'TEXT 180,130,"FONT001",0,2,2,"${printItem[i - 1]['qty']}"\r\n' +
              'QRCODE 600,10,M,8,A,0,"${codeCont}"\r\n'+
              'BOX 5, 200, 812, 800, 3\r\n' +
              'BAR 200, 200, 1, 600\r\n' +
              'BAR 400, 200, 1, 600\r\n' +
              'BAR 700, 200, 1, 600\r\n' +
              'BAR 5, 260, 810, 1\r\n' +
              'BAR 5, 320, 810, 1\r\n' +
              'BAR 5, 380, 810, 1\r\n' +
              'BAR 5, 440, 810, 1\r\n' +
              'BAR 5, 500, 810, 1\r\n' +
              'BAR 5, 560, 810, 1\r\n' +
              'BAR 5, 620, 810, 1\r\n' +
              'BAR 5, 680, 810, 1\r\n' +
              'BAR 5, 740, 810, 1\r\n' +
              'TEXT 10,220,"FONT001",0,2,2,"物料编码"\r\n' +
              'TEXT 200,220,"FONT001",0,2,2,"物料名称"\r\n' +
              'TEXT 400,220,"FONT001",0,2,2,"规格"\r\n' +
              'TEXT 700,220,"FONT001",0,2,2,"数量"\r\n';
          for (j = j * i; j <= pringLength; j++) {
            var printHeight = 220 + 60 * j;

            if(printItem[j - 1]['itemNumber'].length>15){
              println += 'TEXT 10,${printHeight},"FONT001",0,2,2,"${printItem[j - 1]['itemNumber'].substring(0, 14)}"\r\n';
            }else{
              println += 'TEXT 10,${printHeight},"FONT001",0,2,2,"${printItem[j - 1]['itemNumber']}"\r\n';
            }
            if(printItem[j - 1]['itemNumber'].length>8){
              println +=  'TEXT 200,${printHeight},"FONT001",0,2,2,"${printItem[j - 1]['itemName'].substring(0, 8)}"\r\n';
            }else{
              println += 'TEXT 200,${printHeight},"FONT001",0,2,2,"${printItem[j - 1]['itemName']}"\r\n';
            }
            if(printItem[j - 1]['model'].length>20){
              println += 'TEXT 400,${printHeight},"FONT001",0,2,2,"${printItem[j - 1]['model'].substring(0, 18)}"\r\n';
            }else{
              println += 'TEXT 400,${printHeight},"FONT001",0,2,2,"${printItem[j - 1]['model']}"\r\n';
            }
            println += 'TEXT 700,${printHeight},"FONT001",0,2,2,"${printItem[j - 1]['qty']}"\r\n';

          }
          println += 'PRINT 1,1\r\n';
          print(println);
          print(123);
          List<int> pkgData = [];
          pkgData.addAll(gbk.encode(println));
          await this.printGraphics(pkgData);
        }
      }
    }

    //println.codeUnits.toList();
    //return gbk.encode(println);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("打印标签"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("搜索打印机"),
              TextButton(
                onPressed: () {
                  this.getBluetooth();
                },
                child: Text("点击搜索"),
              ),
              Container(
                height: 150,
                child: ListView.builder(
                  itemCount: availableBluetoothDevices.length > 0
                      ? availableBluetoothDevices.length
                      : 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        String select = availableBluetoothDevices[index];
                        List list = select.split("#");
                        // String name = list[0];
                        String mac = list[1];
                        this.setConnect(mac);
                      },
                      title: Text('${availableBluetoothDevices[index]}'),
                      subtitle: Text("点击链接"),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text("打印"),
                        textColor: Colors.white,
                        color: this.connected
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        onPressed: connected ? this.getGraphicsTicket : null,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
