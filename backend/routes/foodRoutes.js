
const express = require('express');
const mongoose = require('mongoose');
const FoodDonation = require('../models/FoodDonation');

const router = express.Router();

// ========================================
// GET ALL FOOD DONATIONS
// GET /api/food
// ========================================
router.get('/', async (req, res) => {
  try {
    const foods = await FoodDonation.find()
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      data: foods,
    });
  } catch (error) {
    console.error('Fetch food error:', error.message);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch food donations.',
    });
  }
});

// ========================================
// CREATE FOOD DONATION
// POST /api/food
// ========================================
router.post('/', async (req, res) => {
  try {
    const foodData = req.body;

    if (
      !foodData ||
      typeof foodData !== 'object' ||
      Array.isArray(foodData)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Please provide valid food donation data.',
      });
    }

    const food = await FoodDonation.create(foodData);

    return res.status(201).json({
      success: true,
      message: 'Food donation created successfully.',
      data: food,
    });
  } catch (error) {
    console.error('Create food error:', error.message);

    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: 'Food donation validation failed.',
        errors: Object.values(error.errors).map(
          (item) => item.message
        ),
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to create food donation.',
    });
  }
});

// ========================================
// GET FOOD DONATION BY ID
// GET /api/food/:id
// ========================================
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food donation ID.',
      });
    }

    const food = await FoodDonation.findById(id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food donation not found.',
      });
    }

    return res.status(200).json({
      success: true,
      data: food,
    });
  } catch (error) {
    console.error('Fetch food by ID error:', error.message);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch food donation.',
    });
  }
});

module.exports = router;
