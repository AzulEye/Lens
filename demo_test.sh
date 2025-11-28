#!/bin/bash
# Demo script to test DiffusionLens with minimal parameters
# This demonstrates generating images from intermediate text encoder layers

echo "=== DiffusionLens Demo Test ==="
echo ""
echo "This script will:"
echo "1. Use Stable Diffusion 1.4 (smallest model, 12 layers)"
echo "2. Generate images from layers 0, 4, 8, 12 (step_layer=4)"
echo "3. Create 1 image per layer (img_num=1)"
echo "4. Use prompt: 'A red apple on a wooden table'"
echo ""
echo "Expected output structure:"
echo "  generations/demo_test/A red apple on a wooden table/"
echo "    ├── layer_0_seed_0.png   (earliest layer - minimal concept)"
echo "    ├── layer_4_seed_0.png   (early-mid layer)"
echo "    ├── layer_8_seed_0.png   (mid-late layer)"
echo "    └── layer_12_seed_0.png  (final layer - full concept)"
echo ""
echo "Note: Requires conda environment 'diffusionlens' to be activated first"
echo "      See README.md for setup instructions"
echo ""

# Check if running in correct environment
if ! python -c "import diffusers" 2>/dev/null; then
    echo "ERROR: diffusers package not found"
    echo "Please activate conda environment:"
    echo "  conda activate diffusionlens"
    exit 1
fi

# Check CUDA availability
if python -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
    echo "✓ CUDA available - will use GPU"
else
    echo "⚠ CUDA not available - will use CPU (very slow!)"
fi

echo ""
echo "Running experiment..."
echo ""

# Run the experiment
python -u run_experiment.py \
    --model_key sd1.4 \
    --img_num 1 \
    --generate \
    --step_layer 4 \
    --folder_name demo_test \
    --input_filename test_prompt.txt \
    --number_of_inputs 1

# Check if output was created
if [ -d "generations/demo_test" ]; then
    echo ""
    echo "=== Success! ==="
    echo ""
    echo "Generated images:"
    find generations/demo_test -name "*.png" -type f | sort
    echo ""
    echo "Total images: $(find generations/demo_test -name '*.png' -type f | wc -l)"
else
    echo ""
    echo "=== Error: Output directory not created ==="
    exit 1
fi
