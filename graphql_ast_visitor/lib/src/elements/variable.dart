import 'package:graphql_parser/graphql_parser.dart';

import 'element.dart';
import 'element_kind.dart';
import 'visitor.dart';

class VariableElement extends Element {
  VariableElement(this._variable) : super();

  final VariableContext _variable;

  @override
  final kind = ElementKind.Variable;

  String get name {
    return _variable.name;
  }

  @override
  String source() {
    return _variable.span.text;
  }

  @override
  void accept(ElementVisitor visitor) {}
}
