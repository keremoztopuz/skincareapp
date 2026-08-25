//
//  LocalizationTests.swift
//  SkinCareTests
//
//  Created by Kerem Öztopuz on 22.08.2026.
//

import Testing
import Foundation
@testable import SkinCare

private let supportedLanguages = ["en", "tr"]

private func localizationKeys(for language: String) throws -> Set<String> {
    let path = try #require(
        Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
        "Localizable.strings missing for \(language)"
    )
    let dictionary = try #require(
        NSDictionary(contentsOfFile: path) as? [String: String],
        "Localizable.strings unreadable for \(language)"
    )
    return Set(dictionary.keys)
}

@Test func testAllLanguagesShareSameLocalizationKeys() throws {
    let reference = try localizationKeys(for: "en")
    #expect(!reference.isEmpty)

    for language in supportedLanguages.dropFirst() {
        let localized = try localizationKeys(for: language)
        let missing = reference.subtracting(localized).sorted()
        let stale = localized.subtracting(reference).sorted()
        #expect(missing.isEmpty, "\(language) is missing keys: \(missing)")
        #expect(stale.isEmpty, "\(language) has stale keys: \(stale)")
    }
}

@Test func testLocalizedValuesAreNotEmpty() throws {
    for language in supportedLanguages {
        let path = try #require(Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language))
        let dictionary = try #require(NSDictionary(contentsOfFile: path) as? [String: String])
        let emptyKeys = dictionary.filter { $0.value.isEmpty }.keys.sorted()
        #expect(emptyKeys.isEmpty, "\(language) has empty values for: \(emptyKeys)")
    }
}
