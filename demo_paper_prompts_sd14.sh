#!/bin/bash
# Demo script using paper prompts but with SD 1.4 for faster testing
# SD 1.4 is smaller (~4GB) and faster than DeepFloyd IF (~20GB)

echo "=== DiffusionLens Demo with Paper Prompts (SD 1.4) ==="
echo ""
echo "Using prompts from paper but with Stable Diffusion 1.4 for speed"
echo ""
echo "Prompts:"
echo "  - A cake on a butterfly"
echo "  - A yellow pickup truck and a pink horse"
echo "  - An orchid on a boat"
echo "  - A babirusa"
echo "  - Simone Biles"
echo "  - Steve Jobs"
echo ""
echo "Parameters:"
echo "  Model: Stable Diffusion 1.4 (smaller, faster than paper's DeepFloyd IF)"
echo "  Layers: 0, 4, 8, 12 (Final) - SD 1.4 has 12 layers total"
echo "  Step layer: 4"
echo "  Images per layer: 1 (for speed)"
echo ""
echo "Expected output:"
echo "  generations/paper_demo_sd14/<prompt>/"
echo "    ├── layer_0.png   (Earliest layer)"
echo "    ├── layer_4.png   (Early-mid layers)"
echo "    ├── layer_8.png   (Mid-late layers)"
echo "    └── layer_12.png  (Final layer)"
echo ""

# Check environment
if ! python -c "import diffusers" 2>/dev/null; then
    echo "ERROR: diffusers package not found"
    echo "Please activate conda environment:"
    echo "  conda activate diffusionlens"
    exit 1
fi

# Check device
if python -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
    echo "✓ CUDA available - will use GPU (~2-5 minutes)"
else
    echo "⚠ CUDA not available - will use CPU (~30-60 minutes)"
fi

echo ""
echo "Running experiment..."
echo ""

# Run with SD 1.4 (faster than IF)
python -u run_experiment.py \
    --model_key sd1.4 \
    --img_num 1 \
    --generate \
    --step_layer 4 \
    --folder_name paper_demo_sd14 \
    --input_filename paper_prompts.txt

# Check results
if [ -d "generations/paper_demo_sd14" ]; then
    echo ""
    echo "=== Success! ==="
    echo ""
    echo "Generated images by prompt:"
    for prompt_dir in generations/paper_demo_sd14/*/; do
        prompt_name=$(basename "$prompt_dir")
        image_count=$(find "$prompt_dir" -name "*.png" -type f | wc -l)
        echo "  $prompt_name: $image_count images"
    done
    echo ""
    echo "Total images: $(find generations/paper_demo_sd14 -name '*.png' -type f | wc -l)"
    echo ""
    echo "Note: Results will differ from paper (which used DeepFloyd IF)"
    echo "      But the concept progression should be similar"
else
    echo ""
    echo "=== Error: Output directory not created ==="
    exit 1
fi
