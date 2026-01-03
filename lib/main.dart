import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syamsun/constants/theme_set.dart';
import 'package:syamsun/utils/homewidget_configuration.dart';
import 'package:syamsun/utils/location_configuration.dart';
import 'package:syamsun/utils/notification_configuration.dart';
import 'package:syamsun/screens/homepage.dart';
import 'package:syamsun/utils/saving_configuration.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();
  await SavingPreferences.init();
  Workmanager().initialize(callbackDispatcher);
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Background task triggered at: ${DateTime.now()}");
    final prayerTimes = await fetchPrayerTimes();
    HomeWidgetConfiguration.updateWidget(prayerTimes);
    debugPrint("Home widget updated.");
    return Future.value(true);
  });
}

Future<PrayerTimes> fetchPrayerTimes() async {
  try {
    final Position position = await LocationConfiguration.getCurrentLocation();
    final coordinates = Coordinates(
        position.latitude, position.longitude); 
    final String? savedMethod =
        await SavingPreferences.getConfigurationMadhab();
    final CalculationMethod calculationMethod = savedMethod != null
        ? CalculationMethod.values.firstWhere(
            (method) => method.toString() == savedMethod,
            orElse: () => CalculationMethod.muslim_world_league,
          )
        : CalculationMethod.muslim_world_league;
    final params = calculationMethod.getParameters();
    final prayerTimes = PrayerTimes.today(coordinates, params);
    return prayerTimes;
  } catch (e) {
    debugPrint('Error fetching prayer times: $e');
    rethrow;
  }
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
    Workmanager().registerPeriodicTask(
      "1",
      "updatePrayerTimes",
      frequency: const Duration(hours: 12),
    );
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
              return const Center(child: CircularProgressIndicator());
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
        dialogTheme: DialogThemeData(backgroundColor: MainThemeSet.primaryColor),
        appBarTheme: AppBarTheme(
          backgroundColor: MainThemeSet.primaryColor,
        ),
      ),
    );
  }
}
