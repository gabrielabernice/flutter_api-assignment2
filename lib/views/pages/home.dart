part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController weightController = TextEditingController();
  List<Province> provinces = [];
  Province? selectedOriginProvince;
  Province? selectedDestinationProvince;
  List<City> originCities = [];
  List<City> destinationCities = [];
  City? selectedOriginCity;
  City? selectedDestinationCity;
  String? selectedCourier;
  bool isLoading = true;
  List<dynamic> shippingOptions = [];

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    try {
      var fetchedProvinces = await MasterDataService.getProvince();
      setState(() {
        provinces = fetchedProvinces;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching provinces: $e');
    }
  }

  Future<void> fetchCities(String provId, bool isOrigin) async {
    try {
      var fetchedCities = await MasterDataService.getCity(provId);
      setState(() {
        if (isOrigin) {
          originCities = fetchedCities;
          selectedOriginCity = null;
        } else {
          destinationCities = fetchedCities;
          selectedDestinationCity = null;
        }
      });
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  void handleCalculateShipping() async {
    if (selectedOriginCity == null ||
        selectedDestinationCity == null ||
        weightController.text.isEmpty ||
        selectedCourier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String result = await MasterDataService.calculateShipping(
        originCity: selectedOriginCity,
        destinationCity: selectedDestinationCity,
        weight: weightController.text,
        courier: selectedCourier!,
      );

      if (result.contains('Error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Parse the result and update the state
        var jsonResponse =
            jsonDecode(result); // Assuming result is a JSON string
        setState(() {
          shippingOptions = jsonResponse['rajaongkir']['results'][0]['costs'];
        });
      }
    } catch (e) {
      // Handle any errors that occur during the shipping calculation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Hitung Ongkir", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value:
                            selectedCourier, // Set the value to the selected courier
                        hint: const Text("Pilih Ekspedisi"),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem<String>(
                            value: "jne",
                            child: Text("JNE"),
                          ),
                          DropdownMenuItem<String>(
                            value: "pos",
                            child: Text("POS"),
                          ),
                          DropdownMenuItem<String>(
                            value: "tiki",
                            child: Text("TIKI"),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCourier =
                                newValue; // Update the selected courier
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(
                      width: 16), // Provide spacing between dropdown and input
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        labelText: 'Berat (gr)',
                        border: UnderlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: const Text(
                    'Origin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Province>(
                        hint: const Text("Select Province"),
                        value: selectedOriginProvince,
                        isExpanded: true,
                        onChanged: (Province? newValue) {
                          setState(() {
                            selectedOriginProvince = newValue;
                            fetchCities(newValue!.provinceId!,
                                true); // Fetch cities for the selected province
                          });
                        },
                        items: provinces
                            .map<DropdownMenuItem<Province>>((Province value) {
                          return DropdownMenuItem<Province>(
                            value: value,
                            child: Text(value.province ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<City>(
                        hint: const Text("Select City"),
                        value: selectedOriginCity,
                        isExpanded: true,
                        onChanged: originCities.isNotEmpty
                            ? (City? newValue) {
                                setState(() {
                                  selectedOriginCity = newValue;
                                });
                              }
                            : null,
                        items: originCities
                            .map<DropdownMenuItem<City>>((City value) {
                          return DropdownMenuItem<City>(
                            value: value,
                            child: Text(value.cityName ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: const Text(
                    'Destination',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Province>(
                        hint: const Text("Select Province"),
                        value: selectedDestinationProvince,
                        isExpanded: true,
                        onChanged: (Province? newValue) {
                          setState(() {
                            selectedDestinationProvince = newValue;
                            fetchCities(newValue!.provinceId!,
                                false); // Fetch cities for the selected province
                          });
                        },
                        items: provinces
                            .map<DropdownMenuItem<Province>>((Province value) {
                          return DropdownMenuItem<Province>(
                            value: value,
                            child: Text(value.province ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<City>(
                        hint: const Text("Select City"),
                        value: selectedDestinationCity,
                        isExpanded: true,
                        onChanged: destinationCities.isNotEmpty
                            ? (City? newValue) {
                                setState(() {
                                  selectedDestinationCity = newValue;
                                });
                              }
                            : null,
                        items: destinationCities
                            .map<DropdownMenuItem<City>>((City value) {
                          return DropdownMenuItem<City>(
                            value: value,
                            child: Text(value.cityName ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Button color
                  onPrimary: Colors.white, // Text color
                ),
                onPressed: handleCalculateShipping,
                child: const Text("Hitung Estimasi Harga"),
              ),
            ),
            // List of service options
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap:
                    true, // Use this to make ListView work in SingleChildScrollView
                physics:
                    NeverScrollableScrollPhysics(), // to disable ListView's scrolling
                itemCount:
                    shippingOptions.length, // Use the length of shippingOptions
                itemBuilder: (context, index) {
                  var service = shippingOptions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0), // Vertical margin
                    elevation: 4.0, // Shadow depth
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.local_shipping),
                      ),
                      title: Text(
                          '${service['service']} - ${service['description']}', // Display service name and description
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Biaya: Rp${service['cost'][0]['value']}"), // Display cost
                          Text(
                              "Estimasi Sampai: ${service['cost'][0]['etd']}", // Display estimated time
                              style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}