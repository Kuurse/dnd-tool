enum Operator {
  plus,
  minus,
  times,
  dividedBy,
  unknown
}

Operator parseOperator(String c){
  switch(c)
  {
    case "+": return Operator.plus;
    case "-": return Operator.minus;
    case "*": return Operator.times;
    case "/": return Operator.dividedBy;
    default: return Operator.unknown;
  }
}
