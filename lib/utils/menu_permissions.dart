import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mayer_wm/views/index/index_page.dart';
import 'package:mayer_wm/views/production/barcode_outbound.dart';
import 'package:mayer_wm/views/production/barcode_storage.dart';
import 'package:mayer_wm/views/production/custody_return_detail.dart';
import 'package:mayer_wm/views/production/custody_return_page.dart';
import 'package:mayer_wm/views/production/custody_stocking_detail.dart';
import 'package:mayer_wm/views/production/custody_stocking_page.dart';
import 'package:mayer_wm/views/production/custody_warehousing_page.dart';
import 'package:mayer_wm/views/production/listing_page.dart';
import 'package:mayer_wm/views/production/offshelf_page.dart';
import 'package:mayer_wm/views/production/picking_page.dart';
import 'package:mayer_wm/views/production/pipe_removal_page.dart';
import 'package:mayer_wm/views/production/pipe_shelving_page.dart';
import 'package:mayer_wm/views/production/stock_up_page.dart';
import 'package:mayer_wm/views/production/warehousing_page.dart';
import 'package:mayer_wm/views/purchase/purchase_warehousing_page.dart';
import 'package:mayer_wm/views/stock/allocation_page.dart';
import 'package:mayer_wm/views/stock/encoding_transfer.dart';
import 'package:mayer_wm/views/stock/packing_page.dart';
import 'package:mayer_wm/views/stock/quantity_transfer.dart';
import 'package:mayer_wm/views/stock/shift_out_page.dart';
import 'package:mayer_wm/views/stock/shift_put_page.dart';
import 'package:mayer_wm/views/stock/stock_page.dart';

class MenuPermissions {
  static void getMenu() async {}

