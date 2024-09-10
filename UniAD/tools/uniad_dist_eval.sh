#!/usr/bin/env bash
T=`date +%m%d%H%M`

# -------------------------------------------------- #
# Usually you only need to customize these variables #
CFG=$1                                               #
CKPT=$2                                              #
GPUS=$3                                              #    
# -------------------------------------------------- #
GPUS_PER_NODE=$(($GPUS<8?$GPUS:8))

MASTER_PORT=${MASTER_PORT:-28596}
WORK_DIR=$(echo ${CFG%.*} | sed -e "s/configs/work_dirs/g")/
# Intermediate files and logs will be saved to UniAD/projects/work_dirs/

if [ ! -d ${WORK_DIR}logs ]; then
    mkdir -p ${WORK_DIR}logs
fi

# Set PYTHONPATH for both single GPU and multi-GPU cases
export PYTHONPATH="$(dirname $0)/..":$PYTHONPATH

# Check if GPUS is 1, and run the script without distributed launch if true
if [ $GPUS -eq 1 ]; then
    python $(dirname "$0")/test.py \
        $CFG \
        $CKPT \
        --launcher none ${@:4} \
        --eval bbox \
        --show-dir ${WORK_DIR} \
        2>&1 | tee ${WORK_DIR}logs/eval.$T
else
    python -m torch.distributed.run \
        --nproc_per_node=$GPUS_PER_NODE \
        --master_port=$MASTER_PORT \
        $(dirname "$0")/test.py \
        $CFG \
        $CKPT \
        --launcher pytorch ${@:4} \
        --eval bbox \
        --show-dir ${WORK_DIR} \
        2>&1 | tee ${WORK_DIR}logs/eval.$T
fi

