//
//  Extension.swift
//  Sumit_RaniumPractical_iOS
//
//  Created by Sam on 02/09/22.
//

import Foundation
import UIKit

//MARK:- Global var declaration
let dateFormatter = DateFormatter()
let date = Date()
let AppName = "NEO States"
 
extension UIColor {
    static let chartBarColour = #colorLiteral(red: 0.4784313725, green: 0.5058823529, blue: 1, alpha: 1)
    static let chartLineColour = #colorLiteral(red: 0.1764705882, green: 0.2509803922, blue: 0.3490196078, alpha: 1)
    static let chartReplacementColour = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    static let chartAverageColour = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    static let chartBarValueColour = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
    static let chartHightlightColour = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
}

extension UIViewController {
    //MARK:- for Showing Alert
    func setPresentAlert(withTitle title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
