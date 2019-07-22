import 'package:graphql_parser/graphql_parser.dart';

import 'argument.dart';
import 'directive.dart';
import 'element_kind.dart';
import 'selection.dart';
import 'selection_set.dart';
import 'visitor.dart';

class FieldElement extends SelectionElement {
  FieldElement(SelectionContext selection, SelectionSetElement parent)
      : super(selection, parent) {
    _field = selection.field;
    _arguments = selection.field.arguments
        .map((argument) => ArgumentElement(argument, this))
        .toList();
    _directives = selection.field.directives
        .map((directive) => DirectiveElement(directive))
        .toList();
    if (selection.field.selectionSet != null) {
      _selectionSet = SelectionSetElement(selection.field.selectionSet);
    }
  }

  @override
  final kind = ElementKind.Field;

  FieldContext _field;

  List<ArgumentElement> _arguments;

  List<ArgumentElement> get arguments {
    return _arguments;
  }

  List<DirectiveElement> _directives;

  List<DirectiveElement> get directives {
    return _directives;
  }

  SelectionSetElement _selectionSet;

  SelectionSetElement get selectionSet {
    return _selectionSet;
  }

  String get alias {
    if (_field.fieldName.alias != null) {
      return _field.fieldName.alias.alias;
    }
    return null;
  }

  @override
  String get name {
    if (_field.fieldName.alias != null) {
      return _field.fieldName.alias.name;
    }
    return _field.fieldName.name;
  }

  @override
  String source() {
    return null;
  }

  @override
  void accept(ElementVisitor visitor) {
    _arguments = _arguments
        .map((argument) => visitor.visitArgument(argument))
        .fold([], flat);

    _directives = _directives
        .map((directive) => visitor.visitDirective(directive))
        .fold([], flat);

    if (_selectionSet != null) {
      _selectionSet = visitor.visitSelectionSet(_selectionSet);
    }
  }
}
