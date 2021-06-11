//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import os

/// A class to handle collecting export results.
/// TODO: Replace with a Combine version along with `MediaExport` refactor.
class MultiEditorExportHandler {
    
    typealias ExportResult = Result<EditorViewController.ExportResult, Error>
    
    init(_ completion: @escaping ([ExportResult]) -> Void) {
        self.completion = completion
    }
    
    private let completion: ([ExportResult]) -> Void
    
    /// Storage for the exported media as export occurs
    private var exports: [ExportResult?] = []
    
    private let logger = OSLog(subsystem: "com.tumblr.kanvas", category: "StoryExport")
    
    /// The count of media items we are waiting for
    private var waitingFor: Int?
    
    func startWaiting(for count: Int) {
        waitingFor = count
        exports = Array<ExportResult?>(repeating: nil, count: count)
    }
    
    func handleExport(_ result: ExportResult, for index: Int) {
        log(result: result, for: index)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.exports[index] = result
            let completedExports = self.exports.compactMap({ return $0 })
            if completedExports.count == self.waitingFor {
                self.completion(completedExports)
            }
        }
    }
    
    private func log(result: ExportResult, for index: Int) {
        switch result {
        case .success(let result):
            switch result.result {
            case .image(_):
                os_log("Exported image %d", log: logger, type: .debug, index)
            case .video(_):
                os_log("Exported video %d", log: logger, type: .debug, index)
            }
        case .failure:
            os_log("Failed export %d", log: logger, type: .error, index)
        }
    }
}
