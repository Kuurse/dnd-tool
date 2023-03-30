
class IntFormFieldValidator {

  static String? validateInt(String? text) {
    if (text == null || text.isEmpty){
      return 'Please enter some text';
    }

    try {
      var integer = int.parse(text!);
      return null;
    } on FormatException {
      return "Nombre non valide";
    }
  }

  static String? validateUint(String? text) {
    if (text == null || text.isEmpty){
      return 'Please enter some text';
    }

    try {
      var integer = int.parse(text!);
      if (integer < 0) {
        return "Entrez un nombre supérieur à 0";
      }
      return null;
    } on FormatException {
      return "Nombre non valide";
    }
  }
}