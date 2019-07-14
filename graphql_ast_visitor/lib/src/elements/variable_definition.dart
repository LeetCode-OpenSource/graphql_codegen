import 'package:graphql_parser/graphql_parser.dart';

import 'element.dart';
import 'element_kind.dart';
import 'named_type.dart';
import 'operation_defination.dart';
import 'utils.dart';
import 'value.dart';
import 'variable.dart';
import 'visitor.dart';

class VariableDefinitionElement extends Element {
  VariableDefinitionElement(this._variableDefination, this.parent) : super() {
    if (_variableDefination.variable != null) {
      _variable = VariableElement(_variableDefination.variable);
    }

    if (_variableDefination.type != null) {
      final typeMeta = getTypeMeta(_variableDefination.type);
      isNullable = typeMeta.isNullable;
      isList = typeMeta.isList;
      _type = NamedTypeElement(typeMeta.typeName);
    }

    if (_variableDefination.defaultValue != null) {
      _defaultValue = ValueElement(_variableDefination.defaultValue.value);
    }
  }

  @override
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

  bool isNullable = false;

  bool isList = false;

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
