require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const TaxPolicy = require('../models/TaxPolicy');

const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/flutter_node_app';

const policies = [
    {
        policyId: 'OLD_REGIME_2024',
        taxYear: '2024-2025',
        regimeCode: 'OLD_REGIME',
        baseExemption: 250000,
        slabs: [
            { min: 0, max: 250000, rate: 0.00 },
            { min: 250000, max: 500000, rate: 0.05 },
            { min: 500000, max: 1000000, rate: 0.20 },
            { min: 1000000, max: null, rate: 0.30 }
        ],
        surcharge: [
            { minIncome: 5000000, rate: 0.10 },
            { minIncome: 10000000, rate: 0.15 }
        ],
        cess: { healthAndEducation: 0.04 },
        rebate: { maxIncomeForRebate: 500000, maxRebateAmount: 12500 },
        capitalGains: { stcgRate: 0.15, ltcgRate: 0.10, ltcgExemption: 100000 },
        allowedDeductions: ['SECTION_80C', 'SECTION_80D', 'HRA', 'STANDARD_DEDUCTION'],
        deductionCaps: {
            'SECTION_80C': 150000,
            'SECTION_80D': 25000,
            'STANDARD_DEDUCTION': 50000
        },
        standardDeductionAmount: 50000
    },
    {
        policyId: 'NEW_REGIME_2024',
        taxYear: '2024-2025',
        regimeCode: 'NEW_REGIME',
        baseExemption: 300000,
        slabs: [
            { min: 0, max: 300000, rate: 0.00 },
            { min: 300000, max: 600000, rate: 0.05 },
            { min: 600000, max: 900000, rate: 0.10 },
            { min: 900000, max: 1200000, rate: 0.15 },
            { min: 1200000, max: 1500000, rate: 0.20 },
            { min: 1500000, max: null, rate: 0.30 }
        ],
        surcharge: [
            { minIncome: 5000000, rate: 0.10 },
            { minIncome: 10000000, rate: 0.15 }
        ],
        cess: { healthAndEducation: 0.04 },
        rebate: { maxIncomeForRebate: 700000, maxRebateAmount: 25000 },
        capitalGains: { stcgRate: 0.15, ltcgRate: 0.10, ltcgExemption: 100000 },
        allowedDeductions: ['STANDARD_DEDUCTION'],  // Far fewer deductions allowed
        deductionCaps: {
            'STANDARD_DEDUCTION': 50000
        },
        standardDeductionAmount: 50000
    },
    {
        policyId: 'CORPORATE_REGIME_2024',
        taxYear: '2024-2025',
        regimeCode: 'CORPORATE_MSME',
        baseExemption: 0,
        slabs: [
            { min: 0, max: null, rate: 0.25 } // Flat 25% for MSME Corporate
        ],
        surcharge: [
            { minIncome: 10000000, rate: 0.07 },
            { minIncome: 100000000, rate: 0.12 }
        ],
        cess: { healthAndEducation: 0.04 },
        rebate: { maxIncomeForRebate: 0, maxRebateAmount: 0 },
        capitalGains: { stcgRate: 0.15, ltcgRate: 0.10, ltcgExemption: 100000 },
        allowedDeductions: ['OPERATING_EXPENSES', 'DEPRECIATION', 'INTEREST_PAID'],
        deductionCaps: {},
        standardDeductionAmount: 0
    }
];

async function seedDB() {
    try {
        await mongoose.connect(mongoURI);
        console.log('MongoDB connected for seeding policies.');

        await TaxPolicy.deleteMany({}); // Clear existing ones
        console.log('Existing tax policies removed.');

        await TaxPolicy.insertMany(policies);
        console.log('New tax policies seeded successfully!');

        mongoose.connection.close();
    } catch (err) {
        console.error('Error seeding DB:', err);
        mongoose.connection.close();
    }
}

seedDB();
