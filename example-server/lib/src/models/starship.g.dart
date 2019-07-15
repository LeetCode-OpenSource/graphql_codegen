// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'starship.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

@generatedSerializable
class Starship extends _Starship {
  Starship({this.id, this.createdAt, this.updatedAt, this.name, this.length});

  /// A unique identifier corresponding to this item.
  @override
  String id;

  /// The time at which this item was created.
  @override
  DateTime createdAt;

  /// The last time at which this item was updated.
  @override
  DateTime updatedAt;

  @override
  final String name;

  @override
  final int length;

  Starship copyWith(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      String name,
      int length}) {
    return Starship(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        name: name ?? this.name,
        length: length ?? this.length);
  }

  bool operator ==(other) {
    return other is _Starship &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.name == name &&
        other.length == length;
  }

  @override
  int get hashCode {
    return hashObjects([id, createdAt, updatedAt, name, length]);
  }

  @override
  String toString() {
    return "Starship(id=$id, createdAt=$createdAt, updatedAt=$updatedAt, name=$name, length=$length)";
  }

  Map<String, dynamic> toJson() {
    return StarshipSerializer.toMap(this);
  }
}

// **************************************************************************
// SerializerGenerator
// **************************************************************************

const StarshipSerializer starshipSerializer = StarshipSerializer();

class StarshipEncoder extends Converter<Starship, Map> {
  const StarshipEncoder();

  @override
  Map convert(Starship model) => StarshipSerializer.toMap(model);
}

class StarshipDecoder extends Converter<Map, Starship> {
  const StarshipDecoder();

  @override
  Starship convert(Map map) => StarshipSerializer.fromMap(map);
}

class StarshipSerializer extends Codec<Starship, Map> {
  const StarshipSerializer();

  @override
  get encoder => const StarshipEncoder();
  @override
  get decoder => const StarshipDecoder();
  static Starship fromMap(Map map) {
    return Starship(
        id: map['id'] as String,
        createdAt: map['created_at'] != null
            ? (map['created_at'] is DateTime
                ? (map['created_at'] as DateTime)
                : DateTime.parse(map['created_at'].toString()))
            : null,
        updatedAt: map['updated_at'] != null
            ? (map['updated_at'] is DateTime
                ? (map['updated_at'] as DateTime)
                : DateTime.parse(map['updated_at'].toString()))
            : null,
        name: map['name'] as String,
        length: map['length'] as int);
  }

  static Map<String, dynamic> toMap(_Starship model) {
    if (model == null) {
      return null;
    }
    return {
      'id': model.id,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
      'name': model.name,
      'length': model.length
    };
  }
}

abstract class StarshipFields {
  static const List<String> allFields = <String>[
    id,
    createdAt,
    updatedAt,
    name,
    length
  ];

  static const String id = 'id';

  static const String createdAt = 'created_at';

  static const String updatedAt = 'updated_at';

  static const String name = 'name';

  static const String length = 'length';
}

// **************************************************************************
// _GraphQLGenerator
// **************************************************************************

/// Auto-generated from [Starship].
final GraphQLObjectType starshipGraphQLType =
    objectType('Starship', isInterface: false, interfaces: [], fields: [
  field('id', graphQLString),
  field('created_at', graphQLDate),
  field('updated_at', graphQLDate),
  field('name', graphQLString),
  field('length', graphQLInt),
  field('idAsInt', graphQLInt)
]);
