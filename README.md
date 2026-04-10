# MATLAB Simulink 自动化工具集

面向 Simulink / AUTOSAR 相关工作的脚本与工具：模型创建与调整、端口与标定查找、ARXML/PortsInfo 分析、批处理入口与可选 GUI。

---

## 快速开始

1. **环境**：MATLAB + Simulink（建议 R2016b 及以上；部分功能依赖更高版本）。
2. 在 MATLAB 中 **`cd` 到本仓库根目录**（与 `README.md` 同级）。
3. 添加路径：

```matlab
addpath(fullfile(pwd, 'tools'));
setup_script_path();
```

4. 查看某个函数说明（与 MathWorks 官方 `help` 一致）：

```matlab
help createSubMod
help findCalibParams
```

5. **可选 — 打开图形界面**（MATLAB App Designer 导出类）：

```matlab
smart_thermal   % 类定义在 src/gui/smart_thermal.m
```

---

## 目录结构

```
src/                 # MATLAB 源码
                     #   app/   — app*.m 批处理/流程脚本
                     #   gui/   — MATLAB App（如 smart_thermal）
                     #   create / change / find / delete / utilities / class
data/ccm/            # 样例数据（如 ARXML、PortsInfo 基线表）
cache/               # 本地缓存（如 ARXML 导入生成的 .slx，默认不入库）
artifacts/           # 导出产物（默认不入库）
third_party/         # 外部库与资源
examples/            # 示例与演示模型
tools/               # 路径初始化、辅助脚本
docs/                # 规范与设计文档（含 rules.md）
tests/               # 预留：自动化测试
```

路径约定与迁移策略见 **`docs/rules.md`**（含开源化目录规范）。

---

## 功能怎么查（避免与 README 重复）

| 需求 | 建议 |
|------|------|
| 单个函数怎么用 | MATLAB 命令行：`help 函数名` |
| 某类函数清单 | 浏览 `src/create/`、`src/find/` 等子目录 |
| 模块级说明 | 各子目录下 `README.md`（如 `src/create/README.md`） |
| 注释与工程规范 | `docs/rules.md`、`.cursor/rules/script.mdc` |

README **不再**维护逐函数示例，以免与 `help` 与源码注释双处维护、易过期。

---

## 使用前提（摘要）

- 依赖 Simulink 模型的操作：请先打开或加载目标模型再调用相关函数。
- 依赖 Excel 模板的创建类函数：模板列要求以该函数的 `help` 说明为准。
- DCM / 大文件：解析可能较慢，路径与编码需符合工具链要求。

---

## 作者

Blue.ge

---

## 更新日志

- **2026.04.10**：目录开源化整理（`src/`、`data/ccm/`、`cache/`、`artifacts/`、`third_party/`、`examples/`、`src/gui` 与 `src/app` 分离）；新增 `tools/setup_script_path.m`；README 改为以快速上手与文档入口为主。
- **2023–2025**：各模块功能演进与 DCM/查找/布局等增强，详见 Git 历史与各函数 `help` 中的变更记录。

---

## 许可说明

仅供内部使用
