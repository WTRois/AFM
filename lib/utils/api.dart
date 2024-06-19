import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Network{
  final String _url = 'http://192.168.8.217:8000/api';
  //final String _url = 'https://absensi.suemerugrup.com/api';

  String token = "";

  

  _getToken() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token')!;
    
  }

  auth(data, apiURL) async{
    var fullUrl = Uri.parse(_url + apiURL);
    return await http.post(
      fullUrl,
      body: jsonEncode(data),
      headers: _setHeaders()
    );
  }

  getData(apiURL) async{
    var fullUrl = Uri.parse(_url + apiURL);
    await _getToken();
    var h = _setHeaders();
    return await http.get(
      fullUrl,
      headers: h,
    ).timeout(Duration(seconds: 60));
  }

  postData(data, apiURL) async{
    var fullUrl = Uri.parse(_url + apiURL);
    await _getToken();
    var h = _setHeaders();
    return await http.post(
      fullUrl,
      body: jsonEncode(data),
      headers: h,
    );
  }

  _setHeaders() => {
    "Content-type": "application/json",
    "Accept": "application/json",
    HttpHeaders.authorizationHeader: 'Bearer $token',
  };

  getUrl(){
    return _url;
  }

  getHeader(){
    return _setHeaders();
  }

  fetchData(apiURL) async{
    var fullUrl = Uri.parse(apiURL);
    return await http.get(
      fullUrl,
    ).timeout(Duration(seconds: 60));
  }
}