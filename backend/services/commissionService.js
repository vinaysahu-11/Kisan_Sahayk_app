const CommissionSettings = require('../models/CommissionSettings');
const SellerProfile = require('../models/SellerProfile');

class CommissionService {
  /**
   * Get commission rate for a category
   */
  async getCommissionRate(category) {
    const settings = await CommissionSettings.findOne({ category, isActive: true });
    return settings ? settings.rate : 10; // Default 10%
  }

  /**
   * Get seller-specific commission rate
   */
  async getSellerCommissionRate(sellerId) {
    const sellerProfile = await SellerProfile.findOne({ user: sellerId });
    if (sellerProfile && sellerProfile.commissionRate !== undefined) {
      return sellerProfile.commissionRate;
    }
    // Fallback to default seller commission
    return await this.getCommissionRate('seller_product');
  }

  /**
   * Calculate commission amount
   */
  calculateCommissionAmount(amount, rate) {
    return parseFloat(((amount * rate) / 100).toFixed(2));
  }

  /**
   * Calculate seller earnings (amount - commission)
   */
  async calculateSellerEarnings(sellerId, grossAmount) {
    const commissionRate = await this.getSellerCommissionRate(sellerId);
    const commissionAmount = this.calculateCommissionAmount(grossAmount, commissionRate);
    const netEarning = grossAmount - commissionAmount;

    return {
      grossAmount,
      commissionRate,
      commissionAmount,
      netEarning
    };
  }

  /**
   * Calculate labour booking commission
   */
  async calculateLabourCommission(bookingAmount) {
    const commissionRate = await this.getCommissionRate('labour_booking');
    const commissionAmount = this.calculateCommissionAmount(bookingAmount, commissionRate);

    return {
      grossAmount: bookingAmount,
      commissionRate,
      commissionAmount,
      netAmount: bookingAmount - commissionAmount
    };
  }

  /**
   * Calculate transport booking commission
   */
  async calculateTransportCommission(bookingAmount) {
    const commissionRate = await this.getCommissionRate('transport_booking');
    const commissionAmount = this.calculateCommissionAmount(bookingAmount, commissionRate);

    return {
      grossAmount: bookingAmount,
      commissionRate,
      commissionAmount,
      netAmount: bookingAmount - commissionAmount
    };
  }

  /**
   * Update commission settings (admin only)
   */
  async updateCommissionSettings(category, rate, updatedBy) {
    let settings = await CommissionSettings.findOne({ category });

    if (settings) {
      settings.rate = rate;
      settings.updatedBy = updatedBy;
      await settings.save();
    } else {
      settings = await CommissionSettings.create({
        category,
        rate,
        updatedBy
      });
    }

    return settings;
  }

  /**
   * Set seller-specific commission rate
   */
  async setSellerCommissionRate(sellerId, rate, updatedBy) {
    const sellerProfile = await SellerProfile.findOne({ user: sellerId });
    if (!sellerProfile) {
      throw new Error('Seller profile not found');
    }

    sellerProfile.commissionRate = rate;
    await sellerProfile.save();

    return sellerProfile;
  }

  /**
   * Get all commission settings
   */
  async getAllCommissionSettings() {
    return await CommissionSettings.find({ isActive: true }).sort({ category: 1 });
  }
}

module.exports = new CommissionService();
