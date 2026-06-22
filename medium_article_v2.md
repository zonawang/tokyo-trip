# 🗼 東京赤坂出差兩日遊：精緻行程規劃與 Git / macOS 憑證背景推送踩坑實錄

自從與 AI 協作夥伴 **Google Antigravity** 展開合作以來，我們的 LINE 智慧水晶占星助理經歷了多次靈魂升級。不過這一次，我們決定暫時偏離占星軌道，帶來一期**【出差番外篇・特別插播】**。

事緣於下週即將啟程的東京赤坂商務出差。在繁忙的工作之餘，我們規劃了兩日的週末行程。身為行程規劃人的我，決定與 Antigravity 挑戰一項全新任務：打造一個整合米其林二星懷石、迎賓館赤坂離宮、teamLab 科技藝術，並與 GitHub 完美同步的豪華行程網頁。

在這個看似與 LINE Bot 無關，實則在技術底層一脈相承的「出差番外篇」中，我們面臨的首要挑戰，在於如何用同一個網頁，同時滿足三位風格、品味截然不同的成員：
*   **質感強迫症規劃者（我）**：連早餐麵包都必須是天然酵母，還得在主管脫鞋進榻榻米包廂前，默默確認大家今天有沒有穿乾淨的襪子，以免在米其林餐廳引發公關危機。
*   **主管 E（天秤座資深主管）**：人類清酒掃地機。對高品質餐飲與清酒有著極致追求，雖然選餐廳會猶豫不決，但看到帳單數字時卻是最淡定的一位。
*   **CTO M（重機騎士與金屬樂迷）**：出發前表示「只要好吃，路邊攤也是米其林」，甚至以為 teamLab「那不就是網美燈光秀」。

網頁在 Nginx 託管下順利上線了，但在將代碼同步回 GitHub 倉庫的最後一哩路上，Git 程序卻似乎在背景有了自己的想法。我們在無交互終端、背景進程懸掛與憑證權限中，展開了一次充滿趣味與底層細節的調優排查。

以下是我們這次的合作與踩坑實錄。

---

## 🧩 第一關：需求平衡與 Nginx 輕量託管

為了讓兩位 50 歲的主管既能享受歷史文化底蘊，又能體驗現代科技，我們在網頁中嵌入了優雅的深色調（Dark Mode）與黃金微光設計，並為兩位進行了「精準打擊」：
*   針對主管 E，我們挑選了米其林二星的「菊乃井」與預約極難的「松川」，並著重其清酒配餐（Pairing）服務；
*   針對 CTO M，我們在網頁中強烈推薦了 teamLab Borderless 沉浸式藝術。果不其然，進去後他默默蹲在展間研究了 15 分鐘粒子系統的運作邏輯，並表示「這個動態渲染做得很扎實」。

為了讓這個網頁具備極速加載與低資源消耗，我們捨棄了繁重的前端框架，採用 **純網頁 HTML5 + 原生 CSS 變數 + Intersection Observer 滾動動畫**，並編寫了極簡的 `nginx:alpine` 進行託管：

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
```

結合 Nginx 啟用 `Gzip` 壓縮與靜態快取，確保在 Google Cloud Run 部署後能實現零延遲加載。

---

## 🧩 第二關：背景 Git Push 掛起與 macOS 鑰匙圈權限排查

當我們滿懷信心準備執行 `git push -u origin main` 時，終端機卻陷入了無盡的沉默。

排查系統進程後，我們發現 Git 推送程序卡在背景，且狀態顯示為 `T` (Stopped)。原來，我們無意間觸發了 Unix 核心的底層保護機制：

> 💡 **背景 TTY 與 SIGTTIN 暫停機制**：
> 1. 在 HTTPS 推送時，由於本地 macOS 鑰匙圈中尚未儲存 `github.com` 的憑證，Git 必須向終端索取使用者名稱與密碼（Token）。
> 2. 然而，AI 協作環境在背景執行的是非互動式終端機（Non-interactive shell），並沒有控制終端（TTY）。
> 3. 當背景進程試圖讀取終端輸入時，Unix 核心會自動向該進程發送 `SIGTTIN` 訊號，強制將其暫停執行（也就是俗稱的「罰站」），這就導致任務卡死且不會輸出任何錯誤日誌。

為了解決這個問題，我們首先使用 `kill -9` 中止了掛起的進程，並由 Antigravity 申請了**「免沙盒執行權限 (Unsandboxed Tool Permission)」**，使其脫離沙盒限制，嘗試調用系統級的 `osxkeychain` 憑證助手。

可惜的是，經查詢後確認，我的 Mac 鑰匙圈裡原本就空空如也。

---

## 🧩 第三關：環境變數 Token 救場與本地安全去識別化

就在排查陷入僵局時，我突然想起來：「不對，我的 Personal Access Token 其實早就設定在環境變數裡了！」

這句話成了破局的關鍵。Antigravity 迅速在環境變數中檢索到了我的 `GITHUB_TOKEN`，並想出了一個安全、免提示的推送妙招：

```bash
# 使用 Token 動態拼接 URL 進行即時推送
git push "https://$GITHUB_TOKEN@github.com/zonawang/tokyo-trip.git" main
```

推送瞬間秒成功，遠端 `main` 分支順利建立。

不過，由於 Git 在推送時會非常貼心地將這條包含明文 Token 的網址寫入本地 `.git/config` 設定檔中。為了保障我的資安，Antigravity 在推送成功後，立即將其修正為安全的 `origin` 別名：

```bash
# 將分支的 upstream 遠端指回安全的 origin 別名，徹底抹除設定檔中的明文 Token
git config branch.main.remote origin
```

這樣既保留了未來在終端機拉取（Pull）與推送（Push）的便利性，也排除了明文憑證洩漏的安全隱患。

---

## 💬 結語

這次與 AI 夥伴 **Google Antigravity** 的合作，不僅收穫了一個兼具設計感、能完美安撫兩位刁鑽主管的精緻行程網頁，也經歷了一次實用的底層系統調優。

我們從最基礎的網頁效能優化、Nginx 容器配置，一路深入到 Unix 進程控制訊號（SIGTTIN）、macOS 鑰匙圈權限與 Git 安全防護。這讓我深刻體會到，一個優秀的 AI 夥伴不只會寫代碼，更能深入底層守護系統的安全。

專案的開源代碼與說明文件已同步更新至 GitHub，歡迎前來參觀與指教（順便祝我這次出差襪子沒有破洞）。

- 🌐 **線上預覽網址**：[https://tokyo-trip-3sv3zqjszq-de.a.run.app](https://tokyo-trip-3sv3zqjszq-de.a.run.app)
- 🔗 **專案 GitHub 倉庫**：[https://github.com/zonawang/tokyo-trip.git](https://github.com/zonawang/tokyo-trip.git)
