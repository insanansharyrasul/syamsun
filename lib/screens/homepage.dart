import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
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
          IconButton(icon: Icon(Icons.food_bank), onPressed: LocalNotifications.showNotification),
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
                                SavingPreferences.saveConfigurationMethod(
                                    newValue.toString());
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
                                SavingPreferences.saveConfigurationMadhab(
                                    newValue.toString());
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
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          )
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
