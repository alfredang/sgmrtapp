import Foundation
import SwiftUI

enum MRTLine: String, CaseIterable, Codable, Hashable {
    case nsl = "NSL"
    case ewl = "EWL"
    case cgl = "CGL"
    case nel = "NEL"
    case ccl = "CCL"
    case cel = "CEL"
    case dtl = "DTL"
    case tel = "TEL"

    var name: String {
        switch self {
        case .nsl: "North South Line"
        case .ewl: "East West Line"
        case .cgl: "Changi Airport Branch"
        case .nel: "North East Line"
        case .ccl: "Circle Line"
        case .cel: "Circle Line Extension"
        case .dtl: "Downtown Line"
        case .tel: "Thomson-East Coast Line"
        }
    }

    var tint: Color {
        switch self {
        case .nsl: Color(red: 0.82, green: 0.08, blue: 0.12)
        case .ewl, .cgl: Color(red: 0.02, green: 0.55, blue: 0.22)
        case .nel: Color(red: 0.55, green: 0.19, blue: 0.72)
        case .ccl, .cel: Color(red: 0.91, green: 0.55, blue: 0.08)
        case .dtl: Color(red: 0.02, green: 0.28, blue: 0.68)
        case .tel: Color(red: 0.57, green: 0.34, blue: 0.18)
        }
    }
}

struct Station: Identifiable, Hashable {
    let id: String
    let name: String
    let lines: Set<MRTLine>

    var sortedLines: [MRTLine] {
        lines.sorted { $0.rawValue < $1.rawValue }
    }
}

struct TrackEdge: Hashable {
    let from: String
    let to: String
    let line: MRTLine
    let minutes: Int
}

struct RouteResult: Equatable {
    let stations: [Station]
    let steps: [RouteStep]
    let estimatedMinutes: Int
    let transferCount: Int
}

struct RouteStep: Identifiable, Equatable {
    let id = UUID()
    let line: MRTLine
    let stations: [Station]
    let minutes: Int

    static func == (lhs: RouteStep, rhs: RouteStep) -> Bool {
        lhs.line == rhs.line && lhs.stations == rhs.stations && lhs.minutes == rhs.minutes
    }
}

struct TrainServiceAlert: Decodable, Identifiable {
    var id: String { "\(line ?? "ALL")-\(message?.createdDate ?? message?.content ?? "service")" }
    let status: Int?
    let line: String?
    let direction: String?
    let stations: String?
    let message: AlertMessage?

    init(status: Int?, line: String?, direction: String?, stations: String?, message: AlertMessage?) {
        self.status = status
        self.line = line
        self.direction = direction
        self.stations = stations
        self.message = message
    }

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case line = "Line"
        case direction = "Direction"
        case stations = "Stations"
        case message = "Message"
    }
}

struct AlertMessage: Decodable {
    let content: String?
    let createdDate: String?

    enum CodingKeys: String, CodingKey {
        case content = "Content"
        case createdDate = "CreatedDate"
    }
}

struct CrowdDensity: Decodable, Identifiable {
    var id: String { "\(station)-\(startTime ?? "")" }
    let station: String
    let startTime: String?
    let endTime: String?
    let crowdLevel: String

    enum CodingKeys: String, CodingKey {
        case station = "Station"
        case startTime = "StartTime"
        case endTime = "EndTime"
        case crowdLevel = "CrowdLevel"
    }

    var displayLevel: String {
        switch crowdLevel.lowercased() {
        case "l": "Low"
        case "m": "Moderate"
        case "h": "High"
        default: "Unavailable"
        }
    }
}
