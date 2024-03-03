import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  final body = (await context.request.json()) as Map<String, dynamic>;

  final response = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'client_id': Platform.environment['GOOGLE_CLIENT_ID'],
      'client_secret': Platform.environment['GOOGLE_CLIENT_SECRET'],
      'code': body['code'],
      'grant_type': 'authorization_code',
      'redirect_uri': null,
    },
  );

  return Response(body: response.body);
}
