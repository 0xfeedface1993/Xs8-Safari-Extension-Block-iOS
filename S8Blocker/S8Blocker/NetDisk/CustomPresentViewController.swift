//
//  CustomPresentViewController.swift
//  TrainsitionFun
//
//  Created by virus1993 on 2017/12/18.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import CoreGraphics

class CustomPresentViewController: UIPresentationController {
    let cornerRadius : CGFloat = 16.0
    var _dimmingView : UIView?
    var _presentationWrappingView : UIView?
    override var presentedView: UIView? {
        return _presentationWrappingView
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
    }
    
    override func presentationTransitionWillBegin() {
        let presentedViewControllerView = super.presentedView
        
        let presentationWrappingView = UIView(frame: frameOfPresentedViewInContainerView)
        presentationWrappingView.layer.shadowOpacity = 0.44
        presentationWrappingView.layer.shadowOffset = CGSize(width: 0, height: -6.0)
        presentationWrappingView.layer.shadowRadius = 13.0
        
        _presentationWrappingView = presentationWrappingView
        
        let presentationRoundedCornerView = UIView(frame: UIEdgeInsetsInsetRect(presentationWrappingView.bounds, UIEdgeInsetsMake(0, 0, -cornerRadius, 0)))
        presentationRoundedCornerView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        presentationRoundedCornerView.layer.cornerRadius = cornerRadius
        presentationRoundedCornerView.layer.masksToBounds = true
        
        let presentatedViewControllerWrappingView = UIView(frame: UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, UIEdgeInsetsMake(0, 0, cornerRadius, 0)))
        presentatedViewControllerWrappingView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        
        presentedViewControllerView?.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        presentedViewControllerView?.frame = presentatedViewControllerWrappingView.bounds
        presentatedViewControllerWrappingView.addSubview(presentedViewControllerView!)
        
        presentationRoundedCornerView.addSubview(presentatedViewControllerWrappingView)
        
        presentationWrappingView.addSubview(presentationRoundedCornerView)
        
        let dimmingView = UIView(frame: containerView!.bounds)
        dimmingView.backgroundColor = .black
        dimmingView.isOpaque = false
        dimmingView.isUserInteractionEnabled = true
        dimmingView.autoresizingMask = UIViewAutoresizing.flexibleHeight.union(.flexibleWidth)
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingView(tap:))))
        _dimmingView = dimmingView
        containerView?.addSubview(dimmingView)
        
        let transistionCoordinate = presentingViewController.transitionCoordinator
        
        _dimmingView?.alpha = 0
        
        transistionCoordinate?.animate(alongsideTransition: { (context) in
            self._dimmingView?.alpha = 0.5
        }, completion: nil)
    }
    
    @objc func dimmingView(tap: UIGestureRecognizer){
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            _presentationWrappingView = nil
            _dimmingView = nil
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let transistionCoordinate = presentingViewController.transitionCoordinator
        
        transistionCoordinate?.animate(alongsideTransition: { (context) in
            self._dimmingView?.alpha = 0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            _presentationWrappingView = nil
            _dimmingView = nil
        }
    }
    
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if let containerPresented = container as? UIViewController, containerPresented == presentedViewController {
            containerView?.setNeedsLayout()
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let containerPresented = container as? UIViewController, containerPresented == presentedViewController {
            return containerPresented.preferredContentSize
        }   else    {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var contanierViewBounds: CGRect!
        if #available(iOS 11.0, *) {
            contanierViewBounds = CGRect(x: containerView!.safeAreaInsets.left, y: 0, width: containerView!.bounds.width - (containerView!.safeAreaInsets.right + containerView!.safeAreaInsets.left), height: containerView!.bounds.height)
        } else {
            // Fallback on earlier versions
            contanierViewBounds = containerView!.bounds
        }
        let presentedViewControllerFrame = contanierViewBounds
        return presentedViewControllerFrame!
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        _dimmingView?.frame = containerView!.bounds
        _presentationWrappingView?.frame = frameOfPresentedViewInContainerView
    }
}

extension CustomPresentViewController : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(presentedViewController == presented, "You didn't initialize \(self) with the correct presentedViewController.  Expected \(presented), got \(presentedViewController).")
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension CustomPresentViewController : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext!.isAnimated ? 0.45:0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let isPresenting = fromViewController == presentingViewController
        
        let fromVC = isPresenting ? fromViewController.view:toViewController.view
        let toVC = !isPresenting ? fromViewController.view:toViewController.view
        
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        
        if let t = toView {
            container.addSubview(t)
        }
        
        if isPresenting {
            prensentingAnimate(baseView: fromVC!, overView: toVC!, transitionContext: transitionContext)
        }   else    {
            dismissAnimate(baseView: fromVC!, overView: toVC!, transitionContext: transitionContext)
        }
    }
    
    
    func prensentingAnimate(baseView: UIView, overView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        baseView.layer.cornerRadius = 13.0
        baseView.transform = CGAffineTransform(scaleX: 1, y: 1)
        overView.transform = CGAffineTransform(translationX: 0, y: containerView!.bounds.maxY)
        baseView.window?.backgroundColor = .black
        baseView.layer.shadowOpacity = 0.44
        baseView.layer.shadowOffset = CGSize(width: 0, height: -6.0)
        baseView.layer.shadowRadius = 13.0
        
        UIView.animate(withDuration: 0.55, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: {
            baseView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            baseView.window?.backgroundColor = .white
        }) { (isFinished) in
            if isFinished {
                overView.transform = CGAffineTransform(translationX: 0, y: self.containerView!.bounds.maxY - 10)
                UIView.animate(withDuration: 0.30, animations: {
                    baseView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                    overView.transform = CGAffineTransform(translationX: 0, y: 0)
                    overView.superview?.superview?.layer.cornerRadius = 0
                }, completion: { (isFinished2) in
                    let wasCancelled = transitionContext.transitionWasCancelled
                    transitionContext.completeTransition(!wasCancelled)
                    if isFinished2 {
                        
                    }
                })
            }
        }
    }
    
    func dismissAnimate(baseView: UIView, overView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        baseView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        overView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        baseView.window?.backgroundColor = .white
        
        UIView.animate(withDuration: 0.30, animations: {
            overView.transform = CGAffineTransform(translationX: self.containerView!.bounds.maxX, y: 0)
        }, completion: { (isFinished2) in
            if isFinished2 {
                UIView.animate(withDuration: 0.55, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: {
                    baseView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: { (isFinished3) in
                    let wasCancelled = transitionContext.transitionWasCancelled
                    transitionContext.completeTransition(!wasCancelled)
                    if isFinished3 {
                        baseView.layer.cornerRadius = 0.0
                        baseView.window?.backgroundColor = .black
                    }
                })
            }
        })
    }
    
}
