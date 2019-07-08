import 'package:graphql_codegen/src/elements/definition.dart';
import 'package:graphql_codegen/src/elements/element.dart';
import 'package:graphql_codegen/src/elements/visitor.dart';
import 'package:graphql_parser/graphql_parser.dart';

class DocumentElement extends Element {
  DocumentElement(this._document) : super() {
    _definitions = this
        ._document
        .definitions
        .map((def) => DefinitionElement.create(def))
        .toList();
  }

  final DocumentContext _document;

  List<DefinitionElement> _definitions;

  List<DefinitionElement> get definitions {
    return _definitions;
  }

  @override
  String source() {
    return null;
  }

  @override
  void accept(ElementVisitor visitor) {
    _definitions = _definitions.map((def) {
      if (def.definitionKind == DefinitionKind.Operation) {
        return visitor.visitOperationDefinition(def);
      } else if (def.definitionKind == DefinitionKind.Fragment) {
        return visitor.visitFragmentDefinition(def);
      }
      return [] as List<DefinitionElement>;
    }).fold([], flat);
  }
}
