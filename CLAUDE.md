# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

DiffusionLens is a research codebase for analyzing text encoders in text-to-image diffusion models. The method generates images from intermediate text encoder representations to understand how prompts are progressively built across encoder layers.

## Setup and Installation

### Environment Setup
```bash
conda create --name diffusionlens --file requirements_2024.txt
conda activate diffusionlens
```

### Required Manual Setup for Stable Diffusion/DeepFloyd Models

1. Download diffusers v0.20.2 from https://github.com/huggingface/diffusers (tag v0.20.2)
2. Rename the downloaded library to `diffusers_local` in the project root
3. Replace `diffusers_local/src/diffusers/pipelines/stable_diffusion/pipeline_stable_diffusion.py` with `pipeline_stable_diffusion.py` from this repo
4. For DeepFloyd IF model: Replace `diffusers_local/src/diffusers/pipelines/deepfloyd_if/pipeline_if.py` with `pipeline_if.py` from this repo

Note: The modified pipeline files add layer-skipping capabilities essential for DiffusionLens analysis.

## Running Experiments

### Basic Generation Command
```bash
python -u run_experiment.py --model_key v1 --img_num 4 --generate --step_layer 4 --folder_name <output_dir> --input_filename <prompt_file>
```

### Key Parameters
- `--model_key`: Model selection
  - `sd1.4`: Stable Diffusion 1.4 (default, smallest model ~4GB)
  - `sd2.1`: Stable Diffusion 2.1 (~5GB)
  - `v1`: DeepFloyd IF-I-XL-v1.0 (~20GB)
  - `sdxl`: Stable Diffusion XL (~7GB)
- `--img_num`: Number of images to generate per prompt and intermediate layer (default: 4)
- `--step_layer`: Number of encoder layers to skip between each generated image (default: 4)
- `--start_layer`: Starting layer index (default: 0)
- `--end_layer`: Ending layer index (default: None, uses all layers)
- `--input_filename`: Path to file containing prompts (one per line), should be in `inputs/` folder
- `--folder_name`: Output directory name (created under `generations/`)
- `--generate`: Flag to generate images
- `--evaluate`: Flag to evaluate generated images using CLIP scores

### Using the FLUX Notebook

The repository includes a Jupyter notebook (`DIffusion_Lens.ipynb`) implementing DiffusionLens with FLUX.1-schnell:

```python
# Key parameter in notebook
skip_layers = 24  # Number of layers to skip from the end of T5 encoder
```

The notebook uses a custom `DiffusionLensFluxPipeline` that modifies the text encoding process to extract intermediate representations.

## Architecture

### Core Components

**run_experiment.py**: Main experiment runner
- `CompositionalExperiment`: Main class orchestrating generation and evaluation
  - `run_experiment()`: Generates images from prompts across encoder layers
  - `create_dataset()`: Creates structured datasets for various compositional scenarios
  - `get_clip_scores()`: Evaluates generated images using CLIP/BLIP models
  - `create_plot()`: Visualizes how concepts emerge across layers

**main_sd.py**: Stable Diffusion/DeepFloyd pipeline wrapper
- `stable_glass_sd()`: Core function that initializes models and generates images
  - Handles model loading for SD 1.4, SD 2.1, SDXL, and DeepFloyd IF
  - Supports layer-based generation via `start_layer`, `end_layer`, `step_layer` parameters
  - Returns images generated from intermediate text encoder representations

**Modified Pipeline Files** (pipeline_stable_diffusion.py, pipeline_if.py):
- Override standard diffusers pipelines to intercept text encoder outputs
- Add layer-skipping logic: pass partial encoder outputs to the diffusion model
- This is the core mechanism enabling DiffusionLens analysis

### Compositional Item Types

The `CompositionalItem` class in run_experiment.py supports various prompt templates:
- `animal`: Single animal prompts
- `animal_object`: Animals with objects/clothing
- `object_size`: Size relationships between objects
- `animal_popularity`: Popular vs uncommon animals
- `woman_wearing`: Complex scenes with clothing and locations
- `shapes`: Geometric shapes with colors and surfaces
- `counting`: Counting multiple objects
- `relations`: Spatial relationships between objects
- `thing_color`: Objects with color attributes
- `two_things_color`: Two objects with different colors
- `None`: Custom prompts from file (most common usage)

### Data Flow

1. Prompts are loaded from `inputs/<filename>` or generated from templates
2. `stable_glass_sd()` initializes the diffusion pipeline with modified encoders
3. For each prompt, images are generated at multiple encoder layer depths
4. Each intermediate representation produces `img_num` images with different seeds
5. Images are saved to `generations/<folder_name>/`
6. Optional evaluation uses OpenCLIP or BLIP2 to score concept emergence

### Output Structure

Generated images are organized as:
```
generations/
  <folder_name>/
    <prompt_text>/
      layer_<N>_seed_<S>.png
```

## Common Development Tasks

### Testing a Single Prompt
```bash
python -u run_experiment.py --model_key sd2.1 --img_num 4 --generate --step_layer 4 --folder_name test_output --input_filename prompts.txt --number_of_inputs 1
```

### Analyzing Specific Layer Range
```bash
python -u run_experiment.py --model_key v1 --generate --start_layer 8 --end_layer 20 --step_layer 2 --folder_name layer_analysis --input_filename prompts.txt
```

### GPU Requirements

DeepFloyd IF and SDXL require significant VRAM (16GB+ recommended). Use `torch_dtype=torch.float16` for memory efficiency (already configured in the code).

## Key Implementation Details

- Text encoders: CLIP (SD models) or T5 (DeepFloyd IF, FLUX)
- The modified pipelines extract `hidden_states` from the encoder and select specific layer outputs
- Layer indexing: layer 0 is earliest, higher numbers are deeper layers
- Negative indexing in FLUX: `hidden_states[-(skip_layers + 1)]` retrieves representations from earlier layers
- Super-resolution pipeline (IF model only): Applied after base image generation for higher quality outputs

## Testing Notes

The codebase does not include formal unit tests. When making changes:
1. Test with a single prompt and small layer range first
2. Verify output images are generated in the expected directory structure
3. Check that layer indices match expectations (especially when modifying pipeline files)

### CPU Debugging

The code now supports CPU execution for debugging (though it will be very slow):
- Device detection is automatic - uses CUDA if available, falls back to CPU
- Check available device: `python -c 'import torch; print(torch.cuda.is_available())'`
- For CPU debugging, use the smallest model (`sd1.4`) with minimal parameters:
  ```bash
  python -u run_experiment.py --model_key sd1.4 --img_num 1 --generate --step_layer 8 --folder_name cpu_test --number_of_inputs 1 --input_filename prompts.txt
  ```
- CPU inference will be 10-100x slower than GPU and may require significant RAM (16GB+)
- The notebook (DIffusion_Lens.ipynb) is recommended for experiments - run it in Google Colab for free GPU access
