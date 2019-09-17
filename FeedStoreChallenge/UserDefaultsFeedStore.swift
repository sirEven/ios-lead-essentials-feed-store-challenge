//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public class UserDefaultsFeedStore: FeedStore {

    private struct CodableFeedImage: Codable {

        public var id: UUID
        public var imageDescription: String?
        public var location: String?
        public var url: URL

        public init(id: UUID, imageDescription: String?, location: String?, url: URL) {
            self.id = id
            self.imageDescription = imageDescription
            self.location = location
            self.url = url
        }
    }

    private struct CodableFeed: Codable {

        public var timestamp: Date
        public var feed: [CodableFeedImage]
        public var id: String

        public init(timestamp: Date, feed: [CodableFeedImage]) {
            self.timestamp = timestamp
            self.feed = feed
            self.id = UUID().uuidString
        }
    }

    private let queue = DispatchQueue(label: "\(UserDefaultsFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private var userDefaults: UserDefaults
    private var key: String

    public init(key: String, userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.key = key
    }

    public func deleteCachedFeed(completion: @escaping UserDefaultsFeedStore.DeletionCompletion) {

        queue.async(flags: .barrier) {
            let userDefaults = self.userDefaults

            userDefaults.removeObject(forKey: self.key)

            completion(nil)
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping UserDefaultsFeedStore.InsertionCompletion) {

        queue.async(flags: .barrier) {
            let jsonFeed = self.localFeedToJson(images: feed, timestamp: timestamp)
            let userDefaults = self.userDefaults

            userDefaults.set(jsonFeed, forKey: self.key)

            completion(nil)
        }
    }

    public func retrieve(completion: @escaping UserDefaultsFeedStore.RetrievalCompletion) {

        queue.async {
            let userDefaults = self.userDefaults
            if let jsonData = userDefaults.data(forKey: self.key) {

                let localFeed = self.jsonToLocalFeed(jsonFeed: jsonData)
                completion(.found(feed: localFeed.images, timestamp: localFeed.timestamp))

            } else {

                completion(.empty)

            }
        }
    }

    private func localFeedToJson(images: [LocalFeedImage], timestamp: Date) -> Data {

        let encoder = JSONEncoder()

        let archivedImages = images.map { CodableFeedImage(id: $0.id, imageDescription: $0.description, location: $0.location, url: $0.url) }

        let archivableFeed = CodableFeed(timestamp: timestamp, feed: archivedImages)

        let jsonFeed = try! encoder.encode(archivableFeed)

        return jsonFeed
    }

    private func jsonToLocalFeed(jsonFeed: Data) -> (timestamp: Date, images: [LocalFeedImage]) {

        let decoder = JSONDecoder()

        let archivedFeed = try! decoder.decode(CodableFeed.self, from: jsonFeed)

        let localFeedImages = archivedFeed.feed.map { LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url) }

        return (archivedFeed.timestamp, localFeedImages)
    }
}
