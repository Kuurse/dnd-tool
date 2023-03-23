
class InitiativeData {
  String? name;
  int? initiative;
  BackendActionRequest? action;
  late CharacterType characterType;

  InitiativeData({this.name, this.initiative, this.action, this.characterType = CharacterType.player});

  Map<String, dynamic> toMap() => toJson();
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (name != null) {
      map["name"] = name;
    }
    if (initiative != null) {
      map["initiative"] = initiative;
    }
    if (action != null) {
      map["action"] = action!.getName();
    }
    map["characterType"] = characterType.getName();

    return map;
  }

  InitiativeData.fromJson(Map<String, dynamic> json) {
    name = json["name"]!;
    initiative = json["initiative"];
    try {
      characterType = CharacterType.values.byName(json["characterType"]);
    } catch (_) {}
    // characterType = CharacterType.npc;
  }
}

enum CharacterType {
  player,
  npc;

  String getName(){
    return toString().split('.').last;
  }
}

enum BackendActionRequest {
  add,
  delete,
  deleteAll;

  String getName(){
    return toString().split('.').last;
  }
}