---
name: sim-dev
description: HD-2D 桌游模拟经营项目开发指南
---

# 🛠️ 项目开发指南：HD-2D 桌游模拟经营 (Godot版)

你是一个 **Godot游戏引擎** 开发者，现在需要开发一个 **桌游经营模拟游戏**。
视觉上采用复古像素与现代3D光影结合的 **HD-2D** 技术，
整体美术氛围和渲染表现对标 《八方旅人（歧路旅人）》 和 《逸剑风云决》，玩法类似《双点医院》。
核心玩法是通过合理布局和经营策略，购买桌游、摆放桌椅、吸引NPC顾客来消费，赚取利润并扩大店铺规模。

---

以下是项目的核心开发指南，涵盖目录结构、核心技术栈和开发里程碑等。

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
│   ├── materials/         # 3D 材质 (用于控制像素画贴图在 3D 中的表现，如无过滤、法线贴图)
│   │   ├── pixel_unshaded.tres
│   │   └── pixel_lit.tres
│   ├── models/            # 建筑组件、地板、天花板
│   ├── music/             # 背景音乐
│   └── sfx/               # 音效
│       ├── place_furniture.wav
│       ├── dice_roll.wav
│       └── coin.wav
├── src/                   # 核心代码逻辑
│   ├── components/        # 实体通用行为组件 (纯逻辑节点，附加到实体下)
│   │   ├── grid_occupier.gd    # 占用网格逻辑
│   │   ├── interactable.gd     # 玩家交互响应区 (Area3D/Area2D)
│   │   ├── sit_point.gd        # NPC 坐下位置计算
│   │   └── item_container.gd   # 容器逻辑 (用于架子存放桌游)
│   ├── environment/       # HD-2D 专门的环境与光影模块
│   │   ├── camera/        # 摄像机控制器 (处理正交/透视切换、跟随、视角旋转)
│   │   │   ├── hd2d_camera.gd
│   │   │   └── hd2d_camera.tscn
│   │   ├── lighting/      # 灯光预设 (白天/黄昏/夜晚光影切换)
│   │   │   └── day_night_cycle.gd
│   │   ├── post_process/  # WorldEnvironment 后期特效配置 (景深、辉光、色彩校正)
│   │   │   └── hd2d_env.tres
│   │   └── room_elements/ # 墙壁、地板的 3D 场景组件
│   │       ├── wall_segment.tscn
│   │       └── floor_tile.tscn
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
│   │   ├── inventory/     # 库存系统 (非常重要)
│   │   │   ├── inventory_manager.gd  # 管理仓库里的桌游库存
│   │   │   └── stock_delivery.gd     # 进货快递逻辑
│   │   ├── time/          # 独立的时间系统
│   │   │   └── time_system.gd        # 控制游戏内的小时、天数流逝 (影响顾客生成和关店逻辑)
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
│   └── resources/         # 存储家具、桌游数据的 .tres 文件
│       ├── furniture/          # 家具数据
│       │   ├── wooden_table.tres
│       │   ├── fancy_chair.tres
│       │   └── shelf.tres
│       ├── boardgames/         # 桌游数据
│       │   ├── catan.tres
│       │   └── ticket_to_ride.tres
│       └── npc/                # NPC 类型数据
│           ├── casual.tres
│           └── hardcore.tres
├── scenes/                # 按“游戏大阶段”划分
│   ├── boot/              # 启动与初始化、Logo展示
│   ├── main_menu/         # 主菜单场景及其独立 UI
│   └── game_world/        # 实际游玩的主场景 (取代之前的 main_game)
│       ├── game_world.tscn
│       └── game_world.gd  # 负责组装 systems, actors, environment
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

在Godot中搭建HD-2D的场景（3D环境+2D Sprite3D+正交/透视相机）
处理复古光影与后期特效

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

## 游戏策划

游店的核心玩法循环 (Core Gameplay Loop)
- 进货与维护：
    - 购买新桌游（扩充库房）。
    - 特色机制：【包牌套/塑封】 桌游是消耗品，顾客游玩会掉耐久。玩家可以花费金钱给热门桌游“包牌套”，降低磨损率。损坏的桌游会引发顾客差评。
    - 进货零食、饮料（高利润附加收入）。

- 店面布置 (网格建造)
    - 摆放不同规格的桌椅（双人桌、四人桌、跑团大圆桌）
    - 点缀植物提升环境值（影响顾客耐心）。

- 迎客与排座 (Seating)：
顾客以“小队（Party）”形式出现（1-6人不等）。玩家/员工需要将他们引导至合适的空桌。
策略点： 比如 4 个人占了 6 人桌，会导致空间浪费；但如果不安排，顾客耐心耗尽会离开。

