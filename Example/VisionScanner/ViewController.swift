//
//  ViewController.swift
//  VisionScanner
//
//  Created by egarro@aldogroup.com on 11/01/2018.
//  Copyright (c) 2018 egarro@aldogroup.com. All rights reserved.
//

import UIKit
import VisionScanner

class ViewController: UIViewController, VisionScannerDelegate {

    @IBOutlet var resultLabel : UILabel!
    @IBOutlet var containerView : UIView!
    var scanner: VisionScannerViewController!
    let logger:Logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner = VisionScannerViewController(logger: logger)
        scanner.visionDelegate = self
        
        addChild(scanner)
        containerView.addSubview(scanner.view)
        scanner.view.translatesAutoresizingMaskIntoConstraints = false
        scanner.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        scanner.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        scanner.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        scanner.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        scanner.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func stopScanner(_ sender: Any) {
        scanner.stopScan(completion: {
            print("scanner stopped")
        })
    }
    @IBAction func pauseScanner(_ sender: Any) {
        scanner.pauseScan(completion: {
            print("scanner paused")
        })
    }
    @IBAction func startScanner(_ sender: Any) {
        scanner.startScan(completion: {
            print("scanner started")
        })
    }
    
    func didScan(code string: String) {
        DispatchQueue.main.async {
            self.resultLabel.text = string
        }
    }
}


final class Logger: VisionScannerLogger {
    func log(message: String) {
        print(message)
    }
}
