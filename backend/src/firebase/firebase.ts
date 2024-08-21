// src/firebase.ts
import admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

const serviceAccount = require(process.env.PATH_TO_SAK as string);

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET as string,
});

export default admin;