//
//  SettingsView.swift
//  ThermalForge
//
//  Settings window: liquid glass tab bar (Monitor / Curve / More),
//  styled per DESIGN.md.
//

import SwiftUI
import ThermalForgeCore

// MARK: - Root

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .monitor

    enum Tab: CaseIterable {
        case monitor, curve, more

        var title: String {
            switch self {
            case .monitor: return L10n.monitor
            case .curve: return L10n.curve
            case .more: return L10n.more
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            GlassTabBar(selected: $selectedTab)

            Group {
                switch selectedTab {
                case .monitor: MonitorTab()
                case .curve: CurveTab()
                case .more: MoreTab()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(TFTheme.Colors.canvas)
        }
        .frame(width: 520, height: 420)
    }
}

// MARK: - Glass Tab Bar

private struct GlassTabBar: View {
    @Binding var selected: SettingsView.Tab

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            HStack(spacing: TFTheme.Spacing.xs) {
                ForEach(SettingsView.Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selected = tab
                        }
                    } label: {
                        Text(tab.title)
                            .font(TFTheme.mono(13, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(selected == tab ? TFTheme.Colors.ink : .clear)
                            .foregroundStyle(selected == tab ? TFTheme.Colors.canvas : TFTheme.Colors.mute)
                            .clipShape(RoundedRectangle(cornerRadius: TFTheme.radius))
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .background(WindowDragArea())
        .background(.regularMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(TFTheme.Colors.hairline)
                .frame(height: 1)
        }
    }
}

/// Lets the tab bar double as the window drag region (title bar is hidden).
private struct WindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        DragView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    final class DragView: NSView {
        override var mouseDownCanMoveWindow: Bool { true }

        override func mouseDown(with event: NSEvent) {
            window?.performDrag(with: event)
        }

        override func mouseDragged(with event: NSEvent) {
            window?.performDrag(with: event)
        }
    }
}

// MARK: - Monitor Tab

private struct MonitorTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(L10n.appName)
                        .font(TFTheme.mono(16, weight: .bold))
                        .foregroundStyle(TFTheme.Colors.ink)
                    Spacer()
                    stateIndicator
                }
                .padding(.bottom, TFTheme.Spacing.md)

                if let status = appState.latestStatus {
                    SectionHeader(title: L10n.fans)
                    ForEach(status.fans, id: \.index) { fan in
                        HStack {
                            Text(L10n.fanIndex(fan.index))
                                .foregroundStyle(TFTheme.Colors.body)
                            Spacer()
                            Text(L10n.rpm(fan.actualRPM))
                                .font(TFTheme.mono(13))
                                .foregroundStyle(TFTheme.Colors.ink)
                        }
                        .font(TFTheme.mono(13))
                        .padding(.vertical, 1)
                    }

                    hairline

                    SectionHeader(title: L10n.temperatures)
                    TemperatureRow(label: L10n.cpu, value: peakTemp(status: status, prefixes: ["TC", "Tp"]), fahrenheit: appState.useFahrenheit)
                    TemperatureRow(label: L10n.gpu, value: peakTemp(status: status, prefixes: ["TG", "Tg"]), fahrenheit: appState.useFahrenheit)
                    TemperatureRow(label: L10n.ram, value: peakTemp(status: status, prefixes: ["TR", "Tm", "TM"]), fahrenheit: appState.useFahrenheit)
                    TemperatureRow(label: L10n.ssd, value: peakTemp(status: status, prefixes: ["TH"]), fahrenheit: appState.useFahrenheit)
                    TemperatureRow(label: L10n.ambient, value: peakTemp(status: status, prefixes: ["TA"]), fahrenheit: appState.useFahrenheit)
                } else {
                    Text(L10n.readingSensors)
                        .font(TFTheme.mono(13))
                        .foregroundStyle(TFTheme.Colors.mute)
                }

                Spacer(minLength: 0)
            }
            .padding(TFTheme.Spacing.lg)
        }
    }

    private var hairline: some View {
        Rectangle()
            .fill(TFTheme.Colors.hairline)
            .frame(height: 1)
            .padding(.vertical, TFTheme.Spacing.sm)
    }

    @ViewBuilder
    private var stateIndicator: some View {
        switch appState.monitorState {
        case .safetyOverride:
            Label(L10n.safety, systemImage: "exclamationmark.triangle.fill")
                .font(TFTheme.mono(11, weight: .medium))
                .foregroundStyle(.red)
        case .active(let name):
            Label(name, systemImage: "fan.fill")
                .font(TFTheme.mono(11, weight: .medium))
                .foregroundStyle(.orange)
        case .idle:
            Label(L10n.idle, systemImage: "fan")
                .font(TFTheme.mono(11, weight: .medium))
                .foregroundStyle(TFTheme.Colors.mute)
        }
    }
}

// MARK: - Curve Tab

