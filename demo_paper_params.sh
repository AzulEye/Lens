#!/bin/bash
# Demo script using exact prompts and parameters from the DiffusionLens paper
# Paper: "Interpreting Text Encoders in Text-to-Image Pipelines"

echo "=== DiffusionLens Paper Recreation Demo ==="
echo ""
echo "Prompts from paper:"
echo "  - A cake on a butterfly"
echo "  - A yellow pickup truck and a pink horse"
echo "  - An orchid on a boat"
echo "  - A babirusa (uncommon animal)"
echo "  - Simone Biles"
echo "  - Steve Jobs"
echo ""
echo "Parameters (from method diagram):"
echo "  Model: DeepFloyd IF (v1) - as used in paper"
echo "  Layers: 8, 12, 16, 24 (Final)"
echo "  Step layer: 4"
echo "  Images per layer: 4 (for statistical robustness)"
echo ""
echo "Expected output:"
echo "  generations/paper_demo/<prompt>/"
echo "    ├── layer_8.png   (Early-mid layers)"
echo "    ├── layer_12.png  (Mid layers)"
echo "    ├── layer_16.png  (Mid-late layers)"
echo "    └── layer_24.png  (Final layer)"
echo ""

# Check environment
if ! python -c "import diffusers" 2>/dev/null; then
    echo "ERROR: diffusers package not found"
    echo "Please activate conda environment:"
    echo "  conda activate diffusionlens"
    exit 1
fi

# Check CUDA
if python -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
    echo "✓ CUDA available - will use GPU"
    echo "⚠ WARNING: DeepFloyd IF requires ~20GB VRAM"
else
    echo "⚠ CUDA not available - will use CPU"
    echo "⚠ WARNING: DeepFloyd IF on CPU will be EXTREMELY slow (hours per image)"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "Running experiment with paper parameters..."
echo "(This may take 10-30 minutes on GPU, much longer on CPU)"
echo ""

# Run with paper parameters
python -u run_experiment.py \
    --model_key v1 \
    --img_num 4 \
    --generate \
    --start_layer 8 \
    --step_layer 4 \
    --folder_name paper_demo \
    --input_filename paper_prompts.txt

# Check results
if [ -d "generations/paper_demo" ]; then
    echo ""
    echo "=== Success! ==="
    echo ""
    echo "Generated images by prompt:"
    for prompt_dir in generations/paper_demo/*/; do
        prompt_name=$(basename "$prompt_dir")
        image_count=$(find "$prompt_dir" -name "*.png" -type f | wc -l)
        echo "  $prompt_name: $image_count images"
    done
    echo ""
    echo "Total images: $(find generations/paper_demo -name '*.png' -type f | wc -l)"
    echo ""
    echo "Compare these with images/examples.png from the paper!"
else
    echo ""
    echo "=== Error: Output directory not created ==="
    exit 1
fi
