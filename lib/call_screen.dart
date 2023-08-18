import 'dart:convert';

import 'package:aitest/controller/record_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dial/dial_button.dart';
import 'package:http/http.dart' as http;

class CallScreen extends StatefulWidget {
  final Function() onPressed;
  final Function() onAcceptPressed;
  final String phoneNumber;

  const CallScreen(
      {required this.phoneNumber,
      required this.onAcceptPressed,
      required this.onPressed,
      super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final String _serverUrl = "http://192.168.0.12:8080/api/check-phone/";

  final RecordController recordController = Get.find();
  bool loading = true;
  int phishingCount = -1;

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
                      flex: 6,
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
                            "대한민국",
                            style: TextStyle(
                                fontSize: fontSize * 0.65, color: Colors.grey),
                          ),
                        ],
                      ))),
                  Expanded(
                      flex: 8,
                      child: Center(
                          child: loading
                              ? Text(
                                  "보이스피싱 조회중...",
                                  style: TextStyle(
                                      fontSize: fontSize * 0.65,
                                      color: Colors.white),
                                )
                              : phishingCount == -1
                                  ? Text(
                                      "보이스피싱 조회에 실패했습니다.",
                                      style: TextStyle(
                                          fontSize: fontSize * 0.65,
                                          color: Colors.white),
                                    )
                                  : phishingCount == 0
                                      ? Text(
                                          "신고 내역이 존재하지 않습니다",
                                          style: TextStyle(
                                              fontSize: fontSize * 0.65,
                                              color: Colors.white),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.warning,
                                                  color: Colors.amberAccent,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 6.0),
                                                  child: Text(
                                                    "주의!",
                                                    style: TextStyle(
                                                        fontSize:
                                                            fontSize * 0.65,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 12.0),
                                              child: Text(
                                                "보이스피싱 $phishingCount회 신고 접수",
                                                style: TextStyle(
                                                    fontSize: fontSize * 0.65,
                                                    color: Colors.white),
                                              ),
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
                              buttonType: DialButtonType.call,
                              content: MdiIcons.phone,
                              subContent: "",
                              onPressed: widget.onAcceptPressed),
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
    _checkVoicePhishing();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkVoicePhishing() async {
    try {
      http.Response response = await http.post(
        Uri.parse("$_serverUrl?target_phone=${widget.phoneNumber}"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        if (data["success"] == true) {
          phishingCount = data["result"];
        }
      }
    } catch (error) {
      print(error);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    loading = false;
    setState(() {});
  }
}
