import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum DialButtonType {
  number,
  call,
  callCancel,
  back,
  none,
  callingActive,
  callingInactive,
  phishingScore
}

class DialButton extends StatelessWidget {
  DialButton(
      {required this.buttonType,
      required this.content,
      required this.subContent,
      required this.onPressed,
      Color? backgroundColor,
      super.key});

  final buttonType;
  final Function()? onPressed;
  final content;
  final subContent;

  Color getPhishingColor(int score) {
    if (score >= 80) {
      return const Color(0xfffe463a);
    } else
      return Colors.grey.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double fontSize = size.width / 11;
    double subFontSize = size.width / 36;
    if (buttonType == DialButtonType.none) {
      return const SizedBox();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: CircleAvatar(
              backgroundColor: buttonType == DialButtonType.number
                  ? const Color(0xffe5e5e5)
                  : buttonType == DialButtonType.call
                      ? const Color(0xff32c759)
                      : buttonType == DialButtonType.callingActive
                          ? const Color(0xff32c759)
                          : buttonType == DialButtonType.callingInactive
                              ? Colors.grey.withOpacity(0.3)
                              : buttonType == DialButtonType.callCancel
                                  ? const Color(0xfffe463a)
                                  : buttonType == DialButtonType.phishingScore
                                      ? (getPhishingColor(
                                          int.tryParse(content) ?? 0))
                                      : Colors.transparent,
              radius: size.width / 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (buttonType == DialButtonType.phishingScore)
                    Text(
                      "$content",
                      style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          height: 1),
                    ),
                  buttonType == DialButtonType.number
                      ? Column(
                          children: [
                            Text(
                              "$content",
                              style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w400,
                                  height: 1),
                            ),
                            subContent != ""
                                ? Text(
                                    "$subContent",
                                    style: TextStyle(
                                        fontSize: subFontSize,
                                        fontWeight: FontWeight.bold,
                                        height: 1),
                                  )
                                : const SizedBox()
                          ],
                        )
                      : buttonType == DialButtonType.call ||
                              buttonType == DialButtonType.callCancel
                          ? Icon(
                              content,
                              size: fontSize,
                              color: Colors.white,
                            )
                          : buttonType == DialButtonType.callingActive ||
                                  buttonType == DialButtonType.callingInactive
                              ? Icon(
                                  content,
                                  size: fontSize,
                                  color: Colors.white,
                                )
                              : buttonType == DialButtonType.back
                                  ? Image.asset(
                                      content,
                                      width: fontSize * 1.2,
                                    )
                                  : const SizedBox(),
                ],
              )),
        ),
        if (buttonType == DialButtonType.callingActive ||
            buttonType == DialButtonType.callingInactive ||
            buttonType == DialButtonType.phishingScore)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              subContent,
              maxLines: 1,
              style: TextStyle(color: Colors.white, fontSize: fontSize * 0.45),
            ),
          )
      ],
    );
  }
}
