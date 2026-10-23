
import Foundation

struct MemorySession: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let activity: String
    let totalRounds: Int
    let correctRounds: Int
    let highestLevel: Int
    let totalDigitsShown: Int
    let hardestCorrectSequenceLength: Int

    var accuracyPercentage: Int {
        guard totalRounds > 0 else { return 0 }
        return Int(
            (Double(correctRounds) / Double(totalRounds) * 100).rounded()
        )
    }

    init(
        date: Date,
        activity: String,
        totalRounds: Int,
        correctRounds: Int,
        highestLevel: Int,
        totalDigitsShown: Int = 0,
        hardestCorrectSequenceLength: Int = 0
    ) {
        self.date = date
        self.activity = activity
        self.totalRounds = totalRounds
        self.correctRounds = correctRounds
        self.highestLevel = highestLevel
        self.totalDigitsShown = totalDigitsShown
        self.hardestCorrectSequenceLength = hardestCorrectSequenceLength
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case activity
        case totalRounds
        case correctRounds
        case highestLevel
        case totalDigitsShown
        case hardestCorrectSequenceLength
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try container.decode(Date.self, forKey: .date)
        activity = try container.decode(String.self, forKey: .activity)
        totalRounds = try container.decode(Int.self, forKey: .totalRounds)
        correctRounds = try container.decode(Int.self, forKey: .correctRounds)
        highestLevel = try container.decode(Int.self, forKey: .highestLevel)

        totalDigitsShown = try container.decodeIfPresent(
            Int.self,
            forKey: .totalDigitsShown
        ) ?? 0

        hardestCorrectSequenceLength = try container.decodeIfPresent(
            Int.self,
            forKey: .hardestCorrectSequenceLength
        ) ?? 0
    }
}
