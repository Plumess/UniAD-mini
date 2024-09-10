### sweeps 目录

`sweeps` 目录包含来自各种传感器的数据扫描。这些数据是连续采集的，用于表示在不同时间点的传感器数据。每个子目录代表一个特定的传感器，并包含以下内容：

- **CAM_FRONT**：前置摄像头的数据。
- **CAM_FRONT_RIGHT**：前右摄像头的数据。
- **CAM_BACK_RIGHT**：后右摄像头的数据。
- **CAM_BACK**：后置摄像头的数据。
- **CAM_BACK_LEFT**：后左摄像头的数据。
- **CAM_FRONT_LEFT**：前左摄像头的数据。
- **LIDAR_TOP**：顶部激光雷达的数据。
- **RADAR_FRONT**：前置雷达的数据。
- **RADAR_FRONT_RIGHT**：前右雷达的数据。
- **RADAR_BACK_RIGHT**：后右雷达的数据。
- **RADAR_BACK_LEFT**：后左雷达的数据。
- **RADAR_FRONT_LEFT**：前左雷达的数据。

每个子目录中的文件命名格式通常为`timestamp_sensor_token.fileformat`，例如：

```
n008-2018-08-01-15-16-36-0400__CAM_BACK__1533151603537558.jpg
n008-2018-08-01-15-16-36-0400__LIDAR_TOP__1533151603547590.pcd.bin
n008-2018-08-01-15-16-36-0400__RADAR_FRONT__1533151603555991.pcd
```

这些文件的时间戳和传感器token可以与`samples`中的数据进行对比和关联。

### samples 目录

`samples` 目录包含关键帧数据，这些数据通常是场景中预定义时间点的传感器数据。`samples` 目录的结构与`sweeps`目录相似，每个子目录代表一个特定的传感器，包含以下内容：

- **CAM_FRONT**：前置摄像头的关键帧数据。
- **CAM_FRONT_RIGHT**：前右摄像头的关键帧数据。
- **CAM_BACK_RIGHT**：后右摄像头的关键帧数据。
- **CAM_BACK**：后置摄像头的关键帧数据。
- **CAM_BACK_LEFT**：后左摄像头的关键帧数据。
- **CAM_FRONT_LEFT**：前左摄像头的关键帧数据。
- **LIDAR_TOP**：顶部激光雷达的关键帧数据。
- **RADAR_FRONT**：前置雷达的关键帧数据。
- **RADAR_FRONT_RIGHT**：前右雷达的关键帧数据。
- **RADAR_BACK_RIGHT**：后右雷达的关键帧数据。
- **RADAR_BACK_LEFT**：后左雷达的关键帧数据。
- **RADAR_FRONT_LEFT**：前左雷达的关键帧数据。

文件命名格式与`sweeps`目录中的文件类似，包含时间戳和传感器token。

### maps 目录

包含地图相关的图像数据，可视的表示驾驶环境中的道路网络、交叉口等。

### can_bus 目录（extension）

包含了 low-level 车辆数据，这些数据记录了车辆的行驶路线、惯性测量单元（IMU）数据、车辆姿态、转向角反馈、电池、刹车、档位、信号、车轮速度、油门、扭矩、太阳能传感器、里程计等信息。每个场景通常包含多个与车辆状态和传感器数据相关的文件。

### 元数据信息及其索引联动

### 1. scene.json

**记录信息**：

- **token**：每个scene的唯一标识符。
- **name**：scene的名称，便于识别。
- **description**：对scene的描述。
- **log_token**：关联的log记录的token。
- **nbr_samples**：该scene中的sample数量。
- **first_sample_token**：该scene中第一个sample的token。
- **last_sample_token**：该scene中最后一个sample的token。

### 2. sample.json

**记录信息**：

- **token**：每个sample的唯一标识符。
- **timestamp**：时间戳。
- **prev**：前一个sample的token。
- **next**：后一个sample的token。
- **scene_token**：关联的scene的token。

### 3. sample_data.json

**记录信息**：

- **token**：每个sample_data的唯一标识符。
- **sample_token**：关联的sample的token。
- **ego_pose_token**：车辆自我定位信息的token。
- **calibrated_sensor_token**：传感器校准信息的token。
- **filename**：文件名，包含数据的路径。
- **fileformat**：文件格式（如jpg, pcd）。
- **is_key_frame**：是否是关键帧。
- **height**：图像高度。
- **width**：图像宽度。
- **timestamp**：时间戳。
- **prev**：前一个sample_data的token。
- **next**：后一个sample_data的token。

### 4. sample_annotation.json

**记录信息**：

- **token**：每个sample_annotation的唯一标识符。
- **sample_token**：关联的sample的token。
- **instance_token**：关联的instance的token。
- **attribute_tokens**：关联的attribute的token列表。
- **visibility_token**：关联的visibility的token。
- **translation**：物体在空间中的位置。
- **size**：物体的大小。
- **rotation**：物体的旋转信息。
- **num_lidar_pts**：物体被lidar检测到的点数。
- **num_radar_pts**：物体被radar检测到的点数。
- **prev**：前一个sample_annotation的token。
- **next**：后一个sample_annotation的token。

### 5. instance.json

**记录信息**：

- **token**：每个instance的唯一标识符。
- **category_token**：关联的category的token。
- **nbr_annotations**：该instance的annotation数量。
- **first_annotation_token**：第一个annotation的token。
- **last_annotation_token**：最后一个annotation的token。

### 6. category.json

**记录信息**：

- **token**：每个category的唯一标识符。
- **name**：类别名称。
- **description**：类别描述。

### 7. attribute.json

**记录信息**：

