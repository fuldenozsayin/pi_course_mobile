import 'package:flutter/material.dart';
import 'package:pi_course_mobile/features/tutors/presentation/tutor_courses_page.dart' show TutorCoursesPage;
import 'features/auth/presentation/login_page.dart';
import 'features/lessons/presentation/my_requests_page.dart';
import 'features/lessons/presentation/incoming_requests_page.dart';
import 'features/auth/presentation/me_page.dart';
import 'features/tutors/presentation/tutor_list_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pi Course',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const LoginPage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      routes: {
        '/tutors': (_) => const TutorListPage(),
        '/me': (_) => const MePage(),
        '/my_requests': (_) => const MyRequestsPage(),
        '/incoming_requests': (_) => const IncomingRequestsPage(),
        '/tutor_courses': (_) => const TutorCoursesPage(),
      },
    );
  }
}
