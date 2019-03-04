//
//  ScrollView.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//

import Tokamak
import UIKit

final class TokamakScrollView: UIView, Default {
  static var defaultValue: UIView {
//    return TokamakScrollView()
    let view = UIView()
    let vw = UIButton(type: UIButton.ButtonType.system)
    vw.setTitle("Button", for: [])
    view.addSubview(vw)
    return view
  }
}

extension ScrollView: UIViewComponent {
    static func update(view box: ViewBox<TokamakScrollView>, _ props: ScrollView.Props, _ children: AnyNode) {
        <#code#>
    }
    
    static func box(for view: TokamakScrollView, _ viewController: UIViewController, _ component: UIKitRenderer.MountedHost, _ renderer: UIKitRenderer) -> ViewBox<TokamakScrollView> {
        <#code#>
    }
    
    static func mountTarget(to parent: UITarget, component: UIKitRenderer.MountedHost, _ renderer: UIKitRenderer) -> UITarget? {
        
    }
    
    static func update(target: UITarget, node: AnyNode) {
        
    }
    
    static func unmount(target: UITarget, completion: @escaping () -> ()) {
        
    }
    
    
//    static func box(
//        for view: TokamakTableView,
//        _ viewController: UIViewController,
//        _ component: UIKitRenderer.MountedHost,
//        _ renderer: UIKitRenderer
//        ) -> ViewBox<TokamakScrollView> {
//        guard let props = component.node.props.value as? Props else {
//            fatalError("incorrect props type stored in ListView node")
//        }
//        let view = UIView()
//        let vw = UIButton(type: UIButton.ButtonType.system)
//        vw.setTitle("Button", for: [])
//        view.addSubview(vw)
////        return view
//        return ViewBox(view, <#UIViewController#>)
//    }
    
  static func update(view box: ViewBox<UIView>, _ props: ScrollView.Props, _ children: AnyNode) {
    let view = UIView()
            let vw = UIButton(type: UIButton.ButtonType.system)
            vw.setTitle("Button", for: [])
            view.addSubview(vw)
//        let view = box.view
//    let scroll = UIScrollView()
//    scroll.translatesAutoresizingMaskIntoConstraints = false
//    scroll.backgroundColor = UIColor.red
//    view.contentSize = CGSize(Size(width: 100.0, height: 100.0))
//    view.isScrollEnabled = true
//    view.minimumZoomScale = 1.0
//    view.maximumZoomScale = 10.0//maximum zoom scale you want
//    view.zoomScale = 1.0
//    view.alwaysBounceVertical = false
//    view.alwaysBounceHorizontal = false
//    view.showsVerticalScrollIndicator = true
//    view.flashScrollIndicators()
    // Auto layout
//    view.leftAnchor.constraint(equalTo: view.leftAnchor, constant:0).isActive = true
//    view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
//    view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
//    view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
//    view.addConstraints([NSLayoutConstraint.init(item: Any, attribute: <#T##NSLayoutConstraint.Attribute#>, relatedBy: <#T##NSLayoutConstraint.Relation#>, toItem: <#T##Any?#>, attribute: <#T##NSLayoutConstraint.Attribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>)])
//    let screenSize: CGRect = UIScreen.main.bounds
//    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": children]))
//    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": children]))
//    view.contentSize = CGSize(width: screenSize.width, height: screenSize.height)
//    view.frame = CGRect(x: 0, y: 70, width: screenSize.width, height: screenSize.height-70)
//    view.backgroundColor = UIColor.clear
//        view.translatesAutoresizingMaskIntoConstraints = false
    ////        view..addSubview(scrollView)
//        view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
//        view.
//        var stackView: UIStackView!
//        stackView = UIStackView()

//        view.translatesAutoresizingMaskIntoConstraints = false
    ////        view.axis = .vertical
//        view.addSubview(stackView)
//
//
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
//
//        for _ in 1 ..< 100 {
//            let vw = UIButton(type: UIButton.ButtonType.system)
//            vw.setTitle("Button", for: [])
//            stackView.addArrangedSubview(vw)
//        }

//        let vw = UIButton(type: UIButton.ButtonType.system)
//        vw.setTitle("Button", for: [])
//        view.addSubview(vw)
  }

  public typealias RefTarget = UIScrollView
}
