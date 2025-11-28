# DiffusionLens Demo Guide

This repository now includes three demo scripts to help you verify and understand the DiffusionLens method.

## Quick Start

**Recommended for first-time users:**
```bash
conda activate diffusionlens
./demo_paper_prompts_sd14.sh
```

This will generate images showing how text encoder layers progressively build concepts, using prompts from the paper.

## Demo Scripts Overview

| Script | Model | Time (GPU) | Time (CPU) | Use Case |
|--------|-------|------------|------------|----------|
| `demo_test.sh` | SD 1.4 | 1-3 min | 20-60 min | Quick verification |
| `demo_paper_prompts_sd14.sh` ⭐ | SD 1.4 | 5-15 min | 1-3 hrs | Recommended demo |
| `demo_paper_params.sh` | DeepFloyd IF | 10-30 min | Many hrs | Exact paper recreation |

## What You'll See

The demo generates a series of images showing how the text encoder builds understanding across layers:

**Example: "A cake on a butterfly"**
```
Layer 0  → Vague shapes, minimal understanding
Layer 4  → Some concepts emerge (cake? butterfly?)
Layer 8  → Concepts more defined but not composed
Layer 12 → Full understanding: cake ON butterfly
```

This progressive refinement is the core insight of the DiffusionLens paper.

## Prerequisites

1. **Install Environment:**
   ```bash
   conda create --name diffusionlens --file requirements_2024.txt
   conda activate diffusionlens
   ```

2. **Setup Modified Diffusers:**
   - Download diffusers v0.20.2: https://github.com/huggingface/diffusers/tree/v0.20.2
   - Rename to `diffusers_local` in project root
   - Replace pipeline files (see CLAUDE.md for details)

3. **GPU Recommended:**
   - CPU works but is 10-100x slower
   - Code auto-detects and uses best available device

## Running Demos

### 1. Quick Test (Verify Installation)
```bash
./demo_test.sh
```
- Uses minimal parameters
- Single simple prompt
- Fast verification that everything works

### 2. Paper Prompts Demo (Recommended)
```bash
./demo_paper_prompts_sd14.sh
```
- Uses 6 prompts from the paper
- SD 1.4 model (fast, small)
- Shows layer progression clearly
- Good balance of speed and demonstration

### 3. Exact Paper Recreation
```bash
./demo_paper_params.sh
```
- Uses DeepFloyd IF model (as in paper)
- Same layer intervals as paper (8, 12, 16, 24)
- Requires 20GB+ VRAM
- Most authentic recreation

## Understanding the Output

### Directory Structure
```
generations/<demo_name>/
└── <prompt>/
    └── sd1.4/  (or v1 for DeepFloyd)
        └── encoder_full_direct/
            ├── all_images/
            │   ├── full_layer_0_idx_0.png
            │   ├── full_layer_4_idx_0.png
            │   ├── full_layer_8_idx_0.png
            │   └── full_layer_12_idx_0.png
            ├── layer_0.png
            ├── layer_4.png
            ├── layer_8.png
            └── layer_12.png
```

### File Types
- **`full_layer_N_idx_i.png`**: Individual images (in all_images/)
- **`layer_N.png`**: Grid visualization of all seeds for that layer

## Prompts from Paper

The demos use these prompts from the paper's examples:

**Conceptual Combination:**
- "A cake on a butterfly"
- "A yellow pickup truck and a pink horse"
- "An orchid on a boat"

**Memory Retrieval:**
- "A babirusa" (uncommon animal)

**Identity:**
- "Simone Biles"
- "Steve Jobs"

See `inputs/paper_prompts.txt` for the full list.

## Manual Execution

You can also run experiments manually:

```bash
# Basic usage
python -u run_experiment.py \
    --model_key sd1.4 \
    --img_num 1 \
    --generate \
    --step_layer 4 \
    --folder_name my_test \
    --input_filename paper_prompts.txt

# With custom parameters
python -u run_experiment.py \
    --model_key sd2.1 \
    --img_num 4 \
    --generate \
    --start_layer 0 \
    --end_layer 20 \
    --step_layer 5 \
    --folder_name custom_demo \
    --input_filename your_prompts.txt
```

## Key Parameters

- `--model_key`: Model to use (sd1.4, sd2.1, v1, sdxl)
- `--img_num`: Images per layer (more = slower but better statistics)
- `--step_layer`: Layers to skip between generations
- `--start_layer`: Starting layer (default: 0)
- `--end_layer`: Ending layer (default: model's last layer)
- `--folder_name`: Output directory name
- `--input_filename`: Prompt file in inputs/ folder

## Troubleshooting

### "ModuleNotFoundError: No module named 'diffusers'"
**Solution:** Activate conda environment first
```bash
conda activate diffusionlens
```

### "ModuleNotFoundError: No module named 'diffusers_local'"
**Solution:** Setup modified diffusers (see Prerequisites above)

### CUDA Out of Memory
**Solution 1:** Use smaller model
```bash
--model_key sd1.4  # Instead of v1 or sdxl
```

**Solution 2:** Reduce images per layer
```bash
--img_num 1  # Instead of 4
```

**Solution 3:** Use CPU (slow but works)
```bash
# Code auto-detects, no flag needed
```

### Images Look Wrong
- Early layers (0-4) should look abstract/incorrect - this is expected!
- Only final layer should look fully correct
- If all layers look the same, check that diffusers_local is properly set up

## Using Google Colab

For GPU access without local hardware:

1. Upload `DIffusion_Lens.ipynb` to Google Colab
2. Enable GPU: Runtime → Change runtime type → GPU
3. Run cells sequentially
4. Modify `skip_layers` parameter to test different layers

## Next Steps

After running demos:

1. **Compare with paper:** Check your outputs against `images/examples.png`
2. **Try custom prompts:** Create your own prompts.txt file
3. **Adjust parameters:** Experiment with different step_layer values
4. **Analyze results:** Look for concept emergence patterns
5. **Read the paper:** Understand the theoretical framework

## References

- **Paper:** "DiffusionLens: Interpreting Text Encoders in Text-to-Image Pipelines"
- **arXiv:** 2403.05846v2
- **Code:** This repository
- **Examples:** See `images/examples.png` and `images/method.png`

## Support

For issues:
1. Check DEMO_VERIFICATION.md for detailed verification steps
2. Read CLAUDE.md for architecture details
3. Verify prerequisites are installed correctly
4. Check that CUDA is available (if using GPU)
