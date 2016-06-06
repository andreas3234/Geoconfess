//
//  DetailViewController.swift
//  GeoConfess
//
//  Created by whitesnow0827 on 3/17/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

final class ConfessionFAQViewController: AppViewControllerWithToolbar,
										 UIScrollViewDelegate {

    @IBOutlet weak private var mainView: UIView!
    @IBOutlet weak private var bottomView: UIView!
    @IBOutlet weak private var scrollView: UIScrollView!
	
	private var faqView: UIView!
    
    private var contactsTableViewController: ContactsTableViewController?
	
    private let faqSentences: [String] = [
        "Qu’est-ce que la confession ?",
        "La confession est le sacrement qui donne au pénitent, par l’intermédiaire du prêtre, d’obtenir la rémission de tous ses péchés personnels (quelle que soit leur gravité).",
        "Que comporte la confession ?",
        "- L’examen des fautes (ou péchés) commises (ou examen de conscience)",
        "- Le regret d’avoir commis ces fautes et la résolution sincère de les éviter à l’avenir (exprimés à travers l’acte de contrition)",
        "- L’expression des fautes commises. ",
        "- L’absolution donnée par le prêtre",
        "- L’accomplissement de la pénitence demandée",
        "Sur l’examen de conscience",
        "Il s’agit de s’examiner sur les Commandements de Dieu et de l’Église ; les péchés capitaux ; les devoirs de son état. (fiche type sur l’examen de conscience ?)",
        "L’acte de contrition",
        "\"Mon Dieu, j'ai un très grand regret de vous avoir offensé parce que vous êtes infiniment bon, infiniment aimable, et que le péché vous déplaît.",
        "Je prends la ferme résolution, avec le secours de votre sainte grâce de ne plus vous offenser et de faire pénitence.\"",
        "Pourquoi la confession est-elle définie comme un sacrement ?",
        "Sacrement de Pénitence",
        "La confession est appelée sacrement de Pénitence car elle consacre une démarche personnelle et ecclésiale de conversion, de repentir et de satisfaction du chrétien pécheur.",
        "Sacrement de confession",
        "La confession est nommée aussi sacrement de confession parce que l’aveu ou confession des péchés devant le prêtre en est un élément essentiel.",
        "Ensuite et dans un sens plus profond, parce que la confession est une reconnaissance et une louange de la sainteté de Dieu et de sa Miséricorde envers l’homme pêcheur.",
        "Sacrement du pardon",
        "La confession est aussi nommée sacrement du pardon. L’absolution sacramentelle du prêtre accorde au pénitent « le pardon et la paix » venant de Dieu.",
        "Sacrement de Réconciliation",
        "Enfin, la confession est dite sacrement de Réconciliation car elle donne au pécheur l’Amour de Dieu qui réconcilie.",
        "Il y a ainsi réconciliation avec Dieu qui fait vivre de son amour miséricordieux.",
        "Cet amour miséricordieux qui permet de répondre à l’appel du Seigneur : « \" Va d’abord te réconcilier avec ton frère \" (Mt 5, 24).",
        "La Réconciliation avec Dieu, si elle est sincère, amène à la réconciliation avec son prochain."
        ]
    
	private let redSubString = "(fiche type sur l’examen de conscience ?)"
	private let lineSpacing: CGFloat = 5.0
	private let linesWithSpacing = [3, 9, 11, 14, 17, 19, 20, 22, 24, 26]
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        
        // Initialize FAQ view.
        initializeFaqView()
		scrollView.delegate = self
    }
    
    // Mark: - Customize UILabel Strings
    func customizeSentences(lines: [String]) -> [NSMutableAttributedString] {
        var attributedSentences :[NSMutableAttributedString] = []
        for sentence in lines {
            
            switch lines.indexOf(sentence)! {
                
            case 0,13:
                let mutableString = NSMutableAttributedString(
					string: sentence,
					attributes: [NSFontAttributeName:UIFont(name: "Calibri-Light", size: 18.0)!,
						NSForegroundColorAttributeName: UIColor.init(red: 55/256, green: 113/256, blue: 182/256, alpha: 1.0)])
                attributedSentences.append(mutableString)
				
            case 2,8,10,14,16,19,21:
                let mutableString = NSMutableAttributedString(
					string: sentence,
					attributes: [NSFontAttributeName:UIFont(name: "Calibri-Bold", size: 13.0)!])
                attributedSentences.append(mutableString)
				
            case 9:
                let mutableString = NSMutableAttributedString(
					string: sentence,
					attributes: [NSFontAttributeName:UIFont(name: "Calibri", size: 13.0)!])
                let range = (mutableString.string as NSString).rangeOfString(redSubString)
                mutableString.addAttribute(NSForegroundColorAttributeName,
                                           value: UIColor.redColor(), range: range)
                attributedSentences.append(mutableString)
				
            default:    // case 1,3,4,5,6,7,11,12,15,17,18,20,22,23,24,25: Normal Sentences
                let mutableString = NSMutableAttributedString(
					string: sentence,
					attributes: [NSFontAttributeName:UIFont(name: "Calibri", size: 13.0)!])
                attributedSentences.append(mutableString)
            }
        }
        
        return attributedSentences
    }
    
    private func initializeFaqView() {
        var attributedSentences = customizeSentences(faqSentences)
        let width = UIScreen.mainScreen().bounds.size.width
    
        faqView = UIView(frame: CGRectMake(width * 0.1, self.scrollView.frame.height * 0.1, width * 0.8, 9999))
        var y: CGFloat = 20
        
        for i in 1...attributedSentences.count {
            if linesWithSpacing.indexOf(i) >= 0 {
                y += lineSpacing
            }
            let label: UILabel = UILabel(frame: CGRect(x: 0, y: y, width: width * 0.8, height: 9999))
            label.attributedText = attributedSentences[i - 1]
            label.ResizeHeigthWithText(label)
            y += label.frame.size.height
            faqView.addSubview(label)
            
        }
        faqView.frame.size.height = y + 50
        scrollView.addSubview(faqView)
        scrollView.contentSize = CGSizeMake(width, self.faqView.frame.size.height)
		
		//let bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
        //self.scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    // MARK: - ScrollView Methods Delegate
	
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print(self.faqView.frame.size)
        print(self.scrollView.contentSize)
        if scrollView.contentOffset.x > 0 || scrollView.contentOffset.x < 0 {
            scrollView.contentOffset.x = 0
        }
    }
}
