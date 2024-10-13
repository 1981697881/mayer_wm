import 'package:flutter/material.dart';
class TextSpanShow extends StatefulWidget {
  final String text;
  final Color? colorTest;
  final Color? ellipsisColorTest;
  final Color? moreBackgroundTest;
  final Color? moreContainerColor;
  final int mMaxLine;
  final bool? showColor;
  final TextStyle? styleText;
  final double? textSpanWidth;
  final double? textSpanHeight;

  const TextSpanShow(this.text,
  {Key ?key,
  required this.mMaxLine,
  this.colorTest,
  this.ellipsisColorTest,
  this.moreBackgroundTest,
  this.moreContainerColor,
  this.showColor,
  this.styleText,
  this.textSpanWidth,
  this.textSpanHeight}) : super(key: key);

  @override
  State<TextSpanShow> createState() => _TextSpanShowState();
}

class _TextSpanShowState extends State<TextSpanShow> {
  bool mIsExpansion = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.textSpanWidth,
      height: widget.textSpanHeight,
      color: widget.moreContainerColor,
      child: richText(
        widget.text,
      ),
    );
  }

  Widget richText(String text) {
    if (isExpansion(text)) {
      //如果需要截断
      if (mIsExpansion) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(
                  text,
                  maxLines: 100,
                  textAlign: TextAlign.left,
                  style: widget.styleText ?? TextStyle(color: widget.colorTest),
                )),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _isShowText();
              },
              child: Container(
                alignment: Alignment.bottomRight,
                width: 70,
                height: 30,
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
          ],
        );
      } else {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(
                  text,
                  maxLines: widget.mMaxLine,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: widget.styleText ??
                      TextStyle(
                          color: widget.ellipsisColorTest ?? widget.colorTest),
                )),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _isShowText();
              },
              child: Container(
                alignment: Alignment.bottomRight,
                width: 70,
                height: 30,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
          ],
        );
      }
    } else {
      return Text(
        text,
        maxLines: widget.mMaxLine,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: widget.styleText ?? const TextStyle(color: Colors.black),
      );
    }
  }

  bool isExpansion(String text) {
    TextPainter textPainter = TextPainter(
        maxLines: widget.mMaxLine,
        text: TextSpan(
            text: text,
            style: const TextStyle(fontSize: 16.0, color: Colors.black)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: 750, minWidth: 750);
    if (textPainter.didExceedMaxLines) {
      //这里判断 文本是否截断
      return true;
    } else {
      return false;
    }
  }

  void _isShowText() {
    if (mIsExpansion) {
      //关闭了
      setState(() {
        mIsExpansion = false;
      });
    } else {
      setState(() {
        mIsExpansion = true;
      });
    }
  }
}

