import 'package:graphql_parser/graphql_parser.dart';

import 'element.dart';
import 'element_kind.dart';
import 'visitor.dart';

class NamedTypeElement extends Element {
  NamedTypeElement(this._named, this.isNullable) : super();

  final TypeNameContext _named;

  final kind = ElementKind.NamedType;

  final bool isNullable;

  @override
  String source() {
    return this._named.name;
  }

  @override
  accept(ElementVisitor visitor) {}
}
