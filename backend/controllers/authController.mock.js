const crypto = require('crypto');

// Mock kullanıcı veritabanı (bellekte tutuluyor)
const mockUsers = [
    {
        id: 1,
        name: 'Test Kullanıcı',
        email: 'test@test.com',
        phone: '05551234567',
        password: crypto.createHash('sha256').update('Test123!').digest('hex'), // Test123!
        createdAt: new Date().toISOString()
    }
];

// Şifre hash'leme
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

// Kayıt olma (Mock)
exports.register = async (req, res) => {
    try {
        const { name, email, phone, password } = req.body;

        // Validasyon
        if (!name || !email || !password) {
            return res.status(400).json({ 
                message: 'Ad, email ve şifre gereklidir' 
            });
        }

        if (password.length < 8) {
            return res.status(400).json({ 
                message: 'Şifre en az 8 karakter olmalıdır' 
            });
        }

        // Email zaten var mı kontrol et
        const existingUser = mockUsers.find(u => u.email === email);
        if (existingUser) {
            return res.status(400).json({ 
                message: 'Bu email zaten kayıtlı' 
            });
        }

        // Telefon zaten var mı kontrol et
        if (phone) {
            const existingPhone = mockUsers.find(u => u.phone === phone);
            if (existingPhone) {
                return res.status(400).json({ 
                    message: 'Bu telefon numarası zaten kayıtlı' 
                });
            }
        }

        // Yeni kullanıcı oluştur
        const newUser = {
            id: mockUsers.length + 1,
            name,
            email,
            phone: phone || null,
            password: hashPassword(password),
            createdAt: new Date().toISOString()
        };

        mockUsers.push(newUser);

        // Token (basit bir token simülasyonu)
        const token = `mock-token-${newUser.id}-${Date.now()}`;

        return res.status(201).json({
            token,
            user: {
                id: newUser.id,
                name: newUser.name,
                email: newUser.email,
                phone: newUser.phone,
                createdAt: newUser.createdAt
            }
        });

    } catch (err) {
        console.error('Kayıt hatası:', err);
        return res.status(500).json({ 
            message: 'Kayıt sırasında hata oluştu',
            error: err.message 
        });
    }
};

// Giriş yapma (Mock)
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validasyon
        if (!email || !password) {
            return res.status(400).json({ 
                message: 'Email ve şifre gereklidir' 
            });
        }

        // Kullanıcıyı bul
        const user = mockUsers.find(u => u.email === email);

        if (!user) {
            return res.status(401).json({ 
                message: 'Email veya şifre hatalı' 
            });
        }

        // Şifre kontrolü
        const hashedPassword = hashPassword(password);
        if (user.password !== hashedPassword) {
            return res.status(401).json({ 
                message: 'Email veya şifre hatalı' 
            });
        }

        // Token (basit bir token simülasyonu)
        const token = `mock-token-${user.id}-${Date.now()}`;

        // Başarılı giriş
        return res.status(200).json({
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                createdAt: user.createdAt
            }
        });

    } catch (err) {
        console.error('Giriş hatası:', err);
        return res.status(500).json({ 
            message: 'Giriş sırasında hata oluştu',
            error: err.message 
        });
    }
};

// Mock kullanıcıları görüntüleme (test için)
exports.getAllUsers = (req, res) => {
    const usersWithoutPasswords = mockUsers.map(u => ({
        id: u.id,
        name: u.name,
        email: u.email,
        phone: u.phone,
        createdAt: u.createdAt
    }));
    res.json({ users: usersWithoutPasswords });
};
