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
                currentLvl += 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.setupLevel()
                }
            }
        }
    }
    @IBOutlet var playButton: UIButton!
    var currentLvl: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLvl = 1
        view.layer.backgroundColor = CGColor(red: 0, green: 0.2, blue: 0.3, alpha: 1.0)
    }

    @IBAction func playTppd(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.playButton.alpha = 0.0
        })
        
        setupLevel()
    }
    
    func setupLevel() {
        cardsButtons.removeAll()
        
        if currentLvl > 4 {
            endGame()
            return
        }
        
        let midX: Int = Int(view.frame.midX)
        let midY: Int = Int(view.frame.midY)
        let spacing: Int = 30
        let cardW = 150
        let cardH = 200
        colors = [.magenta, .magenta, .green, .green, .blue, .blue, .brown, .brown, .cyan, .cyan, .orange, .orange, .gray, .gray, .purple, .purple]
        pairsToFind = currentLvl*2
        
        for u in 1...currentLvl {
            let y: Int
            
            switch currentLvl {
            case 2:
                y = midY + cardH * (-2+u) + spacing * (2*u - 3)/2
            case 3:
                y = midY + cardH * (-5+2*u)/2 + spacing * (u - 2)
            case 4:
                y = midY + cardH * (-3+u) + spacing * (2*u - 5)/2
            default:
                y = midY - cardH/2
            }
            
            for i in 1...4 {
                let x: Int = midX + spacing*(-5+2*i)/2 + cardW*(-3+i)
                let randomColor = colors.remove(at: Int.random(in: 0...currentLvl*4-((u-1)*4)-i))
                createButton(frame: CGRect(x: x, y: y, width: cardW, height: cardH), color: randomColor, number: i)
            }
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
        
        let endLabel = UILabel(frame: CGRect(x: view.frame.midX-300, y: view.frame.height*0.25, width: 600, height: 200))
        endLabel.text = "Nice!"
        endLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        endLabel.font = UIFont(name: "Verdana", size: 75)
        endLabel.textAlignment = .center
        view.addSubview(endLabel)
        endLabel.alpha = 0.0

//        UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
//            endLabel.alpha = 1.0
//        })
        UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
            endLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.2, options: [], animations: {
                endLabel.alpha = 0.0
            })
        })
    }
    
}

