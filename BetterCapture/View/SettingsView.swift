//
//  SettingsView.swift
//  BetterCapture
//
//  Created by Joshua Sattler on 29.01.26.
//

import AppKit
import KeyboardShortcuts
import SwiftUI

/// The settings window for BetterCapture
struct SettingsView: View {
    @Bindable var settings: SettingsStore
    var updaterService: UpdaterService
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        TabView {
            Tab(L10n.text("tab.general", language: appLanguage), systemImage: "gearshape") {
                GeneralSettingsView(settings: settings, updaterService: updaterService)
            }

            Tab(L10n.text("tab.video", language: appLanguage), systemImage: "video") {
                VideoSettingsView(settings: settings)
            }

            Tab(L10n.text("tab.audio", language: appLanguage), systemImage: "waveform") {
                AudioSettingsView(settings: settings)
            }

            Tab(L10n.text("tab.shortcuts", language: appLanguage), systemImage: "keyboard") {
                ShortcutsSettingsView()
            }
        }
        .frame(width: 500, height: 420)
    }
}

// MARK: - Shortcuts Settings

struct ShortcutsSettingsView: View {
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        Form {
            Section(L10n.text("section.recording", language: appLanguage)) {
                KeyboardShortcuts.Recorder(L10n.text("shortcut.toggleRecording", language: appLanguage), name: .toggleRecording)
            }

            Section(L10n.text("section.contentSelection", language: appLanguage)) {
                KeyboardShortcuts.Recorder(L10n.text("shortcut.selectContent", language: appLanguage), name: .selectContent)
                KeyboardShortcuts.Recorder(L10n.text("shortcut.selectArea", language: appLanguage), name: .selectArea)
            }

            Section {
                Text(L10n.text("help.shortcutsGlobal", language: appLanguage))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Video Settings

struct VideoSettingsView: View {
    @Bindable var settings: SettingsStore
    @Environment(\.appLanguage) private var appLanguage

    private var alphaChannelHelpText: String {
        switch settings.videoCodec {
        case .proRes4444:
            return L10n.text("help.alpha.proRes4444", language: appLanguage)
        case .hevc:
            return L10n.text("help.alpha.hevc", language: appLanguage)
        case .h264, .proRes422:
            return L10n.text("help.alpha.unsupported", language: appLanguage)
        }
    }

    private var hdrHelpText: String {
        if settings.videoCodec.supportsHDR {
            return L10n.text("help.hdr.supported", language: appLanguage)
        } else {
            return L10n.text("help.hdr.unsupported", language: appLanguage)
        }
    }

    private var qualityHelpText: String {
        if settings.videoCodec.supportsQualitySetting {
            return L10n.text("help.quality.supported", language: appLanguage)
        } else {
            return L10n.text("help.quality.unsupported", language: appLanguage)
        }
    }

    private var captureNativeResHelpText: String {
        L10n.text("help.nativeResolution", language: appLanguage)
    }

    var body: some View {
        Form {
            Section(L10n.text("section.recording", language: appLanguage)) {
                Picker(L10n.text("setting.frameRate", language: appLanguage), selection: $settings.frameRate) {
                    ForEach(FrameRate.allCases) { rate in
                        Text(rate.displayName(language: appLanguage)).tag(rate)
                    }
                }

                Picker(L10n.text("setting.codec", language: appLanguage), selection: $settings.videoCodec) {
                    ForEach(VideoCodec.allCases) { codec in
                        let isSupported = settings.containerFormat.supportedVideoCodecs.contains(codec)
                        if isSupported {
                            Text(codec.rawValue).tag(codec)
                        } else {
                            Text(L10n.text(
                                "value.codecNotSupportedForFormat",
                                language: appLanguage,
                                codec.rawValue,
                                settings.containerFormat.rawValue.uppercased()
                            ))
                                .foregroundStyle(.secondary)
                                .tag(codec)
                        }
                    }
                }

                Picker(L10n.text("setting.container", language: appLanguage), selection: $settings.containerFormat) {
                    ForEach(ContainerFormat.allCases) { format in
                        Text(".\(format.rawValue)").tag(format)
                    }
                }

                Picker(L10n.text("setting.quality", language: appLanguage), selection: $settings.videoQuality) {
                    ForEach(VideoQuality.allCases) { quality in
                        Text(quality.displayName(language: appLanguage)).tag(quality)
                    }
                }
                .disabled(!settings.videoCodec.supportsQualitySetting)
                .help(qualityHelpText)
            }

            Section(L10n.text("section.advanced", language: appLanguage)) {
                Toggle(L10n.text("setting.captureAlphaChannel", language: appLanguage), isOn: $settings.captureAlphaChannel)
                    .disabled(!settings.videoCodec.canToggleAlpha || !settings.containerFormat.supportsAlphaChannel)
                    .help(alphaChannelHelpText)

                Toggle(L10n.text("setting.hdrRecording", language: appLanguage), isOn: $settings.captureHDR)
                    .disabled(!settings.videoCodec.supportsHDR)
                    .help(hdrHelpText)

                Toggle(L10n.text("setting.nativeResolution", language: appLanguage), isOn: $settings.captureNativeResolution)
                    .help(captureNativeResHelpText)
            }

            Section(L10n.text("section.displayElements", language: appLanguage)) {
                Toggle(L10n.text("setting.showCursor", language: appLanguage), isOn: $settings.showCursor)
                Toggle(L10n.text("setting.showWallpaper", language: appLanguage), isOn: $settings.showWallpaper)
                Toggle(L10n.text("setting.showMenuBar", language: appLanguage), isOn: $settings.showMenuBar)
                Toggle(L10n.text("setting.showDock", language: appLanguage), isOn: $settings.showDock)
                Toggle(L10n.text("setting.showBetterCapture", language: appLanguage), isOn: $settings.showBetterCapture)
            }

            Section(L10n.text("section.windowCapture", language: appLanguage)) {
                Toggle(L10n.text("setting.showWindowShadows", language: appLanguage), isOn: $settings.showWindowShadows)
                    .help(L10n.text("help.windowShadows", language: appLanguage))
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Audio Settings

struct AudioSettingsView: View {
    @Bindable var settings: SettingsStore
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        Form {
            Section(L10n.text("section.sources", language: appLanguage)) {
                Toggle(L10n.text("setting.captureSystemAudio", language: appLanguage), isOn: $settings.captureSystemAudio)
                    .help(L10n.text("help.captureSystemAudio", language: appLanguage))

                Toggle(L10n.text("setting.captureMicrophone", language: appLanguage), isOn: $settings.captureMicrophone)
                    .help(L10n.text("help.captureMicrophone", language: appLanguage))
            }

            Section(L10n.text("section.format", language: appLanguage)) {
                Picker(L10n.text("setting.codec", language: appLanguage), selection: $settings.audioCodec) {
                    ForEach(AudioCodec.allCases) { codec in
                        let isSupported = settings.containerFormat.supportedAudioCodecs.contains(codec)
                        if isSupported {
                            Text(codec.rawValue).tag(codec)
                        } else {
                            Text(L10n.text(
                                "value.codecNotSupportedForFormat",
                                language: appLanguage,
                                codec.rawValue,
                                settings.containerFormat.rawValue.uppercased()
                            ))
                                .foregroundStyle(.secondary)
                                .tag(codec)
                        }
                    }
                }
                .help(L10n.text("help.audioCodec", language: appLanguage))
            }

            Section {
                Text(L10n.text("help.audioTracks", language: appLanguage))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @Bindable var settings: SettingsStore
    var updaterService: UpdaterService
    @Environment(\.appLanguage) private var appLanguage

    @State private var automaticallyChecksForUpdates: Bool

    init(settings: SettingsStore, updaterService: UpdaterService) {
        self.settings = settings
        self.updaterService = updaterService
        self._automaticallyChecksForUpdates = State(initialValue: updaterService.automaticallyChecksForUpdates)
    }

    /// Formats the output directory path for display
    private var displayPath: String {
        let path = settings.outputDirectory.path(percentEncoded: false)
        // Replace home directory with ~ for cleaner display
        let home = FileManager.default.homeDirectoryForCurrentUser.path(percentEncoded: false)
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    var body: some View {
        Form {
            Section(L10n.text("section.outputLocation", language: appLanguage)) {
                Picker(L10n.text("setting.language", language: appLanguage), selection: $settings.appLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName(language: appLanguage)).tag(language)
                    }
                }

                LabeledContent {
                    HStack {
                        Button(L10n.text("action.change", language: appLanguage)) {
                            selectOutputDirectory()
                        }

                        if settings.hasCustomOutputDirectory {
                            Button(L10n.text("action.reset", language: appLanguage), role: .destructive) {
                                settings.resetOutputDirectory()
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "folder")
                        Text(displayPath)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            }

            Section(L10n.text("section.softwareUpdates", language: appLanguage)) {
                Toggle(L10n.text("setting.automaticallyCheckForUpdates", language: appLanguage), isOn: $automaticallyChecksForUpdates)
                    .onChange(of: automaticallyChecksForUpdates) { _, newValue in
                        updaterService.automaticallyChecksForUpdates = newValue
                    }

                LabeledContent(L10n.text("setting.updates", language: appLanguage)) {
                    Button(L10n.text("action.checkForUpdate", language: appLanguage)) {
                        updaterService.checkForUpdates()
                    }
                    .disabled(!updaterService.canCheckForUpdates)
                }
            }

            AboutSection()
        }
        .formStyle(.grouped)
        .padding()
    }

    /// Opens an NSOpenPanel to select a custom output directory
    private func selectOutputDirectory() {
        let panel = NSOpenPanel()
        panel.title = L10n.text("dialog.selectOutputDirectory.title", language: appLanguage)
        panel.message = L10n.text("dialog.selectOutputDirectory.message", language: appLanguage)
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = settings.outputDirectory

        if panel.runModal() == .OK, let url = panel.url {
            settings.setCustomOutputDirectory(url)
        }
    }
}

// MARK: - About Section

struct AboutSection: View {
    @Environment(\.appLanguage) private var appLanguage

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var gitSHA: String {
        Bundle.main.infoDictionary?["GitSHA"] as? String ?? "dev"
    }

    var body: some View {
        Section(L10n.text("section.about", language: appLanguage)) {
            LabeledContent(L10n.text("about.version", language: appLanguage), value: "v\(appVersion) (\(gitSHA))")

            LabeledContent(L10n.text("about.website", language: appLanguage)) {
                Link("jsattler.github.io/BetterCapture", destination: URL(string: "https://jsattler.github.io/BetterCapture")!)
            }

            LabeledContent(L10n.text("about.sourceCode", language: appLanguage)) {
                Link("github.com/jsattler/BetterCapture", destination: URL(string: "https://github.com/jsattler/BetterCapture")!)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(settings: SettingsStore(), updaterService: UpdaterService())
}
