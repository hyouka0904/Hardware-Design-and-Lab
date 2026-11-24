# Hardware Design and Lab

這個儲存庫收錄數位硬體設計實驗、Verilog 範例，以及在 Basys 3 FPGA 上運行的雙人遊戲 **Escape from NTHU**。

## 檔案結構

| 路徑 | 內容 |
| --- | --- |
| [`lab/lab0/`](lab/lab0/) 至 [`lab/lab8/`](lab/lab8/) | 各次實驗的 RTL，以及對應的測試或腳位約束 |
| [`demo/demo1/`](demo/demo1/)、[`demo/demo2/`](demo/demo2/) | VGA 顯示範例 |
| [`final_project/`](final_project/) | Escape from NTHU 的 RTL、FPGA 約束、圖像 ROM 與模擬測試 |
| [`final_project_ver2/`](final_project_ver2/) | 期末專題原型，原型地圖已整合至正式專案 |
| [`common/`](common/)、[`examples/`](examples/)、[`experiments/`](experiments/) | 共用模組與約束、教學範例、實驗程式 |
| [`ip_lab/lab5/`](ip_lab/lab5/)、[`ip_lab5_test/`](ip_lab5_test/)、[`ip_lab/lab6/`](ip_lab/lab6/) | 鍵盤控制器 IP |
| [`Pictrans/`](Pictrans/)、[`archives/`](archives/) | 圖像素材與轉換工具、原始專題封存 |

各實驗和專題有獨立的頂層模組及腳位配置。同名模組可能出現在不同目錄，請依目標專案選擇來源檔。

## Final Project · Escape from NTHU

雙人共用一個鍵盤，在三張正式地圖和一張練習地圖中跳躍、避開障礙並抵達終點。畫面透過 VGA 輸出，板上的七段顯示器顯示計時，專案也提供數位音訊訊號。

| 場景 | 按鍵 | 功能 |
| --- | --- | --- |
| 封面 | Enter | 開啟選單 |
| 選單 | ↑ / W、↓ / S | 切換地圖 |
| 選單 | Enter | 開始遊戲 |
| 遊戲 | ←、→、↑ | 玩家 1 向左、向右、跳躍 |
| 遊戲 | A、D、W | 玩家 2 向左、向右、跳躍 |
| 遊戲或結果畫面 | Enter | 返回選單 |

兩名玩家在所有地圖都可用以下跳躍操作：

- 離開平台後約 100 ms 內仍可起跳（土狼時間）。
- 落地前約 120 ms 內按下跳躍，落地時會自動起跳（跳躍緩衝）。
- 短按跳得低，長按跳得高。跳躍鍵持續按住只會觸發一次。

第四張是從第二版原型整合的練習地圖。玩家 1 是紅色，玩家 2 是藍色，藍色玩家從單向平台出發。按住跳躍可從平台下方跳穿，下降時會落在平台上。

1. 先停在紅河前等雙腳落地，再讓藍色玩家長按跳躍越過紅河。紅色玩家可直接走過紅河。
2. 藍色玩家站在兩條河之間的踏板，維持藍河上的橋，讓紅色玩家過橋。藍色玩家接著可直接走過藍河。
3. 兩人同時站上各自顏色的踏板，右側的門會開 3 秒。上方三格燈會依序熄滅。紅色玩家可留在踏板上的出口，藍色玩家穿過門到藍色出口。若門關上了，任一人離開踏板再踩回去即可重開。

### 在 Vivado 建置

需要 AMD Vivado 與 Basys 3（`xc7a35tcpg236-1`）。從儲存庫根目錄執行以下指令，並指定一個新的建置目錄。

```sh
vivado -mode batch -source final_project/create_project.tcl -tclargs build/final_project
```

腳本會建立專案、設定頂層模組 `final_project`，加入鍵盤控制器和 Basys 3 腳位約束，並從 `background4.coe` 與 `alphabet.coe` 產生兩個 VGA 圖像 ROM。開啟 `build/final_project/escape_from_nthu.xpr`，選擇 **Generate Bitstream**，再透過 **Hardware Manager** 將產生的位元流燒錄到開發板。接上 VGA 螢幕與 Basys 3 USB HID 鍵盤即可操作。

### 執行 RTL 模擬

安裝 Icarus Verilog，確認 `iverilog` 和 `vvp` 可用。以下以 PowerShell 為例，在儲存庫根目錄執行。

```powershell
New-Item -ItemType Directory -Force build | Out-Null
$rtl = Get-ChildItem final_project -Filter *.v | ForEach-Object FullName

foreach ($test in 'position_tb', 'motion_tb', 'round_tb', 'practice_map_tb') {
    $output = "build/$test.vvp"
    iverilog -g2012 -s $test -o $output @rtl "final_project/tests/$test.sv"
    if ($LASTEXITCODE -ne 0) { throw "Compile failed: $test" }
    vvp $output
    if ($LASTEXITCODE -ne 0) { throw "Simulation failed: $test" }
}
```

- `position_tb` 檢查空中放開方向鍵、暫停，以及緩衝起跳時重設垂直步進計時。
- `motion_tb` 檢查方向鍵、可變跳高、土狼時間、跳躍緩衝與玩家狀態重設。
- `round_tb` 檢查勝負鎖定、地圖暫停、結果畫面與回到選單時的重設。

- `practice_map_tb` 檢查第四張地圖的選單入口、單向平台、合作橋、限時門、過關與重設。

這四項測試可獨立執行，無需 Vivado 產生的 ROM IP。
