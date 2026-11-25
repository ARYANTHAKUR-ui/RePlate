
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

// Import routes
const foodRoutes = require('./routes/foodRoutes');
const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
// Enable cross-origin requests for Flutter Web during development.
app.use(cors());

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

    // Listen on all IPv4 interfaces so physical devices
    // can reach the backend over the local network.
    const server = app.listen(PORT, '0.0.0.0', () => {
      console.log(`RePlate API running on port ${PORT}`);
      console.log(`Local API: http://localhost:${PORT}`);
      console.log(`Health check: http://localhost:${PORT}/api/health`);
    });

    server.on('error', (error) => {
      console.error('Express server error:', error.message);
    });
  } catch (error) {
    console.error('Backend startup failed:', error.message);
    process.exit(1);
  }
}

startServer();
