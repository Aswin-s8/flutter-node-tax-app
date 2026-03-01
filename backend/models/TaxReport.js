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
    }
}, { timestamps: true });

module.exports = mongoose.model('TaxReport', taxReportSchema);
