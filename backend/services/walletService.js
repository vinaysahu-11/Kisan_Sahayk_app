const User = require('../models/User');
const WalletTransaction = require('../models/WalletTransaction');

class WalletService {
  /**
   * Credit amount to user wallet
   */
  async creditWallet(userId, amount, category, description, reference = null, metadata = {}) {
    const user = await User.findById(userId);
    if (!user) throw new Error('User not found');

    const balanceBefore = user.wallet.balance;
    const balanceAfter = balanceBefore + amount;

    // Update user wallet
    user.wallet.balance = balanceAfter;
    user.wallet.lastUpdated = new Date();
    await user.save();

    // Create transaction record
    const transaction = await WalletTransaction.create({
      user: userId,
      type: 'credit',
      amount,
      balanceBefore,
      balanceAfter,
      category,
      description,
      reference,
      metadata,
      status: 'completed'
    });

    return { user, transaction };
  }

  /**
   * Debit amount from user wallet
   */
  async debitWallet(userId, amount, category, description, reference = null, metadata = {}) {
    const user = await User.findById(userId);
    if (!user) throw new Error('User not found');

    if (user.wallet.balance < amount) {
      throw new Error('Insufficient wallet balance');
    }

    const balanceBefore = user.wallet.balance;
    const balanceAfter = balanceBefore - amount;

    // Update user wallet
    user.wallet.balance = balanceAfter;
    user.wallet.lastUpdated = new Date();
    await user.save();

    // Create transaction record
    const transaction = await WalletTransaction.create({
      user: userId,
      type: 'debit',
      amount,
      balanceBefore,
      balanceAfter,
      category,
      description,
      reference,
      metadata,
      status: 'completed'
    });

    return { user, transaction };
  }

  /**
   * Get wallet balance
   */
  async getBalance(userId) {
    const user = await User.findById(userId).select('wallet');
    if (!user) throw new Error('User not found');
    return user.wallet.balance;
  }

  /**
   * Get transaction history
   */
  async getTransactions(userId, page = 1, limit = 20, category = null) {
    const skip = (page - 1) * limit;
    const query = { user: userId };
    
    if (category) {
      query.category = category;
    }

    const transactions = await WalletTransaction.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();

    const total = await WalletTransaction.countDocuments(query);

    return {
      transactions,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  /**
   * Process order payment from wallet
   */
  async processOrderPayment(buyerId, orderId, amount) {
    const reference = {
      model: 'Order',
      id: orderId
    };

    return await this.debitWallet(
      buyerId,
      amount,
      'order_payment',
      `Payment for order ${orderId}`,
      reference,
      { orderId: orderId.toString() }
    );
  }

  /**
   * Process seller earning (after commission deduction)
   */
  async processSellerEarning(sellerId, orderId, amount, commissionAmount, commissionRate) {
    const reference = {
      model: 'Order',
      id: orderId
    };

    const netAmount = amount - commissionAmount;

    return await this.creditWallet(
      sellerId,
      netAmount,
      'seller_earning',
      `Earning from order ${orderId} (Commission: ₹${commissionAmount})`,
      reference,
      {
        orderId: orderId.toString(),
        grossAmount: amount,
        commissionRate,
        commissionAmount,
        netAmount
      }
    );
  }

  /**
   * Process refund
   */
  async processRefund(buyerId, orderId, amount) {
    const reference = {
      model: 'Order',
      id: orderId
    };

    return await this.creditWallet(
      buyerId,
      amount,
      'order_refund',
      `Refund for order ${orderId}`,
      reference,
      { orderId: orderId.toString() }
    );
  }

  /**
   * Process labour partner earning
   */
  async processLabourEarning(partnerId, bookingId, amount) {
    const reference = {
      model: 'LabourBooking',
      id: bookingId
    };

    return await this.creditWallet(
      partnerId,
      amount,
      'labour_earning',
      `Earning from labour booking ${bookingId}`,
      reference,
      { bookingNumber: bookingId.toString() }
    );
  }

  /**
   * Process transport partner earning
   */
  async processTransportEarning(partnerId, bookingId, amount) {
    const reference = {
      model: 'TransportBooking',
      id: bookingId
    };

    return await this.creditWallet(
      partnerId,
      amount,
      'transport_earning',
      `Earning from transport booking ${bookingId}`,
      reference,
      { bookingNumber: bookingId.toString() }
    );
  }

  /**
   * Process delivery partner earning
   */
  async processDeliveryEarning(partnerId, deliveryId, amount, codAmount = 0) {
    const reference = {
      model: 'DeliveryOrder',
      id: deliveryId
    };

    let earnedAmount = amount;
    let description = `Delivery earning for ${deliveryId}`;

    // If COD, deduct collected amount from earning
    if (codAmount > 0) {
      description += ` (COD: ₹${codAmount} settled)`;
    }

    return await this.creditWallet(
      partnerId,
      earnedAmount,
      'delivery_earning',
      description,
      reference,
      {
        deliveryNumber: deliveryId.toString(),
        deliveryFee: amount,
        codAmount
      }
    );
  }

  /**
   * Process COD settlement
   */
  async processCODSettlement(partnerId, deliveryId, codAmount) {
    const reference = {
      model: 'DeliveryOrder',
      id: deliveryId
    };

    return await this.debitWallet(
      partnerId,
      codAmount,
      'cod_settlement',
      `COD settlement for delivery ${deliveryId}`,
      reference,
      { deliveryNumber: deliveryId.toString(), codAmount }
    );
  }
}

module.exports = new WalletService();
