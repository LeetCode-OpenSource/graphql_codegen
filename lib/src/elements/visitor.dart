import 'element.dart';
import 'fragment_defination.dart';
import 'variable_definition.dart';
import 'argument.dart';
import 'directive.dart';
import 'field.dart';
import 'fragment_spread.dart';
import 'inline_fragment.dart';
import 'operation_defination.dart';
import 'selection_set.dart';
import 'value.dart';
import 'variable.dart';
import 'named_type.dart';

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
  @override
  String getResult() {
    return '';
  }

  final Tap tap;

  SimpleVisitor({this.tap}) : super();

  List<OperationDefinitionElement> visitOperationDefinition(
      OperationDefinitionElement defination) {
    tap(this, defination);
    return [defination];
  }

  List<FragmentDefinationElement> visitFragmentDefinition(
      FragmentDefinationElement defination) {
    tap(this, defination);
    return [defination];
  }

  NamedTypeElement visitNamedType(NamedTypeElement type) {
    tap(this, type);
    return type;
  }

  List<DirectiveElement> visitDirective(DirectiveElement directive) {
    tap(this, directive);
    return [directive];
  }

  VariableElement visitVariable(VariableElement variable) {
    tap(this, variable);
    return variable;
  }

  ValueElement visitValue(ValueElement value) {
    tap(this, value);
    return value;
  }

  SelectionSetElement visitSelectionSet(SelectionSetElement selectionSet) {
    tap(this, selectionSet);
    return selectionSet;
  }

  List<FieldElement> visitField(FieldElement field) {
    tap(this, field);
    return [field];
  }

  List<InlineFragmentElement> visitInlineFragment(
      InlineFragmentElement inlineFragment) {
    tap(this, inlineFragment);
    return [inlineFragment];
  }

  List<FragmentSpreadElement> visitFragmentSpread(
      FragmentSpreadElement fragmentSpread) {
    tap(this, fragmentSpread);
    return [fragmentSpread];
  }

  List<ArgumentElement> visitArgument(ArgumentElement argument) {
    tap(this, argument);
    return [argument];
  }

  List<VariableDefinitionElement> visitVariableDefinition(
      VariableDefinitionElement varibleDefinition) {
    tap(this, varibleDefinition);
    return [varibleDefinition];
  }
}

typedef Tap = void Function(SimpleVisitor visitor, Element element);