- 推销与荐游 (Recommending)：
顾客落座后会有需求提示框（如：“想要轻松欢乐的”、“想要烧脑策略的”、“情侣找双人游戏”）。
玩家需要在库存中挑选合适的桌游递给他们。匹配度越高，顾客满意度、游玩时间和消费意愿越高。

- 局中服务 (Mid-game Service)：
游玩过程中，顾客会随机产生需求：点饮料/零食、呼叫村规/规则教学（玩家需跑过去交互，读条解决）、突发事件（如“某人急眼了掀桌子”、“饮料洒在桌游上”）。

- 办赛 (Tournaments)：
积累足够声望后，可以在周末举办“TCG卡牌店赛”或“大富翁争霸赛”。
玩法： 比赛日将锁定店面，涌入大量特定类型的顾客。是对店面积载能力、员工服务速度的终极考验，成功后获得大量声望和稀有桌游图纸。

- 3选1随机卡牌Buff（Roguelite元素）


数值框架 (Numerical Framework)

1. 核心资源
金钱 (Money/Gold)： 用于购买家具、进货、雇佣员工、扩建店铺。
声望 (Reputation/Stars)： 店铺等级。声望决定了你能解锁什么级别的桌游（从《大富翁》到《战锤40K》），以及吸引什么类型的顾客。
极客点数 (Geek Points - 可选)： 通过成功推荐硬核游戏或解决复杂规则纠纷获得，用于升级玩家角色的个人技能（如“快步走”、“巧舌如簧”）。
2. 实体数据模型 (对应 Godot 的 .tres Resource)
桌游属性库：
Type (分类)：聚会、策略、德式、美式、毛线、跑团。
Complexity (重度)：1.0 ~ 5.0。重度越高的游戏，顾客玩得越久（占台时间长），但客单价或租金极高。
Max_Players (人数)：支持 2-8 人。
Durability (耐久度)：每次游玩扣除 1-5 点，归零后无法出租。
顾客属性 (NPC Stats)：
Budget (预算)：决定他们是否点得起昂贵的零食。
Patience (耐心值)：排队等待和呼叫服务时的流失速度。
Play_Speed (游玩速度)：结算周期的快慢。
3. 经济模型
收入构成： 台费（按小时计费，HD-2D游戏内每秒=几分钟） + 桌游租赁费 + 餐饮暴利。
支出构成： 每日租金、员工工资、桌游折旧重购费。
平衡难点： 硬核玩家玩一个游戏占桌 4 小时，只付一次租金且不喝水；聚会玩家 1 小时换一个游戏，疯狂买饮料。玩家需要通过“限时段优惠”或“排座策略”来平衡客群。

顾客行为AI设计

1. 顾客画像 (Personas)
为了让 AI 有差异化，我们设计三种基础客群：
现充小白 (Casuals)： 耐心极低，喜欢毛线/聚会游戏（如《UNO》《阿瓦隆》），消费大量零食，容易大声喧哗（影响周围桌的满意度）。
硬核极客 (Hardcore)： 耐心高，指名要重度策略游戏（如《幽港迷城》），自带水杯（不买零食），对桌游耐久度要求极高（如果有折痕会大发雷霆）。
跑团群 (TTRPGers)： 必须要求大桌子或包间，一来就是一整天，需要玩家频繁跑过去充当“DM（主持人）”过判定。
2. AI 行为树 / 状态机流转 (State Machine)
每一个顾客小队（Party Manager 统一调度几个 NPC 实体）的状态流转如下：
State_Spawn：生成在店外，带有一个气泡 UI 显示人数和偏好。
State_Queueing：在吧台前排队。头顶出现耐心进度条。如果耗尽 -> 切换为 State_Leave_Angry。
State_Walking：分配到桌子后，调用 Godot 的 NavigationAgent3D/2D 走向座位。
State_Seated_Waiting：坐下，招手等待玩家推荐桌游。
State_Playing：核心状态。
动画表现： 桌子上出现对应的桌游模型，NPC 手部有掷骰子、抽卡的动作。
内部计时器： 根据桌游的 Duration 属性决定停留时长。
随机中断 (Interrupts)： 根据概率触发 Sub-state_Want_Food（想吃东西）或 Sub-state_Rule_Question（举手问规则）。
State_Paying：游玩结束，走向收银台结账，根据心情掉落金钱和声望评价（弹出发光的金币和表情包）。
State_Despawn：走出店门销毁。
3. 视觉与 HD-2D 的融合 (点睛之笔)
氛围营造： 当硬核玩家玩《克苏鲁的呼唤》时，他们那桌的 3D 灯光可以变暗，桌底冒出紫色的粒子特效；当聚会玩家玩《传情画意》时，头上不断冒出“哈哈哈”的 2D 像素气泡。
这也正契合了《八方旅人》那种**“在精致的微缩模型箱庭中，上演生动市井百态”**的美学核心。

