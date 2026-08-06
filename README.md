# Superstore Business Performance Analysis 

> Phân tích hiệu suất kinh doanh và xác định điểm rò rỉ lợi nhuận
> từ bộ dữ liệu Superstore 4 năm — hướng đến quản trị lợi nhuận bền vững

---

## 1. Overview 

**Bối cảnh:**
Superstore là chuỗi bán lẻ tại Mỹ với 3 ngành hàng (Furniture, Office Supplies, Technology),
hoạt động trên 4 khu vực (West, East, Central, South) trong giai đoạn 2014–2017.


**10 câu hỏi kinh doanh (Business Questions) cần trả lời:**

| # | Câu hỏi | Tool |
|---|---------|------|
| BQ1 | Category nào có doanh thu và lợi nhuận cao nhất? | T-SQL |
| BQ2 | Top 5 sản phẩm doanh thu cao nhất — chúng có thực sự sinh lời? | SQL |
| BQ3 | Có bao nhiêu đơn giảm giá >30% nhưng vẫn lỗ? Thiệt hại bao nhiêu? | SQL |
| BQ4 | Khách hàng chủ yếu chọn Ship Mode nào? Mỗi mode mất bao nhiêu ngày?  | SQL |
| BQ5 | Region nào có profit margin cao nhất? Khu vực nào cần cải thiện? | SQL |
| BQ6 | Mỗi Sub-Category đóng góp bao nhiêu % doanh thu trong Category?  | Python |
| BQ7 | Doanh thu từng tháng 2017 tăng hay giảm so với 2016?  | Python |
| BQ8 | Ai là khách hàng loyal? Trong số VIP top sales, ai đang thực sự sinh lời?  | Python |
| BQ9 | Sub-Category nào sinh lời cao nhất trong mỗi Customer Segment?  | Python |
| BQ10 | Phân bổ đơn hàng High/Medium/Low theo từng Region như thế nào?  | Python |

**Mục tiêu phân tích:**
Xác định nguồn gốc lợi nhuận bị thất thoát và đề xuất hành động cụ thể
có thể triển khai ngay mà không cần tăng doanh số.

---

## 2. Dataset Description

**Nguồn:** Sample - Superstore (Kaggle)
**File:** `Sample-Superstore.csv`

| Thuộc tính | Giá trị |
|-----------|---------|
| Số dòng | 9,994 |
| Số cột | 21 |
| Giai đoạn | 02/01/2014 – 30/12/2017 |
| Đơn hàng unique | 5,009 |
| Khách hàng unique | 793 |
| Tổng doanh thu | $2,297,201 |
| Tổng lợi nhuận | $286,397 |
| Missing values | 0 |

**Mô tả các cột chính:**

| Cột | Kiểu | Mô tả |
|-----|------|-------|
| Order ID | VARCHAR | Mã đơn |
| Order Date | DATE | Ngày đặt hàng |
| Ship Date | DATE | Ngày giao hàng |
| Ship Mode | VARCHAR | Standard Class - Second Class - First Class - Same Day |
| Customer Name | VARCHAR | Tên khách hàng |
| Segment | VARCHAR | Consumer - Corporate - Home Office |
| Region | VARCHAR | West - East - Central - South |
| Category | VARCHAR | Furniture - Office Supplies - Technology |
| Sub-Category | VARCHAR | 17 sub-categories |
| Sales | DECIMAL | Doanh thu  |
| Quantity | INT | Số lượng |
| Discount | DECIMAL | Tỉ lệ giảm giá — **lưu dạng 0.3, không phải 30%** |
| Profit | DECIMAL | Lợi nhuận |

**Lưu ý kỹ thuật:**
- Cột `Discount` dạng thập phân: `0.3` = giảm 30% → filter viết `Discount > 0.3`
- Đếm đơn hàng: dùng `COUNT(DISTINCT [Order ID])`, không dùng `COUNT(*)`
- Tính margin: dùng `SUM(Profit) / SUM(Sales)` — không dùng `AVG(Profit/Sales)`

---

## 3. Tech Stack & Tools

| Tool | Vai trò |
|------|---------|
| **SQL** (SQL Server / SSMS) | BQ1–BQ5 |
| **Python** | BQ6–BQ10 + Advanced Analytics |
| **Pandas** | Data manipulation, groupby, pivot |
| **Scipy** | Z-score anomaly detection |
| **Power BI Desktop** | Dashboard tổng quan |

