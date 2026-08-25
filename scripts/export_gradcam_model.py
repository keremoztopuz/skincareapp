#!/usr/bin/env python3
"""
Export skin_disease CoreML model with dual outputs:
  1. class_scores [1, 5]  — same logits as original model
  2. heatmaps [1, 5, 12, 12] — per-class CAM activation maps

Uses FC layer weights directly on stages[3] features (proper CAM).
No gradient computation needed — mathematically clean.
"""

import os
import torch
import torch.nn as nn
import timm
import coremltools as ct

IMG_SIZE = 384
NUM_CLASSES = 5
CLASS_NAMES = ["Acne", "Eczema", "Psoriasis", "Eye_Bags", "Wrinkles"]
MODEL_PATH = os.path.expanduser(
    "~/Desktop/Masaüstü - Mac/senior_design_project_ai_model/outputs/model/best_model-5.pth"
)
OUTPUT_DIR = os.path.expanduser("~/Projects/SkinCare/SkinCare/Model")


def load_base_model():
    model = timm.create_model(
        "convnext_tiny",
        num_classes=NUM_CLASSES,
        pretrained=False,
        drop_rate=0.3,
        drop_path_rate=0.2,
    )
    state = torch.load(MODEL_PATH, map_location="cpu")
    model.load_state_dict(state)
    model.eval()
    return model


class CAMModel(nn.Module):
    def __init__(self, base_model):
        super().__init__()
        self.stem = base_model.stem
        self.stages = base_model.stages
        self.pool = base_model.head.global_pool
        self.norm = base_model.head.norm
        self.flatten = base_model.head.flatten
        self.fc = base_model.head.fc
        # FC weights: [5, 768] — learned importance of each channel per class
        self.register_buffer("fc_w", base_model.head.fc.weight.detach().clone())

    def forward(self, image):
        x = self.stem(image)
        x = self.stages[0](x)
        x = self.stages[1](x)
        x = self.stages[2](x)
        feat = self.stages[3](x)  # [1, 768, 12, 12]

        # Scores — exact same path as original model
        pooled = self.pool(feat)
        normed = self.norm(pooled)
        flat = self.flatten(normed)
        scores = self.fc(flat)  # [1, 5]

        # CAM: weighted sum of feature maps using FC weights
        # fc_w[c, k] = how important channel k is for class c
        cam = torch.einsum("oi,bihw->bohw", self.fc_w, feat)
        cam = torch.relu(cam)  # [1, 5, 12, 12]

        return scores, cam


def export():
    print("Loading model weights …")
    base = load_base_model()

    print("Building CAM model with FC weights …")
    cam_model = CAMModel(base)
    cam_model.eval()

    dummy = torch.randn(1, 3, IMG_SIZE, IMG_SIZE)
    with torch.no_grad():
        orig_scores = base(dummy)
        new_scores, heatmaps = cam_model(dummy)
        assert torch.allclose(orig_scores, new_scores, atol=1e-5), "Score mismatch!"
        print(f"  Scores match ✓   Heatmap shape: {heatmaps.shape}")

    print("Tracing model …")
    traced = torch.jit.trace(cam_model, dummy)

    print("Converting to CoreML …")
    mlmodel = ct.convert(
        traced,
        inputs=[ct.TensorType(shape=(1, 3, IMG_SIZE, IMG_SIZE), name="image")],
        outputs=[
            ct.TensorType(name="scores"),
            ct.TensorType(name="heatmaps"),
        ],
        minimum_deployment_target=ct.target.iOS18,
        compute_precision=ct.precision.FLOAT32,
    )

    mlmodel.author = "Berat Kerem Öztopuz"
    mlmodel.license = "MIT"
    mlmodel.short_description = (
        "Skin condition classifier (5 classes) with per-class CAM heatmaps. "
        "Outputs: scores [1,5], heatmaps [1,5,12,12]."
    )
    mlmodel.version = "2.0"

    out_path = os.path.join(OUTPUT_DIR, "skin_disease.mlpackage")
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    mlmodel.save(out_path)
    print(f"\nCoreML model saved to: {out_path}")
    print("Done.")


if __name__ == "__main__":
    export()
