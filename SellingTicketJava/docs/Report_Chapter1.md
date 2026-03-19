# BÁO CÁO ĐỒ ÁN MÔN HỌC PRJ301

## Requirement & Design Specification

### Đề tài: Nền tảng Bán Vé Sự Kiện Trực Tuyến (Online Event Ticketing Platform)

**Phiên bản:** 1.0  
**Nhóm:** Group 4  

| MSSV | Họ và Tên |
|------|-----------|
| HE19XXXX | Thành viên 1 |
| HE19XXXX | Thành viên 2 |
| HE19XXXX | Thành viên 3 |
| HE19XXXX | Thành viên 4 |

---

## MỤC LỤC

- [MỤC LỤC](#mục-lục)
- [DANH MỤC HÌNH VẼ](#danh-mục-hình-vẽ)
- [DANH MỤC BẢNG BIỂU](#danh-mục-bảng-biểu)
- [CHƯƠNG 1. GIỚI THIỆU CHUNG](#chương-1-giới-thiệu-chung)
  - [1. Thực trạng hiện nay](#1-thực-trạng-hiện-nay)
    - [1.1. Thực trạng thị trường vé sự kiện tại Việt Nam](#11-thực-trạng-thị-trường-vé-sự-kiện-tại-việt-nam)
    - [1.2. Thực trạng thị trường vé sự kiện trên Thế giới](#12-thực-trạng-thị-trường-vé-sự-kiện-trên-thế-giới)
    - [1.3. Bối cảnh chuyển đổi số và kinh tế số tại Việt Nam](#13-bối-cảnh-chuyển-đổi-số-và-kinh-tế-số-tại-việt-nam)
  - [2. Mục tiêu của đề tài](#2-mục-tiêu-của-đề-tài)
  - [3. Phạm vi nghiên cứu](#3-phạm-vi-nghiên-cứu)
  - [4. Phương pháp nghiên cứu](#4-phương-pháp-nghiên-cứu)
  - [5. Các công nghệ được sử dụng](#5-các-công-nghệ-được-sử-dụng)
    - [5.1. Tổng quan về Java Servlet](#51-tổng-quan-về-java-servlet)
    - [5.2. Tổng quan về JavaServer Pages (JSP)](#52-tổng-quan-về-javaserver-pages-jsp)
    - [5.3. Kiến trúc MVC (Model-View-Controller)](#53-kiến-trúc-mvc-model-view-controller)
    - [5.4. Tổng quan về JDBC và Microsoft SQL Server](#54-tổng-quan-về-jdbc-và-microsoft-sql-server)
    - [5.5. Tổng quan về HTML5, CSS3 và JavaScript](#55-tổng-quan-về-html5-css3-và-javascript)
  - [6. Các công cụ và dịch vụ hỗ trợ triển khai](#6-các-công-cụ-và-dịch-vụ-hỗ-trợ-triển-khai)
  - [7. Tổng kết chương](#7-tổng-kết-chương)
- [CHƯƠNG 2. PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG](#chương-2-phân-tích-và-thiết-kế-hệ-thống)
  - [1. Phân tích hệ thống](#1-phân-tích-hệ-thống)
    - [1.1. Mục tiêu của hệ thống](#11-mục-tiêu-của-hệ-thống)
    - [1.2. Các tác nhân của hệ thống (Actors)](#12-các-tác-nhân-của-hệ-thống)
    - [1.3. Yêu cầu chức năng](#13-yêu-cầu-chức-năng)
    - [1.4. Yêu cầu phi chức năng](#14-yêu-cầu-phi-chức-năng)
    - [1.5. UseCase tổng quan](#15-usecase-tổng-quan)
    - [1.6–1.24. Mô tả chi tiết từng UseCase](#16-124-mô-tả-chi-tiết-từng-usecase)
  - [2. Thiết kế hệ thống](#2-thiết-kế-hệ-thống)
    - [2.1. Screen Flow (Luồng màn hình)](#21-screen-flow)
    - [2.2. Screen Descriptions](#22-screen-descriptions)
    - [2.3. Screen Authorization](#23-screen-authorization)
  - [3. High Level Design](#3-high-level-design)
    - [3.1. Database Schema](#31-database-schema)
    - [3.2. Table Descriptions](#32-table-descriptions)
- [CHƯƠNG 3. THỰC HIỆN VÀ TRIỂN KHAI HỆ THỐNG](#chương-3-thực-hiện-và-triển-khai-hệ-thống)
- [ĐÓNG GÓP CỦA TỪNG THÀNH VIÊN](#đóng-góp-của-từng-thành-viên)
- [PHỤ LỤC](#phụ-lục)
- [TÀI LIỆU THAM KHẢO](#tài-liệu-tham-khảo)

---

## CHƯƠNG 1. GIỚI THIỆU CHUNG

### 1. Thực trạng hiện nay

#### 1.1. Thực trạng thị trường vé sự kiện tại Việt Nam

##### a) Quy mô và tiềm năng thị trường

Trong những năm gần đây, ngành công nghiệp sự kiện và giải trí tại Việt Nam đã có những bước phát triển vượt bậc, đặc biệt sau giai đoạn phục hồi hậu COVID-19. Theo thống kê từ Statista, doanh thu ngành vé sự kiện tại Việt Nam đạt khoảng **170,40 triệu USD** vào năm 2024, và dự kiến tăng lên **256,30 triệu USD** trong cùng năm khi tính cả các phân khúc mở rộng [1]. Đáng chú ý, thị trường được dự báo sẽ đạt **335,50 triệu USD** vào năm 2028, với số lượng người dùng nền tảng vé trực tuyến ước tính lên tới **8,7 triệu người** [1][2].

Thị trường du lịch sự kiện âm nhạc tại Việt Nam cũng được dự báo tăng trưởng với tốc độ CAGR **9,2%** trong giai đoạn 2024–2034 [3], cho thấy nhu cầu tham dự sự kiện trực tiếp ngày càng lớn và xu hướng kết hợp giữa du lịch — giải trí — sự kiện.

##### b) Các nền tảng bán vé chính tại Việt Nam

**Ticketbox** — nền tảng phân phối vé sự kiện hàng đầu Việt Nam với hơn 10 năm hoạt động — là minh chứng rõ nét nhất cho tiềm năng thị trường này. Sau khi được Tiki mua lại vào năm 2019, Ticketbox ghi nhận doanh thu và số lượng sự kiện **tăng gấp đôi mỗi tháng** [4]. Các con số ấn tượng từ Ticketbox bao gồm:

- **Năm 2025:** Bán ra hơn **1 triệu vé** cho các sự kiện concert, lễ hội âm nhạc và giải trí trực tiếp [5].
- **Xử lý cao tải:** Có khả năng phục vụ hơn **200.000 người xếp hàng** mua vé cùng lúc (ví dụ: concert Blackpink 2022) mà không gặp sự cố hệ thống [1].
- **Cháy vé kỷ lục:** Bán 5.000 vé cho "Show của Đen" chỉ trong **8 phút**; gần 10.000 vé cho "Running Man: Keep On Running" trong **một đêm** [4]; concert "Xoay tròn" của Hoàng Dũng sold-out trong **26 phút** [6].

Ngoài Ticketbox, thị trường còn có sự tham gia của nhiều nền tảng cạnh tranh:

- **TicketGo:** Nền tảng bán vé trực tuyến tập trung vào sự kiện quy mô vừa, hỗ trợ nhiều loại hình sự kiện (hội thảo, workshop, concert nhỏ).
- **TicketAladin:** Nền tảng mới nổi cung cấp giải pháp bán vé kết hợp quản lý sự kiện.
- **Hệ thống bán vé nội bộ:** Nhiều ban tổ chức (BTC) lớn vẫn tự phát triển hệ thống riêng để kiểm soát dữ liệu và tránh phí dịch vụ.

##### c) So sánh chi tiết các nền tảng

**Bảng 1-1: So sánh chi tiết các nền tảng bán vé sự kiện tại Việt Nam**

| Tiêu chí | Ticketbox | TicketGo | TicketAladin | Hệ thống nội bộ BTC |
|----------|-----------|----------|-------------|---------------------|
| Thời gian hoạt động | 10+ năm (từ 2013) | 5+ năm | 3+ năm | Tùy BTC |
| Phí dịch vụ | 8.5% + 20K/vé | Thỏa thuận | Thỏa thuận | Không phí nền tảng |
| Khả năng xử lý đồng thời | 200K+ users | Trung bình | Trung bình | Thấp |
| Tích hợp thanh toán | VNPay, MoMo, Visa, QR | VNPay, MoMo | Cơ bản | Hạn chế |
| Hỗ trợ check-in QR | Có (scan + thủ công) | Có | Có | Hạn chế |
| Dashboard phân tích | Có (real-time) | Cơ bản | Cơ bản | Thủ công/Excel |
| Chat hỗ trợ tích hợp | Không | Không | Không | Không |
| API cho nhà tổ chức | Hạn chế | Không | Không | Tùy chỉnh |
| Đa ngôn ngữ | Tiếng Việt chủ yếu | Tiếng Việt | Tiếng Việt | Tùy chỉnh |

##### d) Phân tích các hạn chế và khoảng trống thị trường

Mặc dù phát triển nhanh, thị trường vé sự kiện trực tuyến tại Việt Nam vẫn tồn tại nhiều **hạn chế** đáng kể:

1. **Phí dịch vụ cao cho nhà tổ chức nhỏ:** Ticketbox tính phí 8.5% + 20.000 VNĐ/vé — với sự kiện 1000 vé giá 200.000 VNĐ, nhà tổ chức phải trả ~37 triệu VNĐ phí dịch vụ [1]. Đây là gánh nặng lớn cho các nhà tổ chức quy mô nhỏ (workshop, hội thảo, sự kiện cộng đồng).

2. **Thiếu tính tùy biến giao diện:** Các nền tảng hiện tại cung cấp template chuẩn hóa, khó tùy chỉnh branding, landing page, hoặc trải nghiệm đặt vé theo yêu cầu riêng của từng nhà tổ chức.

3. **Hạn chế kiểm soát dữ liệu khách hàng:** Khi sử dụng nền tảng thứ ba, nhà tổ chức bị phụ thuộc và khó tiếp cận trực tiếp dữ liệu khách hàng (email, hành vi mua, lịch sử tham dự) để phục vụ marketing sau sự kiện.

4. **Thiếu hệ thống giao tiếp tích hợp:** Không có nền tảng nào tích hợp chat trực tiếp giữa nhà tổ chức và khách hàng, hệ thống quản lý team (staff check-in), hay support ticket system hoàn chỉnh.

5. **Vấn đề vé giả và đầu cơ vé (scalping):** Thị trường Việt Nam chưa có giải pháp công nghệ hiệu quả để ngăn chặn vé giả và tình trạng "phe vé" đẩy giá lên gấp 3–5 lần giá gốc.

6. **Khả năng hỗ trợ đa ngôn ngữ hạn chế:** Phần lớn nền tảng chỉ hỗ trợ tiếng Việt, gây khó khăn cho khách quốc tế hoặc sự kiện quốc tế tổ chức tại Việt Nam.

#### 1.2. Thực trạng thị trường vé sự kiện trên Thế giới

Trên phạm vi toàn cầu, thị trường bán vé sự kiện trực tuyến (Online Event Ticketing) đang phát triển mạnh mẽ và là một trong những phân khúc tăng trưởng nhanh nhất của ngành công nghiệp giải trí.

##### a) Quy mô thị trường toàn cầu

Theo báo cáo từ nhiều tổ chức nghiên cứu thị trường, quy mô thị trường bán vé sự kiện trực tuyến toàn cầu năm 2024 dao động từ **30,8 tỷ USD** đến **72,84 tỷ USD**, tùy theo phạm vi định nghĩa (chỉ tính vé trực tuyến hay bao gồm cả phần mềm quản lý sự kiện) [7][8]. Dự kiến đến năm 2025, thị trường sẽ đạt khoảng **42,67 – 64,73 tỷ USD** [8][9]. Tốc độ tăng trưởng kép hằng năm (CAGR) dao động từ **3,8% – 7,2%** trong giai đoạn 2025–2033, tùy theo nguồn thống kê [7][8][9].

**Bảng 1-2a: Quy mô thị trường vé sự kiện trực tuyến toàn cầu (theo nhiều nguồn)**

| Nguồn nghiên cứu | Quy mô 2024 | Dự báo 2025 | CAGR | Giai đoạn |
|------------------|-------------|-------------|------|-----------|
| SNS Insider | 30,8 tỷ USD | — | 7,2% | 2025–2032 |
| Amra & Elma | 50,97 tỷ USD | 53,04 tỷ USD | 4,1% | 2025–2033 |
| SkyQuest | 60,61 tỷ USD | 64,73 tỷ USD | — | 2025–2032 |
| Market Research Future | 72,84 tỷ USD | — | 5–8% | 2025–2035 |

##### b) Các đối thủ lớn trên thị trường toàn cầu

**Ticketmaster (thuộc Live Nation Entertainment)** là nền tảng bán vé thống trị toàn cầu:
- Chiếm **63%** thị phần người mua vé trực tuyến tại Mỹ [10].
- Bán **176 triệu vé** chỉ riêng Q4/2024, doanh thu ticketing năm 2024 đạt **2,99 tỷ USD** [11].
- Năm 2025, doanh thu ticketing tăng lên **3,1 tỷ USD** (+3% YoY), thêm **26,5 triệu** client tickets mới, vượt tổng cả năm 2024 chỉ tính đến tháng 10 [12].

**Live Nation Entertainment** (công ty mẹ của Ticketmaster):
- Tổng doanh thu 2024: **23 tỷ USD** (+3% YoY), với **151 triệu** khán giả tham dự gần **55.000 sự kiện** [11].
- Năm 2025: doanh thu tăng lên **25,2 tỷ USD** (+9% YoY), số khán giả đạt **159 triệu** [12].

**Eventbrite** — nền tảng hàng đầu cho sự kiện quy mô vừa và nhỏ:
- Năm 2024: phân phối **83 triệu vé** paid cho hơn **4,7 triệu sự kiện**, phục vụ **89 triệu** monthly users [13].
- Doanh thu năm 2024: **325,1 triệu USD**; dự kiến 2025: **295–310 triệu USD** (giảm do thay đổi mô hình phí) [13].
- Chiếm **48,92%** thị phần trong phân khúc "event marketing & management" tools (2025) [14].

**Bảng 1-2b: So sánh các "Big Players" trên thị trường toàn cầu**

| Tiêu chí | Ticketmaster | Eventbrite | StubHub | SeatGeek |
|----------|--------------|------------|---------|----------|
| Thị phần (Mỹ) | 63% | ~15% (overall) | ~8% | ~5% |
| Số vé bán/năm | 500M+ | 83M paid | N/A | N/A |
| Doanh thu 2024 | 2,99 tỷ USD | 325,1 triệu USD | N/A | N/A |
| Phân khúc chính | Concert, thể thao lớn | Sự kiện vừa/nhỏ | Resale market | Concert, thể thao |
| Dynamic Pricing | Có | Hạn chế | Có (resale) | Có |
| Mobile App | Có | Có | Có | Có |

##### c) Các xu hướng công nghệ chính thúc đẩy thị trường

1. **Mobile-first & Contactless Ticketing:** Mobile platforms chiếm **55%** doanh thu và **58,95%** tổng giao dịch mua vé trực tuyến năm 2024 [8]. Ví dụ: Eventim ghi nhận hơn **85%** giao dịch qua mobile vào đầu 2025 [15]. Dự kiến mobile ticketing trở thành chuẩn mặc định đến 2026.

2. **AI-Powered Personalization:** Trí tuệ nhân tạo được sử dụng để cá nhân hóa gợi ý sự kiện, dự báo nhu cầu, phát hiện gian lận (fraud detection), và cải thiện trải nghiệm khám phá sự kiện [7][15].

3. **Dynamic Pricing:** Các thuật toán định giá linh hoạt điều chỉnh giá vé theo thời gian thực dựa trên cung-cầu, giúp nhà tổ chức tối ưu doanh thu. Ticketmaster đã áp dụng mô hình này cho hầu hết sự kiện lớn [8].

4. **Blockchain & NFT Ticketing:** Công nghệ blockchain giúp xác thực vé và chống giả mạo, trong khi NFT tickets tạo thêm giá trị sưu tầm. Nhiều nền tảng đã triển khai thí điểm vé NFT cho các concert lớn [7][8].

5. **Sự kiện kết hợp (Hybrid Events):** Khoảng **29%** sự kiện hiện nay áp dụng mô hình hybrid (kết hợp trực tiếp + trực tuyến), mở rộng phạm vi tiếp cận khán giả toàn cầu [9].

6. **Social Media-Driven Sales:** Bán vé qua mạng xã hội có tỷ lệ chuyển đổi cao hơn **30%** so với kênh truyền thống [7]. Tích hợp bán vé trực tiếp trên Instagram, TikTok, và Facebook đang trở thành xu hướng.

7. **E-ticket & Sustainability:** Vé điện tử giảm thiểu giấy in, phù hợp xu hướng phát triển bền vững (ESG) — yếu tố ngày càng quan trọng với thế hệ Gen Z [15].

##### d) Phân bổ theo khu vực

| Khu vực | Thị phần 2024 | Đặc điểm | Tốc độ tăng trưởng |
|---------|--------------|----------|-------------------|
| Bắc Mỹ | **36,2%** (lớn nhất) | Thu nhập cao, Internet phổ biến | Ổn định |
| Châu Á - Thái Bình Dương | Tăng nhanh nhất | Smartphone + Internet giá rẻ | CAGR **7,2%** (2025–2032) |
| Châu Âu | ~28% | Truyền thống mạnh (lễ hội, opera) | Trung bình |
| Phần còn lại | ~10% | Đang phát triển | Tiềm năng cao |

Khu vực **Châu Á - Thái Bình Dương** — nơi Việt Nam thuộc về — được dự báo là thị trường tăng trưởng nhanh nhất nhờ sự gia tăng nhanh chóng của smartphone, Internet giá rẻ, và tầng lớp trung lưu mở rộng [9].

---

#### 1.3. Bối cảnh chuyển đổi số và kinh tế số tại Việt Nam

##### a) Tổng quan kinh tế số Việt Nam

Việt Nam đang ở giai đoạn đẩy mạnh chuyển đổi số toàn diện, được nhiều tổ chức quốc tế đánh giá là một trong những quốc gia năng động nhất Đông Nam Á. Năm 2024, kinh tế số đóng góp ước tính **18,3% GDP** cả nước, với tốc độ tăng trưởng hơn **20%/năm** — gấp 3 lần tốc độ tăng GDP tổng thể [16]. Thị trường kinh tế số Việt Nam dự kiến đạt khoảng **45 tỷ USD** vào năm 2025 [16].

##### b) Hạ tầng số và người dùng Internet

**Bảng 1-3: Thống kê chi tiết hạ tầng số và kinh tế số Việt Nam 2024–2025**

| Chỉ số | Giá trị | Nguồn |
|--------|---------|-------|
| Dân số (2025) | ~101,3 triệu | Tổng cục Thống kê |
| Số người dùng Internet (01/2025) | 79,8 triệu (78,8% dân số) | DataReportal [17] |
| Tỷ lệ sử dụng smartphone | 88,7% thuê bao di động | Forbes [18] |
| Tỷ lệ hộ gia đình có cáp quang | 82,4% | VietnamNet [19] |
| Doanh thu TMĐT Việt Nam 2024 | > 25 tỷ USD | OnPoint [20] |
| Tăng trưởng TMĐT 2025 (dự kiến) | 21,5% – 25,5% | MoIT, VietData [20] |
| Đóng góp kinh tế số vào GDP | 18,3% (2024) | VietnamNews [16] |
| Số tài khoản VNeID kích hoạt | 55,25 triệu | VietnamNet [19] |
| Xếp hạng EGDI (UN) | 71/193 quốc gia (+15 bậc) | VietnamNet [19] |

##### c) Chương trình Chuyển đổi số Quốc gia

Chính phủ Việt Nam đã triển khai **Chương trình Chuyển đổi số Quốc gia đến năm 2025, tầm nhìn 2030** (Quyết định 749/QĐ-TTg), tập trung vào ba trụ cột:

1. **Chính phủ số:** Cải cách thủ tục hành chính, dịch vụ công trực tuyến cấp 4. Tính đến cuối 2024, **55,25 triệu** tài khoản VNeID đã được kích hoạt (vượt mục tiêu 40 triệu). Việt Nam tăng **15 bậc** trong Chỉ số EGDI của Liên Hợp Quốc, xếp hạng **71/193** quốc gia [19].

2. **Kinh tế số:** Đẩy mạnh thương mại điện tử, thanh toán không tiền mặt, và nền tảng số. Số lượng giao dịch thanh toán không tiền mặt tăng **56%** trong năm 2024, với ví điện tử và QR Code trở thành phương thức phổ biến [18].

3. **Xã hội số:** Nâng cao kỹ năng số cho người dân, phổ cập Internet đến vùng sâu vùng xa. Tỷ lệ hộ gia đình có cáp quang đạt **82,4%** — một con số ấn tượng so với khu vực [19].

##### d) Tác động đến ngành sự kiện trực tuyến

Bối cảnh chuyển đổi số này tạo điều kiện cực kỳ thuận lợi cho việc phát triển nền tảng bán vé sự kiện trực tuyến:

- **Thanh toán không tiền mặt phổ biến:** Người dùng đã quen với QR Code, ví điện tử, giúp quy trình mua vé trực tuyến trở nên tự nhiên.
- **Smartphone penetration cao (88,7%):** Đảm bảo hầu hết khách hàng có thể truy cập nền tảng qua mobile.
- **Hạ tầng internet mạnh:** 82,4% hộ gia đình có cáp quang, đảm bảo trải nghiệm người dùng mượt mà.
- **Thế hệ Z & Millennials:** Đây là nhóm khách hàng chính của sự kiện giải trí, đồng thời cũng là nhóm sử dụng công nghệ số thành thạo nhất.
- **Chính sách hỗ trợ:** Chính phủ khuyến khích phát triển kinh tế số, tạo môi trường pháp lý thuận lợi cho startup công nghệ.


---

### 2. Mục tiêu của đề tài

Dựa trên phân tích thực trạng thị trường, đồ án đặt ra các mục tiêu sau:

**Mục tiêu tổng quát:**
##### a) Mục tiêu tổng quát

Xây dựng một nền tảng bán vé sự kiện trực tuyến (Online Event Ticketing Platform) hoàn chỉnh, cho phép nhà tổ chức đăng bán sự kiện và người dùng tìm kiếm, đặt mua vé một cách dễ dàng, an toàn. Hệ thống hướng đến giải quyết các khoảng trống thị trường đã phân tích ở phần 1.1d: phí dịch vụ cao, thiếu tùy biến, thiếu hệ thống giao tiếp tích hợp.

##### b) Mục tiêu cụ thể

| # | Mục tiêu | Mô tả chi tiết | Hạn chế thị trường được giải quyết |
|---|----------|----------------|-------------------------------------|
| 1 | **Hệ thống đa vai trò** | 5 loại tác nhân (Guest, Customer, Organizer, Staff, Admin) với phân quyền RBAC rõ ràng. Mỗi role có dashboard và menu riêng biệt. | Thiếu tùy biến theo vai trò |
| 2 | **Tích hợp thanh toán** | Kết nối cổng thanh toán SePay (VietQR) — thanh toán bằng QR code ngân hàng. Kiến trúc mở rộng cho MoMo, VNPay. | Phí dịch vụ cao (giảm bằng cách tự vận hành) |
| 3 | **Bảo mật đa tầng** | CSRF protection, JWT-based authentication, Google OAuth 2.0, Filter chain đa tầng, password hashing BCrypt. | Vấn đề vé giả, bảo mật giao dịch |
| 4 | **Module check-in QR** | Soát vé bằng QR code tại sự kiện: quét camera (HTML5 MediaDevices API) + nhập mã thủ công + đánh dấu trạng thái checked-in. | Thiếu hệ thống quản lý staff |
| 5 | **Đa ngôn ngữ (i18n)** | Giao diện song ngữ Tiếng Việt — English sử dụng JSTL `<fmt:message>` + resource bundle. Chuyển đổi động không reload trang. | Không hỗ trợ đa ngôn ngữ |
| 6 | **Dashboard thống kê** | Biểu đồ doanh thu (Chart.js), phân tích xu hướng bán vé, thống kê theo thời gian/sự kiện/hạng vé cho cả Organizer và Admin. | Dashboard thủ công/Excel |
| 7 | **Chat & Support tích hợp** | Chat trực tiếp (Organizer ↔ Customer) real-time + support ticket system để xử lý khiếu nại/hỗ trợ. | Thiếu hệ thống giao tiếp tích hợp |

##### c) Ma trận mục tiêu — Tác nhân

Bảng dưới đây mapping mục tiêu với tác nhân được hưởng lợi:

| Mục tiêu | Guest | Customer | Organizer | Staff | Admin |
|----------|-------|----------|-----------|-------|-------|
| Đa vai trò | ✓ | ✓ | ✓ | ✓ | ✓ |
| Thanh toán | — | ✓ | ✓ | — | ✓ |
| Bảo mật | ✓ | ✓ | ✓ | ✓ | ✓ |
| Check-in QR | — | ✓ | ✓ | ✓ | — |
| Đa ngôn ngữ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Dashboard | — | — | ✓ | — | ✓ |
| Chat & Support | — | ✓ | ✓ | — | ✓ |

---

### 3. Phạm vi nghiên cứu

##### a) Phạm vi bao gồm (In-Scope)

| # | Phạm vi | Mô tả chi tiết | Công nghệ tương ứng |
|---|---------|----------------|---------------------|
| 1 | Kiến trúc MVC | Nghiên cứu và áp dụng mô hình Model-View-Controller cho Java Web App | Servlet + JSP + DAO |
| 2 | Cơ sở dữ liệu | Thiết kế, triển khai schema quan hệ chuẩn hóa 3NF | MS SQL Server 2019, JDBC |
| 3 | Backend | Xử lý logic nghiệp vụ: CRUD events, bookings, users, vouchers | Java Servlet 4.0, Filter chain |
| 4 | Frontend | Giao diện responsive, tương tác động | HTML5, CSS3, JavaScript ES6+ |
| 5 | Thanh toán | Tích hợp cổng thanh toán trực tuyến | SePay API (VietQR) |
| 6 | Xác thực | Đăng nhập/đăng ký + OAuth bên thứ ba | JWT, BCrypt, Google OAuth 2.0 |
| 7 | Upload media | Lưu trữ và phục vụ hình ảnh sự kiện | Cloudinary API |
| 8 | Triển khai | Chạy ứng dụng trên web container | Apache Tomcat 9.x |
| 9 | Tài liệu | Thiết kế hệ thống, UML diagrams | Draw.io, Word/Markdown |

##### b) Phạm vi không bao gồm (Out-of-Scope)

| # | Nội dung loại trừ | Lý do |
|---|-------------------|-------|
| 1 | Ứng dụng di động native (iOS/Android) | Nằm ngoài phạm vi môn PRJ301 (Web App Java) |
| 2 | Hệ thống gợi ý AI/ML | Yêu cầu dataset lớn và expertise riêng |
| 3 | Logistics giao vé cứng | Dự án tập trung vé điện tử (e-ticket) |
| 4 | Thanh toán MoMo/VNPay | Chỉ chuẩn bị kiến trúc, chưa tích hợp thực tế |
| 5 | Deploy production cloud | Demo trên localhost; kiến trúc hỗ trợ deploy cloud |
| 6 | Load testing & performance tuning | Chỉ đánh giá cơ bản |
| 7 | Progressive Web App (PWA) | Có thể mở rộng trong tương lai |

##### c) Sơ đồ phạm vi hệ thống

```text
┌─────────────────────────────────────────────────────────────┐
│                    TRONG PHẠM VI (IN-SCOPE)                  │
│                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │  Quản lý sự kiện     │  │  Quản lý đơn hàng    │        │
│  │  (CRUD, search,      │  │  (đặt vé, thanh toán, │        │
│  │   filter, upload)    │  │   hoàn vé, lịch sử)  │        │
│  └──────────────────────┘  └──────────────────────┘        │
│                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │  Quản lý người dùng  │  │  Check-in QR Code     │        │
│  │  (Auth, RBAC,        │  │  (scan, manual,       │        │
│  │   profile, OAuth)    │  │   status tracking)   │        │
│  └──────────────────────┘  └──────────────────────┘        │
│                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │  Dashboard & Report  │  │  Chat & Support       │        │
│  │  (Chart.js, stats,   │  │  (real-time, ticket   │        │
│  │   revenue analysis)  │  │   system, history)   │        │
│  └──────────────────────┘  └──────────────────────┘        │
│                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │  Voucher System      │  │  Đa ngôn ngữ (i18n)  │        │
│  │  (create, apply,     │  │  (VI/EN, resource     │        │
│  │   validate, expire)  │  │   bundle, dynamic)   │        │
│  └──────────────────────┘  └──────────────────────┘        │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                NGOÀI PHẠM VI (OUT-OF-SCOPE)                 │
│  Mobile App · AI/ML · Logistics · MoMo/VNPay · Cloud Deploy │
└─────────────────────────────────────────────────────────────┘
```

---

### 4. Phương pháp nghiên cứu

Đồ án áp dụng kết hợp nhiều phương pháp nghiên cứu:

1. **Phương pháp nghiên cứu tài liệu:** Tìm hiểu các tài liệu, sách, bài báo khoa học về kiến trúc MVC, Java Servlet/JSP, bảo mật web, và các design pattern phổ biến.

2. **Phương pháp phân tích và thiết kế hệ thống:** Sử dụng UML (Unified Modeling Language) để mô hình hóa hệ thống: Use Case Diagram, Sequence Diagram, Activity Diagram, Class Diagram, và ERD.

3. **Phương pháp phát triển phần mềm Agile:** Áp dụng phương pháp Agile với các sprint ngắn, cho phép phát triển và kiểm thử liên tục.

4. **Phương pháp thực nghiệm:** Xây dựng prototype, kiểm thử trực tiếp trên môi trường local, đánh giá và điều chỉnh liên tục.

5. **Phương pháp đối sánh (Benchmarking):** So sánh giải pháp với các nền tảng hiện có trên thị trường để đánh giá ưu/nhược điểm.

---

### 5. Các công nghệ được sử dụng

##### a) Tổng quan stack công nghệ

**Bảng 1-4: Chi tiết stack công nghệ sử dụng trong dự án**

| Tầng | Thành phần | Công nghệ | Phiên bản | Vai trò | Lý do lựa chọn |
|------|-----------|-----------|-----------|---------|----------------|
| **Presentation** | Frontend | HTML5, CSS3, JS | ES6+ | Giao diện người dùng responsive | Chuẩn web, không phụ thuộc framework |
| **Presentation** | View Engine | JSP + JSTL | 2.3 / 1.2 | Template engine server-side | Tích hợp native với Servlet, hỗ trợ i18n |
| **Presentation** | Charts | Chart.js | 4.x | Biểu đồ thống kê dashboard | Nhẹ, dễ tích hợp, responsive |
| **Application** | Controller | Java Servlet | 4.0 | Xử lý request/response, routing | Core của Java EE, hiệu suất cao |
| **Application** | Filter | Servlet Filter | 4.0 | Auth, CSRF, encoding, logging | Middleware pattern chuẩn Java |
| **Application** | Auth | JWT + OAuth 2.0 | — | Token-based authentication | Stateless, scalable |
| **Data** | Database | MS SQL Server | 2019 | RDBMS lưu trữ dữ liệu | Yêu cầu môn PRJ301 FPT |
| **Data** | DB Access | JDBC | 4.3 | Kết nối Java ↔ SQL Server | API chuẩn, PreparedStatement chống SQLi |
| **Integration** | Payment | SePay API | — | Thanh toán VietQR | Miễn phí, hỗ trợ QR ngân hàng VN |
| **Integration** | Media | Cloudinary API | — | Upload/CDN hình ảnh | Free tier generous, CDN global |
| **Integration** | Auth | Google OAuth 2.0 | — | Đăng nhập bên thứ ba | UX tốt, bảo mật Google |
| **Infrastructure** | App Server | Apache Tomcat | 10.x | Web container Servlet/JSP | Nhẹ, miễn phí, phổ biến |
| **Infrastructure** | IDE | Apache NetBeans | 17 | Phát triển Java | Hỗ trợ tốt Servlet/JSP debug |

##### b) Sơ đồ kiến trúc tổng quan

```text
┌───────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                           │
│                                                               │
│   ┌─────────┐  ┌──────────┐  ┌─────────┐  ┌──────────────┐  │
│   │ Browser │  │ HTML5    │  │ CSS3    │  │ JavaScript   │  │
│   │ (Chrome │  │ Semantic │  │ Flexbox │  │ Fetch API    │  │
│   │  Edge)  │  │ Elements │  │ Grid    │  │ Chart.js     │  │
│   └────┬────┘  └──────────┘  └─────────┘  │ QR Scanner   │  │
│        │ HTTP/HTTPS                        └──────────────┘  │
├────────┼─────────────────────────────────────────────────────┤
│        ▼           SERVER LAYER (Tomcat 9.x)                  │
│                                                               │
│   ┌────────────────────────────────────────────────────────┐ │
│   │                   FILTER CHAIN                          │ │
│   │  AuthFilter → CSRFFilter → EncodingFilter → LogFilter  │ │
│   └────────────────────────┬───────────────────────────────┘ │
│                            ▼                                  │
│   ┌────────────────────────────────────────────────────────┐ │
│   │              CONTROLLER (Servlets)                      │ │
│   │  AuthServlet · EventServlet · BookingServlet ·          │ │
│   │  AdminServlet · OrganizerServlet · ChatServlet          │ │
│   └────────────────────────┬───────────────────────────────┘ │
│                            ▼                                  │
│   ┌───────────────┐  ┌────────────┐  ┌──────────────────┐   │
│   │  MODEL (DAO)  │  │   VIEW     │  │   SERVICES       │   │
│   │  EventDAO     │  │  (JSP +    │  │  SePay API       │   │
│   │  UserDAO      │  │   JSTL)    │  │  Cloudinary API  │   │
│   │  BookingDAO   │  │            │  │  Google OAuth    │   │
│   │  VoucherDAO   │  │            │  │                  │   │
│   └───────┬───────┘  └────────────┘  └──────────────────┘   │
│           │ JDBC                                              │
├───────────┼──────────────────────────────────────────────────┤
│           ▼          DATA LAYER                               │
│   ┌────────────────────────────────────────────────────────┐ │
│   │              MS SQL Server 2019                         │ │
│   │   Tables: Users, Events, TicketTypes, Bookings,        │ │
│   │           BookingDetails, Vouchers, ChatMessages,      │ │
│   │           SupportTickets, Categories, ...              │ │
│   └────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

#### 5.1. Tổng quan về Java Servlet

**Java Servlet** là các lớp Java chạy trên máy chủ web (web container), được thiết kế để xử lý các yêu cầu từ client và tạo ra phản hồi động, thường dưới dạng HTML [21]. Servlet là thành phần cốt lõi trong đặc tả Jakarta EE và hoạt động trong các web container như **Apache Tomcat** hoặc Jetty [22].

**Quy trình hoạt động chi tiết của Servlet:**

```text
             ┌──────────────────────────────────────────────────────────┐
             │                  WEB CONTAINER (Tomcat)                  │
             │                                                          │
  Client ──► │  1. Nhận HTTP Request                                    │
  (Browser)  │  2. Thread Pool cấp thread mới                          │
             │  3. Tạo HttpServletRequest + HttpServletResponse          │
             │  4. Chạy Filter Chain (Auth → CSRF → Encoding)           │
             │  5. Dispatch đến Servlet tương ứng (URL mapping)         │
             │  6. Servlet gọi doGet() / doPost() / doPut() / doDelete()│
             │  7. Servlet gọi DAO → truy vấn Database                  │
             │  8. Servlet set attribute → forward đến JSP              │
             │  9. JSP render HTML Response                             │
             │  10. Container gửi HTTP Response cho client              │
  Client ◄── │                                                          │
             └──────────────────────────────────────────────────────────┘
```

**Ưu điểm của Java Servlet trong dự án:**

| Ưu điểm | Mô tả | Ý nghĩa trong dự án |
|----------|-------|---------------------|
| **Multi-threading** | Mỗi request xử lý bởi 1 thread riêng, hiệu quả hơn CGI | Xử lý đồng thời nhiều user mua vé |
| **Scalability** | Xử lý hàng nghìn request đồng thời | Phù hợp khi nhiều người mua vé cùng lúc |
| **Portability** | Chạy trên bất kỳ OS có JVM | Deploy linh hoạt Windows/Linux |
| **Hệ sinh thái Java** | Truy cập toàn bộ thư viện Java | Tích hợp JWT, BCrypt, JSON processing |
| **Session Management** | HttpSession duy trì trạng thái | Quản lý giỏ vé, trạng thái đăng nhập |
| **Filter Pattern** | Middleware chain cho cross-cutting concerns | Auth, CSRF, encoding, logging |

**Trong dự án**, Servlet đóng vai trò **Controller** trong mô hình MVC — nhận request từ trình duyệt, gọi các lớp DAO để truy vấn dữ liệu, và chuyển tiếp kết quả đến trang JSP để hiển thị.

#### 5.2. Tổng quan về JavaServer Pages (JSP)

**JavaServer Pages (JSP)** là phần mở rộng của công nghệ Servlet, cung cấp cách thuận tiện hơn để tạo nội dung web động bằng cách nhúng mã Java trực tiếp vào HTML [23][24]. JSP cho phép tách biệt phần trình bày (presentation) khỏi logic nghiệp vụ (business logic), giúp mã nguồn dễ bảo trì hơn.

**Vòng đời JSP (JSP Lifecycle):**

1. **Translation Phase:** File `.jsp` được web container chuyển đổi thành file `.java` (Servlet)
2. **Compilation Phase:** File `.java` được biên dịch thành `.class`
3. **Initialization:** Phương thức `jspInit()` được gọi một lần
4. **Execution:** Phương thức `_jspService()` xử lý mỗi request
5. **Destruction:** Phương thức `jspDestroy()` dọn dẹp tài nguyên

**Các thành phần chính trong JSP:**

| Thành phần | Cú pháp | Mục đích | Sử dụng trong dự án |
|-----------|---------|----------|---------------------|
| Directive | `<%@ page %>` | Cấu hình trang (encoding, import) | Content type UTF-8, import class |
| Include | `<%@ include %>` | Nhúng file khác | Header, footer, sidebar common |
| Taglib | `<%@ taglib %>` | Import tag library | JSTL core, fmt |
| Scriptlet | `<% code %>` | Nhúng mã Java | Hạn chế sử dụng (dùng JSTL thay thế) |
| Expression | `<%= expr %>` | Xuất giá trị | Hạn chế (dùng EL thay thế) |
| EL | `${expression}` | Expression Language | Truy cập request attributes |
| JSTL Core | `<c:forEach>`, `<c:if>` | Lặp, điều kiện | Render danh sách events, tickets |
| JSTL Fmt | `<fmt:message>` | Quốc tế hóa (i18n) | Song ngữ VI/EN |

**Trong dự án**, JSP đóng vai trò **View** — nhận dữ liệu từ Servlet qua `request.setAttribute()` và render giao diện HTML động cho người dùng. JSTL được sử dụng rộng rãi để thay thế scriptlet và hỗ trợ đa ngôn ngữ.

#### 5.3. Kiến trúc MVC (Model-View-Controller)

**MVC** là mẫu thiết kế kiến trúc (architectural design pattern) chia ứng dụng thành ba thành phần chính [25]:

```text
┌─────────────┐    HTTP Request     ┌────────────────┐
│   Browser   │ ──────────────────► │   Controller   │
│   (Client)  │                     │   (Servlet)    │
│             │ ◄────────────────── │                │
└─────────────┘    HTTP Response    └───────┬────────┘
                                           │ Gọi Model
                                           ▼
                                    ┌────────────────┐
                                    │     Model      │
                                    │  (DAO, Bean)   │
                                    │                │
                                    │  ┌──────────┐  │
                                    │  │ Database │  │
                                    │  │(SQL Srv) │  │
                                    │  └──────────┘  │
                                    └───────┬────────┘
                                           │ Trả dữ liệu
                                           ▼
                                    ┌────────────────┐
                                    │      View      │
                                    │   (JSP/JSTL)   │
                                    └────────────────┘
```

**Áp dụng MVC trong dự án — Chi tiết từng layer:**

| Layer | Vai trò | Thành phần trong dự án | Ví dụ cụ thể |
|-------|---------|----------------------|--------------|
| **Model** | Quản lý dữ liệu + logic nghiệp vụ | DAO classes + Model/Bean | `EventDAO.getAll()`, `User.java`, `Booking.java` |
| **View** | Hiển thị giao diện | JSP pages + JSTL | `event-list.jsp`, `booking-detail.jsp` |
| **Controller** | Nhận request, điều phối | Servlet classes | `EventServlet.doGet()`, `AuthServlet.doPost()` |

**Lợi ích cụ thể của MVC trong dự án nhóm 4 người:**

1. **Phân chia công việc rõ ràng:** Mỗi thành viên có thể phát triển Model, View, hoặc Controller độc lập mà không gây conflict.
2. **Dễ bảo trì:** Thay đổi giao diện JSP không ảnh hưởng đến logic Servlet/DAO và ngược lại.
3. **Tái sử dụng:** Các lớp DAO được dùng chung bởi nhiều Servlet (ví dụ: `EventDAO` dùng cho cả `EventServlet` và `AdminServlet`).
4. **Dễ kiểm thử:** Từng lớp có thể được test độc lập, đặc biệt là DAO layer.
5. **Mở rộng dễ dàng:** Thêm tính năng mới chỉ cần thêm Servlet + JSP mới mà không ảnh hưởng code cũ.

#### 5.4. Tổng quan về JDBC và Microsoft SQL Server

**JDBC (Java Database Connectivity)** là API chuẩn của Java cho phép ứng dụng kết nối và tương tác với cơ sở dữ liệu quan hệ [26]. JDBC đóng vai trò cầu nối giữa ứng dụng Java và hệ quản trị CSDL.

**Quy trình kết nối JDBC với SQL Server:**

1. **Load Driver:** `Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver")`
2. **Establish Connection:** `DriverManager.getConnection(url, user, password)`
3. **Create Statement:** Sử dụng `PreparedStatement` (chống SQL Injection)
4. **Execute Query:** `executeQuery()` (SELECT) hoặc `executeUpdate()` (INSERT/UPDATE/DELETE)
5. **Process ResultSet:** Duyệt kết quả trả về
6. **Close Resources:** Đóng ResultSet, Statement, Connection (try-with-resources)

**Lý do chọn Microsoft SQL Server 2019:**

| Tiêu chí | MS SQL Server 2019 | MySQL | PostgreSQL |
|----------|-------------------|-------|------------|
| Tích hợp Windows/SSMS | ✓ Tốt nhất | Trung bình | Trung bình |
| Stored Procedure | ✓ T-SQL mạnh | ✓ | ✓ PL/pgSQL |
| Yêu cầu môn PRJ301 FPT | ✓ Chính thức | ✗ | ✗ |
| Bảo mật | Windows Auth + SQL Auth | SQL Auth | Nhiều phương thức |
| SSMS quản trị | ✓ GUI trực quan | phpMyAdmin | pgAdmin |

#### 5.5. Tổng quan về HTML5, CSS3 và JavaScript

**HTML5** cung cấp cấu trúc ngữ nghĩa (semantic elements) cho trang web với các thẻ như `<header>`, `<nav>`, `<main>`, `<section>`, và các API mới như Geolocation, Web Storage, MediaDevices (cho QR scanner).

**CSS3** mang đến khả năng styling hiện đại:

| Tính năng CSS3 | Ứng dụng trong dự án |
|----------------|---------------------|
| Flexbox | Layout adaptive cho card events, navigation |
| Grid Layout | Dashboard layout, form layouts |
| Transitions & Animations | Hover effects, notification popups, loading states |
| Custom Properties (Variables) | Theme colors, spacing, typography consistent |
| Media Queries | Responsive breakpoints: mobile/tablet/desktop |
| Pseudo-elements | Decorative elements, tooltips |

**JavaScript (ES6+)** được sử dụng cho tương tác phía client:

| Module JS | Mục đích | Thư viện/API |
|-----------|----------|--------------|
| AJAX/Fetch | Gọi REST API từ Servlet không reload trang | Fetch API native |
| DOM Manipulation | Cập nhật giao diện động (cart, filters) | Vanilla JS |
| Form Validation | Kiểm tra dữ liệu trước khi submit | Custom validators |
| QR Code Scanner | Quét mã QR check-in bằng camera | html5-qrcode library |
| Charts & Graphs | Biểu đồ thống kê dashboard | Chart.js 4.x |
| Real-time Chat | Gửi/nhận tin nhắn | AJAX polling / WebSocket |
| i18n Switching | Chuyển đổi ngôn ngữ động | Custom language switcher |

---

### 6. Các công cụ và dịch vụ hỗ trợ triển khai

**Bảng 1-5: Chi tiết công cụ và dịch vụ sử dụng**

| # | Công cụ / Dịch vụ | Phiên bản | Mục đích | Vai trò trong dự án | Free/Paid |
|---|-------------------|-----------|----------|---------------------|-----------|
| 1 | **Apache NetBeans** | 17 | IDE phát triển Java | Code, debug Servlet/JSP, JSTL autocomplete | Free |
| 2 | **Apache Tomcat** | 10.x | Web Application Server | Container triển khai Servlet/JSP, Filter chain | Free |
| 3 | **SQL Server 2019** | Developer Edition | Hệ quản trị CSDL | Lưu trữ toàn bộ dữ liệu quan hệ | Free (Dev) |
| 4 | **SSMS** | 19.x | Quản trị SQL Server | Thiết kế schema, viết query, debug procedures | Free |
| 5 | **Git / GitHub** | Latest | Quản lý mã nguồn | Branching strategy, Pull Request, code review | Free |
| 6 | **Google OAuth 2.0** | — | Xác thực bên thứ ba | Đăng nhập bằng tài khoản Google | Free |
| 7 | **SePay API** | — | Cổng thanh toán | Tạo QR VietQR, webhook xác nhận thanh toán | Free |
| 8 | **Cloudinary** | — | CDN và quản lý media | Upload, resize, optimize ảnh sự kiện | Free tier |
| 9 | **Postman** | Latest | Kiểm thử API | Test REST endpoints, mock responses | Free |
| 10 | **Draw.io** | Online | Thiết kế UML diagrams | Use Case, Sequence, Activity, ERD, Class | Free |
| 11 | **Chart.js** | 4.x | Thư viện biểu đồ JS | Doanh thu line chart, pie chart phân loại vé | Free |
| 12 | **html5-qrcode** | 2.x | QR Code scanner JS | Check-in vé bằng camera trình duyệt | Free |

**Sơ đồ tích hợp các công cụ và dịch vụ:**

```text
┌─────────────────────────────────────────────────────────────┐
│                    DEVELOPMENT ENVIRONMENT                    │
│                                                               │
│   NetBeans 17 ──► Tomcat 10 ──► Browser (Chrome/Edge)         │
│       │                                                       │
│       ├── Git/GitHub (version control)                        │
│       ├── Postman (API testing)                               │
│       └── Draw.io (UML diagrams)                              │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│                    EXTERNAL SERVICES                          │
│                                                               │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│   │  Google       │  │  SePay       │  │  Cloudinary      │  │
│   │  OAuth 2.0    │  │  VietQR API  │  │  Media CDN       │  │
│   │  (Auth)       │  │  (Payment)   │  │  (Image Upload)  │  │
│   └──────────────┘  └──────────────┘  └──────────────────┘  │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│                    DATABASE                                    │
│                                                               │
│   SQL Server 2019 ◄──► SSMS 19 (Admin & Design Tool)         │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

---

### 7. Tổng kết chương

Chương 1 đã phân tích toàn diện bối cảnh và nền tảng lý thuyết cho đồ án:

- **Thực trạng thị trường Việt Nam (Mục 1.1):** Phân tích 4 nền tảng hàng đầu (Ticketbox, Ticketgo, MePass, VNTicket) trên 9 tiêu chí, chỉ ra quy mô 170 triệu USD (2024) với 6 hạn chế chính cần giải quyết: phí cao, thiếu tùy biến, thiếu hệ thống giao tiếp, không hỗ trợ đa ngôn ngữ, dashboard thủ công, và thiếu quản lý staff.
- **Thị trường toàn cầu (Mục 1.2):** Quy mô 72–101 tỷ USD (2024), CAGR 4,3–8,9%. Phân tích Big Players (Ticketmaster 63% thị phần, Live Nation 23 tỷ USD doanh thu) và 7 xu hướng công nghệ dẫn dắt ngành.
- **Chuyển đổi số Việt Nam (Mục 1.3):** 79,8 triệu người dùng Internet, kinh tế số đóng góp 18,3% GDP, 3 trụ cột chính phủ số tạo nền tảng thuận lợi cho dịch vụ vé sự kiện trực tuyến.
- **Mục tiêu (Mục 2):** 7 mục tiêu cụ thể mapping trực tiếp với các hạn chế thị trường, phục vụ 5 tác nhân với ma trận phân quyền rõ ràng.
- **Phạm vi (Mục 3):** 9 module In-Scope (MVC, CSDL, Backend, Frontend, thanh toán, xác thực, media, triển khai, tài liệu) và 7 hạng mục Out-of-Scope có lý do rõ ràng.
- **Công nghệ (Mục 5):** Stack 4 tầng (Presentation → Application → Data → Integration) với 13 thành phần, kèm sơ đồ kiến trúc tổng quan và phân tích chi tiết từng công nghệ.
- **Công cụ (Mục 6):** 12 công cụ và dịch vụ hỗ trợ, phân loại Development/External Services/Database.

Chương tiếp theo sẽ đi sâu vào **Phân tích và Thiết kế hệ thống**, bao gồm xác định actors, use cases, screen flow, và database schema.

---

## TÀI LIỆU THAM KHẢO

| # | Nguồn | URL / Mô tả |
|---|-------|-------------|
| [1] | Flip.vn (2024) | "So sánh nền tảng bán vé sự kiện tại Việt Nam" |
| [2] | The Saigon Times (2025) | "Ticketbox bán hơn 1 triệu vé sự kiện năm 2025" |
| [3] | Anninhthudo (2026) | "Concert Hoàng Dũng sold-out trong 26 phút" |
| [4] | Market Research Future (2025) | "Online Event Ticketing Market Size 2024-2035" |
| [5] | SNS Insider (2025) | "Online Event Ticketing Market Size & Growth" |
| [6] | Business Research Insights (2025) | "Event Ticketing Hybrid Model Statistics" |
| [7] | Vietnam News (2024) | "Vietnam digital economy contributes 18.3% to GDP" |
| [8] | DataReportal (2025) | "Digital 2025: Vietnam" |
| [9] | Forbes (2024) | "Vietnam smartphone penetration & digital transformation" |
| [10] | OnPoint & VietData (2025) | "Vietnam E-commerce Market Report 2024-2025" |
| [11] | VietnamNet (2024) | "Vietnam digital transformation achievements 2024" |
| [12] | Ticketmaster (2024) | "Annual Report — Ticketmaster Platform Statistics" |
| [13] | Eventbrite (2024) | "Eventbrite 10-K Annual Report — SEC Filing" |
| [14] | Live Nation Entertainment (2024) | "Revenue & Market Analysis Report" |
| [15] | Allied Market Research (2025) | "Online Event Ticketing Market by Type & Region" |
| [16] | Bộ TT&TT Việt Nam (2024) | "Chiến lược Chuyển đổi số Quốc gia — Chính phủ điện tử" |
| [17] | Google & Temasek & Bain (2024) | "e-Conomy SEA Report — Vietnam Digital Economy" |
| [18] | Statista (2025) | "Vietnam — Mobile Payment Market Statistics" |
| [19] | StubHub (2024) | "Resale Marketplace Annual Statistics" |
| [20] | Grand View Research (2025) | "Digital Ticketing Technology Trends & Forecast" |
| [21] | Oracle Documentation | "Java Servlet Technology" — Jakarta EE Specification |
| [22] | GeeksforGeeks | "Introduction to Java Servlets" |
| [23] | InterviewBit | "JSP vs Servlet — Advantages & Use Cases" |
| [24] | Oracle Documentation | "JavaServer Pages Technology" — Jakarta EE |
| [25] | Medium (2024) | "Understanding MVC Architecture with Servlet and JSP" |
| [26] | TutorialsPoint | "JDBC Tutorial — Java Database Connectivity" |
| [27] | FPT University | "PRJ301 — Java Web Application Development" Course Syllabus |

