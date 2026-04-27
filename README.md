# Map Chat

Map Chat là ứng dụng Flutter kết hợp bản đồ tương tác với chatbot sử dụng Gemini API. Dự án tập trung vào các kỹ năng thực tế trong phát triển mobile: xử lý bản đồ, định vị thiết bị, gọi REST API, quản lý trạng thái bất đồng bộ và xây dựng giao diện Material 3 gọn gàng.

Tên package Flutter hiện tại là `learning_flutter_app`, còn tên hiển thị của ứng dụng là `Map Chat`.

## Tính năng nổi bật

- Hiển thị bản đồ tương tác bằng `flutter_map` và OpenStreetMap.
- Tìm kiếm địa điểm, địa chỉ, quán ăn và khu vực qua Nominatim.
- Tự động dùng Photon làm nguồn dự phòng khi Nominatim không phản hồi.
- Chạm vào bản đồ để tra cứu ngược thông tin địa điểm.
- Xác định vị trí hiện tại với xử lý quyền truy cập bằng `geolocator`.
- Hiển thị marker, danh sách kết quả tìm kiếm và bảng thông tin chi tiết địa điểm.
- Mở địa điểm trực tiếp trên OpenStreetMap.
- Chatbot Gemini qua REST API với màn hình cấu hình API key và model.
- Hỗ trợ truyền Gemini API key bằng `--dart-define` hoặc nhập trực tiếp trong app.
- Điều hướng 2 tab bằng `NavigationBar` và giữ trạng thái màn hình với `IndexedStack`.

## Công nghệ sử dụng

| Thành phần | Công nghệ |
| --- | --- |
| Framework | Flutter, Dart |
| UI | Material 3 |
| Bản đồ | `flutter_map`, OpenStreetMap |
| Geocoding | Nominatim, Photon |
| Định vị | `geolocator` |
| HTTP client | `http` |
| Mở liên kết ngoài | `url_launcher` |
| AI chatbot | Gemini Generative Language API |

## Yêu cầu môi trường

- Flutter SDK tương thích với Dart `>=3.2.0 <4.0.0`
- Xcode và CocoaPods nếu chạy trên iOS simulator hoặc thiết bị iOS
- Android Studio hoặc Android SDK nếu chạy trên Android
- Kết nối internet để tải map tiles, tìm kiếm địa điểm và gọi Gemini API
- Gemini API key để sử dụng chức năng chatbot

## Cài đặt

Cài dependencies:

```bash
flutter pub get
```

Chạy ứng dụng trên thiết bị mặc định:

```bash
flutter run
```

Chạy trên iOS simulator:

```bash
open -a Simulator
flutter devices
flutter run -d <ios-simulator-id>
```

Chạy kèm Gemini API key:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY \
  --dart-define=GEMINI_MODEL=gemini-2.5-flash
```

Ngoài ra, có thể mở tab Chatbot trong app và nhập API key trực tiếp ở phần cấu hình.

## Cấu hình iOS

Dự án đã có `ios/Podfile` và cấu hình iOS deployment target là `12.0`.

Nếu cần cài lại CocoaPods thủ công:

```bash
cd ios
pod install
cd ..
```

Ứng dụng đã khai báo mô tả quyền vị trí trong `ios/Runner/Info.plist`:

- `NSLocationWhenInUseUsageDescription`
- `NSLocationTemporaryUsageDescriptionDictionary`

## Cấu hình Android

`android/app/src/main/AndroidManifest.xml` đã khai báo các quyền cần thiết:

- `INTERNET`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_FINE_LOCATION`

## Cấu trúc thư mục

```text
lib/
  main.dart
  models/
    chat_message.dart
    place_result.dart
  screens/
    chatbot_screen.dart
    maps_screen.dart
  services/
    gemini_chat_service.dart
    nominatim_service.dart
```

## Mô tả các module chính

`lib/main.dart`  
Khởi tạo ứng dụng, theme Material 3, bottom navigation và layout chính.

`lib/screens/maps_screen.dart`  
Xử lý giao diện bản đồ, tìm kiếm, marker, định vị, zoom controls, reverse lookup và bảng chi tiết địa điểm.

`lib/services/nominatim_service.dart`  
Gọi Nominatim/Photon, parse dữ liệu địa điểm, giới hạn tần suất request và chuẩn hóa thông báo lỗi mạng.

`lib/screens/chatbot_screen.dart`  
Xây dựng giao diện chatbot, cấu hình API key/model, danh sách tin nhắn và ô nhập nội dung.

`lib/services/gemini_chat_service.dart`  
Gọi Gemini REST API, gửi lịch sử hội thoại gần nhất và xử lý nội dung phản hồi hoặc lỗi từ API.

## Cấu hình Gemini

Chatbot hỗ trợ 2 cách cấu hình:

- Nhập trực tiếp trong app: vào tab Chatbot, mở phần cấu hình và dán API key.
- Truyền khi chạy app:

```bash
--dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
--dart-define=GEMINI_MODEL=gemini-2.5-flash
```

Nếu không truyền model, app sử dụng mặc định `gemini-2.5-flash`.

## Nhà cung cấp dữ liệu bản đồ

Ứng dụng đang sử dụng:

- OpenStreetMap cho map tiles
- Nominatim cho tìm kiếm và reverse geocoding chính
- Photon cho geocoding dự phòng
- CARTO Voyager tiles làm nguồn tiles dự phòng

Trước khi phát hành production, cần cập nhật `User-Agent` trong `NominatimService` bằng thông tin ứng dụng/liên hệ thật và kiểm tra chính sách sử dụng của từng nhà cung cấp dữ liệu.

## Xử lý lỗi thường gặp

### CocoaPods báo không tìm thấy `RunnerTests`

Kiểm tra `ios/Podfile` và đảm bảo chỉ khai báo các target đang tồn tại trong `ios/Runner.xcodeproj`. Dự án hiện tại sử dụng target `Runner`.

### Bản đồ bị trắng hoặc không tải tiles

Kiểm tra kết nối internet/DNS của simulator hoặc thiết bị. App có hiển thị cảnh báo khi không tải được một số ô bản đồ.

### Nút định vị không hoạt động

Đảm bảo dịch vụ định vị đã bật trên simulator/thiết bị và cấp quyền vị trí cho ứng dụng khi được hỏi.

### Chatbot báo thiếu API key

Nhập Gemini API key trong màn hình Chatbot hoặc chạy app với:

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

## Kiểm tra chất lượng

Chạy static analysis:

```bash
flutter analyze
```

Chạy test:

```bash
flutter test
```

Build bản iOS debug cho simulator:

```bash
flutter build ios --debug --simulator
```

## Ghi chú phát triển

- Không commit API key thật vào source code.
- Không lạm dụng Nominatim cho lượng request lớn; cần tuân thủ usage policy của dịch vụ.
- Khi release, nên thay bundle identifier mặc định `com.example.learningflutterapp` bằng identifier chính thức.
- Có thể bổ sung ảnh chụp màn hình app vào README để tăng tính trực quan.

## Giấy phép

Dự án phục vụ mục đích học tập và bài tập. Hãy bổ sung license phù hợp trước khi phân phối hoặc công khai rộng rãi.
