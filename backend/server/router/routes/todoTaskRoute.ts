import express, { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';
import { FirebaseError } from 'firebase/app';
import { TodoTask } from '../../models/models';

const router = express.Router();
const db = admin.firestore();


// Helper function to validate TodoTask
function isValidTodoTask(data: any): data is TodoTask {
    return typeof data.title === 'string' && typeof data.completed === 'boolean';
}

// GET all TODO tasks
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
    try {
        const snapshot = await db.collection('todoTasks').get();
        const todoTasks = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(todoTasks);
    } catch (error: any) {
        next(error);
    }
});

// POST a new TODO task
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
    try {
        if (!isValidTodoTask(req.body)) {
            return res.status(400).json({ message: 'Invalid TODO task data. Title and completed fields are required.' });
        }

        const docRef = await db.collection('todoTasks').add(req.body);
        res.status(201).json({ id: docRef.id, message: 'TODO task created successfully' });
    } catch (error: any) {
        next(error);
    }
});

// GET a TODO task by ID
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
    try {
        const doc = await db.collection('todoTasks').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({ message: 'TODO task not found' });
        }
        res.status(200).json({ id: doc.id, ...doc.data() });
    } catch (error: any) {
        if ((error as FirebaseError).code === 'invalid-argument') {
            return res.status(400).json({ message: 'Invalid TODO task ID format.' });
        }
        next(error);
    }
});

// PUT (update) a TODO task by ID
router.put('/:id', async (req: Request, res: Response, next: NextFunction) => {
    try {
        if (Object.keys(req.body).length === 0) {
            return res.status(400).json({ message: 'Request body cannot be empty for update.' });
        }

        // Validate the updated data (you might want to be more flexible here depending on your use case)
        if (!isValidTodoTask(req.body)) {
            return res.status(400).json({ message: 'Invalid TODO task data. Title and completed fields are required.' });
        }

        await db.collection('todoTasks').doc(req.params.id).update(req.body);

        res.status(200).json({ message: 'TODO task updated successfully' });
    } catch (error: any) {
        if ((error as FirebaseError).code === 'invalid-argument') {
            return res.status(400).json({ message: 'Invalid TODO task ID format.' });
        }
        next(error);
    }
});

// DELETE a TODO task by ID
router.delete('/:id', async (req: Request, res: Response, next: NextFunction) => {
    try {
        await db.collection('todoTasks').doc(req.params.id).delete();
        res.status(204).send();
    } catch (error: any) {
        if ((error as FirebaseError).code === 'invalid-argument') {
            return res.status(400).json({ message: 'Invalid TODO task ID format.' });
        }
        next(error);
    }
});

export default router;