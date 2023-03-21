// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';
import 'dart:math';
import 'package:dnd_helper/views/components/dnd_text_field.dart';
import 'package:flutter/material.dart';
import '../font_awesome_icons.dart';
import '../views/drawer.dart';
import 'components/dnd_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class InitiativeEntryPage extends StatefulWidget {
  const InitiativeEntryPage({Key? key}) : super(key: key) ;


  @override
  State<InitiativeEntryPage> createState() => _InitiativeEntryPageState();
}

class _InitiativeEntryPageState extends State<InitiativeEntryPage> {
  WebSocketChannel? channel;
  String serverMessage = "";

  @override
  void initState() {
    super.initState();
    establishConnection();
  }

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
        var msg = processMessage(message);
        if (msg != null) {
          setState(() {
            serverMessage = msg;
          });
        }
      },
      onDone: () {
        debugPrint('ws channel closed');
        setState(() {
          channel = null;
        });
      },
      onError: (error) {
        debugPrint('ws error $error');
        setState(() {
          channel = null;
        });
      },
    );
  }

  String? processMessage(String? message) {
    return message;
  }

  @override
  Widget build(BuildContext context) {
    var partyIcon = Icon(FontAwesome.users);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Initiative"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(FontAwesome.dice_d20)),
              Tab(icon: partyIcon),
            ],
          ),
        ),
        drawer: const MyDrawer(),
         body: TabBarView(
          children: [
            // Icon(FontAwesome.dice_d20),
            InitiativeEntry(channel: channel, serverMessage: serverMessage),
            partyIcon,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    channel?.sink.close();
  }
}

class InitiativeEntry extends StatefulWidget {
  WebSocketChannel? channel;
  String? serverMessage;

  InitiativeEntry({super.key, required this.channel, required this.serverMessage});

  @override
  State<InitiativeEntry> createState() => _InitiativeEntryState();
}

class _InitiativeEntryState extends State<InitiativeEntry> {

  late TextEditingController nameInputController;
  String? enteredName;
  int? enteredInitiative;
  final _formKey = GlobalKey<FormState>();
  CharacterType _characterType = CharacterType.player;

  @override
  void initState() {
    super.initState();
    nameInputController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    nameInputController.dispose();
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
              validator: (value) {
                var text = value;
                if ((text == null || text.isEmpty) && _characterType == CharacterType.player) {
                  return 'Please enter some text';
                } else if (text == null || text.isEmpty) {
                  if (_characterType == CharacterType.npc) {
                    text = "0";
                  }
                }

                try {
                  enteredInitiative = int.parse(text!);

                  if (_characterType == CharacterType.npc) {
                    var randomRoll = Random().nextInt(19) + 1;
                    enteredInitiative = enteredInitiative! + randomRoll;
                  }
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
              onPressed: widget.channel != null ? () {
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

                  widget.channel?.sink.add(json);
                }
              } : null,
              text: widget.channel != null ? "Envoyer" : "Erreur de connexion",
            ),
            Text(widget.serverMessage ?? "N/A"),
          ],
        ),
      ),
    );
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
      "characterType": characterType.getName(),
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

