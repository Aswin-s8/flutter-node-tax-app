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
    }
}, { timestamps: true });

module.exports = mongoose.model('Company', companySchema);
