//
//  GivePointsController.swift
//  Game_Walker
//
//  Created by 김현식 on 10/8/22.
//

import Foundation
import UIKit

class GivePointsController: UIViewController {
    var currentStationName: String
    var currentPoints: Int
    let gameCode: String
    let team: Team
    
    init(team: Team, gameCode: String) {
        self.team = team
        self.currentStationName = team.currentStation
        self.currentPoints = team.points
        self.gameCode = gameCode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.view.addSubview(containerView)
        self.view.addSubview(givepointsLabel)
        self.view.bringSubviewToFront(givepointsLabel)
        self.view.addSubview(closeButton)
        self.view.addSubview(stepper)
        self.view.addSubview(confirmButton)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: 338).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 338).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 220).isActive = true
        givepointsLabel.translatesAutoresizingMaskIntoConstraints = false
        givepointsLabel.widthAnchor.constraint(equalToConstant: 267.74).isActive = true
        givepointsLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
        givepointsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        givepointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 55).isActive = true
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.widthAnchor.constraint(equalToConstant: 265).isActive = true
        stepper.heightAnchor.constraint(equalToConstant: 134).isActive = true
        stepper.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stepper.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 116).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 284).isActive = true
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.widthAnchor.constraint(equalToConstant: 175.8).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 57).isActive = true
        confirmButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        confirmButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 265).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(popupClosed))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private lazy var containerView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 338, height: 338)
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        return view
    }()
    
    private lazy var givepointsLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 267.74, height: 61)
        let image0 = UIImage(named: "white!give points 1.png")?.cgImage
        let layer0 = CALayer()
        layer0.contents = image0
        layer0.bounds = view.bounds
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        return view
    }()
    
    private lazy var stepper: GMStepper = {
        var view = GMStepper()
        view.frame = CGRect(x: 0, y: 0, width: 265, height: 134)
        view.buttonsBackgroundColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
        view.buttonsFont = UIFont(name: "Dosis-Regular", size: 100) ?? UIFont(name: "AvenirNext-Bold", size: 20.0)!
        view.labelBackgroundColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
        view.labelFont = UIFont(name: "Dosis-Bold", size: 100) ?? UIFont(name: "AvenirNext-Bold", size: 25.0)!
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(self, action: #selector(popupClosed), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175.8, height: 57))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "confirm button 1 (3)"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        T.givePoints(gameCode, team.name, Int(stepper.value))
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func popupClosed() {
        self.presentingViewController?.dismiss(animated: true)
    }
}

//MARK: - GMStepper
@IBDesignable public class GMStepper: UIControl {

    /// Current value of the stepper. Defaults to 0.
    @objc @IBInspectable public var value: Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))

            label.text = formattedValue

            if oldValue != value {
                sendActions(for: .valueChanged)
            }
        }
    }
    
    private var formattedValue: String? {
        let isInteger = Decimal(value).exponent >= 0
        
        // If we have items, we will display them as steps
        if isInteger && stepValue == 1.0 && items.count > 0 {
            return items[Int(value)]
        }
        else {
            return formatter.string(from: NSNumber(value: value))
        }
    }


    /// Minimum value. Must be less than maximumValue. Defaults to 0.
    @objc @IBInspectable public var minimumValue: Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
        }
    }

    /// Maximum value. Must be more than minimumValue. Defaults to 100.
    @objc @IBInspectable public var maximumValue: Double = 999 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
        }
    }

    /// Step/Increment value as in UIStepper. Defaults to 1.
    @objc @IBInspectable public var stepValue: Double = 1 {
        didSet {
            setupNumberFormatter()
        }
    }

    /// The same as UIStepper's autorepeat. If true, holding on the buttons or keeping the pan gesture alters the value repeatedly. Defaults to true.
    @objc @IBInspectable public var autorepeat: Bool = true

    /// If the value is integer, it is shown without floating point.
    @objc @IBInspectable public var showIntegerIfDoubleIsInteger: Bool = true {
        didSet {
            setupNumberFormatter()
        }
    }

    /// Text on the left button. Be sure that it fits in the button. Defaults to "−".
    @objc @IBInspectable public var leftButtonText: String = "−" {
        didSet {
            leftButton.setTitle(leftButtonText, for: .normal)
        }
    }

    /// Text on the right button. Be sure that it fits in the button. Defaults to "+".
    @objc @IBInspectable public var rightButtonText: String = "+" {
        didSet {
            rightButton.setTitle(rightButtonText, for: .normal)
        }
    }

    /// Text color of the buttons. Defaults to white.
    @objc @IBInspectable public var buttonsTextColor: UIColor = UIColor.white {
        didSet {
            for button in [leftButton, rightButton] {
                button.setTitleColor(buttonsTextColor, for: .normal)
            }
        }
    }

    /// Background color of the buttons. Defaults to dark blue.
    @objc @IBInspectable public var buttonsBackgroundColor: UIColor = UIColor(red:0.21, green:0.5, blue:0.74, alpha:1) {
        didSet {
            for button in [leftButton, rightButton] {
                button.backgroundColor = buttonsBackgroundColor
            }
            backgroundColor = buttonsBackgroundColor
        }
    }

    /// Font of the buttons. Defaults to AvenirNext-Bold, 20.0 points in size.
    @objc public var buttonsFont = UIFont(name: "AvenirNext-Bold", size: 20.0)! {
        didSet {
            for button in [leftButton, rightButton] {
                button.titleLabel?.font = buttonsFont
            }
        }
    }

    /// Text color of the middle label. Defaults to white.
    @objc @IBInspectable public var labelTextColor: UIColor = UIColor.white {
        didSet {
            label.textColor = labelTextColor
        }
    }

    /// Text color of the middle label. Defaults to lighter blue.
    @objc @IBInspectable public var labelBackgroundColor: UIColor = UIColor(red:0.26, green:0.6, blue:0.87, alpha:1) {
        didSet {
            label.backgroundColor = labelBackgroundColor
        }
    }

    /// Font of the middle label. Defaults to AvenirNext-Bold, 25.0 points in size.
    @objc public var labelFont = UIFont(name: "AvenirNext-Bold", size: 25.0)! {
        didSet {
            label.font = labelFont
        }
    }
       /// Corner radius of the middle label. Defaults to 0.
    @objc @IBInspectable public var labelCornerRadius: CGFloat = 0 {
        didSet {
            label.layer.cornerRadius = labelCornerRadius
        
            }
    }

    /// Corner radius of the stepper's layer. Defaults to 4.0.
    @objc @IBInspectable public var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }
    
    /// Border width of the stepper and middle label's layer. Defaults to 0.0.
    @objc @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
            label.layer.borderWidth = borderWidth
        }
    }
    
    /// Color of the border of the stepper and middle label's layer. Defaults to clear color.
    @objc @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            label.layer.borderColor = borderColor.cgColor
        }
    }

    /// Percentage of the middle label's width. Must be between 0 and 1. Defaults to 0.5. Be sure that it is wide enough to show the value.
    @objc @IBInspectable public var labelWidthWeight: CGFloat = 0.5 {
        didSet {
            labelWidthWeight = min(1, max(0, labelWidthWeight))
            setNeedsLayout()
        }
    }

    /// Color of the flashing animation on the buttons in case the value hit the limit.
    @objc @IBInspectable public var limitHitAnimationColor: UIColor = UIColor(red:0.26, green:0.6, blue:0.87, alpha:1)

    /// Formatter for displaying the current value
    let formatter = NumberFormatter()
    
    /**
        Width of the sliding animation. When buttons clicked, the middle label does a slide animation towards to the clicked button. Defaults to 5.
    */
    let labelSlideLength: CGFloat = 5


    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.leftButtonText, for: .normal)
        button.setTitleColor(self.buttonsTextColor, for: .normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.addTarget(self, action: #selector(GMStepper.leftButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(GMStepper.buttonTouchUp), for: .touchUpInside)
        button.addTarget(self, action: #selector(GMStepper.buttonTouchUp), for: .touchUpOutside)
        button.addTarget(self, action: #selector(GMStepper.buttonTouchUp), for: .touchCancel)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GMStepper.handleLeftLongPress(gesture:)))
        longPressGestureRecognizer.minimumPressDuration = 1.0
        button.addGestureRecognizer(longPressGestureRecognizer)
        return button
    }()

    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.rightButtonText, for: .normal)
        button.setTitleColor(self.buttonsTextColor, for: .normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.addTarget(self, action: #selector(GMStepper.rightButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(GMStepper.buttonTouchUp), for: .touchUpInside)
        button.addTarget(self, action: #selector(GMStepper.buttonTouchUp), for: .touchUpOutside)
        button.addTarget(self, action: #selector(GMStepper.buttonTouchUp), for: .touchCancel)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GMStepper.handleRightLongPress(gesture:)))
        longPressGestureRecognizer.minimumPressDuration = 1.0
        button.addGestureRecognizer(longPressGestureRecognizer)
        
        return button
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = formattedValue
        label.textColor = self.labelTextColor
        label.backgroundColor = self.labelBackgroundColor
        label.font = self.labelFont
        label.layer.cornerRadius = self.labelCornerRadius
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()

    var labelOriginalCenter: CGPoint!
    var labelMaximumCenterX: CGFloat!
    var labelMinimumCenterX: CGFloat!

    enum StepperState {
        case Stable, ShouldIncrease, ShouldDecrease, MoreIncrease, MoreDecrease
    }
    var stepperState = StepperState.Stable {
        didSet {
            if stepperState != .Stable {
                updateValue()
            }
        }
    }
    
    
    @objc public var items : [String] = [] {
        didSet {
            label.text = formattedValue
        }
    }

    /// Timer used for autorepeat option
    var timer: Timer?

    let timerInterval = TimeInterval(1.0)

    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    fileprivate func setup() {
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(label)

        backgroundColor = buttonsBackgroundColor
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        labelOriginalCenter = label.center

        setupNumberFormatter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GMStepper.reset), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func setupNumberFormatter() {
        let decValue = Decimal(stepValue)
        let digits = decValue.significantFractionalDecimalDigits
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = showIntegerIfDoubleIsInteger ? 0 : digits
        formatter.maximumFractionDigits = digits
    }

    public override func layoutSubviews() {
        let buttonWidth = bounds.size.width * ((1 - labelWidthWeight) / 2)
        let labelWidth = bounds.size.width * labelWidthWeight

        leftButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: bounds.size.height)
        label.frame = CGRect(x: buttonWidth, y: 0, width: labelWidth, height: bounds.size.height)
        rightButton.frame = CGRect(x: labelWidth + buttonWidth, y: 0, width: buttonWidth, height: bounds.size.height)

        labelMaximumCenterX = label.center.x + labelSlideLength
        labelMinimumCenterX = label.center.x - labelSlideLength
        labelOriginalCenter = label.center
    }

    @objc func updateValue() {
        if stepperState == .ShouldIncrease {
            value += stepValue
        } else if stepperState == .ShouldDecrease {
            value -= stepValue
        } else if stepperState == .MoreIncrease {
            value += 20
        } else if stepperState == .MoreDecrease {
            value -= 20
        }
    }
    

    deinit {
        resetTimer()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: LongPress Gesture
extension GMStepper {
    @objc func handleRightLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
            stepperState = .MoreIncrease
        case .changed, .ended, .cancelled, .failed:
            reset()
        default:
            break
        }
    }
    
    @objc func handleLeftLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
            stepperState = .MoreDecrease
        case .changed, .ended, .cancelled, .failed:
            reset()
        default:
            break
        }
    }

    @objc func reset() {
        stepperState = .Stable
        resetTimer()
        leftButton.isEnabled = true
        rightButton.isEnabled = true
    }
}

// MARK: Button Events
extension GMStepper {
    @objc func leftButtonTouchDown(button: UIButton) {
        rightButton.isEnabled = false
        label.isUserInteractionEnabled = false
        resetTimer()
        if value != minimumValue {
            stepperState = .ShouldDecrease
        }
    }

    @objc func rightButtonTouchDown(button: UIButton) {
        leftButton.isEnabled = false
        label.isUserInteractionEnabled = false
        resetTimer()

        if value != maximumValue {
            stepperState = .ShouldIncrease
        }
    }

    @objc func buttonTouchUp(button: UIButton) {
        reset()
    }
}

// MARK: Timer
extension GMStepper {
    @objc func handleTimer(timer: Timer) {
        updateValue()
    }

    func scheduleTimer() {
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(GMStepper.handleTimer), userInfo: nil, repeats: true)
    }

    func resetTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
}


extension Decimal {
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}
