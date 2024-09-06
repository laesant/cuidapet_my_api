import 'dart:convert';

abstract class RequestMapping {
  final Map<String, dynamic> data;

  RequestMapping.empty() : data = {};

  RequestMapping(String data) : data = jsonDecode(data) {
    map();
  }

  void map() {}
}
