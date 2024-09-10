# #!/usr/bin/env bash

# T=`date +%m%d%H%M`

# # -------------------------------------------------- #
# # Usually you only need to customize these variables #
# CFG=$1                                               #
# GPUS=$2                                              #
# # -------------------------------------------------- #
# GPUS_PER_NODE=$(($GPUS<8?$GPUS:8))
# NNODES=`expr $GPUS / $GPUS_PER_NODE`

# MASTER_PORT=${MASTER_PORT:-28596}
# MASTER_ADDR=${MASTER_ADDR:-"127.0.0.1"}
# RANK=${RANK:-0}

# WORK_DIR=$(echo ${CFG%.*} | sed -e "s/configs/work_dirs/g")/
# # Intermediate files and logs will be saved to UniAD/projects/work_dirs/

# if [ ! -d ${WORK_DIR}logs ]; then
#     mkdir -p ${WORK_DIR}logs
# fi

# PYTHONPATH="$(dirname $0)/..":$PYTHONPATH \
# python -m torch.distributed.launch \
#     --nproc_per_node=${GPUS_PER_NODE} \
#     --master_addr=${MASTER_ADDR} \
#     --master_port=${MASTER_PORT} \
#     --nnodes=${NNODES} \
#     --node_rank=${RANK} \
#     $(dirname "$0")/train.py \
#     $CFG \
#     --launcher pytorch ${@:3} \
#     --deterministic \
#     --work-dir ${WORK_DIR} \
#     2>&1 | tee ${WORK_DIR}logs/train.$T



#!/usr/bin/env bash

T=`date +%m%d%H%M`

# -------------------------------------------------- #
# Usually you only need to customize these variables #
CFG=$1                                               #
GPUS=$2                                              #
# -------------------------------------------------- #
GPUS_PER_NODE=$(($GPUS<8?$GPUS:8))
NNODES=$(($GPUS / $GPUS_PER_NODE))

MASTER_PORT=${MASTER_PORT:-28596}
MASTER_ADDR=${MASTER_ADDR:-"127.0.0.1"}
RANK=${RANK:-0}

WORK_DIR=$(echo ${CFG%.*} | sed -e "s/configs/work_dirs/g")/
# Intermediate files and logs will be saved to UniAD/projects/work_dirs/

if [ ! -d ${WORK_DIR}logs ]; then
    mkdir -p ${WORK_DIR}logs
fi

# Set PYTHONPATH for both single GPU and multi-GPU cases
export PYTHONPATH="$(dirname $0)/..":$PYTHONPATH

# Check if GPUS is 1, and run the script without distributed launch if true
if [ $GPUS -eq 1 ]; then
    python $(dirname "$0")/train.py \
        $CFG \
        --launcher none ${@:3} \
        --deterministic \
        --work-dir ${WORK_DIR} \
        2>&1 | tee ${WORK_DIR}logs/train.$T
else
    python -m torch.distributed.run \
        --nproc_per_node=${GPUS_PER_NODE} \
        --nnodes=${NNODES} \
        --rdzv_backend=c10d \
        --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
        --node_rank=${RANK} \
        $(dirname "$0")/train.py \
        $CFG \
        --launcher pytorch ${@:3} \
        --deterministic \
        --work-dir ${WORK_DIR} \
        2>&1 | tee ${WORK_DIR}logs/train.$T
fi
