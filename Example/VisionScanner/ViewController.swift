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
        
        scanner = VisionScannerViewController.instantiate(logger: logger)
        scanner.visionDelegate = self
        
        addChild(scanner)
        containerView.addSubview(scanner.view)
        scanner.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scanner.view.frame = containerView.bounds
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
