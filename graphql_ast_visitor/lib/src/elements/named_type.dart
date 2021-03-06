import 'package:graphql_parser/graphql_parser.dart';

import 'element.dart';
import 'element_kind.dart';
import 'visitor.dart';

class NamedTypeElement extends Element {
  NamedTypeElement(this._named) : super();

  final TypeNameContext _named;

  @override
  final kind = ElementKind.NamedType;

  String get name {
    return _named.name;
  }

  @override
  String source() {
    return _named.name;
  }

  @override
  void accept(ElementVisitor visitor) {}
}
