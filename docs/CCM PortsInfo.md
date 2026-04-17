# CCM PortsInfo：从 ARXML 到信号/组件追溯（培训文档）

本文面向需要在 **CCM 内部 SWC（AUTOSAR ARXML）** 上快速搞清楚「信号从哪来、到哪去、挂在哪个组件上」的同事，说明当前仓库里 **`src/find/arxml`** 脚本解决什么问题、怎么用，以及和 **App Designer GUI（如 `src/gui/smart_thermal`）** 的关系。

---

## 1. 我们要解决什么问题（痛点 → 能力）

| 痛点 | 典型表现 | 当前脚本/GUI 如何缓解 |
|------|----------|------------------------|
| **不知道信号是哪个模型（组件）发出来的** | 在 Simulink 里一层层找 Outport，或靠口头问人 | `findPortFromPortsInfo`：按 **PortName** 查 **Output 侧组件**（生产者）与 **Input 侧组件**（消费者）。GUI 中 **FindSignal** 选信号后展示 **ModelOut / ModelIn**。 |
| **想顺着信号看上下游、上层逻辑** | 需要自己在架构图或多个模型间跳转 | 同一套 PortsInfo 表把 **组件—方向—端口** 拉平；信号名一致即可在表内关联。`findPorsInfoConnection` 可批量统计「被跨组件使用的输出」「仅输出/仅输入」等，辅助发现孤立或非常规连接。 |
| **打开模型、找对子系统路径耗时** | ARXML 组件多，手工导航慢 | `findPortsInfoFromArxml` 先把各组件 **导入为缓存 `.slx`**（`cache/arxml_models_<arxmlBase>/`），再 **批量扫顶层 Inport/Outport** 写出 **PortsInfo Excel**，避免每次在完整架构模型里人肉点端口。 |
| **需要可分享、可工具化的「架构视图」** | Excel 不好给非 MATLAB 同事用 | `findPortsInfoToGjson` 把 **同信号名** 的 Output→Input 组件关系打成 **gjson**（nodes/edges），便于图谱或后续界面消费。 |
| **默认路径不统一、脚本难复用** | 每人放的数据位置不同 | `findDefaultCcmArxml`、`findDefaultPortsInfoExcelPath` 统一 **ARXML** 与 **PortsInfo Excel** 的查找顺序（`data/ccm`、`artifacts`、按时间最新 `*PortsInfo*.xlsx` 等）。 |

> **说明**：PortsInfo 描述的是 **组件端口级** 的输入/输出集合；**跨组件连线**在表里通过 **同名信号** 推断（与 `findPortsInfoToGjson` 的边生成逻辑一致）。若 ARXML/实现中存在别名、中间适配或命名不一致，需在流程上额外约定或扩展列。

---

## 2. 数据流一览（建议培训时对着讲）

```
ARXML 文件
    │  findPortsInfoFromArxml（generateModels）
    ▼
cache/arxml_models_<basename>/*.slx   ← 组件级缓存模型（可跳过已存在）
    │  findPortsInfoFromArxml（exportPorts / all）
    ▼
artifacts/<basename>_PortsInfo.xlsx  ← Ports 表：ComponentName, PortDirection, PortName, OutDataTypeStr, ...
    │
    ├─ findPortFromPortsInfo        → 信号 → 输出组件 / 输入组件
    ├─ findComponentPortsFromPortsInfo → 组件 → 输入信号表 / 输出信号表
    ├─ findPorsInfoConnection       → 全集统计 + 组件清单 + 仅用/孤立信号等
    └─ findPortsInfoToGjson         → 组件关系图数据（.gjson）
```

**GUI（Arxml 页）** 与上述流程对齐：配置 **Arxml** 与 **PortsInfoExcel** 路径后，可触发 **CreateModels / CreateJson（gjson）/ CreatePortsInfoExcel**，并在列表中 **点信号、点组件** 做 **互查**（底层即上述 `find*` 函数）。

---

## 3. `src/find/arxml` 脚本速查（培训用「菜单」）

