import SwiftUI
import AppKit

struct SettingsView: View {
    var onQuit: () -> Void
    var onTestStates: (() -> Void)? = nil

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }

            AboutSettingsView(onQuit: onQuit)
                .tabItem { Label("About", systemImage: "info.circle") }

            AdvancedSettingsView(onTestStates: onTestStates)
                .tabItem { Label("Advanced", systemImage: "wrench.and.screwdriver") }
        }
        .frame(width: 480, height: 320)
    }
}

// MARK: - General

struct GeneralSettingsView: View {
    @State private var destinationPath: String = ReceiveDestination.current.path

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSection(title: "Receive Location") {
                HStack {
                    Text(destinationPath)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button("Change…", action: chooseDestination)
                }
                Text("Files received through LinkaBoo are saved here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(20)
    }

    private func chooseDestination() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = ReceiveDestination.current
        panel.prompt = "Choose"
        panel.message = "Choose where to save received files"
        panel.begin { response in
            if response == .OK, let url = panel.url {
                ReceiveDestination.current = url
                destinationPath = url.path
            }
        }
    }
}

// MARK: - About

struct AboutSettingsView: View {
    var onQuit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage ?? NSImage())
                .resizable()
                .frame(width: 72, height: 72)

            Text("LinkaBoo")
                .font(.title2).bold()

            Text("Version \(shortVersion) (\(build))")
                .font(.caption)
                .foregroundColor(.secondary)

            Button("Send Feedback…", action: sendFeedback)
                .buttonStyle(.bordered)

            Spacer()

            HStack {
                Spacer()
                Button("Quit LinkaBoo", action: onQuit)
            }
        }
        .padding(24)
    }

    private var shortVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    private func sendFeedback() {
        if let url = URL(string: "mailto:feedback@linkaboo.app?subject=LinkaBoo%20Feedback") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Advanced

struct AdvancedSettingsView: View {
    var onTestStates: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSection(title: "Logs") {
                HStack {
                    Text("Open the LinkaBoo log file to inspect diagnostics.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Open Logs", action: openLogs)
                }
            }

            #if DEBUG
            if let onTestStates {
                SettingsSection(title: "Debug") {
                    HStack {
                        Text("Drive the popover through each transfer state.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Test States…", action: onTestStates)
                    }
                }
            }
            #endif

            Spacer()
        }
        .padding(20)
    }

    private func openLogs() {
        NSWorkspace.shared.activateFileViewerSelecting([AppLogger.shared.logFileURL])
    }
}

// MARK: - Shared section styling

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.08))
            )
        }
    }
}
