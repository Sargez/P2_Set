//
//  ViewController.swift
//  Set
//
//  Created by 1C on 30/04/2022.
//

import UIKit

class ViewController: UIViewController {

    var game = Game()
    
    enum GameMode: Int {
        case user = 0
        case iphone
    }
    
    var player = GameMode.user {didSet{game.identifierPlayer = player.rawValue}}
    
    private var deckCount = 0 { didSet {updateDeckCountLabel()} }
    private var messageText = "" {didSet {messageTextLabel.text = messageText}}
    private var messageTextIphone = "" {didSet {messageTextIphoneLabel.text = messageTextIphone}}
    private var scoreCount = 0 {didSet {updateScoreCountLabel()}}
    private var scoreIphoneCount = 0 {didSet {updateScoreIphoneCountLabel()}}
    private var scoreHints = 0 {didSet {updateHintsTitle()}}
    private var emojiIphone = "" {didSet{emojiIphoneLabel.text = emojiIphone}}
    
    private weak var timerForHints: Timer?
    private weak var timerForIphoneTurn: Timer?
    
    @IBOutlet private var cardButtons: [CardButtonsView]!
    @IBOutlet private weak var deal3CardButton: ManageButtonsView!
    @IBOutlet private weak var hints: ManageButtonsView! {didSet {updateHintsTitle()}}
    @IBAction func touchCard(_ sender: CardButtonsView) {
        
        timerForHints?.fire()
        
        if let card = sender.setCard {
            
            if !(timerForIphoneTurn?.isValid ?? true) {
                // user or iphone find a set. update timer
                updateTimer()
            }
            
            game.selectCard(card)
            updateViewFromModel()
            
            if !game.setCards.isEmpty {
                timerForIphoneTurn?.invalidate()
            }
            
        } else {
            print("There isn't card in the array cardsButton")
        }
        
    }
    
    @IBAction func newGame(_ sender: ManageButtonsView) {
        game = Game()
        cardButtons.forEach {$0.setCard = nil}
        updateViewFromModel()
        updateTimer()
    }
    
    private func updateTimer() {

        timerForIphoneTurn?.invalidate()

        let fireDate = Date()

        timerForIphoneTurn = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] timer in

            let bound = Constants.waitingForIphoneTurn * Constants.percentOfWaitingTime
            switch fireDate.timeIntervalSinceNow.distance(to: 0.0) {
            case 0..<bound:
                self!.emojiIphone = Constants.iphoneThinking + " Thinking..."
            case bound...Constants.waitingForIphoneTurn :
                self!.emojiIphone = Constants.iphoneReadyToGo + " Ready. Stady. Go!"
            default:

                timer.invalidate()

                self!.player = .iphone

                self!.game.selectedCards.removeAll()

                let resultOfFlipCoin = [0,1,1,1].randomElement()

                self!.messageTextIphone = ""

                if resultOfFlipCoin == 0 {
                    //don't guess. select random 3 cards
                    var cardOnTheTable = self!.game.cardsOnTheTable
                    cardOnTheTable.shuffle()
                    for index in 0..<3 {
                        self!.game.selectCard(cardOnTheTable[index])
                    }
                } else {
                    //guess. select a set
                    if let setToShow = self!.game.findAllSetsOnTheTable().randomElement() {
                        setToShow.forEach {self!.game.selectCard($0)}
                    }
                }
            }

            self!.updateViewFromModel()

