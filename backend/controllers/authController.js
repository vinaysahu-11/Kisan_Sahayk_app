const User = require('../models/User');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'kisan_sahayk_secret_key_2026';

/**
 * Generate JWT Token
 */
const generateToken = (user) => {
  return jwt.sign(
    { 
      id: user._id, 
      phone: user.phone, 
      role: user.role 
    },
    JWT_SECRET,
    { expiresIn: '30d' }
  );
};

/**
 * Generate and send OTP
 */
exports.sendOTP = async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone || phone.length !== 10) {
      return res.status(400).json({ 
        success: false, 
        message: 'Valid 10-digit phone number required' 
      });
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Find or create user
    let user = await User.findOne({ phone });
    
    if (!user) {
      // Create new buyer user
      user = new User({
        name: 'User', // Default name
        phone,
        role: 'buyer',
        otp: {
          code: otp,
          expiresAt: otpExpiry
        }
      });
    } else {
      user.otp = {
        code: otp,
        expiresAt: otpExpiry
      };
    }

    await user.save();

    // TODO: Send OTP via SMS service (Twilio, MSG91, etc.)
    console.log(`OTP for ${phone}: ${otp}`);

    res.json({
      success: true,
      message: 'OTP sent successfully',
      // In production, remove this
      ...(process.env.NODE_ENV === 'development' && { otp })
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to send OTP', 
      error: error.message 
    });
  }
};

/**
 * Verify OTP and Login
 */
exports.verifyOTP = async (req, res) => {
  try {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({ 
        success: false, 
        message: 'Phone and OTP required' 
      });
    }

    const user = await User.findOne({ phone });

    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    // Check OTP expiry
    if (new Date() > user.otp.expiresAt) {
      return res.status(400).json({ 
        success: false, 
        message: 'OTP expired. Please request a new one.' 
      });
    }

    // Verify OTP
    const isValid = await user.compareOTP(otp);

    if (!isValid) {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid OTP' 
      });
    }

    // Clear OTP
    user.otp = undefined;
    user.isVerified = true;
    user.lastLogin = new Date();
    await user.save();

    // Generate token
    const token = generateToken(user);

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        wallet: user.wallet,
        profileImage: user.profileImage
      }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Login failed', 
      error: error.message 
    });
  }
};

/**
 * Role-based registration (Seller, Labour Partner, etc.)
 */
exports.register = async (req, res) => {
  try {
    const { name, phone, password, email, role } = req.body;

    // Validate role
    const allowedRoles = ['buyer', 'seller', 'labour_partner', 'transport_partner', 'delivery_partner'];
    if (role && !allowedRoles.includes(role)) {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid role' 
      });
    }

    // Check if user exists
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      return res.status(400).json({ 
        success: false, 
        message: 'Phone number already registered' 
      });
    }

    // Create user
    const user = await User.create({
      name,
      phone,
      password,
      email,
      role: role || 'buyer'
    });

    // Generate token
    const token = generateToken(user);

    res.status(201).json({
      success: true,
      message: 'Registration successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Registration failed', 
      error: error.message 
    });
  }
};

/**
 * Get current user profile
 */
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .select('-password -otp')
      .lean();

    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    res.json({
      success: true,
      user
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch profile', 
      error: error.message 
    });
  }
};

/**
 * Update user profile
 */
exports.updateProfile = async (req, res) => {
  try {
    const { name, email, profileImage, preferences } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { 
        $set: { 
          name, 
          email, 
          profileImage, 
          preferences 
        } 
      },
      { new: true, runValidators: true }
    ).select('-password -otp');

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update profile', 
      error: error.message 
    });
  }
};

/**
 * Add address
 */
exports.addAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    // If this is the first address or marked as default, set it as default
    if (user.addresses.length === 0 || req.body.isDefault) {
      // Remove default from all other addresses
      user.addresses.forEach(addr => addr.isDefault = false);
      req.body.isDefault = true;
    }

    user.addresses.push(req.body);
    await user.save();

    res.json({
      success: true,
      message: 'Address added successfully',
      addresses: user.addresses
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to add address', 
      error: error.message 
    });
  }
};

/**
 * Update address
 */
exports.updateAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    const user = await User.findById(req.user.id);

    const address = user.addresses.id(addressId);
    if (!address) {
      return res.status(404).json({ 
        success: false, 
        message: 'Address not found' 
      });
    }

    // If setting as default, remove default from others
    if (req.body.isDefault) {
      user.addresses.forEach(addr => addr.isDefault = false);
    }

    Object.assign(address, req.body);
    await user.save();

    res.json({
      success: true,
      message: 'Address updated successfully',
      addresses: user.addresses
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update address', 
      error: error.message 
    });
  }
};

/**
 * Delete address
 */
exports.deleteAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    const user = await User.findById(req.user.id);

    user.addresses.pull(addressId);
    await user.save();

    res.json({
      success: true,
      message: 'Address deleted successfully',
      addresses: user.addresses
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to delete address', 
      error: error.message 
    });
  }
};

/**
 * Update user preferences (language, dark mode, notifications)
 */
exports.updatePreferences = async (req, res) => {
  try {
    const { language, darkMode, notifications } = req.body;

    const updateFields = {};
    if (language !== undefined) updateFields['preferences.language'] = language;
    if (darkMode !== undefined) updateFields['preferences.darkMode'] = darkMode;
    if (notifications !== undefined) updateFields['preferences.notifications'] = notifications;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updateFields },
      { new: true, runValidators: true }
    ).select('-password -otp');

    res.json({
      success: true,
      message: 'Preferences updated successfully',
      preferences: user.preferences
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update preferences', 
      error: error.message 
    });
  }
};

/**
 * Get user preferences
 */
exports.getPreferences = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('preferences');

    res.json({
      success: true,
      preferences: user.preferences
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get preferences', 
      error: error.message 
    });
  }
};
