import 'package:flutter/material.dart';

import '../../../core/dao/entity/code.dart';
import '../../widgets/list_code_widget.dart';

class ListCodePage extends StatelessWidget {

  List<Code> codes;


  ListCodePage(this.codes, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Коды")),
        body:
        Container(
          child: ListCodeWidget(codes,false),
          margin: const EdgeInsets.only(bottom: 100),
        )
    );
  }

}