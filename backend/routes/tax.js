const express = require('express');
const TaxReport = require('../models/TaxReport');
const auth = require('../middleware/auth');
const router = express.Router();

// Get all tax reports for logged in user
router.get('/', auth, async (req, res) => {
    try {
        const reports = await TaxReport.find({ userId: req.user }).populate('companyId', 'name');
        res.json(reports);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
});

// Calculate and generate a tax report
router.post('/generate', auth, async (req, res) => {
    try {
        const { companyId, taxYear, income, deductions, rawQueryData } = req.body;

        // Really basic tax calculation logic for demonstration
        const netIncome = income - deductions;
        let estimatedTax = 0;

        if (netIncome > 0) {
            // flat 20% estimated tax
            estimatedTax = netIncome * 0.20;
        }

        const report = new TaxReport({
            userId: req.user,
            companyId: companyId || null,
            taxYear,
            totalIncome: income,
            totalDeductions: deductions,
            estimatedTaxOwed: estimatedTax,
            filingStatus: 'Review',
            rawQueryData
        });

        await report.save();

        res.json(report);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
});

module.exports = router;
