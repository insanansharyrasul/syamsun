import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syamsun/bloc/bloc_exports.dart';
import 'package:syamsun/constants/theme_set.dart';

class PrayerTimesDisplay extends StatelessWidget {
  const PrayerTimesDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
      builder: (context, state) {
        if (state.status == PrayerTimesStatus.loading ||
            state.status == PrayerTimesStatus.initial) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        if (state.status == PrayerTimesStatus.error) {
          return Center(
            child: Text(
              'Error: ${state.errorMessage}',
              style: GoogleFonts.lato(color: Colors.white),
            ),
          );
        }

        final prayerTimes = state.prayerTimes!;
        final nextPrayerTime = state.nextPrayerTime;

        return Column(
          children: [
            const SizedBox(height: 16),
            Column(
              children: [
                Text(
                  state.nextPrayerName,
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
                  state.remainingTime,
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Divider(
                color: Colors.white,
                thickness: 1,
              ),
            ),
            const SizedBox(height: 8),
            _PrayerTimeRow(
              prayerName: 'Fajr',
              prayerTime: prayerTimes.fajr,
              isNext: nextPrayerTime == prayerTimes.fajr ||
                  nextPrayerTime == prayerTimes.fajr.add(const Duration(days: 1)),
            ),
            _PrayerTimeRow(
              prayerName: 'Dhuhr',
              prayerTime: prayerTimes.dhuhr,
              isNext: nextPrayerTime == prayerTimes.dhuhr,
            ),
            _PrayerTimeRow(
              prayerName: 'Asr',
              prayerTime: prayerTimes.asr,
              isNext: nextPrayerTime == prayerTimes.asr,
            ),
            _PrayerTimeRow(
              prayerName: 'Maghrib',
              prayerTime: prayerTimes.maghrib,
              isNext: nextPrayerTime == prayerTimes.maghrib,
            ),
            _PrayerTimeRow(
              prayerName: 'Isha',
              prayerTime: prayerTimes.isha,
              isNext: nextPrayerTime == prayerTimes.isha,
            ),
          ],
        );
      },
    );
  }
}

class _PrayerTimeRow extends StatelessWidget {
  final String prayerName;
  final DateTime prayerTime;
  final bool isNext;

  const _PrayerTimeRow({
    required this.prayerName,
    required this.prayerTime,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isNext ? MainThemeSet.focusColor : MainThemeSet.primaryColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: MainThemeSet.mainFont,
          ),
          Text(
            DateFormat.Hm().format(prayerTime),
            style: MainThemeSet.mainFont,
          ),
        ],
      ),
    );
  }
}
