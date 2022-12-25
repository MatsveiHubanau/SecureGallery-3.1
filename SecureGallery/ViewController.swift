//
//  ViewController.swift
//  SecureGallery
//
//  Created by Admin on 31.10.22.
//

import UIKit
import LocalAuthentication
import MessageUI
import RswiftResources

class ViewController: UIViewController {
    
    var enteredPIN = ""
    let localizedActionSMS =       NSLocalizedString("TEXT_SEND_SMS", comment: "")
    let localizedActionEmail =     NSLocalizedString("TEXT_SEND_EMAIL", comment: "")
    let localizedActionPhoneCall = NSLocalizedString("TEXT_PHONE_CALL", comment: "")
    let localizedActionCancel =    NSLocalizedString("TEXT_CANCEL", comment: "")
    let localizedActionTelegram =  NSLocalizedString("TEXT_TELEGRAM", comment: "")
    let localizedToChoose =        NSLocalizedString("TEXT_TO_CHOOSE", comment: "")
    let localizedPlaceholder =     NSLocalizedString("TEXT_PIN", comment: "")
    let localizedWrong =           NSLocalizedString("TEXT_WRONGPIN", comment: "")
    let localizedRetry =           NSLocalizedString("TEXT_RETRY", comment: "")
    let localizedFailed =          NSLocalizedString("TEXT_FACEID_REJECTED", comment: "")
    let localizedDismiss =         NSLocalizedString("TEXT_DISMISS", comment: "")
    
    // MARK: - IBOutlets
    @IBOutlet var pinField: UITextField!
    @IBOutlet var showPinButton: UIButton!
    @IBOutlet var unlockButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    // MARK: - IBActions
    @IBAction func showPin(_ sender: Any) {
        pinField.isSecureTextEntry.toggle()
        showPinButton.isSelected = !pinField.isSecureTextEntry
    }
    
    @IBAction func unlock(_ sender: Any) {
        if pinField.text == "1234"{
            presentGalleryController ()
        } else {
            showAlert(localizedWrong, message: localizedRetry)
            pinField.text?.removeAll()
        }
    }
    
    @IBAction func FaceIDButton(_ sender: UIButton) {
        authenticate()
    }
    
    @IBAction func connectButton(_ sender: Any) {
        showContactSheet(localizedToChoose, message: "")
    }
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pinField.placeholder = localizedPlaceholder
        pinField.delegate = self
        unlockButton.isEnabled = false
        showPinButton.isEnabled = false
        showPinButton.setImage(UIImage(systemName: "eye"), for: .normal)
        showPinButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        registerKeyboardNotifications ()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    // MARK: - Public methods
    func authenticate () {
        let context = LAContext ()
        var error: NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in DispatchQueue.main.async {
                    [weak self] in guard success, error == nil else {
                        self?.pinField.text = ""
                        self?.pinField.layer.borderColor = UIColor.red.cgColor
                        self?.pinField.layer.borderWidth = 1
                        return
                    }
                    self?.presentGalleryController ()
                }
            }
        } else {
            let alert = UIAlertController(title: "Unavailable", message: localizedFailed, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localizedDismiss, style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    func showAlert (_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func showContactSheet (_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let SMSAction = UIAlertAction(title: localizedActionSMS,
                                      style: .default,
                                      handler: { (UIAlertAction) in
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController ()
                controller.body = "Message body"
                controller.recipients = ["+1 (408) 996-1010"]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }})
        let callAction = UIAlertAction(title: localizedActionPhoneCall,
                                       style: .default,
                                       handler: {(UIAlertAction) in
            guard let number = URL(string: "tel://" + "375295746549")
            else { return }
            UIApplication.shared.open(number)
        })
        let emailAction = UIAlertAction(title: localizedActionEmail,
                                        style: .default,
                                        handler: {(UIAlertAction) in if MFMailComposeViewController.canSendMail() {
                                            let mail = MFMailComposeViewController ()
                                            mail.mailComposeDelegate = self
                                            mail.setToRecipients(["matvey2357@gmail.com"])
                                            mail.setSubject("Feedback")
                                            mail.setMessageBody("<h>Describe your problem right to the Boss</h>", isHTML: true)
                                            mail.setCcRecipients(["tcook@apple.com"])
                                            self.present(mail, animated: true)
                                        }})
        let telegramAction = UIAlertAction(title: localizedActionTelegram,
                                           style: .default,
                                           handler: { (UIAlertAction) in
            guard let contact = URL(string: "https://t.me/+375295746549")
            else { return }
            UIApplication.shared.open(contact)
        })
        let cancelAction = UIAlertAction(title: localizedActionCancel,
                                         style: .cancel, handler: { (UIAlertAction) in
            alert.dismiss(animated: true) })
        alert.addAction(callAction)
        alert.addAction(SMSAction)
        alert.addAction(emailAction)
        alert.addAction(telegramAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func presentGalleryController () {
        if #available(iOS 16.0, *) {
            let gallery = GalleryController()
            let navigation = UINavigationController(rootViewController: gallery)
            navigation.modalPresentationStyle = .fullScreen
            self.present(navigation, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:
                                            { self.pinField.text?.removeAll() } )
        } else { return }
    }
    
    
    func registerKeyboardNotifications () {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow (_ notification: Foundation.Notification ){
        guard let userInfo = notification.userInfo else { return }
        let keyboardSize = (userInfo [UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size
        // constraint.constant = 25
        //  сonstraint.constant = 50 + (keyboardSize?.height ?? 0)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize?.height ?? 150 , right: 0)
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide (_ notification: Foundation.Notification) {
        //   constraint.constant = 0
        scrollView.contentInset = .zero
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
        view.layoutIfNeeded()
    }
    
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        unlock(self)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        showPinButton.isEnabled = pinField.text?.count ?? 0 > 0
        unlockButton.isEnabled = pinField.text?.count ?? 0 == 4
        if pinField.text?.count ?? 0 > 4 {
            pinField.text?.removeLast()
        }
    }
}

// MARK: - SMS
extension ViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true)
    }
}
// MARK: - Email
extension ViewController: MFMailComposeViewControllerDelegate {
    
}
