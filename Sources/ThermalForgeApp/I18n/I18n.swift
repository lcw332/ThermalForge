import Foundation

enum L10n {

    // MARK: - Language

    enum Language: String, CaseIterable {
        case english = "en"
        case chinese = "zh"

        var displayName: String {
            switch self {
            case .english: return "English"
            case .chinese: return "中文"
            }
        }
    }

    private static var _language: Language?

    static var language: Language {
        get {
            if let lang = _language { return lang }
            if let stored = UserDefaults.standard.string(forKey: "appLanguage"),
               let lang = Language(rawValue: stored) {
                _language = lang
                return lang
            }
            let preferred = Locale.current.language.languageCode?.identifier ?? "en"
            if preferred.hasPrefix("zh") {
                _language = .chinese
                return .chinese
            }
            _language = .english
            return .english
        }
        set {
            _language = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
        }
    }

    // MARK: - Keys

    private enum Key: String {
        case appName
        case fans
        case fanIndex
        case rpm
        case temperatures
        case cpu
        case gpu
        case ram
        case ssd
        case ambient
        case readingSensors
        case profile
        case instant
        case smart
        case `default`
        case fahrenheitToggle
        case launchAtLogin
        case quitApp
        case safety
        case idle
        case settings
        case monitor
        case curve
        case more
        case appleAuto
        case languageLabel
    }

    // MARK: - Translation Dictionaries

    private static let english: [Key: String] = [
        .appName: "ThermalForge",
        .fans: "FANS",
        .fanIndex: "Fan %d",
        .rpm: "%d RPM",
        .temperatures: "TEMPERATURES",
        .cpu: "CPU",
        .gpu: "GPU",
        .ram: "RAM",
        .ssd: "SSD",
        .ambient: "Ambient",
        .readingSensors: "Reading sensors...",
        .profile: "PROFILE",
        .instant: "instant",
        .smart: "Smart",
        .default: "Default",
        .fahrenheitToggle: "°F / °C",
        .launchAtLogin: "Launch at Login",
        .quitApp: "Quit ThermalForge",
        .safety: "SAFETY",
        .idle: "Idle",
        .settings: "Settings",
        .monitor: "Monitor",
        .curve: "Curve",
        .more: "More",
        .appleAuto: "Apple Auto (not controlled)",
        .languageLabel: "Language",
    ]

    private static let chinese: [Key: String] = [
        .appName: "ThermalForge",
        .fans: "风扇",
        .fanIndex: "风扇 %d",
        .rpm: "%d RPM",
        .temperatures: "温度",
        .cpu: "CPU",
        .gpu: "GPU",
        .ram: "内存",
        .ssd: "固态硬盘",
        .ambient: "环境",
        .readingSensors: "读取传感器中...",
        .profile: "配置文件",
        .instant: "即时",
        .smart: "智能",
        .default: "默认",
        .fahrenheitToggle: "°F / °C",
        .launchAtLogin: "登录时启动",
        .quitApp: "退出 ThermalForge",
        .safety: "安全模式",
        .idle: "空闲",
        .settings: "设置",
        .monitor: "监控",
        .curve: "曲线",
        .more: "更多",
        .appleAuto: "系统自动控制（未接管）",
        .languageLabel: "语言",
    ]

    private static var currentDict: [Key: String] {
        switch language {
        case .english: return english
        case .chinese: return chinese
        }
    }

    private static func t(_ key: Key) -> String {
        currentDict[key] ?? english[key] ?? key.rawValue
    }

    // MARK: - Public String Properties

    static var appName: String { t(.appName) }
    static var fans: String { t(.fans) }
    static func fanIndex(_ index: Int) -> String { String(format: t(.fanIndex), index) }
    static func rpm(_ rpm: Int) -> String { String(format: t(.rpm), rpm) }
    static var temperatures: String { t(.temperatures) }
    static var cpu: String { t(.cpu) }
    static var gpu: String { t(.gpu) }
    static var ram: String { t(.ram) }
    static var ssd: String { t(.ssd) }
    static var ambient: String { t(.ambient) }
    static var readingSensors: String { t(.readingSensors) }
    static var profile: String { t(.profile) }
    static var instant: String { t(.instant) }
    static var smart: String { t(.smart) }
    static var defaultValue: String { t(.default) }
    static var fahrenheitToggle: String { t(.fahrenheitToggle) }
    static var launchAtLogin: String { t(.launchAtLogin) }
    static var quitApp: String { t(.quitApp) }
    static var safety: String { t(.safety) }
    static var idle: String { t(.idle) }
    static var settings: String { t(.settings) }
    static var monitor: String { t(.monitor) }
    static var curve: String { t(.curve) }
    static var more: String { t(.more) }
    static var appleAuto: String { t(.appleAuto) }
    static var languageLabel: String { t(.languageLabel) }
}
