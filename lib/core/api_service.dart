import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/solution_step.dart';

class ApiService {
  static const String defaultBaseUrl = 'http://127.0.0.1:8000';
  final String baseUrl;

  ApiService({this.baseUrl = defaultBaseUrl});

  Future<bool> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/health')).timeout(
        const Duration(seconds: 2),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<SolveResult> solveEquation(String equation) async {
    final cleanEq = equation.trim();
    if (cleanEq.isEmpty) {
      throw Exception('يرجى إدخال معادلة رياضية صالحة.');
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/solve'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'equation_latex': cleanEq}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return SolveResult.fromJson(data);
      } else {
        final err = jsonDecode(utf8.decode(res.bodyBytes));
        throw Exception(err['detail'] ?? 'تعذر حل المعادلة رمزياً.');
      }
    } catch (e) {
      throw Exception('تعذر الاتصال بمحرك الذكاء الاصطناعي ($e). تأكد من تشغيل خادم الباك إند.');
    }
  }
}
