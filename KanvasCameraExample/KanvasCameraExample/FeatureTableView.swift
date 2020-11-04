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
        case metalPreview(Bool)
        case cameraFilters(Bool)
        case metalFilters(Bool)
        case experimentalCameraFilters(Bool)
        case editor(Bool)
        case editorGIFMaker(Bool)
        case editorFilters(Bool)
        case editorText(Bool)
        case editorMedia(Bool)
        case editorDrawing(Bool)
        case mediaPicking(Bool)
        case editorSaving(Bool)
        case editorPosting(Bool)
        case editorPostOptions(Bool)
        case newCameraModes(Bool)
        case gifs(Bool)
        case editorShouldStartGIFMaker(Bool)
        case gifCameraShouldStartGIFMaker(Bool)
        case editToolsRedesign(Bool)
        case shutterButtonTooltip(Bool)
        case horizontalModeSelector(Bool)

        var name: String {
            switch self {
            case .ghostFrame(_):
                return "Camera Ghost Frame"
            case .openGLPreview(_):
                return "Camera OpenGL"
            case .openGLCapture(_):
                return "Camera OpenGL Capture"
            case .metalPreview(_):
                return "Camera Metal"
            case .cameraFilters(_):
                return "Camera Filters"
            case .metalFilters(_):
                return "Metal Filters"
            case .experimentalCameraFilters(_):
                return "Camera Filters (experimental)"
            case .editor(_):
                return "Editor"
            case .editorGIFMaker(_):
                return "Editor GIF Maker"
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
            case .gifs(_):
                return "GIF support"
            case .editorShouldStartGIFMaker:
                return "Editor auto-starts GIF Maker"
            case .gifCameraShouldStartGIFMaker:
                return "GIF Camera auto-starts Editor GIF Maker"
            case .editToolsRedesign(_):
                return "Edit Tools Redesign"
            case .shutterButtonTooltip(_):
                return "Shutter Button Tooltip"
            case .horizontalModeSelector(_):
                return "Horizontal Mode Selector"
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
            case .metalPreview(let enabled):
                return enabled
            case .cameraFilters(let enabled):
                return enabled
            case .metalFilters(let enabled):
                return enabled
            case .experimentalCameraFilters(let enabled):
                return enabled
            case .editor(let enabled):
                return enabled
            case .editorGIFMaker(let enabled):
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
            case .gifs(let enabled):
                return enabled
            case .editorShouldStartGIFMaker(let enabled):
                return enabled
            case .gifCameraShouldStartGIFMaker(let enabled):
                return enabled
            case .editToolsRedesign(let enabled):
                return enabled
            case .shutterButtonTooltip(let enabled):
                return enabled
            case .horizontalModeSelector(let enabled):
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
        case .metalPreview(_):
            featuresData[indexPath.row] = .metalPreview(value)
        case .metalFilters(_):
            featuresData[indexPath.row] = .metalFilters(value)
        case .cameraFilters(_):
            featuresData[indexPath.row] = .cameraFilters(value)
        case .experimentalCameraFilters(_):
            featuresData[indexPath.row] = .experimentalCameraFilters(value)
        case .editor(_):
            featuresData[indexPath.row] = .editor(value)
        case .editorGIFMaker(_):
            featuresData[indexPath.row] = .editorGIFMaker(value)
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
        case .gifs(_):
            featuresData[indexPath.row] = .gifs(value)
        case .editorShouldStartGIFMaker(_):
            featuresData[indexPath.row] = .editorShouldStartGIFMaker(value)
        case .gifCameraShouldStartGIFMaker(_):
            featuresData[indexPath.row] = .gifCameraShouldStartGIFMaker(value)
        case .editToolsRedesign(_):
            featuresData[indexPath.row] = .editToolsRedesign(value)
        case .shutterButtonTooltip(_):
            featuresData[indexPath.row] = .shutterButtonTooltip(value)
        case .horizontalModeSelector(_):
            featuresData[indexPath.row] = .horizontalModeSelector(value)
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
