import Foundation
import AVFoundation
import Combine

class LightSensor: NSObject, ObservableObject {
    @Published var isBright: Bool = false
    @Published var currentBrightness: Float = 0.0
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let brightnessThreshold: Float = 0.6
    private var consistentBrightFrames = 0
    private let requiredConsistentFrames = 60 // ~2 seconds at 30fps
    
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
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        do {
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
