import 'package:car_manufac/car_mfr.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  CarMfr? carMfr;

  Future<CarMfr?> getCarMfr() async {
    var url = "vpic.nhtsa.dot.gov";
    var uri = Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    var response = await get(uri);

    if (response.statusCode == 200) {
      carMfr = carMfrFromJson(response.body);
      return carMfr;
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
      ),
      body: FutureBuilder<CarMfr?>(
        future: getCarMfr(),
        builder: (BuildContext context, AsyncSnapshot<CarMfr?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var results = snapshot.data?.results ?? [];
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var result = results[index];
                return ListTile(
                  title: Text(result.mfrName ?? "Unknown Manufacturer"),
                  subtitle: Text(result.country ?? "Unknown Country"),
                );
              },
            );
          }
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }
}