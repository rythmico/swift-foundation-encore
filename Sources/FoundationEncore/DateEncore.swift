extension Date {
    public static func => (lhs: Date, rhs: (set: Set<Calendar.Component>, to: Int, for: TimeZone)) -> Date {
        let (units, amount, timeZone) = rhs
        return lhs.setting(
            rhs.set.reduce(into: DateComponents()) { $0.setValue(rhs.to, for: $1) },
            for: timeZone
        ) !! preconditionFailure(
            "Date mutation failed with 'date' \(lhs) 'units' \(units) 'amount' \(amount) 'timeZone' \(timeZone)"
        )
    }

    public static func => (lhs: Date, rhs: (set: Set<Calendar.Component>, to: Int)) -> Date {
        lhs => (set: rhs.set, to: rhs.to, for: .neutral)
    }

    public static func => (lhs: Date, rhs: (set: Calendar.Component, to: Int, for: TimeZone)) -> Date {
        lhs => (set: [rhs.set], to: rhs.to, for: rhs.for)
    }

    public static func => (lhs: Date, rhs: (set: Calendar.Component, to: Int)) -> Date {
        lhs => (set: rhs.set, to: rhs.to, for: .neutral)
    }

    private func setting(_ components: DateComponents, for timeZone: TimeZone) -> Date? {
        let calendar = Calendar.neutral => (\.timeZone, timeZone)
        let allUnits: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let originalComponents = calendar.dateComponents(allUnits, from: self)
        let newComponents = allUnits.reduce(into: originalComponents) { acc, unit in
            acc.setValue(components.optionalValue(for: unit) ?? acc.optionalValue(for: unit), for: unit)
        }
        return calendar.date(from: newComponents)
    }
}

extension DateComponents {
    public func optionalValue(for unit: Calendar.Component) -> Int? {
        guard let value = value(for: unit), value != NSNotFound else {
            return nil
        }
        return value
    }
}

extension Date {
    public static func + (lhs: Date, rhs: (amount: Int, unit: Calendar.Component)) -> Date {
        Calendar.neutral.date(byAdding: rhs.unit, value: rhs.amount, to: lhs) !! preconditionFailure(
            "Date addition failed with 'date' \(lhs) 'amount' \(rhs.amount) 'unit' \(rhs.unit)"
        )
    }

    public static func - (lhs: Date, rhs: (amount: Int, unit: Calendar.Component)) -> Date {
        lhs + (-rhs.amount, rhs.unit)
    }

    public static func - (lhs: Date, rhs: (date: Date, unit: Calendar.Component)) -> Int {
        Calendar.neutral.dateComponents([rhs.unit], from: rhs.date, to: lhs).value(for: rhs.unit) !! preconditionFailure(
            "Date diff failed with 'toDate' \(lhs) 'fromDate' \(rhs.date) 'unit' \(rhs.unit)"
        )
    }
}

extension Date {
    public init(date: Date, time: Date) {
        let timeComponents = Calendar.neutral.dateComponents([.hour, .minute, .second], from: time)
        self = date.setting(timeComponents, for: .neutral) !! preconditionFailure(
            "Date merging failed with 'date' \(date) 'time' \(time)"
        )
    }
}

extension Date {
    #if os(Linux)
    public static var now: Date {
        Date()
    }
    #endif

    public static var referenceDate: Date {
        Date(timeIntervalSinceReferenceDate: .zero)
    }
}

#if DEBUG
extension Date: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = ISO8601DateFormatter().date(from: value) !! preconditionFailure(
            "Could not parse string literal '\(value)' into ISO 8601 date"
        )
    }
}
#endif
