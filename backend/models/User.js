const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    // Personalization fields gathered during onboarding
    onboardingCompleted: {
        type: Boolean,
        default: false
    },
    ownsBusiness: {
        type: String,
        enum: ['Yes', 'No', 'Not_Sure_Yet'],
        default: 'Not_Sure_Yet'
    },
    expectedCompaniesCount: {
        type: Number,
        default: 0
    },
    primaryFilingCategory: {
        type: String, // e.g., 'Individual', 'Sole Proprietor', 'LLC', 'S-Corp'
        default: 'Individual'
    },
    industry: {
        type: String
    },
    requiresAccountant: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

// Hash password before saving
userSchema.pre('save', async function () {
    if (!this.isModified('password')) return;
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
});

// Method to verify password
userSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
