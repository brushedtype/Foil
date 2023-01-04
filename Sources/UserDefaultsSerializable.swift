//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//  Documentation
//  https://jessesquires.github.io/Foil
//
//  GitHub
//  https://github.com/jessesquires/Foil
//
//  Copyright © 2021-present Jesse Squires
//

import Foundation

/// Describes a value that can be saved to and fetched from `UserDefaults`.
///
/// Default conformances are provided for:
///    - `Bool`
///    - `Int`
///    - `UInt`
///    - `Float`
///    - `Double`
///    - `String`
///    - `URL`
///    - `Date`
///    - `Data`
///    - `Array`
///    - `Set`
///    - `Dictionary`
///    - `RawRepresentable` types
public protocol UserDefaultsSerializable {

    /// The type of the value that is stored in `UserDefaults`.
    associatedtype StoredValue

    /// The value to store in `UserDefaults`.
    var storedValue: StoredValue { get }

    /// Initializes the object using the provided value.
    ///
    /// - Parameter storedValue: The previously store value fetched from `UserDefaults`.
    init?(storedValue: StoredValue)
}

/// :nodoc:
extension Bool: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension Int: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension UInt: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension Float: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension Double: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension String: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension URL: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension Date: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension Data: UserDefaultsSerializable {
    public var storedValue: Self { self }

    public init(storedValue: Self) {
        self = storedValue
    }
}

/// :nodoc:
extension Array: UserDefaultsSerializable where Element: UserDefaultsSerializable {
    public var storedValue: [Element.StoredValue] {
        self.map { $0.storedValue }
    }

    public init?(storedValue: [Element.StoredValue]) {
        var elements: [Element] = []

        for value in storedValue {
            guard let element = Element(storedValue: value) else {
                return nil
            }
            elements.append(element)
        }

        self = elements
    }
}

/// :nodoc:
extension Set: UserDefaultsSerializable where Element: UserDefaultsSerializable {
    public var storedValue: [Element.StoredValue] {
        self.map { $0.storedValue }
    }

    public init?(storedValue: [Element.StoredValue]) {
        var elements: [Element] = []

        for value in storedValue {
            guard let element = Element(storedValue: value) else {
                return nil
            }
            elements.append(element)
        }

        self = Set(elements)
    }
}

/// :nodoc:
extension Dictionary: UserDefaultsSerializable where Key == String, Value: UserDefaultsSerializable {
    public var storedValue: [String: Value.StoredValue] {
        self.mapValues { $0.storedValue }
    }

    public init?(storedValue: [String: Value.StoredValue]) {
        let dict = try? storedValue.mapValues { try Value(storedValue: $0).tryUnwrap() }

        guard let dict else {
            return nil
        }

        self = dict
    }
}

/// :nodoc:
extension UserDefaultsSerializable where Self: RawRepresentable, Self.RawValue: UserDefaultsSerializable {
    public var storedValue: RawValue.StoredValue { self.rawValue.storedValue }

    public init?(storedValue: RawValue.StoredValue) {
        guard let rawValue = Self.RawValue(storedValue: storedValue) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}

extension Optional {

    enum UnwrapError: Error {
        case foundNil
    }

    func tryUnwrap() throws -> Wrapped {
        guard case .some(let wrapped) = self else {
            throw UnwrapError.foundNil
        }
        return wrapped
    }

}
