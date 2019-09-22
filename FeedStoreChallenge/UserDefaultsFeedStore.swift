//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class UserDefaultsFeedStore: FeedStore {

    private struct FeedImage: Codable {
        let id: UUID
        let imageDescription: String?
        let location: String?
        let url: URL
    }

    private struct Feed: Codable {
       let timestamp: Date
       let feed: [FeedImage]
    }

    private struct LocalFeed {
        let images: [LocalFeedImage]
        let timestamp: Date
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

            let feed = LocalFeed(images: feed, timestamp: timestamp)
            let data = self.data(from: feed)

            self.userDefaults.set(data, forKey: self.key)

            completion(nil)
        }
    }

    public func retrieve(completion: @escaping UserDefaultsFeedStore.RetrievalCompletion) {

        queue.async {

            if let jsonData = self.userDefaults.data(forKey: self.key) {

                let localFeed = self.feed(from: jsonData)
                completion(.found(feed: localFeed.images, timestamp: localFeed.timestamp))

            } else {

                completion(.empty)

            }
        }
    }

    private func data(from feed: LocalFeed) -> Data {

        let images = feed.images.map { FeedImage(id: $0.id, imageDescription: $0.description, location: $0.location, url: $0.url) }

        let feed = Feed(timestamp: feed.timestamp, feed: images)

        return try! JSONEncoder().encode(feed)
    }

    private func feed(from data: Data) -> LocalFeed {

        let feed = try! JSONDecoder().decode(Feed.self, from: data)

        let images = feed.feed.map { LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url) }

        return LocalFeed(images: images, timestamp: feed.timestamp)
    }
}
