//
//  VideoPreviewView.swift
//  VisionScanner-Example
//
//  Created by Esteban Garro on 10/19/17.
//  Copyright © 2018 ALDO Group. All rights reserved.
//

import AVKit
import UIKit

internal class VisionPreviewView : UIView {
    private var sublayers : [CALayer]? = nil
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        if let subs = sublayers {
            layer.sublayers = subs
        }
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }
  
    func clear() {
        sublayers = layer.sublayers
        layer.sublayers = nil
    }
    
    func updateVideoOrientationForDeviceOrientation() {
        if let videoPreviewLayerConnection = videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = orientationMap[deviceOrientation], deviceOrientation.isPortrait || deviceOrientation.isLandscape else { return }
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    private var orientationMap: [UIDeviceOrientation : AVCaptureVideoOrientation] = [
        .portrait : .portrait,
        .portraitUpsideDown : .portraitUpsideDown,
        .landscapeLeft : .landscapeRight,
        .landscapeRight : .landscapeLeft,
    ]
}
