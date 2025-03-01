# 📝 Copilot Instructions

## 🔹 Overview

Bạn là một developer với hơn 10 năm kinh nghiệm, đang phát triển một dự án ứng dụng di động hiện đại sử dụng **Flutter, Dart, Riverpod, Dio và GoRouter**. Dự án này **không sử dụng Provider hoặc Bloc**. Hãy đảm bảo rằng code của bạn **sạch**, **tối ưu** và **dễ bảo trì**.

---

## 📌 General Coding Guidelines

- Sử dụng **Dart** cho toàn bộ code.
- Code phải **clear, concise, readable** và **self-documented**.
- Tuân theo nguyên tắc **KISS (Keep It Simple, Stupid)** và **DRY (Don't Repeat Yourself)**.
- Sử dụng **StatelessWidget** và **StateNotifier** thay vì StatefulWidget khi có thể.
- Tránh sử dụng `dynamic`; ưu tiên dùng các kiểu dữ liệu cụ thể hoặc `Object?` khi cần.
- Hạn chế sử dụng `setState`, thay vào đó sử dụng Riverpod để quản lý state.

---

## 📂 Project Structure

```
/lib
 ├── assets/             # Static assets (hình ảnh, icon, font, etc.)
 ├── common/             # Các component UI tái sử dụng
 ├── features/           # Modules theo chức năng (mỗi feature có logic riêng)
 ├── providers/          # Riverpod state management
 ├── router/             # Cấu hình điều hướng với GoRouter
 ├── services/           # Các service như API, LocalStorage, Auth
 ├── models/             # Định nghĩa các kiểu dữ liệu và models
 ├── utils/              # Các helper functions và extension methods
 ├── theme/              # Cấu hình theme và style chung của ứng dụng
 ├── main.dart           # Entry point của ứng dụng
```

---

## 🏷️ Naming Conventions

### 🔹 Files & Folders

- **snake_case** cho tên file và folder (ví dụ: `user_profile.dart`, `auth_service.dart`).
- **PascalCase** cho tên class (ví dụ: `UserProfile`, `AuthService`).
- **camelCase** cho biến và phương thức (ví dụ: `fetchUserData()`, `userList`).

### 🔹 Widgets

- File widget luôn có phần mở rộng `.dart`.
- Tên widget theo **PascalCase**, bắt đầu bằng danh từ hoặc động từ (ví dụ: `UserCard.dart`, `DashboardScreen.dart`).

### 🔹 Variables & Functions

- Sử dụng **camelCase** cho biến và hàm (ví dụ: `fetchUserData()`, `userList`).
- Ưu tiên dùng `final` khi giá trị không thay đổi.
- Sử dụng prefix `handle` cho các event handlers (ví dụ: `handleSubmit()`, `handleTap()`).

### 🔹 State Management (Riverpod)

- Sử dụng **StateNotifierProvider** để quản lý state phức tạp.
- Đặt tên provider theo cú pháp `xxxProvider` (ví dụ: `userProvider`, `authProvider`).
- Ưu tiên sử dụng `FutureProvider` cho API calls.

---

## 🏗️ State Management (Riverpod)

- Sử dụng **StateNotifier** cho state có thể thay đổi.
- Tránh sử dụng `setState`, thay vào đó dùng Riverpod.
- Khi cần async state, sử dụng `FutureProvider` hoặc `AsyncNotifier`.

Ví dụ:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../models/user.dart';

final userProvider = FutureProvider<User>((ref) async {
  return await UserService.fetchUser();
});

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  Future<void> fetchUser() async {
    state = await UserService.fetchUser();
  }
}

final userNotifierProvider =
    StateNotifierProvider<UserNotifier, User?>((ref) => UserNotifier());
```

---

## 🌍 Networking (Dio)

- Sử dụng **Dio** để gọi API, tránh dùng `http` package trực tiếp.
- Định nghĩa API base URL trong `env.dart` hoặc một file config riêng.
- Bắt lỗi khi gọi API và hiển thị thông báo lỗi hợp lý.

Ví dụ:

```dart
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  static Future<Response> getUserData(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user data');
    }
  }
}
```

---

## 🎨 UI & Styling

- **Material 3** hoặc **Flutter ThemeData** được sử dụng cho theme.
- Sử dụng **extension methods** để tạo các helper cho styling.
- Tránh hardcode style, ưu tiên dùng `Theme.of(context)`.

Ví dụ:

```dart
extension TextStyleHelpers on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
}

final themeData = ThemeData(
  primarySwatch: Colors.blue,
  textTheme: TextTheme(
    bodyMedium: TextStyle(fontSize: 16),
  ),
);
```

---

## 🏛 Navigation (GoRouter)

- Sử dụng **GoRouter** thay vì `Navigator.push`.
- Định nghĩa các route trong một file riêng.
- Tránh truyền tham số trực tiếp vào `Navigator`, thay vào đó dùng `GoRouter` state.

Ví dụ:

```dart
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/profile/:id',
      builder: (context, state) => ProfileScreen(userId: state.pathParameters['id']!),
    ),
  ],
);
```

---

## ❌ Error Handling

- Luôn bắt lỗi khi gọi API.
- Sử dụng **try-catch** để xử lý exception.
- Hiển thị thông báo lỗi qua SnackBar hoặc dialog.

Ví dụ:

```dart
Future<void> fetchUser() async {
  try {
    final user = await UserService.fetchUser();
    print('User fetched: $user');
  } catch (e) {
    print('Failed to fetch user data');
  }
}
```

---

## 📝 Documentation & Comments

- Sử dụng **DartDoc** cho các function, providers và services quan trọng.
- Viết comment ngắn gọn, chỉ cần comment những phần không rõ ràng.

Ví dụ:

```dart
/// Lấy dữ liệu người dùng theo ID
///
/// Trả về một đối tượng [User] nếu thành công.
Future<User> fetchUserData(String userId) async {
  final response = await ApiService.getUserData(userId);
  return User.fromJson(response.data);
}
```

---

## ✅ Best Practices Checklist

✔ Luôn sử dụng Dart, tránh dùng `dynamic`.  
✔ Sử dụng Riverpod cho quản lý state.  
✔ Luôn trả về code đầy đủ, không trả về `// existing code`.  
✔ Dùng Dio để gọi API thay vì `http`.  
✔ Tạo widget nhỏ gọn, tránh file quá dài.  
✔ Dùng GoRouter thay vì `Navigator.push`.  
✔ Đặt tên biến theo camelCase, widget theo PascalCase.  
✔ Tách riêng logic ra service hoặc provider khi cần.

---

## 🔗 Useful References

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Dio Documentation](https://pub.dev/packages/dio)

---
