
const express = require('express');
const mongoose = require('mongoose');
const FoodDonation = require('../models/FoodDonation');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

const HOTEL_ROLE = 'Hotel / Restaurant';
const NGO_ROLE = 'NGO / Organization';

// ========================================
// GET AVAILABLE FOOD DONATIONS
// GET /api/food
// Public: used by NGO Discover
// ========================================
router.get('/', async (req, res) => {
  try {
    const foods = await FoodDonation.find({
      status: 'available',
      expiresAt: { $gt: new Date() },
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      data: foods,
    });
  } catch (error) {
    console.error('Fetch food error:', error.message);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch available food donations.',
    });
  }
});

// ========================================
// GET MY HOTEL DONATIONS
// GET /api/food/mine
// ========================================
router.get('/mine', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== HOTEL_ROLE) {
      return res.status(403).json({
        success: false,
        message: 'Only hotel accounts can access this dashboard.',
      });
    }

    const foods = await FoodDonation.find({
      owner: req.user.userId,
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      data: foods,
    });
  } catch (error) {
    console.error('Fetch hotel donations error:', error.message);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch your donations.',
    });
  }
});

// ========================================
// GET MY ACCEPTED DONATIONS
// GET /api/food/accepted
// NGO only
// ========================================
router.get('/accepted', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== NGO_ROLE) {
      return res.status(403).json({
        success: false,
        message: 'Only NGO accounts can view accepted donations.',
      });
    }

    const foods = await FoodDonation.find({
      claimedBy: req.user.userId,
      status: { $in: ['claimed', 'collected'] },
    }).sort({ claimedAt: -1 });

    return res.status(200).json({
      success: true,
      data: foods,
    });
  } catch (error) {
    console.error('Fetch accepted donations error:', error.message);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch accepted donations.',
    });
  }
});

// ========================================
// CREATE FOOD DONATION
// POST /api/food
// Hotel only
// ========================================
router.post('/', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== HOTEL_ROLE) {
      return res.status(403).json({
        success: false,
        message: 'Only hotel accounts can publish food donations.',
      });
    }

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

    // Only accept permitted fields from the request.
    // Ownership and tracking fields are controlled by the server.
    const food = await FoodDonation.create({
      name: foodData.name,
      peopleCount: foodData.peopleCount,
      category: foodData.category,
      providerName: foodData.providerName,
      location: foodData.location,
      description: foodData.description,
      expiresAt: foodData.expiresAt,
      latitude: foodData.latitude,
      longitude: foodData.longitude,
      owner: req.user.userId,
      status: 'available',
      claimedBy: null,
      claimedAt: null,
      collectedAt: null,
    });

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
// ACCEPT A DONATION
// PATCH /api/food/:id/accept
// NGO only
// ========================================
router.patch('/:id/accept', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== NGO_ROLE) {
      return res.status(403).json({
        success: false,
        message: 'Only NGO accounts can accept donations.',
      });
    }

    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food donation ID.',
      });
    }

    const now = new Date();

    // Atomic update: only one NGO can claim an available donation.
    const food = await FoodDonation.findOneAndUpdate(
      {
        _id: id,
        status: 'available',
        expiresAt: { $gt: now },
      },
      {
        $set: {
          status: 'claimed',
          claimedBy: req.user.userId,
          claimedAt: now,
          collectedAt: null,
        },
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!food) {
      return res.status(409).json({
        success: false,
        message:
          'This donation is no longer available or has expired.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Donation accepted successfully.',
      data: food,
    });
  } catch (error) {
    console.error('Accept donation error:', error.message);

    return res.status(500).json({
      success: false,
      message: 'Failed to accept donation.',
    });
  }
});

// ========================================
// MARK A DONATION AS COLLECTED
// PATCH /api/food/:id/collect
// Only the accepting NGO can do this.
// ========================================
router.patch('/:id/collect', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== NGO_ROLE) {
      return res.status(403).json({
        success: false,
        message: 'Only NGO accounts can update collection status.',
      });
    }

    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food donation ID.',
      });
    }

    const food = await FoodDonation.findOneAndUpdate(
      {
        _id: id,
        claimedBy: req.user.userId,
        status: 'claimed',
      },
      {
        $set: {
          status: 'collected',
          collectedAt: new Date(),
        },
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!food) {
      return res.status(409).json({
        success: false,
        message:
          'Donation not found, not assigned to you, or already collected.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Donation marked as collected.',
      data: food,
    });
  } catch (error) {
    console.error('Mark collected error:', error.message);

    return res.status(500).json({
      success: false,
      message: 'Failed to update collection status.',
    });
  }
});

// ========================================
// DELETE MY DONATION
// DELETE /api/food/:id
// Hotel owner only
// ========================================
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== HOTEL_ROLE) {
      return res.status(403).json({
        success: false,
        message: 'Only hotel accounts can delete donations.',
      });
    }

    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food donation ID.',
      });
    }

    // Prevent deletion after an NGO has accepted the donation.
    const deletedFood = await FoodDonation.findOneAndDelete({
      _id: id,
      owner: req.user.userId,
      status: 'available',
    });

    if (!deletedFood) {
      return res.status(404).json({
        success: false,
        message:
          'Available donation not found or it cannot be deleted because it has already been accepted.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Food donation deleted successfully.',
      data: {
        id: deletedFood._id,
      },
    });
  } catch (error) {
    console.error('Delete food error:', error.message);

    return res.status(500).json({
      success: false,
      message: 'Failed to delete food donation.',
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
