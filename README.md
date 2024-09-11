https://github.com/OpenDriveLab/UniAD

### 数据集准备及训练说明

[模型以及info下载 Google Drive](https://drive.google.com/drive/folders/1ik1MAnYm4iwZSSF4juPBDIEXLeSOXY8d?usp=sharing)

[nuScenes数据集说明](docs/nuScenes数据集说明.md)

[数据集准备](docs/PrepareDatasets.md)

[训练说明](docs/TrainEval.md)

### 训练环境及配置

| 环境 | GPU 配置 | 数据集规模 | 阶段 | Queue Length | 显存占用 | 训练时长 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 官方 | A100 * 8 | 完整数据集 850 场景 | 1 | 5 | 50GB | 约 2 天 | `queue length`显著影响显存需求，也显著影响训练效果 |
| 官方 | A100 * 8 | 完整数据集 850 场景 | 2 | 3 | 17GB | 约 4 天 | `BEV encoder` 被冻结，`queue length`减小，显存需求下降 |
| 个人 | 4090 * 1 | 1/10 数据集 85 场景 | 1 | 1 | 18GB | 约 1天 18小时 | 仅调整`workers per gpu`等参数未明显改善显存占用 |
| 个人 | 4090 * 1 | 1/10 数据集 85 场景 | 2 | 3 | 17GB | 未训练 |  |
| 云端 | A100 * 4 | mini 数据集 10 场景 | 1 | 5 | 50GB | 约 1小时 | 显存足够会给每个显卡都分配 50GB |
| 云端 | A100 * 4 | mini 数据集 10 场景 | 2 | 3 | 17GB | 约 2小时 20分 |  |
| 预计 | A100 * 4 | 完整数据集 850 场景 | 1 | 5 | 50GB | 约 85 小时 | 用平均一个epoch的时长估算 |
| 预计 | A100 * 4 | 完整数据集 850 场景 | 2 | 3 | 17GB | 约 170 小时 | 和官方用8张A100训练时长的两倍比较接近 |

**说明:** 

1. 数据集大小主要影响训练时间；
2.  queue length（BEV 特征时序上下文信息长度）对训练的效果有较大的影响；
3. 一个 batch 都需要占用较大的显存，显存占用基本只取决于 queue length；
4. 调整其他如 workers per gpu 等参数，效果均不佳；
5. 4090 训练性能不排除 官方环境使用的是 CUDA 11.1 导致 新架构没法高效利用 的原因；

### 训练结果对比

统一在 mini 测试集下的 eval 任务，test frame 数量 81张

[推理流程简析](docs/推理流程简析.md)

### Tracking

| 指标 | 官方全数据集 | 自训练mini数据集 |
| --- | --- | --- |
| AMOTA↑ | 0.374 | 0.248 |
| AMOTP↓ | 1.201 | 1.394 |
| IDS↓ | 105 | 65 |
| RECALL↑ | 0.520 | 0.383 |

### Motion

| 指标 | 官方全数据集 | 自训练mini数据集 |
| --- | --- | --- |
| min_ADE↓ | 0.451 | 0.903 |
| min_FDE↓ | 0.562 | 1.385 |
| miss_rate(MR)↓ | 0.059 | 0.116 |
| EPA↑ | 0.608 | 0.381 |

### Occupancy Prediction

| 指标 | 官方全数据集 | 自训练mini数据集 |
| --- | --- | --- |
| IoU-n↑ | 66.0 | 47.7 |
| IoU-f↑ | 44.9 | 33.6 |
| VPQ-n↑ | 54.9 | 9.4 |
| VPQ-f↑ | 35.1 | 4.9 |

### Planning

| 指标 (L2 Distance) | 官方全数据集 | 自训练mini数据集 |
| --- | --- | --- |
| 1s↓ | 0.4395 | 1.1872 |
| 2s↓ | 0.9977 | 2.6354 |
| 3s↓ | 1.8206 | 4.4769 |
| avg↓ | 1.0859 | 2.7665 |

结果说明：

1. eval_mod 在 config 的 base_e2e 中，用于 mmdet3d_plugind 的nuscenes_e2e_dataset 中；
2. 指标结果如何统计（参考issue #98）

https://github.com/OpenDriveLab/UniAD/issues/98

### 代码执行指令和问题修正

- **重要注释**: 若使用自定义的info，修改config中对应stage的`base`配置，设置`img_root`为空字符串（''），避免路径错误。（参考issue #13）

https://github.com/OpenDriveLab/UniAD/issues/13

### 代码执行

```bash
# 评估
./tools/uniad_dist_eval.sh ./projects/configs/stage2_e2e/base_e2e.py ./ckpts/uniad_base_e2e.pth 4

# 训练
./tools/uniad_dist_train.sh ./projects/configs/stage1_track_map/base_track_map.py 4
./tools/uniad_dist_train.sh ./projects/configs/stage2_e2e/base_e2e.py 4
```

### 推理结果处理

/projects/mmdet3d_plugin/uniad/detectors/uniad_e2e.py

在这段代码中，`UniAD`类实现了从模型中读取输入数据并进行推理的逻辑。以下是详细的分析：

### 输入数据

模型的输入主要包括以下内容：

1. **图像数据 (`img`)**：包含每个样本的图像数据，形状为 `(N, C, H, W)`。
2. **图像元数据 (`img_metas`)**：包含每个样本的元数据，如传感器信息、时间戳等。
3. **3D边界框 (`gt_bboxes_3d`)**：每个样本的3D边界框。
4. **3D标签 (`gt_labels_3d`)**：每个样本的3D标签。
5. **轨迹信息**：
    - 过去轨迹 (`gt_past_traj`)，
    - 未来轨迹 (`gt_fut_traj`)，
    - 自主车未来轨迹 (`gt_sdc_fut_traj`)。
6. **分割和占用预测数据**：
    - 分割标签 (`gt_segmentation`)，
    - 实例分割 (`gt_instance`)。
7. **规划信息**：
    - 自主车规划 (`sdc_planning`)，
    - 命令信息 (`command`)。

### 推理流程

1. **检测和跟踪**：调用 `self.forward_track_train` 方法，进行检测和跟踪，生成 BEV（鸟瞰图）嵌入。
2. **分割**：如果包含分割头，则调用 `self.seg_head.forward_train` 方法，进行语义分割和地图生成。
3. **运动预测**：如果包含运动预测头，则调用 `self.motion_head.forward_train` 方法，进行运动预测，生成轨迹和状态预测。
4. **占用预测**：如果包含占用预测头，则调用 `self.occ_head.forward_train` 方法，进行占用预测。
5. **规划**：如果包含规划头，则调用 `self.planning_head.forward_train` 方法，进行规划预测，生成未来的路径和动作。

### 输出处理

1. **合并损失**：各个任务的损失会根据权重进行加权，并合并到最终的损失字典中。
2. **去除冗余信息**：使用 `pop_elem_in_result` 方法，从结果字典中移除不必要的信息，如 `query`、`embedding` 等。

### 测试流程

在测试流程中，主要步骤如下：

1. **初始化和同步**：同步前一帧的信息，计算自车的位置和角度变化。
2. **调用简单测试方法**：调用 `self.simple_test_track` 方法，进行检测和跟踪。
3. **分割、运动和占用预测**：调用相应的头`dense_heads`进行推理，生成结果。
4. **规划**：进行规划预测，并合并到最终的结果中。
5. **格式化结果**：将结果按照预定义的格式进行整理，并返回结果。

在 `UniAD` 类的 `forward_test` 方法中，`result` 字典包含了以下任务的预测结果：

1. **Tracking**（跟踪）：
    - 包含跟踪结果的 BEV（鸟瞰图）嵌入和相关的轨迹信息。
2. **Segmentation**（分割）：
    - 包含语义分割和地图生成的结果，包括分割标签和掩码。
3. **Motion Prediction**（运动预测）：
    - 包含运动预测的结果，包括未来轨迹和状态预测。
4. **Occupancy Prediction**（占用预测）：
    - 包含占用预测的结果，包括分割掩码、未来状态的占用信息。
5. **Planning**（规划）：
    - 包含规划的结果，包括未来路径和动作的规划信息。

### 具体结果打包内容

在 `forward_test` 方法中，以下内容被打包到 `result` 字典中：

1. **跟踪结果** (`result_track`):
    - `bev_embed`：鸟瞰图嵌入。
    - 其他跟踪相关的中间结果，如轨迹嵌入等。
2. **分割结果** (`result_seg`):
    - `lane_labels`：车道线标签。
    - `lane_masks`：车道线掩码。
3. **运动预测结果** (`result_motion`):
    - `future_trajectories`：未来轨迹。
    - `motion_states`：运动状态预测。
4. **占用预测结果** (`result_occ`):
    - `segmentation_masks`：分割掩码。
    - `occupancy_states`：未来状态的占用信息。
5. **规划结果** (`result_planning`):
    - `planning_paths`：规划路径。
    - `planning_commands`：规划命令。

    5. **规划结果** (`result_planning`):
    - `planning_paths`：规划路径。
    - `planning_commands`：规划命令。
