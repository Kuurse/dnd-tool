
// ignore_for_file: prefer_const_constructors

import 'package:dnd_helper/views/components/dnd_text_field.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';

import 'components/dnd_button.dart';

class CustomMonsterForm extends StatelessWidget {
  CustomMonsterForm({Key? key}) : super(key: key);

  /// var mod = partySize/basePartySize;
  /// var newMonster = Monster.fromJson(toJson());
  /// newMonster.hitPoints = ((hitPoints!/basePartySize)*partySize).round();
  /// var ogMulti = multiattack ?? getAttackPerTurnCount();
  /// newMonster.multiattack = ogMulti*mod;
  /// newMonster.xp = (xp*mod).round();
  /// return newMonster;
  ///
  ///

  TextEditingController hpController = TextEditingController();
  TextEditingController? nameController = TextEditingController();
  TextEditingController? multiAttController = TextEditingController();
  TextEditingController? crController = TextEditingController();
  TextEditingController? caController = TextEditingController();

  TextEditingController? strController = TextEditingController();
  TextEditingController? intController = TextEditingController();
  TextEditingController? wisController = TextEditingController();
  TextEditingController? dexController = TextEditingController();
  TextEditingController? conController = TextEditingController();
  TextEditingController? chaController = TextEditingController();

  num? cr;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Nouveau monstre"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column (
            children: [
              DndTextField(
                "Nom",
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              DndTextField(
                "HP",
                controller: hpController,
                validator: validateRequiredInt,
              ),
              DndTextField(
                "CA",
                controller: caController,
                validator: validateRequiredInt,
              ),
              StatInput(
                strController: strController,
                intController: intController,
                wisController: wisController,
                dexController: dexController,
                conController: conController,
                chaController: chaController,
              ),
              DndTextField(
                controller: multiAttController,
                "Attaques par tour (Optionnel)",
              ),
              DndTextField(
                "FP/ID (Optionnel)",
                controller: crController,
                validator: validateCr,
              ),
              DndButton(
                text: "Sauver",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print(hpController.text);
                    print(cr);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  String? validateRequiredInt(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter some text';
    }

    try {
      int.parse(input);
      return null;
    } on FormatException {
      return "Nombre non valide";
    }
  }

  String? validateCr(String? input) {
    if (input == null || input == "") return null;
    try {
      cr = input.interpret();
      return null;
    } on Exception {
      cr = null;
      return "Couldn't parse CR";
    }
  }
}

class StatInput extends StatefulWidget {
  TextEditingController? strController;
  TextEditingController? intController;
  TextEditingController? wisController;
  TextEditingController? dexController;
  TextEditingController? conController;
  TextEditingController? chaController;

  StatInput({
    Key? key,
    required this.strController,
    required this.intController,
    required this.wisController,
    required this.chaController,
    required this.conController,
    required this.dexController}) : super(key: key);

  @override
  State<StatInput> createState() => _StatInputState();
}

class _StatInputState extends State<StatInput> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 3;
    const double height = 48;

    return GridView.count(
      padding: const EdgeInsets.all(8.0),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      crossAxisCount: 3,
      childAspectRatio: (itemWidth / height),
      children: <Widget>[
        TextFormField(
          decoration: getDecoration("FOR"),
          controller: widget.strController,
         ),
        TextFormField(
          decoration: getDecoration("DEX"),
        ),
        TextFormField(
          decoration: getDecoration("CON"),
        ),
        TextFormField(
          decoration: getDecoration("INT"),
        ),
        TextFormField(
          decoration: getDecoration("WIS"),
        ),
        TextFormField(
          decoration: getDecoration("CHA"),
        ),
      ],
    );
  }

  InputDecoration getDecoration(String label) {
    return InputDecoration(
      label: Text(label),
      hintText: "ex: 12",
      contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      border: const OutlineInputBorder(),
      hintStyle: const TextStyle(color: Color(0XFFADADAD)),
    );
  }
}
