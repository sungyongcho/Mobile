import 'package:http/http.dart';
import 'dart:convert';

class WorldTime {
  String location; // location name for the UI
  late String time; // the time in that location
  String flag; // url to an asset flag icon
  String url; // location url for api endpoint

  WorldTime({required this.location, required this.flag, required this.url});

  Future<void> getTime() async {
    // TODO: need to fix
    Response response = await get(
        Uri.parse('https://timeapi.io/api/time/current/zone?timeZone=$url'));
    Map data = jsonDecode(response.body);

    String datetime = data['dateTime'];

    DateTime now = DateTime.parse(datetime);

    // set the time property
    time = now.toString();
  }
}
