const express = require('express');
const crypto = require('crypto');
const path = require('path');
const TaxReport = require('../models/TaxReport');
const TaxPolicy = require('../models/TaxPolicy');
const Company = require('../models/Company');
const auth = require('../middleware/auth');
const taxEngine = require('../core/taxEngine');
const pdfService = require('../services/pdfService');

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

// Compare Regimes Endpoint
router.post('/compare', auth, async (req, res) => {
    try {
        const { taxYear, financialData } = req.body;

        // Fetch applicable policies for the given year
        const availablePolicies = await TaxPolicy.find({ taxYear });

        if (!availablePolicies || availablePolicies.length === 0) {
            return res.status(404).json({ message: 'No tax policies found for the given year' });
        }

        const comparison = await taxEngine.compareRegimes(financialData, availablePolicies);
        res.json(comparison);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error during comparison' });
    }
});

// Calculate and generate a tax report
router.post('/generate', auth, async (req, res) => {
    try {
        const { companyId, taxYear, financialData, selectedPolicyId } = req.body;

        const policy = await TaxPolicy.findOne({ policyId: selectedPolicyId });
        if (!policy) return res.status(404).json({ message: 'Selected Tax Policy not found' });

        let companyDetails = { name: 'Individual Taxpayer', taxId: 'N/A' };
        if (companyId) {
            const company = await Company.findById(companyId);
            if (company) {
                companyDetails = { name: company.name, taxId: company.taxId || 'N/A' };
            }
        }

        // Use the comparison engine for single policy to get full breakdown
        const comparison = await taxEngine.compareRegimes(financialData, [policy]);
        const result = comparison.results[0]; // The only one

        // Generate a deterministic hash for audit
        const hashPayload = JSON.stringify(result);
        const reportHash = crypto.createHash('sha256').update(hashPayload).digest('hex');

        // Create the report record
        const reportData = {
            reportId: `REP_${Date.now()}`,
            taxYear,
            regimeSelected: policy.regimeCode,
            reportHash,
            financialSummary: result
        };

        // Generate PDF
        const pdfUrl = await pdfService.generateTaxReportPDF(reportData, companyDetails);

        const dbReport = new TaxReport({
            userId: req.user,
            companyId: companyId || null,
            taxYear,
            totalIncome: result.grossRevenue,
            totalDeductions: result.totalDeductions,
            taxableIncome: result.taxableIncome,
            finalTaxLiability: result.totalTax,
            estimatedTaxOwed: result.netPayable,
            effectiveTaxRate: result.effectiveRate,
            slabBreakdown: result.slabBreakdown,
            regimeSelected: policy.regimeCode,
            grossRevenue: result.grossRevenue,
            filingStatus: 'Review',
            reportHash,
            pdfUrl,
            rawQueryData: financialData
        });

        await dbReport.save();

        res.json({
            message: 'Report Generated Successfully',
            reportId: dbReport._id,
            pdfUrl,
            summary: result
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error generating report' });
    }
});

// Download PDF endpoint
router.get('/download/:reportId', auth, async (req, res) => {
    try {
        const report = await TaxReport.findOne({ _id: req.params.reportId, userId: req.user });
        if (!report || !report.pdfUrl) {
            return res.status(404).json({ message: 'Report PDF not found' });
        }

        // Since we saved it inside public/reports
        const filename = report.pdfUrl.split('/').pop();
        const absolutePath = path.join(__dirname, '../public/reports', filename);

        res.download(absolutePath, filename);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error downloading file' });
    }
});

module.exports = router;
