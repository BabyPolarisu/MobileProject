class AppConstants {
  static const String appName = 'UniMarket';
  static const String appTagline = 'ตลาดนัดออนไลน์ ซื้อ-ขาย ปลอดภัย สำหรับชาวมหาวิทยาลัย';

  static const List<Map<String, String>> initialCategories = [
    {'id': '1', 'name': 'หนังสือเรียน', 'icon': '📚', 'code': 'books'},
    {'id': '2', 'name': 'อิเล็กทรอนิกส์', 'icon': '💻', 'code': 'electronics'},
    {'id': '3', 'name': 'เครื่องแต่งกาย', 'icon': '👕', 'code': 'clothing'},
    {'id': '4', 'name': 'รองเท้า', 'icon': '👟', 'code': 'shoes'},
    {'id': '5', 'name': 'เครื่องประดับ', 'icon': '💍', 'code': 'accessories'},
    {'id': '6', 'name': 'ของใช้ในหอ', 'icon': '🛋️', 'code': 'dorm'},
    {'id': '7', 'name': 'อุปกรณ์การเรียน', 'icon': '📝', 'code': 'stationary'},
    {'id': '8', 'name': 'อุปกรณ์ออกกำลังกาย', 'icon': '💪🏻', 'code': 'sports'},
  ];

  static const List<Map<String, String>> reportReasons = [
    {'code': 'bug', 'name': '🐛 เว็บไซต์มีปัญหา / บั๊ก'},
    {'code': 'fraud', 'name': '💸 ฉ้อโกง / หลอกลวง'},
    {'code': 'fake', 'name': '❌ สินค้าปลอม / ลอกเลียนแบบ'},
    {'code': 'harassment', 'name': '🤬 คำหยาบคาย / คุกคาม'},
    {'code': 'spam', 'name': '📢 สแปม / โฆษณา'},
    {'code': 'other', 'name': '📝 อื่นๆ'},
  ];

  static const List<String> quickChatPrompts = [
    'สินค้านี้ยังอยู่ไหมครับ/ค่ะ?',
    'ลดราคาได้อีกไหมครับ?',
    'นัดรับที่ไหนได้บ้างครับ?',
    'ขอดูรูปภาพเพิ่มเติมหน่อยครับ',
    'ของแท้ไหมครับ?',
  ];
}
