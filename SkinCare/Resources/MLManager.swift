//
//  MLManager.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import CoreML
import Vision
import UIKit

class MLManager {
    
    private var model : VNCoreMLModel!
    
    init() {
        do {
            let config = MLModelConfiguration()
            let coreModel = try skin_disease(configuration: config)
            self.model = try VNCoreMLModel(for: coreModel.model)
        } catch {
            print("model not loaded")
        }
    }
    
    func detect(image: UIImage, completion: @escaping (SkinCondition?, Double) -> Void ) {
        guard let model = model, let ciImage = CIImage(image: image) else { return }
        
        let request = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil, 0)
                return
            }
            let condition = SkinCondition(rawValue: topResult.identifier)
            completion (condition, Double(topResult.confidence))
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        try? handler.perform( [request] )
    }
}
