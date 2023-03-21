extension RegExpExtension on RegExp {
  List<String> allMatchesWithSep(String input, [int start = 0]) {
    var result = <String>[];
    for (var match in allMatches(input, start)) {
      result.add(input.substring(start, match.start));
      result.add(match[0]!);
      start = match.end;
    }
    result.add(input.substring(start));
    return result;
  }
}

extension StringExtension on String {
  List<String> splitWithDelim(RegExp pattern) =>
      pattern.allMatchesWithSep(this);

  String? valueBetween(String section1, String section2) {
    if (!contains(section1) || !contains(section2)){
      throw Exception("Values not found : '$section1' , '$section2' in '$this'");
    }

    var split1 = split(section1).last;
    return split1.split(section2).first;
  }


  List<String> splitAtIndex(int i){
    if (i < 0) throw Exception("Invalid index");
    if (i <= length) return [this];
    var end = substring(i);
    var start = substring(0, i);
    var l = <String> [start, end];
    return l;
  }

  List<String> splitAtIndexes(List<int> indexes) {

    var ind = List.from(indexes);
    ind.sort();
    var list = <String>[];
    int x=0;
    for (int i=0; i<ind.length; i++){
      var sub = substring(x, ind[i]);
      list.add(sub);
      x = ind[i];
    }
    var last = substring(x);
    if (last.isNotEmpty) list.add(substring(x));

    return list;
  }
}

extension IntExtension on int {
  static int fromPlainEnglish(String text){
    var numbers = <String, int>{
      "two ": 2,
      "three ": 3,
      "four ": 4,
      "five ": 5,
      "six ": 6,
      "seven ": 7,
      "eight ": 8,
      "nine ": 9,
      "ten ": 10,
    };

    var num = 1;
    for (int i=0; i<numbers.keys.length; i++){
      if (text.contains(numbers.keys.elementAt(i))) {
        num = numbers.values.elementAt(i);
        break;
      }
    }
    return num;
  }
}