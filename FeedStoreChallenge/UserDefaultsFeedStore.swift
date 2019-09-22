//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class UserDefaultsFeedStore: FeedStore {

    private struct CodableFeedImage: Codable {

        let id: UUID
        let imageDescription: String?
        let location: String?
        let url: URL
    }

    private struct CodableFeed: Codable {

       let timestamp: Date
       let feed: [CodableFeedImage]
       let id: String

        init(timestamp: Date, feed: [CodableFeedImage]) {
            self.timestamp = timestamp
            self.feed = feed
            id = UUID().uuidString
        }
    }

    private let queue: DispatchQueue
    private let userDefaults: UserDefaults
    private let key: String

    public init(key: String, userDefaults: UserDefaults) {

        self.userDefaults = userDefaults
        self.key = key
        queue = DispatchQueue(label: "\(UserDefaultsFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    }

    public func deleteCachedFeed(completion: @escaping UserDefaultsFeedStore.DeletionCompletion) {

        queue.async(flags: .barrier) {

            self.userDefaults.removeObject(forKey: self.key)

            completion(nil)
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping UserDefaultsFeedStore.InsertionCompletion) {

        queue.async(flags: .barrier) {
            let jsonFeed = self.localFeedToJson(images: feed, timestamp: timestamp)

            self.userDefaults.set(jsonFeed, forKey: self.key)

            completion(nil)
        }
    }

    public func retrieve(completion: @escaping UserDefaultsFeedStore.RetrievalCompletion) {

        queue.async {

            if let jsonData = self.userDefaults.data(forKey: self.key) {

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
