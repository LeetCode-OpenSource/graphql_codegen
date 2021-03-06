import 'package:graphql_parser/graphql_parser.dart';

import 'definition.dart';
import 'directive.dart';
import 'element_kind.dart';
import 'field.dart';
import 'fragment_spread.dart';
import 'selection_set.dart';
import 'variable_definition.dart';
import 'visitor.dart';

class OperationDefinitionElement extends DefinitionElement {
  OperationDefinitionElement(this._defination) : super(_defination) {
    if (_defination.variableDefinitions != null) {
      _variableDefinition = _defination.variableDefinitions.variableDefinitions
          .map((variableDefination) =>
              VariableDefinitionElement(variableDefination, this))
          .toList();
    }

    _directives = _defination.directives
        .map((directive) => DirectiveElement(directive))
        .toList();

    if (_defination.selectionSet != null) {
      _selectionSet = SelectionSetElement(_defination.selectionSet);
    }
    _findFragmentNames();
  }

  @override
  final kind = ElementKind.OperationDefinition;

  final OperationDefinitionContext _defination;

  String get operation {
    return _defination.TYPE.text;
  }

  String get name {
    return _defination.name;
  }

  bool get isMutation {
    return _defination.isMutation;
  }

  bool get isQuery {
    return _defination.isQuery;
  }

  bool get isSubscription {
    return _defination.isSubscription;
  }

  List<VariableDefinitionElement> _variableDefinition;

  List<VariableDefinitionElement> get variableDefinition {
    return _variableDefinition;
  }

  List<DirectiveElement> _directives;

  List<DirectiveElement> get directives {
    return _directives;
  }

  SelectionSetElement _selectionSet;

  SelectionSetElement get selectionSet {
    return _selectionSet;
  }

  List<String> fragments;

  void _findFragmentNames() {
    final visitor = _InlineFragmentsVisitor();
    accept(visitor);
    fragments = visitor.fragments.toList();
  }

  @override
  String source() {
    return _defination.span.text;
  }

  @override
  void accept(ElementVisitor visitor) {
    _variableDefinition = (_variableDefinition ?? [])
        .map((val) => visitor.visitVariableDefinition(val))
        .fold([], flat);

    _directives = (_directives ?? [])
        .map((directive) => visitor.visitDirective(directive))
        .fold([], flat);

    if (_selectionSet != null) {
      _selectionSet = visitor.visitSelectionSet(_selectionSet);
    }
  }
}

class _InlineFragmentsVisitor extends SimpleVisitor {
  _InlineFragmentsVisitor() : super(tap: (self, ele) {});

  final Set<String> fragments = {};

  @override
  SelectionSetElement visitSelectionSet(SelectionSetElement selectionSet) {
    selectionSet.accept(this);
    return super.visitSelectionSet(selectionSet);
  }

  @override
  List<FragmentSpreadElement> visitFragmentSpread(
      FragmentSpreadElement fragmentSpread) {
    fragments.add(fragmentSpread.name);
    return [fragmentSpread];
  }

  @override
  List<FieldElement> visitField(FieldElement field) {
    field.accept(this);
    return super.visitField(field);
  }
}