# 3. 开发里程碑 (Development Roadmap)

## 第一阶段：HD-2D 视觉验证
- [ ] 搭一个 hd2d_camera，放一个 3D 的地板和墙壁，加上一个 Sprite3D 的玩家，加上描边 Shader
- [ ] 实现角色在场景中移动，确保像素不模糊、无抖动。
- [ ] 设置环境光/像素风格光照

## 第二阶段：放置系统
- [ ] 实现网格吸附逻辑。
- [ ] 实现“虚影预览”：家具放下前显示红色（不可放）或绿色（可放）。
- [ ] **关键**：实现“桌椅绑定”逻辑（椅子靠近桌子自动激活）。

## 第三阶段：NPC 与游玩循环
- [ ] NPC 生成系统。
- [ ] NPC 自动寻找“已激活”的桌游站并坐下。
- [ ] 游玩计时与金钱结算。

## 第四阶段：UI 与管理界面
- [ ] 建造菜单（选择不同家具）。
- [ ] 店铺信息面板（今日盈利、顾客满意度）。

# 4. 实用代码模板

- 像素完美渲染设置
```gdscript
# 主场景相机设置
$Camera3D.projection = Camera3D.PROJECTION_ORTHOGONAL
$Camera3D.size = 10  # 根据网格大小调整

# Sprite3D 纹理过滤
sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
```

- 全局信号总线 (EventBus.gd)
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

- 数据资源示例 (FurnitureResource.gd)
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

- 网格放置系统核心逻辑
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

- 桌椅绑定逻辑
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

- NPC 状态机示例
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

卡牌数据模板
```Gdscript
# src/data/buff_card.gd
extends Resource
class_name BuffCard

enum Rarity { COMMON, RARE, EPIC }
enum BuffType { SPEED, PROFIT, SPAWN_RATE, SPECIAL_EVENT }

@export var card_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var rarity: Rarity
@export var buff_type: BuffType
@export var buff_value: float
```
BuffManger 
```Gdscript
# src/core/BuffManager.gd
extends Node

var active_buffs: Array[BuffCard] = []

# 当玩家选定卡牌后调用
func apply_card(card: BuffCard):
    active_buffs.append(card)
    # 通过你之前设定的 EventBus 广播全局信号
    EventBus.emit_signal("buff_applied", card)

# 其他系统来这里查询数值，比如 Player.gd 查速度
func get_speed_multiplier() -> float:
    var multi = 1.0
    for buff in active_buffs:
        if buff.buff_type == BuffCard.BuffType.SPEED:
            multi += buff.buff_value
    return multi

# 每天关店时清理临时 Buff
func clear_daily_buffs():
    active_buffs.clear()
```

玩法循环接入 (GameManager.gd)
```Gdscript
# src/core/GameManager.gd

func start_new_day():
    # 暂停游戏时间
    Engine.time_scale = 0 
    
    # 从数据库随机抽取 3 张不同的卡牌
    var choices = CardDatabase.get_random_cards(3)
    
    # 唤起 UI
    var ui = load("res://src/ui/menus/card_draft_menu.tscn").instantiate()
    ui.setup(choices)
    get_tree().root.add_child(ui)
    
    # 等待 UI 发出选定完毕的信号 (Godot 4 的 await 语法)
    var selected_card = await ui.card_selected
    
    BuffManager.apply_card(selected_card)
    
    # 恢复时间，正式开门营业
    Engine.time_scale = 1
    open_shop()
```

# 5. 常见问题与解决方案

## 问题 1：HD-2D 的视觉割裂感与光影BUG (视觉痛点)
【表现与原因】
把 2D 像素小人（Sprite3D）放进 3D 场景后，边缘会发虚发糊；而且 2D 小人遇到 3D 光照时，要么完全不反光，要么影子像一张纸一样纸片感极强，甚至和地板产生 Z-Fighting（闪烁）。
【Godot 解决方案】
像素完美设置： 必须在 Project Settings 中将 Textures -> Default Texture Filter 改为 Nearest（最近大点）。
Sprite3D 阴影处理： 在 Sprite3D 的属性面板中，将 Alpha Cut 改为 Discard 或 Opaque Pre-pass（非常关键，否则透明像素也会投射方形阴影）。将 Geometry -> Cast Shadow 开启。
Y-Billboard (公告板)： 将 Sprite3D 的 Billboard 模式设为 Y-Billboard，这样无论摄像机怎么转，像素小人永远面向屏幕，但不会像不倒翁一样前后倾斜。
摄像机视角选择： 建议使用 透视摄像机 (Perspective) 但把 FOV 调得很低（比如 20-30），然后拉远距离。这比直接用正交摄像机 (Orthogonal) 更有纵深感，也是《八方旅人》使用的技巧。

