import 'package:graphql_parser/graphql_parser.dart';

import 'element.dart';
import 'element_kind.dart';
import 'value.dart';
import 'variable.dart';
import 'visitor.dart';

class ArgumentElement extends Element {
  ArgumentElement(this._argument, this.parent) : super() {
    if (_argument.valueOrVariable.value != null) {
      _value = ValueElement(_argument.valueOrVariable.value);
    } else {
      _variable = VariableElement(_argument.valueOrVariable.variable);
    }
  }

  final Element parent;

  final ArgumentContext _argument;

  @override
  final kind = ElementKind.Argument;

  ValueElement _value;

  VariableElement _variable;

  String get name {
    return _argument.name;
  }

  @override
  String source() {
    return null;
  }

  @override
  void accept(ElementVisitor visitor) {
    if (_value != null) {
      _value = visitor.visitValue(_value);
    } else {
      _variable = visitor.visitVariable(_variable);
    }
  }
}
