import 'package:adhan/adhan.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

class HomeWidgetConfiguration {
  static final String homeWidgetName = 'PrayerWidget';
  static final String appGroupId = 'group.com.example.syamsun';
  static void updateWidget(PrayerTimes prayerTimes) {
    final prayerTimesMap = {
      "fajr": prayerTimes.fajr,
      "dhuhr": prayerTimes.dhuhr,
      "asr": prayerTimes.asr,
      "maghrib": prayerTimes.maghrib,
      "isha": prayerTimes.isha,
    };

    prayerTimesMap.forEach((key, value) {
      HomeWidget.saveWidgetData(key, DateFormat.Hm().format(value));
    });

    HomeWidget.updateWidget(androidName: homeWidgetName);
  }
}
