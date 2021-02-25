//
//  ViewController.swift
//  Memory
//
//  Created by Kacper on 18/02/2021.
//

import UIKit

class ViewController: UIViewController {
    var cardsButtons = [UIButton]()
    var colors = [UIColor]()
    var cardsUp: Int = 0 {
        didSet {
            if cardsUp == 2 {
                twoCardsShown()
            }
        }
    }
    var cardsButtonsUp = [UIButton]()
    var pairsToFind: Int = 0 {
        didSet {
            if pairsToFind == 0 {
                endGame()
            }
        }
    }
    @IBOutlet var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.backgroundColor = CGColor(red: 0, green: 0.2, blue: 0.3, alpha: 1.0)
    }
    
    func startGame() {
        setupLevel(1)
    }

    @IBAction func playTppd(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.playButton.alpha = 0.0
        })
        startGame()
    }
    
    func setupLevel(_ lvl: Int) {
        let midX: Int = Int(view.frame.midX)
        let midY: Int = Int(view.frame.midY)
        let horSpacing: Int = 40
        let cardW = 150
        colors = [.magenta, .magenta, .green, .green, .green, .green]
        pairsToFind = lvl*2
        
        for i in 1...4 {
//            let x = midX + horSpacing*(-2.5+CGFloat(i)) + cardW*(-3+CGFloat(i))
            let x: Int = midX + horSpacing*(-5+2*i)/2 + cardW*(-3+i)
            let randomColor = colors.remove(at: Int.random(in: 0...4-i))
            createButton(frame: CGRect(x: x, y: midY-100, width: cardW, height: 200), color: randomColor, number: i)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            for btn in self.cardsButtons {
                btn.alpha = 1.0
            }
        })
    }
    
    func createButton(frame: CGRect, color: UIColor, number: Int) {
        let button = UIButton(type: .system)
        button.frame = frame
        button.setTitle("\(number)", for: .normal)
        button.setTitleColor(UIColor.clear, for: .normal)
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.layer.cornerRadius = frame.width*0.2
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
        button.alpha = 0.0
        
        let inColor = UIView(frame: CGRect(x: frame.width*0.1, y: frame.width*0.1, width: frame.width-frame.width*0.2, height: frame.height-frame.width*0.2))
        inColor.backgroundColor = color
        inColor.layer.cornerRadius = frame.width*0.1
        inColor.isUserInteractionEnabled = false
        inColor.accessibilityIdentifier = "inc"
        button.addSubview(inColor)
        
        let overColor = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        overColor.layer.backgroundColor = UIColor(red: 0.3, green: 0.47, blue: 0.6, alpha: 1.0).cgColor
        overColor.layer.cornerRadius = frame.width*0.2
        overColor.accessibilityIdentifier = "overc"
        overColor.isUserInteractionEnabled = false
        button.addSubview(overColor)
        
        cardsButtons.append(button)
        view.addSubview(button)
    }
    
    @objc func cardTapped(sender: Any) {
        guard let btn = sender as? UIButton else { return }
        if let title = btn.currentTitle {
            if let number = Int(title) {
                print(number)
            }
        }
        
        for subvw in btn.subviews {
            if subvw.accessibilityIdentifier == "overc" {
                UIView.animate(withDuration: 0.2, animations: {
                    subvw.alpha = 0.0
                })
            }
        }
        
        cardsButtonsUp.append(btn)
        cardsUp += 1
    }
    
    func twoCardsShown() {
        for btn in cardsButtons {
            btn.isUserInteractionEnabled = false
        }
        
        var colors = [UIColor]()
        
        for btn in cardsButtonsUp {
            for subview in btn.subviews {
                if subview.accessibilityIdentifier == "inc" {
                    if let color = subview.backgroundColor {
                        colors.append(color)
                    }
                }
            }
        }
        
        if colors.count == 2 {
            if colors[0] == colors[1] {
                pairsToFind -= 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    for btn in self!.cardsButtonsUp {
                        UIView.animate(withDuration: 0.2, animations: {
                            btn.alpha = 0.0
                        })
                    }
                    
                    for btn in self!.cardsButtons {
                        btn.isUserInteractionEnabled = true
                    }
                    self?.cardsUp = 0
                    self?.cardsButtonsUp.removeAll()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    for btn in self!.cardsButtons {
                        for subvw in btn.subviews {
                            if subvw.accessibilityIdentifier == "overc" {
                                UIView.animate(withDuration: 0.2, animations: {
                                    subvw.alpha = 1.0
                                })
                            }
                        }
                        btn.isUserInteractionEnabled = true
                    }
                    self?.cardsUp = 0
                    self?.cardsButtonsUp.removeAll()
                }
            }
        }
        
        
    }
    
    func endGame() {
        cardsButtons.removeAll()
        playButton.setTitle("PLAY AGAIN", for: .normal)
        UIView.animate(withDuration: 0.5, delay: 1.5, options: [], animations: { [weak self] in
            self?.playButton.alpha = 1.0
        })
    }
    
}

