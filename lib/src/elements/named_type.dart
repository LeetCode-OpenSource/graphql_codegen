import 'package:graphql_codegen/src/elements/element.dart';
import 'package:graphql_codegen/src/elements/element_kind.dart';
import 'package:graphql_codegen/src/elements/visitor.dart';
import 'package:graphql_parser/graphql_parser.dart';

class NamedTypeElement extends Element {
  NamedTypeElement(this._named);

  final TypeNameContext _named;

  final kind = ElementKind.NamedType;

  @override
  String source() {
    return this._named.name;
  }

  @override
  accept(ElementVisitor visitor) { }
}
