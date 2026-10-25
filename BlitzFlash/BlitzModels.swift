import Foundation

struct VocabularyWord: Identifiable, Hashable {
    let id = UUID()
    var english: String
    var turkish: String
    var englishSentence: String
    var turkishSentence: String

    /// "Hangi / Hangisi (soru)" → ["hangi", "hangisi", "soru"]
    private static func answerOptions(_ text: String) -> [String] {
        text.components(separatedBy: CharacterSet(charactersIn: "/,;()"))
            .map(\.foldedForAnswer)
            .filter { !$0.isEmpty }
    }

    /// Yazarak Tahmin için hoşgörülü eşleşme: tam eşleşme ya da en az 3 harflik parça.
    /// (Eskiden tek harf bile "içeriyor" sayılıp doğru kabul ediliyordu.)
    func matches(_ answer: String) -> Bool {
        let normalized = answer.foldedForAnswer
        guard !normalized.isEmpty else { return false }
        return Self.answerOptions(turkish).contains { option in
            option == normalized
                || (normalized.count >= 3 && (option.contains(normalized) || normalized.contains(option)))
        }
    }

    func strictlyMatchesTurkish(_ answer: String) -> Bool {
        let normalized = answer.foldedForAnswer
        return !normalized.isEmpty
            && (Self.answerOptions(turkish).contains(normalized) || turkish.foldedForAnswer == normalized)
    }

    func strictlyMatchesTarget(_ answer: String, language: LearningLanguage) -> Bool {
        let normalized = answer.foldedForAnswer
        return !normalized.isEmpty && Self.answerOptions(targetTerm(for: language)).contains(normalized)
    }

    func targetTerm(for language: LearningLanguage) -> String {
        switch language {
        case .english: english
        case .spanish: SpanishVocabularyData.entry(for: self)?.term ?? english
        case .czech: CzechVocabularyData.entry(for: self)?.term ?? english
        }
    }

    /// Hedef dildeki örnek cümle. İspanyolca/Çekçe verinin bir kısmı yer tutucu
    /// cümle ("La palabra X aparece...") içerdiği için onlar hiç gösterilmez.
    func targetSentence(for language: LearningLanguage) -> String? {
        switch language {
        case .english:
            return englishSentence
        case .spanish:
            guard let sentence = SpanishVocabularyData.entry(for: self)?.sentence,
                  !sentence.hasPrefix("La palabra ") else { return nil }
            return sentence
        case .czech:
            guard let sentence = CzechVocabularyData.entry(for: self)?.sentence,
                  !sentence.hasPrefix("Slovo ") else { return nil }
            return sentence
        }
    }

    func targetPronunciation(for language: LearningLanguage) -> String? {
        switch language {
        case .english: EnglishPronunciationData.pronunciation(for: english)
        case .czech: CzechVocabularyData.entry(for: self)?.pronunciation
        case .spanish: nil
        }
    }
}

/// Son gösterilen kelimeleri tekrar etmeden rastgele seçer.
struct WordPicker {
    private var recentIDs: [UUID] = []
    private let memory = 40

    mutating func next(from words: [VocabularyWord]) -> VocabularyWord? {
        let pool = words.filter { !recentIDs.contains($0.id) }
        guard let word = (pool.isEmpty ? words : pool).randomElement() else { return nil }
        recentIDs.append(word.id)
        if recentIDs.count > memory { recentIDs.removeFirst() }
        return word
    }
}

enum LearningLanguage: String, CaseIterable, Identifiable {
    case english
    case spanish
    case czech

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "İngilizce"
        case .spanish: "İspanyolca"
        case .czech: "Çekçe"
        }
    }

    var nativeTitle: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        case .czech: "Čeština"
        }
    }

    var shortCode: String {
        switch self {
        case .english: "EN"
        case .spanish: "ES"
        case .czech: "CZ"
        }
    }

    /// Bu dilde karşılığı olan kelimeler (eksik çeviri İngilizce görünmesin).
    var words: [VocabularyWord] {
        switch self {
        case .english: VocabularyData.words
        case .spanish: VocabularyData.words.filter { SpanishVocabularyData.entry(for: $0) != nil }
        case .czech: VocabularyData.words.filter { CzechVocabularyData.entry(for: $0) != nil }
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
