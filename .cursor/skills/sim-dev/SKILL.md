---
name: sim-dev
description: 2D 桌游模拟经营项目开发指南
---

# 🛠️ 项目开发指南：2D 桌游模拟经营 (Godot版)

你是一个Godot游戏开发者，现在需要开发一个2D桌游模拟经营游戏。
风格类似星露谷物语，玩法类似双点医院，核心玩法是通过合理布局和经营策略，购买桌游、摆放桌椅、吸引NPC顾客来消费，赚取利润并扩大店铺规模。
以下是项目的核心开发指南，涵盖目录结构、核心技术栈和开发里程碑。

# 1. 项目目录结构 (Project Structure)

遵循 Godot 的“场景即组件”哲学，建议采用按功能模块划分的目录结构：

```Text
/godot_sim
├── assets/                # 原始资源
│   ├── sprites/           # 2D 像素角色、家具、图标
│   │   ├── characters/    # NPC/玩家角色精灵表
│   │   │   ├── player/
│   │   │   └── npc/
│   │   ├── furniture/     # 家具图标/精灵
│   │   │   ├── table.png
│   │   │   ├── chair.png
│   │   │   └── shelf.png
│   │   └── ui/            # UI 图标
│   ├── models/            # 建筑组件、地板、天花板
│   ├── music/             # 背景音乐
│   └── sfx/               # 音效
│       ├── place_furniture.wav
│       ├── dice_roll.wav
│       └── coin.wav
├── src/                   # 核心代码逻辑
│   ├── core/              # 全局单例 (Autoloads)
│   │   ├── GameManager.gd # 游戏主循环、时间控制
│   │   ├── EconomyManager.gd # 金钱、声望计算
│   │   ├── EventBus.gd    # 全局信号中心 (Observer Pattern)
│   │   └── DataManager.gd # 资源加载、数据持久化
│   ├── actors/            # 动态实体
│   │   ├── player/        # 玩家控制
│   │   │   ├── player.gd
│   │   │   └── player.tscn
│   │   └── npc/           # 顾客 AI (行为树、导航)
│   │       ├── npc.gd
│   │       ├── npc.tscn
│   │       ├── npc_spawner.gd  # NPC 生成器
│   │       └── npc_states/     # 状态机状态
│   │           ├── state_idle.gd
│   │           ├── state_walk.gd
│   │           ├── state_sit.gd
│   │           └── state_play.gd
│   │
│   ├── objects/           # 可交互物体 (家具/桌游)
│   │   ├── furniture/          # 家具
│   │   │   ├── base_furniture.gd
│   │   │   ├── base_furniture.tscn
│   │   │   ├── table.gd
│   │   │   ├── table.tscn
│   │   │   ├── chair.gd
│   │   │   └── chair.tscn
│   │   └── game_stations/      # 特殊的“桌椅组合”逻辑
│   │       ├── game_station.gd
│   │       └── game_station.tscn
│   ├── systems/           # 核心经营系统
│   │   ├── building/      # 网格放置系统
│   │   │   ├── grid.gd
│   │   │   ├── placement_system.gd
│   │   │   └── preview_helper.gd
│   │   ├── pathfinding/   # 导航网格生成
│   │   │   └── nav_manager.gd
│   │   └── economy/       # 财务报表逻辑
│   │       ├── transaction.gd
│   │       └── pricing.gd
│   ├── ui/                # 用户界面
│   │   ├── hud/           # 顶部状态栏
│   │   │   ├── top_bar.gd
│   │   │   ├── top_bar.tscn
│   │   │   ├── money_display.gd
│   │   │   └── reputation_display.gd
│   │   ├── menus/
│   │   │   ├── build_menu.gd
│   │   │   ├── build_menu.tscn
│   │   │   ├── shop_menu.gd
│   │   │   ├── shop_menu.tscn
│   │   │   └── pause_menu.gd
│   │   ├── components/         # 复用 UI 组件
│   │   │   ├── button_pixel.gd
│   │   │   └── progress_bar.gd
│   │   └── notifications/
│   │       └── toast.gd
│   └── utils/                  # 工具类
│       ├── math_utils.gd
│       └── signal_waiter.gd
├── data/                  # 数据驱动相关 (重点)
│   ├── resources/         # 存储家具、桌游数据的 .tres 文件
│   │   ├── furniture/          # 家具数据
│   │   │   ├── wooden_table.tres
│   │   │   ├── fancy_chair.tres
│   │   │   └── shelf.tres
│   │   ├── boardgames/         # 桌游数据
│   │   │   ├── catan.tres
│   │   │   └── ticket_to_ride.tres
│   │   └── npc/                # NPC 类型数据
│   │       ├── casual.tres
│   │       └── hardcore.tres
│   └── tables/            # 可选：CSV 或 JSON 导出的平衡表
│       ├── furniture_stats.json
│       ├── npc_spawn_rates.json
│       └── upgrade_costs.json
├── scenes/                     # 游戏场景
│   ├── main_game.tscn          # 主游戏场景
│   ├── main_menu.tscn          # 主菜单
│   └── loading_screen.tscn     # 加载界面
├── shaders/                    # 自定义着色器
│   ├── pixel_snap.gdshader     # 像素对齐
│   └── outline.gdshader        # 描边效果
├── config/                     # 配置文件
│   ├── input_map.gd            # 输入映射
│   └── settings.gd             # 游戏设置
├── default_bus_layout.tres     # 音频总线配置
└── project.godot               # 项目配置文件
```

# 2. 核心技术栈 (Essential Skills)

## 必备 Godot 节点类型

