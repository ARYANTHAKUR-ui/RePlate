
const mongoose = require('mongoose');

const foodDonationSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },
    peopleCount: {
      type: Number,
      required: true,
      min: 1,
    },
    category: {
      type: String,
      required: true,
      enum: ['Meals', 'Snacks', 'Bakery', 'Fruits', 'Other'],
    },
    providerName: {
      type: String,
      required: true,
      trim: true,
    },
    location: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
      maxlength: 1000,
    },
    expiresAt: {
      type: Date,
      required: true,
    },
    latitude: {
      type: Number,
      default: null,
      min: -90,
      max: 90,
    },
    longitude: {
      type: Number,
      default: null,
      min: -180,
      max: 180,
    },
    status: {
      type: String,
      enum: ['available', 'claimed', 'collected', 'expired'],
      default: 'available',
    },
  },
  {
    timestamps: true,
  }
);

const FoodDonation = mongoose.model(
  'FoodDonation',
  foodDonationSchema
);

module.exports = FoodDonation;
