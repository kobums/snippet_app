package com.gowoobro.snippet.snippet_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class SnippetWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val text = widgetData.getString("snippet_text", "앱을 열어 스니펫을 확인하세요.")
                val tag = widgetData.getString("snippet_tag", "Snippet")
                
                setTextViewText(R.id.widget_text, "“$text”")
                setTextViewText(R.id.widget_tag, tag)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
