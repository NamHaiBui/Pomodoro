import express from 'express';
import admin from 'firebase-admin';

const router = express.Router();
const db = admin.firestore();

router.get('/', async (req, res, next) => {
  try {
    const snapshot = await db.collection('todoTasks').get();
    const tasks = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(tasks);
  } catch (error) {
    next(error);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const docRef = await db.collection('todoTasks').add(req.body);
    res.status(201).json({ id: docRef.id, message: 'Todo task created successfully' });
  } catch (error) {
    next(error);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const doc = await db.collection('todoTasks').doc(req.params.id).get();
    if (!doc.exists) {
      res.status(404).json({ message: 'Todo task not found' });
    } else {
      res.json({ id: doc.id, ...doc.data() });
    }
  } catch (error) {
    next(error);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    await db.collection('todoTasks').doc(req.params.id).update(req.body);
    res.json({ message: 'Todo task updated successfully' });
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await db.collection('todoTasks').doc(req.params.id).delete();
    res.json({ message: 'Todo task deleted successfully' });
  } catch (error) {
    next(error);
  }
});


export default router;