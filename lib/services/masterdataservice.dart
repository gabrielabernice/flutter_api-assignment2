part of 'services.dart';

class MasterDataService {
  static Future<List<Province>> getProvince() async {
    var response = await http.get(Uri.https(Const.baseUrl, "/starter/province"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        });

    if (response.statusCode == 200) {
      var job = json.decode(response.body);
      List<Province> result = (job['rajaongkir']['results'] as List)
          .map((e) => Province.fromJson(e as Map<String, dynamic>))
          .toList();
      return result;
    } else {
      // Handle non-200 responses or throw an exception
      throw Exception('Failed to load provinces');
    }
  }

  static Future<List<City>> getCity(String provId) async {
    // Append the province ID as a query parameter
    var uri = Uri.https(Const.baseUrl, "/starter/city", {'province': provId});

    var response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'key': Const.apiKey,
    });

    if (response.statusCode == 200) {
      var job = json.decode(response.body);
      List<City> result = (job['rajaongkir']['results'] as List)
          .map((e) => City.fromMap(e as Map<String, dynamic>))
          .toList();
      return result;
    } else {
      throw Exception('Failed to load cities');
    }
  }

  static Future<String> calculateShipping({
    required City? originCity,
    required City? destinationCity,
    required String weight,
    required String courier,
  }) async {
    if (originCity == null ||
        destinationCity == null ||
        weight.isEmpty ||
        courier.isEmpty) {
      return 'Error: Missing required fields';
    }

    var uri = Uri.https(Const.baseUrl, "/starter/cost");
    int weightInt = int.tryParse(weight) ?? 0; // Safe parsing with default to 0

    var shippingData = {
      "origin": originCity.cityId,
      "destination": destinationCity.cityId,
      "weight": weightInt,
      "courier": courier.toLowerCase(),
    };

    try {
      var response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey, // Assuming you need the API key here too
        },
        body: jsonEncode(shippingData),
      );

      if (response.statusCode == 200) {
        // Process the response if the status is OK
        return response
            .body; // Or any other way you want to process the response
      } else {
        // Handle non-200 responses
        return 'Error: Failed to calculate shipping';
      }
    } catch (e) {
      // Handle any errors during the request
      return 'Error: ${e.toString()}';
    }
  }
}