            self!.player = .user

        }
        
    }
    
    @IBAction private func showMeSet(_ sender: ManageButtonsView) {
        
        timerForHints?.invalidate()
        
        if let setToShow = game.findAllSetsOnTheTable().randomElement() {
            
            cardButtons.indices.forEach { index in
                let button = cardButtons[index]
                
                if let card = button.setCard, setToShow.contains(card) {
                    button.hint = true
                } else {
                    button.hint = false
                }
            }
            
            timerForHints = Timer.scheduledTimer(withTimeInterval: TimeInterval(Constants.flashingTime), repeats: false) {
                [weak self] timer in
                self!.cardButtons.indices.forEach { index in
                    let button = self!.cardButtons[index]
                    button.hint = false
                }
                
            }
            
        }
        
    }
    
    @IBAction private func deal3Card(_ sender: ManageButtonsView) {
        game.deal3Cards()
        updateViewFromModel()
        updateTimer()
    }
    
    @IBOutlet private weak var deckCountLabel: UILabel! {didSet {updateDeckCountLabel()}}
    @IBOutlet private weak var messageTextIphoneLabel: UILabel!{didSet {messageTextIphoneLabel.text = messageTextIphone}}
    @IBOutlet private weak var messageTextLabel: UILabel! {didSet {messageTextLabel.text = messageText}}
    @IBOutlet private weak var scoreIphoneCountLabel: UILabel!{didSet {updateScoreIphoneCountLabel()}}
    @IBOutlet private weak var scoreCountLabel: UILabel! {didSet {updateScoreCountLabel()}}
    @IBOutlet private weak var emojiIphoneLabel: UILabel!{didSet{emojiIphoneLabel.text = ""}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
        updateTimer()
    }
    
    private func updateViewFromModel() {
        
        var message = ""
        messageText = ""
        messageTextIphone = ""
        
        for index in cardButtons.indices {
        
            let button = cardButtons[index]
            
            if index < game.cardsOnTheTable.count {
                let card = game.cardsOnTheTable[index]
                button.setCard = card
                
                button.select = game.selectedCards.contains(card) && (game.selectedCards.count < 3)
                
                button.match = game.matchedCards.contains(card) && game.selectedCards.contains(card)
                
                button.disMatch = !game.matchedCards.contains(card) && game.selectedCards.contains(card) && (game.selectedCards.count == 3)
            
                if game.deck.cards.isEmpty && game.matchedCards.contains(card) && !game.selectedCards.contains(card) {
                    //it's closer to the end of the game. just hidden the button
                    button.setCard = nil
                }
 
            } else {
                button.setCard = nil
            }
            
        }
        
        deckCount = game.deck.cards.count
        deal3CardButton.isEnabled = (cardButtons.count > game.cardsOnTheTable.count || !game.setCards.isEmpty) && deckCount != 0
        scoreCount = game.score[0]
        scoreIphoneCount = game.score[1]
        scoreHints = game.findAllSetsOnTheTable().count
        hints.isEnabled = scoreHints > 0
        
        if scoreHints == 0, deckCount == 0 {
            message = "Game over!!!"
        } else if !game.setCards.isEmpty {
            message = "😆 Set!"
            emojiIphone = player == GameMode.user ? Constants.iphoneLikeYou : Constants.iphoneWin + " I'm right!"
        } else if (game.selectedCards.count == 3 && game.setCards.isEmpty) {
            message = "😡 Ohh No..."
            emojiIphone = player == GameMode.user ? Constants.iphoneDisLikeYou : Constants.iphoneLose + " My mistake!"
        }
        
        if player == GameMode.user {
            messageText = message
        } else {
            messageTextIphone = scoreHints == 0 && game.setCards.isEmpty ? "😤 No sets at all..." : message
            emojiIphone = scoreHints == 0 && game.setCards.isEmpty ? "" : emojiIphone
        }
        
    }
    
    private func updateDeckCountLabel() {
        deckCountLabel.text = "Deck: \(deckCount)"
    }
  
    private func updateScoreCountLabel() {
        scoreCountLabel.text = "Your score: \(scoreCount)"
    }
    
    private func updateScoreIphoneCountLabel() {
        scoreIphoneCountLabel.text = "Iphone score: \(scoreIphoneCount)"
    }
    
    private func updateHintsTitle() {
        hints.setTitle("Hints:\(scoreHints)", for: UIControl.State.normal)
    }
    
    private struct Constants {
        static let flashingTime = 3.0
        static let waitingForIphoneTurn = 20.0
        static let percentOfWaitingTime = 0.9
        static let iphoneThinking = "🤔"
        static let iphoneReadyToGo = "😋"
        static let iphoneWin = "😀"
        static let iphoneLose = "😤"
        static let iphoneLikeYou = "👍"
        static let iphoneDisLikeYou = "👎"
    }
}

