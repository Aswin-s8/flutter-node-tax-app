const mongoose = require('mongoose');

const companySchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    taxId: {
        type: String, // EIN or similar
    },
    companyType: {
        type: String, // LLC, S-Corp, C-Corp, etc.
    },
    industry: {
        type: String
    },
    foundingDate: {
        type: Date
    },
    // Compliance and SmartTax upgraded fields
    turnover: {
        type: Number,
        default: 0
    },
    msmeStatus: {
        type: Boolean,
        default: false
    },
    startupRecognition: {
        type: Boolean,
        default: false
    },
    employeeCount: {
        type: Number,
        default: 0
    },
    exportPercentage: {
        type: Number,
        default: 0
    }
}, { timestamps: true });

module.exports = mongoose.model('Company', companySchema);
