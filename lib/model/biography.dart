import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:superheroes/model/alignment_info.dart';

part 'biography.g.dart';

@JsonSerializable()
class Biography {
  final String fullName;
  final String alignment;
  final List<String> aliases;
  final String placeOfBirth;

  Biography({
    required this.fullName,
    required this.alignment,
    required this.aliases,
    required this.placeOfBirth,
  });

  factory Biography.fromJson(final Map<String, dynamic> json) =>
      _$BiographyFromJson(json);

  Map<String, dynamic> toJson() => _$BiographyToJson(this);

  AlignmentInfo? get alignmentInfo => AlignmentInfo.fromAlignment(alignment);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Biography &&
        other.fullName == fullName &&
        other.alignment == alignment &&
        listEquals(other.aliases, aliases) &&
        other.placeOfBirth == placeOfBirth;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        alignment.hashCode ^
        aliases.hashCode ^
        placeOfBirth.hashCode;
  }
}
