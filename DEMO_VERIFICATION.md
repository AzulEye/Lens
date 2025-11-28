# DiffusionLens Demo Verification

## Available Demo Scripts

### 1. Quick Test Demo (`demo_test.sh`)
- **Purpose:** Verify code works with minimal parameters
- **Model:** SD 1.4 (smallest, fastest)
- **Prompt:** "A red apple on a wooden table"
- **Runtime:** 1-3 min GPU / 20-60 min CPU

### 2. Paper Prompts with SD 1.4 (`demo_paper_prompts_sd14.sh`) ⭐ RECOMMENDED
- **Purpose:** Reproduce paper results quickly
- **Model:** SD 1.4 (12 layers)
- **Prompts:** 6 prompts from paper
- **Layers:** 0, 4, 8, 12
- **Runtime:** 5-15 min GPU / 1-3 hours CPU

### 3. Paper Parameters Demo (`demo_paper_params.sh`)
- **Purpose:** Exact paper recreation
- **Model:** DeepFloyd IF (24 layers, as in paper)
- **Prompts:** 6 prompts from paper
- **Layers:** 8, 12, 16, 24 (as in paper's method diagram)
- **Runtime:** 10-30 min GPU (requires 20GB VRAM) / many hours CPU

## Test Configuration (Quick Test)

**Test Command:**
```bash
python -u run_experiment.py \
    --model_key sd1.4 \
    --img_num 1 \
    --generate \
    --step_layer 4 \
    --folder_name demo_test \
    --input_filename test_prompt.txt \
    --number_of_inputs 1
```

**Test Input:**
- Prompt: "A red apple on a wooden table"
- Model: Stable Diffusion 1.4 (12 layers total, layers 0-12)
- Step layer: 4 (generates images from layers 0, 4, 8, 12)
- Images per layer: 1

## Expected Output Structure

Based on code analysis (main_sd.py lines 200-239), the expected output is:

```
generations/demo_test/
└── A red apple on a wooden table/
    └── sd1.4/
        └── encoder_full_direct/
            ├── all_images/
            │   ├── full_layer_0_idx_0.png   # Layer 0 (earliest representation)
            │   ├── full_layer_4_idx_0.png   # Layer 4
            │   ├── full_layer_8_idx_0.png   # Layer 8
            │   └── full_layer_12_idx_0.png  # Layer 12 (final representation)
            ├── layer_0.png   # Grid visualization for layer 0
            ├── layer_4.png   # Grid visualization for layer 4
            ├── layer_8.png   # Grid visualization for layer 8
            └── layer_12.png  # Grid visualization for layer 12
```

**Total expected files:** 8 images
- 4 individual images (in `all_images/`)
- 4 grid visualizations (in `encoder_full_direct/`)

## How It Works

### Code Flow Analysis

1. **Input Processing** (run_experiment.py:664-702)
   - Reads prompt from `inputs/test_prompt.txt`
   - Creates `CompositionalItem` with the prompt
   - Passes to `stable_glass_sd()` function

2. **Model Loading** (main_sd.py:52-106)
   - Detects device (CUDA or CPU)
   - Loads Stable Diffusion 1.4 pipeline
   - Loads modified pipeline from `diffusers_local` with layer parameters

3. **Image Generation** (main_sd.py:200-210)
   - Calls modified SD pipeline with:
     - `start_layer=0` (default)
     - `end_layer=None` (uses all layers)
     - `step_layer=4` (skip 4 layers between generations)
   - Pipeline generates images at layers: 0, 4, 8, 12
   - Each call to the pipeline extracts intermediate text encoder representation

4. **Output Saving** (main_sd.py:222-239)
   - Creates output directory structure
   - Saves individual images: `full_layer_{N}_idx_{i}.png`
   - Creates grid visualizations: `layer_{N}.png`

### Modified Pipeline Behavior

The key modification in `pipeline_stable_diffusion.py` (not in standard diffusers):
- Text encoder normally produces final layer output
- Modified version extracts intermediate layer outputs
- Controlled by `start_layer`, `end_layer`, `step_layer` parameters
- Each intermediate representation is fed to the diffusion model to generate an image

### Expected Visual Progression

Based on the DiffusionLens paper's findings:

**Layer 0** (earliest):
- Minimal semantic understanding
- Basic token embeddings
- Image may be blurry or show incorrect concepts

**Layer 4** (early-mid):
- Some concept recognition starting
- "Red" and "apple" concepts beginning to form
- Rough composition

**Layer 8** (mid-late):
- Stronger concept integration
- "Red apple" more clearly defined
- Background elements emerging

**Layer 12** (final):
- Full prompt understanding
- Clear red apple on wooden table
- All details and relationships established

## Verification Steps

To verify the demo worked correctly:

1. **Check directory structure:**
   ```bash
   ls -R generations/demo_test/
   ```

2. **Count generated images:**
   ```bash
   find generations/demo_test -name "*.png" | wc -l
   # Expected: 8
   ```

3. **Verify layer progression:**
   ```bash
   ls generations/demo_test/A\ red\ apple\ on\ a\ wooden\ table/sd1.4/encoder_full_direct/all_images/
   # Should show: full_layer_0_idx_0.png, full_layer_4_idx_0.png,
   #              full_layer_8_idx_0.png, full_layer_12_idx_0.png
   ```

4. **Check image dimensions:**
   - SD 1.4 default output: 512x512 pixels
   - All images should be the same size

## Paper Prompts from Examples

The following prompts are from the paper's Figure 1 (images/examples.png):

**Conceptual Combination (testing compositional understanding):**
- "A cake on a butterfly" - unusual object combination
- "A yellow pickup truck and a pink horse" - two objects with colors
- "An orchid on a boat" - object placement

**Memory Retrieval (testing uncommon concepts):**
- "A babirusa" - uncommon animal (pig-deer)

**Famous People (testing identity understanding):**
- "Simone Biles" - Olympic gymnast
- "Steve Jobs" - tech entrepreneur

Additional prompts from method diagram (images/method.png):
- "A pink snail and an orange donut"
- "A yellow dolphin"
- "A cow"
- "A giraffe in a house"

These prompts test different aspects:
1. **Conceptual Combination:** How concepts merge across layers
2. **Memory Retrieval:** How rare concepts are built up
3. **Famous Faces:** How identity information emerges

## Running the Demo

### Prerequisites

1. Install conda environment:
   ```bash
   conda create --name diffusionlens --file requirements_2024.txt
   conda activate diffusionlens
   ```

2. Download and setup diffusers_local (see CLAUDE.md for details)

3. Ensure sufficient disk space (~5GB for model + outputs)

### Execution

```bash
# Using the provided script:
./demo_test.sh

# Or manually:
conda activate diffusionlens
python -u run_experiment.py --model_key sd1.4 --img_num 1 --generate \
    --step_layer 4 --folder_name demo_test --input_filename test_prompt.txt \
    --number_of_inputs 1
```

### Expected Runtime

- **With GPU (CUDA):** 1-3 minutes for 4 images
- **With CPU only:** 20-60 minutes (very slow, not recommended)

## Troubleshooting

**ModuleNotFoundError: No module named 'diffusers'**
- Solution: Activate conda environment first

**ModuleNotFoundError: No module named 'diffusers_local'**
- Solution: Follow manual setup in CLAUDE.md to create diffusers_local

**CUDA out of memory**
- Solution: Reduce img_num to 1 (done in demo)
- Or use CPU (very slow): Code now auto-detects and falls back

**No images generated**
- Check `generations/demo_test/` exists
- Look for error messages in console output
- Verify input file exists: `inputs/test_prompt.txt`

## Code Changes Made

✅ **Device Detection** (main_sd.py:35)
- Automatically detects CUDA availability
- Falls back to CPU if needed

✅ **Protected CUDA Calls** (main_sd.py:39-41, pipeline_*.py)
- All `torch.cuda.*` calls wrapped in availability checks

✅ **Dynamic Device Assignment** (main_sd.py:79, 87, 106)
- Replaced hardcoded `.to("cuda")` with `.to(device)`

✅ **Smallest Model Default** (run_experiment.py:1169)
- Changed default from `v1` (20GB) to `sd1.4` (4GB)

These changes ensure the demo can run even without GPU access (though slowly).
