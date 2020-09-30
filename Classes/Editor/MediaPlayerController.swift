//
//  MediaPlayerController.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 07/02/2020.
//

import Foundation

/// Protocol for the editor and preview controller
protocol MediaPlayerController: UIViewController {
    /// Called when the Posting Options view is dismissed.
    func onPostingOptionsDismissed()
}
