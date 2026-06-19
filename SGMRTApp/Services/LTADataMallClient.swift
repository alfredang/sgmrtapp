import Foundation

final class LTADataMallClient: @unchecked Sendable {
    private let session: URLSession
    private let accountKey: String
    private let baseURL = URL(string: "https://datamall2.mytransport.sg/ltaodataservice")!

    init(session: URLSession = .shared) {
        self.session = session
        accountKey = Bundle.main.object(forInfoDictionaryKey: "LTAAccountKey") as? String ?? ""
    }

    func fetchTrainServiceAlerts() async throws -> [TrainServiceAlert] {
        let url = baseURL.appending(path: "TrainServiceAlerts")
        let response: TrainAlertsResponse = try await get(url)
        if !response.value.affectedSegments.isEmpty {
            return response.value.affectedSegments
        }
        return response.value.messages.map {
            TrainServiceAlert(
                status: response.value.status,
                line: nil,
                direction: nil,
                stations: nil,
                message: $0
            )
        }
    }

    func fetchCrowdDensity(for line: MRTLine) async throws -> [CrowdDensity] {
        var components = URLComponents(url: baseURL.appending(path: "PCDRealTime"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "TrainLine", value: line.rawValue)]
        let response: ODataResponse<CrowdDensity> = try await get(components.url!)
        return response.value
    }

    private func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(accountKey, forHTTPHeaderField: "AccountKey")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

private struct ODataResponse<T: Decodable>: Decodable {
    let value: [T]
}

private struct TrainAlertsResponse: Decodable {
    let value: TrainAlertsValue
}

private struct TrainAlertsValue: Decodable {
    let status: Int?
    let affectedSegments: [TrainServiceAlert]
    let messages: [AlertMessage]

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case affectedSegments = "AffectedSegments"
        case messages = "Message"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        affectedSegments = try container.decodeIfPresent([TrainServiceAlert].self, forKey: .affectedSegments) ?? []
        messages = try container.decodeIfPresent([AlertMessage].self, forKey: .messages) ?? []
    }
}
