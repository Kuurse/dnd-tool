

import 'package:dnd_helper/views/components/dnd_text_field.dart';
import 'package:dnd_helper/views/drawer.dart';
import 'package:flutter/material.dart';

class ScaleMonsterPage extends StatefulWidget {
  const ScaleMonsterPage({Key? key}) : super(key: key);

  @override
  State<ScaleMonsterPage> createState() => _ScaleMonsterPageState();
}

class _ScaleMonsterPageState extends State<ScaleMonsterPage> {
  final int normalPartySize = 4;
  final int ourPartySize = 7;
  String? text;

  // TextEditingController targetPartySizeController = TextEditingController();
  String? scaledHp;
  String? scaledMultiatt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SCALE IT BABY"),
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          DndTextField(
            "HP",
            onChanged: scaleHp,
          ),
          DndTextField("Nombre d'attaques",
            validator: validate,
            onChanged: scaleMultiAtt,
            keyboardType: TextInputType.number,
          ),
          Text("Scaled HP: $scaledHp"),
          Text("Scaled multiatt : $scaledMultiatt"),
        ],
      ),
    );
  }

  void scaleHp(String? input) {
    if (input == null) scaledHp = "0";
    try {
      var hitPoints = int.parse(input!);
      setState(() {
        scaledHp = ((hitPoints/4)*7).round().toString();
      });
    } on FormatException {
      setState(() {
        scaledHp = "0";
      });
    }
  }

  void scaleMultiAtt(String? input) {
    if (input == null) scaledMultiatt = "0";
    var mod = ourPartySize/normalPartySize;
    try {
      var multiattack = int.parse(input!);
      setState(() {
        scaledMultiatt = (multiattack*mod).toString();
      });
    } on FormatException {
      setState(() {
        setState(() {
          scaledMultiatt = "0";
        });
      });
    }

  }

  String? validate(String? value) {
    try {
      int.parse(value!);
      return null;
    } on  Exception {
      return "Entrée invalide";
    }
  }
}
