# Steam Split Tunnel

Chỉ đẩy **lưu lượng TCP của Steam** qua tunnel Cloudflare WARP (miễn phí).
Toàn bộ HTTPS khác (Chrome, Zalo, ...) và **toàn bộ UDP (CS2)** đi thẳng ra Internet.

# Lưu ý trước khi dùng

- **Đừng bật VPN khác** (WARP app, Tailscale, Radmin) cùng lúc — `strict_route` sẽ xung đột.
- **Đừng mua game khi tunnel đang bật**: Steam có thể thấy IP Cloudflare → sai region.
- WARP endpoint `188.114.96.1` đang ổn định; nếu chết, thử `188.114.97.1`, `188.114.98.1`, `188.114.99.1`.
- Config pin sing-box **1.10.7**; nâng lên 1.11+ phải đổi schema (wireguard → endpoints, sniff → action).

## Nó làm gì

| Luồng | Đường đi |
|---|---|
| `steam.exe`, `steamwebhelper.exe`, `steamservice.exe` (TCP) | → WARP (tunnel) |
| HTTPS của app khác (Chrome, Firefox, Edge...) | → đi thẳng |
| UDP (CS2, Discord voice, game khác) | → đi thẳng, ping không đổi |
| DNS | → DoH 1.1.1.1 (đi thẳng), không còn bị trả `127.0.0.1` |

Cơ chế: TUN adapter `SteamTun` + sing-box 1.10.7. Rule match theo **tên process**,
nên không phụ thuộc SNI/ECH, không cần bật sniffing.

## Cài đặt

1. Tải file zip và giải nén
2. Nhấp đúp **`install.bat`** → bấm **Yes** ở hộp thoại UAC.
3. Script sẽ copy sang `C:\steam-tunnel`, tạo Scheduled Task `SteamSplitTunnel`
   (chạy khi đăng nhập, quyền cao nhất), rồi khởi động ngay.
4. **Thoát hẳn Steam** (tray → Exit) rồi mở lại, sau đó thử vào store.

## Kiểm chứng

```powershell
# 1) Tunnel có sống không
Get-Process sing-box
Get-NetAdapter -Name SteamTun

# 2) Store phải mở được (trước đây treo ~20s)
curl.exe -sS -o NUL -w "%{http_code} %{time_total}s`n" https://store.steampowered.com/

# 3) Web khác vẫn đi thẳng: IP egress phải là IP nhà mạng
curl.exe -sS https://api.ipify.org

# 4) UDP của game không vào tunnel
Get-NetUDPEndpoint -OwningProcess (Get-Process cs2).Id   # LocalAddress = 192.168.1.10
```

Xem log: `C:\steam-tunnel\sing-box.log` — dòng `route: match process_name=... => outbound warp`.

## Dùng hằng ngày

- Tự chạy khi đăng nhập Windows. Không cần làm gì.
- **Tắt tạm**: chạy `stop.bat` (hoặc `C:\steam-tunnel\stop.bat`).
- **Bật lại**: chạy `install.bat` (copy lại rồi start) hoặc `schtasks /Run /TN SteamSplitTunnel`.
- **Xem trạng thái**: `status.bat`.

## Gỡ hoàn toàn

Chạy **`uninstall.bat`** (Yes ở UAC). Nó sẽ:

1. Dừng task + kill `sing-box.exe`
2. Xoá Scheduled Task `SteamSplitTunnel`
3. Xoá adapter `SteamTun`
4. Xoá thư mục `C:\steam-tunnel`

Không đụng tới DNS hệ thống, registry, driver — không có gì còn lại sau khi gỡ.
Nếu muốn gỡ tay từng bước:

```powershell
schtasks /End /TN SteamSplitTunnel
schtasks /Delete /TN SteamSplitTunnel /F
taskkill /IM sing-box.exe /F
Remove-NetAdapter -Name SteamTun -Confirm:$false
Remove-Item -Recurse -Force C:\steam-tunnel
```

## Cấu hình (config.json)

```json
"route": {
  "rules": [
    { "port": 53, "outbound": "dns-out" },                  // DNS → DoH nội bộ
    { "network": "udp", "outbound": "direct" },             // UDP đi thẳng (game)
    { "process_name": ["steam.exe","steamwebhelper.exe",
                        "steamservice.exe"], "outbound": "warp" }  // Steam → tunnel
  ],
  "final": "direct"
}
```

Muốn thêm app khác vào tunnel: thêm tên exe vào `process_name`.
Muốn **chỉ 443** của Steam (không tunnel CM 27015): thêm `"port": [443, 80]` vào rule đó.

## Xử lý sự cố

| Hiện tượng | Nguyên nhân / cách sửa |
|---|---|
| Store vẫn treo | Steam chưa khởi động lại; hoặc WARP endpoint chết → đổi `server` trong config sang `188.114.97.1` rồi chạy lại |
| Mất mạng hoàn toàn sau khi cài | Chạy `stop.bat`; kiểm tra xung đột Tailscale/Radmin VPN (tắt chúng khi dùng) |
| `sing-box.exe` thoát ngay | Xem `C:\steam-tunnel\sing-box.log`; thường do thiếu quyền admin hoặc thiếu `wintun.dll` |
| Web khác chậm | Kiểm tra rule: chỉ process Steam được tunnel, không nên có `port 443` toàn cục |
| Tải game chậm | WARP free bị bóp; có thể tắt tunnel khi chỉ tải file lớn |

## Lưu ý

- **Đừng bật VPN khác** (WARP app, Tailscale, Radmin) cùng lúc — `strict_route` sẽ xung đột.
- **Đừng mua game khi tunnel đang bật**: Steam có thể thấy IP Cloudflare → sai region.
- WARP endpoint `188.114.96.1` đang ổn định; nếu chết, thử `188.114.97.1`, `188.114.98.1`, `188.114.99.1`.
- Config pin sing-box **1.10.7**; nâng lên 1.11+ phải đổi schema (wireguard → endpoints, sniff → action).
