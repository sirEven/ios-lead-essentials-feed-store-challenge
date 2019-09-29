//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class UserDefaultsFeedStore: FeedStore {

    fileprivate struct FeedImage: Codable {
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
            let data = try! self.data(from: feed)

            self.userDefaults.set(data, forKey: self.key)

            completion(nil)
        }
    }

    public func retrieve(completion: @escaping UserDefaultsFeedStore.RetrievalCompletion) {

        queue.async {
            guard let jsonData = self.userDefaults.data(forKey: self.key) else {
                return completion(.empty)
            }

            do {
                let localFeed = try self.feed(from: jsonData)
                completion(.found(feed: localFeed.images, timestamp: localFeed.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func data(from feed: LocalFeed) throws -> Data {

        let images = feed.images.map { FeedImage(image: $0) }

        let feed = Feed(timestamp: feed.timestamp, feed: images)

        return try JSONEncoder().encode(feed)
    }

    private func feed(from data: Data) throws -> LocalFeed {

        let feed = try JSONDecoder().decode(Feed.self, from: data)

        let images = feed.feed.map { LocalFeedImage(image: $0) }

        return LocalFeed(images: images, timestamp: feed.timestamp)
    }
}

private extension UserDefaultsFeedStore.FeedImage {
    init(image: LocalFeedImage){
        self.init(id: image.id, imageDescription: image.description, location: image.location, url: image.url)
    }
}

private extension LocalFeedImage {
    init(image: UserDefaultsFeedStore.FeedImage){
        self.init(id: image.id, description: image.imageDescription, location: image.location, url: image.url)
    }
}
