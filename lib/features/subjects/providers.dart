import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pi_course_mobile/features/auth/providers.dart';
import 'data/subject_repository.dart';
import 'data/models/subject.dart';

final subjectRepositoryProvider = Provider((ref) =>
    SubjectRepository(ref.read(apiClientProvider)));

final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  return ref.read(subjectRepositoryProvider).list();
});
