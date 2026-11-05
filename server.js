const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// In-memory data store (replaced by a real database in Stage 6)
let items = [{ id: 1, name: 'first item' }];
let nextId = 2;

// Health check (used by load balancers later)
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/items', (req, res) => {
  res.json(items);
});

app.get('/items/:id', (req, res) => {
  const item = items.find((i) => i.id === Number(req.params.id));
  if (!item) return res.status(404).json({ error: 'Item not found' });
  res.json(item);
});

app.post('/items', (req, res) => {
  const name = req.body && req.body.name;
  if (typeof name !== 'string' || name.trim() === '') {
    return res.status(400).json({ error: 'name is required' });
  }
  const item = { id: nextId++, name: name.trim() };
  items.push(item);
  res.status(201).json(item);
});

app.delete('/items/:id', (req, res) => {
  const id = Number(req.params.id);
  const before = items.length;
  items = items.filter((i) => i.id !== id);
  if (items.length === before) {
    return res.status(404).json({ error: 'Item not found' });
  }
  res.status(204).end();
});

// Unknown route -> JSON 404
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Errors (e.g. invalid JSON body) -> JSON, not HTML
app.use((err, req, res, next) => {
  const status = err.status || 500;
  res.status(status).json({ error: status === 500 ? 'Internal server error' : err.message });
});

const server = app.listen(PORT, () => {
  console.log(`API listening on port ${PORT}`);
});

// Clean shutdown when a container is stopped
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down');
  server.close(() => process.exit(0));
});