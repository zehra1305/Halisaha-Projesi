const jwt = require('jsonwebtoken');

// Geçici token oluştur (şifre sıfırlama için)
const createTemporaryToken = async (userId, email) => {
    const payload = {
        userId,
        email,
    };
    
    const token = await jwt.sign(payload, process.env.TEMPORARY_TOKEN_SECRET, {
        algorithm: "HS512",
        expiresIn: "3m" // 3 dakika geçerli
    });
    
    return token;
};

// Geçici token'ı doğrula
const decodedTemporaryToken = async (temporaryToken) => {
    try {
        const decoded = await jwt.verify(temporaryToken, process.env.TEMPORARY_TOKEN_SECRET);
        return decoded; // { userId, email, iat, exp }
    } catch (err) {
        throw new Error('Geçersiz veya süresi dolmuş token');
    }
};

module.exports = { createTemporaryToken, decodedTemporaryToken };