| 函数文件 | 一句话 | 典型用法 |
|----------|--------|----------|
| `findDefaultCcmArxml.m` | 把 ARXML 文件名解析成磁盘路径 | 被 `findPortsInfoFromArxml` 调用；也可单独用来定位 `CCM_Internal_swc.arxml` |
| `findPortsInfoFromArxml.m` | **从 ARXML 生成缓存模型并导出 PortsInfo Excel** | `step`: `all`（默认）、`generateModels`、`exportPorts`；输出目录默认 `cache/` 与 `artifacts/` |
| `findDefaultPortsInfoExcelPath.m` | **统一默认 PortsInfo Excel 路径** | 各查询函数未传 `excelFile` 时使用 |
| `findPortFromPortsInfo.m` | **按信号查生产者/消费者组件** | 对应 GUI：**Signals → ModelOut / ModelIn** |
| `findComponentPortsFromPortsInfo.m` | **按组件查 SigIn / SigOut** | 对应 GUI：**Components → SigIn / SigOut**；支持 `matchMode` `exact`/`contains` |
| `findPorsInfoConnection.m` | **整表统计与清单**（组件全集、各类信号集合） | 做数据质量检查、讲架构概览、给 GUI 批量填充列表 |
| `findPortsInfoToGjson.m` | **Excel → gjson**（组件节点 + 按信号连边） | 与 GUI **CreateJson** 一致思路，便于外部分享或二次可视化 |

**已知限制（培训时要交代清楚）**：`findPortsInfoFromArxml.m` 内 **接口表（Interfaces）导出** 仍注释为「逻辑暂时有问题，勿用」；当前主线以 **Ports** 表为准。

---

## 4. GUI 操作说明（与当前脚本的关系）

以下为基于 **App「Arxml」页** 的典型能力（与 `src/gui/smart_thermal.m` 中对 `findPorsInfoConnection`、`findPortFromPortsInfo`、`findComponentPortsFromPortsInfo`、`findPortsInfoFromArxml`、`findPortsInfoToGjson` 的调用一致）：

1. **FindSignal（左区）**  
   - 在 **Signals** 中选一条信号 → **ModelOut** 显示 **输出该信号的组件**，**ModelIn** 显示 **作为输入消费该信号的组件**。  
   - 本质是 **`findPortFromPortsInfo`** 的交互版。

2. **FindComponent（右区）**  
   - 在 **Components** 中选组件 → **SigIn / SigOut** 列出该组件的输入、输出端口（信号）。  
   - 本质是 **`findComponentPortsFromPortsInfo`**。

3. **交叉查询**  
   - 各列表中的 **信号名、组件名** 均可作为下一次查询的入口（「点模型看端口、点信号看上下游」），适合培训现场演示 **端到端追溯**。

4. **Source（底部）**  
   - **Arxml**、**PortsInfoExcel**：与 **`findPortsInfoFromArxml`** / 默认 **`findDefaultPortsInfoExcelPath`** 策略一致，便于切换版本或回归对比。

---

## 5. 命令行快速上手（不讲 GUI 时可用）

```matlab
% 1) 从 ARXML 生成缓存模型并导出 Ports（首次或 ARXML 更新后）
out = findPortsInfoFromArxml('CCM_Internal_swc.arxml');  % 或指定完整路径
% out.excelFile 即为生成的 xlsx

% 2) 查某信号谁发、谁收
R = findPortFromPortsInfo('YourPortName_Signal');

% 3) 查某组件进出的信号
C = findComponentPortsFromPortsInfo('YourSwcName');

% 4) 整表体检 + 组件/信号清单
S = findPorsInfoConnection('excelFile', out.excelFile);

% 5) 生成 gjson（可选）
g = findPortsInfoToGjson('excelFile', out.excelFile);
```

---

## 6. 后续可做的优化（路线图，供讨论）

- **接口与数据类型**：恢复或重写 **Interfaces** 导出，与 **Port** 行对齐，便于和 AUTOSAR 接口定义交叉核对。  
- **命名与别名**：支持 **信号映射表**（ARXML 名 ↔ 实现名），减少「表里对不上」的误报。  
- **图可视化**：在 gjson 基础上接 **内置图布局** 或 Web 图谱，替代「只看列表」。  
- **与 Simulink 架构模型联动**：从列表 **一键打开** 对应 `cache` 下 `.slx` 或主架构中的引用位置（需项目内路径约定）。  
- **性能**：超大型 ARXML 时，**分组件增量导出**、并行扫端口、或跳过未变更组件的哈希缓存。  
- **测试与样例数据**：在 `tests/` 增加小 ARXML + 期望 PortsInfo/gjson 的 **回归用例**，保证重构安全。

---

## 7. 文档与代码位置

- **培训本文档**：`docs/CCM PortsInfo.md`  
- **核心实现**：`src/find/arxml/*.m`  
- **示例 GUI**：`src/gui/smart_thermal.mlapp`（导出代码见 `src/gui/smart_thermal.m`）

---

*文档版本：与 `src/find/arxml` 当前实现同步整理；若函数行为变更，请同步更新第 3、5 节示例。*
