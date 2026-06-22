# 🗾 東京赤坂商務休閒二日遊 | Tokyo Akasaka 2-Day Itinerary

[![Cloud Run Deployed](https://img.shields.io/badge/Deployed%20to-Cloud%20Run-blue?logo=google-cloud&logoColor=white&style=flat-style)](https://tokyo-trip-3sv3zqjszq-de.a.run.app)
[![Tech Stack](https://img.shields.io/badge/Tech%20Stack-HTML%20%2F%20Vanilla%20CSS%20%2F%20JS-gold?style=flat-style)](#)

這是一個專為**三人商務出差與假日休閒**量身打造的東京赤坂兩日精選行程網頁。網頁採用極致奢華的深色調（Dark Mode）與黃金微光設計，提供流暢的動態效果與響應式互動體驗，完美展現超齡的行程規劃與生活品味。

🎯 **線上預覽網址**：[https://tokyo-trip-3sv3zqjszq-de.a.run.app](https://tokyo-trip-3sv3zqjszq-de.a.run.app)

---

## 🎭 專屬成員介紹 (The Crew)

這趟行程旨在完美平衡三個截然不同的靈魂，讓兩位 50 歲的主管既能享受文化底蘊，又能體驗當代科技藝術：

*   🧑‍💼 **你 (行程規劃者)**：29 歲、高級感代言人。核心需求是每處細節都要充滿質感，極力避免任何「踩雷」點。
*   🍷 **主管 E (天秤座資深主管)**：人類清酒掃地機。品味極高，選餐廳猶豫不決但預算無上限，對清酒配餐有極致追求。
*   🤘 **CTO M (重機騎士/金屬樂迷)**：最接地氣的技術巨擘。看似對高級料理無感（「好吃路邊攤也是米其林」），但對科技藝術（teamLab 粒子系統）充滿熱情。

---

## 📅 行程亮點 (Itinerary Highlights)

### Day 1: 文化底蘊 & 精緻食饗
*   🍳 **早餐**：[Bricolage Bread & Co.](https://maps.google.com/maps?q=Bricolage+Bread+%26+Co.+Roppongi+Tokyo) — 烘焙手工天然酵母麵包。
*   ⛩ **文化**：[日枝神社 千本鳥居](https://maps.google.com/maps?q=Hie+Shrine+Akasaka+Tokyo) — 鬧區中的紅色千本鳥居。
*   🏛 **景點**：[迎賓館赤坂離宮](https://maps.google.com/maps?q=Akasaka+Palace+State+Guest+House+Tokyo) — 新巴洛克式華麗宮殿。
*   🍱 **午餐**：[菊乃井 赤坂店 (⭐⭐ 米其林)](https://maps.google.com/maps?q=Kikunoi+Akasaka+Tokyo) — 正統京都懷石料理。
*   ☕ **下午茶**：[The Classic House at Akasaka Prince](https://maps.google.com/maps?q=Classic+House+Akasaka+Prince+Tokyo) — 1930年代法式優雅洋館。
*   🥩 **晚餐**：[鐵板燒 あかさか (ANA InterContinental 37F)](https://maps.google.com/maps?q=ANA+InterContinental+Tokyo+Teppanyaki) — 俯瞰東京高空夜景，享受頂級神戶牛。

### Day 2: 藝術巡禮 & 東京風情
*   🥞 **早餐**：[Mercer Brunch Roppongi](https://maps.google.com/maps?q=Mercer+Brunch+Roppongi+Tokyo) — 時尚美式早午餐與綿密法式吐司。
*   🎨 **藝術**：[teamLab Borderless (麻布台Hills)](https://maps.google.com/maps?q=teamLab+Borderless+Azabudai+Hills+Tokyo) — 全球頂尖沉浸式數位光影藝術。
*   🐄 **午餐**：[赤坂 雷門 高級焼肉](https://maps.google.com/maps?q=Yakiniku+Raimon+Akasaka+Tokyo) — 高性價比 A5 黑毛和牛午間套餐。
*   ☕ **下午茶**：[ANA InterContinental Atrium Lounge](https://maps.google.com/maps?q=ANA+InterContinental+Tokyo) — 精緻高空挑中庭主題英式下午茶。
*   🛍 **購物**：[東京 Midtown & サントリー美術館](https://maps.google.com/maps?q=Tokyo+Midtown+Roppongi) — 日本傳統美學與設計名店。
*   🌆 **夜景**：[森美術館 & 東京 City View](https://maps.google.com/maps?q=Mori+Art+Museum+Roppongi+Hills+Tokyo) — 52樓 360 度環繞都市天際線夕陽與夜景。
*   🍶 **晚餐**：[松川 (Matsukawa)](https://maps.google.com/maps?q=Matsukawa+Restaurant+Akasaka+Tokyo) — 東京極致奢華的頂級懷石料理殿堂。

---

## 🛠 專案結構與架構

本專案採用輕量、極速、零相依（Zero Dependency）的純前端架構，並透過 Docker Nginx 容器化進行雲端部署：

```text
├── index.html       # 行程網頁核心（含 HTML5 語意化結構、響應式 CSS、動態 Observer 腳本）
├── nginx.conf       # 高效能 Nginx 設定（啟用 Gzip 壓縮、快取靜態資源，並接聽 8080 端口）
├── Dockerfile       # Nginx Alpine 多階段構建
└── .dockerignore    # 排除 Git 檔案以加速 Docker 映像檔建置
```

---

## 💻 本地開發與運行

### 方法 1：直接開啟
直接在瀏覽器中按兩下 `index.html` 即可運行！

### 方法 2：使用 Docker 模擬雲端環境
1. 建置 Docker 映像檔：
   ```bash
   docker build -t tokyo-trip .
   ```
2. 啟動容器（對應本地 8080 端口）：
   ```bash
   docker run -d -p 8080:8080 tokyo-trip
   ```
3. 在瀏覽器中輸入 `http://localhost:8080` 即可預覽。

---

## ☁️ Google Cloud Run 部署指南

此網頁目前託管於 Google Cloud Run，部署流程如下：

```bash
# 1. 確保已登入 Google Cloud 並設定目標專案
gcloud auth login
gcloud config set project line-zona

# 2. 一鍵建置並部署至 Asia-East1 (台灣) 節點
gcloud run deploy tokyo-trip \
  --source . \
  --project line-zona \
  --region asia-east1 \
  --allow-unauthenticated \
  --port 8080 \
  --quiet
```

*部署優勢*：
- 配置 `--min-instances 0`，不產生常駐費用。
- 靜態 Nginx 對記憶體與 CPU 要求極低，免費額度內即可輕鬆承載。

---

## 📝 授權與維護
由 **zonawang** 精心策劃與維護。如有任何行程變動，隨時更新 `index.html` 重新部署即可！✈️
