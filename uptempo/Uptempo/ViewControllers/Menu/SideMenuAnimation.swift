import UIKit

class SideMenuInteractor: UIPercentDrivenInteractiveTransition {
    var hasStarted: Bool = false
    var shouldFinish: Bool = false
}

enum SideMenuSlideDirection {
    case Up
    case Down
    case Left
    case Right
}

class SideDismissMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let snapshot = transitionContext.containerView.viewWithTag(SideMenuHelper.snapshotTagNumber),
            let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            animations: {
                snapshot.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
        },
            completion: { _ in
                if !transitionContext.transitionWasCancelled {
                    transitionContext.containerView.insertSubview(toController.view, aboveSubview: fromController.view)
                    snapshot.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class SidePresentMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var direction: SideMenuSlideDirection

    init(direction: SideMenuSlideDirection) {
        self.direction = direction
    }

    func transitionDuration(using: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }

        // Insert the to controller view below the from view
        transitionContext.containerView.insertSubview(toController.view, belowSubview: fromController.view)

        // Create a snapshot (a picture) of current (from) view.
        let snapshot = fromController.view.snapshotView(afterScreenUpdates: false)!
        snapshot.tag = SideMenuHelper.snapshotTagNumber
        snapshot.isUserInteractionEnabled = false
        snapshot.layer.shadowOpacity = 0.7
        transitionContext.containerView.insertSubview(snapshot, aboveSubview: toController.view)
        fromController.view.isHidden = true

        if let createSessionController = toController as? CreateSessionMenuViewController {
            createSessionController.setCoverSnapshot(snapshot: snapshot)
        }

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            animations: {
                var distance = UIScreen.main.bounds.width * SideMenuHelper.menuWidthPercent
                if self.direction == .Right {
                    distance *= -1
                }

                snapshot.center.x += distance
        },
            completion: { _ in
                fromController.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

struct SideMenuHelper {
    static let menuWidthPercent: CGFloat = 0.6
    static let percentThreshold:CGFloat = 0.3
    static let snapshotTagNumber = 10001
}
