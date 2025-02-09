import 'package:adhan/adhan.dart';
import 'package:syamsun/utils/notification_configuration.dart';

class ScheduleConfiguration {
  static void schedulePrayerNotification(PrayerTimes prayerTimes) {
    final prayerTimesMap = {
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    for (var entry in prayerTimesMap.entries) {
      LocalNotifications.scheduledNotification(
        prayerName: entry.key,
        prayerTime: entry.value,
      );
      print('Scheduled ${entry.key} at ${entry.value}');
    }
  }

  static DateTime getNextPrayerTime(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    if (now.isBefore(prayerTimes.fajr)) return prayerTimes.fajr;
    if (now.isBefore(prayerTimes.dhuhr)) return prayerTimes.dhuhr;
    if (now.isBefore(prayerTimes.asr)) return prayerTimes.asr;
    if (now.isBefore(prayerTimes.maghrib)) return prayerTimes.maghrib;
    if (now.isBefore(prayerTimes.isha)) return prayerTimes.isha;
    return prayerTimes.fajr.add(Duration(days: 1));
  }

  static String setNextName(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    if (now.isBefore(prayerTimes.fajr)) return 'Fajr';
    if (now.isBefore(prayerTimes.dhuhr)) return 'Dhuhr';
    if (now.isBefore(prayerTimes.asr)) return 'Asr';
    if (now.isBefore(prayerTimes.maghrib)) return 'Maghrib';
    if (now.isBefore(prayerTimes.isha)) return 'Isha';
    return 'Fajr';
  }
}
