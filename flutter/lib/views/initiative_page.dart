// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, must_be_immutable
import 'dart:math';
import 'package:dnd_helper/views/components/dnd_text_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../font_awesome_icons.dart';
import '../models/initiative_data.dart';
import '../rpg_icons.dart';
import '../views/drawer.dart';
import 'components/dnd_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class InitiativePage extends StatefulWidget {
  const InitiativePage({Key? key}) : super(key: key);

  @override
  State<InitiativePage> createState() => InitiativePageState();
}

class InitiativePageState extends State<InitiativePage>
    with SingleTickerProviderStateMixin {
  WebSocketChannel? channel;
  List<InitiativeData> initiativeList = <InitiativeData>[];
  late TabController tabController;

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
  }

  @override
  void initState() {
    super.initState();
    establishConnection();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  void establishConnection() {
    String url = 'ws://82.165.188.135:8080';
    var wsUrl = Uri.parse(url);
    channel = WebSocketChannel.connect(wsUrl);

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
        // timeout
        restoreConnection();
      },
      onError: (error) {
        debugPrint('ws channel error: $error');
        restoreConnection();
      },
    );
  }

  restoreConnection() {
    Future.delayed(Duration(seconds: 1)).then((_) {
      debugPrint('Reestablishing connection');
      establishConnection();
    }).onError((error, stackTrace) {
      debugPrint('Error reestablishing connection: $error');
      setState(() {
        channel = null;
      });
    });
  }

  List<InitiativeData>? processMessage(String? message) {
    if (message == null) return [];
    List<InitiativeData> initiatives = List<InitiativeData>.from(
        (jsonDecode(message).map((model) => InitiativeData.fromJson(model))));
    return initiatives;
  }

  void deleteAll() {
    var json = jsonEncode(
      InitiativeData(
        action: BackendActionRequest.deleteAll,
      ).toMap()
    );
    channel?.sink.add(json);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(
          "Supprimés",
          style: TextStyle(color: Colors.white),
        ),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.black,
    ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Initiative"),
        actions: tabController.index == 1 ? [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Show Snackbar',
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
                      ), // set up the AlertDi,
                    ],
                  ); // show the dialo;
                },
              );
            },
          ),
        ] : null,
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
          InitiativeForm(
            channel: channel,
            initiativeList: initiativeList,
            tabController: tabController,
            parent: this,
          ),
          InitiativeList(
              channel: channel,
              initiativeList: initiativeList,
          ),
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

class InitiativeForm extends StatefulWidget {
  WebSocketChannel? channel;
  List initiativeList = <InitiativeData>[];
  TabController tabController;
  InitiativePageState parent;

  InitiativeForm(
      {super.key,
      required this.channel,
      required this.initiativeList,
      required this.tabController,
      required this.parent});

  @override
  State<InitiativeForm> createState() => _InitiativeFormState();
}

class _InitiativeFormState extends State<InitiativeForm> {
  late TextEditingController nameInputController;
  String? enteredName;
  String? _savedName;
  int? enteredInitiative;
  final _formKey = GlobalKey<FormState>();
  CharacterType _characterType = CharacterType.player;


  @override
  void initState() {
    super.initState();
    nameInputController = TextEditingController();
    getName();
  }

  @override
  void dispose() {
    super.dispose();
    nameInputController.dispose();
  }

  void getName() async {
    final prefs = await SharedPreferences.getInstance();
    var name = prefs.getString('name');
    setState(() {
      _savedName = name;
    });
  }

  void restoreConnection() {
    if (widget.channel == null) {
      debugPrint("Reestablishing connection");
      widget.parent.establishConnection();
      setState(() {
        widget.channel = widget.parent.channel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.channel == null) {
      restoreConnection();
    }

    if (_characterType == CharacterType.player) {
      nameInputController.text = _savedName ?? "" ;
    } else {
      nameInputController.text = enteredName ?? "";
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
              onChanged: (text) async {
                if (_characterType == CharacterType.npc) {
                  enteredName = text;
                }
                if (_characterType == CharacterType.player && text != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('name', text);
                }
              },
            ),
            DndTextField(
              _characterType == CharacterType.player
                  ? "Initiative"
                  : "Bonus d'initiative",
              hint: _characterType == CharacterType.player
                  ? "ex: 15"
                  : "Valeur par défaut: 0",
              keyboardType: TextInputType.number,
              validator: (value) {
                var text = value;
                if (text == null || text.isEmpty) {
                  if (_characterType == CharacterType.player) {
                    return 'Please enter some text';
                  } else if (_characterType == CharacterType.npc) {
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
              onPressed: widget.channel != null
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        var json = jsonEncode(InitiativeData(
                                name: nameInputController.text,
                                initiative: enteredInitiative,
                                action: BackendActionRequest.add,
                                characterType: _characterType)
                            .toMap());

                        widget.channel?.sink.add(json);

                        if (_characterType == CharacterType.player) {
                          widget.tabController
                              .animateTo((widget.tabController.index + 1) % 2);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Center(
                              child: Text(
                                "Envoyé",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.black,
                          ));
                        }
                      }
                    }
                  : widget.parent.establishConnection,
              text: widget.channel != null
                  ? "Envoyer"
                  : "Erreur de connexion - Cliquer pour réessayer",
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

  InitiativeList(
      {super.key, required this.channel, required this.initiativeList});

  @override
  State<InitiativeList> createState() => _InitiativeListState();
}

class _InitiativeListState extends State<InitiativeList> {
  @override
  Widget build(BuildContext context) {
    List<InitiativeData> list = widget.initiativeList;
    return Scaffold(
      body: widget.channel != null ? ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          bool isPlayer = list[index].characterType == CharacterType.player;
          return Card(
              child: ListTile(
                  onTap: () => debugPrint(list[index].name),
                  title: Text(list[index].name ?? "",
                      style: TextStyle(
                          color: isPlayer ? Colors.green : Colors.red)),
                  subtitle: Text("${list[index].initiative}" ?? ""),
                  leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isPlayer ? Icon(Rpg.knight_helmet) : Icon(Rpg.dragon),
                      ]),
                  trailing: ElevatedButton(
                    onPressed: () {
                      showAlertDialog(context,
                          confirmAction: () =>
                              deleteInitiativeEntry(list[index]),
                          index: index);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero),
                    child: Icon(Icons.close),
                  )));
        },
      ) : Text(
        "Erreur de connexion",
        style: TextStyle(color: Colors.white, fontSize: 20.0),
        textAlign: TextAlign.center,
      ),
    );
  }

  showAlertDialog(BuildContext context,
      {Function()? confirmAction,
        Function()? cancelAction,
        required int index}) {
    // set up the buttons
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
            ), // set up the AlertDi,
          ],
        ); // show the dialo;
      },
    );
  }

  void deleteInitiativeEntry(InitiativeData initData) {
    var json = jsonEncode(InitiativeData(
        name: initData.name,
        action: BackendActionRequest.delete,
        characterType: initData.characterType)
        .toMap());
    widget.channel?.sink.add(json);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(
          "Supprimé",
          style: TextStyle(color: Colors.white),
        ),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.black,
    ));
  }

  void deleteAll() {
    var json = jsonEncode(InitiativeData(
      action: BackendActionRequest.deleteAll,
    ).toMap());
    widget.channel?.sink.add(json);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(
          "Supprimés",
          style: TextStyle(color: Colors.white),
        ),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.black,
    ));
  }
}
