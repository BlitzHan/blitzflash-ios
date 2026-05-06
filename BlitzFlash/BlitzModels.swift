import Foundation

struct VocabularyWord: Identifiable, Hashable {
    let id = UUID()
    var english: String
    var turkish: String
    var englishSentence: String
    var turkishSentence: String

    var acceptedAnswers: [String] {
        turkish
            .replacingOccurrences(of: "(", with: "/")
            .replacingOccurrences(of: ")", with: "/")
            .components(separatedBy: CharacterSet(charactersIn: "/,;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).foldedForAnswer }
            .filter { !$0.isEmpty }
    }

    func matches(_ answer: String) -> Bool {
        let normalized = answer.foldedForAnswer
        guard !normalized.isEmpty else { return false }
        return acceptedAnswers.contains { option in
            option == normalized || option.contains(normalized) || normalized.contains(option)
        }
    }

    func targetTerm(for language: LearningLanguage) -> String {
        switch language {
        case .english:
            english
        case .spanish:
            SpanishVocabularyData.entry(for: self)?.term ?? english
        }
    }

    func targetSentence(for language: LearningLanguage) -> String {
        switch language {
        case .english:
            englishSentence
        case .spanish:
            SpanishVocabularyData.entry(for: self)?.sentence ?? englishSentence
        }
    }

    func targetAcceptedAnswers(for language: LearningLanguage) -> [String] {
        targetTerm(for: language)
            .replacingOccurrences(of: "(", with: "/")
            .replacingOccurrences(of: ")", with: "/")
            .components(separatedBy: CharacterSet(charactersIn: "/,;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).foldedForAnswer }
            .filter { !$0.isEmpty }
    }

    func strictlyMatchesTarget(_ answer: String, language: LearningLanguage) -> Bool {
        let normalized = answer.foldedForAnswer
        guard !normalized.isEmpty else { return false }
        return targetAcceptedAnswers(for: language).contains(normalized)
    }

    func strictlyMatchesTurkish(_ answer: String) -> Bool {
        let normalized = answer.foldedForAnswer
        guard !normalized.isEmpty else { return false }
        return acceptedAnswers.contains(normalized) || turkish.foldedForAnswer == normalized
    }
}

enum LearningLanguage: String, CaseIterable, Identifiable {
    case english
    case spanish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "İngilizce"
        case .spanish: "İspanyolca"
        }
    }

    var nativeTitle: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        }
    }

    var shortCode: String {
        switch self {
        case .english: "EN"
        case .spanish: "ES"
        }
    }

    var cardLabel: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        }
    }
}

enum BlitzMode: String, CaseIterable, Identifiable {
    case free
    case typing
    case sentence
    case hunt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: "Serbest Mod"
        case .typing: "Yazarak Tahmin"
        case .sentence: "Cümle Tamamla"
        case .hunt: "Kelime Avı"
        }
    }

    var subtitle: String {
        switch self {
        case .free: "Süresiz, kendi hızında çalış"
        case .typing: "60 saniyede kaç bilirsin?"
        case .sentence: "Boşluklu cümlede doğru kelimeyi bul"
        case .hunt: "Grid'deki kelimeleri çevir"
        }
    }

    var icon: String {
        switch self {
        case .free: "rectangle.stack.fill"
        case .typing: "keyboard.fill"
        case .sentence: "text.badge.checkmark"
        case .hunt: "square.grid.3x3.fill"
        }
    }
}

extension String {
    var foldedForAnswer: String {
        replacingOccurrences(of: "İ", with: "i")
            .replacingOccurrences(of: "I", with: "i")
            .replacingOccurrences(of: "ı", with: "i")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "tr_TR"))
            .lowercased(with: Locale(identifier: "tr_TR"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
