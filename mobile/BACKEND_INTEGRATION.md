# Backend Entegrasyon Rehberi

## 📦 Oluşturulan Dosyalar

### 1. **Services** (API İstekleri)
- `lib/services/api_service.dart` - Backend API istekleri
- `lib/services/storage_service.dart` - Token ve kullanıcı bilgilerini saklar

### 2. **Models** (Veri Modelleri)
- `lib/models/user.dart` - User model

### 3. **Providers** (State Management)
- `lib/providers/auth_provider.dart` - Authentication state yönetimi

---

## 🔧 Backend API Gereksinimleri

Node.js backend'inizin şu endpoint'leri sağlaması gerekiyor:

### **1. Login Endpoint**
```
POST /api/auth/login
```
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Success - 200):**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "name": "Ahmet Yılmaz",
    "email": "user@example.com",
    "phone": "05551234567",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Response (Error - 400/401):**
```json
{
  "message": "Email veya şifre hatalı"
}
```

---

### **2. Register Endpoint**
```
POST /api/auth/register
```
**Request Body:**
```json
{
  "name": "Ahmet Yılmaz",
  "email": "user@example.com",
  "phone": "05551234567",
  "password": "Password123!"
}
```

**Response (Success - 200/201):**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "name": "Ahmet Yılmaz",
    "email": "user@example.com",
    "phone": "05551234567",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Response (Error - 400):**
```json
{
  "message": "Bu email zaten kayıtlı"
}
```

---

### **3. Google OAuth (Opsiyonel)**
```
POST /api/auth/google
```
**Request Body:**
```json
{
  "idToken": "google_id_token"
}
```

---

### **4. Password Reset (Opsiyonel)**
```
POST /api/auth/reset-password
```
**Request Body:**
```json
{
  "email": "user@example.com"
}
```

---

## 🚀 Kullanım

### **Backend URL Ayarları**

`lib/services/api_service.dart` dosyasında:

```dart
// Local development için
static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator

// Production için
static const String baseUrl = 'https://yourdomain.com/api';
```

---

## 📱 Çalıştırma

1. **Backend'i başlatın:**
```bash
cd backend
npm start
```

2. **Flutter uygulamasını çalıştırın:**
```bash
cd mobile
flutter run
```

---

## 🔐 Güvenlik Notları

1. **HTTPS kullanın** production'da
2. **Token'ları güvenli saklayın** (SharedPreferences kullanılıyor)
3. **Password validation** client-side yapılıyor ama backend'de de kontrol edin
4. **CORS ayarlarını** yapın backend'de:

```javascript
// Node.js Express örneği
const cors = require('cors');
app.use(cors({
  origin: '*', // Development için, production'da domain belirtin
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

---

## 📝 TODO Backend Tarafında

### Express.js Örnek Router:

```javascript
// routes/auth.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Register
router.post('/register', async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    
    // Email kontrolü
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Bu email zaten kayıtlı' });
    }

    // Password hash
    const hashedPassword = await bcrypt.hash(password, 10);

    // Kullanıcı oluştur
    const user = await User.create({
      name,
      email,
      phone,
      password: hashedPassword
    });

    // JWT token oluştur
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        createdAt: user.createdAt
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Kullanıcı kontrolü
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Email veya şifre hatalı' });
    }

    // Şifre kontrolü
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Email veya şifre hatalı' });
    }

    // JWT token oluştur
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        createdAt: user.createdAt
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
```

### MongoDB User Model Örneği:

```javascript
// models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  phone: {
    type: String,
    required: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  profileImage: {
    type: String,
    default: null
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('User', userSchema);
```

---

## 🧪 Test Etme

### Postman ile test:

1. **Register:**
```
POST http://localhost:3000/api/auth/register
Content-Type: application/json

{
  "name": "Test User",
  "email": "test@test.com",
  "phone": "05551234567",
  "password": "Test123!"
}
```

2. **Login:**
```
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "test@test.com",
  "password": "Test123!"
}
```

---

## 📞 Yardım

Sorun yaşarsanız:
1. Backend loglarını kontrol edin
2. Flutter console'da hata mesajlarına bakın
3. Network inspector kullanın (Flutter DevTools)
