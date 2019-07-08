import 'package:graphql_codegen/graphql_codegen.dart';

main() {
  final result = gen('''
query GetUser(\$userId: ID!, \$withFriends: Boolean!) {
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
  }
}

fragment PictureFragment on Picture {
  uri,
  width,
  height
}
  ''');
  print(result);
}
