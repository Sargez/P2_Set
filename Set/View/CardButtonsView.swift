//
//  CardBattons.swift
//  Set
//
//  Created by 1C on 01/05/2022.
//

import UIKit

//@IBDesignable
class CardButtonsView: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var setCard: Card? {didSet{updateTheButton()}}
    
    @IBInspectable
    var cornerRadius: CGFloat = CGFloat(CardButtonsConstants.cornerRadius)  {didSet {setNeedsLayout()}}

    @IBInspectable
    var borderWidth: CGFloat = CGFloat(CardButtonsConstants.borderWidth) {didSet {setNeedsLayout()}}
    
    @IBInspectable
    var select: Bool = false {didSet{updateTheButton(); setNeedsLayout()}}
    
    @IBInspectable
    var match: Bool = false {didSet{updateTheButton(); setNeedsLayout()}}
    
    @IBInspectable
    var disMatch: Bool = false {didSet{updateTheButton(); setNeedsLayout()}}
    
    @IBInspectable
    var hint: Bool = false {didSet{updateTheButton(); setNeedsLayout()}}
      
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTheButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
    }
    
    private func updateTheButton() {
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = -1;
        if let card = setCard {
            layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
            setAttributedTitleToButton(card)
            updateFrame(at: card)
            isEnabled = true
            backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor
            isEnabled = false
            backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            setTitle("", for: UIControl.State.normal)
            setAttributedTitle(NSAttributedString(), for: UIControl.State.normal)
        }
    }
    
    private func updateFrame(at card:Card) {
        
        if select {
            setBorderColor(color: CardButtonsConstants.boderColorSelect)
        } else if match {
            setBorderColor(color: CardButtonsConstants.boderColorMatched)
        } else if disMatch {
            setBorderColor(color: CardButtonsConstants.boderColorDisMatched)
        } else if hint {
            setBorderColor(color: CardButtonsConstants.boderColorHints)
        }
                
    }
    
    func setBorderColor(color: CGColor) {
        layer.borderColor = color
        layer.borderWidth = borderWidth
    }
    
    private func setAttributedTitleToButton(_ card: Card) {
        
        func getAttributes(_ card:Card) -> [NSAttributedString.Key: Any] {
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
                
            var font = UIFont.preferredFont(forTextStyle: .body).withSize(CGFloat(CardButtonsConstants.fontSizeSymbolOnCard))
            font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
                
            var color:UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
            switch card.color {
                case .v1: color = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                case .v2: color = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                case .v3: color = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            }
                             
            var alphaComponent = 1.0
            if card.fill == Card.Variants.v2 {
                alphaComponent = CardButtonsConstants.alphaComponentStripped
            } else if card.fill == Card.Variants.v3 {
                alphaComponent = CardButtonsConstants.alphaComponentOutline
            }
            
            let attributes: [NSAttributedString.Key: Any] = [
                    .paragraphStyle : paragraphStyle,
                    .font: font,
                    .foregroundColor: color.withAlphaComponent(CGFloat(alphaComponent)),
                    .strokeWidth: card.fill == Card.Variants.v2 ? CardButtonsConstants.strokeWidthSymbolOnCard : -10,
                    .strokeColor: color
                ]
            return attributes
            
        }
        
        func getTitleString(_ card: Card) -> String {
            
            var titleString = ""
            
            var symbol = ""
            switch card.type {
            case .v1: symbol = CardButtonsConstants.circleSymbol
            case .v2: symbol = CardButtonsConstants.squareSymbol
            case .v3: symbol = CardButtonsConstants.triangleSymbol
            }
                    
            let separator = UIScreen.main.traitCollection.verticalSizeClass == .regular ? "\n" : " "
            for _ in 1...card.amount.rawValue {
                titleString = titleString.isEmpty ? titleString + symbol : titleString + separator + symbol
            }
            
            return titleString
        }
        
        setAttributedTitle(NSAttributedString.init(string: getTitleString(card), attributes: getAttributes(card)), for: UIControl.State.normal)
        
    }
    
    private struct CardButtonsConstants {
        static let borderWidth = 5.0
        static let cornerRadius = 8.0
        static let boderColorSelect = UIColor.orange.cgColor
        static let boderColorMatched = UIColor.cyan.cgColor
        static let boderColorDisMatched = UIColor.red.cgColor
        static let boderColorHints = UIColor.magenta.cgColor
        static let circleSymbol = "●"
        static let squareSymbol = "■​"
        static let triangleSymbol = "▲"
        static let alphaComponentStripped = 0.4
        static let alphaComponentOutline = 0.15
        static let strokeWidthSymbolOnCard = 10
        static let fontSizeSymbolOnCard = 25
    }
    
}
