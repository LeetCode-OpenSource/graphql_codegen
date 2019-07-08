import 'package:graphql_parser/graphql_parser.dart';

import 'directive.dart';
import 'selection_set.dart';
import 'argument.dart';
import 'element_kind.dart';
import 'visitor.dart';
import 'selection.dart';

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

  String get name {
    return this._field.fieldName.name;
  }

  @override
  String source() {
    return null;
  }

  @override
  accept(ElementVisitor visitor) {
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
