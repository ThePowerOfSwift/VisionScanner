//
//  VisionScannerViewController.swift
//  VisionScanner-Example
//
//  Created by Esteban Garro on 2018-10-30.
//  Copyright © 2018 ALDO Group. All rights reserved.
//

import AVKit
import UIKit
import Vision

public protocol VisionScannerLogger {
    func log(message: String)
}

public protocol VisionScannerDelegate: class {
    func didScan(code string: String)
}

public enum VisionScannerState: Equatable {
    case stopped
    case paused
    case active
}

public class VisionScannerViewController: UIViewController {
    
    private var previewView = VisionPreviewView(frame: .zero)
    
    private var captureSession: AVCaptureSession!
    private var requests = [VNRequest]()
    
    private var captureVideoOutput: AVCaptureVideoDataOutput!
    private var logger: VisionScannerLogger?
    
    public weak var visionDelegate: VisionScannerDelegate?
    public var currentState: VisionScannerState = .stopped
    
    public init(logger: VisionScannerLogger? = nil) {
        self.logger = logger
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        configureVideoCaptureSession()
    }
    
    private func initUI() {
        view.backgroundColor = .clear
        view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        previewView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func configureVideoCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            logger?.log(message: "Unable to find capture device")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            logger?.log(message: "Unable to obtain video input")
            return
        }
        
        captureVideoOutput = AVCaptureVideoDataOutput()
        captureVideoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        captureSession = AVCaptureSession()
        previewView.session = captureSession
        
        guard captureSession.canAddInput(videoInput) else {
            logger?.log(message: "Unable to add input")
            return
        }
        
        guard captureSession.canAddOutput(captureVideoOutput) else {
            logger?.log(message: "Unable to add video output")
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        captureSession.addInput(videoInput)
        captureSession.addOutput(captureVideoOutput)
        captureSession.commitConfiguration()
    }
    
    private func reportResults(_ res: [Any]?) {
        guard let results = res, results.count > 0 else {
            logger?.log(message: "No results to report!")
            return
        }
        
        logger?.log(message: "Number of results: \(results.count)")
        results.map({$0 as? VNBarcodeObservation})
               .compactMap({$0?.payloadStringValue})
               .forEach({ (payload) in
                    DispatchQueue.main.async {
                        self.visionDelegate?.didScan(code: payload)
                    }
               })
    }

    deinit {
        stopScan()
    }
    
    public func stopScan(completion: (()->Void)? = nil) {
        guard captureSession != nil else {
            logger?.log(message: "Stop: No capture session present.")
            completion?()
            return
        }
        
        logger?.log(message: "Scanner stopped")
        if captureSession.isRunning {
            captureSession.stopRunning()
        }

        previewView.clear()
        currentState = .stopped
        completion?()
    }
    
    public func pauseScan(completion: (()->Void)? = nil) {
        guard captureVideoOutput != nil else {
            logger?.log(message: "Pause: No captureVideoOutput present.")
            completion?()
            return
        }
        
        logger?.log(message: "Scanner paused")
        currentState = .paused
        self.requests.removeAll()
        captureVideoOutput.setSampleBufferDelegate(nil, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        completion?()
    }
    
    public func resetScan() {
        // Does nothing here
        logger?.log(message: "ResetScan: Not implemented")
    }
    
    public func startScan(completion: (()->Void)? = nil) {
        guard captureSession != nil else {
            logger?.log(message: "Start: No capture session present.")
            completion?()
            return
        }
        
        logger?.log(message: "Scanner started")
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
        
        captureVideoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        previewView.updateVideoOrientationForDeviceOrientation()
        
        startBarcodeDetection()
        currentState = .active
        completion?()
    }
    
    private func startBarcodeDetection() {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { [weak self] in
            self?.detectBarcodeHandler(request: $0, error: $1)  })
        self.requests = [barcodeRequest]
    }
    
    private func detectBarcodeHandler(request: VNRequest, error: Error?) {
        if error != nil {
            logger?.log(message: error.debugDescription)
        }
        guard let barcodes = request.results else {
            logger?.log(message: "No barcode results to report")
            return
        }
        
        self.reportResults(barcodes)
    }
}


// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension VisionScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // Run Vision code with live stream
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        logger?.log(message: "Running")
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            logger?.log(message: "No pixel buffer found")
            return
        }
        
        var requestOptions: [VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics : camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}


