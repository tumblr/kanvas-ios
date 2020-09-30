//
// Created by Tony Cheng on 8/8/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

import Foundation

private struct LoadingIndicatorConstants {
    static let backgroundColor = UIColor.black.withAlphaComponent(0.7)
    static let width: CGFloat = 50
    static let height = LoadingIndicatorConstants.width
}

/// Loading indicator view. Right now it contains just a regular activity indicator,
/// but it will eventually be replaced with a custom animation
final class LoadingIndicatorView: UIView {

    private let indicator = UIActivityIndicatorView(style: .whiteLarge)
    
    var indicatorColor: UIColor {
        set { indicator.color = newValue }
        get { return indicator.color }
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = LoadingIndicatorConstants.backgroundColor
        addSubview(indicator)
        setupConstraints()
    }

    private func setupConstraints() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: LoadingIndicatorConstants.width),
            indicator.heightAnchor.constraint(equalToConstant: LoadingIndicatorConstants.height)
        ])
    }

    // MARK: - Play and Stop
    
    /// Starts the loading animation
    func startLoading() {
        indicator.startAnimating()
    }

    /// Stops the loading animation
    func stopLoading() {
        indicator.stopAnimating()
    }
}
