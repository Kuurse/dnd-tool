
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DndTextField extends StatelessWidget {
  String label;
  String? hint;
  String? Function(String?)? validator;
  void Function(String?)? onChanged;
  TextInputType? keyboardType;
  TextEditingController? controller;
  List<TextInputFormatter>? inputFormatters;


  DndTextField(this.label, {Key? key, this.hint, this.validator, this.onChanged, this.keyboardType, this.controller, this.inputFormatters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                border: const OutlineInputBorder(),
                hintStyle: const TextStyle(color: Color(0XFFADADAD)),
                hintText: hint ?? label,
                label: Text(label),
              ),
              onChanged: onChanged,
              validator: validator,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
