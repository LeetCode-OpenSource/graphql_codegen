import 'package:graphql_parser/graphql_parser.dart';

import 'definition.dart';
import 'element.dart';
import 'element_kind.dart';
import 'visitor.dart';

class DocumentElement extends Element {
  DocumentElement(this._document) : super() {
    _definitions = _document.definitions
        .map((def) => DefinitionElement.create(def))
        .toList();
  }

  @override
  final kind = ElementKind.Document;

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
      final List<DefinitionElement> empty = [];
      return empty;
    }).fold([], flat);
  }
}
