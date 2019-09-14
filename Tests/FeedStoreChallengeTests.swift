//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class CodableFeedImage: Codable {

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

class CodableFeed: Codable {

    public var timestamp: Date
    public var feed: [CodableFeedImage]
    public var id: String

    public init(timestamp: Date, feed: [CodableFeedImage]) {
        self.timestamp = timestamp
        self.feed = feed
        self.id = UUID().uuidString
    }
}

class UserDefaultsFeedStore: FeedStore {

    private var userDefaults: UserDefaults
    private var key: String

    public init(key: String, userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.key = key
    }

    func deleteCachedFeed(completion: @escaping UserDefaultsFeedStore.DeletionCompletion) {

        let userDefaults = self.userDefaults

        userDefaults.removeObject(forKey: key)

        completion(nil)
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping UserDefaultsFeedStore.InsertionCompletion) {

        let jsonFeed = self.localFeedToJson(images: feed, timestamp: timestamp)
        let userDefaults = self.userDefaults

        userDefaults.set(jsonFeed, forKey: key)

        completion(nil)
    }

    func retrieve(completion: @escaping UserDefaultsFeedStore.RetrievalCompletion) {

        let userDefaults = self.userDefaults
        if let jsonData = userDefaults.data(forKey: key) {

            let localFeed = self.jsonToLocalFeed(jsonFeed: jsonData)
            completion(.found(feed: localFeed.images, timestamp: localFeed.timestamp))

        } else {

            completion(.empty)

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

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {

    //
    //   We recommend you to implement one test at a time.
    //   Uncomment the test implementations one by one.
    // 	 Follow the process: Make the test pass, commit, and move to the next one.
    //

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        assertThatSideEffectsRunSerially(on: sut)
    }

    // - MARK: Helpers

    private func makeSUT(with key: String) -> FeedStore {
        let sut = UserDefaultsFeedStore(key: testSpecificUserDefaultsKey(), userDefaults: .standard)
        return sut
    }

    private func testSpecificUserDefaultsKey() -> String {
        return "feed"
    }

    private func cleanDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: testSpecificUserDefaultsKey())
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
