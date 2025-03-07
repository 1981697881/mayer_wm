import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuIcon{
  static getIcon(){
    // 映射表，将字符串映射到对应的IconData
    final Map<String, IconData> iconMap = {
      'add_shopping_cart': Icons.add_shopping_cart,
      'add_alarm': Icons.add_alarm,
      'assignment': Icons.assignment,
      'chrome_reader_mode': Icons.chrome_reader_mode,
      'autorenew': Icons.autorenew,
      'switch_camera': Icons.switch_camera,
      'streetview': Icons.streetview,
      'business': Icons.business,
      'open_in_browser': Icons.open_in_browser,
      'system_update_alt': Icons.system_update_alt,
      'dashboard': Icons.dashboard,
      'exit_to_app': Icons.exit_to_app,
      'grid_on': Icons.grid_on,
      'view_quilt': Icons.view_quilt,
      'vertical_align_top': Icons.vertical_align_top,
      'vertical_align_bottom': Icons.vertical_align_bottom,
      'flip': Icons.flip,
      'flight_land': Icons.flight_land,
      'flight_takeoff': Icons.flight_takeoff,
    };
    return iconMap;

  }
}