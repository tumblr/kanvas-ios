//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreTumblr
import TMTumblrSDK

/// Constants for KanvasStickerProvider
private struct Constants {
    static let stickerPackEndpoint = "stickerpacks"
}

/// Sticker provider to be used in Orangina
public final class KanvasStickerProvider: StickerProvider {

    private weak var delegate: StickerProviderDelegate?
    private let session: TMSession
    
    public init(session: TMSession) {
        self.session = session
    }
    
    // MARK: - StickerProvider
    
    public func setDelegate(delegate: StickerProviderDelegate) {
        self.delegate = delegate
    }
    
    public func getStickerTypes() {
        let urlDeterminer = BaseURLDeterminer(urlProvider: TMSettingsAppReader(userDefaults: UserDefaults.standard))
        guard let baseURL = urlDeterminer.baseURL() else {
            delegate?.didLoadStickerTypes([])
            return
        }

        let request = TMAPIRequest(baseURL: baseURL, method: .GET, path: Constants.stickerPackEndpoint, queryParameters: nil)
        
        let requestSender = RequestSender(request: request, session: session, notificationCenter: NotificationCenter.default, responseConverter: KanvasStickerTypeResponseConverter(), parserDelegate: NoOpResponseParserDelegate())
        
        requestSender.start { [weak self] result in

            DispatchQueue.main.async(execute: {
                switch result {
                case .error:
                    self?.delegate?.didLoadStickerTypes([])
                case .value(let types):
                    self?.delegate?.didLoadStickerTypes(types)
                }
            })
        }
    }
}
