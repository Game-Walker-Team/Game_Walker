//
//  OverlayViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 8/31/23.
//

import Foundation
import UIKit

class OverlayViewController: UIViewController {
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var closeBtn: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(OverlayViewController.self, action: #selector(dismissOverlay), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlayView()
        //setupTapGesture()
    }
    
    private func setupOverlayView() {
        view.addSubview(overlayView)
        overlayView.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeBtn.widthAnchor.constraint(equalToConstant: 44),
            closeBtn.heightAnchor.constraint(equalToConstant: 44),
            closeBtn.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 30),
            closeBtn.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -35)
        ])
    }
    
    private func setupTapGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
            overlayView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissOverlay() {
        dismiss(animated: true, completion: nil)
    }

    func showExplanationLabels(explanationTexts: [String], componentPositions: [CGPoint], numberOfLabels: Int, tabBarTop: CGFloat) {
        guard explanationTexts.count >= numberOfLabels,
              componentPositions.count >= numberOfLabels else {
            fatalError("Not enough explanation texts or component frames provided.")
        }
        
        for i in 0..<numberOfLabels {
            let explanationLbl = UILabel()
            explanationLbl.translatesAutoresizingMaskIntoConstraints = false
            explanationLbl.text = explanationTexts[i]
            explanationLbl.numberOfLines = 0
            explanationLbl.textAlignment = .center
            explanationLbl.textColor = .white
            explanationLbl.font = UIFont(name: "Dosis-Bold", size: 15)
            overlayView.addSubview(explanationLbl)
            var maxWidth: CGFloat = 0
            // Set maximum width constraint
            if (componentPositions[i].y >= tabBarTop) {
                maxWidth = 75
            } else {
                maxWidth = 200
            }
            explanationLbl.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
            
            NSLayoutConstraint.activate([
                explanationLbl.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: componentPositions[i].x),
                explanationLbl.bottomAnchor.constraint(equalTo: overlayView.topAnchor, constant: componentPositions[i].y - 15)
            ])
        }
    }
}
