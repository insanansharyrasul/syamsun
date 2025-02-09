import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syamsun/constants/theme_set.dart';
import 'package:syamsun/utils/homewidget_configuration.dart';
import 'package:syamsun/utils/schedule_configuration.dart';

class PrayerTimesRestart extends StatefulWidget {
  final Future<Position> location;
  final Madhab madhab;
  final CalculationMethod method;
  final Function(String) locationName;
  const PrayerTimesRestart({
    super.key,
    required this.location,
    required this.madhab,
    required this.method,
    required this.locationName,
  });

  @override
  State<PrayerTimesRestart> createState() => _PrayerTimesRestartState();
}

class _PrayerTimesRestartState extends State<PrayerTimesRestart> {
  final String _timezone = DateTime.now().timeZoneName;
  late Future<Position> _locationFuture;
  Timer? _timer;
  Coordinates _myCoordinates = Coordinates(0, 0);

  @override
  void initState() {
    super.initState();
    _locationFuture = widget.location;
    widget.location.then((position) {
      _getAddressFromCoordinates(position.latitude, position.longitude);
      _myCoordinates = Coordinates(position.latitude, position.longitude);
      final paramsCalc = widget.method.getParameters();
      paramsCalc.madhab = widget.madhab;
      final prayerTimes = PrayerTimes.today(_myCoordinates, paramsCalc);
      ScheduleConfiguration.schedulePrayerNotification(prayerTimes);
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      widget.locationName('${place.country}, ${place.locality} ($_timezone)');
    } catch (e) {
      if (mounted) {
        setState(() {
          widget.locationName('Location not found');
        });
      }
    }
  }

  String _formatTimeDifference(DateTime nextPrayerTime) {
    final now = DateTime.now();
    final difference = nextPrayerTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _locationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final Coordinates myCoordinates = Coordinates(
          snapshot.data!.latitude,
          snapshot.data!.longitude,
        );
        final paramsCalc = widget.method.getParameters();
        paramsCalc.madhab = widget.madhab;
        final prayerTimes = PrayerTimes.today(myCoordinates, paramsCalc);
        final nextPrayerTime =
            ScheduleConfiguration.getNextPrayerTime(prayerTimes);
        HomeWidgetConfiguration.updateWidget(prayerTimes);
        return Column(
          children: [
            SizedBox(height: 16),
            Column(
              children: [
                Text(
                  ScheduleConfiguration.setNextName(prayerTimes),
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 24),
                ),
                Text(
                  DateFormat.Hm().format(nextPrayerTime),
                  style: GoogleFonts.lato(color: Colors.amber, fontSize: 32),
                ),
                Text(
                  'Remaining',
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                ),
                Text(
                  _formatTimeDifference(
                      ScheduleConfiguration.getNextPrayerTime(prayerTimes)),
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Divider(
                color: Colors.white,
                thickness: 1,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: nextPrayerTime == prayerTimes.fajr ||
                        nextPrayerTime ==
                            prayerTimes.fajr.add(Duration(days: 1))
                    ? MainThemeSet.focusColor
                    : MainThemeSet.primaryColor,
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fajr',
                    style: MainThemeSet.mainFont,
                  ),
                  Text(
                    DateFormat.Hm().format(prayerTimes.fajr),
                    style: MainThemeSet.mainFont,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: nextPrayerTime == prayerTimes.dhuhr
                    ? MainThemeSet.focusColor
                    : MainThemeSet.primaryColor,
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dhuhr',
                    style: MainThemeSet.mainFont,
                  ),
                  Text(
                    DateFormat.Hm().format(prayerTimes.dhuhr),
                    style: MainThemeSet.mainFont,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: nextPrayerTime == prayerTimes.asr
                    ? MainThemeSet.focusColor
                    : MainThemeSet.primaryColor,
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Asr',
                    style: MainThemeSet.mainFont,
                  ),
                  Text(
                    DateFormat.Hm().format(prayerTimes.asr),
                    style: MainThemeSet.mainFont,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: nextPrayerTime == prayerTimes.maghrib
                    ? MainThemeSet.focusColor
                    : MainThemeSet.primaryColor,
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maghrib',
                    style: MainThemeSet.mainFont,
                  ),
                  Text(
                    DateFormat.Hm().format(prayerTimes.maghrib),
                    style: MainThemeSet.mainFont,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: nextPrayerTime == prayerTimes.isha
                    ? MainThemeSet.focusColor
                    : MainThemeSet.primaryColor,
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Isha',
                    style: MainThemeSet.mainFont,
                  ),
                  Text(
                    DateFormat.Hm().format(prayerTimes.isha),
                    style: MainThemeSet.mainFont,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
