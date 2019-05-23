//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/**
 Identifies an element.

 By default, it uses the type's simple name;
 except for NibLoadable components, it uses the nibname.
 */
public protocol Identifiable {

    static var identifier: String { get }

}

public extension Identifiable {

    static var identifier: String {
        return String(describing: self)
    }

}

extension UITableViewCell: Identifiable { }
extension UICollectionReusableView: Identifiable { }
extension UITableViewHeaderFooterView: Identifiable { }

public extension UICollectionView {

    /**
     Registers a cell to be used by a UICollectionView.

     - parameter cellType: A nibloadable collection view cell type
     to take the identifier and nib from.
     */
    func register<T: UICollectionViewCell>(cell cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.identifier)
    }

    /**
     Registers a header to be used by a UICollectionView.

     - parameter headerType: A nibloadable reusable view type
     to take the identifier and nib from.
     */
    func register<T: UICollectionReusableView>(header headerType: T.Type) {
        register(headerType,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: headerType.identifier)
    }

    /**
     Registers a footer to be used by a UICollectionView.

     - parameter footerType: A nibloadable reusable view type
     to take the identifier and nib from.
     */
    func register<T: UICollectionReusableView>(footer footerType: T.Type) {
        register(footerType,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: footerType.identifier)
    }

    /**
     Returns a reusable cell of the type specified to be used and adds it
     to the UICollectionView in the indexPath specified.

     - parameter cellType: A collection cell to take the identifier from.
     - parameter indexPath: IndexPath where to add the cell to the collection view.
     */
    func dequeue<T: UICollectionViewCell>(cell cellType: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath) as? T
    }

    /**
     Returns a reusable header of the type specified to be used and adds it
     to the UICollectionView in the indexPath specified.

     - parameter headerType: A collection reusable header view to take the identifier from.
     */
    func dequeue<T: UICollectionReusableView>(header headerType: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                withReuseIdentifier: headerType.identifier,
                                                for: indexPath) as? T
    }

    /**
     Returns a reusable footer of the type specified to be used and adds it
     to the UICollectionView in the indexPath specified.

     - parameter footerType: AA collection reusable footer view to take the identifier from.
     */
    func dequeue<T: UICollectionReusableView>(footer footerType: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                withReuseIdentifier: footerType.identifier,
                                                for: indexPath) as? T
    }

    func dequeue<T: UICollectionReusableView>(view viewType: T.Type, ofKind kind: String, for indexPath: IndexPath) -> T? {
        return dequeueReusableSupplementaryView(ofKind: kind,
                                                withReuseIdentifier: viewType.identifier,
                                                for: indexPath) as? T
    }

}
