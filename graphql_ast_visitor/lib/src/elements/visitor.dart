import 'argument.dart';
import 'directive.dart';
import 'element.dart';
import 'field.dart';
import 'fragment_defination.dart';
import 'fragment_spread.dart';
import 'inline_fragment.dart';
import 'named_type.dart';
import 'operation_defination.dart';
import 'selection_set.dart';
import 'value.dart';
import 'variable.dart';
import 'variable_definition.dart';

abstract class ElementVisitor {
  String getResult();

  List<OperationDefinitionElement> visitOperationDefinition(
      OperationDefinitionElement defination);

  List<FragmentDefinationElement> visitFragmentDefinition(
      FragmentDefinationElement defination);

  NamedTypeElement visitNamedType(NamedTypeElement type);

  List<DirectiveElement> visitDirective(DirectiveElement directive);

  VariableElement visitVariable(VariableElement variable);

  ValueElement visitValue(ValueElement value);

  SelectionSetElement visitSelectionSet(SelectionSetElement selectionSet);

  List<FieldElement> visitField(FieldElement field);

  List<InlineFragmentElement> visitInlineFragment(
      InlineFragmentElement inlineFragment);

  List<FragmentSpreadElement> visitFragmentSpread(
      FragmentSpreadElement fragmentSpread);

  List<ArgumentElement> visitArgument(ArgumentElement argument);

  List<VariableDefinitionElement> visitVariableDefinition(
      VariableDefinitionElement varibleDefinition);
}

class SimpleVisitor extends ElementVisitor {
  SimpleVisitor({this.tap}) : super();

  @override
  String getResult() {
    return '';
  }

  final Tap tap;

  @override
  List<OperationDefinitionElement> visitOperationDefinition(
      OperationDefinitionElement defination) {
    tap(this, defination);
    return [defination];
  }

  @override
  List<FragmentDefinationElement> visitFragmentDefinition(
      FragmentDefinationElement defination) {
    tap(this, defination);
    return [defination];
  }

  @override
  NamedTypeElement visitNamedType(NamedTypeElement type) {
    tap(this, type);
    return type;
  }

  @override
  List<DirectiveElement> visitDirective(DirectiveElement directive) {
    tap(this, directive);
    return [directive];
  }

  @override
  VariableElement visitVariable(VariableElement variable) {
    tap(this, variable);
    return variable;
  }

  @override
  ValueElement visitValue(ValueElement value) {
    tap(this, value);
    return value;
  }

  @override
  SelectionSetElement visitSelectionSet(SelectionSetElement selectionSet) {
    tap(this, selectionSet);
    return selectionSet;
  }

  @override
  List<FieldElement> visitField(FieldElement field) {
    tap(this, field);
    return [field];
  }

  @override
  List<InlineFragmentElement> visitInlineFragment(
      InlineFragmentElement inlineFragment) {
    tap(this, inlineFragment);
    return [inlineFragment];
  }

  @override
  List<FragmentSpreadElement> visitFragmentSpread(
      FragmentSpreadElement fragmentSpread) {
    tap(this, fragmentSpread);
    return [fragmentSpread];
  }

  @override
  List<ArgumentElement> visitArgument(ArgumentElement argument) {
    tap(this, argument);
    return [argument];
  }

  @override
  List<VariableDefinitionElement> visitVariableDefinition(
      VariableDefinitionElement varibleDefinition) {
    tap(this, varibleDefinition);
    return [varibleDefinition];
  }
}

typedef Tap = void Function(SimpleVisitor visitor, Element element);
