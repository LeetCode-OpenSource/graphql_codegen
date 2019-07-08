import 'package:graphql_parser/graphql_parser.dart';

import 'directive.dart';
import 'element_kind.dart';
import 'definition.dart';
import 'selection_set.dart';
import 'named_type.dart';
import 'visitor.dart';

class FragmentDefinationElement extends DefinitionElement {
  FragmentDefinationElement(this._defination) : super(_defination) {
    if (this._defination.typeCondition != null) {
      _typeCondition =
          NamedTypeElement(this._defination.typeCondition.typeName, true);
    }
    if (_defination.directives.isNotEmpty) {
      _directives = _defination.directives
          .map((directive) => DirectiveElement(directive))
          .toList();
    }
    if (this._defination.selectionSet != null) {
      _selectionSet = SelectionSetElement(this._defination.selectionSet);
    }
  }

  final kind = ElementKind.FragmentDefinition;

  final FragmentDefinitionContext _defination;

  List<DirectiveElement> _directives = [];

  List<DirectiveElement> get directives {
    return _directives;
  }

  SelectionSetElement _selectionSet;

  SelectionSetElement get selectionSet {
    return _selectionSet;
  }

  NamedTypeElement _typeCondition;

  NamedTypeElement get typeCondition {
    return _typeCondition;
  }

  String get name {
    return _defination.name;
  }

  @override
  String source() {
    return null;
  }

  @override
  accept(ElementVisitor visitor) {
    if (_typeCondition != null) {
      _typeCondition = visitor.visitNamedType(_typeCondition);
    }
    if (_defination.directives.isNotEmpty) {
      _directives = _directives.map((directive) {
        return visitor.visitDirective(directive);
      }).fold([], flat);
    }
    if (_selectionSet != null) {
      _selectionSet = visitor.visitSelectionSet(_selectionSet);
    }
  }
}
