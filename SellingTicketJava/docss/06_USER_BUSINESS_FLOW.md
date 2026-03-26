# 06. User Business Flow

## 1) Đăng ký
- View: `/register`
- Controller: `RegisterServlet`
- Validate: email, password mạnh, phone, gender, date of birth, tuổi tối thiểu 16
- DAO: `UserDAO.registerFull()`
- DB: `Users`

## 2) Đăng nhập
- View: `/login.jsp`
- Controller: `LoginServlet`
- Service/DAO: `UserService -> UserDAO`
- Sau login: session + JWT cookie + redirect theo `returnUrl`

## 3) Xem sự kiện
- `/home`, `/events`, `/event-detail`, `/categories`
- `EventServlet/EventDetailServlet/EventsServlet` gọi `EventService`

## 4) Chọn vé và checkout
- View: `ticket-selection.jsp`, `checkout.jsp`
- Controller: `CheckoutServlet`
- Luồng:
  1. kiểm tra event còn diễn ra
  2. kiểm tra status `approved`
  3. kiểm tra ticket type thuộc event
  4. kiểm tra sale window
  5. kiểm tra số lượng còn lại
  6. tạo order atomic
  7. xử lý SeePay pending flow

## 5) Xem lịch sử mua vé
- `/my-tickets`
- `MyTicketsServlet` chỉ forward JSP, dữ liệu được load bằng AJAX từ `/api/my-tickets` và `/api/my-orders`

## 6) Profile
- `/profile`
- `ProfileServlet`
- Update: full name, phone, gender, birth date

## 7) Support
- `SupportTicketServlet`/`SupportTicketService` và các JSP support
- Tạo ticket, chat support, xem ticket của mình

## Luồng input/output đơn giản
- Input: form + query param
- Output: JSP forward hoặc redirect

## Rủi ro
- Một số kiểm tra quan trọng nằm ở backend, nhưng nếu chỉ nhìn JSP thì dễ tưởng chưa có validate.
- Nếu logic validate ở controller bỏ sót, user có thể gửi request tay.

## Tóm tắt dễ nhớ
User chủ yếu: đăng ký, login, xem event, mua vé, xem vé, cập nhật profile, tạo ticket support.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/07_ADMIN_BUSINESS_FLOW.md`

## Điểm người mới hay nhầm
- Nghĩ `my-tickets.jsp` tự tải data sẵn. Thực tế nó dựa vào AJAX API.
