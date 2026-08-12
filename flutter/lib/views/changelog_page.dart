import 'package:flutter/material.dart';

import '../Views/drawer.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});
  final String changelog = """
  v1.0.2:
   - Correction de bug permettant d'entrer des nombres négatifs dans le champ d'initiative
   - Auto-reconnexion au socket lorsqu'une déconnexion est détectée
   - Ajout de la page de changelog
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text('Changelog'),
      ),
      body: Center(
        child: Text(changelog),
      ),
    );
  }
}
