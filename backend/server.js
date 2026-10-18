
const express = require('express');
const mongoose = require('mongoose');
require('dotenv').config();

// Import routes
const foodRoutes = require('./routes/foodRoutes');
const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json({ limit: '100kb' }));

// Root route
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to the RePlate API!',
  });
});

// Health check route
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    database:
      mongoose.connection.readyState === 1
        ? 'connected'
        : 'disconnected',
  });
});

// Food routes
app.use('/api/food', foodRoutes);

// Authentication routes
app.use('/api/auth', authRoutes);

// Start server after connecting to MongoDB
async function startServer() {
  try {
    // Check MongoDB configuration
    if (!process.env.MONGODB_URI) {
      throw new Error(
        'MONGODB_URI is missing from backend/.env'
      );
    }

    // Check JWT configuration
    if (
      !process.env.JWT_SECRET ||
      process.env.JWT_SECRET.length < 32
    ) {
      throw new Error(
        'A strong JWT_SECRET is required in backend/.env'
      );
    }

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);

    console.log('MongoDB connected successfully!');

    // Start Express server
    app.listen(PORT, '0.0.0.0', () => {
      console.log(
        `RePlate API running at http://localhost:${PORT}`
      );
    });
  } catch (error) {
    console.error(
      'Backend startup failed:',
      error.message
    );

    process.exit(1);
  }
}

startServer();
