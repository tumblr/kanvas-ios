//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import AVFoundation

extension Data {
    func save(to filename: String, in directory: URL, ext fileExtension: String) throws -> URL {
        let fileURL = directory.appendingPathComponent(filename).appendingPathExtension(fileExtension)
        try write(to: fileURL, options: .atomic)
        return fileURL
    }
}

extension UIImage {
    func save(info: MediaInfo, in directory: URL = FileManager.default.temporaryDirectory) -> URL? {
        do {
            guard let jpgImageData = jpegData(compressionQuality: 1.0) else {
                return nil
            }
            let fileURL = try jpgImageData.save(to: "\(hashValue)", in: directory, ext: "jpg")
            info.write(toImage: fileURL)
            return fileURL
        } catch {
            print("Failed to save to file. \(error)")
            return nil
        }
    }
}

private extension DispatchQueue {
    /// Dispatch block asynchronously
    /// - Parameter block: Block

    func publisher<Output, Failure: Error>(_ block: @escaping (Future<Output, Failure>.Promise) -> Void) -> AnyPublisher<Output, Failure> {
        Future<Output, Failure> { promise in
            self.async { block(promise) }
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output: Sequence {
    typealias Sorter = (Output.Element, Output.Element) -> Bool

    func sort(
        by sorter: @escaping Sorter
    ) -> Publishers.Map<Self, [Output.Element]> {
        map { sequence in
            sequence.sorted(by: sorter)
        }
    }
}

class Archiver {
    let saveDirectory: URL

    init(saveDirectory: URL) {
        self.saveDirectory = saveDirectory
    }

    @available(iOS 13, *)
    func handle(exports: [EditorViewController.ExportResult?]) -> AnyPublisher<[Result<KanvasMedia?, Error>], Error> {
        let exportCount = exports.count
        let publishers: [AnyPublisher<(Int, KanvasMedia?), Error>] = exports.enumerated().map { (index, export) in
            return DispatchQueue.global(qos: .userInitiated).publisher { [weak self] promise
                in
                guard let export = export else {
                    promise(.success((index, nil)))
                    return
                }
                let media = self?.handle(export: export)
                promise(.success((index, media)))
            }
        }
        let allPublishers = Publishers.MergeMany(publishers)
        let collected = allPublishers.collect(exportCount).sort(by: { (first, second) in
            return first.0 < second.0
        }).map({ (element) -> [Result<KanvasMedia?, Error>] in
            return element.map { index, item in
                return .success(item)
            }
        })
        let result: AnyPublisher<[Result<KanvasMedia?, Error>], Error> = collected.eraseToAnyPublisher()
        return result
    }

    func handle(export: EditorViewController.ExportResult) -> KanvasMedia? {

        switch (export.result, export.original) {
        case (.image(let image), .image(let original)):
            if let url = image.save(info: export.info), let originalURL = original.save(info: export.info, in: self.saveDirectory) {
                print("Original image URL: \(originalURL)")
                return KanvasMedia(image: image, url: url, original: originalURL, info: export.info)
            } else {
                return nil
            }
        case (.video(let url), .video(let original)):
            print("Original video URL: \(original)")
            let asset = AVURLAsset(url: url)
            return KanvasMedia(asset: asset, original: original, info: export.info)
        default:
            return nil
        }
    }
}
