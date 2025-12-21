const nodemailer = require('nodemailer');

const SendMailer = async(mailOptions) => {
    const transporter = nodemailer.createTransport({
        host: 'smtp.gmail.com',
        port: 587,
        secure: false,
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASSWORD
        },
        tls: {
            rejectUnauthorized: false
        }
    });

    // UTF-8 desteği için headers ekle
    const mailOptionsWithEncoding = {
        ...mailOptions,
        encoding: 'utf-8',
        textEncoding: 'base64'
    };

    try {
        const info = await transporter.sendMail(mailOptionsWithEncoding);
        console.log("✉️  Email gönderildi:", info.response);
        return true;
    } catch (error) {
        console.error("❌ Email gönderilemedi:", error);
        return false;
    }
};

module.exports = SendMailer;
