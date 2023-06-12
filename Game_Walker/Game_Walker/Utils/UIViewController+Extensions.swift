//
//  UIViewController+Extensions.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/11/22.
//

import UIKit

// MARK: - Keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
// MARK: - GameInfoPopUps
extension UIViewController {
    func showGameInfoPopUp(gameName: String? = nil, gameLocation: String? = nil, gamePoitns: String? = nil, refereeName: String? = nil, gameRule: String? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = GameInfoViewController(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", refereeName: refereeName ?? "", gameRule: gameRule ?? "")
        showGameInfoPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showGameInfoPopUp(popUpViewController: GameInfoViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
    
    func showRefereeGameInfoPopUp(gameName: String? = nil, gameLocation: String? = nil, gamePoitns: String? = nil, gameRule: String? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = RefereeGameInfoViewcontroller(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", gameRule: gameRule ?? "")
        showRefereeGameInfoPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showRefereeGameInfoPopUp(popUpViewController: RefereeGameInfoViewcontroller, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
}
// MARK: - PlayerMessagePopUps
extension UIViewController {
    func showMessagePopUp(messages: [String]? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = MessageViewController(messages: messages ?? [])
        showMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showMessagePopUp(popUpViewcontroller: MessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
    
    func showAnnouncementPopUp(announcement: String = "", _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = AnnouncementViewController(announcement: announcement)
        showAnnouncementPopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showAnnouncementPopUp(popUpViewcontroller: AnnouncementViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}
// MARK: - RefereeMessagePopUps
extension UIViewController {
    func showRefereeMessagePopUp(messages: [String]? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = RefereeMessageViewController(messages: messages ?? [])
        showRefereeMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showRefereeMessagePopUp(popUpViewcontroller: RefereeMessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
    
    func showRefereeAnnouncementPopUp(announcement: String = "", _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = RefereeAnnouncementViewController(announcement: announcement)
        showRefereeAnnouncementPopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showRefereeAnnouncementPopUp(popUpViewcontroller: RefereeAnnouncementViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}

// MARK: - InfoPopUp
extension UIViewController {
    func showInfoPopUp(_ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = InfoViewController(select: true)
        showInfoPopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showInfoPopUp(popUpViewcontroller: InfoViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}
// MARK: - HostMessagePopUps
extension UIViewController {
    func showHostMessagePopUp(messages: [String]? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = HostMessageViewController(messages: messages ?? [])
        showHostMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showHostMessagePopUp(popUpViewcontroller: HostMessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}

// MARK: - textField
extension UITextField {
    func setPadding(left: CGFloat, right: CGFloat? = nil) {
        setLeftPadding(left)
        if let rightPadding = right {
            setRightPadding(rightPadding)
        }
    }

    private func setLeftPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    private func setRightPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
