import SwiftUI
import AppKit

struct settingsView: View {
    @Binding var standardTimer: Int
    @Binding var shortBreak: Int
    @Binding var longBreak: Int

    var body: some View {
        VStack(spacing: 25) {
            // Title
            Text("Settings")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 5)

            // Launch at login option
            VStack(alignment: .leading, spacing: 8) {
                Text("General")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                HStack {
                    Text("Launch at login")
                        .font(.system(size: 14))
                    Spacer()
                    Toggle("", isOn: .constant(false))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }

            // Timer settings
            VStack(alignment: .leading, spacing: 8) {
                Text("Timer Duration (minutes)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                HStack(spacing: 15) {
                    timerSetting(value: $standardTimer, title: "Pomodoro", color: .red)
                    timerSetting(value: $shortBreak, title: "Short Break", color: .green)
                    timerSetting(value: $longBreak, title: "Long Break", color: .blue)
                }
            }

            Spacer()
        }
        .padding()
        .frame(width: 400, height: 300)
    }

    private func timerSetting(value: Binding<Int>, title: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)

            TextField("", value: value, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .frame(width: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct settingsView_Previews: PreviewProvider {
    static var previews: some View {
        settingsView(standardTimer: .constant(25), shortBreak: .constant(5), longBreak: .constant(15))
    }
}
