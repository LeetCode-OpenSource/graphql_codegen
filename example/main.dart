import 'package:graphql_codegen/graphql_codegen.dart';

import 'introspection.dart';

class DartGenerateVisitor extends SimpleVisitor {
  DartGenerateVisitor({Tap tap}) : super(tap: tap);

  String _result = '';

  @override
  String getResult() {
    return _result;
  }

  String getDefaultValue(ValueElement value) {
    if (value.valueKind == ValueKind.String) {
      return '"${value.source()}"';
    } else if (value.valueKind == ValueKind.Boolean) {
      return '${value.source()}';
    }
  }

  @override
  List<OperationDefinitionElement> visitOperationDefinition(
      OperationDefinitionElement defination) {
    final constructorParams = defination.variableDefinition.map((variable) {
      if (variable.defaultValue != null) {
        return 'this.${variable.variable.name} = ${getDefaultValue(variable.defaultValue)}';
      } else {
        return 'this.${variable.variable.name}';
      }
    }).join(', ');
    _result += '''
    class ${defination.name}Variable {
      ${defination.name}Variable({$constructorParams});
    }
    ''';
    return super.visitOperationDefinition(defination);
  }
}

void tap(SimpleVisitor visitor, Element ele) {
  print(ele.kind);
  ele.accept(visitor);
}

main() {
  final visitor = DartGenerateVisitor(tap: tap);
  final result = gen('''
query GetUser(\$userId: ID!, \$withFriends: Boolean = false) {
  user(id: \$userId) {
    id,
    name,
    isViewerFriend,
    profilePicture(size: 50)  {
      ...PictureFragment
    }
  	friends @include(if: \$withFriends) {
      name
    }
    friend @include(if: 1) {
      name
    }
  }
}

fragment PictureFragment on Picture {
  uri,
  width,
  height
}
  ''', visitor);
  print(result);
}
