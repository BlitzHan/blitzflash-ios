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
        case .sentence: "Cumle Tamamla"
        case .hunt: "Kelime Avi"
        }
    }

    var subtitle: String {
        switch self {
        case .free: "Suresiz, kendi hizinda calis"
        case .typing: "60 saniyede kac bilirsin?"
        case .sentence: "Bosluklu cumlede dogru kelimeyi bul"
        case .hunt: "Grid'deki kelimeleri cevir"
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
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "tr_TR"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
