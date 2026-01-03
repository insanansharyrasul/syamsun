import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:syamsun/bloc/bloc_exports.dart';
import 'package:syamsun/constants/theme_set.dart';
import 'package:syamsun/screens/prayertimes_data.dart';
import 'package:syamsun/utils/homewidget_configuration.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  DateTime _duration = DateTime(2024, 1, 1, 0, 0, 0);
  DateTime? _lastLoadedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HomeWidget.groupId = HomeWidgetConfiguration.appGroupId;

    // Load prayer times when homepage is shown
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (_lastLoadedDate == null ||
          _lastLoadedDate!.day != now.day ||
          _lastLoadedDate!.month != now.month ||
          _lastLoadedDate!.year != now.year) {
        debugPrint('App resumed - day changed, refreshing prayer times');
        _loadPrayerTimes(forceLocationRefresh: true);
      } else {
        debugPrint('App resumed - same day, no refresh needed');
      }
    }
  }

  String _formatAlarmTime(DateTime alarmTime) {
    final hour = alarmTime.hour.toString().padLeft(2, '0');
    final minute = alarmTime.minute.toString().padLeft(2, '0');
    final day = alarmTime.day;
    final month = alarmTime.month;
    return '$hour:$minute ($day/$month)';
  }

  void _loadPrayerTimes({bool forceLocationRefresh = false}) {
    final settingsState = context.read<SettingsBloc>().state;
    final prayerTimesState = context.read<PrayerTimesBloc>().state;

    // If we already have prayer times loaded, use refresh (uses cache)
    if (prayerTimesState.status == PrayerTimesStatus.loaded) {
      context.read<PrayerTimesBloc>().add(RefreshPrayerTimes(
            method: settingsState.calculationMethod,
            madhab: settingsState.madhab,
            forceLocationRefresh: forceLocationRefresh,
          ));
    } else {
      context.read<PrayerTimesBloc>().add(LoadPrayerTimes(
            method: settingsState.calculationMethod,
            madhab: settingsState.madhab,
          ));
    }

    _lastLoadedDate = DateTime.now();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<SettingsBloc, SettingsState>(
        bloc: context.read<SettingsBloc>(),
        builder: (_, settingsState) {
          return SimpleDialog(
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
                  DropdownButton<CalculationMethod>(
                    value: settingsState.calculationMethod,
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
                      if (newValue != null) {
                        context.read<SettingsBloc>().add(UpdateCalculationMethod(newValue));
                        context.read<PrayerTimesBloc>().add(RefreshPrayerTimes(
                              method: newValue,
                              madhab: settingsState.madhab,
                            ));
                      }
                    },
                  ),
                  Text(
                    'Madhab',
                    style: DialogThemeSet.mainFont,
                  ),
                  DropdownButton<Madhab>(
                    value: settingsState.madhab,
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
                      if (newValue != null) {
                        context.read<SettingsBloc>().add(UpdateMadhab(newValue));
                        context.read<PrayerTimesBloc>().add(RefreshPrayerTimes(
                              method: settingsState.calculationMethod,
                              madhab: newValue,
                            ));
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSleepNotifierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<SettingsBloc, SettingsState>(
        bloc: context.read<SettingsBloc>(),
        builder: (_, settingsState) {
          return SimpleDialog(
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
                        final sleepDuration = Duration(
                          hours: _duration.hour,
                          minutes: _duration.minute,
                        );

                        context.read<PrayerTimesBloc>().add(ScheduleSleepNotification(
                              sleepDuration: sleepDuration,
                              method: settingsState.calculationMethod,
                              madhab: settingsState.madhab,
                            ));

                        Navigator.pop(dialogContext);

                        await Future.delayed(const Duration(milliseconds: 100));
                        if (context.mounted) {
                          final alarmTime =
                              context.read<PrayerTimesBloc>().state.scheduledAlarmTime;
                          final message = alarmTime != null
                              ? 'Sleep notifier set for: ${_formatAlarmTime(alarmTime)}'
                              : 'Sleep notifier set: ${_duration.hour.toString().padLeft(2, '0')}:${_duration.minute.toString().padLeft(2, '0')} before Fajr';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                message,
                                style: DialogThemeSet.dropDownFont,
                              ),
                              backgroundColor: MainThemeSet.focusColor,
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error setting alarm: $e');
                        if (context.mounted) {
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
      builder: (context, prayerTimesState) {
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
                  prayerTimesState.locationName,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12),
                ),
                if (prayerTimesState.scheduledAlarmTime != null)
                  Text(
                    'Sleep alarm: ${_formatAlarmTime(prayerTimesState.scheduledAlarmTime!)}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => _showSettingsDialog(context),
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => _showSleepNotifierDialog(context),
                icon: const Icon(
                  Icons.alarm,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: const PrayerTimesDisplay(),
        );
      },
    );
  }
}
