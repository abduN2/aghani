//
//  PlayerViewController.swift
//  aghani
//
//  Created by Abdulrahman Negmeldin on 2025-01-14.
//

import UIKit

class PlayerViewController: UIViewController {

    public var position: Int = 0
    public var songs: [Song] = []
    
    @IBOutlet var holder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if holder.subviews.count == 1 {
            configure()
        }
    }
    
    func configure() {
        //setup player
        
        
        //setup user interface elements
    }

}
