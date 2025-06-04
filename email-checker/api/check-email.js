import { initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

// Only initialize once
const app = initializeApp({
    credential: cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.PRIVATE_KEY.replace(/\\n/g, '\n'),
    }),

});

export default async function handler(req, res) {
    const { email } = req.query;

    if (!email) return res.status(400).json({ error: "Missing email" });

    try {
        const user = await getAuth().getUserByEmail(email);
        return res.status(200).json({ exists: true, uid: user.uid });
    } catch (err) {
        if (err.code === "auth/user-not-found") {
            return res.status(200).json({ exists: false });
        } else {
            return res.status(500).json({ error: err.message });
        }
    }
}
