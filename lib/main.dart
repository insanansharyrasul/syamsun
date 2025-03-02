import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syamsun/constants/theme_set.dart';
import 'package:syamsun/utils/notification_configuration.dart';
import 'package:syamsun/screens/homepage.dart';
import 'package:syamsun/utils/saving_configuration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();
  await SavingPreferences.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.locationWhenInUse.status;
    final alarmStatus = await Permission.scheduleExactAlarm.status;

    if (locationStatus.isGranted && alarmStatus.isGranted) {
      setState(() {
        _permissionsGranted = true;
      });
    } else {
      final locationResult = await Permission.locationWhenInUse.request();
      final alarmResult = await Permission.scheduleExactAlarm.request();

      if (locationResult.isGranted && alarmResult.isGranted) {
        setState(() {
          _permissionsGranted = true;
        });
      } else {
        setState(() {
          _permissionsGranted = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SalahTime",
      home: Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
          future: Future.wait([
            SavingPreferences.getConfigurationMethod(),
            SavingPreferences.getConfigurationMadhab()
          ]).then((value) => {
                'prayerMethod': value[0],
                'madhab': value[1],
              }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return _permissionsGranted
                ? Homepage(
                    prayerMethod: snapshot.data!['prayerMethod'] ??
                        'CalculationMethod.north_america',
                    madhab: snapshot.data!['madhab'] ?? 'Madhab.shafi',
                  )
                : Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Location & exact alarm permission is required",
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: openAppSettings,
                          style: ElevatedButton.styleFrom(
                              iconColor: MainThemeSet.focusColor,
                              backgroundColor: MainThemeSet.focusColor),
                          child: Text('Open Settings',
                              style: GoogleFonts.lato(color: Colors.white)),
                        )
                      ],
                    ),
                  );
          },
        ),
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: MainThemeSet.primaryColor,
        dialogBackgroundColor: MainThemeSet.primaryColor,
        dialogTheme: DialogTheme(backgroundColor: MainThemeSet.primaryColor),
        appBarTheme: AppBarTheme(
          backgroundColor: MainThemeSet.primaryColor,
        ),
      ),
    );
  }
}
