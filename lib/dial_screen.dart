import 'package:aitest/call_screen.dart';
import 'package:aitest/calling_screen.dart';
import 'package:aitest/dial/dial_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialScreen extends StatefulWidget {
  const DialScreen({super.key});

  @override
  State<DialScreen> createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  List subContents = [
    " ",
    "A B C",
    "D E F",
    "G H I",
    "J K L",
    "M N O",
    "P Q R S",
    "T U V",
    "W X Y Z",
    "",
    "+",
    ""
  ];
  String text = "";
  bool isCalling = false;
  bool isCall = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double fontSize = size.width / 12;
    return isCall
        ? CallScreen(
            phoneNumber: text,
            onAcceptPressed: () async {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  isCall = false;
                  isCalling = true;
                });
              });
            },
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 300));
              setState(() {
                isCall = false;
                isCalling = false;
              });
            },
          )
        : isCalling
            ? CallingScreen(
                phoneNumber: text,
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 300));
                  setState(() {
                    isCalling = false;
                  });
                },
              )
            : Scaffold(
                body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 10),
                  child: Column(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Center(
                              child: Text(
                            "$text",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: fontSize),
                          ))),
                      Expanded(
                          flex: 5,
                          child: GridView.count(
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            children: [
                              ...List<Widget>.generate(
                                  9,
                                  (index) => DialButton(
                                      buttonType: DialButtonType.number,
                                      content: "${index + 1}",
                                      subContent: subContents[index],
                                      onPressed: () {
                                        insertText("${index + 1}");
                                      })),
                              DialButton(
                                  buttonType: DialButtonType.number,
                                  content: "*",
                                  subContent: "",
                                  onPressed: () {
                                    insertText("*");
                                  }),
                              DialButton(
                                  buttonType: DialButtonType.number,
                                  content: "0",
                                  subContent: "+",
                                  onPressed: () {
                                    insertText("0");
                                  }),
                              DialButton(
                                  buttonType: DialButtonType.number,
                                  content: "#",
                                  subContent: "",
                                  onPressed: () async {
                                    // insertText("#");
                                    if (text.isEmpty) return;
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
                                    setState(() {
                                      isCall = true;
                                    });
                                  }),
                              DialButton(
                                  buttonType: DialButtonType.none,
                                  content: "",
                                  subContent: "",
                                  onPressed: null),
                              DialButton(
                                  buttonType: DialButtonType.call,
                                  content: Icons.call,
                                  subContent: "",
                                  onPressed: () async {
                                    if (text.isEmpty) return;
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
                                    setState(() {
                                      isCalling = true;
                                      isCall = false;
                                    });
                                  }),
                              DialButton(
                                  buttonType: text.isEmpty
                                      ? DialButtonType.none
                                      : DialButtonType.back,
                                  content: "assets/images/back.png",
                                  subContent: "",
                                  onPressed: () {
                                    cancelText();
                                  }),
                            ],
                          )),
                    ],
                  ),
                ),
              ));
  }

  void cancelText() {
    if (text.isEmpty) return;
    if (text.length <= 3) {
      text = text.substring(0, text.length - 1);
    } else {
      if (text[text.length - 2] == "-") {
        text = text.substring(0, text.length - 2);
      } else {
        text = text.substring(0, text.length - 1);
      }
      insertText("");
    }

    setState(() {});
  }

  void insertText(String insertText) {
    text = "$text$insertText";
    text = text.replaceAll('-', '');
    if (text.length > 3) {
      if (text.length <= 7) {
        text = "${text.substring(0, 3)}-${text.substring(3, text.length)}";
      } else if (text.length <= 11) {
        text =
            "${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7, text.length)}";
      }
    }
    setState(() {});
  }
}
