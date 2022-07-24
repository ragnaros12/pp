import 'package:hexagon/hexagon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:EdiScan/ui/pages/display_code_page/display_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/common_helper.dart';
import '../../bottom_navigation/bloc/bottom_bloc.dart';
import '../../bottom_navigation/bloc/bottom_event.dart';
import '../history_code_page/bloc/code_bloc.dart';
import '../history_code_page/bloc/code_event.dart';


class ScanCodePage extends StatelessWidget with WidgetsBindingObserver{

  MobileScannerController controller = MobileScannerController(formats: [BarcodeFormat.all]);

  ScanCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool cameraStop = false;
    MobileScanner scanner = MobileScanner(allowDuplicates: false, onDetect:  (code, args) async{
      if(!cameraStop) {
        cameraStop = true;
        await controller.stop();
        String date = Helper.format.format(DateTime.now());
        context.read<CodeBloc>().add(Add(code, date));
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                DisplayCodePage(Helper.getValueFromType(code), date,
                    Helper.getDisplayFormat(code.format), code.type.name
                )
            )
        );
        await controller.start();
        cameraStop = false;
      }
    }, controller: controller,);
    return Stack(
      children: [
        scanner,
        Align(
          alignment: Alignment.center,
            child: ClipRect(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.black45
                ),
                width: MediaQuery.of(context).size.width / 1.5,
                height: MediaQuery.of(context).size.width / 1.5,
              ),
            )
        ),
        Container(
            color: Colors.black87,
            margin: const EdgeInsets.all(20),
            height: 50,
            child: Stack(
              children: [
                flash(),
                switchCamera(),
                openImage(context)
              ],
            )
        )
      ],
    );
  }
  Widget flash(){
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                  margin: const EdgeInsets.all(5),
                  child: ValueListenableBuilder(
                    valueListenable: controller.torchState,
                    builder: (context, state, child) {
                      switch (state as TorchState) {
                        case TorchState.off:
                          return const Icon(Icons.flash_off, color: Colors.white, size: 30,);
                        case TorchState.on:
                          return const Icon(Icons.flash_on, color: Colors.white, size: 30,);
                      }
                    },
                  )
              ),
              onTap: () {
                controller.toggleTorch();
              },
            )
        ),
        margin: const EdgeInsets.only(left: 5),
      )
    );
  }

  Widget switchCamera(){
    return Align(
        alignment: Alignment.center,
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                margin: const EdgeInsets.all(5),
                child: ValueListenableBuilder(
                  valueListenable: controller.cameraFacingState,
                  builder: (context, state, child) {
                    switch (state as CameraFacing) {
                      case CameraFacing.front:
                        return const Icon(Icons.camera_front, color: Colors.white, size: 30,);
                      case CameraFacing.back:
                        return const Icon(Icons.photo_camera_back, color: Colors.white, size: 30,);
                    }
                  },
                ),
              ),
              onTap: () {
                controller.switchCamera();
              },
            )
        )
    );
  }


  Widget openImage(BuildContext context){
    return Align(
        alignment: Alignment.centerRight,
        child: Container(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                  margin: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.document_scanner,
                    color: Colors.white,
                    size: 30,
                  )
              ),
              onTap: () async {
                XFile? image = await Helper.imagePicker.pickImage(
                    source: ImageSource.camera);

                Helper.analyzeImage(image!.path, context);
              },
            ),
          ),
          margin: const EdgeInsets.only(right: 5),
        )
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    controller.start();
  }
}