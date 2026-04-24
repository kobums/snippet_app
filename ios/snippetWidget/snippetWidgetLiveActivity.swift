import ActivityKit
import WidgetKit
import SwiftUI

// Must stay in sync with ReadingSessionLAAttributes in AppDelegate.swift
struct ReadingSessionLAAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var timerReferenceEpoch: Double
        var isPaused: Bool
        var pausedElapsedSeconds: Int
    }
    var bookTitle: String
    var coverUrl: String
}

// MARK: - Colors (DesignTokens: primaryMain #1A1A1A)

private extension Color {
    static let snPrimary  = Color(red: 0.102, green: 0.102, blue: 0.102) // #1A1A1A
    static let snSurface  = Color(red: 0.200, green: 0.200, blue: 0.200) // #333333
    static let snWhite    = Color.white
    static let snWhite70  = Color.white.opacity(0.7)
    static let snWhite40  = Color.white.opacity(0.4)
    static let snWhite15  = Color.white.opacity(0.15)
}

// MARK: - Live Activity Widget

struct snippetWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReadingSessionLAAttributes.self) { context in
            ReadingLockScreenView(context: context)
                .activityBackgroundTint(Color.snPrimary)
                .activitySystemActionForegroundColor(.snWhite)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 10) {
                        BookCoverView(size: 36)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.bookTitle)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.snWhite)
                                .lineLimit(2)
                            statusLabel(isPaused: context.state.isPaused)
                        }
                    }
                    .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    timerView(context: context)
                        .font(.system(.headline, design: .monospaced).weight(.semibold))
                        .foregroundColor(.snWhite)
                        .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Divider().background(Color.snWhite15).padding(.horizontal, 6)
                }
            } compactLeading: {
                BookCoverView(size: 20).clipShape(RoundedRectangle(cornerRadius: 3))
            } compactTrailing: {
                timerView(context: context)
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                    .foregroundColor(.snWhite)
            } minimal: {
                BookCoverView(size: 16).clipShape(Circle())
            }
            .widgetURL(URL(string: "snippet://reading-session"))
            .keylineTint(.snWhite40)
        }
    }

    @ViewBuilder
    private func timerView(context: ActivityViewContext<ReadingSessionLAAttributes>) -> some View {
        if context.state.isPaused {
            Text(formatTime(context.state.pausedElapsedSeconds))
        } else {
            Text(Date(timeIntervalSince1970: context.state.timerReferenceEpoch), style: .timer)
        }
    }

    @ViewBuilder
    private func statusLabel(isPaused: Bool) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isPaused ? Color.snWhite40 : Color.snWhite70)
                .frame(width: 5, height: 5)
            Text(isPaused ? "일시정지" : "읽는 중")
                .font(.system(size: 10))
                .foregroundColor(.snWhite40)
        }
    }
}

// MARK: - Lock Screen View

struct ReadingLockScreenView: View {
    let context: ActivityViewContext<ReadingSessionLAAttributes>

    var body: some View {
        HStack(spacing: 14) {
            BookCoverView(size: 56)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.snWhite15, lineWidth: 0.5))
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 5) {
                Text(context.attributes.bookTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.snWhite)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 5) {
                    Circle()
                        .fill(context.state.isPaused ? Color.snWhite40 : Color.snWhite70)
                        .frame(width: 6, height: 6)
                    Text(context.state.isPaused ? "일시정지" : "읽는 중")
                        .font(.system(size: 12))
                        .foregroundColor(.snWhite40)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                timerText
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    .foregroundColor(context.state.isPaused ? Color.snWhite40 : .snWhite)
                    .monospacedDigit()
                Text("독서 시간")
                    .font(.system(size: 10))
                    .foregroundColor(.snWhite15)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private var timerText: some View {
        if context.state.isPaused {
            Text(formatTime(context.state.pausedElapsedSeconds))
        } else {
            Text(Date(timeIntervalSince1970: context.state.timerReferenceEpoch), style: .timer)
        }
    }
}

// MARK: - Book Cover (reads from App Group shared container)

struct BookCoverView: View {
    let size: CGFloat
    private let groupId = "group.com.gowoobro.snippet"

    var body: some View {
        if let img = loadImage() {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size * 1.4)
        } else {
            ZStack {
                Color(red: 0.200, green: 0.200, blue: 0.200)
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.2)
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(width: size, height: size * 1.4)
        }
    }

    private func loadImage() -> UIImage? {
        guard let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupId
        ) else { return nil }
        guard let data = try? Data(contentsOf: container.appendingPathComponent("current_book_cover.jpg"))
        else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Helper

private func formatTime(_ seconds: Int) -> String {
    let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
    return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
}
