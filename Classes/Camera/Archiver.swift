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
    func handle(exports: [EditorViewController.ExportResult?]) -> AnyPublisher<[Result<KanvasCameraMedia?, Error>], Error> {
        let exportCount = exports.count
        let publishers: [AnyPublisher<(Int, KanvasCameraMedia?), Error>] = exports.enumerated().map { (index, export) in
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
        }).map({ (element) -> [Result<KanvasCameraMedia?, Error>] in
            return element.map { index, item in
                return .success(item)
            }
        })
        let result: AnyPublisher<[Result<KanvasCameraMedia?, Error>], Error> = collected.eraseToAnyPublisher()
        return result
//        return allPublishers.collect(exportCount).eraseToAnyPublisher()
//        publishers.forEach { publisher in
//            publishers.sin
//        }
    }

    func handle(export: EditorViewController.ExportResult) -> KanvasCameraMedia? {

        switch (export.result, export.original) {
        case (.image(let image), .image(let original)):
            if let url = image.save(info: export.info), let originalURL = original.save(info: export.info, in: self.saveDirectory) {
                print("Original image URL: \(originalURL)")
                return KanvasCameraMedia(image: image, url: url, original: originalURL, info: export.info)
            } else {
                return nil
            }
        case (.video(let url), .video(let original)):
//                    let originalURL =  saveDirectory.appendingPathComponent(url.lastPathComponent)
            print("Original video URL: \(original)")
//                    try? FileManager.default.removeItem(at: originalURL)
//                    try! FileManager.default.moveItem(at: original, to: originalURL)
            let asset = AVURLAsset(url: url)
            return KanvasCameraMedia(asset: asset, original: original, info: export.info)
        default:
            return nil
        }
    }
}
