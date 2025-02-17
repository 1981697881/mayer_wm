import 'package:shared_preferences/shared_preferences.dart';

class API {
  Future<String> LOGIN_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/login';
  }
 /* String LOGIN_URL() {
    return sharedPreferences.getString('url') + '/Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
  }*/
  //单据查询
  Future<String> CURRENCY_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/billList/queryBillList';
  }//单据装箱查询
  Future<String> CURRENCYPICK_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/billList/queryBillListP';
  }
  //盘点方案查询
  Future<String> CURRENCY_INVURL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/invCheck/invProject';
  }//盘点方案明细查询
  Future<String> CURRENCY_INVLIST() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/invCheck/invCheckList';
  }
  //获取单号
  Future<String> ORDERNO_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/billList/getBillNo';
  }
  //获取菜单
  Future<String> PERMISSION_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/sysMenu/getSysMenuById';
  }
  //获取库存
  Future<String> INVENTORY_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/basic/inventory';
  }//物料查询
  Future<String> ITEM_LIST() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/item/itemList/1/50';
  }
  //扫码获取库存
  Future<String> SCANINVENTORY_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/basic/inventoryByBarcode';
  }
 //获取部门
  Future<String> DEPT_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/basic/deptList';
  }
 //获取仓库
  Future<String> STOCK_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/basic/stockList';
  }
 //获取客户
  Future<String> CUSTOMER_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/basic/customerList';
  }
 //获取供应商
  Future<String> SUPPLIER_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/basic/supplierList';
  }
  //采购保存
  Future<String> SAVE_PURCHASE() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/purchaseStockIn';
  }//销售保存
  Future<String> SAVE_SALES() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/saleStockOut';
  }//生产保存
  Future<String> SAVE_PRODUCT() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/productStockIn';
  }//领料保存
  Future<String> SAVE_PICKING() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/pickingStockOut';
  }//调拨保存
  Future<String> SAVE_TRANS() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/addTrans';
  }//盘点保存
  Future<String> INV_CHECK() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/invCheck/invCheckQty';
  }//条码查询
  Future<String> SCAN_BARCODE() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/basic/barcodeScan';
  }//条码库存查询
  Future<String> SCAN_INVBARCODE() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/inventory/barcodeScan';
  }//其他入库
  Future<String> SAVE_STOCKIN() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/otherStockIn';
  }//其他出库
  Future<String> SAVE_STOCKOUT() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/otherStockOut';
  }//推荐库位
  Future<String> RECOMENT_STOCKPATH() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/recomentSPPath';
  }//历史库位
  Future<String> RECOMENT_STOCKPLACE() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/recomentStockPlace';
  }//上架
  Future<String> ON_FRAME() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/inventory/onFrame';
  }//下架
  Future<String> UNDER_FRAME() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/inventory/underFrame';
  }
  //查询条码清单
  Future<String> BARCODE_SCAN() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/barcodelist/barcodeScan';
  }//条码清单保存
  Future<String> BARCODE_SAVE() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/barcodelist/saveBarcodeEntry';
  }
  //查询库位
  Future<String> STOCK_PLACE() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/basic/stockPlaceList';
  }
  //装箱
  Future<String> PACK_BOX() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/packToBox';
  }
  //获取装箱清单
  Future<String> GET_BOXLIST() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/getToBoxList';
  }
  //更新装箱清单
  Future<String> UPDATE_BOX() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/updateBoxListPrintcount';
  } //理货
  Future<String> PRE_STOCKOUT() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/stockBill/preStockOut';
  } //移库
  Future<String> MOVE_POSIIIONS() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/inventory/movePositions';
  }//获取单据类型
  Future<String> GET_BILLTYPE() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/api/billList/getBillType';
  }
  //提交
  Future<String> SAVE_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc';
  }
  //保存
  Future<String> SUBMIT_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Submit.common.kdsvc';
  }

//下推
  Future<String> DOWN_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Push.common.kdsvc';
  }

//审核
  Future<String> AUDIT_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Audit.common.kdsvc';
  }

//反审核
  Future<String> UNAUDIT_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.UnAudit.common.kdsvc';
  }

//删除
  Future<String> DELETE_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Delete.common.kdsvc';
  }

//修改状态
  Future<String> STATUS_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExcuteOperation.common.kdsvc';
  }

  /* static const String LOGIN_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
  //通用查询
  static const String CURRENCY_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExecuteBillQuery.common.kdsvc';
  //提交
  static const String SAVE_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc';
  //保存
  static const String SUBMIT_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Submit.common.kdsvc';
  //下推
  static const String DOWN_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Push.common.kdsvc';
  //审核
  static const String AUDIT_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Audit.common.kdsvc';
  //反审核
  static const String UNAUDIT_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.UnAudit.common.kdsvc';
  //删除
  static const String DELETE_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Delete.common.kdsvc';
  //修改状态
  static const String STATUS_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExcuteOperation.common.kdsvc';*/
  //版本查询
  static const String VERSION_URL =
      'https://www.pgyer.com/apiv2/app/check?_api_key=dd6926b00c3c3f22a0ee4204f8aaad88&appKey=f1ac53541819f992d43b73b9f9008a8d';
  //授权查询 authorize
  static const String AUTHORIZE_URL =
      'http://auth.gzfzdev.com:50022/web/auth/findAuthMessage';
}
