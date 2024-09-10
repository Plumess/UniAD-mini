# nuScenes

Download nuScenes V1.0 full dataset data, CAN bus and map(v1.3) extensions [HERE](https://www.nuscenes.org/download), then follow the steps below to prepare the data.

### v1.0 full

samples, sweeps, v1.0-test, v1.0-trainval

### **can_bus**

直接放在 nuscenes 下即可

### **map extensions**

解压后的 basemap，expansion，prediction 文件夹放到 maps 下

**Download nuScenes, CAN_bus and Map extensions**

```bash
cd UniAD
mkdir data
# Download nuScenes V1.0 full dataset data directly to (or soft link to) UniAD/data/
# Download CAN_bus and Map(v1.3) extensions directly to (or soft link to) UniAD/data/nuscenes/
```

下载数据集时，meta 数据是对数据集的构建关系数据库的 json 文件，与几百GB的传感器数据一一对应，用来索引和指导训练/测试；其余都是数据集本身，各种传感器数据；

[www.nuscenes.org](https://www.nuscenes.org/nuscenes#data-format)

full 版本将 meta 拆分为了 trainval 和 test 两种，其中 train 和 val 应该是放在一起了，且没有标记区别，全部解压完成后应该如下：

```
nuscenes/
├── can_bus/
├── maps/
├── samples/
├── sweeps/
├── v1.0-test/
├── v1.0-trainval/
```

mini 是只有10个场景的小集，teaser 是包含100个场景的预发布集，也是 full 的子集；

mini 也是可以用的，在 tools/create_data.py 中 修改 version 为 mini，可以生成mini的训练和测试集的相应的info；

如果希望随机拆分，需要在 data_converter/uniad_nuscenes_converter.py 中使用nuscenes工具包获取的list进行随机选取，替换输出即可。或者使用nuscenes.utils.splits中的**get_scenes_of_custom_split函数**读取自定义的splits.json。

```python
    from nuscenes.utils import splits
    available_vers = ['v1.0-trainval', 'v1.0-test', 'v1.0-mini']
    assert version in available_vers
    if version == 'v1.0-trainval':
        train_scenes = splits.train
        val_scenes = splits.val
        # random split 1/10
        num_train_scenes = len(train_scenes)
        train_scenes = random.sample(train_scenes, num_train_scenes // 10)
        num_val_scenes = len(val_scenes)
        val_scenes = random.sample(val_scenes, num_val_scenes // 10)
    elif version == 'v1.0-test':
        train_scenes = splits.test
        # random split 1/10
        num_train_scenes = len(train_scenes)
        train_scenes = random.sample(train_scenes, num_train_scenes // 10)
        val_scenes = []
    elif version == 'v1.0-mini':
        train_scenes = splits.mini_train
        val_scenes = splits.mini_val
    else:
        raise ValueError('unknown')
```

[nuscenes-devkit/python-sdk/nuscenes/utils/splits.py at master · nutonomy/nuscenes-devkit](https://github.com/nutonomy/nuscenes-devkit/blob/master/python-sdk/nuscenes/utils/splits.py)

**Prepare UniAD data info**

*Option1: We have already prepared the off-the-shelf data infos for you:*

```bash
cd UniAD/data
mkdir infos && cd infos
wget https://github.com/OpenDriveLab/UniAD/releases/download/v1.0/nuscenes_infos_temporal_train.pkl  # train_infos
wget https://github.com/OpenDriveLab/UniAD/releases/download/v1.0/nuscenes_infos_temporal_val.pkl  # val_infos
```

*Option2: You can also generate the data infos by yourself:*
> The generated data path will contain the root directory. Please remember to change the `data_root` to empty in config files if using your generated pkl. Refer to https://github.com/OpenDriveLab/UniAD/issues/13.

```bash
cd UniAD/data
mkdir infos
./tools/uniad_create_data.sh
# This will generate nuscenes_infos_temporal_{train,val}.pkl
```

**Prepare Motion Anchors**

```bash
cd UniAD/data
mkdir others && cd others
wget https://github.com/OpenDriveLab/UniAD/releases/download/v1.0/motion_anchor_infos_mode6.pkl
```

**The Overall Structure**

*Please make sure the structure of UniAD is as follows:*

```
UniAD
├── projects/
├── tools/
├── ckpts/
│   ├── bevformer_r101_dcn_24ep.pth
│   ├── uniad_base_track_map.pth
|   ├── uniad_base_e2e.pth
├── data/
│   ├── nuscenes/
│   │   ├── can_bus/
│   │   ├── maps/
│   │   ├── samples/
│   │   ├── sweeps/
│   │   ├── v1.0-test/
│   │   ├── v1.0-trainval/
│   ├── infos/
│   │   ├── nuscenes_infos_temporal_train.pkl
│   │   ├── nuscenes_infos_temporal_val.pkl
│   ├── others/
│   │   ├── motion_anchor_infos_mode6.pkl
```

---