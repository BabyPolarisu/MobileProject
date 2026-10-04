from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from products.models import Category, Product, UserProfile, VerificationRequest, Review, ChatRoom, Message

class Command(BaseCommand):
    help = 'Seed initial categories, demo users, and products for UniMarket'

    def handle(self, *args, **options):
        self.stdout.write("Seeding UniMarket database...")

        # 1. Categories
        categories_data = [
            ("หนังสือเรียน", "📚"),
            ("อิเล็กทรอนิกส์", "💻"),
            ("เครื่องแต่งกาย", "👕"),
            ("รองเท้า", "👟"),
            ("เครื่องประดับ", "💍"),
            ("ของใช้ในหอ", "🛋️"),
            ("อุปกรณ์การเรียน", "📝"),
            ("อุปกรณ์ออกกำลังกาย", "🏸"),
        ]

        cat_map = {}
        for name, icon in categories_data:
            cat, _ = Category.objects.get_or_create(name=name, defaults={"icon": icon})
            cat_map[name] = cat
        self.stdout.write(f"Categories seeded: {len(cat_map)}")

        # 2. Users
        # Admin
        admin_user, created = User.objects.get_or_create(
            username="admin",
            defaults={"email": "admin@ubu.ac.th", "is_staff": True, "is_superuser": True}
        )
        if created:
            admin_user.set_password("admin1234")
            admin_user.save()
        p_admin, _ = UserProfile.objects.get_or_create(user=admin_user)
        p_admin.display_name = "ผู้ดูแลระบบ (Admin)"
        p_admin.phone_number = "045-353-000"
        p_admin.address = "สำนักงานบริการเทคโนโลยีสารสนเทศ มหาวิทยาลัยอุบลราชธานี"
        p_admin.bio = "เจ้าหน้าที่ผู้ดูแลระบบตลาดกลาง UniMarket"
        p_admin.save()

        # Somchai
        somchai, created = User.objects.get_or_create(
            username="somchai_ubu",
            defaults={"email": "somchai@ubu.ac.th"}
        )
        if created:
            somchai.set_password("somchai1234")
            somchai.save()
        p_somchai, _ = UserProfile.objects.get_or_create(user=somchai)
        p_somchai.display_name = "สมชาย เรียนดี"
        p_somchai.phone_number = "089-123-4567"
        p_somchai.address = "หอพักนักศึกษา อาคาร 3 มหาวิทยาลัยอุบลราชธานี"
        p_somchai.bio = "นักศึกษาชั้นปีที่ 3 คณะวิทยาศาสตร์ ชอบอ่านหนังสือและคอมพิวเตอร์"
        p_somchai.save()

        v_somchai, _ = VerificationRequest.objects.get_or_create(user=somchai)
        v_somchai.status = 'approved'
        v_somchai.save()

        # Thanaporn
        thanaporn, created = User.objects.get_or_create(
            username="thanaporn_k",
            defaults={"email": "thanaporn@ubu.ac.th"}
        )
        if created:
            thanaporn.set_password("thanaporn1234")
            thanaporn.save()
        p_thanaporn, _ = UserProfile.objects.get_or_create(user=thanaporn)
        p_thanaporn.display_name = "ธนพร สายช้อป"
        p_thanaporn.phone_number = "081-987-6543"
        p_thanaporn.address = "หอพักสตรีศรีอุบล"
        p_thanaporn.bio = "สินค้าทุกชิ้นใช้เอง สภาพดี ราคาแบ่งปันเพื่อนนักศึกษาค่ะ"
        p_thanaporn.save()

        v_thanaporn, _ = VerificationRequest.objects.get_or_create(user=thanaporn)
        v_thanaporn.status = 'approved'
        v_thanaporn.save()

        self.stdout.write("Users and profiles seeded.")

        # 3. Products
        products_data = [
            {
                "name": "หนังสือ Calculus 1 สำหรับวิศวะและวิทยาศาสตร์",
                "description": "สภาพ 95% ไร้รอยขีดเขียน ไฮไลท์เฉพาะบทแรกๆ เหมาะสำหรับน้องปี 1 อ่านเตรียมสอบกลางภาค",
                "price": 180.00,
                "condition": "used",
                "category": cat_map.get("หนังสือเรียน"),
                "seller": thanaporn,
            },
            {
                "name": "iPad Air 4 64GB WiFi สี Space Grey",
                "description": "เครื่องศูนย์ไทย อุปกรณ์ครบกล่อง สภาพสวย ไม่มีรอยตกหล่น แบตเตอรี่ 88% แถมเคสและฟิล์มกระจกติดแล้ว",
                "price": 11500.00,
                "condition": "used",
                "category": cat_map.get("อิเล็กทรอนิกส์"),
                "seller": thanaporn,
            },
            {
                "name": "เสื้อช็อปวิศวะ ม.อุบล ไซส์ L สภาพดี",
                "description": "เสื้อช็อปสีกรมท่า ไซส์ L รอบอก 42 นิ้ว ผ้าหนาทนทาน ซักเก็บอย่างดี ไม่มีรอยขาด",
                "price": 250.00,
                "condition": "used",
                "category": cat_map.get("เครื่องแต่งกาย"),
                "seller": somchai,
            },
            {
                "name": "เครื่องคิดเลขวิทยาศาสตร์ Casio fx-991EX",
                "description": "รุ่นยอดนิยมสำหรับสอบวิศวะและวิทยาศาสตร์ หน้าจอความละเอียดสูง ฟังก์ชันครบ ใช้งานได้ปกติทุกปุ่ม",
                "price": 590.00,
                "condition": "used",
                "category": cat_map.get("อุปกรณ์การเรียน"),
                "seller": somchai,
            },
            {
                "name": "พัดลมตั้งโต๊ะ Hatari 16 นิ้ว ลมแรงประหยัดไฟ",
                "description": "ใช้งานมา 1 เทอม สภาพดีมาก ลมแรงเงียบ เหมาะสำหรับใช้ในหอพัก ประหยัดไฟเบอร์ 5",
                "price": 350.00,
                "condition": "used",
                "category": cat_map.get("ของใช้ในหอ"),
                "seller": thanaporn,
            },
            {
                "name": "ไม้แบดมินตัน Yonex พร้อมซองใส่",
                "description": "เอ็นเพิ่งขึ้นใหม่ 24 ปอนด์ กริปใหม่ สภาพพร้อมลงคอร์ท มีรอยสะกิดเล็กน้อยจากการเล่น",
                "price": 450.00,
                "condition": "used",
                "category": cat_map.get("อุปกรณ์ออกกำลังกาย"),
                "seller": thanaporn,
            },
            {
                "name": "รองเท้าผ้าใบ Converse All Star สีขาว เบอร์ 42",
                "description": "ของแท้ 100% สภาพ 90% พื้นยังเต็ม ซักทำความสะอาดเรียบร้อย พร้อมใส่ทันที",
                "price": 850.00,
                "condition": "used",
                "category": cat_map.get("รองเท้า"),
                "seller": somchai,
            },
        ]

        for p_data in products_data:
            p, created = Product.objects.get_or_create(
                name=p_data["name"],
                defaults={
                    "description": p_data["description"],
                    "price": p_data["price"],
                    "condition": p_data["condition"],
                    "category": p_data["category"],
                    "seller": p_data["seller"],
                    "status": "active",
                }
            )

        # 4. OpenID Connect (OIDC) RSA Key & Client Setup
        from django.core.management import call_command
        from oidc_provider.models import RSAKey, Client, ResponseType

        if not RSAKey.objects.exists():
            self.stdout.write("Generating OIDC RSA Key...")
            call_command("creatersakey")
            self.stdout.write(self.style.SUCCESS("OIDC RSA Key generated."))

        oidc_client, c_created = Client.objects.get_or_create(
            client_id="unimarket-flutter",
            defaults={
                "name": "UniMarket Flutter Web App",
                "client_type": "confidential",
                "client_secret": "unimarket_secret_key",
                "jwt_alg": "RS256",
                "reuse_consent": True,
                "require_consent": False,
            }
        )
        oidc_client.client_type = "confidential"
        oidc_client.client_secret = "unimarket_secret_key"
        oidc_client._scope = "openid profile email"
        oidc_client.redirect_uris = [
            "http://localhost:50000/callback",
            "http://127.0.0.1:50000/callback",
            "http://localhost:50000",
            "http://127.0.0.1:50000",
        ]
        oidc_client.post_logout_redirect_uris = [
            "http://localhost:50000/",
            "http://127.0.0.1:50000/",
        ]
        oidc_client.save()

        code_type = ResponseType.objects.filter(value="code").first()
        if code_type and not oidc_client.response_types.filter(value="code").exists():
            oidc_client.response_types.add(code_type)

        self.stdout.write(self.style.SUCCESS(f"OIDC Client 'unimarket-flutter' ready (Redirect: http://localhost:50000/callback)"))
        self.stdout.write("Products seeded successfully.")
        self.stdout.write(self.style.SUCCESS("Database seeding completed!"))

