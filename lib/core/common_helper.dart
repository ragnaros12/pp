import 'package:EdiScan/core/dao/database_helper.dart';
import 'package:EdiScan/core/dao/entity/code.dart';
import 'package:EdiScan/ui/pages/list_code_page/list_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../ui/pages/display_code_page/display_code_page.dart';
import '../ui/pages/history_code_page/bloc/code_bloc.dart';
import '../ui/pages/history_code_page/bloc/code_event.dart';

class Helper{
  static DateFormat format = DateFormat("dd-MM-yyyy HH:mm:ss");
  static MobileScannerController? _controllerFiles;
  static ImagePicker imagePicker = ImagePicker();


  static void analyzeImage(String path, BuildContext context) async{
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("сканинг")));
    List<Code> data = [];
    if(_controllerFiles == null){
      _controllerFiles = MobileScannerController(formats: [BarcodeFormat.all]);
      _controllerFiles!.stop();
      _controllerFiles!.barcodes.listen((event) {
        String text = Helper.getValueFromType(event);
        Code code = Code(null, text, Helper.format.format(DateTime.now()), Helper.getDisplayFormat(event.format), event.type.name);
        DbHelper.daoCodeService().insert(code);
        data.add(code);
      });

    }

    if(await _controllerFiles!.analyzeImage(path)){
      await Future.delayed(const Duration(milliseconds: 500));

      await Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              ListCodePage(data)
          )
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("на изображении нет кода")));
    }
  }


  static String getDisplayFormat(BarcodeFormat format){
    switch(format){
      case BarcodeFormat.dataMatrix:
        return "матрикс код";
      case BarcodeFormat.qrCode:
        return "qr код";
      case BarcodeFormat.codebar:
        return "баркод";
    }
    return format.name;
  }
  static BarcodeType decodeType(String type){
    return BarcodeType.values.firstWhere((element) => element.name == type);
  }
  static IconData getIconFromType(BarcodeType type){
    switch(type){
      case BarcodeType.url:
        return Icons.link;
      case BarcodeType.email:
        return Icons.email;
    }
    return Icons.text_fields;
  }
  static String getDisplayStringFromType(BarcodeType type){
    switch(type){
      case BarcodeType.url:
        return "Веб-сайт";
      case BarcodeType.email:
        return "Email";
    }
    return "Текст";
  }
  static String getValueFromType(Barcode code){
    switch(code.type){
      case BarcodeType.url:
        return code.url!.url!;
      case BarcodeType.email:
        return code.email!.address!;
    }
    return code.rawValue!;
  }

}