import Foundation
import AVFoundation
import Combine

class LightSensor: NSObject, ObservableObject {
    @Published var isBright: Bool = false
    @Published var currentBrightness: Float = 0.0
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    // Balanced threshold: 0.45
    // Allows bright indoor lights and window light (usually hits 0.5-0.6)
    // Filters out dim corners/ambient shadow (usually < 0.3)
    private let brightnessThreshold: Float = 0.45
    
    // ~1 second consistency (30 frames) to prevent glitches
    private let requiredConsistentFrames = 30
    private var consistentBrightFrames = 0
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async { self.setupSession() }
                }
            }
        default:
            print("Camera permission denied")
        }
    }
    
    private func setupSession() {
        // Switch to FRONT camera for easier "selfie with light" detection
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            // LOCK EXPOSURE: Prevent auto-brightening in dark
            try device.lockForConfiguration()
            if device.isExposureModeSupported(.custom) {
                // Set to low exposure duration and low ISO to ensure DARK is DARK
                let duration = CMTime(value: 1, timescale: 60) // 1/60s shutter
                let iso = device.activeFormat.minISO // Minimum sensitivity
                device.setExposureModeCustom(duration: duration, iso: iso, completionHandler: nil)
            }
            device.unlockForConfiguration()
            
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func stop() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
    }
}

extension LightSensor: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Calculate average brightness from the center of the image to save performance
        // Simplification for MVP: Sample a few pixels or use metadata if available. 
        // Better approach: Extract luminosity from YpCbCr buffer (Y plane).
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // Assuming '420v' (YpCbCr) format which is standard for camera output
        // The first plane is the Y (Luma) plane.
        
        guard let baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0) else { return }
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        
        // Simple sampling strategy: Check center 100x100 area
        var totalLuma: UInt64 = 0
        let sampleSize = 100
        let startX = (width - sampleSize) / 2
        let startY = (height - sampleSize) / 2
        
        for y in 0..<sampleSize {
            let row = buffer.advanced(by: (startY + y) * bytesPerRow)
            for x in 0..<sampleSize {
                let luma = row[startX + x]
                totalLuma += UInt64(luma)
            }
        }
        
        let avgLuma = Float(totalLuma) / Float(sampleSize * sampleSize)
        let normalizedBrightness = avgLuma / 255.0
        
        DispatchQueue.main.async {
            self.currentBrightness = normalizedBrightness
            
            if normalizedBrightness > self.brightnessThreshold {
                self.consistentBrightFrames += 1
            } else {
                self.consistentBrightFrames = 0
            }
            
            if self.consistentBrightFrames >= self.requiredConsistentFrames {
                self.isBright = true
            }
        }
    }
}
