package com.example.syamsun

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
/**
 * Implementation of App Widget functionality.
 */
class PrayerWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                val fajr = widgetData.getString("fajr", null)
                setTextViewText(R.id.fajr_time, fajr ?: "-")
                val dhuhr = widgetData.getString("dhuhr", null)
                setTextViewText(R.id.dhuhr_time, dhuhr ?: "-")
                val asr = widgetData.getString("asr", null)
                setTextViewText(R.id.asr_time, asr ?: "-")
                val maghrib = widgetData.getString("maghrib", null)
                setTextViewText(R.id.maghrib_time, maghrib ?: "-")
                val isha = widgetData.getString("isha", null)
                setTextViewText(R.id.isha_time, isha ?: "-")
                // End new code
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}