| 节点	| 用途	| 关键设置 |
| --- | --- | --- |
| SubViewport + SubViewportContainer	| 实现像素完美渲染	| canvas_items 缩放模式，关闭 filter |
| Sprite3D	| 2D 角色/物品在 3D 空间展示	| billboard = disabled，texture_filter = nearest |
| Camera3D	| 正交视角相机	| projection = Orthogonal，调整 size |
| GridMap	| 地板/墙壁快速搭建	| 配合 TileSet 使用 |
| NavigationRegion3D	| NPC 寻路	| 需要 NavigationMesh |
| StateMachine (自定义)	| NPC/玩家状态控制	| 建议使用 State 模式 |
| Resource (.tres)	| 数据容器	| 创建设施/桌游数据资产 |

## 关键系统实现

- 2.1 像素完美渲染设置
```gdscript
# 主场景相机设置
$Camera3D.projection = Camera3D.PROJECTION_ORTHOGONAL
$Camera3D.size = 10  # 根据网格大小调整

# Sprite3D 纹理过滤
sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
```

- 2.2 全局信号总线 (EventBus.gd)
```gdscript
extends Node

# 经济事件
signal money_changed(new_amount, delta)
signal reputation_changed(new_value)

# 放置系统事件
signal furniture_placed(position, furniture_id)
signal furniture_removed(position)

# NPC 事件
signal npc_arrived(npc_id)
signal npc_seated(station_id, npc_id)
signal npc_finished_playing(station_id, revenue)

# UI 事件
signal build_mode_toggled(is_active)
signal menu_opened(menu_name)

# 时间事件
signal day_started(day_number)
signal day_ended(report)
```

- 2.3 数据资源示例 (FurnitureResource.gd)
```gdscript
extends Resource
class_name FurnitureResource

@export var id: String
@export var display_name: String
@export var icon: Texture2D
@export var model_path: String  # 3D 模型路径
@export var size: Vector2i      # 占用网格尺寸 (如 1x1, 2x2)
@export var purchase_price: int
@export var sell_price: int
@export var category: String     # "table", "chair", "decoration"

# 特殊属性
@export var is_chair: bool = false
@export var is_table: bool = false
@export var comfort_bonus: float = 0.0  # 影响顾客满意度
```

- 2.4 网格放置系统核心逻辑
```gdscript
# placement_system.gd
extends Node

var grid_size: Vector2 = Vector2(20, 20)  # 20x20 网格
var cell_size: float = 1.0
var occupied_cells: Dictionary  # 存储已占用的位置

func can_place(position: Vector3, size: Vector2i) -> bool:
    var grid_pos = world_to_grid(position)
    for x in range(size.x):
        for y in range(size.y):
            var check_pos = Vector2i(grid_pos.x + x, grid_pos.y + y)
            if occupied_cells.has(check_pos):
                return false
    return true

func place_furniture(furniture: FurnitureResource, position: Vector3):
    if can_place(position, furniture.size):
        var instance = load(furniture.model_path).instantiate()
        instance.position = position
        add_child(instance)
        
        # 标记占用
        var grid_pos = world_to_grid(position)
        for x in range(furniture.size.x):
            for y in range(furniture.size.y):
                occupied_cells[Vector2i(grid_pos.x + x, grid_pos.y + y)] = furniture.id
        
        # 触发绑定逻辑
        if furniture.is_table:
            try_bind_chairs(grid_pos)
        
        return true
    return false
```

- 2.5 桌椅绑定逻辑
```gdscript
# 当放置桌子时，自动检查周围椅子
func try_bind_chairs(table_grid_pos: Vector2i):
    var adjacent_positions = [
        Vector2i(0, 1), Vector2i(1, 0), 
        Vector2i(0, -1), Vector2i(-1, 0)
    ]
    
    for offset in adjacent_positions:
        var chair_pos = table_grid_pos + offset
        if occupied_cells.has(chair_pos):
            var furniture_id = occupied_cells[chair_pos]
            var chair_data = get_furniture_data(furniture_id)
            if chair_data and chair_data.is_chair:
                create_game_station(table_grid_pos, chair_pos)
```

- 2.6 NPC 状态机示例
```gdscript
# npc.gd - 主控制器
extends CharacterBody3D

enum State { IDLE, WALKING, SITTING, PLAYING, LEAVING }
var current_state: State = State.IDLE
var target_station: GameStation = null

func _process(delta):
    match current_state:
        State.IDLE:
            find_available_station()
        State.WALKING:
            move_toward_target()
        State.SITTING:
            start_playing_game()
        State.PLAYING:
            play_timer -= delta
            if play_timer <= 0:
                finish_playing()
```

# 3. 开发里程碑 (Development Roadmap)

## 第一阶段：视觉与基础相机 (Day 1-3)
- [ ] 搭建房间地板，配置正交视角相机。
- [ ] 实现 Sprite3D 角色在场景中移动，确保像素不模糊、无抖动。
- [ ] 设置环境光/像素风格光照

## 第二阶段：放置系统 (Week 1)
- [ ] 实现网格吸附逻辑。
- [ ] 实现“虚影预览”：家具放下前显示红色（不可放）或绿色（可放）。
- [ ] **关键**：实现“桌椅绑定”逻辑（椅子靠近桌子自动激活）。

## 第三阶段：NPC 与游玩循环 (Week 2)
- [ ] NPC 生成系统。
- [ ] NPC 自动寻找“已激活”的桌游站并坐下。
- [ ] 游玩计时与金钱结算。

## 第四阶段：UI 与管理界面 (Week 3)
- [ ] 建造菜单（选择不同家具）。
- [ ] 店铺信息面板（今日盈利、顾客满意度）。