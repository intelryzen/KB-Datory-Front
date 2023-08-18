import 'package:aitest/controller/record_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'dial/dial_button.dart';

class CallingScreen extends StatefulWidget {
  final Function() onPressed;
  final String phoneNumber;

  const CallingScreen(
      {required this.phoneNumber, required this.onPressed, super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  final RecordController recordController = Get.find();
  int time = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double fontSize = size.width / 12;

    return Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          time = recordController.recordingTime.value;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 10),
              child: Column(
                children: [
                  Expanded(
                      flex: 3,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.phoneNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: fontSize, color: Colors.white),
                          ),
                          Text(
                            time == 0
                                ? "연결 중..."
                                : "${(time ~/ 60).toString().padLeft(2, "0")}:${(time % 60).toString().padLeft(2, "0")}",
                            style: TextStyle(
                                fontSize: fontSize * 0.65, color: Colors.grey),
                          ),
                        ],
                      ))),
                  Expanded(
                      flex: 5,
                      child: GridView.count(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 0,
                        childAspectRatio: 0.8,
                        children: [
                          DialButton(
                              buttonType: recordController.isRecording.isTrue
                                  ? DialButtonType.callingActive
                                  : DialButtonType.callingInactive,
                              content: MdiIcons.dominoMask,
                              subContent: !recordController.recorderIsInited ||
                                      recordController.isRecording.isFalse
                                  ? "준비중"
                                  : "피싱 감지${recordController.isRecording.isTrue ? "중" : "시작"}",
                              onPressed: () {
                                if (!recordController.recorderIsInited) {
                                  Fluttertoast.showToast(
                                      msg: "녹음 준비 중입니다.");
                                } else if (recordController
                                    .isRecording.isFalse) {
                                  recordController.startRecord();
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "감지 중에는 종료할 수 없습니다.");
                                }
                              }),
                          DialButton(
                              buttonType: DialButtonType.phishingScore,
                              content: recordController.isRecording.isTrue
                                  ? "${recordController.score}"
                                  : "-",
                              subContent: "피싱 확률",
                              onPressed: () {}),
                          DialButton(
                              buttonType: DialButtonType.callingInactive,
                              content: Icons.volume_up,
                              subContent: "스피커",
                              onPressed: () {}),
                          DialButton(
                              buttonType: DialButtonType.none,
                              content: "",
                              subContent: "",
                              onPressed: null),
                          DialButton(
                              buttonType: DialButtonType.none,
                              content: "",
                              subContent: "",
                              onPressed: null),
                          DialButton(
                              buttonType: DialButtonType.none,
                              content: "",
                              subContent: "",
                              onPressed: null),
                          DialButton(
                              buttonType: DialButtonType.none,
                              content: "",
                              subContent: "",
                              onPressed: null),
                          DialButton(
                              buttonType: DialButtonType.callCancel,
                              content: MdiIcons.phoneHangup,
                              subContent: "",
                              onPressed: widget.onPressed),
                        ],
                      )),
                ],
              ),
            ),
          );
        }));
  }

  @override
  void initState() {
    recordController.openRecorder(widget.phoneNumber);
    super.initState();
  }

  @override
  void dispose() {
    recordController.closeRecorder();
    super.dispose();
  }
}
