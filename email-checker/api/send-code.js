import { getAuth } from "firebase-admin/auth";
import { initializeApp, cert } from "firebase-admin/app";
import nodemailer from "nodemailer";

const app = initializeApp({
    credential: cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.PRIVATE_KEY.replace(/\\n/g, '\n'),
    }),
});

// Memory cache
const codeMap = new Map();

function generateCode(length = 8) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return Array.from({ length }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
}

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS,
    },
});

export default async function handler(req, res) {
    const { email } = req.body || {}; // Fix: handle undefined req.body
    if (!email) return res.status(400).json({ error: "Missing email" });

    try {
        exists
        const user = await getAuth().getUserByEmail(email);

        const code = generateCode();
        codeMap.set(email, code);
        setTimeout(() => codeMap.delete(email), 5 * 60 * 1000); // expire in 5 min

        await transporter.sendMail({
            from: `"Your App" <${process.env.MAIL_USER}>`,
            to: email,
            subject: "Your Password Reset Code",
            text: `Here's your password reset code: ${code}`,
            html: `<p>Here's your <b>password reset code</b>: <code>${code}</code></p>`,
        });

        return res.status(200).json({ success: true });
    } catch (err) {
        if (err.code === "auth/user-not-found") {
            return res.status(200).json({ exists: false });
        }
        return res.status(500).json({ error: err.message });
    }
}

export function getCodeForEmail(email) {
    return codeMap.get(email);
}

export function invalidateCodeForEmail(email) {
    codeMap.delete(email);
}