**Nguyên tắc phân công tool:**

```
SQL  → BQ1–BQ5
         Aggregation, filter, window function
         Query ngắn, chạy thẳng trong SSMS, kết nối trực tiếp Power BI

Python → BQ6–BQ10 + Advanced
         Những tác vụ DAX / Power Query xử lý cồng kềnh:

         BQ7     pd.unstack()       thay self-join SQL (15 dòng → 2 dòng)
         RFM     pd.qcut() × 3      thay RANKX × 9 DAX measures
         Cohort  groupby+unstack    thay 15+ bước Power Query
         Anomaly scipy.zscore       DAX không có hàm native
         CLV     AOV × F × Margin   thay AVERAGEX lồng nhau

Power BI → Visual & Dashboard
```

---

## 4. Project Structure

```
Superstore-Business-Analysis/
│
├── README.md                         
│
├── data/
│   └── Sample_-_Superstore.csv                
│
├── sql/
│   └── Superstore_SQL.sql                => BQ1–BQ5 
│       ├── BQ1: Category Sales & Profit
│       ├── BQ2: Top 5 Products by Revenue
│       ├── BQ3: Discount >30% AND Loss Orders
│       ├── BQ4: Orders & Ship Days by Ship Mode
│       └── BQ5: Region Profit Margin Ranking
│
├── notebooks/
│   └── Superstore_Python_BQ6_10_Advanced.ipynb   => BQ6–BQ10
│       ├── BQ6:  Sub-Category % of Category Sales
│       ├── BQ7:  YoY Monthly Revenue 2017 vs 2016
│       ├── BQ8:  Loyal Customer & VIP Profit Flag
│       ├── BQ9:  Best Sub-Category per Segment (rank)
│       ├── BQ10: Order Value Tier by Region
│       ├── ADV:  RFM Segmentation (pd.qcut scoring)
│       ├── ADV:  Cohort Retention Matrix
│       ├── ADV:  Discount Anomaly Detection (Z-score)
│       ├── ADV:  Customer Lifetime Value (CLV)
│       └── Export: 7 CSV files → import vào Power BI
│
└── dashboard/
    └── Superstore.pbix                            ← Power BI file (3 pages)
```

---

## 5. Key Insights & Analysis

### Tổng quan 4 năm

| Năm | Revenue | Profit | Margin | Orders |
|-----|---------|--------|--------|--------|
| FY2014 | $484,247 | $49,544 | 10.2% | 969 |
| FY2015 | $470,533 | $61,619 | 13.1% | 1,038 |
| FY2016 | $609,206 | $81,795 | 13.4% | 1,315 |
| FY2017 | $733,215 | $93,439 | 12.7% ⚠️ | 1,687 |

> **FY2017:** Revenue đỉnh nhưng margin giảm 0.7pp → "growth at a cost",
> nghi ngờ do tăng discount để chốt đơn cuối năm.

---

### BQ1 — Category Performance

| Category | Sales | Sales % | Profit | Margin |
|----------|-------|---------|--------|--------|
| Technology | $836,154 | 36.4% | $145,455 | **17.4%** |
| Office Supplies | $719,047 | 31.3% | $122,491 | 17.0% |
| Furniture | $742,000 | **32.3%** | $18,451 | **2.5%** ⚠️ |

Furniture chiếm 32% doanh thu nhưng chỉ đóng góp **6.4% tổng lợi nhuận**.

---

### BQ2 — Top 5 Products by Revenue

| # | Sản phẩm | Sales | Profit | Margin |
|---|---------|-------|--------|--------|
| 1 | Canon imageCLASS 2200 Copier | $61,600 | $25,200 | 40.9% |
| 2 | Fellowes PB500 Punch Machine | $27,453 | $7,753 | 28.2% |
| 3 | Cisco TelePresence EX90 | $22,638 | **-$1,811** | **-8.0%** ⚠️ |
| 4 | HON 5400 Task Chairs | $21,871 | $0 | 0.0% |
| 5 | GBC DocuBind TL300 | $19,823 | $2,234 | 11.3% |

Doanh thu cao ≠ sinh lời: 2/5 sản phẩm top sales không tạo ra lợi nhuận.

---

### BQ3 — Discount Abuse

