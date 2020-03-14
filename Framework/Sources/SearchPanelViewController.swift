//
//  SearchContentController.swift
//  ECardCore
//
//  Created by KEVIN CAO on 2018/12/22.
//  Copyright © 2018 KEVIN CAO. All rights reserved.
//

import Foundation
//import FloatingPanel
import SnapKit

//
// This is the DELEGATE PROTOCOL
//
@objc public protocol SearchPanelViewControllerDelegate {
    // Classes that adopt this protocol MUST define
    // this method -- and hopefully do something in
    // that definition.
    @objc func closeSearching(_ sender:UISearchBar)
}


@objc public class SearchPanelViewController  : UIViewController, UISearchBarDelegate, FloatingPanelControllerDelegate {
    
    @objc public var searchBar: UISearchBar!
    @objc public var visualEffectView: UIVisualEffectView!
    @objc public var fpc: FloatingPanelController!
    @objc public var contentView: UIView!
    @objc public var delegate:SearchPanelViewControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        visualEffectView = UIVisualEffectView()
        self.view.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { (maker) in
            maker.top.bottom.left.right.equalToSuperview()
        }
        
        searchBar = UISearchBar()
        searchBar.frame = CGRect.zero
        visualEffectView.contentView.addSubview(searchBar)
        searchBar.placeholder = "Search for a sticker"
        searchBar.showsCancelButton = false
        self.definesPresentationContext = true
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        let textField = searchBar.searchTextField
        textField.font = UIFont(name: textField.font!.fontName, size: 15.0)
        searchBar.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(50)
            maker.top.equalTo(17 /*FloatingPanelSurfaceView.topGrabberBarHeight*/)
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fpc?.delegate = self
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 10, *) {
            visualEffectView.layer.cornerRadius = 9.0
            visualEffectView.clipsToBounds = true
        }
    }
    
    // MARK: FloatingPanelControllerDelegate
    
    public func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        switch newCollection.verticalSizeClass {
        case .compact:
            fpc?.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
            fpc?.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
            return SearchPanelLandscapeLayout()
        default:
            fpc?.surfaceView?.borderWidth = 0.0
            fpc?.surfaceView?.borderColor = nil
            return nil
        }
    }
    
    public func floatingPanelDidMove(_ vc: FloatingPanelController) {
        let y = vc.surfaceView.frame.origin.y
        let tipY = vc.originYOfSurface(for: .tip)
        if y > tipY - 44.0 {
            let progress = max(0.0, min((tipY  - y) / 44.0, 1.0))
            self.contentView?.alpha = progress
        }
    }
    
    public func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.position == .full {
            self.searchBar?.showsCancelButton = false
            self.searchBar?.resignFirstResponder()
        }
    }
    
    func showHeader() {
    //    changeHeader(height: 116.0)
    }
    
    func hideHeader() {
    //    changeHeader(height: 0.0)
    }

    
    public func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if targetPosition != .full {
             self.hideHeader()
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if targetPosition == .tip {
                            self.contentView?.alpha = 0.0
                        } else {
                            self.contentView?.alpha = 1.0
                        }
        }, completion: nil)
    }
   
}

public class SearchPanelLandscapeLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0
        case .tip: return 69.0
        default: return nil
        }
    }
    
    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        } else {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        }
    }
    
    public func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}

