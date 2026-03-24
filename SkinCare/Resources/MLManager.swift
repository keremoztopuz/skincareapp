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
}
