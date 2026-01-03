import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syamsun/bloc/bloc_exports.dart';
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
    final coordinates = Coordinates(position.latitude, position.longitude);
    final String? savedMethod = await SavingPreferences.getConfigurationMadhab();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PermissionBloc()..add(CheckPermissions())),
        BlocProvider(create: (_) => SettingsBloc()..add(LoadSettings())),
        BlocProvider(create: (_) => PrayerTimesBloc()),
      ],
      child: MaterialApp(
        title: "SalahTime",
        theme: ThemeData(
          scaffoldBackgroundColor: MainThemeSet.primaryColor,
          dialogTheme: DialogThemeData(backgroundColor: MainThemeSet.primaryColor),
          appBarTheme: AppBarTheme(
            backgroundColor: MainThemeSet.primaryColor,
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, permissionState) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            // Show loading while checking permissions or loading settings
            if (permissionState.status == AppPermissionStatus.loading ||
                permissionState.status == AppPermissionStatus.initial ||
                settingsState.status == SettingsStatus.loading ||
                settingsState.status == SettingsStatus.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Show permission denied screen
            if (permissionState.status == AppPermissionStatus.denied) {
              return Scaffold(
                body: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Location & exact alarm permission is required",
                        style: GoogleFonts.lato(color: Colors.white, fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: openAppSettings,
                        style: ElevatedButton.styleFrom(
                            iconColor: MainThemeSet.focusColor,
                            backgroundColor: MainThemeSet.focusColor),
                        child: Text('Open Settings', style: GoogleFonts.lato(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show error screen if settings failed to load
            if (settingsState.status == SettingsStatus.error) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Error: ${settingsState.errorMessage}',
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                ),
              );
            }

            // Permissions granted and settings loaded - show homepage
            return const Homepage();
          },
        );
      },
    );
  }
}
