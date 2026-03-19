# Release Runbook

## 1. Muc tieu
Tai lieu nay mo ta quy trinh release chuan cua team cho du an SellingTicketJava theo luong deploy hien tai:
- SQL Server
- Apache Tomcat 10.1
- NetBeans/Ant build WAR

## 2. Pham vi
Ap dung cho cac moi truong:
- Staging
- Production

Khong ap dung cho local dev nhanh (co the chay full reset).

## 3. Vai tro
- Release Owner: dieu phoi release, quyet dinh go/no-go
- DB Owner: backup DB, chay migration, xac nhan data
- App Owner: build/deploy WAR, verify app
- QA Owner: smoke test va sign-off

## 4. Tien dieu kien
- Code da merge vao nhanh release
- Build pass, khong co loi compile
- Co backup DB truoc release
- Co tai khoan deploy Tomcat Manager (neu deploy qua manager)
- Da xac nhan file cau hinh:
  - src/java/db.properties
  - src/webapp/WEB-INF/google-oauth.properties
  - src/java/seepay.properties

## 5. Luong release chuan

### B1. Chot phien ban
- Tao tag release (vd: v2026.03.12-rc1)
- Chot commit hash release
- Tao release notes ngan gon: tinh nang, fix, migration can chay

### B2. Backup database
Khuyen nghi backup full truoc moi release:

```sql
BACKUP DATABASE SellingTicketDB
TO DISK = 'D:\\backup\\SellingTicketDB_pre_release.bak'
WITH INIT, COMPRESSION, STATS = 10;
```

### B3. Chay migration theo thu tu
- Chay cac file trong thu muc database/migrations theo thu tu ten file.
- Khong chay file full reset tren staging/production.

Thu tu toi thieu hien tai:
1. database/migrations/migration_auth_fix.sql
2. database/migrations/migration_bcrypt_fix.sql
3. database/migrations/migration_event_settings.sql
4. database/migrations/migration_rejection_reason.sql
5. database/migrations/migration_site_settings.sql
6. database/migrations/migration_soft_delete.sql
7. database/migrations/fix_roles.sql

### B4. Build WAR
Tai root project, build bang Ant:

```bash
ant clean
ant dist
```

WAR output:
- dist/SellingTicketJava.war

### B5. Deploy len Tomcat
Co 2 cach team dang dung:

#### Cach A: NetBeans Deploy (khuyen dung)
- Mo project trong NetBeans
- Chon server Tomcat 10.1
- Run/Deploy project

#### Cach B: Ant deploy qua Tomcat Manager
Thong tin deploy duoc map trong nbproject/ant-deploy.xml.
Can set dung credentials tren may deploy.

### B6. Smoke test sau deploy
Kiem tra toi thieu:
- Public pages: /home, /events, /event-detail
- Auth: /login, /register, /logout
- Checkout flow: chon ve -> checkout -> tao order
- Organizer pages: /organizer/events, /organizer/create-event
- Admin pages: /admin/dashboard, /admin/settings
- Support/chat: /api/chat/* hoat dong
- File upload: /media/upload

### B7. Verify database sau migration
Kiem tra nhanh:
- Bang SiteSettings ton tai va co du lieu
- Khong co loi FK/constraint
- Event status, order status, user role hop le

### B8. Monitoring sau release (30-60 phut)
- Theo doi catalina.out va log app
- Theo doi loi 500/404
- Theo doi login failures bat thuong
- Theo doi checkout/payment errors

## 6. Rollback plan

### Rollback app
- Deploy lai WAR phien ban truoc
- Restart context neu can

### Rollback database
Neu migration gay loi nghiem trong:
1. Tam ngung traffic
2. Restore tu backup pre-release
3. Deploy lai WAR version truoc
4. Chay smoke test toi thieu

Restore mau:

```sql
ALTER DATABASE SellingTicketDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE SellingTicketDB
FROM DISK = 'D:\\backup\\SellingTicketDB_pre_release.bak'
WITH REPLACE, RECOVERY;
ALTER DATABASE SellingTicketDB SET MULTI_USER;
```

## 7. Checklist go-live
- [ ] Backup DB thanh cong
- [ ] Migration chay thanh cong
- [ ] Build WAR thanh cong
- [ ] Deploy thanh cong
- [ ] Smoke test pass
- [ ] Monitoring on-call da san sang
- [ ] Release notes da gui team

## 8. Dieu cam ket trong release
- Khong chay database/schema/full_reset_seed.sql tren staging/prod
- Khong sua truc tiep du lieu production neu khong co ticket
- Khong deploy neu chua co backup DB

## 9. Tai lieu lien quan
- docs/auth/auth-docs.md
- docs/security/protected-route-audit.txt
- database/README.md
