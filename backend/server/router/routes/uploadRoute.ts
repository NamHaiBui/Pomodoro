import express from 'express';
import admin from 'firebase-admin';
import multer from 'multer';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();
const storageConfig = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); // Specify upload directory
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + '-' + file.originalname);
    }
});
const upload = multer({
    storage: storageConfig,
    limits: { fileSize: 1024 * 1024 * 5 } // Limit to 5MB 
});

const bucket = admin.storage().bucket();

router.post('/', upload.single('file'), async (req, res, next) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No file was uploaded.' });
        }

        const fileName = `${uuidv4()}_${req.file.originalname}`;
        const fileUpload = bucket.file(fileName);

        const blobStream = fileUpload.createWriteStream({
            metadata: {
                contentType: req.file.mimetype
            }
        });

        blobStream.on('error', (error: Error) => { // Error type added here
            next(error);
        });

        blobStream.on('finish', async () => {
            const [url] = await fileUpload.getSignedUrl({
                action: 'read',
                expires: '03-01-2500'
            });

            res.status(200).json({ message: 'File uploaded successfully', url });
        });

        blobStream.end(req.file.buffer);
    } catch (error) {
        next(error);
    }
});

export default router;
