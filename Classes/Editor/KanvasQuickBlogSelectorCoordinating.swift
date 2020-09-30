//
//  KanvasQuickBlogSelectorCoordinating.swift
//  KanvasCamera
//
//  Created by Jimmy Schementi on 1/15/20.
//

import Foundation

public protocol KanvasQuickBlogSelectorCoordinating {

    func present(presentingView: UIView, fromPoint: CGPoint)

    func dismiss()

    func touchDidMoveToPoint(_ location: CGPoint)

    func avatarView(frame: CGRect) -> UIView?

}
