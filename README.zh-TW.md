[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [繁體中文](README.zh-TW.md)

# 2025 ICM Problem E 農田生態系模型重建

本專案以 MATLAB 重建圍繞 2025 ICM Problem E 的四類建模流程，用於工程重現、作品展示與教學。目前發行：[v1.0.0](https://github.com/HanamiGekka/ICM2025-Problem-E-Reconstruction/releases/tag/v1.0.0)。

**原始競賽程式碼並未完整復原。Models I–III 的部分參數採用明確揭露的重建假設，並非原始競賽參數；本專案也不是經實證驗證的農業預測系統。** 重建依據包含競賽論文、留存的數學筆記、部分歷史實作行為與已記錄結果。Task4 分別保留歷史相容版及修正版，不混為同一結果。

## 模型總覽

| 模型 | 可執行流程 | 證據與假設 |
| --- | --- | --- |
| I：四物種 | 六組藥劑情境、含事件的 ODE、收穫與補種、軌跡及熱圖 | 論文方程式與劑量標籤；係數、初值、時程和求解器屬於新假設 |
| II：六物種 | F/V1/V2 最佳化、獨立網格、前後比較與收斂分析 | 論文方程式及單位成本；保留 N4² 與 N4*N6 兩種形式，偏好為新設定 |
| III：七物種 | V1=0、引入蜜蜂、字面授粉與族群耦合授粉、F/V2 最佳化 | 有依據的除草劑移除；替代耦合與新係數分別揭露 |
| IV／Task4：八物種 | 16 種有機策略、預期與歷史 Pareto、確定性 CA/RGB | 留存原始碼證據；歷史相容與修正版分開 |

流程為：設定 → 已說明的微分方程式右側項 → 分段積分與事件 → 多樣性、穩定性及作物彙總 → 有界搜尋／網格 → 匯出、比較與敏感度分析。前三個模型共用計算核心，避免複製三套流程。

[70 列參數表](config/reconstruction_parameters.csv)與[假設說明](docs/methodology/ASSUMED_PARAMETERS.md)列出正規化單位、界限、來源，以及 `documented_only`、`reconstructed_baseline`、`reconstructed_low`、`reconstructed_high` 四種設定。`documented_only` 保留未知參數的 NaN 缺口；不做事後校正或歷史目標擬合。

## 範例結果圖

![六組重建藥劑情境](results/reproduced/full/model1_trajectories.png)

![重建模型的授粉替代形式](results/reproduced/full/model3_pollination.png)

![重建敏感度排序](results/reproduced/full/sensitivity_ranking.png)

圖片為既有 MATLAB 重建輸出，不是新的農田觀測或本次重新計算的結果。

## 證據類別

| 類別 | 本儲存庫中的意義 |
| --- | --- |
| 原始歷史資料 | 個別保存且獲准公開的論文與證書；其餘歷史檔案保留私有 |
| 重建實作 | 依證據及已揭露選擇編寫的可執行 MATLAB 程式，不是完整原始競賽程式碼 |
| 新假設 | 參數表與方法文件中明確列出的係數、初值、時程、求解器與偏好 |
| 歷史相容版 | `historical_compat` 保留有留存證據支持的 Task4 行為 |
| 修正版 | `corrected` 明示時間範圍、零害蟲規則及偏好修正，部分輸出刻意不同 |
| 重現輸出 | 重建流程產生的圖、CSV 與驗證檔，不是農業實測資料 |

## MATLAB 快速開始

已驗證環境為 **MATLAB R2023b（23.2.0.2365128）、Windows x64，僅基礎 MATLAB**。執行數值流程不需要額外工具箱或 Python。在儲存庫根目錄執行：

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

Windows PowerShell 包裝腳本可使用 PATH 中的 MATLAB，或透過 `-MatlabExe` 指定既有執行檔：

```powershell
.\scripts\run_reconstruction.ps1 -Public -MatlabExe matlab
```

單一模型範例：

```matlab
c = reconstruction_config(3,'reconstructed_baseline');
r = simulate_reconstructed(c);
o = optimize_reconstructed(c);
rOptimized = simulate_reconstructed(c,o.decision);
```

## 主要結果與限制

在基準偏好下，Models II 與 III 的目標函數選擇零藥劑。效用提高時作物指標反而下降，F=0 時輸出的穩定性代理指標為零。**這是所設目標函數的計算結果，不是農業建議。** 網格一致不代表證明連續空間中的全域最佳解。[結果報告](docs/results/RECONSTRUCTION_RESULTS.md)保留決策、差異與結構替代形式；[敏感度報告](docs/results/SENSITIVITY_REPORT.md)涵蓋 ±10%／±20%、重新正規化的目標權重、界限與高低壓力設定。

Task4 歷史相容版在顯示精度下符合 Table5 的全部 14 列。預期偏好與留存程式中的反向 Pareto 篩選不同；修正版因時間範圍及零害蟲規則而產生不同田地指標，不藉由調參消除差異。Models I–III 因採用新設定而不等同歷史目標；Model II 相互衝突的兩組目標分別保留。圖形正規化屬於重建時的呈現約定。

結構證據充分不代表實證有效。早期精確參數、原始求解器與事件、GA 歷程、亂數狀態、迴歸樣本及 R² 仍無法復原。蜜蜂／作物耦合是有爭議的模型形式，未驗證為真實生物規律；反覆施藥時，成本仍以正規化單次劑量指標處理。詳見[重建範圍](docs/methodology/RECONSTRUCTION_SCOPE.md)、[修正說明](docs/methodology/CORRECTIONS.md)與[參數來源](docs/methodology/PARAMETER_PROVENANCE.md)。

## 可重現性與目錄

公開檢查不需私有 Original 歷史檔案；私有檢查另核對 74 個歷史檔案與目標轉錄。數值陣列／CSV 為確定性結果，UTC 產生時間與 PNG 時間戳記可能改變。CA 使用已揭露的固定 twister 種子，並還原呼叫端的 RNG 狀態。[可重現性說明](docs/methodology/REPRODUCIBILITY.md)提供完整範圍。本次只維護文件，未重新執行 MATLAB 匯出。

| 目錄 | 用途 |
| --- | --- |
| `config/` | 參數及目標來源表 |
| `src/matlab/`、`tests/matlab/` | 方程式、模擬、最佳化、CA、匯出及公開檢查 |
| `docs/methodology/`、`docs/results/` | 假設、來源、修正、重現步驟與結果 |
| `results/reproduced/` | 已產生的重建圖、CSV、設定及驗證 JSON |
| `historical-documents/` | 獲准公開的歷史論文與證書，位於 MIT 軟體授權範圍之外 |

## 歷史資料、引用與授權

[原始論文與獲獎證書](historical-documents/README.md)是個別授權公開的歷史副本，姓名、簽名與中繼資料按原始位元組保留，其他私有檔案不公開。重用輸出時請註明發行標籤 **v1.0.0**、參數設定與所選 Task4 版本，不應將本儲存庫引用為完整原始競賽程式碼。

[MIT 授權](LICENSE)僅適用於新撰寫且具有相應權利的重建軟體，不自動授予歷史論文、證書、私有歷史原始碼、參考文獻、資料集、照片或第三方材料的權利。目標數值轉錄屬於註明來源的證據，不能因此擴張軟體授權。公開儲存庫採用獨立 Git 歷史及逐項審查的允許清單，只有兩份固定雜湊的歷史 PDF 獲明確授權公開。
