# HostVN VPS Patch Script

Script tự động sửa lỗi và cấu hình tối ưu cho VPS sử dụng **HostVN Scripts**.

## Chức năng
1.  **Sửa lỗi 520 (Cloudflare):** Do cấu hình Nginx chặn nhầm file `.html` (trong `map.conf`).
2.  **Cấu hình FastCGI Cache:** Tự động tạo thư mục cache và thêm cấu hình cache cho domain cụ thể.
3.  **Hỗ trợ nhiều domain:** Có thể chạy cho bất kỳ domain nào trên VPS.

## Hướng dẫn sử dụng

### Cách 1: Chạy trực tiếp từ GitHub (Khuyên dùng)
Bạn chỉ cần copy và chạy 1 lệnh duy nhất dưới đây trên VPS (quyền root):

```bash
bash <(curl -sL https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/patch_hostvn.sh) [ten_mien]
```
*Ví dụ:*
```bash
bash <(curl -sL https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/patch_hostvn.sh) azevent.vn
```
*(Nếu không nhập tên miền, script sẽ hỏi bạn sau khi chạy)*

---

### Cách 2: Tải về và chạy thủ công

1. **Tải script về:**
   ```bash
   wget https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/patch_hostvn.sh
   # Hoặc dùng curl
   curl -O https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/patch_hostvn.sh
   ```

2. **Cấp quyền thực thi:**
   ```bash
   chmod +x patch_hostvn.sh
   ```

3. **Chạy script:**
   ```bash
   sudo ./patch_hostvn.sh [ten_mien]
   ```
   *Ví dụ:* `sudo ./patch_hostvn.sh congtytochucsukienaz.com`

---

## Lưu ý
- Script cần được chạy với quyền **root**.
- Script sẽ tự động backup các file cấu hình (`.bak`) trước khi sửa đổi.
- Nếu bạn gặp lỗi, hãy kiểm tra lại file backup hoặc log của Nginx.