  static getMenuChild(list){

    var menu = [];
    for (var i  in jsonDecode(list)) {
      var obj = {
        "icon": i['cuIcon'],
        "text": i["name"],
        "parentId": i['parent'],
        "color": Colors.pink.withOpacity(0.7),
        "router": i['path'],
        "source": i['source'],
      };
      menu.add(obj);
      /*switch (i['id']) {
        case 13:
          var obj = {
            "icon": Icons.add_shopping_cart,
            "text": "采购入库",
            "parentId": 2,
            "color": Colors.pink.withOpacity(0.7),
            "router": PurchaseWarehousingPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 11:
          var obj = {
            "icon": Icons.add_alarm,
            "text": "成品备货",
            "parentId": 3,
            "color": Colors.pink.withOpacity(0.7),
            "router": StockUpPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 15:
          var obj = {
            "icon": Icons.assignment,
            "text": "生产领料",
            "parentId": 4,
            "color": Colors.pink.withOpacity(0.7),
            "router": PickingPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 16:
          var obj = {
            "icon": Icons.attachment,
            "text": "编码转移",
            "parentId": 4,
            "color": Colors.pink.withOpacity(0.7),
            "router": EncodingTransfer(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 17:
          var obj = {
            "icon": Icons.chrome_reader_mode,
            "text": "成品入库",
            "parentId": 4,
            "color": Colors.pink.withOpacity(0.7),
            "router": WarehousingPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 18:
          var obj = {
            "icon": Icons.autorenew,
            "text": "生产移转",
            "parentId": 4,
            "color": Colors.pink.withOpacity(0.7),
            "router": QuantityTransfer(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 7:
          var obj = {
            "icon": Icons.switch_camera,
            "text": "寄库",
            "parentId": 5,
            "color": Colors.pink.withOpacity(0.7),
            "router": CustodyWarehousingPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 8:
          var obj = {
            "icon": Icons.streetview,
            "text": "寄库领出",
            "parentId": 5,
            "color": Colors.pink.withOpacity(0.7),
            "router": CustodyStockingDetail(FBillNo: null, tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 41:
          var obj = {
            "icon": Icons.business,
            "text": "寄库退回",
            "parentId": 5,
            "color": Colors.pink.withOpacity(0.7),
            "router": CustodyReturnDetail(FBillNo: null, tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 42:
          var obj = {
            "icon": Icons.open_in_browser,
            "text": "管材上架",
            "parentId": 5,
            "color": Colors.pink.withOpacity(0.7),
            "router": PipeShelvingPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 43:
          var obj = {
            "icon": Icons.system_update_alt,
            "text": "管材下架",
            "parentId": 5,
            "color": Colors.pink.withOpacity(0.7),
            "router": PipeRemovalPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 44:
          var obj = {
            "icon": Icons.system_update_alt,
            "text": "管材下架",
            "parentId": 5,
            "color": Colors.pink.withOpacity(0.7),
            "router": PipeRemovalPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 9:
          var obj = {
            "icon": Icons.dashboard,
            "text": "仓库调拨",
            "parentId": 5,
            "color": Colors.pink.withOpacity(0.7),
            "router": AllocationPage(tranType: i['source']),
            "source": "",
          };
          menu.add(obj);
          break;
        case 10:
          var obj = {
            "icon": Icons.exit_to_app,
            "text": "移库",
            "parentId": 5,
            "color": Colors.pink.withOpacity(0.7),
            "router": ShiftPutPage(FBillNo: null, tranType: i['source']),
            "source": '',
          };
          menu.add(obj);
          break;
        case 19:
            var obj = {
              "icon": Icons.grid_on,
              "text": "库存查询",
              "parentId": 6,
              "color": Colors.pink.withOpacity(0.7),
              "router": StockPage(),
              "source": '',
            };
            menu.add(obj);
          break;
        case 25:
            var obj = {
              "icon": Icons.view_quilt,
              "text": "装箱查询",
              "parentId": 6,
              "color": Colors.pink.withOpacity(0.7),
              "router": PackingPage(),
              "source": '',
            };
            menu.add(obj);
          break;
      }*/
    }
    /*menu.add({
      "icon": "flight_land",
      "text": "条码入库",
      "parentId": 5,
      "color": Colors.pink.withOpacity(0.7),
      "router": "BarcodeStorage",
      "source": '',
    });
    menu.add({
      "icon": "flight_takeoff",
      "text": "条码出库",
      "parentId": 5,
      "color": Colors.pink.withOpacity(0.7),
      "router": "BarcodeOutbound",
      "source": '',
    });*/
    /*menu.add({2
      "icon": Icons.loupe,
      "text": "外购入库",
      "parentId": 1,
      "color": Colors.pink.withOpacity(0.7),
      "router": PurchaseWarehousingPage(),
      "source": "",
    });
    menu.add({
      "icon": Icons.loupe,
      "text": "外购入库无源单",
      "parentId": 1,
      "color": Colors.pink.withOpacity(0.7),
      "router": PurchaseWarehousingDetail(FBillNo: null),
      "source": "",
    });
    menu.add({
      "icon": Icons.loupe,
      "text": "销售出库",
      "parentId": 2,
      "color": Colors.pink.withOpacity(0.7),
      "router": RetrievalPage(),
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "销售出库无源单",
      "parentId": 2,
      "color": Colors.pink.withOpacity(0.7),
      "router": RetrievalDetail(FBillNo: null),
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "领料",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": PickingPage(),
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "领料无源单",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": PickingDetail(FBillNo: null),
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "产品入库",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": WarehousingPage(),
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "产品入库无源单",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": WarehousingDetail(FBillNo: null),
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "盘盈单",
      "parentId": 4,
      "color": Colors.pink.withOpacity(0.7),
      "router": "",
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "盘亏单",
      "parentId": 4,
      "color": Colors.pink.withOpacity(0.7),
      "router": "",
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "调拨",
      "parentId": 4,
      "color": Colors.pink.withOpacity(0.7),
      "router": AllocationPage(),
      "source": "",
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "调拨无源单",
      "parentId": 4,
      "color": Colors.pink.withOpacity(0.7),
      "router": AllocationDetail(),
      "source": '',
    });

    menu.add({
      "icon": Icons.loupe,
      "text": "库存查询",
      "parentId": 5,
      "color": Colors.pink.withOpacity(0.7),
      "router": StockPage(),
      "source": '',
    });*/
    return menu;
  }
}
