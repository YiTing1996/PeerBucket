//
//  PeerBucketWidget.swift
//  PeerBucketWidget
//
//  Created by 陳憶婷 on 2022/7/5.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "", uiImage: UIImage(named: "background"))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: "", uiImage: UIImage(named: "background"))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let defaultUrl = """
        https://firebasestorage.googleapis.
        com:443/v0/b/peerbucket-54af1.appspot.com/o
        /avatar%2F713324E5-7C35-4AAD-9553-E036244B1B9A.png?alt=media&token=3eed7c52-21b7-458b-9bea-a6bdc2cc7b66
        """
        
        let userDefaults = UserDefaults(suiteName: "group.com.doreen.PeerBucket")
        let text = userDefaults?.value(forKey: "text") as? String ?? ""
        let image = userDefaults?.value(forKey: "image") as? String ?? defaultUrl
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        
        URLSession.shared.dataTask(with: URL(string: image)!) { (data, _, _) in
            let currentDate = Date()
            if let data = data,
               let uiImage = UIImage(data: data) {
                let entry = SimpleEntry(
                    date: currentDate,
                    text: text,
                    uiImage: uiImage)
                entries.append(entry)
            }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }.resume()
        
        //        let currentDate = Date()
        //        for hourOffset in 0 ..< 5 {
        //            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
        //            let entry = SimpleEntry(date: entryDate, text: text, uiImage: )
        //            entries.append(entry)
        //        }
        //
        //        let timeline = Timeline(entries: entries, policy: .atEnd)
        //        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let text: String
    let uiImage: UIImage?
}

struct PeerBucketWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { geo in
                entry.uiImage.map {
                    Image(uiImage: $0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width,
                               height: geo.size.height,
                               alignment: .center)
                }
            }
            
            Text(entry.text)
                .font(Font.system(size: 20,
                                  weight: .semibold,
                                  design: .default))
                .foregroundColor(.black)
                .font(.headline)
                .frame(maxHeight: 10, alignment: .bottom)
                .background(Color.yellow)
//                .padding()
        }
    }
}

@main
struct PeerBucketWidget: Widget {
    let kind: String = "PeerBucketWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PeerBucketWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct PeerBucketWidget_Previews: PreviewProvider {
    static var previews: some View {
        PeerBucketWidgetEntryView(entry: SimpleEntry(date: Date(), text: "", uiImage: UIImage(named: "background")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
