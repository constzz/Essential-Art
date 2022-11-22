//
//  Essential Art Image Cache Integration Tests.swift
//  Essential Art Cache Integration Tests
//
//  Created by Konstantin Bezzemelnyi on 22.11.2022.
//

import Foundation
import XCTest
import Essential_Art


class Essential_Art_ImageCacheIntegrationTests: XCTestCase, ArtworksCacheIntegrationTests {
    
    override func setUp() {
        super.setUp()
        deleteStoreArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        deleteStoreArtifacts()
    }

    func test_loadImageData_deliversSavedData() throws {
        let imageLoader = makeImageLoader()
        let artworksLoader = makeSUT()
        
        let imageURL = anyImageURL
        let artwork = artwork(withImageURL: imageURL)
        
        let image = UIImage.make(withColor: .green)
        let expectedImageData = image.pngData()
        let imageResponse = succcessfulResponse(forURL: imageURL)
        
        try artworksLoader.save([artwork])
        try imageLoader.save(image, for: imageResponse)
        
        expect(imageLoader, toRecieveImageData: expectedImageData, forImageURL: artwork.imageURL)
    }
        
    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() throws {
        
        let imageLoader = makeImageLoader()
        let artworksLoader = makeSUT()
        
        let imageURL = anyImageURL
        let artwork = artwork(withImageURL: imageURL)
        
        let oldImage = UIImage.make(withColor: .green)
        let newImage = UIImage.make(withColor: .blue)
        
        let imageResponse = succcessfulResponse(forURL: imageURL)
        
        try artworksLoader.save([artwork])
        try imageLoader.save(oldImage, for: imageResponse)
        try imageLoader.save(newImage, for: imageResponse)
        
        expect(imageLoader, toRecieveImageData: newImage.pngData(), forImageURL: artwork.imageURL)
    }
    
    // MARK: - Helpers
    
    private func makeImageLoader() -> ArtworkImageStore {
        let cache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 0, directory: testSpecificStoreURL)
        return URLCacheArtworkImageStore(cache: cache)
    }
    
    private func makeSUT(currentDate: Date = .init()) -> LocalArtworksLoader {
        let store: ArtworksStore = try! CoreDataArtworksStore(storeURL: testSpecificStoreURL)
        let loader = LocalArtworksLoader(store: store, currentDate: { currentDate })
        
        return loader
    }
    
    private var anyImageURL: URL {
        URL(string: "https://test-url.com/image1.jpg")!
    }
    
    private func succcessfulResponse(forURL url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func artwork(withImageURL imageURL: URL) -> Artwork {
        Artwork(title: "", imageURL: imageURL, artist: "")
    }
    
    private func expect(
        _ sut: ArtworkImageStore,
        toRecieveImageData expectedImageData: Data?,
        forImageURL imageURL: URL,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let result = Result { try sut.retrieve(dataForURL: imageURL) }
        switch result {
        case .success(let image):
            XCTAssertEqual(image.pngData(), expectedImageData, file: file, line: line)
            
        case .failure(let error):
            XCTFail("Expected to retreive image, but recieved \(error) instead", file: file, line: line)
        }
    }

    
    internal var testSpecificStoreURL: URL {
        return cacheDirectory.appendingPathComponent("\(type(of: self))")
    }
    
    private var cacheDirectory: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
