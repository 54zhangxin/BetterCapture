//
//  MenuBarSettingsView.swift
//  BetterCapture
//
//  Created by Joshua Sattler on 02.02.26.
//

import SwiftUI

// MARK: - Section Divider

/// A styled divider for menu bar sections
struct SectionDivider: View {
    var body: some View {
        Divider()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
    }
}

// MARK: - Section Header

/// A styled section header for menu bar (bold, not uppercase)
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }
}

// MARK: - Menu Bar Divider (smaller)

/// A styled divider for menu bar
struct MenuBarDivider: View {
    var body: some View {
        Divider()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
    }
}

// MARK: - Toggle Row

/// A menu bar style toggle with a switch on the right side and hover effect
struct MenuBarToggle: View {
    let name: String
    @Binding var isOn: Bool
    var isDisabled: Bool = false
    @State private var isHovered = false

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isDisabled ? .secondary : .primary)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(.blue)
                .scaleEffect(0.8)
                .disabled(isDisabled)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .contentShape(.rect)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovered && !isDisabled ? .gray.opacity(0.1) : .clear)
                .padding(.horizontal, 4)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Expandable Picker Row

/// Represents a single option in a `MenuBarExpandablePicker`
struct PickerOption<Value: Hashable & Equatable> {
    let value: Value
    let label: String
    var isDisabled: Bool = false
    var disabledMessage: String?
}

/// A menu bar style picker that expands inline to show options with hover effect
struct MenuBarExpandablePicker<SelectionValue: Hashable & Equatable>: View {
    let name: String
    @Binding var selection: SelectionValue
    let options: [PickerOption<SelectionValue>]
    @State private var isExpanded = false
    @State private var isHovered = false

    /// Convenience initializer for simple options without disabled state
    init(
        name: String,
        selection: Binding<SelectionValue>,
        options: [(value: SelectionValue, label: String)]
    ) {
        self.name = name
        self._selection = selection
        self.options = options.map { PickerOption(value: $0.value, label: $0.label) }
    }

    /// Full initializer with disabled state support
    init(
        name: String,
        selection: Binding<SelectionValue>,
        optionsWithState: [PickerOption<SelectionValue>]
    ) {
        self.name = name
        self._selection = selection
        self.options = optionsWithState
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(currentLabel)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? .gray.opacity(0.1) : .clear)
                    .padding(.horizontal, 4)
            )
            .onHover { hovering in
                isHovered = hovering
            }

            // Expanded options
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options, id: \.value) { option in
                        PickerOptionRow(
                            label: option.label,
                            isSelected: selection == option.value,
                            isDisabled: option.isDisabled,
                            disabledMessage: option.disabledMessage
                        ) {
                            selection = option.value
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                            }
                        }
                    }
                }
                .padding(.leading, 12)
                .background(.quaternary.opacity(0.3))
            }
        }
    }

    private var currentLabel: String {
        options.first { $0.value == selection }?.label ?? ""
    }
}

// MARK: - Picker Option Row

/// A single option row in an expandable picker with hover effect
struct PickerOptionRow: View {
    let label: String
    let isSelected: Bool
    var isDisabled: Bool = false
    var disabledMessage: String?
    let onSelect: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(size: 13))
                        .foregroundStyle(isDisabled ? .tertiary : .primary)
                    if isDisabled, let message = disabledMessage {
                        Text(message)
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovered && !isDisabled ? .gray.opacity(0.1) : .clear)
                .padding(.horizontal, 4)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Device Row (for microphone selection)

/// A device selection row with icon in circle, native macOS style
struct DeviceRow: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Icon in circle
                ZStack {
                    Circle()
                        .fill(isSelected ? .blue.opacity(0.8) : .gray.opacity(0.3))
                        .frame(width: 24, height: 24)

                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isSelected ? .white : .primary)
                }

                // Name
                Text(name)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)

                Spacer()

                // Checkmark when selected
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovered ? .gray.opacity(0.1) : .clear)
                .padding(.horizontal, 4)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Microphone Expandable Picker

