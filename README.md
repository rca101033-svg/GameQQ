# Wasteland: Last Horizon (廢土：最後地平線)
### 橫向廢土生存 x 六角格探險 x Roguelike 卡牌策略單機手機遊戲

本專案採用 Godot Engine 4.3 (GDScript) 開發，專為手機橫向操作 (Landscape Touch) 打造，具備手勢拖拽出牌、生存數值倒數 (日夜交替/飢渴/感染)、For The King 式六角網格探險，以及「返回根據地安全屋方可存檔結算」的硬派撤離循環。

---

## 🎮 遊戲核心機制與遊玩循環

1. **第 7 號安全屋 (基地根據地)**
   - 休息治療：清空負面狀態、恢復生命、時間推進至清晨。
   - 終端機存檔：全遊戲唯一合法存檔點，進入廢土後無法隨意 SL 存檔。
   - 庫存整備、卡組調整、零件升級。

2. **廢土六角地圖 (Hex Map)**
   - 每移動 1 格推進 1 小時 (消耗飽食度、水分)。
   - 日夜交替：夜晚視線縮小、感染度上升、遭遇敵人強度提升 30%。
   - 節點事件：廢墟搜刮物資、輻射廢棄區、遭遇戰鬥。

3. **Roguelike 卡牌戰鬥 (Landscape Drag & Drop)**
   - 橫向佈局，手指向上拖曳出牌，鬆開釋放，下拉或 AP 不足自動彈回。
   - 飢渴與疾病直接懲罰戰鬥數值 (如 AP 減少、附加虛弱)。
   - 戰死強制回營並遺失探險所得物資。

---

## 🎨 免費線上開源素材庫推薦與配置指南

本專案架構完全相容開源 CC0 / 免費商用素材庫，推薦整合以下資源：

| 類別 | 推薦免費素材來源 | 授權說明 | 建議用途 |
| :--- | :--- | :--- | :--- |
| **卡牌圖標與狀態** | Game-icons.net | CC BY 3.0 | 卡牌能力圖示、Buff/Debuff 狀態標記、UI 動作圖示 |
| **UI 介面與按鈕** | Kenney.nl (UI Pack) | CC0 1.0 (公有領域) | 廢土風格面板、進度條、彈窗與按鈕切片 |
| **廢土角色與怪物** | OpenGameArt.org | CC0 / OGA-BY | 廢土掠奪者、變異生物、拾荒者立繪 |
| **六角格地貌貼圖** | Kenney.nl (Hexagon Pack) | CC0 1.0 | 六角地圖格子貼圖 (荒漠、輻射坑、廢墟建築) |
| **音效與音效合成** | sfxr.me / Kenney Audio | CC0 1.0 | 抽牌聲、出牌打擊、受傷、日夜鐘聲 |

---

## 🚀 如何上傳至 GitHub 並啟用自動建置

### 步驟 1：在 GitHub 建立全新儲存庫
1. 登入 GitHub，點選右上角 New repository。
2. 命名為 `wasteland-card-game`，設為 Public 或 Private。

### 步驟 2：本地推播至 GitHub
在專案根目錄開啟終端機執行：
```bash
git remote add origin https://github.com/<您的GitHub帳號>/wasteland-card-game.git
git branch -M main
git push -u origin main
```

### 步驟 3：開啟 GitHub Pages 網頁試玩 (免安裝)
本專案已內建 GitHub Actions 工作流，會自動安裝 Godot 4.3、匯出 HTML5 頁面、並部署到 GitHub Pages。

1. 進入 GitHub 儲存庫的 **Settings** -> **Pages**。
2. 在 **Build and deployment** 下方的 **Source** 選擇 **GitHub Actions**。
3. 每次推播至 main 分支時，GitHub Actions 會自動以 Godot 4 引擎匯出 HTML5 版本，產出線上手機瀏覽器即可直接遊玩的靜態網址。
4. 若專案尚未加入 `project.godot`，工作流會先生成佔位頁面，以確保 Pages 站點可成功部署；當遊戲專案加入後，下一次推播會自動進行真正的 HTML5 匯出。

### Godot 4 工作流重點
```yaml
- name: Setup Godot 4.3
  uses: chickensoftgames/setup-godot@v2
  with:
    version: "4.3.0"
    include_templates: true

- name: Export Godot project to HTML5
  run: |
    godot --headless --path . --export-release "Web" build/web/index.html
```

這樣可讓 GitHub Actions 在 CI 中直接執行 Godot 匯出，並部署成 `github.io` 網頁版本。
