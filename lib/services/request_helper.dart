import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:zapytaj/config/app_config.dart';

class RequestHelper {
  // API URL (The file performing CRUD operations)
  static const API = URL + '/api';

  static Map<String, String> headers = {
    "Accept": "application/json",
  };

  static Map<String, String> multiRequestHeaders = {
    "Content-type": "multipart/form-data",
  };

  static Future<http.Response> post(BuildContext context,
      {String endpoint, Map data}) async {
    http.Response response;
    try {
      response = await http.post(API + endpoint, headers: headers, body: data);

      if (201 == response.statusCode) {
        final parsed = json.decode(response.body);
        if (parsed['message'] != null)
          Toast.show(parsed['message'], context, duration: 2);
        return response;
      } else if (404 == response.statusCode) {
        final parsed = json.decode(response.body);
        if (parsed["message"] != null)
          Toast.show(parsed["message"][0], context, duration: 2);
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      print(response.body);
      return null;
    }
  }

  static Future<http.Response> get(BuildContext context,
      {String endpoint}) async {
    var response;
    try {
      response = await http.get(API + endpoint, headers: headers);
      if (200 == response.statusCode) {
        print(response);
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print('$e');
      print(response.body);
      return null;
    }
  }

  static Future<http.Response> put(BuildContext context,
      {String endpoint, Map data}) async {
    http.Response response;
    try {
      response = await http.put(API + endpoint, headers: headers, body: data);

      if (200 == response.statusCode) {
        // final parsed = json.decode(response.body);
        // if (parsed['message'] != null)
        //   Toast.show(parsed['message'], context, duration: 2);
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      print(response.body);
      return null;
    }
  }

  static Future multipartRequest(
    BuildContext context, {
    String endpoint,
    Map<String, String> data,
    List<http.MultipartFile> files,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(API + endpoint));
      request.files.addAll(files);
      request.headers.addAll(multiRequestHeaders);
      request.fields.addAll(data);
      print("request: " + request.toString());
      var res = await request.send();
      print("This is response:" + res.reasonPhrase);
      String resBody = await res.stream.bytesToString();
      print(resBody);
      return resBody;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