private struct CurveTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(appState.activeProfile.name)
                    .font(TFTheme.mono(13, weight: .medium))
                    .foregroundStyle(TFTheme.Colors.ink)
                Spacer()
                let curve = appState.activeProfile.curve
                if !curve.handsOff {
                    Text(curveSummary(curve))
                        .font(TFTheme.mono(11))
                        .foregroundStyle(TFTheme.Colors.mute)
                }
            }
            .padding(.horizontal, TFTheme.Spacing.lg)
            .padding(.vertical, TFTheme.Spacing.sm)

            if appState.activeProfile.curve.handsOff {
                Spacer()
                Text(L10n.appleAuto)
                    .font(TFTheme.mono(13))
                    .foregroundStyle(TFTheme.Colors.mute)
                Spacer()
            } else {
                CurveChartView(
                    curve: appState.activeProfile.curve,
                    currentTemp: appState.maxTemp,
                    fahrenheit: appState.useFahrenheit
                )
                .padding(.horizontal, TFTheme.Spacing.lg)
                .padding(.bottom, TFTheme.Spacing.md)
            }
        }
    }

    private func curveSummary(_ curve: FanProfile.Curve) -> String {
        let unit = fahrenheitUnit
        if curve.instantEngage {
            return "\(Int(displayTemp(curve.startTemp)))°\(unit) \(L10n.instant)"
        }
        return "\(Int(displayTemp(curve.startTemp)))→\(Int(displayTemp(curve.ceilingTemp)))°\(unit)"
    }

    private var fahrenheitUnit: String {
        appState.useFahrenheit ? "F" : "C"
    }

    private func displayTemp(_ celsius: Float) -> Float {
        appState.useFahrenheit ? celsius * 9 / 5 + 32 : celsius
    }
}

// MARK: - Curve Chart

private struct CurveChartView: View {
    let curve: FanProfile.Curve
    let currentTemp: Float?
    var fahrenheit: Bool = false

    private let minT: Float = 30
    private let maxT: Float = 100

    var body: some View {
        Canvas { ctx, size in
            let left: CGFloat = 36
            let right: CGFloat = 8
            let top: CGFloat = 12
            let bottom: CGFloat = 22
            let plotW = size.width - left - right
            let plotH = size.height - top - bottom

            func x(_ t: Float) -> CGFloat {
                left + CGFloat((t - minT) / (maxT - minT)) * plotW
            }
            func y(_ p: Float) -> CGFloat {
                top + (1 - CGFloat(p)) * plotH
            }

            // Axes
            var axes = Path()
            axes.move(to: CGPoint(x: left, y: top))
            axes.addLine(to: CGPoint(x: left, y: top + plotH))
            axes.addLine(to: CGPoint(x: left + plotW, y: top + plotH))
            ctx.stroke(axes, with: .color(TFTheme.Colors.hairlineStrong), lineWidth: 1)

            // Y gridlines + labels
            for p: Float in [0, 0.5, 1] {
                var grid = Path()
                grid.move(to: CGPoint(x: left, y: y(p)))
                grid.addLine(to: CGPoint(x: left + plotW, y: y(p)))
                ctx.stroke(grid, with: .color(TFTheme.Colors.hairline), lineWidth: 1)

                let label = Text("\(Int(p * 100))%")
                    .font(TFTheme.mono(10))
                    .foregroundStyle(TFTheme.Colors.mute)
                ctx.draw(label, at: CGPoint(x: left - 16, y: y(p)), anchor: .center)
            }

            // X labels
            for t: Float in [40, 60, 80, 100] {
                let disp = fahrenheit ? t * 9 / 5 + 32 : t
                let label = Text("\(Int(disp))°")
                    .font(TFTheme.mono(10))
                    .foregroundStyle(TFTheme.Colors.mute)
                ctx.draw(label, at: CGPoint(x: x(t), y: top + plotH + 11), anchor: .center)
            }

            // Curve
            var path = Path()
            var started = false
            var t = minT
            while t <= maxT {
                let p = curve.targetPercent(at: t, fansCurrentlyRunning: true) ?? 0
                let pt = CGPoint(x: x(t), y: y(p))
                if started {
                    path.addLine(to: pt)
                } else {
                    path.move(to: pt)
                    started = true
                }
                t += 0.25
            }
            ctx.stroke(path, with: .color(TFTheme.Colors.ink), lineWidth: 1.5)

            // Current temp marker
            if let tempC = currentTemp {
                let clamped = min(max(tempC, minT), maxT)
                var marker = Path()
                marker.move(to: CGPoint(x: x(clamped), y: top))
                marker.addLine(to: CGPoint(x: x(clamped), y: top + plotH))
                ctx.stroke(
                    marker,
                    with: .color(TFTheme.Colors.accent),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )

                let disp = fahrenheit ? tempC * 9 / 5 + 32 : tempC
                let label = Text("\(Int(disp))°")
                    .font(TFTheme.mono(10, weight: .medium))
                    .foregroundStyle(TFTheme.Colors.accent)
                ctx.draw(label, at: CGPoint(x: x(clamped), y: top - 6), anchor: .center)
            }
        }
    }
}

// MARK: - More Tab

private struct MoreTab: View {
    @EnvironmentObject var appState: AppState
    @State private var language: L10n.Language = L10n.language

    var body: some View {
        VStack(alignment: .leading, spacing: TFTheme.Spacing.lg) {
            Toggle(L10n.fahrenheitToggle, isOn: $appState.useFahrenheit)
            Toggle(L10n.launchAtLogin, isOn: $appState.launchAtLogin)

            HStack {
                Text(L10n.languageLabel)
                Spacer()
                Picker("", selection: $language) {
                    ForEach(L10n.Language.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 180)
                .onChange(of: language) { _, newValue in
                    L10n.language = newValue
                }
            }

            Rectangle()
                .fill(TFTheme.Colors.hairline)
                .frame(height: 1)

            Button(action: { NSApp.terminate(nil) }) {
                Text(L10n.quitApp)
            }
            .buttonStyle(.plain)
            .foregroundStyle(TFTheme.Colors.mute)

            Spacer()
        }
        .font(TFTheme.mono(13))
        .foregroundStyle(TFTheme.Colors.ink)
        .padding(TFTheme.Spacing.lg)
    }
}

// MARK: - Shared Helpers

func peakTemp(status: ThermalStatus, prefixes: [String]) -> Float? {
    status.temperatures
        .filter { key, _ in prefixes.contains(where: { key.hasPrefix($0) }) }
        .values
        .max()
}
