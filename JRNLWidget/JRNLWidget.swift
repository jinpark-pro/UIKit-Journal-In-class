//
//  JRNLWidget.swift
//  JRNLWidget
//
//  Created by Jungjin Park on 2024-05-30.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    let modelContext = ModelContext(try! ModelContainer(for: JournalEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false)))
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), journalEntryDate: "JRNL", journalEntryTitle: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), journalEntryDate: "JRNL", journalEntryTitle: "")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let descriptor = FetchDescriptor<JournalEntry>()
        let currentDate = Date()
        
        if let journalEntries = try? modelContext.fetch(descriptor) {
            for minuteOffset in 0..<journalEntries.count {
                let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 5, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, journalEntryDate: journalEntries[minuteOffset].dateString, journalEntryTitle: journalEntries[minuteOffset].entryTitle)
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let journalEntryDate: String
    let journalEntryTitle: String
}

struct JRNLWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.journalEntryDate)
            Text(entry.journalEntryTitle)
        }
    }
}

struct JRNLWidget: Widget {
    let kind: String = "JRNLWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                JRNLWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                JRNLWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    JRNLWidget()
} timeline: {
    SimpleEntry(date: .now, journalEntryDate: "JRNL", journalEntryTitle: "")
    SimpleEntry(date: .now, journalEntryDate: "JRNL", journalEntryTitle: "")
}
