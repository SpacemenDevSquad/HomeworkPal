import Foundation

/// How long before an assignment's due date a reminder fires.
enum ReminderLeadTime: Int, CaseIterable, Identifiable, Sendable {
    case fifteenMinutes = 15
    case oneHour = 60
    case threeHours = 180
    case oneDay = 1_440
    case twoDays = 2_880
    case oneWeek = 10_080

    var id: Int { rawValue }

    var minutesBeforeDue: Int { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .fifteenMinutes: "15 Minutes Before"
        case .oneHour: "1 Hour Before"
        case .threeHours: "3 Hours Before"
        case .oneDay: "1 Day Before"
        case .twoDays: "2 Days Before"
        case .oneWeek: "1 Week Before"
        }
    }
}
