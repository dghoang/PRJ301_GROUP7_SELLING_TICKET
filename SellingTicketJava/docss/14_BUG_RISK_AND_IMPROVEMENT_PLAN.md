# 14. Bug Risk and Improvement Plan

## Top rủi ro quan trọng
1. Broken access control ở các route phụ.
2. XSS nếu output HTML/text không encode.
3. Sai sót ở payment/webhook idempotency.
4. Overselling nếu có đường tạo đơn khác ngoài checkout chuẩn.
5. Role model hơi lệch giữa `customer/organizer/admin/support_agent` và “staff” theo event.
6. Một số luồng chưa thấy quên mật khẩu/OTP/email verify hoàn chỉnh.
7. Hardcoded private keys/default credentials cần quản lý kỹ.
8. Validate backend chưa chắc đồng đều ở mọi endpoint.
9. Một số controller quá dài, khó bảo trì.
10. Tài liệu source thiếu chuẩn hóa, gây khó học cho người mới.

## Ưu tiên sửa trước
- Access control.
- XSS/output encoding.
- Payment/webhook idempotency.
- Đồng bộ role/staff model.
- Audit log cho thao tác nhạy cảm.

## Roadmap gợi ý
1. Chuẩn hóa auth/role.
2. Audit toàn bộ controller.
3. Chuẩn hóa DTO/validator.
4. Tách controller lớn.
5. Thêm test cho checkout, refund, check-in, approve event.

## Tóm tắt dễ nhớ
Sửa trước những chỗ ảnh hưởng tiền và quyền.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/15_LEARNING_PATH_FOR_BEGINNER.md`

## Điểm người mới hay nhầm
- Muốn học hết mọi file một lượt. Nên học theo luồng trước, file sau.
