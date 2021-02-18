import UIKit

/// A type which displays a media picker and calls the `delegate` with any received media.
public protocol MediaPicker {
    /// Presents the Media Picker UI
    /// - Parameters:
    ///   - on: The view controller to present on.
    ///   - settings: The `CameraSettings` which Kanvas has been started with.
    ///   - delegate: A delegate which will receive the media.
    ///   - completion: The completion to call upon presentation.
    static func present(on: UIViewController, with settings: CameraSettings, delegate: KanvasMediaPickerViewControllerDelegate, completion: @escaping () -> Void)
}
