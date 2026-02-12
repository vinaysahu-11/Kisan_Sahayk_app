// Partner Wallet and Earnings Models

class PartnerWallet {
  final String partnerId;
  final double balance;
  final double totalEarnings;
  final double totalCommission;
  final double pendingAmount;
  final List<WalletTransaction> transactions;

  PartnerWallet({
    required this.partnerId,
    required this.balance,
    required this.totalEarnings,
    required this.totalCommission,
    required this.pendingAmount,
    required this.transactions,
  });
}

class WalletTransaction {
  final String id;
  final String bookingId;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final double commission;
  final double netAmount;
  final String description;
  final TransactionStatus status;

  WalletTransaction({
    required this.id,
    required this.bookingId,
    required this.date,
    required this.type,
    required this.amount,
    required this.commission,
    required this.netAmount,
    required this.description,
    required this.status,
  });
}

enum TransactionType {
  earning,
  withdrawal,
  refund,
  penalty,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
}

class WithdrawalRequest {
  final String id;
  final String partnerId;
  final double amount;
  final DateTime requestDate;
  final DateTime? processedDate;
  final WithdrawalStatus status;
  final String bankAccountNumber;
  final String ifscCode;

  WithdrawalRequest({
    required this.id,
    required this.partnerId,
    required this.amount,
    required this.requestDate,
    this.processedDate,
    required this.status,
    required this.bankAccountNumber,
    required this.ifscCode,
  });
}

enum WithdrawalStatus {
  pending,
  processing,
  completed,
  rejected,
}

class PartnerProfile {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? aadhaarNumber;
  final String? profilePhotoUrl;
  final String? aadhaarPhotoUrl;
  final BankDetails? bankDetails;
  final DateTime registrationDate;
  final PartnerStatus status;
  final double rating;
  final int totalReviews;
  final bool isVerified;

  PartnerProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.aadhaarNumber,
    this.profilePhotoUrl,
    this.aadhaarPhotoUrl,
    this.bankDetails,
    required this.registrationDate,
    required this.status,
    required this.rating,
    required this.totalReviews,
    required this.isVerified,
  });
}

class BankDetails {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branch;

  BankDetails({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branch,
  });
}

enum PartnerStatus {
  pending,
  approved,
  suspended,
  rejected,
  inactive,
}

class BookingRequest {
  final String requestId;
  final String bookingId;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final DateTime requestTime;
  final DateTime? expiryTime;
  final RequestStatus status;
  final double estimatedEarning;
  final double platformCommission;
  final double netEarning;

  BookingRequest({
    required this.requestId,
    required this.bookingId,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.requestTime,
    this.expiryTime,
    required this.status,
    required this.estimatedEarning,
    required this.platformCommission,
    required this.netEarning,
  });
}

enum RequestStatus {
  pending,
  accepted,
  rejected,
  expired,
  cancelled,
}
