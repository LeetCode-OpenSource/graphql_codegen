import 'package:graphql_parser/graphql_parser.dart';

import 'operation_defination.dart';
import 'element_kind.dart';
import 'named_type.dart';
import 'value.dart';
import 'variable.dart';
import 'visitor.dart';
import 'element.dart';

class VariableDefinitionElement extends Element {
  VariableDefinitionElement(this._variableDefination, this.parent) : super() {
    if (this._variableDefination.variable != null) {
      _variable = VariableElement(this._variableDefination.variable);
    }

    if (this._variableDefination.type != null) {
      _type = NamedTypeElement(this._variableDefination.type.typeName,
          this._variableDefination.type.isNullable);
    }

    if (this._variableDefination.defaultValue != null) {
      _defaultValue = ValueElement(this._variableDefination.defaultValue.value);
    }
  }

  final kind = ElementKind.VariableDefinition;

  final OperationDefinitionElement parent;

  final VariableDefinitionContext _variableDefination;

  VariableElement _variable;

  VariableElement get variable {
    return _variable;
  }

  NamedTypeElement _type;

  NamedTypeElement get type {
    return _type;
  }

  ValueElement _defaultValue;

  ValueElement get defaultValue {
    return _defaultValue;
  }

  @override
  String source() {
    return null;
  }

  @override
  void accept(ElementVisitor visitor) {
    if (_variable != null) {
      _variable = visitor.visitVariable(_variable);
    }

    if (_type != null) {
      _type = visitor.visitNamedType(_type);
    }

    if (_defaultValue != null) {
      _defaultValue = visitor.visitValue(_defaultValue);
    }
  }
}
