import { getCodeForEmail, invalidateCodeForEmail } from './check-email';

export default async function (req, res) {
    if (req.method !== 'POST') return res.status(405).end();

    const { email, code } = req.body;
    if (!email || !code) return res.status(400).json({ error: "Missing email or code" });

    const storedCode = getCodeForEmail(email);
    if (!storedCode) return res.status(400).json({ error: "Code expired or not found" });

    if (storedCode !== code) return res.status(400).json({ error: "Invalid code" });

    invalidateCodeForEmail(email); // one-time use
    return res.status(200).json({ verified: true });
}
