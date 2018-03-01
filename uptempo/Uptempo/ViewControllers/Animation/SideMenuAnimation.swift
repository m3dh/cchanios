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

    static func mapGestureStateToInteractor(gestureState:UIGestureRecognizerState, progress:CGFloat, interactor: SideMenuInteractor?, triggerSegue: () -> Void){
        guard let interactor = interactor else { return }
        switch gestureState {
        case .began:
            interactor.hasStarted = true
            triggerSegue()
        case .changed:
            interactor.shouldFinish = progress > self.percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }

    static func calculateProgress(translationInView: CGPoint, viewBounds: CGRect, direction: SideMenuSlideDirection) -> CGFloat {
        let pointOnAxis:CGFloat
        let axisLength:CGFloat
        switch direction {
        case .Up, .Down:
            pointOnAxis = translationInView.y
            axisLength = viewBounds.height
        case .Left, .Right:
            pointOnAxis = translationInView.x
            axisLength = viewBounds.width
        }

        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis:Float
        let positiveMovementOnAxisPercent:Float
        switch direction {
        case .Right, .Down: // positive
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        case .Up, .Left: // negative
            positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
            return CGFloat(-positiveMovementOnAxisPercent)
        }
    }
}