/// A microphone picker with device-style rows (icon in circle)
struct MicrophoneExpandablePicker: View {
    @Binding var selectedID: String?
    let devices: [AudioInputDevice]
    @Environment(\.appLanguage) private var appLanguage
    @State private var isExpanded = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(L10n.text("setting.microphone", language: appLanguage))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(currentLabel)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? .gray.opacity(0.1) : .clear)
                    .padding(.horizontal, 4)
            )
            .onHover { hovering in
                isHovered = hovering
            }

            // Expanded device options
            if isExpanded {
                VStack(spacing: 0) {
                    // System Default option
                    DeviceRow(
                        name: L10n.text("value.systemDefault", language: appLanguage),
                        icon: "mic",
                        isSelected: selectedID == nil
                    ) {
                        selectedID = nil
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded = false
                        }
                    }

                    // Available devices
                    ForEach(devices) { device in
                        DeviceRow(
                            name: device.name,
                            icon: device.isDefault ? "mic.fill" : "mic",
                            isSelected: selectedID == device.id
                        ) {
                            selectedID = device.id
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                            }
                        }
                    }
                }
                .padding(.leading, 12)
                .background(.quaternary.opacity(0.3))
            }
        }
    }

    private var currentLabel: String {
        if let id = selectedID, let device = devices.first(where: { $0.id == id }) {
            return device.name
        }
        return L10n.text("value.systemDefault", language: appLanguage)
    }
}

// MARK: - Expandable Section (for arbitrary content)

/// A menu bar style expandable section with hover effect
struct MenuBarExpandableSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @State private var isExpanded = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? .gray.opacity(0.1) : .clear)
                    .padding(.horizontal, 4)
            )
            .onHover { hovering in
                isHovered = hovering
            }

            // Expanded content
            if isExpanded {
                VStack(spacing: 0) {
                    content
                }
                .padding(.leading, 12)
                .background(.quaternary.opacity(0.3))
            }
        }
    }
}

// MARK: - Video Settings Section

/// Video settings section with header and inline content
struct VideoSettingsSection: View {
    @Bindable var settings: SettingsStore
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: L10n.text("section.video", language: appLanguage))

            // Content Filter Section
            MenuBarExpandableSection(title: L10n.text("section.contentFilter", language: appLanguage)) {
                MenuBarToggle(name: L10n.text("setting.showCursor", language: appLanguage), isOn: $settings.showCursor)
                MenuBarToggle(name: L10n.text("setting.showWallpaper", language: appLanguage), isOn: $settings.showWallpaper)
                MenuBarToggle(name: L10n.text("setting.showMenuBar", language: appLanguage), isOn: $settings.showMenuBar)
                MenuBarToggle(name: L10n.text("setting.showDock", language: appLanguage), isOn: $settings.showDock)
                MenuBarToggle(name: L10n.text("setting.showWindowShadows", language: appLanguage), isOn: $settings.showWindowShadows)
                MenuBarToggle(name: L10n.text("setting.showBetterCapture", language: appLanguage), isOn: $settings.showBetterCapture)
            }

            // Frame Rate Picker
            MenuBarExpandablePicker(
                name: L10n.text("setting.frameRate", language: appLanguage),
                selection: $settings.frameRate,
                options: FrameRate.allCases.map { ($0, $0.displayName(language: appLanguage)) }
            )

            // Video Codec Picker (shows all codecs, disables incompatible ones)
            MenuBarExpandablePicker(
                name: L10n.text("setting.codec", language: appLanguage),
                selection: $settings.videoCodec,
                optionsWithState: VideoCodec.allCases.map { codec in
                    let isSupported = settings.containerFormat.supportedVideoCodecs.contains(codec)
                    return PickerOption(
                        value: codec,
                        label: codec.rawValue,
                        isDisabled: !isSupported,
                        disabledMessage: isSupported ? nil : L10n.text(
                            "value.notSupportedForFormat",
                            language: appLanguage,
                            settings.containerFormat.rawValue.uppercased()
                        )
                    )
                }
            )

            // Container Format Picker
            MenuBarExpandablePicker(
                name: L10n.text("setting.container", language: appLanguage),
                selection: $settings.containerFormat,
                options: ContainerFormat.allCases.map { ($0, $0.rawValue.uppercased()) }
            )

            // Alpha Channel Toggle (disabled if codec doesn't support or container doesn't support)
            MenuBarToggle(
                name: L10n.text("setting.captureAlphaChannel", language: appLanguage),
                isOn: $settings.captureAlphaChannel,
                isDisabled: !settings.videoCodec.canToggleAlpha || !settings.containerFormat.supportsAlphaChannel
            )

            // HDR Recording Toggle (disabled for codecs that don't support HDR)
            MenuBarToggle(
                name: L10n.text("setting.hdrRecording", language: appLanguage),
                isOn: $settings.captureHDR,
                isDisabled: !settings.videoCodec.supportsHDR
            )
        }
    }
}

