# HostVN VPS Patch Script By Antigravity

Script tự động sửa lỗi và cấu hình tối ưu cho VPS sử dụng **HostVN Scripts**.

## Chức năng
1.  **Sửa lỗi 520 (Cloudflare):** Do cấu hình Nginx chặn nhầm file `.html` (trong `map.conf`).
2.  **Cấu hình FastCGI Cache:** Tự động quét và bật cache cho **TẤT CẢ** các domain đang hoạt động trên VPS.
3.  **Tự động hóa hoàn toàn:** Không cần nhập tên miền thủ công.

## Hướng dẫn sử dụng

### Cách 1: Chạy trực tiếp từ GitHub (Nhanh nhất)
Copy và chạy lệnh sau trên VPS (quyền root):

```bash
bash <(curl -sL https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/patch_hostvn.sh)
```

Script sẽ tự động:
- Quét toàn bộ file cấu hình trong `/etc/nginx/sites-enabled/`.
- Áp dụng sửa lỗi và cấu hình cache cho từng domain.
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

**Quản lý Redis (Menu):**
Sau khi cài đặt xong, bạn chỉ cần gõ lệnh sau để mở menu quản lý:
```bash
redis-manager
```
*(Menu cho phép: Start, Stop, Restart, Xem trạng thái, Bật/Tắt khởi động cùng VPS)*

---

## Lưu ý
- Script cần được chạy với quyền **root**.
- Script sẽ tự động backup các file cấu hình (`.bak`) trước khi sửa đổi.
- Script sẽ kiểm tra xem cache đã được bật chưa trước khi thêm cấu hình mới (tránh trùng lặp).
