
const mongoose = require('mongoose');

const foodDonationSchema = new mongoose.Schema(
  {
    // Basic food donation details
    name: {
      type: String,
      required: [true, 'Food name is required.'],
      trim: true,
    },

    peopleCount: {
      type: Number,
      required: [true, 'Number of people is required.'],
      min: [1, 'People count must be at least 1.'],
    },

    category: {
      type: String,
      required: [true, 'Food category is required.'],
      enum: ['Meals', 'Snacks', 'Bakery', 'Fruits', 'Other'],
      default: 'Meals',
    },

    providerName: {
      type: String,
      required: [true, 'Provider name is required.'],
      trim: true,
    },

    location: {
      type: String,
      required: [true, 'Pickup location is required.'],
      trim: true,
    },

    description: {
      type: String,
      default: '',
      trim: true,
    },

    // Food expiry and pickup coordinates
    expiresAt: {
      type: Date,
      required: [true, 'Food expiry time is required.'],
      index: true,
    },

    latitude: {
      type: Number,
      default: null,
    },

    longitude: {
      type: Number,
      default: null,
    },

    // Hotel account that created the donation
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
      index: true,
    },

    // Donation lifecycle
    status: {
      type: String,
      enum: ['available', 'claimed', 'collected', 'expired'],
      default: 'available',
      index: true,
    },

    // NGO account that accepted the donation
    claimedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
      index: true,
    },

    // Date when the NGO accepted the donation
    claimedAt: {
      type: Date,
      default: null,
    },

    // Date when the NGO collected the food
    collectedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

// Helpful compound index for an NGO's donation history.
foodDonationSchema.index({
  claimedBy: 1,
  status: 1,
  claimedAt: -1,
});

module.exports = mongoose.model(
  'FoodDonation',
  foodDonationSchema
);
