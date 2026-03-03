const mongoose = require('mongoose');

const taxPolicySchema = new mongoose.Schema({
    policyId: {
        type: String,
        required: true,
        unique: true
    },
    taxYear: {
        type: String, // e.g. "2024-2025"
        required: true
    },
    regimeCode: {
        type: String, // e.g. "OLD_REGIME", "NEW_REGIME", "CORPORATE_MSME"
        required: true
    },
    baseExemption: {
        type: Number,
        default: 0
    },
    slabs: [{
        min: Number,
        max: Number, // null/undefined for infinite
        rate: Number
    }],
    surcharge: [{
        minIncome: Number,
        rate: Number
    }],
    cess: {
        healthAndEducation: { type: Number, default: 0 }
    },
    rebate: {
        maxIncomeForRebate: { type: Number, default: 0 },
        maxRebateAmount: { type: Number, default: 0 }
    },
    capitalGains: {
        stcgRate: { type: Number, default: 0 },
        ltcgRate: { type: Number, default: 0 },
        ltcgExemption: { type: Number, default: 0 }
    },
    allowedDeductions: [{ type: String }],
    deductionCaps: {
        type: Map,
        of: Number // e.g., { "SECTION_80C": 150000 }
    },
    standardDeductionAmount: {
        type: Number,
        default: 0
    }
}, { timestamps: true });

module.exports = mongoose.model('TaxPolicy', taxPolicySchema);
