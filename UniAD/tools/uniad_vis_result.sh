#!/bin/bash
export PYTHONPATH="$(dirname $0)/..":$PYTHONPATH
python ./tools/analysis_tools/visualize/run.py \
    --predroot ./output/results.pkl \
    --out_folder ./output/official \
    --demo_video ./output/official/demo_video.avi \
    --project_to_cam True