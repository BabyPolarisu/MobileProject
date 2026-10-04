import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/chat_model.dart';
import '../models/review_model.dart';
import '../models/report_model.dart';
import '../models/verification_model.dart';
import '../models/notification_model.dart';
import '../core/constants.dart';
import '../core/auth/oidc_service.dart';
import 'api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final OidcService oidcService = OidcService();

  // Authentication & Route Guard State
  bool isAuthenticated = false;
  bool isAuthLoading = true;

  // Theme Mode State (Light / Dark)
  ThemeMode themeMode = ThemeMode.light;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  // Current logged in user
  late UserModel currentUser;
  late UserModel adminUser;
  late UserModel otherSellerUser;

  // Data lists
  List<CategoryModel> categories = [];
  List<ProductModel> products = [];
  List<ChatRoomModel> chatRooms = [];
  Map<int, List<ChatMessageModel>> chatMessages = {};
  List<ReviewModel> reviews = [];
  List<ReportModel> reports = [];
  List<VerificationRequestModel> verificationRequests = [];
  List<NotificationItemModel> notifications = [];

  // Active filters
  CategoryModel? selectedCategory;
  String searchQuery = '';
  String? selectedCondition; // 'new', 'used', null
  double? maxPriceFilter;

  // Backend connection status
  bool isConnectedToBackend = false;
  bool isSimulatedOffline = false;

  AppState() {
    _initSeedData();
    _initAuthAndTheme();
    checkBackendConnection();
  }

  Future<void> _initAuthAndTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

      final restored = await oidcService.restoreSession();
      if (restored != null) {
        currentUser = restored;
        isAuthenticated = true;
        apiService.authToken = await oidcService.getAccessToken();
      }
    } catch (_) {
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', themeMode == ThemeMode.dark);
    } catch (_) {}
  }

  void toggleSimulatedOffline() {
    isSimulatedOffline = !isSimulatedOffline;
    if (isSimulatedOffline) {
      isConnectedToBackend = false;
      notifyListeners();
    } else {
      checkBackendConnection();
    }
  }

  Future<bool> loginWithOidc(String username, String password) async {
    final user = await oidcService.login(username: username, password: password);
    if (user != null) {
      currentUser = user;
      isAuthenticated = true;
      apiService.authToken = await oidcService.getAccessToken();
      await checkBackendConnection();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await oidcService.logout();
    isAuthenticated = false;
    apiService.authToken = null;
    notifyListeners();
  }

  Future<bool> checkBackendConnection() async {
    if (isSimulatedOffline) {
      isConnectedToBackend = false;
      notifyListeners();
      return false;
    }
    final online = await apiService.checkServerHealth();
    isConnectedToBackend = online;
    if (online) {
      try {
        await apiService.registerMobileDevice(
          platform: 'flutter_web',
          model: 'Web Browser (Port 50000)',
        );
        final backendCats = await apiService.fetchCategories();
        if (backendCats.isNotEmpty) {
          categories = backendCats;
        }
        final backendProducts = await apiService.fetchProducts();
        if (backendProducts.isNotEmpty) {
          products = backendProducts;
        }
      } catch (_) {}
    }
    notifyListeners();
    return online;
  }


  void _initSeedData() {
    // 1. Users
    currentUser = UserModel(
      id: 1,
      username: 'somchai_ubu',
      email: 'somchai@ubu.ac.th',
      displayName: 'สมชาย เรียนดี',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=faces',
      phoneNumber: '089-123-4567',
      address: 'หอพักนักศึกษา อาคาร 3 มหาวิทยาลัยอุบลราชธานี',
      bio: 'นักศึกษาชั้นปีที่ 3 คณะวิทยาศาสตร์ ชอบอ่านหนังสือและคอมพิวเตอร์',
      isVerified: true,
      isAdmin: false,
    );

    adminUser = UserModel(
      id: 99,
      username: 'admin',
      email: 'admin@ubu.ac.th',
      displayName: 'ผู้ดูแลระบบ (Admin)',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=faces',
      phoneNumber: '045-353-000',
      address: 'สำนักงานบริการเทคโนโลยีสารสนเทศ',
      bio: 'เจ้าหน้าที่ผู้ดูแลระบบตลาดกลาง UniMarket มหาวิทยาลัย',
      isVerified: true,
      isAdmin: true,
    );

    otherSellerUser = UserModel(
      id: 2,
      username: 'thanaporn_k',
      email: 'thanaporn@ubu.ac.th',
      displayName: 'ธนพร สายช้อป',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&h=200&fit=crop&crop=faces',
      phoneNumber: '081-987-6543',
      address: 'หอพักสตรีศรีอุบล',
      bio: 'สินค้าทุกชิ้นใช้เอง สภาพดี ราคาแบ่งปันเพื่อนนักศึกษาค่ะ',
      isVerified: true,
      isAdmin: false,
    );

    // 2. Categories
    categories = AppConstants.initialCategories.map((e) => CategoryModel(
      id: int.parse(e['id']!),
      name: e['name']!,
      icon: e['icon']!,
      code: e['code']!,
    )).toList();

    // 3. Products (Offline/Initial seed cache matching Django DB)
    final catBooks = categories.firstWhere((c) => c.code == 'books', orElse: () => categories[0]);
    final catElectronics = categories.firstWhere((c) => c.code == 'electronics', orElse: () => categories[1]);
    final catClothing = categories.firstWhere((c) => c.code == 'clothing', orElse: () => categories[2]);
    final catStationary = categories.firstWhere((c) => c.code == 'stationary', orElse: () => categories[6]);
    final catDorm = categories.firstWhere((c) => c.code == 'dorm', orElse: () => categories[5]);
    final catSports = categories.firstWhere((c) => c.code == 'sports', orElse: () => categories[7]);

    products = [
      ProductModel(
        id: 1,
        name: 'หนังสือ Calculus 1 สำหรับวิศวะและวิทยาศาสตร์',
        description: 'สภาพ 95% ไร้รอยขีดเขียน ไฮไลท์เฉพาะบทแรกๆ เหมาะสำหรับน้องปี 1 อ่านเตรียมสอบกลางภาค นัดรับในมอได้ครับ',
        price: 180.0,
        condition: 'used',
        imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop',
        category: catBooks,
        seller: otherSellerUser,
        status: 'active',
        favoritesCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ProductModel(
        id: 2,
        name: 'iPad Air 4 64GB WiFi สี Space Grey',
        description: 'เครื่องศูนย์ไทย อุปกรณ์ครบกล่อง สภาพสวย ไม่มีรอยตกหล่น แบตเตอรี่ 88% แถมเคสและฟิล์มกระจกติดแล้ว',
        price: 11500.0,
        condition: 'used',
        imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=600&auto=format&fit=crop',
        category: catElectronics,
        seller: otherSellerUser,
        status: 'active',
        favoritesCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProductModel(
        id: 3,
        name: 'เสื้อช็อปวิศวะ ม.อุบล ไซส์ L สภาพดี',
        description: 'เสื้อช็อปสีกรมท่า ไซส์ L รอบอก 42 นิ้ว ผ้าหนาทนทาน ซักเก็บอย่างดี ไม่มีรอยขาด ใส่เรียนช็อปสบาย',
        price: 250.0,
        condition: 'used',
        imageUrl: 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=600&auto=format&fit=crop',
        category: catClothing,
        seller: currentUser,
        status: 'active',
        favoritesCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ProductModel(
        id: 4,
        name: 'เครื่องคิดเลขวิทยาศาสตร์ Casio fx-991EX',
        description: 'รุ่นยอดนิยมสำหรับสอบวิศวะและวิทยาศาสตร์ หน้าจอความละเอียดสูง ฟังก์ชันครบ ใช้งานได้ปกติทุกปุ่ม พร้อมฝาครอบสไลด์',
        price: 590.0,
        condition: 'used',
        imageUrl: 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=600&auto=format&fit=crop',
        category: catStationary,
        seller: currentUser,
        status: 'active',
        favoritesCount: 7,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ProductModel(
        id: 5,
        name: 'พัดลมตั้งโต๊ะ Hatari 16 นิ้ว ลมแรงประหยัดไฟ',
        description: 'พัดลมตั้งโต๊ะสีเขียวมิ้นท์ ปรับแรงลมได้ 3 ระดับ สภาพ 90% ใช้งานดีเงียบ ประหยัดไฟเบอร์ 5 นัดรับได้ที่หอพัก',
        price: 320.0,
        condition: 'used',
        imageUrl: 'https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=600&auto=format&fit=crop',
        category: catDorm,
        seller: otherSellerUser,
        status: 'active',
        favoritesCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ProductModel(
        id: 6,
        name: 'กีตาร์โปร่ง Yamaha F310 พร้อมกระเป๋าใส่',
        description: 'กีตาร์โปร่งยอดนิยม เสียงใสกังวาน เหมาะสำหรับผู้เริ่มต้นและซ้อมเพลงในหอ สภาพ 95% เปลี่ยนสาย ใหม่พร้อมเล่น',
        price: 2800.0,
        condition: 'used',
        imageUrl: 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=600&auto=format&fit=crop',
        category: catDorm,
        seller: currentUser,
        status: 'active',
        favoritesCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      ProductModel(
        id: 7,
        name: 'ไม้แบดมินตัน Yonex พร้อมลูกแบด 1 หลอด',
        description: 'ไม้แบดมินตันน้ำหนักเบา กริปสภาพดี เอ็นตึง 24 ปอนด์ พร้อมซองและลูกขนไก่ RSL 1 หลอด',
        price: 450.0,
        condition: 'used',
        imageUrl: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&auto=format&fit=crop',
        category: catSports,
        seller: otherSellerUser,
        status: 'active',
        favoritesCount: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProductModel(
        id: 8,
        name: 'โคมไฟอ่านหนังสือ LED ถนอมสายตา ปรับแสงได้ 3 ระดับ',
        description: 'โคมไฟตั้งโต๊ะทำงาน ชาร์จ USB พับเก็บได้ แสงนุ่มนวลไม่แสบตา ปรับอุณหภูมิสีได้ 3 แบบ เหมาะกับอ่านหนังสือสอบ',
        price: 190.0,
        condition: 'new',
        imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600&auto=format&fit=crop',
        category: catStationary,
        seller: currentUser,
        status: 'active',
        favoritesCount: 9,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];

    // 4. Chat Rooms & Messages
    final room1 = ChatRoomModel(
      id: 101,
      otherUser: otherSellerUser,
      lastMessage: 'ได้ครับ นัดรับที่ศูนย์อาหารบ่ายสองโมงนะครับ',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 1,
      relatedProductId: 1,
      relatedProductName: 'หนังสือ Calculus 1 สำหรับวิศวะและวิทยาศาสตร์',
      relatedProductPrice: 180.0,
      relatedProductImage: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&auto=format&fit=crop',
    );

    chatRooms = [room1];

    chatMessages[101] = [
      ChatMessageModel(
        id: 1,
        roomId: 101,
        senderId: currentUser.id,
        senderName: currentUser.effectiveName,
        content: 'สวัสดีครับ หนังสือ Calculus 1 ยังอยู่ไหมครับ?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isMine: true,
      ),
      ChatMessageModel(
        id: 2,
        roomId: 101,
        senderId: otherSellerUser.id,
        senderName: otherSellerUser.effectiveName,
        content: 'สวัสดีค่ะ ยังอยู่ค่ะ เล่มนี้สภาพดีมากเลยนะคะ',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isMine: false,
      ),
      ChatMessageModel(
        id: 3,
        roomId: 101,
        senderId: currentUser.id,
        senderName: currentUser.effectiveName,
        content: 'สะดวกนัดรับแถวศูนย์อาหารกลางวันไหมครับ?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isMine: true,
      ),
      ChatMessageModel(
        id: 4,
        roomId: 101,
        senderId: otherSellerUser.id,
        senderName: otherSellerUser.effectiveName,
        content: 'ได้ครับ นัดรับที่ศูนย์อาหารบ่ายสองโมงนะครับ',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isMine: false,
      ),
    ];

    // 5. Reviews
    reviews = [
      ReviewModel(
        id: 1,
        reviewer: currentUser,
        sellerId: otherSellerUser.id,
        rating: 5,
        comment: 'ผู้ขายใจดีมาก ตอบแชทไว นัดรับตรงเวลา หนังสือสภาพเหมือนใหม่เลยครับ แนะนำเลย!',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ReviewModel(
        id: 2,
        reviewer: UserModel(id: 3, username: 'kitti_w', email: '', displayName: 'กิตติศักดิ์ วิศวะ'),
        sellerId: otherSellerUser.id,
        rating: 5,
        comment: 'แพ็คของดีมาก นัดส่งของตามเวลา สุภาพและน่ารักมากครับ',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    // 6. Reports
    reports = [
      ReportModel(
        id: 1,
        reporter: currentUser,
        productId: 2,
        productName: 'iPad Air 5',
        reason: 'spam',
        details: 'พบการโพสต์ซ้ำหลายครั้งในบอร์ด',
        status: 'investigating',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // 7. Verifications
    verificationRequests = [
      VerificationRequestModel(
        id: 1,
        userId: currentUser.id,
        username: currentUser.username,
        studentCardImageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=400&fit=crop',
        status: 'approved',
        adminComment: 'ข้อมูลบัตรนักศึกษาถูกต้องเรียบร้อย',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 19)),
      ),
      VerificationRequestModel(
        id: 2,
        userId: 4,
        username: 'siriwan_freshy',
        studentCardImageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=400&fit=crop',
        status: 'pending',
        adminComment: '',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    // 8. Notifications
    notifications = [
      NotificationItemModel(
        id: 1,
        title: 'สินค้าได้รับการอนุมัติ ✅',
        message: 'สินค้า "เสื้อช็อปนักศึกษา ม.อุบล ไซส์ L" ของคุณพร้อมขายในตลาดแล้ว',
        link: '/product/3',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationItemModel(
        id: 2,
        title: 'ยืนยันตัวตนสำเร็จ 🎉',
        message: 'บัตรนักศึกษาของคุณผ่านการอนุมัติแล้ว ตอนนี้คุณได้รับป้ายผู้ขายที่เชื่อถือได้',
        link: '/profile',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 19)),
      ),
      NotificationItemModel(
        id: 3,
        title: 'ข้อความใหม่จาก ธนพร 💬',
        message: 'ได้ครับ นัดรับที่ศูนย์อาหารบ่ายสองโมงนะครับ',
        link: '/chat/101',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  // --- Switch User (Student / Seller / Admin for easy testing) ---
  void switchUser(String username) {
    if (username == 'admin') {
      currentUser = adminUser;
    } else if (username == 'thanaporn_k') {
      currentUser = otherSellerUser;
    } else {
      currentUser = UserModel(
        id: 1,
        username: 'somchai_ubu',
        email: 'somchai@ubu.ac.th',
        displayName: 'สมชาย เรียนดี',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=faces',
        phoneNumber: '089-123-4567',
        address: 'หอพักนักศึกษา อาคาร 3 มหาวิทยาลัยอุบลราชธานี',
        bio: 'นักศึกษาชั้นปีที่ 3 คณะวิทยาศาสตร์ ชอบอ่านหนังสือและคอมพิวเตอร์',
        isVerified: true,
        isAdmin: false,
      );
    }
    notifyListeners();
  }

  void switchUserRole(bool toAdmin) {
    switchUser(toAdmin ? 'admin' : 'somchai_ubu');
  }

  // --- Filtering Products ---
  List<ProductModel> get filteredProducts {
    return products.where((p) {
      // Non-admin can only see active or sold, or their own pending
      if (!currentUser.isAdmin && p.status != 'active' && p.status != 'sold' && p.seller.id != currentUser.id) {
        return false;
      }
      // Category filter
      if (selectedCategory != null && p.category?.id != selectedCategory!.id) {
        return false;
      }
      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchName = p.name.toLowerCase().contains(q);
        final matchDesc = p.description.toLowerCase().contains(q);
        if (!matchName && !matchDesc) return false;
      }
      // Condition filter
      if (selectedCondition != null && p.condition != selectedCondition) {
        return false;
      }
      // Max price filter
      if (maxPriceFilter != null && p.price > maxPriceFilter!) {
        return false;
      }
      return true;
    }).toList();
  }

  List<ProductModel> get wishlistProducts =>
      products.where((p) => p.isFavorite).toList();

  List<ProductModel> get myListings =>
      products.where((p) => p.seller.id == currentUser.id).toList();

  List<ProductModel> get pendingApprovalProducts =>
      products.where((p) => p.status == 'pending').toList();

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;

  int get unreadMessagesCount =>
      chatRooms.fold(0, (sum, room) => sum + room.unreadCount);

  // --- Actions: Product ---
  void selectCategory(CategoryModel? cat) {
    selectedCategory = cat;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setConditionFilter(String? condition) {
    selectedCondition = condition;
    notifyListeners();
  }

  void toggleFavorite(int productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final item = products[index];
      final newFav = !item.isFavorite;
      final newCount = newFav ? item.favoritesCount + 1 : (item.favoritesCount > 0 ? item.favoritesCount - 1 : 0);
      products[index] = item.copyWith(
        isFavorite: newFav,
        favoritesCount: newCount,
      );
      if (isConnectedToBackend) {
        apiService.toggleFavorite(productId, currentUser.id);
      }
      notifyListeners();
    }
  }

  void addProduct({
    required String name,
    required String description,
    required double price,
    required String condition,
    required CategoryModel category,
    required String imageUrl,
  }) {
    final newProduct = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      description: description,
      price: price,
      condition: condition,
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop',
      category: category,
      seller: currentUser,
      status: currentUser.isAdmin ? 'active' : 'pending', // Auto-approve if admin
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    products.insert(0, newProduct);

    // Notification
    notifications.insert(0, NotificationItemModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'สร้างโพสต์สินค้าแล้ว 📝',
      message: currentUser.isAdmin
          ? 'สินค้า "${newProduct.name}" วางจำหน่ายแล้ว'
          : 'สินค้า "${newProduct.name}" ถูกส่งเพื่อรอการตรวจสอบจากแอดมิน',
      link: '/product/${newProduct.id}',
      createdAt: DateTime.now(),
    ));

    if (isConnectedToBackend) {
      apiService.createProduct(
        name: name,
        description: description,
        price: price,
        condition: condition,
        categoryId: category.id,
        sellerId: currentUser.id,
      );
    }

    notifyListeners();
  }

  Future<void> updateProduct(ProductModel updated) async {
    final index = products.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      products[index] = updated;
      notifyListeners();
    }
    if (isConnectedToBackend) {
      await apiService.updateProduct(
        id: updated.id,
        name: updated.name,
        description: updated.description,
        price: updated.price,
        condition: updated.condition,
        categoryId: updated.category?.id,
        status: updated.status,
      );
    }
  }

  Future<void> deleteProduct(int productId) async {
    products.removeWhere((p) => p.id == productId);
    notifyListeners();
    if (isConnectedToBackend) {
      await apiService.deleteProduct(productId);
    }
  }

  void markAsSold(int productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index] = products[index].copyWith(status: 'sold');
      notifyListeners();
    }
  }

  // --- Admin Product Moderation ---
  void approveProduct(int productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index] = products[index].copyWith(status: 'active');
      notifications.insert(0, NotificationItemModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'สินค้าได้รับการอนุมัติ ✅',
        message: 'สินค้า "${products[index].name}" ได้รับการอนุมัติแล้ว',
        link: '/product/$productId',
        createdAt: DateTime.now(),
      ));
      if (isConnectedToBackend) {
        apiService.adminProductAction(productId, 'approve');
      }
      notifyListeners();
    }
  }

  void rejectProduct(int productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index] = products[index].copyWith(status: 'rejected');
      if (isConnectedToBackend) {
        apiService.adminProductAction(productId, 'reject');
      }
      notifyListeners();
    }
  }

  void suspendProduct(int productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index] = products[index].copyWith(status: 'suspended');
      if (isConnectedToBackend) {
        apiService.adminProductAction(productId, 'suspend');
      }
      notifyListeners();
    }
  }

  // --- Chat Actions ---
  ChatRoomModel getOrCreateChatRoom(ProductModel product) {
    final existingRoom = chatRooms.cast<ChatRoomModel?>().firstWhere(
      (r) => r?.otherUser.id == product.seller.id && r?.relatedProductId == product.id,
      orElse: () => null,
    );
    if (existingRoom != null) {
      return existingRoom;
    }

    final newRoomId = DateTime.now().millisecondsSinceEpoch;
    final newRoom = ChatRoomModel(
      id: newRoomId,
      otherUser: product.seller,
      lastMessage: 'สนใจสินค้า: ${product.name}',
      lastMessageTime: DateTime.now(),
      relatedProductId: product.id,
      relatedProductName: product.name,
      relatedProductPrice: product.price,
      relatedProductImage: product.imageUrl,
    );

    chatRooms.insert(0, newRoom);
    chatMessages[newRoomId] = [
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch,
        roomId: newRoomId,
        senderId: currentUser.id,
        senderName: currentUser.effectiveName,
        content: 'สวัสดีครับ สนใจสินค้า "${product.name}" ครับ',
        timestamp: DateTime.now(),
        isMine: true,
      ),
    ];

    notifyListeners();
    return newRoom;
  }

  List<ChatMessageModel> getMessagesForRoom(int roomId) {
    return chatMessages[roomId] ?? [];
  }

  void sendMessage(int roomId, String content) {
    if (content.trim().isEmpty) return;

    final newMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      roomId: roomId,
      senderId: currentUser.id,
      senderName: currentUser.effectiveName,
      content: content.trim(),
      timestamp: DateTime.now(),
      isMine: true,
    );

    if (!chatMessages.containsKey(roomId)) {
      chatMessages[roomId] = [];
    }
    chatMessages[roomId]!.add(newMsg);

    // Update room preview
    final roomIdx = chatRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      chatRooms[roomIdx] = chatRooms[roomIdx].copyWith(
        lastMessage: content.trim(),
        lastMessageTime: DateTime.now(),
      );
    }

    notifyListeners();

    // Simulate other party response for realistic university marketplace demo
    Future.delayed(const Duration(seconds: 2), () {
      final replyMsg = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        roomId: roomId,
        senderId: 999,
        senderName: roomIdx != -1 ? chatRooms[roomIdx].otherUser.effectiveName : 'ผู้ขาย',
        content: 'รับทราบครับ เดี๋ยวสะดวกช่วงเย็นนัดรับของได้เลยครับ ขอบคุณครับ',
        timestamp: DateTime.now(),
        isMine: false,
      );
      chatMessages[roomId]?.add(replyMsg);
      if (roomIdx != -1) {
        chatRooms[roomIdx] = chatRooms[roomIdx].copyWith(
          lastMessage: replyMsg.content,
          lastMessageTime: DateTime.now(),
          unreadCount: chatRooms[roomIdx].unreadCount + 1,
        );
      }
      notifyListeners();
    });
  }

  void markRoomMessagesAsRead(int roomId) {
    final roomIdx = chatRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      chatRooms[roomIdx] = chatRooms[roomIdx].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  // --- Reviews ---
  List<ReviewModel> getReviewsForSeller(int sellerId) {
    return reviews.where((r) => r.sellerId == sellerId).toList();
  }

  double getAverageRating(int sellerId) {
    final sellerReviews = getReviewsForSeller(sellerId);
    if (sellerReviews.isEmpty) return 5.0;
    final total = sellerReviews.fold(0, (sum, r) => sum + r.rating);
    return total / sellerReviews.length;
  }

  void addReview({
    required int sellerId,
    required int rating,
    required String comment,
  }) {
    final newReview = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch,
      reviewer: currentUser,
      sellerId: sellerId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    reviews.insert(0, newReview);
    notifyListeners();
  }

  // --- Reports ---
  void submitReport({
    int? productId,
    String? productName,
    int? reportedUserId,
    String? reportedUserName,
    required String reason,
    required String details,
    String contactInfo = '',
  }) {
    final newReport = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch,
      reporter: currentUser,
      productId: productId,
      productName: productName,
      reportedUserId: reportedUserId,
      reportedUserName: reportedUserName,
      contactInfo: contactInfo,
      reason: reason,
      details: details,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    reports.insert(0, newReport);
    notifyListeners();
  }

  void updateReportStatus(int reportId, String newStatus) {
    final index = reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final r = reports[index];
      reports[index] = ReportModel(
        id: r.id,
        reporter: r.reporter,
        productId: r.productId,
        productName: r.productName,
        reportedUserId: r.reportedUserId,
        reportedUserName: r.reportedUserName,
        contactInfo: r.contactInfo,
        reason: r.reason,
        details: r.details,
        status: newStatus,
        createdAt: r.createdAt,
      );
      notifyListeners();
    }
  }

  // --- Verification ---
  void submitVerification({required String studentCardUrl}) {
    final newReq = VerificationRequestModel(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: currentUser.id,
      username: currentUser.username,
      studentCardImageUrl: studentCardUrl,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    verificationRequests.insert(0, newReq);
    notifyListeners();
  }

  void approveVerification(int requestId) {
    final index = verificationRequests.indexWhere((v) => v.id == requestId);
    if (index != -1) {
      final req = verificationRequests[index];
      verificationRequests[index] = VerificationRequestModel(
        id: req.id,
        userId: req.userId,
        username: req.username,
        studentCardImageUrl: req.studentCardImageUrl,
        status: 'approved',
        adminComment: 'อนุมัติผ่านการตรวจสอบเรียบร้อยแล้ว',
        createdAt: req.createdAt,
        updatedAt: DateTime.now(),
      );
      if (req.userId == currentUser.id) {
        currentUser = currentUser.copyWith(isVerified: true);
      }
      notifyListeners();
    }
  }

  void rejectVerification(int requestId, String reason) {
    final index = verificationRequests.indexWhere((v) => v.id == requestId);
    if (index != -1) {
      final req = verificationRequests[index];
      verificationRequests[index] = VerificationRequestModel(
        id: req.id,
        userId: req.userId,
        username: req.username,
        studentCardImageUrl: req.studentCardImageUrl,
        status: 'rejected',
        adminComment: reason,
        createdAt: req.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // --- Notifications ---
  void markNotificationsAsRead() {
    notifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  // Update Profile
  void updateProfile({
    required String displayName,
    required String phoneNumber,
    required String address,
    required String bio,
    String? avatarUrl,
  }) {
    currentUser = currentUser.copyWith(
      displayName: displayName,
      phoneNumber: phoneNumber,
      address: address,
      bio: bio,
      avatarUrl: avatarUrl ?? currentUser.avatarUrl,
    );
    notifyListeners();
  }
}
