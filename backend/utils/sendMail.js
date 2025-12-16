const nodemailer = require('nodemailer');

const SendMailer = async(mailOptions) => {
    const transporter = nodemailer.createTransport({
        host: 'smtp.gmail.com',
        port: 587,
        secure: false,
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASSWORD
        }
    });

    try {
        const info = await transporter.sendMail(mailOptions);
        console.log("✉️  Email gönderildi:", info.response);
        return true;
    } catch (error) {
        console.error("❌ Email gönderilemedi:", error);
        return false;
    }
};

module.exports = SendMailer;
