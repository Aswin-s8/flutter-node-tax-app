require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/flutter_node_app';
mongoose.connect(mongoURI).then(() => console.log('MongoDB connected'))
    .catch(err => console.error(err));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/onboarding', require('./routes/onboarding'));
app.use('/api/companies', require('./routes/company'));
app.use('/api/taxes', require('./routes/tax'));

const todoRoutes = require('./routes/todos');
app.use('/api/todos', todoRoutes);

// Basic Route
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to the Flutter + Node.js API' });
});

// Start Server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
