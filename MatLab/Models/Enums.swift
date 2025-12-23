import Foundation

// MARK: - Source Type
enum SourceType: String, Codable, CaseIterable {
    case streaming = "Streaming"
    case local = "Local"
    case downloaded = "Téléchargé"

    var icon: String {
        switch self {
        case .streaming: return "wifi"
        case .local: return "iphone"
        case .downloaded: return "arrow.down.circle.fill"
        }
    }
}

// MARK: - Progress Status
enum ProgressStatus: String, Codable, CaseIterable {
    case notSeen = "Non vu"
    case seen = "Vu"
    case inProgress = "En cours"
    case mastered = "Maîtrisé"
    case toReview = "À revoir"

    var icon: String {
        switch self {
        case .notSeen: return "circle"
        case .seen: return "eye.fill"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .mastered: return "checkmark.circle.fill"
        case .toReview: return "arrow.counterclockwise"
        }
    }

    var color: String {
        switch self {
        case .notSeen: return "gray"
        case .seen: return "blue"
        case .inProgress: return "orange"
        case .mastered: return "green"
        case .toReview: return "purple"
        }
    }
}

// MARK: - Gi Type
enum GiType: String, Codable, CaseIterable {
    case gi = "Gi"
    case noGi = "No-Gi"
    case both = "Les deux"

    var icon: String {
        switch self {
        case .gi: return "tshirt.fill"
        case .noGi: return "figure.wrestling"
        case .both: return "arrow.left.arrow.right"
        }
    }
}

// MARK: - Level
enum TechniqueLevel: String, Codable, CaseIterable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case advanced = "Avancé"

    var color: String {
        switch self {
        case .beginner: return "white"
        case .intermediate: return "blue"
        case .advanced: return "purple"
        }
    }
}

// MARK: - Video Type
enum VideoType: String, Codable, CaseIterable {
    case instructional = "Instructional"
    case highlight = "Highlight"
    case sparring = "Sparring"
    case competition = "Compétition"
    case drill = "Drill"

    var icon: String {
        switch self {
        case .instructional: return "book.fill"
        case .highlight: return "star.fill"
        case .sparring: return "figure.martial.arts"
        case .competition: return "trophy.fill"
        case .drill: return "repeat"
        }
    }
}

// MARK: - BJJ Category Type (Predefined)
enum BJJCategoryType: String, CaseIterable {
    case mobility = "Mobilité / Warm-up"
    case closedGuard = "Garde Fermée"
    case sitUpGuard = "Sit-up Guard"
    case butterflyGuard = "Butterfly Guard"
    case spiderGuard = "Spider Guard"
    case delaRiva = "De La Riva"
    case xGuard = "X-Guard"
    case halfGuard = "Half Guard"
    case topPosition = "Top Position"
    case backControl = "Back Control"
    case legLocks = "Leg Locks"
    case passing = "Passing"
    case takedowns = "Takedowns"
    case submissions = "Submissions"
    case escapes = "Escapes"
    case concepts = "Concepts"

    var icon: String {
        switch self {
        case .mobility: return "figure.run"
        case .closedGuard: return "shield.fill"
        case .sitUpGuard: return "chair.fill"
        case .butterflyGuard: return "leaf.fill"
        case .spiderGuard: return "ant.fill"
        case .delaRiva: return "figure.stand"
        case .xGuard: return "xmark"
        case .halfGuard: return "figure.wave"
        case .topPosition: return "arrow.up.circle.fill"
        case .backControl: return "arrow.uturn.backward.circle.fill"
        case .legLocks: return "figure.strengthtraining.traditional"
        case .passing: return "arrow.right.circle.fill"
        case .takedowns: return "figure.wrestling"
        case .submissions: return "hand.raised.fill"
        case .escapes: return "arrow.up.forward"
        case .concepts: return "brain.head.profile"
        }
    }

    var color: String {
        switch self {
        case .mobility: return "orange"
        case .closedGuard, .sitUpGuard, .butterflyGuard, .spiderGuard, .delaRiva, .xGuard, .halfGuard:
            return "blue"
        case .topPosition, .backControl:
            return "green"
        case .legLocks:
            return "red"
        case .passing:
            return "purple"
        case .takedowns:
            return "brown"
        case .submissions:
            return "red"
        case .escapes:
            return "teal"
        case .concepts:
            return "indigo"
        }
    }
}
