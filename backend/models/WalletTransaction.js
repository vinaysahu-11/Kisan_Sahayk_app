const mongoose = require('mongoose');

const walletTransactionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: ['credit', 'debit'],
    required: true
  },
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  balanceBefore: {
    type: Number,
    required: true
  },
  balanceAfter: {
    type: Number,
    required: true
  },
  category: {
    type: String,
    enum: [
      'order_payment',
      'order_refund',
      'seller_earning',
      'commission_deduction',
      'labour_payment',
      'labour_earning',
      'transport_payment',
      'transport_earning',
      'delivery_earning',
      'cod_settlement',
      'withdrawal',
      'added_by_admin',
      'penalty',
      'bonus',
      'incentive'
    ],
    required: true
  },
  reference: {
    model: {
      type: String,
      enum: ['Order', 'LabourBooking', 'TransportBooking', 'DeliveryOrder', 'Withdrawal']
    },
    id: mongoose.Schema.Types.ObjectId
  },
  description: String,
  metadata: {
    orderId: String,
    bookingNumber: String,
    commissionRate: Number,
    commissionAmount: Number
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'cancelled'],
    default: 'completed'
  },
  processedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

walletTransactionSchema.index({ user: 1, createdAt: -1 });
walletTransactionSchema.index({ type: 1 });
walletTransactionSchema.index({ category: 1 });
walletTransactionSchema.index({ status: 1 });
walletTransactionSchema.index({ 'reference.id': 1 });

module.exports = mongoose.model('WalletTransaction', walletTransactionSchema);
