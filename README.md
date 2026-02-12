# HostVN VPS Patch Script By Antigravity

Script tự động sửa lỗi và cấu hình tối ưu cho VPS sử dụng **HostVN Scripts**.

## Chức năng
1.  **Sửa lỗi 520 (Cloudflare):** Do cấu hình Nginx chặn nhầm file `.html` (trong `map.conf`).
2.  **Cấu hình FastCGI Cache:** Tự động quét và bật cache cho **TẤT CẢ** các domain đang hoạt động trên VPS.
3.  **Tự động hóa hoàn toàn:** Không cần nhập tên miền thủ công.

## Hướng dẫn sử dụng

### Cài đặt tự động (Khuyến nghị)
Chạy lệnh sau với quyền root:
```bash
sudo bash <(curl -sL https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/patch_hostvn.sh)
```
*Script sẽ tự động quét toàn bộ website trên VPS và áp dụng bản vá cho tất cả.*

Hoặc nếu muốn chạy riêng cho 1 domain:
```bash
sudo bash <(curl -sL https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/patch_hostvn.sh) yourdomain.com
```
- Reload Nginx.

---

### Cách 2: Tải về và chạy thủ công

1. **Tải script về:**
   ```bash
   wget https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/patch_hostvn.sh
   ```

2. **Cấp quyền thực thi:**
   ```bash
   chmod +x patch_hostvn.sh
   ```

3. **Chạy script:**
   ```bash
   sudo ./patch_hostvn.sh
   ```

---

## Cài đặt Redis (Tùy chọn) for Object Cache

Nếu bạn muốn tăng tốc độ database cho WordPress/WooCommerce, hãy cài thêm Redis:

**Cách chạy nhanh:**
```bash
sudo bash <(curl -sL https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/install_redis.sh)
```
*Script sẽ tự động cài `redis-server` và `php-redis` extension.*

**Quản lý Redis (Menu tích hợp):**
Script đã tự động thêm vào menu gốc của HostVN.
1. Gõ `hostvn` hoặc `menu` để mở menu.
2. Chọn số **10. Redis Manager** để quản lý.

*(Hoặc gõ lệnh tắt `redis-manager`)*

---

## Lưu ý
- Script cần được chạy với quyền **root**.
- Script sẽ tự động backup các file cấu hình (`.bak`) trước khi sửa đổi.
- Script sẽ kiểm tra xem cache đã được bật chưa trước khi thêm cấu hình mới (tránh trùng lặp).
