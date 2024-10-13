import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mayer_wm/views/index/index_page.dart';
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
class MenuRouts{
  static getRouts(){
    Map routes = {
      "PurchaseWarehousingPage": (content, {arguments}) => PurchaseWarehousingPage(tranType: arguments),
      "StockUpPage": (content, {arguments}) => StockUpPage(tranType: arguments),
      "PickingPage": (context, {arguments}) => PickingPage(tranType: arguments),
      "WarehousingPage": (context, {arguments}) => WarehousingPage(tranType: arguments),
      "QuantityTransfer": (context, {arguments}) => QuantityTransfer(tranType: arguments),
      "CustodyWarehousingPage": (context, {arguments}) => CustodyWarehousingPage(tranType: arguments),
      "CustodyStockingDetail": (context, {arguments}) => CustodyStockingDetail(FBillNo: null,tranType: arguments),
      "CustodyReturnDetail": (context, {arguments}) => CustodyReturnDetail(FBillNo: null,tranType: arguments),
      "PipeShelvingPage": (context, {arguments}) => PipeShelvingPage(tranType: arguments),
      "PipeRemovalPage": (context, {arguments}) => PipeRemovalPage(tranType: arguments),
      "AllocationPage": (context, {arguments}) => AllocationPage(tranType: arguments),
      "ShiftPutPage": (context, {arguments}) => ShiftPutPage(FBillNo: null,tranType: arguments),
      "ListingPage": (context, {arguments}) => ListingPage(FBillNo: null,tranType: arguments),
      "OffshelfPage": (context, {arguments}) => OffshelfPage(tranType: arguments),
      "StockPage": (context) => StockPage(),
      "PackingPage": (context) => PackingPage(),
    };
    // 定义一个函数，并返回MaterialPageRoute
    var onGenerateRoute = (RouteSettings settings) {
      var pageBuilder = routes[settings.name];
      if (pageBuilder != null) {
        if (settings.arguments != null) {
          // 创建路由页面并携带参数
          return MaterialPageRoute(
              builder: (context) =>
                  pageBuilder(context, arguments: settings.arguments));
        } else {
          return MaterialPageRoute(builder: (context) => pageBuilder(context));
        }
      }
      return MaterialPageRoute(builder: (context) => IndexPage());
    };
    return onGenerateRoute;
  }
}