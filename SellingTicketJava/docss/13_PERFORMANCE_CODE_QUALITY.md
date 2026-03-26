# 13. Performance Code Quality

## Clean code
- Có tách lớp rõ: controller/service/dao/util.
- Có helper dùng chung như `ServletUtil`, `InputValidator`.
- Có chỗ dùng `PageResult` cho pagination.

## Điểm chưa tối ưu
- Một số controller khá dài.
- Một số class vừa làm validate vừa làm orchestration.
- Còn nhiều `new Service()` thủ công.
- Một số luồng đọc DB nhiều lần nếu người dùng vào trang phức tạp.

## Điểm tốt về performance
- Có batch load order items để tránh N+1.
- Có batch load ticket types theo nhiều event.
- Có pool connection trong `DBContext`.
- Có index cho nhiều bảng quan trọng.

## Nơi nên tối ưu thêm
- Dùng pagination cho các list lớn nếu chưa có.
- Chuẩn hóa output encoding trong JSP.
- Giảm số query lặp ở dashboard/summary nếu có thể cache.

## Tóm tắt dễ nhớ
Project ổn ở mức sinh viên và có tư duy performance khá tốt, nhất là batch load và connection pool.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/14_BUG_RISK_AND_IMPROVEMENT_PLAN.md`

## Điểm người mới hay nhầm
- Tưởng code ít dòng là tốt. Ở web app, quan trọng là tách đúng trách nhiệm và tránh query thừa.
