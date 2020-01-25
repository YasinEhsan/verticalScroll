//
//  BottomSheetViewController.swift
//  verticalScroll
//
//  Created by Yasin Ehsan on 1/25/20.
//  Copyright © 2020 Yasin Ehsan. All rights reserved.
//

import UIKit

class BottomSheetViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionViewOne: UICollectionView!
    @IBOutlet weak var navBarView: UIView!
    
        let closeThresholdHeight: CGFloat = 100
        let openThreshold: CGFloat = UIScreen.main.bounds.height - 200
        let closeThreshold = UIScreen.main.bounds.height - 100 // same value as closeThresholdHeight
        var panGestureRecognizer: UIPanGestureRecognizer?
        var animator: UIViewPropertyAnimator?

        private var lockPan = false
    
        var dataSource1: [String] = ["yas", "tas", "yas", "tas", "yas", "tas", "yas", "tas"]

        override func viewDidLoad() {
            
            collectionViewOne.dataSource = self
            
            
            
            gotPanned(0)
            super.viewDidLoad()

            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(respondToPanGesture))
            view.addGestureRecognizer(gestureRecognizer)
            gestureRecognizer.delegate = self
            panGestureRecognizer = gestureRecognizer
        }

        func gotPanned(_ percentage: Int) {
            if animator == nil {
                animator = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: {
                    let scaleTransform = CGAffineTransform(scaleX: 1, y: 5).concatenating(CGAffineTransform(translationX: 0, y: 240))
                                    
                    //                self.navBarView.alpha = 0                    self.navBarView.transform = scaleTransform
                })
                animator?.isReversed = true
                animator?.startAnimation()
                animator?.pauseAnimation()
            }
            animator?.fractionComplete = CGFloat(percentage) / 100
        }

        // MARK: methods to make the view draggable

        @objc func respondToPanGesture(recognizer: UIPanGestureRecognizer) {
            guard !lockPan else { return }
            if recognizer.state == .ended {
                let maxY = UIScreen.main.bounds.height - CGFloat(openThreshold)
                lockPan = true
                if maxY > self.view.frame.minY {
                    maximize { self.lockPan = false }
                } else {
                    minimize { self.lockPan = false }
                }
                return
            }
            let translation = recognizer.translation(in: self.view)
            moveToY(self.view.frame.minY + translation.y)
            recognizer.setTranslation(.zero, in: self.view)
        }

        func maximize(completion: (() -> Void)?) {
            UIView.animate(withDuration: 0.2, animations: {
                self.moveToY(0)
            }) { _ in
                if let completion = completion {
                    completion()
                }
            }
        }

        func minimize(completion: (() -> Void)?) {
            UIView.animate(withDuration: 0.2, animations: {
                self.moveToY(self.closeThreshold - 100)
            }) { _ in
                if let completion = completion {
                    completion()
                }
            }
        }

        private func moveToY(_ position: CGFloat) {
            view.frame = CGRect(x: 0, y: position, width: view.frame.width, height: view.frame.height)

            let maxHeight = view.frame.height - closeThresholdHeight
            let percentage = Int(100 - ((position * 100) / maxHeight))

            gotPanned(percentage)

            let name = NSNotification.Name(rawValue: "BottomViewMoved")
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["percentage": percentage])
        }
}

extension BottomSheetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource1.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellOne", for: indexPath) as! OneCollectionViewCell
        cell.setLabel(dataSource1[indexPath.row])
        return cell
        
    }
}
