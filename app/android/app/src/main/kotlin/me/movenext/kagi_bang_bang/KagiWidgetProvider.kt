package me.movenext.kagi_bang_bang

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class KagiWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.kagi_widget).apply {
                val searchIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("widget://search"))
                setOnClickPendingIntent(R.id.search_button, searchIntent)

                val assistantIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("widget://assistant"))
                setOnClickPendingIntent(R.id.assistant_button, assistantIntent)

                val summarizerIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("widget://summarizer"))
                setOnClickPendingIntent(R.id.summarizer_button, summarizerIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}