| Discount Band | Transactions | Profit | Margin |
|--------------|-------------|--------|--------|
| 0% | 4,798 | +$320,988 | 29.5% |
| 1–20% | 3,803 | +$100,785 | ~12% |
| 21–30% | 227 | -$10,369 | -10.0% |
| 31–50% | 310 | -$48,447 | ~-26% |
| **>50%** | **856** | **-$76,559** | **-119%** ⚠️ |

**1,140 giao dịch** discount >30% và lỗ → phá hủy **-$127,738** lợi nhuận.
Discount >50%: bán $1.00 lỗ $1.19.

---

### BQ4 — Shipping Mode

| Ship Mode | Orders | Tỉ lệ | Avg Ship Days |
|-----------|--------|-------|---------------|
| Standard Class | 2,994 | 59.8% | 5.0 ngày |
| Second Class | 964 | 19.2% | 3.2 ngày |
| First Class | 787 | 15.7% | 2.2 ngày |
| Same Day | 264 | 5.3% | 0 ngày |

---

### BQ5 — Region Margin Gap

| Region | Sales | Profit | Margin | Gap vs West |
|--------|-------|--------|--------|-------------|
| West | $725,458 | $108,418 | **14.9%** | — |
| East | $678,781 | $91,523 | 13.5% | -1.4pp |
| South | $391,722 | $46,749 | 11.9% | -3.0pp |
| Central | $501,240 | $39,706 | **7.9%** | **-7.0pp** ⚠️ |

Gap 7pp tại Central ≈ **$35,000 lợi nhuận bị bỏ quên** mỗi năm.

---

### BQ6 — Sub-Category % of Category

- Chairs chiếm **44.3%** Furniture sales — lớn nhất nhóm
- Tables chiếm **27.9%** Furniture sales nhưng margin **-8.6%** → lỗ ròng -$17,725
- Copiers chỉ **17.9%** Technology sales nhưng margin **37.2%** → sinh lời nhất

---

### BQ7 — YoY Monthly Revenue

| Tháng | 2016 | 2017 | Growth |
|-------|------|------|--------|
| Tháng 1 | $18,543 | $43,971 | **+137.1%** ← tăng mạnh nhất |
| Tháng 5 | $56,988 | $44,261 | **-22.3%** ← giảm mạnh nhất |
| Tháng 8 | $31,115 | $63,121 | **+102.9%** |
| Tháng 11 | $79,412 | $118,448 | **+49.2%** |
| **Tổng** | **$609,206** | **$733,215** | **+20.4%** |

---

### BQ8 — Customer Loyalty Paradox

- **628 / 793** khách hàng loyal (≥ 3 năm) = **79.2%**
- **117 / 628** loyal customers đang có profit âm
- Sean Miller: $25,043 sales nhưng **lỗ -$1,981** → "expensive VIP"
- Tamara Chand: $19,052 sales, **lãi $8,981** (margin 47.1%) → VIP thực sự

---

### BQ9 — Best Sub-Category per Segment

| Segment | Sub-Category #1 | Profit | Margin |
|---------|----------------|--------|--------|
| Consumer | Copiers | $24,084 | 34.5% |
| Corporate | Copiers | $18,990 | 40.6% |
| Home Office | Copiers | $12,544 | 38.2% |

Copiers #1 ở **cả 3 Segments**. Home Office + Office Supplies = **20.8% margin** — cao nhất matrix.

---

### BQ10 — Order Value Tier by Region

| Region | Low (<$500) | Medium ($500–1K) | High (>$1K) |
|--------|------------|-----------------|------------|
| West | 1,206 (75%) | 190 (12%) | 215 (13%) |
| East | 1,034 (74%) | 193 (14%) | 174 (12%) |
| Central | 892 (76%) | 154 (13%) | 129 (11%) |
| South | 603 (73%) | 117 (14%) | 102 (12%) |

---

### Advanced — RFM Segmentation (793 khách hàng)

| Segment | Customers | % | Avg Monetary | Hành động |
|---------|-----------|---|-------------|-----------|
| Champions | 124 | 15.6% | $5,221 | Reward, upsell |
| Loyal | 255 | 32.2% | $3,863 | Cross-sell combo |
| Potential | 217 | 27.4% | $2,159 | Tăng frequency |
| At Risk | 118 | 14.9% | $1,239 | Win-back campaign |
| Lost | 79 | 10.0% | $633 | Re-engage hoặc dừng |

---

### Advanced — Cohort Retention (Cohort 2014: 595 khách)

