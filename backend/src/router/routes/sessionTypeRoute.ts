import express, { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';
import { FirebaseError } from 'firebase/app';
import { SessionType } from '../../models/models';

const router = express.Router();
const db = admin.firestore();

// GET all session types
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const snapshot = await db.collection('sessionTypes').get();
    const sessionTypes: SessionType[] = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() as SessionType }));
    res.status(200).json(sessionTypes);
  } catch (error: any) {
    next(error);
  }
});

// POST a new session type
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { name, duration, description } = req.body;

    if (!name || typeof name !== 'string' || !duration || typeof duration !== 'number') {
      return res.status(400).json({ message: 'Invalid or missing name or duration' });
    }

    // Validate description if provided
    if (description && typeof description !== 'string') {
      return res.status(400).json({ message: 'Invalid description format' });
    }

    const newSessionType: SessionType = {
      name,
      duration,
      description, // Include description if provided
      // Add any additional properties from req.body if needed
      ...req.body
    };

    const docRef = await db.collection('sessionTypes').add(newSessionType);

    res.status(201).json({ id: docRef.id, message: 'Session type created successfully' });
  } catch (error: any) {
    next(error);
  }
});

// GET a session type by ID
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doc = await db.collection('sessionTypes').doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Session type not found' });
    }

    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid session type ID format.' });
    }
    next(error);
  }
});

// PUT (update) a session type by ID
router.put('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (Object.keys(req.body).length === 0) {
      return res.status(400).json({ message: 'Request body cannot be empty for update.' });
    }

    // You might add additional validation here for the updated data, 
    // including checking if 'description' is provided and is a string

    await db.collection('sessionTypes').doc(req.params.id).update(req.body);

    res.status(200).json({ message: 'Session type updated successfully' });
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid session type ID format.' });
    }
    next(error);
  }
});

// DELETE a session type by ID
router.delete('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await db.collection('sessionTypes').doc(req.params.id).delete();

    res.status(204).send(); // 204 No Content for successful deletion
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid session type ID format.' });
    }
    next(error);
  }
});

export default router;