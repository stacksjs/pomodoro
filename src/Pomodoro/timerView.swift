//
//  timerView.swift
//  Timer
//
//

import SwiftUI
import AppKit

struct timerView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 15) {
            // Timer display
            Text(viewModel.timeString(from: viewModel.remainingTime))
                .font(.system(size: 60, weight: .medium, design: .monospaced))
                .foregroundColor(.primary)

            // Progress indicator
            ZStack {
                Circle()
                    .stroke(Color(NSColor.systemGray), lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: calculateProgress())
                    .stroke(timerColor(), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                // Control button
                Button(action: viewModel.toggleTimer) {
                    Image(systemName: buttonIcon())
                        .font(.system(size: 32))
                        .foregroundColor(timerColor())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .frame(width: 200, height: 200)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func calculateProgress() -> CGFloat {
        CGFloat(viewModel.remainingTime) / CGFloat(viewModel.timerDuration * 60)
    }

    private func timerColor() -> Color {
        if viewModel.timerDuration > 15 {
            return Color.red.opacity(0.8) // Pomodoro
        } else if viewModel.timerDuration > 8 {
            return Color.blue.opacity(0.8) // Long break
        } else {
            return Color.green.opacity(0.8) // Short break
        }
    }

    private func buttonIcon() -> String {
        switch viewModel.timerState {
        case .running:
            return "pause.fill"
        case .paused, .stopped:
            return "play.fill"
        }
    }
}

#if DEBUG
struct timerView_Previews: PreviewProvider {
    static var previews: some View {
        timerView(viewModel: TimerViewModel(duration: 25))
    }
}
#endif
