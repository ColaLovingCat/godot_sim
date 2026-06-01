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

| 节点                               | 用途                       | 关键设置                                       |
| ---------------------------------- | -------------------------- | ---------------------------------------------- |
| SubViewport + SubViewportContainer | 实现像素完美渲染           | canvas_items 缩放模式，关闭 filter             |
| Sprite3D                           | 2D 角色/物品在 3D 空间展示 | billboard = disabled，texture_filter = nearest |
| Camera3D                           | 正交视角相机               | projection = Orthogonal，调整 size             |
| GridMap                            | 地板/墙壁快速搭建          | 配合 TileSet 使用                              |
| NavigationRegion3D                 | NPC 寻路                   | 需要 NavigationMesh                            |
| StateMachine (自定义)              | NPC/玩家状态控制           | 建议使用 State 模式                            |
| Resource (.tres)                   | 数据容器                   | 创建设施/桌游数据资产                          |

- 存档系统 (Save/Load)不要依赖 Godot 自带的 PackedScene 保存整个场景。采用数据分离的设计：
    - 写一个全局的 SaveManager.gd。
    - 游戏保存时，提取 EconomyManager 的金钱、InventoryManager 的库存、以及 PlacementSystem 的 occupied_cells 字典。
    - 将这些纯数据打包成 Dictionary，使用 JSON.stringify 保存为本地 .json 或 .save 文件。
    - 加载时，清空场景，读取 JSON，根据记录的坐标重新 instantiate() 对应的家具和解锁的桌游。

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

## 亮点

桌游本身可贴合现实生活中的原型，可采用**“神似形不似”的谐音梗或特征提炼**

- 盒绘、封面、地图等小细节
- 玩法说明书
- 支持玩家数量

在 HD-2D 的画面下，这些桌游不仅是 UI 里的图标，当顾客游玩时，桌面上还会出现真实的 3D 微缩模型（地图板、米宝、卡牌阵列）。

以下为 4 个极具代表性的桌游实例，涵盖了不同类型的客群和玩法表现：

- 实例一：德式策略入门经典（原型：《卡坦岛 Catan》）
游戏名称： 《六边形岛的开拓者》(Pioneers of Hex Island)
支持人数： 3 - 4 人
外观细节：
盒绘： 一轮红日下，几个像素小人拿着羊毛和木头在交易。
桌面组件： 当顾客游玩时，桌面上会拼接出色彩斑斓的六边形地砖（黄色麦田、绿色森林）。桌上散落着细小的木头房子模型。
玩法说明书 (UI 弹窗展示)：
“以羊换麦，友谊不在。在这个资源匮乏的岛屿上，谁能建起最长的道路，谁就是真正的岛主！注意防范那个可怕的强盗！”
游戏内机制影响： 顾客游玩时，经常会触发**“大声争吵（交易）”**的动画气泡：“我用两只羊换你一块砖，换不换！”。属于最基础的热门游戏，翻台率适中。

