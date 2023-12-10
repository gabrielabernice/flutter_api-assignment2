part of 'models.dart';

class Province extends Equatable {
  final String? provinceId;
  final String? province;

  const Province({this.provinceId, this.province});

  factory Province.fromMap(Map<String, dynamic> map) => Province(
        provinceId: map['province_id'] as String?,
        province: map['province'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'province_id': provinceId,
        'province': province,
      };

  /// `dart:convert`
  ///
  /// Parses the map and returns the resulting [Province].
  factory Province.fromJson(Map<String, dynamic> map) {
    return Province.fromMap(map);
  }

  /// `dart:convert`
  ///
  /// Converts [Province] to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  List<Object?> get props => [provinceId, province];

  @override
  bool get stringify => true;
}
