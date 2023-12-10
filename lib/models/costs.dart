part of 'models.dart';

class Costs extends Equatable {
  final String? service;
  final String? description;
  final List<Cost>? cost;

  const Costs({this.service, this.description, this.cost});

  factory Costs.fromMap(Map<String, dynamic> data) => Costs(
        service: data['service'] as String?,
        description: data['description'] as String?,
        cost: (data['cost'] as List<dynamic>?)
            ?.map((e) => Cost.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'service': service,
        'description': description,
        'cost': cost?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Costs].
  factory Costs.fromJson(String data) {
    return Costs.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Costs] to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [service, description, cost];
}

class ShippingResponse {
  final List<Costs>? costs;

  ShippingResponse({this.costs});

  factory ShippingResponse.fromMap(Map<String, dynamic> map) {
    var results = map['rajaongkir']['results'] as List<dynamic>;
    var costsList = results.map((e) => Costs.fromMap(e)).toList();
    return ShippingResponse(costs: costsList);
  }
}

class ShippingResult {
  final ShippingResponse? response;
  final String? errorMessage;

  ShippingResult._({this.response, this.errorMessage});

  factory ShippingResult.success(ShippingResponse response) {
    return ShippingResult._(response: response);
  }

  factory ShippingResult.error(String errorMessage) {
    return ShippingResult._(errorMessage: errorMessage);
  }

  bool get isSuccess => response != null;
  bool get isError => errorMessage != null;
}
