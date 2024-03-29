//
//  LaunchScreenController.swift
//  Game_Walker
//
//  Created by 김현식 on 2/13/23.
//

import Foundation
import UIKit
import AVFoundation

class LaunchScreenController: UIViewController {
    
    private let audioPlayerManager = AudioPlayerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black;
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.addRectangles()
        }
    }
    
    func addRectangles() {
        self.audioPlayerManager.playAudioFile(named: "LaunchScreenMusic", withExtension: "wav")
        let screenSize = UIScreen.main.bounds.size
        let rectangleWidth = screenSize.width
        let rectangleHeight = screenSize.height/4
        let rectangleViews = [
            UIView(frame: CGRect(x: 0, y: 0, width: rectangleWidth, height: rectangleHeight)),
            UIView(frame: CGRect(x: 0, y: rectangleHeight, width: rectangleWidth, height: rectangleHeight)),
            UIView(frame: CGRect(x: 0, y: rectangleHeight*2, width: rectangleWidth, height: rectangleHeight)),
            UIView(frame: CGRect(x: 0, y: rectangleHeight*3, width: rectangleWidth, height: rectangleHeight))
        ]
        let colors = [
            UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1),
            UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1),
            UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1),
            UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        ]
        let words = ["LET", "THERE", "BE", "LIGHT"]
        addRectangle(at: 0, rectangleViews: rectangleViews, colors: colors, words: words)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.view.backgroundColor = .white
            self.addWords()
        }
    }
    
    func addRectangle(at index: Int, rectangleViews: [UIView], colors: [UIColor], words: [String]) {
        let rectangleView = rectangleViews[index]
        rectangleView.backgroundColor = colors[index]
        let label = UILabel(frame: rectangleView.bounds)
        label.text = words[index]
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: fontSize(size: 50))
        label.textColor = .white
        rectangleView.addSubview(label)
        self.view.addSubview(rectangleView)
        
        UIView.animate(withDuration: 0.45, animations: {
            rectangleView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.45, animations: {
                rectangleView.alpha = 0.0
            }, completion: { _ in
                rectangleView.removeFromSuperview()
                if index < colors.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                        self.addRectangle(at: index+1, rectangleViews: rectangleViews, colors: colors, words: words)
                    }
                }
            })
        })
    }
    
    func addWords() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 295, height: 44))
        label.backgroundColor = .white
        let myString = "LET THERE BE LIGHT"
        let attributedString = NSMutableAttributedString(string: myString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1), range: NSRange(location: 0, length: 3))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1), range: NSRange(location: 4, length: 5))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1), range: NSRange(location: 10, length: 2))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1), range: NSRange(location: 13, length: 5))
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 35))
        label.textAlignment = .center
        label.attributedText = attributedString
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 295/375).isActive = true
        label.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 44/812).isActive = true
        label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        UIView.animate(withDuration: 0.9, animations: {
            label.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.9, animations: {
                label.alpha = 0.0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.addIcon()
        }
    }
    
    func addIcon() {
        let imageView = UIImageView(image: UIImage(named: "Typography 1"))
        imageView.frame = CGRect(x: 0, y: 0, width: 278, height: 181)
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 278/375).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 181/812).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        UIView.animate(withDuration: 0.9, animations: {
            imageView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.9, animations: {
                imageView.alpha = 0.0
            }, completion: { _ in
                imageView.removeFromSuperview()
                self.performSegue(withIdentifier: "goToMain", sender: self)
            })
        })
    }
}

