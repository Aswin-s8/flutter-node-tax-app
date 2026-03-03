const TaxPolicy = require('../models/TaxPolicy');

/**
 * Validates claimed deductions against the allowed deductions and caps in the tax policy.
 */
function validateDeductions(claimedDeductions, policy) {
    const validatedDeductions = [];
    let totalAllowed = 0.0;

    // Convert array of objects [{ type: 'SECTION_80C', amount: 150000 }] into processed results
    const claimedList = Array.isArray(claimedDeductions) ? claimedDeductions : [];

    // Add standard deduction if policy allows it
    if (policy.allowedDeductions.includes('STANDARD_DEDUCTION') && policy.standardDeductionAmount > 0) {
        // Only add if not already claimed
        if (!claimedList.find(d => d.type === 'STANDARD_DEDUCTION')) {
            claimedList.push({ type: 'STANDARD_DEDUCTION', amount: policy.standardDeductionAmount });
        }
    }

    for (const deduction of claimedList) {
        if (!policy.allowedDeductions.includes(deduction.type)) {
            validatedDeductions.push({
                type: deduction.type,
                claimed: deduction.amount,
                allowed: 0.0,
                rejected: deduction.amount,
                reason: "Not applicable in selected tax regime"
            });
            continue;
        }

        // JS Map gives undefined if not found
        const cap = policy.deductionCaps.get(deduction.type);
        const actualCap = cap !== undefined ? cap : Infinity;

        const allowedAmount = Math.min(deduction.amount, actualCap);
        const rejectedAmount = deduction.amount - allowedAmount;

        totalAllowed += allowedAmount;

        validatedDeductions.push({
            type: deduction.type,
            claimed: deduction.amount,
            allowed: allowedAmount,
            rejected: rejectedAmount,
            reason: rejectedAmount > 0 ? "Exceeds maximum allowable limit" : "Approved"
        });
    }

    return { validatedDeductions, totalAllowed };
}

/**
 * Calculates progressive slab-based tax.
 */
function calculateSlabTax(taxableIncome, policy) {
    let totalTax = 0.0;
    const slabBreakdown = [];

    for (const slab of policy.slabs) {
        if (taxableIncome <= slab.min) {
            break;
        }

        const slabMax = slab.max !== null ? slab.max : Infinity;
        const taxableInSlab = Math.min(taxableIncome - slab.min, slabMax - slab.min);
        const slabTax = taxableInSlab * slab.rate;

        totalTax += slabTax;
        slabBreakdown.push({
            range: `${slab.min} - ${slab.max || 'Above'}`,
            rate: slab.rate,
            amountTaxed: taxableInSlab,
            tax: slabTax
        });
    }

    return { totalTax, slabBreakdown };
}

/**
 * Calculates capital gains tax.
 */
function calculateCapitalGains(income, policy) {
    const stcg = income.stcg || 0;
    const ltcg = income.ltcg || 0;

    const taxableLtcg = Math.max(0, ltcg - policy.capitalGains.ltcgExemption);

    const stcgTax = stcg * policy.capitalGains.stcgRate;
    const ltcgTax = taxableLtcg * policy.capitalGains.ltcgRate;

    return stcgTax + ltcgTax;
}

/**
 * Applies surcharge based on income brackets.
 */
function applySurcharge(taxBeforeSurcharge, taxableIncome, policy) {
    let surchargeRate = 0;

    // Surcharge brackets should ideally be sorted descending by minIncome
    const sortedSurcharges = [...policy.surcharge].sort((a, b) => b.minIncome - a.minIncome);

    for (const bracket of sortedSurcharges) {
        if (taxableIncome > bracket.minIncome) {
            surchargeRate = bracket.rate;
            break;
        }
    }

    return taxBeforeSurcharge * surchargeRate;
}

/**
 * Computes gross income from financial structure.
 */
function calculateGrossIncome(financialData) {
    return (financialData.income?.grossRevenue || 0) +
        (financialData.income?.operatingIncome || 0) +
        (financialData.income?.stcg || 0) +
        (financialData.income?.ltcg || 0);
}

/**
 * The main regime comparison engine.
 */
async function compareRegimes(financialData, availablePolicies) {
    const comparisonResults = [];

    for (const policy of availablePolicies) {
        // 1. Calculate allowed deductions
        const { totalAllowed: allowedDeductionsTotal, validatedDeductions } = validateDeductions(
            financialData.deductions?.claimed || [],
            policy
        );

        // 2. Calculate initial taxable income
        const grossIncome = calculateGrossIncome(financialData);
        const totalExpenses = (financialData.expenses?.operating || 0) + (financialData.expenses?.depreciation || 0);

        // Depending on company type, expenses might be deductible from revenue
        const incomeAfterExpenses = Math.max(0, grossIncome - totalExpenses);

        const taxableIncome = Math.max(0, incomeAfterExpenses - allowedDeductionsTotal);

        // 3. Calculate Base Tax
        const { totalTax: baseTax, slabBreakdown } = calculateSlabTax(taxableIncome, policy);

        // 4. Apply Rebate
        let taxAfterRebate = baseTax;
        if (taxableIncome <= policy.rebate.maxIncomeForRebate) {
            taxAfterRebate = Math.max(0, baseTax - policy.rebate.maxRebateAmount);
        }

        // 5. Capital Gains Tax
        const cgTax = calculateCapitalGains(financialData.income || {}, policy);

        // 6. Surcharge & Cess
        const taxBeforeCess = taxAfterRebate + cgTax;
        const surchargeApplicable = applySurcharge(taxBeforeCess, taxableIncome, policy);
        const cessApplicable = (taxBeforeCess + surchargeApplicable) * policy.cess.healthAndEducation;

        const totalTaxLiability = taxBeforeCess + surchargeApplicable + cessApplicable;

        // 7. Credits (TDS, Advance Tax)
        const credits = (financialData.credits?.tds || 0) + (financialData.credits?.advanceTax || 0);
        const netPayable = totalTaxLiability - credits;

        comparisonResults.push({
            regimeName: policy.regimeCode,
            policyId: policy.policyId,
            grossRevenue: grossIncome,
            totalExpenses,
            taxableIncome,
            totalDeductions: allowedDeductionsTotal,
            baseTax,
            surchargeAppied: surchargeApplicable,
            cessApplied: cessApplicable,
            totalTax: totalTaxLiability,
            netPayable: netPayable,
            effectiveRate: grossIncome > 0 ? (totalTaxLiability / grossIncome) * 100 : 0,
            slabBreakdown,
            validatedDeductions
        });
    }

    const optimalRegime = comparisonResults.reduce((prev, curr) => curr.totalTax < prev.totalTax ? curr : prev);
    const maxTax = Math.max(...comparisonResults.map(c => c.totalTax));

    return {
        results: comparisonResults,
        recommendedRegime: optimalRegime.regimeName,
        recommendedPolicyId: optimalRegime.policyId,
        savingsAgainstMax: maxTax - optimalRegime.totalTax
    };
}

module.exports = {
    validateDeductions,
    calculateSlabTax,
    calculateCapitalGains,
    applySurcharge,
    compareRegimes
};
