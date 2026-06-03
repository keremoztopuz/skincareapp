# SkinCare Graduation Pitch Memory

This file is the working memory for preparing the Computer Engineering Graduation Project pitch deck.

## Required Presentation Intent

The presentation must not be a pure technical report. It must work as:

- Pitch
- Engineering proof
- Technical validation

The jury should be convinced that:

- The problem is worth solving.
- The proposed solution is meaningful.
- Real engineering work has been done.
- The system actually works.
- The team understands the technology and design decisions.

Recommended formula:

Problem -> Solution -> Demo -> Architecture -> Technical Decisions -> Validation -> Results -> Conclusion

## Required Slide Flow

1. Title
   - Project name
   - Student names
   - Supervisor
   - University
   - Department
   - Date

2. Problem Statement
   - Explain the real-world problem.
   - SkinCare angle: limited dermatology access, missed early symptoms, users struggle to understand skin conditions.

3. Proposed Solution
   - One simple sentence.
   - Suggested wording: AI-powered mobile skin analysis app that analyzes user photos and provides preliminary condition assessment and care recommendations.

4. Live Demo / Product Walkthrough
   - Show the system early.
   - Flow: open app -> take photo -> AI analyzes image -> results displayed.
   - If live demo is risky, use screenshots or screen recording.

5. Existing Solutions and Literature Review
   - Concise comparison table.
   - Compare studies/products by strengths and limitations.
   - Position our project as mobile + AI + academic prototype.

6. System Architecture
   - High-level only.
   - Suggested architecture: User -> Swift iOS App -> CoreML Model -> Local Persistence / Supabase / Gemini VLM.

7. Technology Stack
   - SwiftUI: iOS user interface.
   - CoreML: on-device model inference.
   - Python: training, evaluation, export tooling.
   - PyTorch + timm: ConvNeXt Tiny model development.
   - scikit-learn: metrics.
   - Matplotlib + Seaborn: metric and confusion matrix visualization.
   - Supabase: product/recommendation data.
   - Gemini VLM: secondary visual condition analysis.

8. Core Engineering Design
   - Explain technical decisions and why they were selected.
   - Important decision: use local CoreML inference for fast mobile prediction.
   - Important decision: parse raw CoreML multi-array scores manually because the exported model is not a label-based Vision classifier.
   - Important decision: model's second output class maps to Redness in the app. Keep this naming; do not rename UI to Eczema.

9. AI / Algorithm Design
   - Model: ConvNeXt Tiny via timm.
   - Input size: 384 x 384.
   - Number of classes: 5.
   - Training config:
     - Batch size: 32
     - Learning rate: 5e-5
     - Weight decay: 0.1
     - Detection threshold: 0.5
     - Warmup epochs: 5
     - Label smoothing: 0.1
     - Class weights: [1.0, 1.0, 1.0, 2.03, 4.23]
   - Model output order:
     - 0: Acne
     - 1: Redness in app terminology
     - 2: Psoriasis
     - 3: Eye_Bags
     - 4: Wrinkles

10. Database and Data Model
   - Keep high level.
   - Main entities: AnalysisRecord, UserProfile, RoutineItem, RoutineSuggestion.
   - AnalysisRecord stores condition, scores, date, image data, and derived skin metrics.

11. Testing and Validation
   - Functional tests to mention:
     - Camera capture
     - Image preprocessing
     - CoreML prediction
     - Result display
     - Analysis record persistence
     - Recommendation/routine generation
   - AI validation metrics:
     - Accuracy: 75.02%
     - Precision: 0.6818
     - Recall: 0.6012
     - F1 Score: 0.5846
   - Generated validation images:
     - `/Users/keremoztopuz/Desktop/Masaüstü - Mac/senior_design_project_ai_model/outputs/images/test_metrics.png`
     - `/Users/keremoztopuz/Desktop/Masaüstü - Mac/senior_design_project_ai_model/outputs/images/confusion_matrix.png`
     - `/Users/keremoztopuz/Desktop/Masaüstü - Mac/senior_design_project_ai_model/outputs/images/full_confusion_matrix.png`

12. Challenges and Solutions
   - Dataset limitations and class imbalance.
   - Eye_Bags and Wrinkles have lower recall than Acne, Redness, and Psoriasis.
   - CoreML export produced raw multi-array outputs instead of Vision classification labels.
   - Swift integration was fixed by manually normalizing input, running MLModel prediction, reading `scores`, applying sigmoid, and mapping outputs by index.
   - App terminology keeps Redness for the second model output.

13. Contributions and Achievements
   - End-to-end working iOS prototype.
   - Custom trained skin condition model.
   - CoreML integration.
   - On-device inference pipeline.
   - Result scoring and persistence.
   - Recommendation/routine support.
   - Metric visualization outputs.

14. Future Improvements
   - Larger and more balanced datasets.
   - Improve Eye_Bags and Wrinkles recall.
   - Add doctor verification workflow.
   - Add more skin condition categories.
   - Improve confidence calibration and threshold tuning.
   - More robust real-world testing.

15. Conclusion
   - Summarize problem, solution, working system, and achieved objectives.
   - Suggested wording: The proposed mobile AI system successfully performs preliminary skin condition assessment and demonstrates the feasibility of real-time AI-assisted skincare analysis.

16. Questions
   - Thank you / Q&A.

## Current Technical Notes

- SkinCare CoreML model path: `SkinCare/Model/skin_disease.mlpackage`.
- Python checkpoint path: `/Users/keremoztopuz/Desktop/Masaüstü - Mac/senior_design_project_ai_model/outputs/model/best_model.pth`.
- Python model config class names originally list `["Acne", "Eczema", "Psoriasis", "Eye_Bags", "Wrinkles"]`, but app terminology must keep the second class as Redness.
- Swift files involved in model integration:
  - `SkinCare/Resources/MLManager.swift`
  - `SkinCare/ViewModel/CameraViewModel.swift`
  - `SkinCare/Model/SkinCondition.swift`

## Deck Guidance

- Start with the problem, not CNN details.
- Show the working app early.
- Use screenshots or screen recording if live demo is risky.
- Keep architecture high level.
- Use metric plots and confusion matrices as engineering proof.
- Be honest about limitations, especially Eye_Bags and Wrinkles recall.
