import 'package:flutter/material.dart';
import '../tools/scaler.dart';
import '../models/monster.dart';
import '../font_awesome_icons.dart';
import 'package:dnd_helper/models/monster.dart' as mon;

import 'components/dnd_button.dart';

class MonsterDetailPage extends StatelessWidget {
  Monster? monster;
  MonsterDetailPage({this.monster, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(monster?.name ?? "Monstre"),
        actions: <Widget>[
          PopupMenuButton(
            icon: const Icon(Icons.scale_sharp),
              itemBuilder: (context){
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text("Taille du groupe"),
                  ),

                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text("Niveau du groupe"),
                  ),
                ];
              },
              onSelected:(value){
                switch (value) {
                  case 0:
                    showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return PartySizeScalingDialog(monster!);
                        }
                    );
                    break;
                  case 1:
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return LevelScalingDialog(monster!);
                      }
                    );
                    break;
                }
              }
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MonsterHeader(monster!),
              StatBlock(monster),
              SkillsList(monster!.skills!),
              Row(
                children: [
                  const Text("Senses:  "),
                  Flexible(
                    child: Text(
                        monster!.senses!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height:4),
              Row(
                children: [
                  const Text("Immunités:  "),
                  Text(monster!.damageImmunities!),
                ],
              ),
              ActionList("Actions", monster!.actions ?? []),
              ActionList("Legendary actions", monster!.legendaryActions ?? []),
              ActionList("Reactions", monster!.reactions ?? []),
              ActionList("Special", monster!.specialAbilities ?? []),
            ],
          ),
        ),
      )
    );
  }
}

class ActionList extends StatelessWidget {
  final List<mon.Action> actions;
  final String title;
  const ActionList(this.title, this.actions, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox(width: 0, height: 0);

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            // color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        ListView.builder(
          itemCount: actions.length,
          primary: false,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                child: ListTile(
                    title: Column(
                      children: [
                        Text(actions[index].name!),
                        Text(actions[index].desc!),
                      ],
                    )
                )
            );
          },
        ),
      ],
    );
  }
}

class MonsterHeader extends StatelessWidget {
  final Monster monster;
  const MonsterHeader(this.monster, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesome.shield_alt,
                      color: Colors.blue,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(monster.armorClass.toString()),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      FontAwesome.heart,
                      color: Colors.red,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(monster.hitPoints.toString()),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      FontAwesome.dice_d20,
                      color: Colors.green
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(getInitiativeText()),
                    ),
                  ],
                )
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesome.skull,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text("${monster.challengeRating}"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      FontAwesome.bullseye,
                      color: Colors.yellow,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text("${monster.proficiencyBonus}"),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String getInitiativeText() {
    var dexBonus = (monster.dexterity!-10)~/2;
    var plus = dexBonus >= 0 ? "+" : "";
    // return "Initiative: $plus$dexBonus";
    return "$plus$dexBonus";
  }
}

class SkillsList extends StatelessWidget {
  List<Stat> skills;
  SkillsList(this.skills, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    const columns = 2;
    final double itemWidth = size.width / columns;
    const double height = 20.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Skills",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height:4),
            GridView.count(
              padding: EdgeInsets.all(0),
              shrinkWrap: true,
              primary: false,
              crossAxisCount: columns,
              childAspectRatio: (itemWidth / height),
              children: List<Widget>.generate(
                skills.length,
                (index) => Row(
                  children: [
                    Text("${skills[index].name} : "),
                    Text("${skills[index].value}"),
                  ]
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const double height = 90;

class StatBlock extends StatelessWidget {
  final Monster? monster;
  const StatBlock(this.monster, {super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 3;

    return GridView.count(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      childAspectRatio: (itemWidth / height),
      children: <Widget>[
        StatDetail(
            name: "FOR",
            value: monster?.strength,
            save: monster?.strengthSave
        ),
        StatDetail(
          name: "DEX",
          value: monster?.dexterity,
          save: monster?.dexteritySave,
        ),
        StatDetail(
          name: "CON",
          value: monster?.constitution,
          save: monster?.constitutionSave,
        ),
        StatDetail(
          name: "INT",
          value: monster?.intelligence,
          save: monster?.intelligenceSave,
        ),
        StatDetail(
          name: "SAG",
          value: monster?.wisdom,
          save: monster?.wisdomSave,
        ),
        StatDetail(
          name: "CHA",
          value: monster?.charisma,
          save: monster?.charismaSave,
        ),
      ],
    );
  }
}

class StatDetail extends StatelessWidget {
  final String? name;
  final int? value;
  final int? save;
  const StatDetail({this.name, this.value, this.save, super.key});

  @override
  Widget build(BuildContext context) {
    var saveHasValue = save != 0;

    return Container(
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                name ?? "?",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                )
            ),
            const SizedBox(height: 4),
            Text("$value (${getValueBonus(value)})"),
            saveHasValue ? Text(
              "Save ${save! >= 0 ? "+$save" : save}",
              style: const TextStyle(
                color: Colors.green,
              ),
            ) : const SizedBox(height: 0,),
          ],
        ),
      ),
    );
  }

  String getValueBonus(int? value){
    if (value == null) return "+0";
    int bonus = (value-10) ~/ 2;
    String plusMinus = bonus > 0 ? "+" : "";
    return "$plusMinus$bonus";
  }
}

class LevelScalingDialog extends StatelessWidget {

  Monster monster;
  LevelScalingDialog(this.monster, {super.key}){
    designedLevelController.text = 6.toString();
    targetLevelController.text = 1.toString();
  }
  String? text;

  TextEditingController designedLevelController = TextEditingController();
  TextEditingController targetLevelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Title'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: GridView.count(
            crossAxisCount: 2,
            primary:false,
            shrinkWrap: true,
            children: [
              const Text("Designed party level"),
              TextField(
                controller: designedLevelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "5",
                ),
                onChanged: (text) => this.text = text,
              ),
              const Text("Target party level"),
              TextField(
                controller: targetLevelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Target party level",
                ),
                onChanged: (text) => this.text = text,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              var designedLevel = int.parse(designedLevelController.text);
              var targetLevel = int.parse(targetLevelController.text);
              var scaled = monster.scaleToPartyLevel(targetLevel, designedLevel);

              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context)=>
                      MonsterDetailPage(monster: scaled)
                  )
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: const Text("OK"),
          ),
        ]
    );
  }
}

class PartySizeScalingDialog extends StatelessWidget {

  Monster monster;
  PartySizeScalingDialog(this.monster, {super.key}){
    targetPartySizeController.text = 7.toString();
  }
  String? text;

  TextEditingController targetPartySizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Title'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: GridView.count(
            crossAxisCount: 2,
            primary:false,
            shrinkWrap: true,
            children: [
              const Text("Target party size"),
              TextField(
                controller: targetPartySizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Target party size",
                ),
                onChanged: (text) => this.text = text,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: const Text("Annuler"),
          ),
          DndButton(
            onPressed: () {
              Navigator.pop(context);
              var targetPartySize = int.parse(targetPartySizeController.text);
              var scaled = monster.scaleToPartySize(targetPartySize);

              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context)=>
                      MonsterDetailPage(monster: scaled)
                  )
              );
            },
            text: "OK",
          ),
        ]
    );
  }
}

