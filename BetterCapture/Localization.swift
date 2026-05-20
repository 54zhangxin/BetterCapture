//
//  Localization.swift
//  BetterCapture
//
//  Created by OpenAI Codex on 17.04.26.
//

import Foundation
import SwiftUI

enum SupportedAppLanguage: String {
    case english
    case simplifiedChinese

    var locale: Locale {
        switch self {
        case .english:
            Locale(identifier: "en")
        case .simplifiedChinese:
            Locale(identifier: "zh-Hans")
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    static let storageKey = "appLanguage"

    case system
    case english
    case simplifiedChinese

    var id: String { rawValue }

    static var current: AppLanguage {
        guard let rawValue = UserDefaults.standard.string(forKey: storageKey) else {
            return .system
        }
        return AppLanguage(rawValue: rawValue) ?? .system
    }

    var resolved: SupportedAppLanguage {
        switch self {
        case .system:
            let preferredLanguage = Locale.autoupdatingCurrent.language.languageCode?.identifier
            if preferredLanguage == "zh" {
                return .simplifiedChinese
            }
            return .english
        case .english:
            return .english
        case .simplifiedChinese:
            return .simplifiedChinese
        }
    }

    var locale: Locale {
        resolved.locale
    }

    func displayName(language: SupportedAppLanguage) -> String {
        switch self {
        case .system:
            L10n.text("value.followSystem", language: language)
        case .english:
            "English"
        case .simplifiedChinese:
            "简体中文"
        }
    }
}

private struct AppLanguageEnvironmentKey: EnvironmentKey {
    static let defaultValue: SupportedAppLanguage = AppLanguage.current.resolved
}

extension EnvironmentValues {
    var appLanguage: SupportedAppLanguage {
        get { self[AppLanguageEnvironmentKey.self] }
        set { self[AppLanguageEnvironmentKey.self] = newValue }
    }
}

enum L10n {
    static func text(_ key: String, language: SupportedAppLanguage = AppLanguage.current.resolved) -> String {
        table(for: language)[key] ?? englishTable[key] ?? key
    }

    static func text(
        _ key: String,
        language: SupportedAppLanguage = AppLanguage.current.resolved,
        _ arguments: CVarArg...
    ) -> String {
        String(format: text(key, language: language), locale: language.locale, arguments: arguments)
    }

    static func text(_ key: String, _ arguments: CVarArg...) -> String {
        let language = AppLanguage.current.resolved
        return String(format: text(key, language: language), locale: language.locale, arguments: arguments)
    }

    private static func table(for language: SupportedAppLanguage) -> [String: String] {
        switch language {
        case .english:
            englishTable
        case .simplifiedChinese:
            simplifiedChineseTable
        }
    }

    private static let englishTable: [String: String] = [
        "tab.general": "General",
        "tab.video": "Video",
        "tab.audio": "Audio",
        "tab.shortcuts": "Shortcuts",
        "section.recording": "Recording",
        "section.contentSelection": "Content Selection",
        "section.sources": "Sources",
        "section.format": "Format",
        "section.displayElements": "Display Elements",
        "section.windowCapture": "Window Capture",
        "section.outputLocation": "Output Location",
        "section.softwareUpdates": "Software Updates",
        "section.about": "About",
        "section.advanced": "Advanced",
        "section.video": "Video",
        "section.audio": "Audio",
        "section.camera": "Camera",
        "section.contentFilter": "Content Filter",
        "setting.language": "Language",
        "setting.frameRate": "Frame Rate",
        "setting.codec": "Codec",
        "setting.audioCodec": "Audio Codec",
        "setting.container": "Container",
        "setting.quality": "Quality",
        "setting.captureAlphaChannel": "Capture Alpha Channel",
        "setting.hdrRecording": "HDR Recording",
        "setting.nativeResolution": "Native Resolution",
        "setting.captureSystemAudio": "Capture System Audio",
        "setting.captureMicrophone": "Capture Microphone",
        "setting.presenterOverlay": "Presenter Overlay",
        "setting.showCursor": "Show Cursor",
        "setting.showWallpaper": "Show Wallpaper",
        "setting.showMenuBar": "Show Menu Bar",
        "setting.showDock": "Show Dock",
        "setting.showWindowShadows": "Show Window Shadows",
        "setting.showBetterCapture": "Show BetterCapture",
        "setting.microphone": "Microphone",
        "setting.camera": "Camera",
        "setting.automaticallyCheckForUpdates": "Automatically check for updates",
        "setting.updates": "Updates",
        "shortcut.toggleRecording": "Toggle Recording",
        "shortcut.selectContent": "Select Content",
        "shortcut.selectArea": "Select Area",
        "help.shortcutsGlobal": "Shortcuts work globally, even when BetterCapture is not focused.",
        "help.alpha.proRes4444": "ProRes 4444 always includes alpha channel support",
        "help.alpha.hevc": "Enable transparency support for HEVC",
        "help.alpha.unsupported": "Alpha channel not supported by this codec",
        "help.hdr.supported": "Enable 10-bit HDR capture for high dynamic range content",
        "help.hdr.unsupported": "HDR is only supported with ProRes 422 and ProRes 4444 codecs",
        "help.quality.supported": "Controls the video bitrate. Higher quality produces sharper output with larger files",
        "help.quality.unsupported": "ProRes codecs use fixed-quality encoding",
        "help.nativeResolution": "When enabled, captures at the display's native pixel resolution. When disabled, captures at the logical (1x) resolution. Has no effect on non-Retina displays",
        "help.windowShadows": "Include window shadows when capturing individual windows",
        "help.captureSystemAudio": "Record audio from applications and system sounds",
        "help.captureMicrophone": "Record audio from the default microphone input",
        "help.audioCodec": "AAC is compressed, PCM is uncompressed lossless (MOV only)",
        "help.audioTracks": "Audio tracks are recorded separately for post-processing flexibility.",
        "value.native": "Native",
        "value.followSystem": "Follow System",
        "value.quality.low": "Low",
        "value.quality.medium": "Medium",
        "value.quality.high": "High",
        "value.notSupportedForFormat": "Not supported for %@",
        "value.codecNotSupportedForFormat": "%@ (not supported for %@)",
        "value.systemDefault": "System Default",
        "action.change": "Change...",
        "action.reset": "Reset",
        "action.checkForUpdate": "Check for Update",
        "action.startRecording": "Start Recording",
        "action.stopRecording": "Stop Recording",
        "action.resetSelection": "Reset Selection",
        "action.openOutputFolder": "Open Output Folder",
        "action.settings": "Settings...",
        "action.quit": "Quit...",
        "action.openSettings": "Open Settings",
        "action.dismiss": "Dismiss",
        "action.confirm": "Confirm",
        "action.cancel": "Cancel",
        "action.selectContent": "Select Content...",
        "action.changeContent": "Change Content...",
        "action.selectArea": "Select Area...",
        "action.changeArea": "Change Area...",
        "dialog.selectOutputDirectory.title": "Select Output Directory",
        "dialog.selectOutputDirectory.message": "Choose where recordings will be saved",
        "about.version": "Version",
        "about.website": "Website",
        "about.sourceCode": "Source Code",
        "status.permissionsRequired": "Permissions Required",
        "status.screenRecording": "Screen Recording",
        "status.microphone": "Microphone",
        "status.live": "LIVE",
        "notification.showInFinder": "Show in Finder",
        "notification.recordingSaved.title": "Recording Saved",
        "notification.recordingSaved.body": "Your recording has been saved to %@",
        "notification.recordingFailed.title": "Recording Failed",
        "notification.recordingFailed.body": "Your recording could not be saved: %@",
        "notification.recordingStopped.title": "Recording Stopped",
        "notification.recordingStopped.body": "Recording stopped unexpectedly",
        "notification.recordingStopped.bodyWithError": "Recording stopped unexpectedly: %@"
    ]

    private static let simplifiedChineseTable: [String: String] = [
        "tab.general": "通用",
        "tab.video": "视频",
        "tab.audio": "音频",
        "tab.shortcuts": "快捷键",
        "section.recording": "录制",
        "section.contentSelection": "内容选择",
        "section.sources": "音源",
        "section.format": "格式",
        "section.displayElements": "显示元素",
        "section.windowCapture": "窗口捕捉",
        "section.outputLocation": "输出位置",
        "section.softwareUpdates": "软件更新",
        "section.about": "关于",
        "section.advanced": "高级",
        "section.video": "视频",
        "section.audio": "音频",
        "section.camera": "摄像头",
        "section.contentFilter": "内容过滤",
        "setting.language": "语言",
        "setting.frameRate": "帧率",
        "setting.codec": "编码器",
        "setting.audioCodec": "音频编码",
        "setting.container": "封装格式",
        "setting.quality": "画质",
        "setting.captureAlphaChannel": "录制 Alpha 通道",
        "setting.hdrRecording": "HDR 录制",
        "setting.nativeResolution": "原生分辨率",
        "setting.captureSystemAudio": "录制系统音频",
        "setting.captureMicrophone": "录制麦克风",
        "setting.presenterOverlay": "演讲者叠层",
        "setting.showCursor": "显示鼠标指针",
        "setting.showWallpaper": "显示壁纸",
        "setting.showMenuBar": "显示菜单栏",
        "setting.showDock": "显示 Dock",
        "setting.showWindowShadows": "显示窗口阴影",
        "setting.showBetterCapture": "显示 BetterCapture",
        "setting.microphone": "麦克风",
        "setting.camera": "摄像头",
        "setting.automaticallyCheckForUpdates": "自动检查更新",
        "setting.updates": "更新",
        "shortcut.toggleRecording": "切换录制",
        "shortcut.selectContent": "选择内容",
        "shortcut.selectArea": "选择区域",
        "help.shortcutsGlobal": "即使 BetterCapture 不在前台，快捷键也会全局生效。",
        "help.alpha.proRes4444": "ProRes 4444 始终包含 Alpha 通道支持",
        "help.alpha.hevc": "为 HEVC 启用透明通道支持",
        "help.alpha.unsupported": "当前编码器不支持 Alpha 通道",
        "help.hdr.supported": "为高动态范围内容启用 10-bit HDR 录制",
        "help.hdr.unsupported": "只有 ProRes 422 和 ProRes 4444 支持 HDR",
        "help.quality.supported": "控制视频码率。更高画质会带来更清晰的输出和更大的文件体积",
        "help.quality.unsupported": "ProRes 编码使用固定质量",
        "help.nativeResolution": "开启后按显示器原生像素分辨率录制；关闭后按逻辑分辨率（1x）录制。对非 Retina 显示器无影响",
        "help.windowShadows": "捕捉单个窗口时包含窗口阴影",
        "help.captureSystemAudio": "录制应用和系统声音",
        "help.captureMicrophone": "录制默认麦克风输入",
        "help.audioCodec": "AAC 为有损压缩，PCM 为无损未压缩（仅 MOV 支持）",
        "help.audioTracks": "音轨会分别录制，方便后期处理。",
        "value.native": "原生",
        "value.followSystem": "跟随系统",
        "value.quality.low": "低",
        "value.quality.medium": "中",
        "value.quality.high": "高",
        "value.notSupportedForFormat": "该格式不支持：%@",
        "value.codecNotSupportedForFormat": "%@（%@ 不支持）",
        "value.systemDefault": "系统默认",
        "action.change": "更改...",
        "action.reset": "重置",
        "action.checkForUpdate": "检查更新",
        "action.startRecording": "开始录制",
        "action.stopRecording": "停止录制",
        "action.resetSelection": "重置选择",
        "action.openOutputFolder": "打开输出文件夹",
        "action.settings": "设置...",
        "action.quit": "退出...",
        "action.openSettings": "打开设置",
        "action.dismiss": "关闭",
        "action.confirm": "确认",
        "action.cancel": "取消",
        "action.selectContent": "选择内容...",
        "action.changeContent": "更改内容...",
        "action.selectArea": "选择区域...",
        "action.changeArea": "更改区域...",
        "dialog.selectOutputDirectory.title": "选择输出目录",
        "dialog.selectOutputDirectory.message": "选择录制文件保存的位置",
        "about.version": "版本",
        "about.website": "网站",
        "about.sourceCode": "源代码",
        "status.permissionsRequired": "需要授权",
        "status.screenRecording": "屏幕录制",
        "status.microphone": "麦克风",
        "status.live": "直播中",
        "notification.showInFinder": "在访达中显示",
        "notification.recordingSaved.title": "录制已保存",
        "notification.recordingSaved.body": "你的录制已保存到 %@",
        "notification.recordingFailed.title": "录制失败",
        "notification.recordingFailed.body": "录制无法保存：%@",
        "notification.recordingStopped.title": "录制已停止",
        "notification.recordingStopped.body": "录制意外停止",
        "notification.recordingStopped.bodyWithError": "录制意外停止：%@"
    ]
}

extension FrameRate {
    func displayName(language: SupportedAppLanguage) -> String {
        switch self {
        case .native:
            L10n.text("value.native", language: language)
        default:
            "\(rawValue) fps"
        }
    }
}

extension VideoQuality {
    func displayName(language: SupportedAppLanguage) -> String {
        switch self {
        case .low:
            L10n.text("value.quality.low", language: language)
        case .medium:
            L10n.text("value.quality.medium", language: language)
        case .high:
            L10n.text("value.quality.high", language: language)
        }
    }
}
