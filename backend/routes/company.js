const express = require('express');
const Company = require('../models/Company');
const auth = require('../middleware/auth');
const router = express.Router();

// Get all companies for logged in user
router.get('/', auth, async (req, res) => {
    try {
        const companies = await Company.find({ userId: req.user });
        res.json(companies);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
});

// Register a new company
router.post('/', auth, async (req, res) => {
    try {
        const {
            name, taxId, companyType, industry, foundingDate,
            turnover, msmeStatus, startupRecognition, employeeCount, exportPercentage
        } = req.body;

        const newCompany = new Company({
            name,
            taxId,
            companyType,
            industry,
            foundingDate,
            turnover: turnover || 0,
            msmeStatus: msmeStatus || false,
            startupRecognition: startupRecognition || false,
            employeeCount: employeeCount || 0,
            exportPercentage: exportPercentage || 0,
            userId: req.user
        });

        const company = await newCompany.save();
        res.json(company);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
});

module.exports = router;
