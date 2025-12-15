private func validateMessage(text: String) throws {
        let minimumCharacters: Int = 3
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).count >= minimumCharacters else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharacters)
        }
        let badWords: [String] = ["bitch", "ass"]
        if !badWords.contains(where: { text.lowercased().contains($0) }) {
            throw TextValidationError.hasBadWords
        }
    }