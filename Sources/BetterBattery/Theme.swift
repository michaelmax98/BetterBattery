import SwiftUI
import AppKit

/// State-driven accent colors shared by the panel, the menu bar glyph,
/// and the low-battery glow. Green on power, blue on battery, orange and
/// red once the user-configurable low-battery thresholds are crossed.
enum PowerAccent {
    static let green = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let blue = Color(red: 0.04, green: 0.52, blue: 1.00)
    static let orange = Color(red: 1.00, green: 0.62, blue: 0.04)
    static let red = Color(red: 1.00, green: 0.27, blue: 0.23)

    // Text-weight variants. The bright accents above are tuned for fills,
    // charts, the glyph and the glow; as *text* on the light panel they fall
    // to ~2:1 contrast. These keep the bright color in dark mode and deepen
    // in light mode to ≥ 4.5:1 (WCAG AA), even on the tinted tiles.
    static let greenText = adaptive(light: (0.086, 0.439, 0.184), dark: green)    // #16702F
    static let blueText = adaptive(light: (0.039, 0.373, 0.761), dark: blue)      // #0A5FC2
    static let orangeText = adaptive(light: (0.604, 0.306, 0.031), dark: orange)  // #9A4E08
    static let redText = adaptive(light: (0.729, 0.110, 0.071), dark: red)        // #BA1C12
    /// Neutral chip text (the Settings header): in light mode a dark gray, so
    /// it reads as clickable rather than disabled without outweighing the
    /// colored chips. Dark mode keeps the original `.gray`.
    static let neutralText = adaptive(light: (0.314, 0.314, 0.333), dark: .gray)  // #505055

    private static func adaptive(light: (Double, Double, Double), dark: Color) -> Color {
        let darkNS = NSColor(dark)
        let lightNS = NSColor(srgbRed: light.0, green: light.1, blue: light.2, alpha: 1)
        return Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? darkNS : lightNS
        })
    }

    /// Text version of `accent(for:)` — for the hero readout and captions.
    static func textAccent(for snapshot: BatterySnapshot, warn: Int, critical: Int) -> Color {
        switch snapshot.state {
        case .noBattery:
            return .secondary
        case .charging, .charged, .pluggedIdle:
            return greenText
        case .discharging:
            if snapshot.percent <= critical { return redText }
            if snapshot.percent <= warn { return orangeText }
            return blueText
        }
    }

    /// Panel accent — every state gets a color, including blue on battery.
    static func accent(for snapshot: BatterySnapshot, warn: Int, critical: Int) -> Color {
        switch snapshot.state {
        case .noBattery:
            return .secondary
        case .charging, .charged, .pluggedIdle:
            return green
        case .discharging:
            if snapshot.percent <= critical { return red }
            if snapshot.percent <= warn { return orange }
            return blue
        }
    }

    /// Menu bar fill — neutral (white/black) at normal levels on battery so
    /// the icon blends with the system ones, colored for everything else.
    static func iconFill(for snapshot: BatterySnapshot, warn: Int, critical: Int, neutral: Color) -> Color {
        switch snapshot.state {
        case .noBattery:
            return neutral.opacity(0.5)
        case .charging, .charged, .pluggedIdle:
            return green
        case .discharging:
            if snapshot.percent <= critical { return red }
            if snapshot.percent <= warn { return orange }
            return neutral
        }
    }
}
