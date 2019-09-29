//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

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

    //
    // Uncomment the following tests if your implementation has failable operations.
    // Otherwise, delete the commented out code!
    //

    //extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
    //
    //    func test_insert_deliversErrorOnInsertionError() {
    ////        let sut = makeSUT()
    ////
    ////        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    //    }
    //
    //    func test_insert_hasNoSideEffectsOnInsertionError() {
    ////        let sut = makeSUT()
    ////
    ////        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    //    }
    //
    //}
    //extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
    //
    //    func test_delete_deliversErrorOnDeletionError() {
    ////        let sut = makeSUT()
    ////
    ////        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    //    }
    //
    //    func test_delete_hasNoSideEffectsOnDeletionError() {
    ////        let sut = makeSUT()
    ////
    ////        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    //    }

}

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {

    func test_retrieve_deliversFailureOnRetrievalError() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        writeInvalidData()

        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let sut = makeSUT(with: testSpecificUserDefaultsKey())

        writeInvalidData()

        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }

    private func writeInvalidData() {
        UserDefaults.standard.set("invalid data".data(using: .utf8), forKey: "feed")
    }

}
