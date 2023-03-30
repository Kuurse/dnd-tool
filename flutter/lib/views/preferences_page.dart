
import 'package:dnd_helper/tools/IntFormFieldValidator.dart';
import 'package:dnd_helper/views/components/dnd_text_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController partySizeController = TextEditingController();
  final TextEditingController partyLevelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PreferencesPage({Key? key}) : super(key: key){
    _setFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Preferences"),
        ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            DndTextField(
              "Nom",
              controller: nameController,
              onChanged: (text) async {
                if (text != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('name', text);
                }
              },
            ),
            DndTextField(
              "Taille de votre groupe",
              validator: IntFormFieldValidator.validateUint,
              controller: partySizeController,
              onChanged: (text) async {
                if (_formKey.currentState!.validate()){
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('partySize', int.parse(text!));
                }
              },
            ),
            DndTextField(
              "Niveau de votre groupe",
              validator: IntFormFieldValidator.validateUint,
              controller: partyLevelController,
              onChanged: (text) async {
                if (_formKey.currentState!.validate()){
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('partyLevel', int.parse(text!));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setFields() async {
    final prefs = await SharedPreferences.getInstance();
    var name = prefs.getString('name');
    if (name != null) {
      nameController.text = name;
    }

    var size = prefs.getInt('partySize');
    if (size != null){
      partySizeController.text = size.toString();
    }

    var level = prefs.getInt('partyLevel');
    if (level != null){
      partyLevelController.text = level.toString();
    }
  }
}
