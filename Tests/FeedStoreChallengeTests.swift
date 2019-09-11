//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class ArchivedFeedImage: Codable {

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

class ArchivedFeed: Codable {

    public var timestamp: Date
    public var feed: [ArchivedFeedImage]
    public var id: String

    public init(timestamp: Date, feed: [ArchivedFeedImage]) {
        self.timestamp = timestamp
        self.feed = feed
        self.id = UUID().uuidString
    }
}

class UserDefaultsFeedStore: FeedStore {

    private func userDefaults() -> UserDefaults {
        return UserDefaults.standard
    }

    private let queue = DispatchQueue(label: "\(UserDefaultsFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)

    func deleteCachedFeed(completion: @escaping UserDefaultsFeedStore.DeletionCompletion) {

    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping UserDefaultsFeedStore.InsertionCompletion) {

        let jsonFeed = self.localFeedToJson(images: feed, timestamp: timestamp)

        self.userDefaults().set(jsonFeed, forKey: "feed")

        completion(nil)

    }

    func retrieve(completion: @escaping UserDefaultsFeedStore.RetrievalCompletion) {

        if let jsonData = self.userDefaults().data(forKey: "feed") {

            let localFeed = self.jsonToLocalFeed(jsonFeed: jsonData)
            completion(.found(feed: localFeed.images, timestamp: localFeed.timestamp))

        } else {

            completion(.empty)

        }

    }

    private func localFeedToJson(images: [LocalFeedImage], timestamp: Date) -> Data {

        let encoder = JSONEncoder()

        let archivedImages = images.map { ArchivedFeedImage(id: $0.id, imageDescription: $0.description, location: $0.location, url: $0.url) }

        let archivableFeed = ArchivedFeed(timestamp: timestamp, feed: archivedImages)

        let jsonFeed = try! encoder.encode(archivableFeed)

        return jsonFeed
    }

    private func jsonToLocalFeed(jsonFeed: Data) -> (timestamp: Date, images: [LocalFeedImage]) {

        let decoder = JSONDecoder()

        let archivedFeed = try! decoder.decode(ArchivedFeed.self, from: jsonFeed)

        let localFeedImages = archivedFeed.feed.map { LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url) }

        return (archivedFeed.timestamp, localFeedImages)
    }
}

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {

    //
    //   We recommend you to implement one test at a time.
    //   Uncomment the test implementations one by one.
    // 	 Follow the process: Make the test pass, commit, and move to the next one.
    //

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        //      let sut = makeSUT()
        //
        //      assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        //		let sut = makeSUT()
        //
        //		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        //		let sut = makeSUT()
        //
        //		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        //		let sut = makeSUT()
        //
        //		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        //		let sut = makeSUT()
        //
        //		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_storeSideEffects_runSerially() {
        //		let sut = makeSUT()
        //
        //		assertThatSideEffectsRunSerially(on: sut)
    }

    // - MARK: Helpers

    private func makeSUT() -> FeedStore {
        let sut = UserDefaultsFeedStore()
        return sut
    }

    private func cleanDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "feed")
    }

    override func tearDown() {
        cleanDefaults()
    }

    override func setUp() {
        cleanDefaults()
    }

}

//
// Uncomment the following tests if your implementation has failable operations.
// Otherwise, delete the commented out code!
//

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() {
////		let sut = makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() {
////		let sut = makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
