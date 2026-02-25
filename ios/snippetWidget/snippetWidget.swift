import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let appGroupId = "group.com.gowoobro.snippet"

    func placeholder(in context: Context) -> SnippetEntry {
        SnippetEntry(date: Date(), text: "앱을 열어 첫 스니펫을 확인해보세요.", tag: "Snippet")
    }

    func getSnapshot(in context: Context, completion: @escaping (SnippetEntry) -> ()) {
        let entry = SnippetEntry(date: Date(), text: "앱을 열어 첫 스니펫을 확인해보세요.", tag: "Snippet")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let text = userDefaults?.string(forKey: "snippet_text") ?? "앱을 열어 스니펫을 동기화해주세요!"
        let tag = userDefaults?.string(forKey: "snippet_tag") ?? "Snippet"

        let entry = SnippetEntry(date: Date(), text: text, tag: tag)

        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct SnippetEntry: TimelineEntry {
    let date: Date
    let text: String
    let tag: String
}

struct snippetWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        if #available(iOS 16.0, *), family == .accessoryRectangular {
            // Lock Screen Accessory View (Monochrome, Auto-masked)
            VStack(alignment: .leading) {
                Text("“\(entry.text)”")
                    .font(.system(size: 14, weight: .regular))
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else {
            // Home Screen View
            VStack(alignment: .leading, spacing: 10) {
                Text("“\(entry.text)”")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.8)
            }
            .padding(2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct snippetWidget: Widget {
    let kind: String = "snippetWidget"
    
    private var families: [WidgetFamily] {
        if #available(iOS 16.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular]
        } else {
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                snippetWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color.clear.background(.ultraThinMaterial)
                    }
            } else {
                snippetWidgetEntryView(entry: entry)
                    .background(Color.clear.background(.ultraThinMaterial))
            }
        }
        .configurationDisplayName("Snippet 스니펫")
        .description("현재 스와이프 화면 상단의 문장을 띄워줍니다.")
        .supportedFamilies(families)
    }
}
