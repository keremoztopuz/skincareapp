//
//  InteractiveSwipeBack.swift
//  SkinCare
//

import SwiftUI
import UIKit

// MARK: - Pushed screens

/// Allows the edge-swipe pop whenever there is something to pop.
///
/// One shared instance because `UIGestureRecognizer.delegate` is weak: a
/// per-screen delegate would be released on the way out, leaving the gesture
/// unguarded — which is the root-screen freeze this guards against.
private final class SwipeBackGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    static let shared = SwipeBackGestureDelegate()

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let nav = gestureRecognizer.view?.next as? UINavigationController else { return false }
        // Swiping on the first screen wedges UINavigationController, and a
        // second gesture mid-transition leaves the stack out of sync with
        // SwiftUI's path.
        return nav.viewControllers.count > 1 && nav.transitionCoordinator == nil
    }
}

/// Finds the hosting navigation controller and hands its pop gesture back to
/// the delegate above. Draws nothing.
private struct SwipeBackEnabler: UIViewControllerRepresentable {
    final class Host: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard let gesture = navigationController?.interactivePopGestureRecognizer,
                  gesture.delegate !== SwipeBackGestureDelegate.shared else { return }
            gesture.delegate = SwipeBackGestureDelegate.shared
        }
    }

    func makeUIViewController(context: Context) -> Host { Host() }
    func updateUIViewController(_ uiViewController: Host, context: Context) {}
}

extension View {
    /// Restores swipe-from-edge-to-go-back on a pushed screen that hides the
    /// system back button.
    ///
    /// UIKit ties `interactivePopGestureRecognizer` to the navigation bar's
    /// back button, so `.navigationBarBackButtonHidden(true)` — which every
    /// screen drawing its own `BackHeaderBar` needs — installs a delegate that
    /// refuses the gesture. SwiftUI's `NavigationStack` inherits that.
    ///
    /// Outside a navigation stack there is no navigation controller to reach,
    /// so this is a no-op — safe on screens that are also presented modally.
    func interactiveSwipeBack() -> some View {
        background(SwipeBackEnabler().frame(width: 0, height: 0))
    }
}

// MARK: - Full-screen covers

/// Installs a real `UIScreenEdgePanGestureRecognizer` on the presented
/// screen's root view.
///
/// A SwiftUI overlay strip would have been shorter, but `Color.clear` is
/// hit-testable: a transparent strip down the leading edge swallows taps on
/// everything under it, and the result screen's cards run full-width. A UIKit
/// recognizer is invisible to hit testing until it actually recognizes, and it
/// yields to a vertical drag on its own, so scrolling survives.
private struct EdgeDismissInstaller: UIViewControllerRepresentable {
    @Binding var offset: CGFloat
    let onDismiss: () -> Void

    private static let dismissThreshold: CGFloat = 90
    private static let flickVelocity: CGFloat = 800

    final class Coordinator: NSObject {
        var offset: (CGFloat) -> Void = { _ in }
        var settle: (Bool) -> Void = { _ in }

        @objc func handlePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view).x
            switch gesture.state {
            case .changed:
                offset(max(0, translation))
            case .ended:
                let velocity = gesture.velocity(in: gesture.view).x
                settle(translation > EdgeDismissInstaller.dismissThreshold
                       || velocity > EdgeDismissInstaller.flickVelocity)
            case .cancelled, .failed:
                settle(false)
            default:
                break
            }
        }
    }

    final class Host: UIViewController {
        var attach: (UIView) -> Void = { _ in }
        private var isAttached = false

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard !isAttached else { return }
            // The cover's own hosting controller, not this zero-sized child:
            // the gesture has to span the whole screen, and this view is
            // carried along by the offset it drives.
            var root: UIViewController = self
            while let parent = root.parent { root = parent }
            isAttached = true
            attach(root.view)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> Host {
        let host = Host()
        let coordinator = context.coordinator
        coordinator.offset = { offset = $0 }
        coordinator.settle = { shouldDismiss in
            if shouldDismiss {
                // No exit animation of our own: the cover plays its own, and
                // running both makes the content jump.
                onDismiss()
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    offset = 0
                }
            }
        }
        host.attach = { view in
            let pan = UIScreenEdgePanGestureRecognizer(
                target: coordinator,
                action: #selector(Coordinator.handlePan(_:))
            )
            pan.edges = .left
            view.addGestureRecognizer(pan)
        }
        return host
    }

    func updateUIViewController(_ uiViewController: Host, context: Context) {}
}

/// Drag-from-the-left-edge to dismiss, for screens presented as a
/// `.fullScreenCover` — those carry no dismissal gesture of their own.
private struct EdgeSwipeToDismiss: ViewModifier {
    /// The presenter clears its own flag: `ResultView`'s single-dismissal rule
    /// stays in one place rather than being reimplemented here.
    let onDismiss: () -> Void

    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .background(
                EdgeDismissInstaller(offset: $offset, onDismiss: onDismiss)
                    .frame(width: 0, height: 0)
            )
    }
}

extension View {
    /// Adds swipe-from-the-left-edge dismissal to full-screen cover content.
    func edgeSwipeToDismiss(onDismiss: @escaping () -> Void) -> some View {
        modifier(EdgeSwipeToDismiss(onDismiss: onDismiss))
    }
}
