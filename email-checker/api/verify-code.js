import { getCodeForEmail, invalidateCodeForEmail } from './send-code.js';

export default async function handler(req, res) {
    if (req.method !== 'POST') return res.status(405).end();

    const { email, code } = req.body || {};
    if (!email || !code) {
        return res.status(400).json({ error: "Missing email or code" });
    }

    try {
        const storedCode = getCodeForEmail(email);
        if (!storedCode) {
            return res.status(400).json({ error: "Code expired or not found" });
        }

        if (storedCode !== code) {
            return res.status(400).json({ error: "Invalid code" });
        }

        // Invalidate the code after successful match
        invalidateCodeForEmail(email);
        return res.status(200).json({ verified: true });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
}
