//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import AVFoundation
import os
import UIKit

/// Saves `EditorViewController.ExportResult` to the directory specified by `saveDirectory`
class MediaArchiver {

    let saveDirectory: URL?

    private let log = OSLog(subsystem: "com.tumblr.kanvas", category: "MediaArchiver")

    /// Initializes a new MediaArchiver class to handle exports.
    /// - Parameter saveDirectory: A URL to save the files to.
    init(saveDirectory: URL?) {
        self.saveDirectory = saveDirectory
    }

    /// Handles a set of exports
    /// - Parameter exports: A set of `EditorViewController.ExportResult`s to save to disk.
    /// - Returns: A publisher which contains a set of resulting `KanvasMedia` or `Error` objects. Will emit the set after all media has been saved.
    func handle(exports: [EditorViewController.ExportResult?]) -> AnyPublisher<CameraController.MediaOutput, Error> {
        let exportCount = exports.count
        let publishers: [AnyPublisher<(Int, KanvasMedia?), Error>] = exports.enumerated().map { (index, export) in
            return Future { [weak self] promise in
                guard let self = self else { return }
                
                Task.detached(priority: .userInitiated) { [weak self] in
                    guard let export = export else {
                        promise(.success((index, nil)))
                        return
                    }
                    let media = self?.handle(export: export)
                    promise(.success((index, media)))
                }
            }.eraseToAnyPublisher()
        }
        
        let allPublishers = Publishers.MergeMany(publishers)
        let collected = allPublishers.collect(exportCount).sort(by: { (first, second) in
            return first.0 < second.0
        }).map({ (element) -> CameraController.MediaOutput in
            return element.map { index, item in
                return .success(item)
            }
        })
        let result: AnyPublisher<CameraController.MediaOutput, Error> = collected.eraseToAnyPublisher()
        return result
    }

    private func handle(export: EditorViewController.ExportResult) -> KanvasMedia? {
        switch (export.result, export.original) {
        case (.image(let image), .image(let original)):
            if let url = image.save(info: export.info) {
                let originalURL: URL?
                if let saveDirectory = saveDirectory {
                    originalURL = original.save(info: export.info, in: saveDirectory)
                    os_log(.debug, log: log, "Original image URL: %@", String(describing: originalURL))
                } else {
                    originalURL = nil
                }
                let archiveURL = self.archive(media: .image(original), archive: export.archive, to: url.deletingPathExtension().lastPathComponent)
                return KanvasMedia(image: image, url: url, original: originalURL, info: export.info, archive: archiveURL)
            } else {
                return nil
            }
        case (.video(let url), .video(let original)):
            let archiveURL = self.archive(media: .video(original), archive: export.archive, to: url.deletingPathExtension().lastPathComponent)
            os_log(.debug, log: log, "Original video URL: %@", original.absoluteString)
            let asset = AVURLAsset(url: url)
            return KanvasMedia(asset: asset, original: original, info: export.info, archive: archiveURL)
        default:
            return nil
        }
    }

    private func archive(media: EditorViewController.Media, archive data: Data, to path: String) -> URL? {

        let archive: Archive

        switch media {
        case .image(let image):
            archive = Archive(image: image, data: data)
        case .video(let url):
            archive = Archive(video: url, data: data)
        }

        let archiveURL: URL?
        if let saveDirectory = saveDirectory {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: archive, requiringSecureCoding: true)
                archiveURL = try data.save(to: path, in: saveDirectory, ext: "")
            } catch let error {
                archiveURL = nil
                print("Failed to archive \(error)")
            }
        } else {
            archiveURL = nil
        }

        return archiveURL
    }
}

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

private extension Publisher where Output: Sequence {
    typealias Sorter = (Output.Element, Output.Element) -> Bool

    func sort(
        by sorter: @escaping Sorter
    ) -> Publishers.Map<Self, [Output.Element]> {
        map { sequence in
            sequence.sorted(by: sorter)
        }
    }
}
