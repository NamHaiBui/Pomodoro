import express, { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';
import { FirebaseError } from 'firebase/app';

const router = express.Router();
const db = admin.firestore();

// GET all ongoing sessions
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const snapshot = await db.collection('ongoingSessions').get();
    const ongoingSessions = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(ongoingSessions); 
  } catch (error: any) {
    next(error); // Pass to error handler
  }
});

// POST a new ongoing session
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const session = {
      ...req.body,
      startTime: admin.firestore.FieldValue.serverTimestamp()
    };
    const docRef = await db.collection('ongoingSessions').add(session);
    res.status(201).json({ id: docRef.id, message: 'Ongoing session created successfully' }); 
  } catch (error: any) {
    next(error);
  }
});

// GET an ongoing session by ID
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doc = await db.collection('ongoingSessions').doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ message: 'Ongoing session not found' }); // 404 Not Found
    }
    res.status(200).json({ id: doc.id, ...doc.data() }); // 200 OK
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid ongoing session ID format.' }); // 400 Bad Request
    }
    next(error);
  }
});

// PUT (update) an ongoing session by ID - to set endTime
router.put('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (Object.keys(req.body).length === 0) {
      return res.status(400).json({ message: 'Request body cannot be empty for update.' }); // 400 Bad Request
    }

    await db.collection('ongoingSessions').doc(req.params.id).update(req.body);
    res.status(200).json({ message: 'Ongoing session updated successfully' }); // 200 OK
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid ongoing session ID format.' }); // 400 Bad Request
    }
    next(error);
  }
});

// DELETE an ongoing session by ID
router.delete('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await db.collection('ongoingSessions').doc(req.params.id).delete();
    res.status(204).json({ message: 'Ongoing session deleted successfully' });  // 204 No Content
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid ongoing session ID format.' }); // 400 Bad Request
    }
    next(error);
  }
});

export default router;
