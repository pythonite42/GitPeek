import 'dart:convert';
import 'dart:io';
import 'package:gitpeek/models/repo.dart';
import 'package:http/http.dart' as http;

class GithubService {
  Future<List<Repo>> fetchRepos(String username) async {
    final url = Uri.parse('https://api.github.com/users/$username/repos');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((repoJson) => Repo.fromJson(repoJson)).toList();
      } else if (response.statusCode == 404) {
        throw HttpException('User konnte nicht gefunden werden');
      } else {
        throw HttpException('Repositories konnten nicht geladen werden');
      }
    } on SocketException {
      throw HttpException('Fehlende Internetverbindung');
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Ein unerwarteter Fehler ist aufgetreten');
    }
  }
}

class HttpException implements Exception {
  HttpException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}