- **token**：每个attribute的唯一标识符。
- **name**：属性名称。
- **description**：属性描述。

### 8. visibility.json

**记录信息**：

- **token**：每个visibility的唯一标识符。
- **level**：可见性等级描述。
- **description**：可见性描述。

### 9. sensor.json

**记录信息**：

- **token**：每个sensor的唯一标识符。
- **channel**：传感器通道名称，如"CAM_FRONT_RIGHT”。
- **modality**：传感器类型（如camera, lidar, radar）。

### 10. calibrated_sensor.json

**记录信息**：

- **token**：每个校准传感器的唯一标识符。
- **sensor_token**：关联的传感器的token。
- **translation**：传感器在车辆中的位置。
- **rotation**：传感器的旋转信息。
- **camera_intrinsic**：相机内参矩阵（仅适用于相机）。

### 11. ego_pose.json

**记录信息**：

- **token**：每个ego_pose的唯一标识符。
- **timestamp**：时间戳。
- **translation**：车辆在世界坐标系中的位置。
- **rotation**：车辆的旋转信息。

### 12. log.json

**记录信息**：

- **token**：每个log的唯一标识符。
- **vehicle**：车辆名称。
- **date_captured**：数据捕获日期。
- **location**：捕获地点。
- **logfile**：日志文件路径。

### 13. map.json

**记录信息**：

- **category**：地图的类别（如semantic_prior）。
- **token**：每个map的唯一标识符。
- **filename**：地图文件路径。
- **log_tokens**：与该地图相关的log记录的token列表。

### 数据集索引和联动

1. **场景级联动**：
    - **scene.json**:
        - `first_sample_token`和`last_sample_token`：用于访问该scene中的所有sample。
    - **sample.json**:
        - `scene_token`：用于将sample与scene关联。
        - `prev`和`next`：用于访问前一个和后一个sample，形成一个链式结构。
        - `token`：用于将sample与sample_data和sample_annotation关联。
2. **样本数据和传感器数据**：
    - **sample_data.json**:
        - `sample_token`：用于将sample_data与sample关联。
        - `ego_pose_token`：用于将sample_data与ego_pose关联。
        - `calibrated_sensor_token`：用于将sample_data与calibrated_sensor关联。
        - `prev`和`next`：用于访问前一个和后一个sample_data，形成一个链式结构。
    - **calibrated_sensor.json**:
        - `sensor_token`：用于将校准的传感器数据与sensor关联。
3. **标注数据**：
    - **sample_annotation.json**:
        - `sample_token`：用于将sample_annotation与sample关联。
        - `instance_token`：用于将sample_annotation与instance关联。
        - `attribute_tokens`：用于将sample_annotation与attribute关联。
        - `visibility_token`：用于将sample_annotation与visibility关联。
        - `prev`和`next`：用于访问前一个和后一个sample_annotation，形成一个链式结构。
    - **instance.json**:
        - `category_token`：用于将instance与category关联。
        - `first_annotation_token`和`last_annotation_token`：用于访问该instance的所有标注。
4. **传感器和车辆位姿数据**：
    - **sensor.json**：提供传感器的基本信息和类型（例如camera、lidar、radar）。
    - **ego_pose.json**：提供车辆在世界坐标系中的位置和旋转信息，通过sample_data中的ego_pose_token关联。
5. **属性和可见性数据**：
    - **attribute.json**：提供物体的属性信息（如物体的状态或行为）。
    - **visibility.json**：提供物体在特定样本中的可见性信息。
6. **日志和地图数据**：
    - **log.json**：通过scene.json中的log_token关联，提供车辆名称、数据捕获日期和地点等信息。
    - **map.json**：
        - `log_tokens`：将地图与相关的log记录关联，通过这些log记录可以访问scene信息。

### 使用指南

1. **加载场景数据**：
    - 首先加载`scene.json`，遍历每个scene，记录其`token`、`name`、`description`等信息。使用`first_sample_token`和`last_sample_token`来确定该scene中的样本范围。
2. **访问样本数据**：
    - 加载`sample.json`，通过`scene_token`筛选出属于特定scene的samples。利用`prev`和`next`字段在样本之间导航，形成一个链式结构。
    - 对于每个sample，通过`data`字段访问相关的sample_data，利用sample_data中的`token`进一步加载具体的传感器数据。
3. **处理传感器数据**：
    - 加载`sample_data.json`，获取每个sample_data的详细信息，包括`filename`（数据文件路径）和`calibrated_sensor_token`（传感器校准信息）。
    - 加载`calibrated_sensor.json`，使用`sensor_token`关联到`sensor.json`，了解传感器的类型和通道名称。
    - 通过`ego_pose_token`从`ego_pose.json`中获取车辆在世界坐标系中的位置和旋转信息。
4. **获取标注信息**：
    - 加载`sample_annotation.json`，通过`sample_token`找到对应sample的标注数据。记录标注信息，包括物体的位置（translation）、大小（size）和旋转信息（rotation）。
    - 通过`instance_token`从`instance.json`中获取物体实例的更多信息，如类别（通过`category_token`关联`category.json`）。
    - 加载`attribute.json`获取物体的属性信息，通过`attribute_tokens`进行关联。
    - 加载`visibility.json`获取物体的可见性信息，通过`visibility_token`进行关联。
5. **使用日志数据**：
    - 加载`log.json`，获取车辆名称、数据捕获日期和地点等信息。通过`log_token`与`scene.json`中的记录关联，了解具体场景的信息。
6. **处理地图数据**：
    - 加载`map.json`，使用`filename`字段加载具体的地图文件。通过`log_tokens`字段，关联到相关的log记录，进而了解该地图文件的适用场景。