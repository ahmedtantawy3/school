import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school/bloc/ClassList/class_list_bloc.dart';
import 'package:school/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/pages/my_classes_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    await FirebaseFirestore.instance.enablePersistence();
  }

  runApp(const MyApp());
}

enum HomePageType {
  firstPage,
  secondPage,
  thirdPage,
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ClassListBloc()..add(LoadClasses()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('ar'), // Arabic
        ],
        home: const HomePage(),
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16), // Button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Button border radius
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageType _currentPage = HomePageType.firstPage;

  Widget _buildHomePageWidget() {
    switch (_currentPage) {
      case HomePageType.firstPage:
        return const FirstPage();
      case HomePageType.secondPage:
        return const SecondPage();
      case HomePageType.thirdPage:
        return const ThirdPage();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mr Haitham Tammam Center'),
        backgroundColor: Colors.orange, // Set home AppBar background color
      ),
      body: Row(
        children: [
          // Column of buttons
          Container(
            color: Colors.purple[200], // Set column background color
            padding: const EdgeInsets.all(16), // Add padding to the column
            child: SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage = HomePageType.firstPage;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.purple, // Set button background color
                      ),
                      child: const Text('Classes'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage = HomePageType.secondPage;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.deepOrange, // Set button background color
                      ),
                      child: const Text('Students'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage = HomePageType.thirdPage;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Set button background color
                      ),
                      child: const Text('Treasury'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Container for the main content
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: _buildHomePageWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyClassesPage();
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Second Page Content'),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Third Page Content'),
    );
  }
}
