import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';
import 'field_meta.dart';
import 'scalar_type_mapping.dart';
import 'utils.dart';

class SelectionVisitor extends SimpleVisitor {
  SelectionVisitor(this.typeMap, this.subTypeMap, this.operationName,
      this.graphqlTypeMeta, this.fragments,
      {Tap tap})
      : super(tap: tap) {
    schemaName = operationName;
    if (graphqlTypeMeta.isList) {
      typeName = schemaName;
    } else {
      typeName = graphqlTypeMeta.name;
    }
  }

  final Map<String, dynamic> typeMap;

  final Map<String, dynamic> subTypeMap;

  final Map<String, FragmentDefinationElement> fragments;

  final String operationName;

  String unionClassName;

  FieldMeta graphqlTypeMeta;

  String schemaName;

  String fieldName;

  String alias;

  String typeName;

  String _result = '';

  bool isScalar = false;

  String get schemaDef {
    if (graphqlTypeMeta.isList) {
      final listOpen = List.filled(graphqlTypeMeta.listCount, 'List<').join('');
      final listClose = List.filled(graphqlTypeMeta.listCount, '>').join('');
      return '$listOpen$schemaName$listClose ${graphqlTypeMeta.fieldName};';
    } else {
      return '$schemaName ${graphqlTypeMeta.fieldName};';
    }
  }

  @override
  String getResult() {
    return _result;
  }

  @override
  List<InlineFragmentElement> visitInlineFragment(
      InlineFragmentElement inlineFragment) {
    schemaName = inlineFragment.typeCondition.name;
    typeName = schemaName;
    _result += generateFromSelection(
        '${schemaName}Of$unionClassName',
        '$operationName$schemaName',
        graphqlTypeMeta.name,
        inlineFragment.selectionSet.selections,
        typeMap,
        fragments);
    return [inlineFragment];
  }

  @override
  List<FieldElement> visitField(FieldElement field) {
    fieldName = field.name;
    alias = field.alias;
    if (field.selectionSet != null) {
      if (graphqlTypeMeta.isUnion) {
        schemaName =
            '$operationName${capitalizeUpperCase(fieldName)}${graphqlTypeMeta.name}';
        typeName = schemaName;
        final result = generateUnions(
            typeMap[graphqlTypeMeta.name],
            graphqlTypeMeta.name,
            schemaName,
            flatFragmentSpreadSelections(
                    field.selectionSet.selections, fragments)
                .whereType<InlineFragmentElement>()
                .map((selection) {
              final InlineFragmentElement inlineFragment = selection;
              return inlineFragment.typeCondition.name;
            }).toSet());
        _result += result;
        _result += generateFromSelection(
            schemaName,
            operationName,
            graphqlTypeMeta.name,
            field.selectionSet.selections,
            typeMap,
            fragments,
            skipClassGeneration: true);
      } else {
        final childFiledsResults = generateFromSelection(
            schemaName,
            '$operationName${capitalizeUpperCase(fieldName)}',
            graphqlTypeMeta.name,
            field.selectionSet.selections,
            typeMap,
            fragments);
        _result += childFiledsResults;
      }
    } else {
      final fieldMeta = findDeepOfType(subTypeMap[field.name]);
      final typeName = fieldMeta.isEnum
          ? '${capitalizeUpperCase(fieldMeta.name)}'
          : scalarTypeMapping[fieldMeta.name];
      isScalar = !fieldMeta.isEnum;
      schemaName = typeName;
    }
    return super.visitField(field);
  }
}
