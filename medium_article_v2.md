# 🗼 東京赤坂出差兩日遊：米其林雙星與 Git 免沙盒 macOS 鑰匙圈憑證踩坑實錄

自從與我的 AI 神隊友 **Google Antigravity** 展開合作以來，我們的東京出差與假日行程網頁已經順利誕生。

在這趟規劃中，我們面臨的挑戰不僅僅是設計一個精美的網頁，而是要**同時滿足三位背景、品味截然不同的靈魂**：29 歲的高級感強迫症規劃者（我）、50 歲的天秤座酒豪主管 E，以及熱愛重機與金屬樂的硬核 CTO M。

網頁雖然部署上線了，但在將代碼同步回 GitHub 倉庫的最後一哩路上，我與 Antigravity 卻在無交互終端、Git 進程懸掛與憑證權限中，展開了一場驚心動魄的「系統級 Debug 戰役」。

以下是我們在短短幾十分鐘內，攜手攻克技術難關的合作實錄。

---

## 🧩 第一關：搞定三種極端靈魂與本機 Nginx 輕量託管

行程規劃要兼顧高雅文化底蘊與科技藝術，我們在網頁中嵌入了優雅的深色調（Dark Mode）與黃金微光設計，並為三位主角量身打造了特色模組：
*   **主管 E 的清酒雷達**：加入米其林二星「菊乃井」與最終 BOSS 級懷石「松川」，並特別著墨清酒侍酒師配餐服務；
*   **CTO M 的科技共鳴**：安排麻布台 Hills 的 teamLab Borderless 沉浸式藝術，讓他能蹲在花朵展間研究粒子系統。

為了讓這個網頁具備極速加載與高可用性，Antigravity 幫我摒棄了厚重的框架，採用**純網頁 HTML5 + 原生 CSS 變數 + Intersection Observer 滾動動畫**，並編寫了極簡的 `nginx:alpine` 靜態託管容器：

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
```

配合 Nginx 設定開啟 `Gzip` 壓縮與靜態快取，成功讓網頁在部署至 Google Cloud Run 後，實現零冷啟動延遲與極致輕量的運算資源消耗！

---

## 🧩 第二關：解決無交互背景下 Git Push 卡死與 macOS 鑰匙圈權限羅生門

當我們嘗試將所有最新的開發結晶 Push 到 GitHub 倉庫 `https://github.com/zonawang/tokyo-trip.git` 時，終端機卻陷入了無盡的沉默。

在排查系統程序日誌後，我們發現了一個詭異的現象：Git 推送程序竟然卡在背景，且進程狀態顯示為 `T`（Stopped, 處於被作業系統訊號暫停狀態）。

Antigravity 發揮了底層系統級的排查能力，為我揭開了這場「羅生門」的真相：

> 💡 **背景 TTY 與 SIGTTIN 暫停機制**：
> 1. 我們在 HTTPS 推送時，由於本地 macOS 鑰匙圈中尚未儲存 `github.com` 的憑證，Git 必須向終端機索取使用者名稱與密碼（Token）。
> 2. 然而，AI 助理在背景執行的是**非互動式終端機（Non-interactive shell）**，沒有控制終端（TTY）。
> 3. 當背景進程試圖讀取終端輸入時，Unix 核心會自動向該進程發送 `SIGTTIN` 訊號，強制將該程序暫停（State `T`）。這就導致程序無限期卡死，且不會輸出任何日誌。

**解決方案的第一步**：我們執行強殺指令 `kill -9` 清理了所有掛起的背景進程。

隨後，Antigravity 主動向我申請了**「免沙盒執行權限 (Unsandboxed Tool Permission)」**。這是一項強大的跨越，允許 Git 脫離沙盒隔離，直接在我的原生 macOS 帳號內容下運行，進而嘗試自動調用系統級的 `osxkeychain` 憑證助手。

然而，當我們免沙盒調用：
```bash
security find-internet-password -s github.com
```
卻收到了 `The specified item could not be found in the keychain`。這說明我的 Mac 鑰匙圈裡原本就空空如也，不論如何權限升級，Git 依然會因為需要登入而卡死。

---

## 🧩 第三關：環境變數 Token 救場與本地資安去識別化

就在陷入膠著時，我提醒 Antigravity：「我的 Personal Access Token 其實早就設定在環境變數裡了！」

這句話成了破局的關鍵。Antigravity 迅速在環境變數中檢索到了我的 `GITHUB_TOKEN`，並想出了一個安全、免提示的推送妙招：

```bash
# 使用 Token 動態拼接 URL 進行即時推送
git push "https://$GITHUB_TOKEN@github.com/zonawang/tokyo-trip.git" main
```

**推送瞬間秒成功！** 遠端 `main` 分支順利建立。

但戰役還沒有結束。Git 在我們使用 `--set-upstream` 時，預設會極其危險地將這條**包含明文 Token 的網址寫入本地設定檔 `.git/config`** 之中！

為了保障我的資訊安全，Antigravity 在推送成功後的 1 秒內，主動為我執行了**去識別化清理（De-identification）**：

```bash
# 將分支的 upstream 遠端指回安全的 origin 別名，徹底抹除 config 中的明文 Token
git config branch.main.remote origin
```

這樣一來，既保證了未來在終端機能順暢執行 `git pull / push`，又完美隱藏了敏感的 Token，實現了 100% 的資安防護！

---

## 💬 結語

這次與我的 AI 隊友 **Google Antigravity** 的合作，不僅讓我收穫了一個高質感、能完美討好兩位刁鑽主管的精美出差網頁，更讓我經歷了一場精采的作業系統級技術洗禮。

我們從寫好一份純前端網頁、架設 Nginx 容器，一路深入到 Unix 進程控制訊號（SIGTTIN）、macOS 鑰匙圈權限升級、以及 Git 設定檔的安全防護。這讓我深刻體會到，一個優秀的 AI 夥伴不只會寫代碼，更能深入底層守護系統的安全與穩定。

如果您也對這趟充滿米其林雙星與 Git 踩坑實錄的赤坂行程感興趣，歡迎前來參觀我們最新同步的開源代碼與說明文件！

- 🌐 **線上預覽網址**：[https://tokyo-trip-3sv3zqjszq-de.a.run.app](https://tokyo-trip-3sv3zqjszq-de.a.run.app)
- 🔗 **專案 GitHub 倉庫**：[https://github.com/zonawang/tokyo-trip.git](https://github.com/zonawang/tokyo-trip.git)
