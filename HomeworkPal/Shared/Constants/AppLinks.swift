import Foundation

/// Web pages linked from Settings → About.
enum AppLinks {
    // Force-unwrapping is safe here: each is a fixed, well-formed literal, so a typo fails on first launch in testing.
    static let sourceCode = URL(string: "https://github.com/SpacemenDevSquad/HomeworkPal")!
    /// Hosted in the public repository so the policy sits next to the code that keeps it.
    static let privacyPolicy = URL(string: "https://github.com/SpacemenDevSquad/HomeworkPal/blob/main/PRIVACY.md")!
    static let termsOfService = URL(string: "https://github.com/SpacemenDevSquad/HomeworkPal/blob/main/TERMS.md")!
}
