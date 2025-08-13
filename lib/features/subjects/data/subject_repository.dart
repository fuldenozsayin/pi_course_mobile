import '../../../core/api_client.dart';
import 'models/subject.dart';

class SubjectRepository {
  final ApiClient _api;
  SubjectRepository(this._api);

  Future<List<Subject>> list() async {
    final r = await _api.dio.get('/subjects');
    final data = r.data;
    final List raw = switch (data) {
      List => data,
      Map<String, dynamic> m when m['results'] is List => m['results'] as List,
      _ => throw StateError('Unexpected /subjects payload: $data'),
    };
    return raw.map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
  }
}
