# Phân tích Hiệu suất Kinh doanh & Thông tin Chiến lược Superstore (FY2014 - FY2017)

## Tổng quan dự án
Dự án này thực hiện một phân tích dữ liệu kinh doanh chuyên sâu dựa trên bộ dữ liệu Superstore (2014-2017), bao gồm 9.994 giao dịch và đạt doanh thu 2,3 triệu USD. Kết nối nhiều chỉ số đo lường để định vị các điểm rò rỉ lợi nhuận cốt lõi, đánh giá hành vi vận hành và xây dựng các chiến lược hành động cụ thể cho đội ngũ kinh doanh.

Mục tiêu cốt lõi là chuyển dịch trọng tâm của doanh nghiệp từ việc tăng trưởng quy mô thuần túy ("tăng trưởng bằng mọi giá") sang quản trị lợi nhuận bền vững.

Khung phân tích chi tiết của chuyên viên và toàn bộ báo cáo phân rã được lưu trữ trong tệp Superstore_Analyst.ipynb đi kèm trong kho lưu trữ này.

---

## Chỉ số kinh doanh cốt lõi (Tóm tắt điều hành)
* Tổng doanh thu: $2,297,201 (Giai đoạn 4 năm)
* Tổng lợi nhuận: $286,397
* Lợi nhuận trung bình trên mỗi đơn hàng: $57
* Biên lợi nhuận tổng thể: 12.59% (Mức trung bình của ngành bán lẻ)
* Tỷ lệ khách hàng trung thành: 79.2% (Khách hàng hoạt động từ 3 năm trở lên)

---

## Các khía cạnh phân tích & Thông tin chuyên sâu

### 1. Hiệu suất Doanh thu & Lợi nhuận (Theo Danh mục & Danh mục con)
* **Động lực thúc đẩy lợi nhuận:** Ngành hàng Công nghệ (Technology) dẫn đầu với biên lợi nhuận tốt nhất (17.4% trên doanh thu $836K). Các danh mục con như Máy photocopy (Copiers - 37.2%) và Giấy (Paper - 43.4%) mang lại tỷ lệ lợi nhuận cao nhất.
* **Điểm rò rỉ lợi nhuận:** Ngành hàng Đồ nội thất (Furniture) chiếm 32.3% doanh thu nhưng chỉ đóng góp 6.4% vào tổng lợi nhuận do biên lợi nhuận thấp kỷ lục (2.5%).
* **Cảnh báo nghiêm trọng:** Bàn làm việc (Tables) là danh mục con duy nhất chịu lỗ ròng (-$17,725) dù mang về $207K doanh thu, nguyên nhân chính là do chính sách chiết khấu quá mức.

### 2. "Sát thủ thầm lặng" hủy hoại lợi nhuận (Phân tích tác động chiết khấu)
* **Vùng an toàn:** Các giao dịch áp dụng mức chiết khấu 0% mang lại biên lợi nhuận lý tưởng là 29.5%. Khả năng sinh lời bắt đầu sụt giảm nghiêm trọng ngay khi mức chiết khấu vượt quá 20%.
* **Hủy hoại giá trị:** Có 856 giao dịch áp dụng mức chiết khấu lớn hơn 50%, vận hành với biên lợi nhuận thảm họa -119% (bán ra 1.00 USD thì doanh nghiệp lỗ 1.19 USD), trực tiếp thổi bay $76,559 lợi nhuận.

### 3. Phân tích sâu về Khách hàng & Khu vực
* **Khoảng cách địa lý:** Khu vực Trung tâm (Central) có hiệu suất kém rõ rệt với biên lợi nhuận chỉ đạt 7.9% — thấp hơn 7 điểm phần trăm so với khu vực phía Tây (West). Điều này báo hiệu danh mục sản phẩm chưa tối ưu hoặc việc kiểm soát chiết khấu tại khu vực này bị lỏng lẻo.
* **Sự trung thành đắt đỏ:** Khách hàng đứng đầu về doanh số (Sean Miller, mang lại $25K doanh thu) trên thực tế lại tạo ra khoản lỗ ròng -$1,981 do doanh nghiệp chiết khấu quá tay để giữ chân khách VIP.
* **Phân khúc giá trị cao:** Sự kết hợp giữa Khách hàng cá nhân làm việc tại nhà + Văn phòng phẩm (Home Office + Office Supplies) mang lại biên lợi nhuận tốt nhất toàn hệ thống (20.8%), đây là mục tiêu chính cho các chiến dịch bán hàng combo.

---

## Khuyến nghị chiến lược & Dự báo tác động
Việc triển khai danh sách hành động ưu tiên sau đây có thể mở rộng lợi nhuận hàng năm từ $286K lên $494K (tăng trưởng 73%), hoàn toàn dựa vào việc tối ưu hóa vận hành mà không cần phải tăng doanh số bán ra:

| Mức độ ưu tiên | Hành động chiến lược | Dự báo tác động lợi nhuận / năm | Mức độ khả thi | Lộ trình |
| :--- | :--- | :--- | :--- | :--- |
| NGUY CẤP | Áp đặt mức trần chiết khấu tối đa là 20% cho các đơn hàng tiêu chuẩn. | +$125,000 | Cao | Ngay lập tức |
| NGUY CẤP | Định giá lại hoặc tạm dừng kinh doanh danh mục con Bàn làm việc (Tables). | +$35,000 | Cao | 1-2 Tháng |
| CAO | Kiểm toán lại chính sách giá ở khu vực Trung tâm và phân tích các bất thường trong danh mục sản phẩm. | *Phối hợp liên phòng ban* | Trung bình | 1 Quý |
| TRUNG BÌNH | Đánh giá lại các điều khoản hợp đồng với nhóm khách hàng VIP có khối lượng mua lớn (Ví dụ: Sean Miller) để bảo vệ biên lợi nhuận. | *Giảm thiểu rủi ro* | Trung bình | 1 Quý |
| THẤP | Tập trung ngân sách marketing để đẩy mạnh các gói sản phẩm combo Home Office + Office Supplies. | +$28,000 | Trung bình | 1 Quý |

---

## Công nghệ & Phương pháp đề xuất sử dụng
* SQL (BigQuery): Tổng hợp dữ liệu, sử dụng Window Functions để xếp hạng khu vực, và phân nhóm dữ liệu (binning analysis) cho các dải chiết khấu.
* Python (Pandas & Seaborn): Làm sạch dữ liệu, phát hiện các điểm bất thường (định vị nhóm khách hàng VIP gây lỗ ròng), và trực quan hóa ma trận lợi nhuận.
* Power BI / Tableau: Xây dựng Dashboard tổng quan dành cho cấp điều hành, tập trung theo dõi Biến động biên lợi nhuận (%) thay vì chỉ theo dõi doanh số.

---
Khung phân tích được xây dựng dựa trên Báo cáo Thông tin Chiến lược Chuyên viên Kinh doanh Superstore (FY2014-2017) từ tài liệu Superstore_Analyst.ipynb
