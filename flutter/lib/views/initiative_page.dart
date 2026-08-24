// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, must_be_immutable
import 'dart:math';
import 'package:dnd_helper/views/components/dnd_text_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  WebSocketChannel? channel;
  bool _isConnected = true;
  bool _isReconnecting = false;
  List<InitiativeData> initiativeList = <InitiativeData>[];
  int _currentTurnIndex = 0;
  late TabController tabController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isConnected) {
      debugPrint('App resumed, reconnecting WebSocket');
      establishConnection();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        if (mounted) {
          setState(() {
            _isConnected = true;
            _isReconnecting = false;
          });
        }
        var msg = processMessage(message);
        if (msg != null) {
          setState(() {
            initiativeList = msg.$1;
            _currentTurnIndex = msg.$2;
          });
        }
      },
      onDone: () {
        debugPrint('ws channel closed');
        if (mounted) {
          setState(() {
            _isConnected = false;
            _isReconnecting = true;
          });
        }
        restoreConnection();
      },
      onError: (error) {
        debugPrint('ws channel error: $error');
        if (mounted) {
          setState(() {
            _isConnected = false;
            _isReconnecting = true;
          });
        }
        restoreConnection();
      },
    );
  }

  void restoreConnection() {
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (mounted) {
        debugPrint('Reestablishing connection');
        setState(() {
          establishConnection();
        });
      }
    }).onError((error, stackTrace) {
      debugPrint('Error reestablishing connection: $error');
      if (mounted) {
        setState(() {
          channel = null;
          _isConnected = false;
          _isReconnecting = false;
        });
      }
    });
  }

  (List<InitiativeData>, int)? processMessage(String? message) {
    if (message == null) return null;
    final decoded = jsonDecode(message);
    final List<dynamic> raw =
        decoded is List ? decoded : (decoded['initiatives'] as List);
    final int turn =
        decoded is List ? 0 : ((decoded['currentTurn'] as int?) ?? 0);
    final initiatives = List<InitiativeData>.from(
        raw.map((model) => InitiativeData.fromJson(model)));
    final clamped =
        initiatives.isEmpty ? 0 : turn.clamp(0, initiatives.length - 1);
    return (initiatives, clamped);
  }

  void _onNextTurn() {
    if (initiativeList.isEmpty) return;
    print("Moving to next turn");
    final nextIndex = (_currentTurnIndex + 1) % initiativeList.length;
    final json = jsonEncode({
      'action': BackendActionRequest.setTurn.getName(),
      'index': nextIndex,
    });
    channel?.sink.add(json);
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
            isConnected: _isConnected,
            isReconnecting: _isReconnecting,
            onReconnect: establishConnection,
            currentTurnIndex: _currentTurnIndex,
            onNextTurn: _onNextTurn,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    channel?.sink.close();
    super.dispose();
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
              keyboardType: kIsWeb ? TextInputType.text : TextInputType.numberWithOptions(signed: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
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
  final bool isConnected;
  final bool isReconnecting;
  final VoidCallback onReconnect;
  final int currentTurnIndex;
  final VoidCallback onNextTurn;

  InitiativeList({
    super.key,
    required this.channel,
    required this.initiativeList,
    required this.isConnected,
    required this.isReconnecting,
    required this.onReconnect,
    required this.currentTurnIndex,
    required this.onNextTurn,
  });

  @override
  State<InitiativeList> createState() => _InitiativeListState();
}

class _InitiativeListState extends State<InitiativeList> {
  @override
  Widget build(BuildContext context) {
    List<InitiativeData> list = widget.initiativeList;
    return Scaffold(
      floatingActionButton: list.isNotEmpty
          ? FloatingActionButton(
              onPressed: widget.onNextTurn,
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              child: const Icon(Icons.skip_next),
            )
          : null,
      body: Column(
        children: [
          Visibility(
            visible: !widget.isConnected,
            child: Container(
              color: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.isReconnecting
                    ? [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        const Text("connexion en cours...",
                            style: TextStyle(color: Colors.white)),
                      ]
                    : [
                        const Icon(Icons.wifi_off, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text("Connexion perdue",
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: widget.onReconnect,
                          child: const Text(
                            "Reconnecter",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
              ),
            ),
          ),
          Expanded(
            child: widget.channel != null
                ? ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isPlayer =
                          list[index].characterType == CharacterType.player;
                      return Card(
                          shape: index == widget.currentTurnIndex
                              ? RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.yellow, width: 2),
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : null,
                          child: ListTile(
                              onTap: () => debugPrint(list[index].name),
                              title: Text(list[index].name ?? "",
                                  style: TextStyle(
                                      color: isPlayer
                                          ? Colors.green
                                          : Colors.red)),
                              subtitle: Text("${list[index].initiative}" ?? ""),
                              leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isPlayer
                                        ? Icon(Rpg.knight_helmet)
                                        : Icon(Rpg.dragon),
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
                  )
                : const Text(
                    "Erreur de connexion",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
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
