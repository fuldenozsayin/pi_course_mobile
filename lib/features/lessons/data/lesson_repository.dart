import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pi_course_mobile/features/auth/providers.dart';
import '../../../core/api_client.dart';
import 'models/lesson_request.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return LessonRepository(api);
});

class LessonRepository {
  LessonRepository(this._api);
  final ApiClient _api;

  Future<List<LessonRequest>> list({
    required String role, // 'student' | 'tutor'
    String? status, // pending | approved | rejected
  }) async {
    final q = {
      'role': role,
      if (status != null) 'status': status,
    };
    final res = await _api.dio.get('/lesson-requests/', queryParameters: q);
    final data = res.data is Map<String, dynamic> ? res.data['results'] : res.data;
    final list = (data as List).map((e) => LessonRequest.fromJson(e)).toList();
    return list;
  }

  Future<LessonRequest> create({
    required int tutorId,
    required int subjectId,
    required String startTime, // ISO
    required int durationMinutes,
    String? note,
  }) async {
    final body = {
      'tutor_id': tutorId,
      'subject_id': subjectId,
      'start_time': startTime,
      'duration_minutes': durationMinutes,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final res = await _api.dio.post('/lesson-requests/', data: body);
    return LessonRequest.fromJson(res.data);
  }

  Future<void> changeStatus({required int id, required String status}) async {
    try {
      // DRF çoğunlukla trailing slash ister
      await _api.dio.patch('/lesson-requests/$id/', data: {'status': status});
    } on DioException catch (e) {
      final sc = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('Status change failed (HTTP $sc): $body');
    }
  }
}
