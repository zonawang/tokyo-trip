# 🗼 東京赤坂出差兩日遊：精緻行程規劃與 Git / macOS 憑證背景推送踩坑實錄

自從與 AI 協作夥伴 **Google Antigravity** 展開合作以來，我們的 LINE 智慧占星助理經歷了多次優化。不過這一次，我們決定暫時偏離占星軌道，帶來一期**【出差番外篇】**。

事緣於下週即將啟程的東京赤坂商務出差。在繁忙的工作之餘，我們規劃了兩日的週末行程。身為行程規劃人的我，決定與 Antigravity 合作打造一個整合米其林二星懷石、迎賓館赤坂離宮、teamLab 科技藝術，並與 GitHub 完美同步的豪華行程網頁。

在這個看似與 LINE Bot 無關，實則在技術底層一脈相承的「出差番外篇」中，我們的挑戰在於同時滿足三位風格截然不同的成員：規劃者（我）、偏好高品質餐飲與清酒的主管 E，以及熱愛重機與技術細節的 CTO M。

網頁利用 Nginx 託管順利上線了，但在代碼同步回 GitHub 倉庫的過程中，我們在無交互終端、Git 背景進程懸掛與憑證權限中，經歷了一次深入底層的排查與調優。

以下是我們在解決這些技術細節時的完整記錄。

---

## 🧩 第一關：需求平衡與 Nginx 輕量託管

行程規劃的重點在於兼顧文化底蘊與現代科技體驗，因此我們在網頁中嵌入了優雅的深色調（Dark Mode）與黃金微光設計，並為三位主角進行了客製化設計：
*   **主管 E 的餐飲需求**：挑選了米其林二星的「菊乃井」與預約極難的「松川」，並著重其清酒配餐服務。
*   **CTO M 的技術視角**：安排了 teamLab Borderless 沉浸式藝術，讓他能從技術角度觀察其粒子系統的運作方式。

為了實現極速加載與低資源消耗，我們捨棄了複雜的前端框架，採用 **純網頁 HTML5 + 原生 CSS 變數 + Intersection Observer 滾動動畫**，並透過 `nginx:alpine` 進行輕量化託管：

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
```

結合 Nginx 啟用 `Gzip` 壓縮與靜態快取，確保在 Google Cloud Run 部署後能實現零延遲加載。

---

## 🧩 第二關：背景 Git Push 掛起與 macOS 鑰匙圈權限排查

在嘗試將最新的代碼 Push 到 GitHub 倉庫時，Git 程序在背景無響應，且進程狀態顯示為 `T` (Stopped)，即處於被作業系統訊號暫停執行的狀態。

排查後發現，這是由於背景終端的限制所致：

> 💡 **背景 TTY 與 SIGTTIN 暫停機制**：
> 1. 在 HTTPS 推送時，由於本地 macOS 鑰匙圈中尚未儲存 `github.com` 的憑證，Git 必須向終端索取使用者名稱與密碼（Token）。
> 2. 然而，背景執行的是非互動式終端機（Non-interactive shell），沒有控制終端（TTY）。
> 3. 當背景進程試圖讀取終端輸入時，Unix 核心會自動向該進程發送 `SIGTTIN` 訊號，強制將其暫停執行，因而造成背景任務中斷。

為解決此問題，我們首先中止了掛起的進程，並由 Antigravity 申請了**「免沙盒執行權限 (Unsandboxed Tool Permission)」**，使其脫離沙盒限制，嘗試調用系統級的 `osxkeychain` 憑證助手。

然而，經測試後確認本地鑰匙圈確實無相關憑證，因此仍需尋求其他驗證管道。

---

## 🧩 第三關：環境變數 Token 救場與本地安全去識別化

隨後我們發現，先前配置的 `GITHUB_TOKEN` 已儲存在環境變數中。我們便利用 Token 拼接 URL 的方式進行安全推送：

```bash
# 使用 Token 動態拼接 URL 進行即時推送
git push "https://$GITHUB_TOKEN@github.com/zonawang/tokyo-trip.git" main
```

推送順利完成，遠端 `main` 分支成功建立。

為避免 Git 將包含明文 Token 的網址寫入本地設定檔 `.git/config` 的上游配置中，我們在推送成功後，立即將其修正為安全的 `origin` 別名：

```bash
# 將分支的 upstream 遠端指回安全的 origin 別名，徹底抹除設定檔中的明文 Token
git config branch.main.remote origin
```

這樣既保留了未來在終端機拉取（Pull）與推送（Push）的便利性，也排除了明文憑證洩漏的安全隱患。

---

## 💬 結語

這次與 AI 夥伴 **Google Antigravity** 的合作，不僅收穫了一個兼具設計感與實用性的精緻行程網頁，也經歷了一次實用的底層系統調優。

從最基礎的網頁效能優化、Nginx 容器配置，到 Unix 進程控制訊號、macOS 鑰匙圈權限與 Git 安全防護，這次的經驗提醒我們，除了業務代碼的開發，底層架構的穩定與資安防護同樣重要。

專案的開源代碼與說明文件已同步更新至 GitHub，歡迎前來參觀與指教。

- 🌐 **線上預覽網址**：[https://tokyo-trip-3sv3zqjszq-de.a.run.app](https://tokyo-trip-3sv3zqjszq-de.a.run.app)
- 🔗 **專案 GitHub 倉庫**：[https://github.com/zonawang/tokyo-trip.git](https://github.com/zonawang/tokyo-trip.git)
