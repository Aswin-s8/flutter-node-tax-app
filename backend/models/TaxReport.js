const mongoose = require('mongoose');

const taxReportSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    companyId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Company',
        // Can be null if the user is filing as an individual
    },
    taxYear: {
        type: Number,
        required: true
    },
    totalIncome: {
        type: Number,
        default: 0
    },
    totalDeductions: {
        type: Number,
        default: 0
    },
    estimatedTaxOwed: {
        type: Number,
        default: 0
    },
    filingStatus: {
        type: String,
        enum: ['Draft', 'Review', 'Filed'],
        default: 'Draft'
    },
    rawQueryData: {
        // A place to store the raw answers to the tax questionnaire
        type: mongoose.Schema.Types.Mixed
    },

    // SmartTax upgraded fields
    regimeSelected: {
        type: String // e.g., 'OLD_REGIME', 'NEW_REGIME'
    },
    grossRevenue: {
        type: Number,
        default: 0
    },
    totalExpenses: {
        type: Number,
        default: 0
    },
    taxableIncome: {
        type: Number,
        default: 0
    },
    finalTaxLiability: {
        type: Number,
        default: 0
    },
    effectiveTaxRate: {
        type: Number,
        default: 0
    },
    slabBreakdown: [{
        range: String,
        rate: Number,
        amountTaxed: Number,
        tax: Number
    }],
    creditsApplied: {
        type: mongoose.Schema.Types.Mixed // Details on applied credits
    },
    pdfUrl: {
        type: String // URL or path to generated PDF report
    },
    reportHash: {
        type: String // Hash to verify data integrity
    }
}, { timestamps: true });

module.exports = mongoose.model('TaxReport', taxReportSchema);
