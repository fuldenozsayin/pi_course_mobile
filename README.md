# 📱 Pi Course — Mobil Uygulama (Flutter)

Öğrencilerin eğitmenleri bulup **ders talebi** oluşturabildiği Flutter tabanlı mobil uygulama.<br/>
Backend: **Django + DRF** projesi için [pi-course-backend](https://github.com/fuldenozsayin/pi-course-backend) reposuna bakabilirsiniz.

---

## 🧭 İçindekiler

- [Repo Yapısı](#repo-yapisi)
- [Özellikler](#ozellikler)
- [Kurulum & Çalıştırma](#kurulum-calistirma)
- [ENV / Backend Adresi](#env-backend-adresi)
- [Dizin Yapısı](#dizin-yapisi)
- [Mimari Notlar](#mimari-notlar)
- [Kullandığımız Ek Kütüphaneler ve Nedenleri](#kutuphaneler-ve-nedenleri)
- [Artı Puan Durumu (Frontend)](#arti-puan-durumu-frontend)
- [Testler](#testler)
- [Kod Referansları](#kod-referanslari)
- [Ekran Görselleri](#ekran-gorselleri)
- [Demo Hesaplar](#demo-hesaplar)
- [Kalanlar / Trade-off’lar](#kalanlar-trade-offlar)



---

## <h2 id="repo-yapisi">Repo Yapısı</h2>

Bu proje **iki ayrı repo** olarak yapılandırılmıştır:
- **Backend** (Django + DRF) → [pi-course-backend](https://github.com/fuldenozsayin/pi-course-backend)
- **Mobil** (Flutter) → [pi_course_mobile](https://github.com/fuldenozsayin/pi_course_mobile)

### Neden İki Repo?
- **Bağımsız geliştirme**: Backend ve mobil ekipleri (veya tek geliştirici) birbirinden bağımsız olarak çalışabilir. Bir repo üzerinde yapılan değişiklik diğerini etkilemez.
- **Sürüm kontrolü**: Backend API’sinin versiyonlaması ile mobil uygulamanın versiyonlaması ayrı tutulur.
- **Deploy kolaylığı**: Backend sunucuya deploy edilirken mobil uygulamanın paketlenme sürecinden etkilenmez.
- **Daha temiz commit geçmişi**: Backend ve mobil değişiklikleri aynı commit geçmişinde karışmaz, kod inceleme süreçleri sadeleşir.
- **Test ve CI/CD ayrımı**: Her repo kendi test sürecine ve CI/CD pipeline’ına sahip olabilir.

---

## <h2 id="ozellikler">✨ Özellikler</h2>

* 🔑 **Kayıt & Giriş**: Öğrenci/Eğitmen rol seçimi, JWT ile güvenli oturum
* 📚 **Eğitmen Listesi**: Filtre (subject), arama (ad/bio), sıralama (rating), **sonsuz kaydırma**
* 👤 **Eğitmen Detayı**: Bilgiler + “Ders Talep Et” akışı
* 📝 **Ders Talebi Oluşturma**: Konu, tarih/saat, süre, opsiyonel not
* 📋 **Taleplerim**: Öğrenci – kendi talepleri | Eğitmen – gelen talepler (onay/ret)
* 🔄 **Pull-to-refresh**
* 🔒 **Token Saklama** (güvenli depolama)
* ⚠️ Boş/Yükleniyor/Hata durumlarına uygun UI

---

## <h2 id="kurulum-calistirma">🚀 Kurulum & Çalıştırma</h2>

1. Flutter sürümünü kontrol et

```bash
flutter --version
```

2. Bağımlılıkları yükle

```bash
flutter pub get
```

3. Backend adresini ayarla (bkz. [ENV / Backend Adresi](#-env--backend-adresi))

4. Çalıştır

```bash
flutter run
```

> 🧩 Model kod üretimi gerekiyorsa:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## <h2 id="env-backend-adresi">⚙️ ENV / Backend Adresi</h2>

`lib/core/env.dart` dosyasında `baseUrl` değerini güncelle:

```dart
// Geliştirme (localhost)
const baseUrl = "http://127.0.0.1:8000/api";

// Android emülatöründe localhost
// const baseUrl = "http://10.0.2.2:8000/api";
```

---

## <h2 id="dizin-yapisi">🗂 Dizin Yapısı</h2>

```
lib/
├─ core/                   # api_client.dart, env.dart, storage.dart
├─ features/
│  ├─ auth/               # giriş/kayıt (model, repo, provider, UI)
│  ├─ lessons/            # ders talepleri (öğrenci/eğitmen)
│  ├─ subjects/           # ders konuları
│  └─ tutors/             # eğitmen listesi, detay, kurs düzenleme (+ sonsuz kaydırma)
├─ app.dart               # uygulama kökü
└─ main.dart              # başlangıç
```

---

## <h2 id="mimari-notlar">🧱 Mimari Notlar</h2>

* **Feature-based** modüler yapı (`data / presentation / providers`)
* **Repository Pattern**: UI yalnızca provider’larla konuşur; API erişimi repository’lerde soyutlanır
* **Riverpod** ile tip güvenli, test edilebilir state yönetimi
* **Dio + Interceptor**: tek noktadan yetkilendirme başlığı, hata yakalama
* **Sayfalama**: DRF `limit/offset` + `count/results`; **Eğitmen Listesi** ekranında **sonsuz kaydırma** aktif

---

## <h2 id="kutuphaneler-ve-nedenleri">🧩 Kullandığımız Ek Kütüphaneler ve Nedenleri</h2>

| Paket                                     | Amaç             | Neden                                                  |
| ----------------------------------------- | ---------------- | ------------------------------------------------------ |
| **flutter\_riverpod**                     | Durum yönetimi   | Reaktif akış, **tip güvenliği**, kolay test            |
| **dio**                                   | HTTP istemcisi   | Interceptor, kapsamlı hata yönetimi, esnek istek/yanıt |
| **json\_annotation + json\_serializable** | Model ⇄ JSON     | **Kod üretimi** ile güvenilir dönüşüm, az boilerplate  |
| **build\_runner**                         | Codegen komutu   | json\_serializable için derleme zamanı üretim          |
| **flutter\_secure\_storage**              | Güvenli depolama | Erişim/yenileme token’larını **güvenli** saklama       |

> Not: Pubspec sürümleri projeye göre tanımlıdır.

---

## <h2 id="arti-puan-durumu-frontend">✅ Artı Puan Durumu (Frontend)</h2>

* 🔄 **Pull-to-refresh** → **Var** (`RefreshIndicator`)
* ♾️ **Sonsuz kaydırma (pagination)** → **Var** (Eğitmen listesinde `ScrollController + loadMore`, DRF `limit/offset`)

---

## <h2 id="testler">🧪 Testler</h2>

```bash
flutter test
```

Model değişikliği sonrası:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## <h2 id="kod-referanslari">🧷 Kod Referansları</h2>

**Çekirdek**

* `lib/core/api_client.dart`, `lib/core/env.dart`, `lib/core/storage.dart`

**Auth**

* `features/auth/data/models/auth_tokens.dart`, `user.dart`, `user.g.dart`
* `features/auth/data/auth_repository.dart`, `features/auth/providers.dart`
* `features/auth/presentation/login_page.dart`, `register_page.dart`, `me_page.dart`

**Lessons**

* `features/lessons/data/models/lesson_request.dart`, `lesson_request.g.dart`
* `features/lessons/data/lesson_repository.dart`, `features/lessons/providers.dart`
* `features/lessons/presentation/lesson_request_page.dart`, `my_requests_page.dart`, `incoming_requests_page.dart`

**Subjects**

* `features/subjects/data/models/subject.dart`, `subject.g.dart`
* `features/subjects/data/subject_repository.dart`, `features/subjects/providers.dart`

**Tutors**

* `features/tutors/data/models/tutor.dart`, `tutor.g.dart`
* `features/tutors/data/tutor_repository.dart` (liste, detay, profil, subject list, güncelleme)
* `features/tutors/providers.dart` (sonsuz kaydırma için `StateNotifier`)
* `features/tutors/presentation/tutor_list_page.dart` (**sonsuz kaydırma**)
* `features/tutors/presentation/tutor_detail_page.dart`
* `features/tutors/presentation/tutor_courses_page.dart`, `tutor_course_editor_page.dart`

---

## <h2 id="ekran-gorselleri">🖼 Ekran Görselleri</h2>

<table align="center">
  <tr>
    <td align="center">
      <img src="https://github.com/fuldenozsayin/pi_course_mobile/docs/screens/giris_ekrani.png" alt="Giriş Ekranı" width="220"/><br>
      <em>Giriş Ekranı</em>
    </td>
    <td align="center">
      <img src="https://github.com/fuldenozsayin/pi_course_mobile/docs/screens/egitmen_listesi_ekrani.png" alt="Eğitmen Listesi" width="220"/><br>
      <em>Eğitmen Listesi</em>
    </td>
    <td align="center">
      <img src="https://github.com/fuldenozsayin/pi_course_mobile/docs/screens/egitmen_detayi_ekrani.png" alt="Eğitmen Detayı" width="220"/><br>
      <em>Eğitmen Detayı</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/fuldenozsayin/pi_course_mobile/docs/screens/ders_talebi_olusturma_ekrani.png" alt="Ders Talebi Oluşturma" width="220"/><br>
      <em>Ders Talebi Oluşturma</em>
    </td>
    <td align="center">
      <img src="https://github.com/fuldenozsayin/pi_course_mobile/docs/screens/student_talepler.png" alt="Öğrenci Talepleri" width="220"/><br>
      <em>Öğrenci Talepleri</em>
    </td>
    <td align="center">
      <img src="https://github.com/fuldenozsayin/pi_course_mobile/docs/screens/tutor_taleplerin_hepsi.png" alt="Eğitmen Gelen Ders Talepleri" width="220"/><br>
      <em>Eğitmen Gelen Ders Talepleri</em>
    </td>
  </tr>
</table>

---

## <h2 id="demo-hesaplar">🔐 Demo Hesaplar</h2>

* Öğrenci: `student@demo.com` / `Passw0rd!`
* Eğitmen: `tutor@demo.com` / `Passw0rd!`

---

## <h2 id="kalanlar-trade-offlar">🧭 Kalanlar / Trade-off’lar</h2>

* **UI** piksel mükemmel hedeflenmedi; MVP odaklı
* **Basit CI (GitHub Actions)** ile testlerin otomatik çalışması.
