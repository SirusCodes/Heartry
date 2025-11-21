import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final changelogProvider = FutureProvider<String>((ref) async {
  const changelogURL =
      "https://raw.githubusercontent.com/SirusCodes/Heartry/main/CHANGELOG.md";
  final response = await http.get(Uri.parse(changelogURL));

  if (response.statusCode != 200) {
    throw Exception("Changelog was not reachable");
  }

  return response.body;
});