## 问题 2：网格建造后，NPC 寻路卡死或穿模 (系统痛点)
【表现与原因】
玩家在营业时买了一张大桌子放在路中间。原本正走向吧台的 NPC 没有更新寻路，直接卡在桌子前抽搐，或者直接穿透了桌子走过去。
【Godot 解决方案】
放弃复杂的 3D 物理 NavMesh，强烈推荐使用基于网格的 A 寻路 (AStarGrid2D 搭配 3D 坐标系转接)*。
核心思路： 桌游店本质上是方块网格。在内存中维护一个 AStarGrid2D（是的，即使场景是 3D 的，地面逻辑其实也是 2D 平面）。
动态更新： 当玩家放下桌子时，在 grid.gd 中将该坐标的 AStar 节点设为 solid（不可通行）。
重新计算路径： 监听建造事件（通过 EventBus），当网格改变时，所有处于 State_Walking 状态的 NPC 立刻调用 recalculate_path()。

## 问题 3：NPC 数量增多导致掉帧 (性能痛点)
【表现与原因】
当店铺扩张，店内同时有 50 个顾客 + 5 个员工时，如果每个 NPC 都在 _process(delta) 里每帧检测周围的桌子、计算耐心值、判断是不是该生气，CPU 负载会激增。
【Godot 解决方案】
事件驱动代替每帧检测： 顾客坐下玩桌游需要 3 分钟，不要在 _process 里写 time_left -= delta，而是直接创建一个 Godot 的 Timer 节点，设为 180 秒，超时后触发 on_game_finished() 信号。
状态机休眠： 当 NPC 处于“玩游戏”或“等待”状态时，直接关闭其物理处理和逻辑帧 (set_process(false) 和 set_physics_process(false))，只保留动画播放，直到 Timer 唤醒它们。
可见性剔除： 使用 VisibleOnScreenNotifier3D，当 NPC 走出屏幕外围时（比如回家的路上），停止渲染并降低逻辑更新频率。

## 问题 4：鼠标难以点中 3D 场景里的像素物品 (交互痛点)
【表现与原因】
玩家需要点击桌子上的一盒小小桌游来“收纳”，或者点击乱跑的顾客。但因为 HD-2D 是俯视角，像素贴图又扁，玩家经常点错或者点不到，交互手感极差。
【Godot 解决方案】
夸张的碰撞箱 (Hitbox)： 用于鼠标射线检测的 CollisionShape3D 要比实际物体大 1.5 到 2 倍。不要用精确的网格形状，全用粗糙的BoxShape或CapsuleShape。
射线检测分层 (Collision Layers)： 在 Godot 的项目设置中定义好 Layer（比如 Layer 1是墙壁，Layer 2是家具，Layer 3是NPC）。鼠标发出射线时，根据当前所处的状态（比如在建网格模式，只检测墙壁/地板；在服务模式，只检测NPC和桌子）。
UI 反馈补偿： 当鼠标射线扫到可交互物体时，务必给物体加上白色的 Shader 描边，并在鼠标位置弹出交互提示（如 [E] 整理桌面），弥补物理判定上的不精确感。

## 问题 5：卡牌 Buff 导致数值永久损坏 (架构痛点)
【表现与原因】
这是加入了你新提议的“3选1 Buff系统”后最容易出的问题。
比如基础速度是 100，抽到卡牌增加 30，变成 130。第二天结算清空卡牌，你执行 speed -= 30，恢复 100。
但如果遇到复杂的百分比叠加、或者中途有其他事件（员工升级减速），单纯的加减法会导致第二天速度变成负数或极其变态的高。
【Godot 解决方案】
绝对不要直接修改基础数值！引入修饰器模式 (Modifier Pattern)。
在实体上设计两个变量：base_speed 和 current_speed。
```Gdscript
# 正确的计算方式，每次重新计算，而不是累加减
func calculate_current_speed():
    var multiplier = 1.0
    var flat_bonus = 0.0
    
    # 遍历当前所有激活的卡牌 Buff
    for buff in BuffManager.active_buffs:
        if buff.type == "SPEED_FLAT":
            flat_bonus += buff.value
        elif buff.type == "SPEED_MULT":
            multiplier += buff.value # 如 0.3 代表 +30%
            
    current_speed = (base_speed + flat_bonus) * multiplier
```
每当新的一天开始清空卡牌，或者抽到新卡牌时，直接调用一次 calculate_current_speed() 即可，这样数据永远是“防弹的”（Bulletproof）。