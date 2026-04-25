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
        case .sentence: "Cümle Tamamla"
        case .hunt: "Kelime Avı"
        }
    }

    var subtitle: String {
        switch self {
        case .free: "Süresiz, kendi hızında çalış"
        case .typing: "60 saniyede kac bilirsin?"
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
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "tr_TR"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
