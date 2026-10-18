[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [繁體中文](README.zh-TW.md)

# 2025 ICM Problem E 农田生态系统模型重建

本项目用 MATLAB 重建围绕 2025 ICM Problem E 的四类建模流程，用于工程复现、作品展示和教学。当前发行：[v1.0.0](https://github.com/HanamiGekka/ICM2025-Problem-E-Reconstruction/releases/tag/v1.0.0)。

**原始竞赛代码没有完整恢复。Models I–III 的部分参数采用明确披露的重建假设，并非原始竞赛参数；本项目也不是经过实证验证的农业预测系统。** 重建依据包括竞赛论文、存留数学笔记、部分历史实现行为和已记录结果。Task4 同时保留历史兼容与修正版，不混为同一结果。

## 模型总览

| 模型 | 可运行流程 | 证据与假设 |
| --- | --- | --- |
| I：四物种 | 六组药剂情景、含事件的 ODE、收获与补种、轨迹和热图 | 论文方程与剂量标签；系数、初值、日程和求解器为新假设 |
| II：六物种 | F/V1/V2 优化、独立网格、前后对照与收敛分析 | 论文方程和单位成本；保留 N4² 与 N4*N6 两种形式，偏好为新设定 |
| III：七物种 | V1=0、引入蜜蜂、字面授粉与种群耦合授粉、F/V2 优化 | 有据可查的除草剂移除；替代耦合和新系数分别披露 |
| IV／Task4：八物种 | 16 种有机策略、预期与历史 Pareto、确定性 CA/RGB | 存留源码证据；历史兼容与修正版分开 |

流程为：配置 → 已说明的微分方程右端项 → 分段积分与事件 → 多样性、稳定性及作物汇总 → 有界搜索／网格 → 导出、比较和敏感性分析。前三个模型共用一个计算内核，避免复制三套流程。

[70 行参数表](config/reconstruction_parameters.csv)与[假设说明](docs/methodology/ASSUMED_PARAMETERS.md)列明归一化单位、边界、来源，以及 `documented_only`、`reconstructed_baseline`、`reconstructed_low`、`reconstructed_high` 四种配置。`documented_only` 保留未知参数的 NaN 缺口；不做事后调参或历史目标拟合。

## 示例结果图

![六组重建药剂情景](results/reproduced/full/model1_trajectories.png)

![重建模型的授粉替代形式](results/reproduced/full/model3_pollination.png)

![重建敏感性排序](results/reproduced/full/sensitivity_ranking.png)

图片是已有 MATLAB 重建输出，不是新的农田观测或本轮重算结果。

## 证据类别

| 类别 | 本仓库中的含义 |
| --- | --- |
| 原始历史材料 | 单独保存且获准公开的论文与证书；其余历史档案保留私有 |
| 重建实现 | 依据公开证据和披露选择编写的可运行 MATLAB 代码，不是完整原始竞赛源码 |
| 新假设 | 参数表和方法文档中明确列出的系数、初值、日程、求解器与偏好 |
| 历史兼容版 | `historical_compat` 保留有存留证据支持的 Task4 行为 |
| 修正版 | `corrected` 明示时域、零害虫规则及偏好修正，部分输出有意不同 |
| 复现输出 | 重建流程生成的图、CSV 与验证文件，不是农业实测数据 |

## MATLAB 快速开始

已验证环境为 **MATLAB R2023b（23.2.0.2365128）、Windows x64，仅基础 MATLAB**。运行数值流程不需要额外工具箱或 Python。在仓库根目录执行：

```matlab
addpath('src/matlab','tests/matlab');
run_checks('public');
export_task4('historical_compat');
export_task4('corrected');
export_ca_scenarios;
export_historical_comparison;
export_full_reconstruction;
verify_exports;
```

Windows PowerShell 包装脚本支持 PATH 中的 MATLAB，或通过 `-MatlabExe` 指定已有可执行文件：

```powershell
.\scripts\run_reconstruction.ps1 -Public -MatlabExe matlab
```

单个模型示例：

```matlab
c = reconstruction_config(3,'reconstructed_baseline');
r = simulate_reconstructed(c);
o = optimize_reconstructed(c);
rOptimized = simulate_reconstructed(c,o.decision);
```

## 主要结果与限制

在基线偏好下，Models II 和 III 的目标函数选择零药剂。效用提高时作物指标反而下降，F=0 时打印的稳定性代理指标为零。**这是所设目标函数的计算结果，不是农业建议。** 网格一致不等于证明连续空间的全局最优。[结果报告](docs/results/RECONSTRUCTION_RESULTS.md)保留决策、差异和结构替代形式；[敏感性报告](docs/results/SENSITIVITY_REPORT.md)覆盖 ±10%／±20%、重新归一化的目标权重、边界与高低压力配置。

Task4 历史兼容版在展示精度下匹配 Table5 的全部 14 行。预期偏好与存留源码中反向的 Pareto 筛选不同；修正版因时域和零害虫规则而产生不同田地指标，不通过调参消除差异。Models I–III 因采用新设定而不等于历史目标；Model II 相互冲突的两组目标分别保留。图像归一化属于重建时的展示约定。

结构证据充分不代表实证有效。早期精确参数、原始求解器与事件、GA 历程、随机数状态、回归样本和 R² 无法恢复。蜜蜂／作物耦合是有争议的模型形式，未验证为真实生物规律；反复施药时，成本仍按归一化单次剂量指标处理。详见[重建范围](docs/methodology/RECONSTRUCTION_SCOPE.md)、[修正说明](docs/methodology/CORRECTIONS.md)和[参数来源](docs/methodology/PARAMETER_PROVENANCE.md)。

## 可复现性与目录

公开检查无需私有 Original 档案；私有检查另核验 74 个历史文件和目标转录。数值数组／CSV 为确定性结果，UTC 生成时间及 PNG 时间戳可变化。CA 使用已披露的固定 twister 种子，并还原调用者的 RNG 状态。[可复现性说明](docs/methodology/REPRODUCIBILITY.md)给出完整边界。本轮只维护文档，未重新运行 MATLAB 导出。

| 目录 | 用途 |
| --- | --- |
| `config/` | 参数及目标来源表 |
| `src/matlab/`、`tests/matlab/` | 方程、模拟、优化、CA、导出及公开检查 |
| `docs/methodology/`、`docs/results/` | 假设、来源、修正、复现步骤和结果 |
| `results/reproduced/` | 已生成的重建图、CSV、配置和验证 JSON |
| `historical-documents/` | 获准公开的历史论文与证书，位于 MIT 软件许可范围之外 |

## 历史资料、引用与许可证

[原始论文与获奖证书](historical-documents/README.md)是单独授权公开的历史副本，姓名、签名和元数据按原字节保留，其他私有档案不公开。复用输出时请注明发行标签 **v1.0.0**、参数配置和所选 Task4 变体，不应将本仓库引用为完整原始竞赛源码。

[MIT 许可证](LICENSE)仅适用于新编写且具有相应授权的重建软件，不自动授予对历史论文、证书、私有历史源码、参考文献、数据集、照片或第三方材料的权利。目标数值转录属于注明来源的证据，不能因此扩展软件授权。公开仓库采用独立 Git 历史和逐项审查的允许列表，只有两份固定哈希的历史 PDF 被明确授权公开。