// MARK: - Audio Settings Section

/// Audio settings section with header and inline content
struct AudioSettingsSection: View {
    @Bindable var settings: SettingsStore
    let audioDeviceService: AudioDeviceService
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        VStack(spacing: 0) {
            // Separator before Audio section
            SectionDivider()

            SectionHeader(title: L10n.text("section.audio", language: appLanguage))

            // System Audio Toggle
            MenuBarToggle(name: L10n.text("setting.captureSystemAudio", language: appLanguage), isOn: $settings.captureSystemAudio)

            // Microphone Toggle
            MenuBarToggle(name: L10n.text("setting.captureMicrophone", language: appLanguage), isOn: $settings.captureMicrophone)

            // Microphone Source Picker (only shown when microphone is enabled)
            if settings.captureMicrophone {
                MicrophoneExpandablePicker(
                    selectedID: $settings.selectedMicrophoneID,
                    devices: audioDeviceService.availableDevices
                )
            }

            // Audio Codec Picker (shows all codecs, disables incompatible ones)
            MenuBarExpandablePicker(
                name: L10n.text("setting.audioCodec", language: appLanguage),
                selection: $settings.audioCodec,
                optionsWithState: AudioCodec.allCases.map { codec in
                    let isSupported = settings.containerFormat.supportedAudioCodecs.contains(codec)
                    return PickerOption(
                        value: codec,
                        label: codec.rawValue,
                        isDisabled: !isSupported,
                        disabledMessage: isSupported ? nil : L10n.text(
                            "value.notSupportedForFormat",
                            language: appLanguage,
                            settings.containerFormat.rawValue.uppercased()
                        )
                    )
                }
            )
        }
    }
}

// MARK: - Camera Expandable Picker

/// A camera picker with device-style rows, matching the microphone picker pattern
struct CameraExpandablePicker: View {
    @Binding var selectedID: String?
    let devices: [CameraDevice]
    @Environment(\.appLanguage) private var appLanguage
    @State private var isExpanded = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(L10n.text("setting.camera", language: appLanguage))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(currentLabel)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? .gray.opacity(0.1) : .clear)
                    .padding(.horizontal, 4)
            )
            .onHover { hovering in
                isHovered = hovering
            }

            // Expanded device options
            if isExpanded {
                VStack(spacing: 0) {
                    // System Default option
                    DeviceRow(
                        name: L10n.text("value.systemDefault", language: appLanguage),
                        icon: "camera",
                        isSelected: selectedID == nil
                    ) {
                        selectedID = nil
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded = false
                        }
                    }

                    // Available devices
                    ForEach(devices) { device in
                        DeviceRow(
                            name: device.name,
                            icon: "camera",
                            isSelected: selectedID == device.id
                        ) {
                            selectedID = device.id
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                            }
                        }
                    }
                }
                .padding(.leading, 12)
                .background(.quaternary.opacity(0.3))
            }
        }
    }

    private var currentLabel: String {
        if let id = selectedID, let device = devices.first(where: { $0.id == id }) {
            return device.name
        }
        return L10n.text("value.systemDefault", language: appLanguage)
    }
}

// MARK: - Presenter Overlay Settings Section

/// Presenter Overlay toggle and camera picker
struct PresenterOverlaySettingsSection: View {
    @Bindable var settings: SettingsStore
    let cameraDeviceService: CameraDeviceService
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        VStack(spacing: 0) {
            SectionDivider()

            SectionHeader(title: L10n.text("section.camera", language: appLanguage))

            MenuBarToggle(name: L10n.text("setting.presenterOverlay", language: appLanguage), isOn: $settings.presenterOverlayEnabled)

            if settings.presenterOverlayEnabled {
                CameraExpandablePicker(
                    selectedID: $settings.selectedCameraID,
                    devices: cameraDeviceService.availableDevices
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        VideoSettingsSection(settings: SettingsStore())
        PresenterOverlaySettingsSection(settings: SettingsStore(), cameraDeviceService: CameraDeviceService())
        AudioSettingsSection(settings: SettingsStore(), audioDeviceService: AudioDeviceService())
    }
    .frame(width: 320)
    .padding(.vertical, 8)
}
