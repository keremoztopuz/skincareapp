//
//  MLManager.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import CoreML
import UIKit

class MLManager {
// MARK: Model Loading
    private var model : MLModel?
    private let classLabels: [SkinCondition] = [.acne, .redness, .psoriasis]
    
    init() {
        do {
            let config = MLModelConfiguration()
            let coreModel = try skin_disease(configuration: config)
            self.model = coreModel.model
        } catch {
            print("model not loaded")
        }
    }
// MARK: Model Implementation
    func detect(image: UIImage, completion: @escaping (SkinCondition?, Double) -> Void ) {
        let inputSize = 384
        let mean: [Float] = [0.5942, 0.4433, 0.3871]
        let std: [Float] = [0.2427, 0.2027, 0.1930]

        guard let model,
              let resized = image.resizedForML(to: inputSize),
              let cgImage = resized.cgImage,
              let tensor = try? MLMultiArray(shape: [1, 3, inputSize, inputSize] as [NSNumber], dataType: .float32) else {
            completion(nil, 0)
            return
        }

        var pixels = [UInt8](repeating: 0, count: inputSize * inputSize * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &pixels,
            width: inputSize,
            height: inputSize,
            bitsPerComponent: 8,
            bytesPerRow: inputSize * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            completion(nil, 0)
            return
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: inputSize, height: inputSize))

        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(tensor.dataPointer))
        let hw = inputSize * inputSize
        for c in 0..<3 {
            for i in 0..<hw {
                let raw = Float(pixels[i * 4 + c]) / 255.0
                ptr[c * hw + i] = (raw - mean[c]) / std[c]
            }
        }

        do {
            let input = try MLDictionaryFeatureProvider(dictionary: ["image": MLFeatureValue(multiArray: tensor)])
            let output = try model.prediction(from: input)
            let scores = output.featureValue(for: "scores")?.multiArrayValue
                ?? output.featureNames.compactMap { output.featureValue(for: $0)?.multiArrayValue }.first

            guard let scores else {
                completion(nil, 0)
                return
            }

            func sigmoid(_ x: Double) -> Double { 1.0 / (1.0 + exp(-x)) }

            let probabilities = classLabels.enumerated().map { index, label in
                (label, sigmoid(Double(truncating: scores[[0, index] as [NSNumber]])))
            }
            guard let top = probabilities.max(by: { $0.1 < $1.1 }) else {
                completion(nil, 0)
                return
            }

            completion(top.0, top.1)
        } catch {
            print("ML prediction error: \(error.localizedDescription)")
            completion(nil, 0)
        }
    }
}
