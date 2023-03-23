// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, must_be_immutable

import 'dart:math';
import 'package:dnd_helper/views/components/dnd_text_field.dart';
import 'package:flutter/material.dart';
import '../font_awesome_icons.dart';
import '../models/initiative_data.dart';
import '../rpg_icons.dart';
import '../views/drawer.dart';
import 'components/dnd_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class InitiativeEntryPage extends StatefulWidget {
  const InitiativeEntryPage({Key? key}) : super(key: key) ;


  @override
  State<InitiativeEntryPage> createState() => _InitiativeEntryPageState();
}

class _InitiativeEntryPageState extends State<InitiativeEntryPage> with SingleTickerProviderStateMixin {
  WebSocketChannel? channel;
  List<InitiativeData> initiativeList = <InitiativeData>[];
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    establishConnection();
    tabController = TabController(
        length: 2,
        vsync: this
    );
  }

  void establishConnection() {
    // final wsUrl = Uri.parse('ws://jeromedessy.be:8080');
    final wsUrl = Uri.parse('ws://localhost:8080');
    // final wsUrl = Uri.parse('ws://192.168.1.6:8080');
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
            initiativeList = msg;
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

  List<InitiativeData>? processMessage(String? message) {
    if (message == null) return [];
    List<InitiativeData> initiatives = List<InitiativeData>.from((jsonDecode(message).map((model) => InitiativeData.fromJson(model))));
    return initiatives;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Initiative"),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(icon: Icon(FontAwesome.dice_d20)),
            Tab(icon: Icon(FontAwesome.users)),
          ],
        ),
      ),
      drawer: const MyDrawer(),
       body: TabBarView(
         controller: tabController,
        children: [
          // Icon(FontAwesome.dice_d20),
          InitiativeEntry(channel: channel, initiativeList: initiativeList, tabController: tabController),
          InitiativeList(channel: channel, initiativeList: initiativeList),
        ],
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
  List initiativeList = <InitiativeData>[];
  TabController tabController;

  InitiativeEntry({super.key, required this.channel, required this.initiativeList, required this.tabController});

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
    if (_characterType == CharacterType.player) {
      nameInputController.text = enteredName ?? getName();
    }

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
              _characterType == CharacterType.player ? "Initiative" : "Bonus d'initiative",
              hint: _characterType == CharacterType.player ?  "ex: 15" : "Valeur par défaut: 0",
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
                    var randomRoll = Random().nextInt(20) + 1;
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

                  var json = jsonEncode(
                    InitiativeData(
                      name: nameInputController.text,
                      initiative: enteredInitiative,
                      action: BackendActionRequest.add,
                      characterType: _characterType
                    ).toMap()
                  );

                  widget.channel?.sink.add(json);

                  if (_characterType == CharacterType.player) {
                    widget.tabController.animateTo((widget.tabController.index + 1) % 2);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text(
                              "Envoyé",
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.black,
                        )
                    );
                  }
                }
              } : null,
              text: widget.channel != null ? "Envoyer" : "Erreur de connexion",
            ),
          ],
        ),
      ),
    );
  }

}


class InitiativeList extends StatefulWidget {
  WebSocketChannel? channel;
  List<InitiativeData> initiativeList = <InitiativeData>[];

  InitiativeList({super.key, required this.channel, required this.initiativeList});

  @override
  State<InitiativeList> createState() => _InitiativeListState();
}

class _InitiativeListState extends State<InitiativeList> {

  @override
  Widget build(BuildContext context) {
    List<InitiativeData> list = widget.initiativeList;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Tout supprimer?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Annuler"),
                  ),
                  TextButton(
                    onPressed: () {
                      deleteAll();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Confirmer"),
                  ),  // set up the AlertDi,
                ],
              );  // show the dialo;
            },
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.delete),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          debugPrint("${list[index].characterType}");
          bool isPlayer = list[index].characterType == CharacterType.player;
          return Card(
              child: ListTile(
                  onTap: () => debugPrint(list[index].name),
                  title: Text(
                      list[index].name ?? "",
                    style: TextStyle(
                      color: isPlayer ? Colors.green : Colors.red
                    )
                  ),
                  subtitle: Text("${list[index].initiative}" ?? ""),
                  leading:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [isPlayer ?
                          Icon(Rpg.knight_helmet):
                          Icon(Rpg.dragon),
                        ]
                      ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      showAlertDialog(
                          context,
                          confirmAction: () => deleteInitiativeEntry(list[index]),
                          index: index
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero
                    ),
                    child: Icon(Icons.close),
                  )
              )
          );
        },
      ),
    );
  }

  showAlertDialog(BuildContext context, {Function()? confirmAction, Function()? cancelAction, required int index}) {  // set up the buttons
    InitiativeData init = widget.initiativeList[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text("${init.name} : ${init.initiative}"),
          actions: [
            TextButton(
              onPressed: () {
                if (cancelAction != null) {
                  cancelAction();
                }
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                if (confirmAction != null) {
                  confirmAction();
                }
                Navigator.of(context).pop();
              },
              child: const Text("Confirmer"),
            ),  // set up the AlertDi,
          ],
        );  // show the dialo;
      },
    );
  }

  void deleteInitiativeEntry(InitiativeData initData){
    var json = jsonEncode(
        InitiativeData(
            name: initData.name,
            action: BackendActionRequest.delete,
            characterType: initData.characterType
        ).toMap()
    );
    widget.channel?.sink.add(json);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Supprimé",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black,
        )
    );
  }

  void deleteAll(){
    var json = jsonEncode(
        InitiativeData(
            action: BackendActionRequest.deleteAll,
        ).toMap()
    );
    widget.channel?.sink.add(json);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Supprimés",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black,
        )
    );
  }

}

