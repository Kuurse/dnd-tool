import '../models/monster.dart';

extension MonsterScaler on Monster {
  static const int basePartySize = 4;

  Monster scaleToPartySize(int partySize) {
    var mod = partySize/basePartySize;
    var newMonster = Monster.fromJson(toJson());
    newMonster.hitPoints = ((hitPoints!/basePartySize)*partySize).round();
    var ogMulti = multiattack ?? getAttackPerTurnCount();
    newMonster.multiattack = ogMulti*mod;
    newMonster.xp = (xp*mod).round();
    return newMonster;
  }

  Monster scaleToPartyLevel(int partyLevel, int designedLevel) {
    var newMonster = Monster.fromJson(toJson());
    var mod = partyLevel/designedLevel;
    var diff = partyLevel-designedLevel;

    newMonster.hitPoints = hitPoints! + diff*10;
    newMonster.armorClass = armorClass!+(diff~/2);
    newMonster.xp = (xp*mod).round();

    var saveModifier = diff~/2;
    newMonster.dexteritySave = dexteritySave! + saveModifier;
    newMonster.strengthSave = strengthSave! + saveModifier;
    newMonster.wisdomSave = wisdomSave! + saveModifier;
    newMonster.constitutionSave = constitutionSave! + saveModifier;
    newMonster.charismaSave = charismaSave! + saveModifier;
    newMonster.intelligenceSave = intelligenceSave! + saveModifier;

    newMonster.actions = _scaleActions(actions, diff);
    newMonster.legendaryActions = _scaleActions(legendaryActions, diff);
    newMonster.reactions = _scaleActions(reactions, diff);
    newMonster.legendaryActions = _scaleActions(specialAbilities, diff);

    return newMonster;
  }

  static final List<int> _availableDice = <int>[4, 6, 8, 10, 12];
  DiceRoll? calculateDamageDice(Action action, int diff) {
    return scaleUp(action, diff);
  }

  DiceRoll? scaleUp(Action action, int diff) {
    if (action.diceRoll == null) return null;
    // final avgDmg = action.readAverageDamage();
    final avgDmg = action.computeAverageDamage();
    var targetDmg = avgDmg! + (diff * 2);
    if (targetDmg < 0) {
      targetDmg = 1;
    }

    print("Scaling ${action.name}");
    print("OG average $avgDmg, target avg $targetDmg");

    var tmpDice = DiceRoll.fromJson(action.diceRoll.toString());
    final plus = diff >= 0;

    while (plus ? tmpDice.getAverageRoll() < targetDmg : tmpDice.getAverageRoll() > targetDmg) {
      final dmgDiff = targetDmg - tmpDice.getAverageRoll();

      if (tmpDice.getAverageRoll() == targetDmg) {
        break;
      }
      // The goal here is to change values with this priority:
      // - the number of dice
      // - the size of the dice
      // - the modifier
      // And repeat the checks until the average is equal or over the target;

      // check if changing dice amount is ok
      // going from XdY+Z to ((tmpDice.dice![0].diceFaces!+1)/2)(X+n)dY+Z increases average by (Y+1)/2
      final x1 = ((tmpDice.dice![0].diceFaces!+1)/2);
      if (plus ? dmgDiff >= x1 : (dmgDiff <= x1 && tmpDice.dice![0].amount! > 1)) {
        // More dice
        tmpDice.dice = plus ?
          <DiceValue>[ DiceValue(tmpDice.dice![0].amount! + 1, tmpDice.dice![0].diceFaces) ] :
          <DiceValue>[ DiceValue(tmpDice.dice![0].amount! - 1, tmpDice.dice![0].diceFaces) ];
        continue;
      }

      if (tmpDice.getAverageRoll() == targetDmg) {
        break;
      }
      // check if increasing dice size is ok
      // going from XdY+Z to Xd(Y+n)+Z increases average by n
      // find the index of the current dice
      //     check if the next dice would nuke the average
      //         check if there is a next dice. If not, we can go to next step
      var index = _availableDice.indexOf(tmpDice.dice![0].diceFaces!);
      if (plus ? index < _availableDice.length - 1 : index > 0) {
        final nextDiceFaceCount = plus ? _availableDice[index + 1] : _availableDice[index-1];
        final diceFaces = tmpDice.dice![0].diceFaces!;
        // If the damage difference is bigger/smaller than the dice faces difference, it's
        // ok to increase/decrease dice
        final x2 = tmpDice.dice![0].amount!*((nextDiceFaceCount - diceFaces)/2);
        if (plus ? dmgDiff >= x2 : dmgDiff <= x2) {
          // Increase/decrease dice
          tmpDice.dice = <DiceValue>[ DiceValue(tmpDice.dice![0].amount, nextDiceFaceCount) ];
          continue;
        }
      }

      if (tmpDice.getAverageRoll() == targetDmg) {
        break;
      }
      // if all else is done or has failed, increase the modifier
      var mod =  (tmpDice.modifier ?? 0) + (targetDmg - tmpDice.getAverageRoll());
      if (mod < 0) {
        mod = 0;
        break;
      }
      tmpDice.modifier = mod;
    }

    print("returning $tmpDice for ${action.name} ");
    return tmpDice;
  }

  List<Action> _scaleActions(List<Action>? act, int diff) {
    var a = <Action>[];
    if (act == null) {
      return a;
    }

    for (var action in act){
      if (action.diceRoll == null) continue;
      var newAction = Action(name: action.name);
      newAction.attackBonus = action.attackBonus! + (diff/2).round();

      var dmgDice = calculateDamageDice(action, diff);
      newAction.diceRoll = dmgDice;

      //update description with the values just computed
      var oldAvg = action.computeAverageDamage();
      var newAvg = newAction.diceRoll!.getAverageRoll().toString();

      var desc = action.desc!.replaceAll(action.diceRoll.toString(), dmgDice.toString())
        .replaceAll("$oldAvg ", "$newAvg ").replaceAll("${action.attackBonus} ", "${newAction.attackBonus} ");

      newAction.desc = desc;
      a.add(newAction);
    }

    return a;
  }
}