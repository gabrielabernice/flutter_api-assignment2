part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Province> provinceData = []; ///
  bool isLoading = false;

  Future<dynamic> getProvinces() async{////
    await MasterDataService.getProvince().then((value) {
      setState(() {
        provinceData = value; ///
        isLoading = false;
      });
    });
  }

  dynamic cityDataOrigin;
  dynamic cityIdOrigin;
  dynamic selectedCityOrigin;

  Future<List<City>> getCities(var provId) async{////
    dynamic city;
    await MasterDataService.getCity(provId).then((value) {
      setState(() {
        city = value;
      });
    });

    return city;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getProvinces();////
    cityDataOrigin = getCities("5");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: [
                      Text("Origin"),
                      Container(
                        width: 240,
                        child: FutureBuilder<List<City>>(
                          future: cityDataOrigin,
                          builder: (context, snapshot){
                            if(snapshot.hasData){
                              return DropdownButton(
                                isExpanded: true,
                                value: selectedCityOrigin,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 30,
                                elevation: 4,
                                style: TextStyle(color: Colors.black),
                                hint: selectedCityOrigin == null
                                ? Text('Pilih kota')
                                : Text(selectedCityOrigin.cityName),
                                items: snapshot.data!.map<DropdownMenuItem<City>>((City value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value.cityName.toString())
                                  );
                                }).toList(),
                                onChanged: (newValue){
                                  setState(() {
                                    selectedCityOrigin = newValue;
                                    cityIdOrigin = selectedCityOrigin.cityId;
                                  });
                                }
                              );
                            }else if(snapshot.hasError){
                              return Text("Tidak ada data");
                            }
                            return UiLoading.loadingSmall();
                          }),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: provinceData.isEmpty
                  ? const Align(
                      alignment: Alignment.center,
                      child: Text("Data tidak ditemukan"),
                  )
                  : ListView.builder(
                    itemCount: provinceData.length,
                    itemBuilder: (context, index){
                      return CardProvince(provinceData[index]);
                    }
                  )
                ),
              ),
            ],
          ),
          isLoading == true ? UiLoading.loadingBlock()
          : Container()
        ],
      ),
    );
  }
}