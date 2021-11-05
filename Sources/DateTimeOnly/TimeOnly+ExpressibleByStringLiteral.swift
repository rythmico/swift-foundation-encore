#if DEBUG
import Foundation

extension TimeOnly: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        guard let _self = Self(rawValue: value) else {
            preconditionFailure("Could not parse string literal '\(value)' into \(Self.self)")
        }
        self = _self
    }
}
#endif