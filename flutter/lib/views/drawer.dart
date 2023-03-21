
import 'package:dnd_helper/views/scale_monster_page.dart';
import 'package:flutter/material.dart';

import '../Views/monsters_list.dart';
import 'initiative_entry_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black45,
            ),
            child: Text(
              'Coucou petite perruche',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            title: const Text('Quickie'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScaleMonsterPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Monstres'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonsterList()),
              );
            },
          ),
          ListTile(
            title: const Text('Initiative'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InitiativeEntryPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