- 实例二：聚会与身份猜测（原型：《阿瓦隆 Avalon》/《狼人杀》）
游戏名称： 《亚瑟王庭的背刺》(Backstabs of Arthur's Court)
支持人数： 5 - 10 人 (大桌专属)
外观细节：
盒绘： 一个阴暗的王冠，一半是金色，一半浸染了血红色的像素块。盒子非常小。
桌面组件： 桌面上没有大版图，只有一圈代表玩家身份的卡牌，以及几个红蓝相间的“任务成功/失败”投票指示物。
玩法说明书：
“天黑请闭眼……梅林请睁眼。在正义与邪恶的阵营中，语言是你唯一的武器。不要相信坐在你左边的那个人！”
游戏内机制影响： 这是现充聚会玩家的最爱。游玩此游戏时，该桌顾客会产生**“极高噪音”**。如果旁边桌坐着正在玩硬核策略游戏的客人，满意度会狂掉。

- 实例三：美式跑团/克苏鲁神话（原型：《诡镇奇谈 / 克苏鲁的呼唤》）
游戏名称： 《触手镇调查员》(Investigators of Tentacle Town)
支持人数： 1 - 4 人 (支持单人游玩)
外观细节：
盒绘： 浓重的黑绿色调，一条巨大的暗影触手缠绕着一辆 1920 年代的老爷车。
桌面组件： 极其复杂的铺场。桌子上铺满了密密麻麻的小卡牌、人物面板，以及一把醒目的多面体骰子（D10/D20）。
玩法说明书：
“凝视深渊的时候，请顺便掷一次理智（SAN）检定。在这个充满不可名状恐惧的小镇，调查员们的目标不是胜利，而是活下去（或者疯得慢一点）。”
游戏内机制影响： 吸引硬核玩家。游玩时间极长（占用桌子半天），且非常容易呼叫店员（触发“村规/规则判定”小游戏，玩家需跑过去通过 QTE 帮他们查规则）。

- 实例四：超重度史诗战役（原型：《幽港迷城 Gloomhaven》）
游戏名称： 《暗黑港战纪》(Chronicles of Gloomport)
支持人数： 1 - 4 人
外观细节：
盒绘： 一个巨大的宝箱图案，盒子奇大无比，堪比微波炉。
桌面组件： 占据整张大桌子的地下城网格地图，上面立着各种立牌（Standees）和微缩模型。
玩法说明书：
“欢迎来到接下来 100 个小时的牢狱之灾（划掉）史诗冒险。这盒游戏重达 10 公斤，请在搬运时注意保护您的腰椎。”
游戏内机制影响： 极难解锁的终极游戏之一。
搬运惩罚： 店员/玩家在仓库拿到这盒游戏端给客人时，移动速度会骤降 50%。
专属事件： 玩这个游戏的客人绝不买任何饮料（怕洒在昂贵的版图上），但光是台费就能让你赚得盆满钵满。

【桌游图鉴系统 (The Board Game Collection)】
玩家进货了一种新桌游后，可以在菜单里解锁它的图鉴。
点击图鉴，会在屏幕中央渲染出这个桌游的 3D 高清模型（盒子），玩家可以用鼠标按住360度旋转查看它的盒绘（就像在真实的桌游店里拿起一盒游戏把玩一样）。
盒子的背面甚至可以贴着像素风的条形码、出版商 Logo（比如你的工作室名字），以及用诙谐的语调写成的“玩法说明书”。

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

- HD-2D 专属的相机控制逻辑 (Camera Controller)
```gdscript
# src/environment/camera/hd2d_camera.gd
extends Node3D

@export var move_speed: float = 10.0
@export var zoom_speed: float = 2.0
@onready var camera = $Camera3D

func _process(delta: float):
    # 1. 边缘平移 (WASD 或 鼠标推边缘)
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    # 结合当前相机的朝向进行移动计算
    var forward = global_transform.basis.z * input_dir.y
    var right = global_transform.basis.x * input_dir.x
    position += (forward + right) * move_speed * delta

    # 2. 视角旋转 (HD-2D 经典的 90度 步进旋转，Q/E 键)
    if Input.is_action_just_pressed("rotate_left"):
        var tween = create_tween()
        tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y + 90, 0.3).set_trans(Tween.TRANS_SINE)

    if Input.is_action_just_pressed("rotate_right"):
        var tween = create_tween()
        tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y - 90, 0.3).set_trans(Tween.TRANS_SINE)
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

func world_to_grid(pos: Vector3) -> Vector2i:
    # 3D 空间中，地面网格对应 X 和 Z
    return Vector2i(floor(pos.x / cell_size), floor(pos.z / cell_size))

func can_place(position: Vector3, size: Vector2i) -> bool:
    var grid_pos = world_to_grid(position)
    for x in range(size.x):
        for z in range(size.y): # 注意这里的变量迭代
            var check_pos = Vector2i(grid_pos.x + x, grid_pos.y + z) # 存储为 2D 坐标 (X, Z)
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

- 卡牌数据模板

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

- BuffManger

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

- 玩法循环接入 (GameManager.gd)

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

- 交互点击规范
```Gdscript
# components/interactable.gd
extends Area3D

signal on_clicked

func _ready():
    # 开启这个才能接收输入事件
    input_ray_pickable = true 

# Godot 4 内置的 3D 输入事件拦截
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        on_clicked.emit()
        # 例如：点中顾客时弹出信息，点中垃圾时清理
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
放弃复杂的 3D 物理 NavMesh，强烈推荐使用基于网格的 A 寻路 (AStarGrid2D 搭配 3D 坐标系转接)\*。
核心思路： 桌游店本质上是方块网格。在内存中维护一个 AStarGrid2D（是的，即使场景是 3D 的，地面逻辑其实也是 2D 平面）。
动态更新： 当玩家放下桌子时，在 grid.gd 中将该坐标的 AStar 节点设为 solid（不可通行）。
重新计算路径： 监听建造事件（通过 EventBus），当网格改变时，所有处于 State_Walking 状态的 NPC 立刻调用 recalculate_path()。

## 问题 3：NPC 数量增多导致掉帧 (性能痛点)

【表现与原因】
当店铺扩张，店内同时有 50 个顾客 + 5 个员工时，如果每个 NPC 都在 \_process(delta) 里每帧检测周围的桌子、计算耐心值、判断是不是该生气，CPU 负载会激增。
【Godot 解决方案】
事件驱动代替每帧检测： 顾客坐下玩桌游需要 3 分钟，不要在 \_process 里写 time_left -= delta，而是直接创建一个 Godot 的 Timer 节点，设为 180 秒，超时后触发 on_game_finished() 信号。
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
