const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');
const router = express.Router();

// Update user personalization profile
router.post('/', auth, async (req, res) => {
    try {
        const { ownsBusiness, expectedCompaniesCount, primaryFilingCategory, industry, requiresAccountant } = req.body;

        let user = await User.findById(req.user);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.ownsBusiness = ownsBusiness || user.ownsBusiness;
        user.expectedCompaniesCount = expectedCompaniesCount || user.expectedCompaniesCount;
        user.primaryFilingCategory = primaryFilingCategory || user.primaryFilingCategory;
        user.industry = industry || user.industry;
        user.requiresAccountant = requiresAccountant !== undefined ? requiresAccountant : user.requiresAccountant;

        // Mark as completed
        user.onboardingCompleted = true;

        await user.save();

        res.json(user);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
});

module.exports = router;
