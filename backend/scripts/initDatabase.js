const mongoose = require('mongoose');
require('dotenv').config();

// Import all models
const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Category = require('../models/Category');
const SellerProfile = require('../models/SellerProfile');
const LabourBooking = require('../models/LabourBooking');
const TransportBooking = require('../models/TransportBooking');
const DeliveryOrder = require('../models/DeliveryOrder');
const WalletTransaction = require('../models/WalletTransaction');
const CommissionSettings = require('../models/CommissionSettings');
const Rating = require('../models/Rating');
const Return = require('../models/Return');

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/kisan_sahayk');
    console.log('✅ MongoDB Connected Successfully');
  } catch (error) {
    console.error('❌ MongoDB Connection Error:', error.message);
    process.exit(1);
  }
};

// Initialize database with collections and seed data
const initializeDatabase = async () => {
  try {
    console.log('🚀 Starting Database Initialization...\n');

    // Drop existing collections to start fresh
    console.log('🗑️  Dropping existing collections...');
    const collections = await mongoose.connection.db.listCollections().toArray();
    for (const collection of collections) {
      await mongoose.connection.db.dropCollection(collection.name);
      console.log(`   Dropped: ${collection.name}`);
    }
    console.log('✓ All existing collections dropped\n');

    // Create collections by syncing indexes (handles conflicts)
    console.log('📦 Creating Collections and Syncing Indexes...');
    
    await User.syncIndexes();
    console.log('✓ User collection created');
    
    await Product.syncIndexes();
    console.log('✓ Product collection created');
    
    await Order.syncIndexes();
    console.log('✓ Order collection created');
    
    await Cart.syncIndexes();
    console.log('✓ Cart collection created');
    
    await Category.syncIndexes();
    console.log('✓ Category collection created');
    
    await SellerProfile.syncIndexes();
    console.log('✓ SellerProfile collection created');
    
    await LabourBooking.syncIndexes();
    console.log('✓ LabourBooking collection created');
    
    await TransportBooking.syncIndexes();
    console.log('✓ TransportBooking collection created');
    
    await DeliveryOrder.syncIndexes();
    console.log('✓ DeliveryOrder collection created');
    
    await WalletTransaction.syncIndexes();
    console.log('✓ WalletTransaction collection created');
    
    await CommissionSettings.syncIndexes();
    console.log('✓ CommissionSettings collection created');
    
    await Rating.syncIndexes();
    console.log('✓ Rating collection created');
    
    await Return.syncIndexes();
    console.log('✓ Return collection created');

    console.log('\n✅ All 13 Collections Created Successfully!\n');

    // Seed initial data
    console.log('🌱 Seeding Initial Data...\n');

    // Check if categories already exist
    const categoryCount = await Category.countDocuments();
    if (categoryCount === 0) {
      console.log('Adding default categories...');
      const categories = [
        {
          name: 'Seeds',
          nameHi: 'बीज',
          nameCg: 'बीया',
          description: 'Agricultural seeds',
          image: 'https://via.placeholder.com/150',
          isActive: true
        },
        {
          name: 'Fertilizers',
          nameHi: 'उर्वरक',
          nameCg: 'खाद',
          description: 'Organic and chemical fertilizers',
          image: 'https://via.placeholder.com/150',
          isActive: true
        },
        {
          name: 'Pesticides',
          nameHi: 'कीटनाशक',
          nameCg: 'कीड़ा मार दवा',
          description: 'Crop protection chemicals',
          image: 'https://via.placeholder.com/150',
          isActive: true
        },
        {
          name: 'Tools & Equipment',
          nameHi: 'औजार और उपकरण',
          nameCg: 'औजार अउ साधन',
          description: 'Farming tools and equipment',
          image: 'https://via.placeholder.com/150',
          isActive: true
        },
        {
          name: 'Machinery',
          nameHi: 'मशीनरी',
          nameCg: 'यंत्र',
          description: 'Agricultural machinery',
          image: 'https://via.placeholder.com/150',
          isActive: true
        },
        {
          name: 'Irrigation',
          nameHi: 'सिंचाई',
          nameCg: 'पानी देवई',
          description: 'Irrigation systems and equipment',
          image: 'https://via.placeholder.com/150',
          isActive: true
        },
        {
          name: 'Animal Feed',
          nameHi: 'पशु आहार',
          nameCg: 'जनावर के चारा',
          description: 'Livestock feed and supplements',
          image: 'https://via.placeholder.com/150',
          isActive: true
        },
        {
          name: 'Organic Products',
          nameHi: 'जैविक उत्पाद',
          nameCg: 'जैविक चीज',
          description: 'Organic farming products',
          image: 'https://via.placeholder.com/150',
          isActive: true
        }
      ];

      await Category.insertMany(categories);
      console.log('✓ Added 8 default categories');
    } else {
      console.log('✓ Categories already exist');
    }

    // Check if commission settings exist
    const commissionCount = await CommissionSettings.countDocuments();
    if (commissionCount === 0) {
      console.log('Adding default commission settings...');
      
      const commissionSettings = [
        {
          category: 'seller_product',
          rate: 10, // 10% commission on product sales
          description: 'Commission on product sales',
          isActive: true
        },
        {
          category: 'labour_booking',
          rate: 8, // 8% commission on labour bookings
          description: 'Commission on labour partner bookings',
          isActive: true
        },
        {
          category: 'transport_booking',
          rate: 8, // 8% commission on transport bookings
          description: 'Commission on transport partner bookings',
          isActive: true
        }
      ];

      await CommissionSettings.insertMany(commissionSettings);
      console.log(`✓ Added ${commissionSettings.length} commission settings`);
    } else {
      console.log('✓ Commission settings already exist');
    }

    // Create admin user if doesn't exist
    const adminCount = await User.countDocuments({ role: 'admin' });
    if (adminCount === 0) {
      console.log('Creating default admin user...');
      
      const admin = new User({
        name: 'Admin',
        phone: '9999999999',
        password: 'admin123', // Will be hashed by pre-save hook
        email: 'admin@kisansahayk.com',
        role: 'admin',
        wallet: {
          balance: 0
        },
        isActive: true
      });

      await admin.save();
      console.log('✓ Admin user created (Phone: 9999999999, Password: admin123)');
    } else {
      console.log('✓ Admin user already exists');
    }

    console.log('\n✅ Database Initialization Complete!\n');
    console.log('📊 Database Summary:');
    console.log(`   - Users: ${await User.countDocuments()}`);
    console.log(`   - Products: ${await Product.countDocuments()}`);
    console.log(`   - Orders: ${await Order.countDocuments()}`);
    console.log(`   - Carts: ${await Cart.countDocuments()}`);
    console.log(`   - Categories: ${await Category.countDocuments()}`);
    console.log(`   - Seller Profiles: ${await SellerProfile.countDocuments()}`);
    console.log(`   - Labour Bookings: ${await LabourBooking.countDocuments()}`);
    console.log(`   - Transport Bookings: ${await TransportBooking.countDocuments()}`);
    console.log(`   - Delivery Orders: ${await DeliveryOrder.countDocuments()}`);
    console.log(`   - Wallet Transactions: ${await WalletTransaction.countDocuments()}`);
    console.log(`   - Commission Settings: ${await CommissionSettings.countDocuments()}`);
    console.log(`   - Ratings: ${await Rating.countDocuments()}`);
    console.log(`   - Returns: ${await Return.countDocuments()}`);

    console.log('\n✨ You can now start using the API!\n');

  } catch (error) {
    console.error('❌ Error during initialization:', error);
    throw error;
  }
};

// Run initialization
const run = async () => {
  await connectDB();
  await initializeDatabase();
  await mongoose.connection.close();
  console.log('🔌 Database connection closed');
  process.exit(0);
};

run();
