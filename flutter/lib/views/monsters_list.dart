import 'package:dnd_helper/views/monster_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/monster.dart';
import 'custom_monster_form.dart';
import 'drawer.dart';

class MonsterList extends StatefulWidget {
  const MonsterList({Key? key}) : super(key: key);

  @override
  State<MonsterList> createState() => _MonsterListState();
}

class _MonsterListState extends State<MonsterList> {
  List<Monster>? monsters = <Monster>[];
  List<Monster>? filteredMonsters = <Monster>[];
  bool _searchBoolean = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMonsters();
  }

  Future<void> fetchMonsters() async {
    final stopwatch = Stopwatch()..start();
    var json = await http.get(Uri.parse('https://raw.githubusercontent.com/Kuurse/DnD_Scaler/dev/assets/monsters.json'));
    print('HTTP get executed in ${stopwatch.elapsed}');
    setState(() {
      monsters = Response.fromJson(jsonDecode(json.body)).results;
      print('JSON parsing executed in ${stopwatch.elapsed}');
      isLoading = false;
      filteredMonsters = List.from(monsters!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: !_searchBoolean ? Text("Monstres (${monsters?.length})") : _searchTextField(),
        actions: !_searchBoolean ? [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                filteredMonsters = List.from(monsters!);
                _searchBoolean = true;
              });
            })
        ] : [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchBoolean = false;
              });
            }
          )
        ]
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomMonsterForm())
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          !_searchBoolean ? _defaultListView() : _searchListView(),
          isLoading ? const Center(
            child: CupertinoActivityIndicator(
              animating: true,
            ),
          ) : const SizedBox()
        ]
      )
    );
  }


  Widget _defaultListView() {
    return ListView.builder(
      itemCount: monsters!.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
            child: ListTile(
              onTap: () => onTap(context, index, true),
                title: Text(monsters![index].name ?? "")
            )
        );
      },

    );
  }

  void onTap(BuildContext context, int index, bool defaultList) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context)=>
        MonsterDetailPage(monster: defaultList ? (monsters?[index]) : filteredMonsters?[index])
      )
    );
  }

  Widget _searchListView() { //add
    return ListView.builder(
      itemCount: filteredMonsters!.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            onTap: () => onTap(context, index, false),
            title: Text(filteredMonsters![index].name ?? "")
          )
        );
      }
    );
  }

  Widget _searchTextField() {
    return TextField(
      autofocus: true, //Display the keyboard when TextField is displayed
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //Specify the action button on the keyboard
      decoration: const InputDecoration( //Style of TextField
        enabledBorder: UnderlineInputBorder( //Default TextField border
            borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: UnderlineInputBorder( //Borders when a TextField is in focus
            borderSide: BorderSide(color: Colors.white)
        ),
        hintText: 'Search', //Text that is displayed when nothing is entered.
        hintStyle: TextStyle( //Style of hintText
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
      onChanged: onChanged,
    );
  }

  void onChanged(String string){
    filteredMonsters = List.from(monsters!);
    monsters?.forEach((monster) {
      if (!monster.name!.toLowerCase().contains(string.toLowerCase())){
        filteredMonsters?.remove(monster);
      }
    });
    setState((){});
  }
}
