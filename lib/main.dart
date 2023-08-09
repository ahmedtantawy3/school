import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school/bloc/ClassList/class_list_bloc.dart';
import 'package:school/bloc/StudentsList/students_list_bloc.dart';
import 'package:school/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:school/pages/all_students.dart';
import 'package:school/services/my_student.dart';
import '/pages/my_classes_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:calendar_view/calendar_view.dart';
import 'dart:convert';
// import 'dart:html' as html;

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
  CameraPage,
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
        BlocProvider(
          create: (context) => StudentsListBloc()..add(LoadStudents()),
        ),
      ],
      child: CalendarControllerProvider(
        controller: EventController(),
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
          locale: const Locale('ar'),
          home: const HomePage(),
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Button border radius
                ),
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
      case HomePageType.CameraPage:
        return const CameraPage();
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
                      child: const Text('الصفوف'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage = HomePageType.CameraPage;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.deepOrange, // Set button background color
                      ),
                      child: const Text('الطلاب'),
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
                      child: const Text('الخزينة'),
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

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AllStudents();
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

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Firestore Data')),
        body: JsonData(),
      ),
    );
  }
}

class JsonData extends StatefulWidget {
  @override
  _JsonDataState createState() => _JsonDataState();
}

class _JsonDataState extends State<JsonData> {
  String? jsonStr;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    CollectionReference students =
        FirebaseFirestore.instance.collection('students');

    students.snapshots().listen((snapshot) {
      final studentDocs = snapshot.docs
          .map((doc) => MyStudent.fromFirestore(doc))
          .toList()
          .map((e) => e.toFirestore())
          .toList();

      List<Map<String, dynamic>> studentList = [];

      for (var studentDoc in studentDocs) {
        studentList.add(studentDoc);
      }

      setState(() {
        jsonStr = jsonEncode(studentDocs);
      });
    });
  }

  void downloadFile() {
    // final encodedStr = Uri.encodeComponent(jsonStr!);
    // html.AnchorElement(href: "data:text/plain;charset=utf-8,$encodedStr")
    //   ..setAttribute("download", "data.json")
    //   ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: jsonStr == null ? null : downloadFile,
            child: const Text('Download JSON'),
          ),
          const SizedBox(height: 20),
          // jsonStr == null
          //     ? const CircularProgressIndicator()
          //     : Text('Loaded: $jsonStr'),
        ],
      ),
    );
  }
}

// main.dart

// import 'dart:js' as js;
// import 'package:flutter/material.dart';
// import 'camera_web_view.dart';
// import 'dart:html' as html;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: FirstPage(),
//     );
//   }
// }

// class FirstPage extends StatefulWidget {
//   @override
//   _FirstPageState createState() => _FirstPageState();
// }

// class _FirstPageState extends State<FirstPage> {
//   // Define a variable to store the image data
//   String? _imageData;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("First Page"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Display the image widget if the image data is not null
//             _imageData != null
//                 ? Image.network(_imageData!)
//                 : Text("No image captured"),
//             SizedBox(height: 20),
//             ElevatedButton(
//               child: Text("Go to Web View"),
//               onPressed: () async {
//                 // Navigate to the second page and wait for the result
//                 var result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CameraPage()),
//                 );

//                 // Set the image data to the result
//                 setState(() {
//                   _imageData = result;
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CameraPage extends StatefulWidget {
//   @override
//   _CameraPageState createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   // Define a variable to store the image data
//   String? _imageData;

//   @override
//   void initState() {
//     super.initState();

//     html.window.onMessage.listen((event) {
//       // Check the type of the message
//       if (event.data["type"] == "receiveImage") {
//         // Set the image data to the received data

//         _imageData = event.data["data"];

//         if (mounted) {
//           // Access the context property safely
//           Navigator.pop(context, _imageData);
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Web View"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Display the web view widget
//             Expanded(child: WebView()),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
// }
