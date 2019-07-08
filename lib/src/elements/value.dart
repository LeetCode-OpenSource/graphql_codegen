import 'package:graphql_parser/graphql_parser.dart';

import 'element_kind.dart';
import 'visitor.dart';
import 'element.dart';

enum ValueKind {
  Boolean,
  Number,
  List,
  String,
}

class ValueElement extends Element {
  ValueElement(this._value) : super();

  final ValueContext _value;

  final kind = ElementKind.Value;

  ValueKind get valueKind {
    if (_value is BooleanValueContext) {
      return ValueKind.Boolean;
    } else if (_value is NumberValueContext) {
      return ValueKind.Number;
    } else if (_value is ListValueContext) {
      return ValueKind.List;
    } else {
      return ValueKind.String;
    }
  }

  @override
  String source() {
    return _value.span.text;
  }

  @override
  void accept(ElementVisitor visitor) {}
}
