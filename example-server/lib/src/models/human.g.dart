// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'human.dart';

// **************************************************************************
// _GraphQLGenerator
// **************************************************************************

/// Auto-generated from [Human].
final GraphQLObjectType humanGraphQLType =
    objectType('Human', isInterface: true, interfaces: [
  characterGraphQLType
], fields: [
  field('id', graphQLString),
  field('createdAt', graphQLDate),
  field('updatedAt', graphQLDate),
  field('id', graphQLString),
  field('name', graphQLString),
  field('appearsIn', listOf(episodeGraphQLType)),
  field('friends', listOf(characterGraphQLType)),
  field('totalCredits', graphQLInt),
  field('idAsInt', graphQLInt)
]);
