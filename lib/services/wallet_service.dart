import 'dart:async';
import '../models/partner_models.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  // Platform configuration
  static const double minWithdrawalAmount = 500.0;
  static const double maxWithdrawalAmount = 50000.0;
  static const int withdrawalProcessingDays = 2;

  final Map<String, PartnerWallet> _wallets = {};
  final List<WithdrawalRequest> _withdrawalRequests = [];

  final StreamController<PartnerWallet> _walletUpdatesController =
      StreamController<PartnerWallet>.broadcast();

  Stream<PartnerWallet> get walletUpdates => _walletUpdatesController.stream;

  // Get wallet for partner
  PartnerWallet getWallet(String partnerId) {
    if (!_wallets.containsKey(partnerId)) {
      _wallets[partnerId] = PartnerWallet(
        partnerId: partnerId,
        balance: 0.0,
        totalEarnings: 0.0,
        totalCommission: 0.0,
        pendingAmount: 0.0,
        transactions: [],
      );
    }
    return _wallets[partnerId]!;
  }

  // Add earnings to wallet
  void addEarning({
    required String partnerId,
    required String bookingId,
    required double grossAmount,
    required double commissionPercent,
    required String description,
  }) {
    final wallet = getWallet(partnerId);
    final commission = (grossAmount * commissionPercent) / 100;
    final netAmount = grossAmount - commission;

    final transaction = WalletTransaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      date: DateTime.now(),
      type: TransactionType.earning,
      amount: grossAmount,
      commission: commission,
      netAmount: netAmount,
      description: description,
      status: TransactionStatus.completed,
    );

    final updatedTransactions = [...wallet.transactions, transaction];

    final updatedWallet = PartnerWallet(
      partnerId: partnerId,
      balance: wallet.balance + netAmount,
      totalEarnings: wallet.totalEarnings + netAmount,
      totalCommission: wallet.totalCommission + commission,
      pendingAmount: wallet.pendingAmount,
      transactions: updatedTransactions,
    );

    _wallets[partnerId] = updatedWallet;
    _walletUpdatesController.add(updatedWallet);
  }

  // Request withdrawal
  Future<WithdrawalRequest> requestWithdrawal({
    required String partnerId,
    required double amount,
    required String accountNumber,
    required String ifscCode,
  }) async {
    final wallet = getWallet(partnerId);

    if (amount < minWithdrawalAmount) {
      throw Exception('Minimum withdrawal amount is ₹$minWithdrawalAmount');
    }

    if (amount > wallet.balance) {
      throw Exception('Insufficient balance');
    }

    if (amount > maxWithdrawalAmount) {
      throw Exception('Maximum withdrawal amount is ₹$maxWithdrawalAmount');
    }

    final request = WithdrawalRequest(
      id: 'WD${DateTime.now().millisecondsSinceEpoch}',
      partnerId: partnerId,
      amount: amount,
      requestDate: DateTime.now(),
      status: WithdrawalStatus.pending,
      bankAccountNumber: accountNumber,
      ifscCode: ifscCode,
    );

    _withdrawalRequests.add(request);

    // Update wallet balance (deduct)
    final updatedWallet = PartnerWallet(
      partnerId: partnerId,
      balance: wallet.balance - amount,
      totalEarnings: wallet.totalEarnings,
      totalCommission: wallet.totalCommission,
      pendingAmount: wallet.pendingAmount + amount,
      transactions: wallet.transactions,
    );

    _wallets[partnerId] = updatedWallet;
    _walletUpdatesController.add(updatedWallet);

    return request;
  }

  // Get withdrawal requests for partner
  List<WithdrawalRequest> getWithdrawalRequests(String partnerId) {
    return _withdrawalRequests
        .where((req) => req.partnerId == partnerId)
        .toList()
      ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
  }

  // Get transactions for partner
  List<WalletTransaction> getTransactions(String partnerId) {
    final wallet = getWallet(partnerId);
    return wallet.transactions
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get earnings summary
  Map<String, double> getEarningsSummary(String partnerId) {
    final wallet = getWallet(partnerId);
    final now = DateTime.now();
    
    double todayEarnings = 0.0;
    double weeklyEarnings = 0.0;
    double monthlyEarnings = 0.0;

    for (final txn in wallet.transactions) {
      if (txn.type == TransactionType.earning &&
          txn.status == TransactionStatus.completed) {
        // Today
        if (txn.date.year == now.year &&
            txn.date.month == now.month &&
            txn.date.day == now.day) {
          todayEarnings += txn.netAmount;
        }

        // This week (last 7 days)
        if (now.difference(txn.date).inDays < 7) {
          weeklyEarnings += txn.netAmount;
        }

        // This month
        if (txn.date.year == now.year && txn.date.month == now.month) {
          monthlyEarnings += txn.netAmount;
        }
      }
    }

    return {
      'today': todayEarnings,
      'weekly': weeklyEarnings,
      'monthly': monthlyEarnings,
      'total': wallet.totalEarnings,
      'balance': wallet.balance,
      'pending': wallet.pendingAmount,
    };
  }

  void dispose() {
    _walletUpdatesController.close();
  }
}
