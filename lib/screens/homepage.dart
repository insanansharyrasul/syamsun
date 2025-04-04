// ignore_for_file: use_build_context_synchronously

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:syamsun/constants/theme_set.dart';
import 'package:syamsun/utils/location_configuration.dart';
import 'package:syamsun/screens/prayertimes_data.dart';
import 'package:syamsun/utils/homewidget_configuration.dart';
import 'package:syamsun/utils/notification_configuration.dart';
import 'package:syamsun/utils/saving_configuration.dart';

class Homepage extends StatefulWidget {
  final String prayerMethod;
  final String madhab;

  const Homepage({
    super.key,
    required this.prayerMethod,
    required this.madhab,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<Position> _locationFuture;
  late CalculationMethod _selectedMethod;
  late Madhab _selectedMadhab;
  String _locationName = '';
  DateTime _duration = DateTime(2024, 1, 1, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    _selectedMethod = CalculationMethod.values.firstWhere(
      (method) => method.toString() == widget.prayerMethod,
      orElse: () => CalculationMethod.north_america,
    );
    _selectedMadhab = Madhab.values.firstWhere(
      (madhab) => madhab.toString() == widget.madhab,
      orElse: () => Madhab.shafi,
    );
    _locationFuture = LocationConfiguration.getCurrentLocation();
    HomeWidget.groupId = HomeWidgetConfiguration.appGroupId;
  }

  // Refresh the FutureBuilder
  void _refresh() {
    setState(() {
      _locationFuture = LocationConfiguration.getCurrentLocation();
    });
  }

  void changeLocationName(String locationName) {
    setState(() {
      _locationName = locationName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prayer Times',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            Text(
              _locationName,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) => SimpleDialog(
                    title: Text(
                      'Settings',
                      style: DialogThemeSet.titleFont,
                    ),
                    children: [
                      Column(
                        children: [
                          Text(
                            'Calculation Method',
                            style: DialogThemeSet.mainFont,
                          ),
                          DropdownButton(
                            value: _selectedMethod,
                            dropdownColor: MainThemeSet.primaryColor,
                            alignment: Alignment.center,
                            items: CalculationMethod.values.map((method) {
                              return DropdownMenuItem(
                                value: method,
                                child: Text(
                                  method.toString().split('.').last,
                                  style: DialogThemeSet.dropDownFont,
                                ),
                              );
                            }).toList(),
                            onChanged: (CalculationMethod? newValue) {
                              setState(() {
                                _selectedMethod = newValue!;
                                _refresh();
                                SavingPreferences.saveConfigurationMethod(newValue.toString());
                              });
                            },
                          ),
                          Text(
                            'Madhab',
                            style: DialogThemeSet.mainFont,
                          ),
                          DropdownButton(
                            value: _selectedMadhab,
                            dropdownColor: MainThemeSet.primaryColor,
                            items: Madhab.values.map((madhab) {
                              return DropdownMenuItem(
                                value: madhab,
                                child: Text(
                                  madhab.toString().split('.').last,
                                  style: DialogThemeSet.dropDownFont,
                                ),
                              );
                            }).toList(),
                            onChanged: (Madhab? newValue) {
                              setState(() {
                                _selectedMadhab = newValue!;
                                _refresh();
                                SavingPreferences.saveConfigurationMadhab(newValue.toString());
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) => SimpleDialog(
                    title: Text(
                      'Set Sleep Notifier',
                      style: DialogThemeSet.titleFont,
                      textAlign: TextAlign.center,
                    ),
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TimePickerSpinner(
                            time: DateTime(2024, 1, 1, 7, 0, 0),
                            is24HourMode: true,
                            normalTextStyle: DialogThemeSet.dropDownFont,
                            highlightedTextStyle: DialogThemeSet.dropDownFont.copyWith(
                              color: MainThemeSet.focusColor,
                            ),
                            alignment: Alignment.center,
                            itemHeight: 40,
                            onTimeChange: (time) {
                              _duration = time;
                            },
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                // Get current location and calculate prayer times
                                final position = await LocationConfiguration.getCurrentLocation();
                                final coordinates =
                                    Coordinates(position.latitude, position.longitude);
                                final params = _selectedMethod.getParameters();
                                params.madhab = _selectedMadhab;

                                // Get next Fajr time
                                final now = DateTime.now();
                                final prayerTimes = PrayerTimes.today(coordinates, params);
                                final nextFajr = prayerTimes.fajr.isAfter(now)
                                    ? prayerTimes.fajr
                                    : PrayerTimes(
                                            coordinates, DateComponents.from(now.add(const Duration(days: 1))), params)
                                        .fajr;

                                final selectedDuration = Duration(
                                  hours: _duration.hour,
                                  minutes: _duration.minute,
                                );
                                final alarmTime = nextFajr.subtract(selectedDuration);
                                debugPrint('Alarm time: $alarmTime');
                                await LocalNotifications.scheduledSleeepNotification(
                                  id: 'Sleep',
                                  setTime: alarmTime,
                                );

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Alarm set for ${alarmTime.hour}:${alarmTime.minute}',
                                      style: DialogThemeSet.dropDownFont,
                                    ),
                                    backgroundColor: MainThemeSet.focusColor,
                                  ),
                                );
                              } catch (e) {
                                debugPrint('Error setting alarm: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error setting alarm',
                                      style: DialogThemeSet.dropDownFont,
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MainThemeSet.focusColor,
                            ),
                            child: Text(
                              'Set Notifier',
                              style: DialogThemeSet.dropDownFont,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.alarm,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: PrayerTimesRestart(
        location: _locationFuture,
        method: _selectedMethod,
        madhab: _selectedMadhab,
        locationName: changeLocationName,
      ),
    );
  }
}
