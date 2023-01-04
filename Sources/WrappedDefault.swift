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

import Combine
import Foundation

/// A property wrapper that uses `UserDefaults` as a backing store,
/// whose `wrappedValue` is non-optional and registers a **non-optional default value**.
@propertyWrapper
public struct WrappedDefault<T: UserDefaultsSerializable> {
    private let _userDefaults: UserDefaults
    private let _publisher: CurrentValueSubject<T, Never>
    private let _observer: ObserverTrampoline

    /// The key for the value in `UserDefaults`.
    public let key: String

    /// The value retrieved from `UserDefaults`.
    public var wrappedValue: T {
        get {
            try! self._userDefaults.fetch(self.key)
        }
        set {
            self._userDefaults.save(newValue, for: self.key)
        }
    }

    /// A publisher that delivers updates to subscribers.
    public var projectedValue: AnyPublisher<T, Never> {
        self._publisher.eraseToAnyPublisher()
    }

    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - wrappedValue: The default value to register for the specified key.
    ///   - keyName: The key for the value in `UserDefaults`.
    ///   - userDefaults: The `UserDefaults` backing store. The default value is `.standard`.
    public init(wrappedValue: T, key keyName: String, userDefaults: UserDefaults = .standard) {
        self.key = keyName
        self._userDefaults = userDefaults
        userDefaults.registerDefault(value: wrappedValue, key: keyName)

        // error is thrown if there was an error decoding the stored value
        do {
            let storedValue: T = try userDefaults.fetch(keyName)
            self._publisher = CurrentValueSubject<T, Never>(storedValue)

        } catch {
            // when we catch an error, we reset the user default value. in some situations that may be OK
            // but in others we may want to recover in a different way...
            self._userDefaults.delete(for: keyName)

            // set the initial value to the wrapped value
            self._publisher = CurrentValueSubject<T, Never>(wrappedValue)
        }

        self._observer = ObserverTrampoline(userDefaults: userDefaults, key: keyName) { [unowned _publisher] in
            // TODO: handle default being set to value that cannot be decoded
            _publisher.send(try! userDefaults.fetch(keyName))
        }
    }
}
