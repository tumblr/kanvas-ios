//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol FeatureTableViewDelegate: class {
    func featureTableViewLoadFeatures() -> [FeatureTableView.KanvasFeature]
    func featureTableView(didUpdateFeature feature: FeatureTableView.KanvasFeature, withValue value: Bool)
}

class FeatureTableView: UIView, UITableViewDelegate, UITableViewDataSource, FeatureTableViewCellDelegate {

    enum KanvasFeature {
        case ghostFrame(Bool)
        case openGLPreview(Bool)
        case openGLCapture(Bool)
        case cameraFilters(Bool)
        case experimentalCameraFilters(Bool)
        case editor(Bool)
        case editorGif(Bool)
        case editorGifToggle(Bool)
        case editorFilters(Bool)
        case editorText(Bool)
        case editorMedia(Bool)
        case editorDrawing(Bool)
        case mediaPicking(Bool)
        case editorSaving(Bool)
        case editorPosting(Bool)
        case editorPostOptions(Bool)
        case newCameraModes(Bool)

        var name: String {
            switch self {
            case .ghostFrame(_):
                return "Camera Ghost Frame"
            case .openGLPreview(_):
                return "Camera OpenGL"
            case .openGLCapture(_):
                return "Camera OpenGL Capture"
            case .cameraFilters(_):
                return "Camera Filters"
            case .experimentalCameraFilters(_):
                return "Camera Filters (experimental)"
            case .editor(_):
                return "Editor"
            case .editorGif(_):
                return "Editor GIF"
            case .editorGifToggle(_):
                return "Editor GIF as Toggle"
            case .editorFilters(_):
                return "Editor Filters"
            case .editorText(_):
                return "Editor Text"
            case .editorMedia(_):
                return "Editor Media"
            case .editorDrawing(_):
                return "Editor Drawing"
            case .mediaPicking(_):
                return "Media Picking"
            case .editorPosting(_):
                return "Editor Posting"
            case .editorSaving(_):
                return "Editor Saving"
            case .newCameraModes(_):
                return "New Camera Modes"
            case .editorPostOptions(_):
                return "Editor Post Options"
            }
        }

        var enabled: Bool {
            switch self {
            case .ghostFrame(let enabled):
                return enabled
            case .openGLPreview(let enabled):
                return enabled
            case .openGLCapture(let enabled):
                return enabled
            case .cameraFilters(let enabled):
                return enabled
            case .experimentalCameraFilters(let enabled):
                return enabled
            case .editor(let enabled):
                return enabled
            case .editorGif(let enabled):
                return enabled
            case .editorGifToggle(let enabled):
                return enabled
            case .editorFilters(let enabled):
                return enabled
            case .editorText(let enabled):
                return enabled
            case .editorMedia(let enabled):
                return enabled
            case .editorDrawing(let enabled):
                return enabled
            case .mediaPicking(let enabled):
                return enabled
            case .editorSaving(let enabled):
                return enabled
            case .editorPosting(let enabled):
                return enabled
            case .newCameraModes(let enabled):
                return enabled
            case .editorPostOptions(let enabled):
                return enabled
            }
        }
    }

    private struct Constants {
        static let featureCellReuseIdentifier = "featureCell"
    }

    private let featuresTable = UITableView(frame: .zero)

    weak var delegate: FeatureTableViewDelegate?

    private lazy var featuresData: [KanvasFeature] = {
        return delegate?.featureTableViewLoadFeatures() ?? []
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFeatureTable()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupFeatureTable() {
        // table view
        featuresTable.delegate = self
        featuresTable.dataSource = self
        featuresTable.translatesAutoresizingMaskIntoConstraints = false
        featuresTable.register(FeatureTableViewCell.self, forCellReuseIdentifier: Constants.featureCellReuseIdentifier)
        addSubview(featuresTable)
        NSLayoutConstraint.activate([
            featuresTable.topAnchor.constraint(equalTo: topAnchor),
            featuresTable.bottomAnchor.constraint(equalTo: bottomAnchor),
            featuresTable.leftAnchor.constraint(equalTo: leftAnchor),
            featuresTable.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

    private func updateFeaturesData(value: Bool, indexPath: IndexPath) {
        switch featuresData[indexPath.row] {
        case .ghostFrame(_):
            featuresData[indexPath.row] = .ghostFrame(value)
        case .openGLPreview(_):
            featuresData[indexPath.row] = .openGLPreview(value)
        case .openGLCapture(_):
            featuresData[indexPath.row] = .openGLCapture(value)
        case .cameraFilters(_):
            featuresData[indexPath.row] = .cameraFilters(value)
        case .experimentalCameraFilters(_):
            featuresData[indexPath.row] = .experimentalCameraFilters(value)
        case .editor(_):
            featuresData[indexPath.row] = .editor(value)
        case .editorGif(_):
            featuresData[indexPath.row] = .editorGif(value)
        case .editorGifToggle(_):
            featuresData[indexPath.row] = .editorGifToggle(value)
        case .editorFilters(_):
            featuresData[indexPath.row] = .editorFilters(value)
        case .editorText(_):
            featuresData[indexPath.row] = .editorText(value)
        case .editorMedia(_):
            featuresData[indexPath.row] = .editorMedia(value)
        case .editorDrawing(_):
            featuresData[indexPath.row] = .editorDrawing(value)
        case .mediaPicking(_):
            featuresData[indexPath.row] = .mediaPicking(value)
        case .editorPosting(_):
            featuresData[indexPath.row] = .editorPosting(value)
        case .editorSaving(_):
            featuresData[indexPath.row] = .editorSaving(value)
        case .newCameraModes(_):
            featuresData[indexPath.row] = .newCameraModes(value)
        case .editorPostOptions(_):
            featuresData[indexPath.row] = .editorPostOptions(value)
        }
        delegate?.featureTableView(didUpdateFeature: featuresData[indexPath.row], withValue: value)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featuresData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.featureCellReuseIdentifier, for: indexPath)
        guard let featureCell = cell as? FeatureTableViewCell else {
            return cell
        }
        featureCell.indexPath = indexPath
        featureCell.delegate = self
        featureCell.textLabel?.text = featuresData[indexPath.row].name
        featureCell.toggleSwitch(featuresData[indexPath.row].enabled, animated: false)
        return featureCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeatureTableViewCell else {
            return
        }
        let newValue = !featuresData[indexPath.row].enabled
        cell.toggleSwitch(newValue, animated: true)
        updateFeaturesData(value: newValue, indexPath: indexPath)
    }

    func featureTableViewCell(didToggle value: Bool, indexPath: IndexPath) {
        updateFeaturesData(value: value, indexPath: indexPath)
    }
}

protocol FeatureTableViewCellDelegate: class {
    func featureTableViewCell(didToggle value: Bool, indexPath: IndexPath)
}

private class FeatureTableViewCell: UITableViewCell {

    private let switchView: UISwitch = UISwitch(frame: .zero)

    var indexPath: IndexPath?

    weak var delegate: FeatureTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        switchView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(switchView)
        switchView.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        switchView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        switchView.addTarget(self, action: #selector(switchTouchUpInside), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func switchTouchUpInside() {
        guard let indexPath = indexPath else { return }
        delegate?.featureTableViewCell(didToggle: switchView.isOn, indexPath: indexPath)
    }

    func toggleSwitch(_ value: Bool, animated: Bool) {
        switchView.setOn(value, animated: animated)
    }
}
