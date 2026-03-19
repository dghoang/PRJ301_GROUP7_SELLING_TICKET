# Documentation Index

## Muc luc

### Phan tich Code (Hoc + Bao ve)
- architecture.md
  - Kien truc MVC 3 tang, so do package, design pattern, cau hinh ky thuat.

- business-flows.md
  - 15 luong nghiep vu chi tiet: dang nhap, checkout atomic, payment QR, webhook IPN,
    phat ve JWT, check-in, voucher, chat, support ticket, admin approval...
    Co giai thich ly do thiet ke + cau hoi hoi dong thuong gap.

- database-schema.md
  - Mo ta 21 bang, ERD, cac index quan trong, quan he FK, ghi chu thiet ke.

### Xac thuc & Bao mat
- auth/auth-docs.md
  - Tai lieu xac thuc, phan quyen, JWT, session restore, logout, OAuth flow.
  - Rate limiting, BCrypt, cookie security, security headers.

- security/protected-route-audit.txt
  - Audit danh sach route duoc bao ve va thong tin kiem tra quyen truy cap.

### Quan tri / Vận hanh
- setup/runbook.md
  - Runbook release/deploy cho staging va production: backup DB, migration, build WAR,
    deploy Tomcat, smoke test, rollback plan.

## Ghi chu

- Toan bo tai lieu chuyen mon da duoc nhom theo linh vuc trong thu muc `docs/`.
- Neu bo sung tai lieu moi, uu tien tao thu muc theo module (vi du: `docs/payment/`, `docs/event/`).
