
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:dnd_helper/views/components/dnd_text_field.dart';
import 'package:flutter/material.dart';

import '../font_awesome_icons.dart';
import '../views/drawer.dart';
import 'components/dnd_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

class InitiativeEntryPage extends StatefulWidget {
  const InitiativeEntryPage({Key? key}) : super(key: key);

  @override
  State<InitiativeEntryPage> createState() => _InitiativeEntryPageState();
}

class _InitiativeEntryPageState extends State<InitiativeEntryPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Initiative"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(FontAwesome.dice_d20)),
              Tab(icon: Icon(Icons.list)),
            ],
          ),
        ),
        drawer: const MyDrawer(),
         body: const TabBarView(
          children: [
            // Icon(FontAwesome.dice_d20),
            InitiativeEntry(),
            Icon(Icons.list),
          ],
        ),
      ),
    );
  }
}

class InitiativeEntry extends StatefulWidget {

  const InitiativeEntry({super.key});

  @override
  State<InitiativeEntry> createState() => _InitiativeEntryState();
}

class _InitiativeEntryState extends State<InitiativeEntry> {

  late TextEditingController nameInputController = TextEditingController();
  String? enteredName;
  int? enteredInitiative;
  final _formKey = GlobalKey<FormState>();
  WebSocketChannel? channel;
  CharacterType _characterType = CharacterType.player;

  @override
  void initState() {
    super.initState();
    establishConnection();
  }

  String getName(){
    return "Vocnys";
  }

  @override
  Widget build(BuildContext context) {
    nameInputController.text = enteredName ?? getName();
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DndTextField(
              "Nom",
              controller: nameInputController,
              onChanged: (text) {
                enteredName = text;
              },
            ),
            DndTextField(
              "Initiative",
              keyboardType: TextInputType.number,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Please enter some text';
                }
                try {
                  enteredInitiative = int.parse(text);
                  return null;
                } on FormatException {
                  return "Nombre non valide";
                }
              },
            ),
            ListTile(
              title: const Text('Joueur'),
              leading: Radio<CharacterType>(
                value: CharacterType.player,
                groupValue: _characterType,
                onChanged: (CharacterType? value) {
                  setState(() {
                    _characterType = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Monstre'),
              leading: Radio<CharacterType>(
                value: CharacterType.npc,
                groupValue: _characterType,
                onChanged: (CharacterType? value) {
                  setState(() {
                    _characterType = value!;
                  });
                },
              ),
            ),
            DndButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content: Center(
                  //         child: Text(
                  //           enteredInitiative!,
                  //           style: TextStyle(
                  //               color: Colors.white
                  //           ),
                  //         ),
                  //       ),
                  //       duration: Duration(seconds: 1),
                  //       backgroundColor: Colors.black,
                  //     )
                  // );

                  var json = jsonEncode(
                    InitiativeData(
                      name: nameInputController.text,
                      initiative: enteredInitiative,
                      action: "add",
                      characterType: _characterType
                    ).toMap()
                  );

                  print("Sending json: $json");
                  channel?.sink.add(json);
                }
              },
              text: "Envoyer",
            ),
            Text(serverMessage),
          ],
        ),
      ),
    );
  }

  String serverMessage = "";

  void establishConnection() {
    // final wsUrl = Uri.parse('ws://jeromedessy.be:8080');
    final wsUrl = Uri.parse('ws://localhost:8080');
    channel = WebSocketChannel.connect(
        wsUrl,
        protocols: [
          'echo-protocol'
        ]
    );

    channel?.stream.listen(
      (dynamic message) {
        debugPrint('message $message');
        var msg = processMessage(message);
        if (msg != null) {
          setState(() {
            serverMessage = msg;
          });
        }
      },
      onDone: () {
        debugPrint('ws channel closed');
      },
      onError: (error) {
        debugPrint('ws error $error');
      },
    );
  }

  String? processMessage(String? message) {

  }
}

class InitiativeData {
  String name;
  int? initiative;
  String? action;
  CharacterType characterType;

  InitiativeData({required this.name, this.initiative, this.action, this.characterType = CharacterType.player});

  Map<String, dynamic> toMap() => toJson();
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "initiative": initiative,
      "action": action,
      "characterType": characterType!.getName(),
    };
  }
}

enum CharacterType {
  player,
  npc;

  String getName(){
    return toString().split('.').last;
  }
}

