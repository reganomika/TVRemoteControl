import Foundation

public  struct LGTVResponseApplication: Codable, Identifiable {
    public init(id: String? = nil, title: String? = nil, systemApp: Bool? = nil) {
        self.id = id
        self.title = title
        self.systemApp = systemApp
    }
    
    public let id: String?
    public let title: String?
    public let systemApp: Bool?
}
