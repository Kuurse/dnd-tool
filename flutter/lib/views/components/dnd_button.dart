
import 'package:flutter/material.dart';

class DndButton extends StatelessWidget {
  String text;
  MaterialStatesController? statesController;
  Clip clipBehavior;
  bool autofocus;
  FocusNode? focusNode;
  Color? backgroundColor;
  Color shadowColor;
  void Function(bool?)? onFocusChange;
  void Function(bool?)? onHover;
  void Function()? onPressed;
  void Function()? onLongPress;

  DndButton({
    Key? key,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    this.backgroundColor = Colors.black,
    this.shadowColor = Colors.black,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shadowColor: shadowColor,
        disabledForegroundColor: Colors.red,
      ),
      onFocusChange: onFocusChange,
      onHover: onHover,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      key: key,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white
        ),
      ),
    );
  }
}

