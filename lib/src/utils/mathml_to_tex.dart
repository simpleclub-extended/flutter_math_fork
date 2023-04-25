import 'package:html/dom.dart' as dom;

String parseMathMLRecursive(dom.Node node, String parsed) {
  if (node is dom.Element) {
    List<dom.Element> nodeList = node.nodes.whereType<dom.Element>().toList();
    if (node.localName == "math" ||
        node.localName == "mrow" ||
        node.localName == "mtr") {
      for (var element in nodeList) {
        parsed = parseMathMLRecursive(element, parsed);
      }
    }
    // note: munder, mover, and munderover do not support placing braces and other
    // markings above/below elements, instead they are treated as super/subscripts for now.
    if ((node.localName == "msup" ||
            node.localName == "msub" ||
            node.localName == "munder" ||
            node.localName == "mover") &&
        nodeList.length == 2) {
      parsed = parseMathMLRecursive(nodeList[0], parsed);
      parsed =
          "${parseMathMLRecursive(nodeList[1], "$parsed${node.localName == "msup" || node.localName == "mover" ? "^" : "_"}{")}}";
    }
    if ((node.localName == "msubsup" || node.localName == "munderover") &&
        nodeList.length == 3) {
      parsed = parseMathMLRecursive(nodeList[0], parsed);
      parsed = "${parseMathMLRecursive(nodeList[1], "${parsed}_{")}}";
      parsed = "${parseMathMLRecursive(nodeList[2], "$parsed^{")}}";
    }
    if (node.localName == "mfrac" && nodeList.length == 2) {
      parsed = "${parseMathMLRecursive(nodeList[0], parsed + r"\frac{")}}";
      parsed = "${parseMathMLRecursive(nodeList[1], "$parsed{")}}";
    }
    // note: doesn't support answer & intermediate steps
    if (node.localName == "mlongdiv" && nodeList.length == 4) {
      parsed = parseMathMLRecursive(nodeList[0], parsed);
      parsed = "${parseMathMLRecursive(nodeList[2], parsed + r"\overline{)")}}";
    }
    if (node.localName == "msqrt") {
      parsed = parsed + r"\sqrt{";
      for (var element in nodeList) {
        parsed = parseMathMLRecursive(element, parsed);
      }
      parsed = "$parsed}";
    }
    if (node.localName == "mroot" && nodeList.length == 2) {
      parsed = "${parseMathMLRecursive(nodeList[1], parsed + r"\sqrt[")}]";
      parsed = "${parseMathMLRecursive(nodeList[0], "$parsed{")}}";
    }
    if (node.localName == "mi" ||
        node.localName == "mn" ||
        node.localName == "mo") {
      if (_mathML2Tex.keys.contains(node.text.trim())) {
        parsed = parsed +
            _mathML2Tex[
                _mathML2Tex.keys.firstWhere((e) => e == node.text.trim())]!;
      } else if (node.text.startsWith("&") && node.text.endsWith(";")) {
        parsed = parsed +
            node.text
                .trim()
                .replaceFirst("&", r"\")
                .substring(0, node.text.trim().length - 1);
      } else {
        parsed = parsed + node.text.trim();
      }
    }
    if (node.localName == 'mtable') {
      String inner =
          nodeList.map((e) => parseMathMLRecursive(e, '')).join(' \\\\');
      parsed = '$parsed\\begin{matrix}$inner\\end{matrix}';
    }
    if (node.localName == "mtd") {
      for (var element in nodeList) {
        parsed = parseMathMLRecursive(element, parsed);
      }
      parsed = '$parsed & ';
    }
  }
  return parsed;
}

Map<String, String> _mathML2Tex = {
  "sin": r"\sin",
  "sinh": r"\sinh",
  "csc": r"\csc",
  "csch": r"csch",
  "cos": r"\cos",
  "cosh": r"\cosh",
  "sec": r"\sec",
  "sech": r"\sech",
  "tan": r"\tan",
  "tanh": r"\tanh",
  "cot": r"\cot",
  "coth": r"\coth",
  "log": r"\log",
  "ln": r"\ln",
  "{": r"\{",
  "}": r"\}",
};