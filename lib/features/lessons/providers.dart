import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pi_course_mobile/features/auth/providers.dart';
import 'data/lesson_repository.dart';
import 'data/models/lesson_request.dart';

final lessonRepositoryProvider =
Provider((ref) => LessonRepository(ref.read(apiClientProvider)));

final myRequestsFilterProvider = StateProvider<Map<String, String?>>(
      (_) => {'role': 'student', 'status': null},
);

final myRequestsProvider = FutureProvider<List<LessonRequest>>((ref) async {
  final p = ref.watch(myRequestsFilterProvider);
  return ref.read(lessonRepositoryProvider)
      .list(role: p['role']!, status: p['status']);
});
