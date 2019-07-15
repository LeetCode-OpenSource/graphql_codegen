// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'droid.dart';

// **************************************************************************
// _GraphQLGenerator
// **************************************************************************

/// Auto-generated from [Droid].
final GraphQLObjectType droidGraphQLType = objectType('Droid',
    isInterface: true,
    description: 'Beep! Boop!',
    interfaces: [
      characterGraphQLType
    ],
    fields: [
      field('id', graphQLString),
      field('createdAt', graphQLDate),
      field('updatedAt', graphQLDate),
      field('id', graphQLString),
      field('name', graphQLString),
      field('appearsIn', listOf(episodeGraphQLType)),
      field('friends', listOf(characterGraphQLType),
          description:
              'Doc comments automatically become GraphQL descriptions.'),
      field('idAsInt', graphQLInt)
    ]);