| Năm | Active | Retention |
|-----|--------|-----------|
| 2014 | 595 | 100.0% |
| 2015 | 437 | 73.4% |
| 2016 | 485 | 81.5% |
| 2017 | 517 | 86.9% |

Retention tăng dần qua các năm → nền tảng khách hàng ngày càng vững.

---

### Advanced — CLV

- **155 / 793 customers (19.5%)** có CLV âm → đang phá hủy giá trị
- Top CLV: Tamara Chand ($8,981), Raymond Buch ($6,976), Sanjit Chand ($5,757)

---

## 6. Business Recommendations

| Mức độ | Hành động | Tác động ước tính | Timeline |
|--------|-----------|------------------|---------|
| 🔴 NGUY CẤP | Áp trần discount tối đa **20%** cho đơn tiêu chuẩn | **+$125,000/năm** | Ngay lập tức |
| 🔴 NGUY CẤP | Re-price hoặc ngừng kinh doanh **Tables** sub-category | **+$35,000/năm** | 1–2 tháng |
| 🟠 CAO | Audit pricing & discount policy tại **Central region** | ~$35,000/năm | 1 quý |
| 🟠 CAO | Kiểm tra product mix Furniture tại Central | Phối hợp liên phòng | 1 quý |
| 🟡 TRUNG BÌNH | Review contract VIP có profit âm (Sean Miller et al.) | Giảm rủi ro | 1 quý |
| 🟡 TRUNG BÌNH | Đẩy mạnh combo **Home Office + Office Supplies** (20.8%) | **+$28,000/năm** | 1 quý |
| 🟢 THẤP | Mở rộng danh mục **Copiers & Paper** (margin 37–43%) | **+$20,000/năm** | 2 quý |
| 🟢 THẤP | Xây dựng loyalty program chính thức từ RFM segments | Tăng retention | 2 quý |

```
Profit hiện tại (avg/năm) :   $286,397
Recoverable (top 4 actions):  +$208,000
Profit mục tiêu            :  ~$494,397  (+73%)

→ Không cần tăng doanh số — chỉ cần tối ưu discount và product mix.
```

---

## 7. How to Run / Reproduction

### Yêu cầu

```bash
pip install pandas numpy scipy
```

### Bước 1 — Chạy T-SQL (BQ1–BQ5)

1. Import `data/Sample_-_Superstore.csv` vào SQL Server
   (dùng **Import Wizard** hoặc **BULK INSERT**)
2. Đặt tên bảng là `superstore`
3. Mở `sql/Superstore_Junior_TSQL.sql` trong **SSMS**
4. Chạy từng section BQ1 → BQ5

```sql
-- Kiểm tra load đúng chưa
SELECT COUNT(*) FROM superstore;   -- kỳ vọng: 9,994
```

### Bước 2 — Chạy Python Notebook (BQ6–BQ10 + Advanced)

1. Đặt `Sample_-_Superstore.csv` cùng thư mục với notebook
2. Mở `notebooks/Superstore_Python_BQ6_10_Advanced.ipynb`
3. Chạy **Kernel → Restart & Run All**
4. Chạy cell **Export** cuối cùng → xuất 7 file CSV

```python
# Kiểm tra load đúng chưa
import pandas as pd
df = pd.read_csv('Sample_-_Superstore.csv', encoding='latin-1')
print(df.shape)   # kỳ vọng: (9994, 21)
```

### Bước 3 — Dựng visual Power BI (BQ6–BQ10)

1. Mở Power BI Desktop
2. **Get Data → Text/CSV** → import `Sample_-_Superstore.csv`
   hoặc import 7 file CSV đã export từ notebook
3. Làm theo hướng dẫn trong `guide/Power_BI_Guide_BQ6_BQ10.md`
   - DAX measures cần tạo
   - Visual type + field mapping cho từng BQ
   - Conditional formatting, slicer, layout dashboard

```
guide/Power_BI_Guide_BQ6_BQ10.md
├── DAX measures cơ bản (Total Sales, Profit Margin, v.v.)
├── BQ6: Stacked Bar + Matrix
├── BQ7: Line Chart + Column YoY %
├── BQ8: Scatter + Table VIP Flag
├── BQ9: Clustered Bar + Heatmap Matrix
├── BQ10: 100% Stacked Bar + Cross-tab
└── Layout 3 trang + Slicer + Format số

