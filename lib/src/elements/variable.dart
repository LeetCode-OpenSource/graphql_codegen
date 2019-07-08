import 'package:graphql_parser/graphql_parser.dart';

import 'element_kind.dart';
import 'element.dart';
import 'visitor.dart';

class VariableElement extends Element {
  VariableElement(this._variable) : super();

  final VariableContext _variable;

  final kind = ElementKind.Variable;

  String get name {
    return _variable.name;
  }

  @override
  String source() {
    return _variable.span.text;
  }

  void accept(ElementVisitor visitor) {}
}
