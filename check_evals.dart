import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = "https://spotlight-api-m2kt.onrender.com/api";
  try {
    final response = await http.get(Uri.parse(baseUrl + '/Evaluations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Total evaluations: \${data.length}');
      if (data.isNotEmpty) {
        print('Latest evaluation:');
        print(const JsonEncoder.withIndent('  ').convert(data.last));
      }
    }
  } catch (e) {
    print('Error: \$e');
  }
}
