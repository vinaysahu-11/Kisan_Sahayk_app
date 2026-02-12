# Kisan Sahayk Backend API

Node.js + Express + MongoDB backend for the Kisan Sahayk agricultural application.

## Features

- 🔐 JWT-based authentication
- 👤 User management with role-based access (buyer, seller, labour, transport, delivery, admin)
- 🛒 E-commerce functionality (products, orders, cart)
- 💰 Wallet system for transactions
- 📦 Order tracking and management
- 👷 Labour booking system
- 🚚 Transport booking system
- 🌤️ Weather API integration
- ⭐ Rating and review system

## Tech Stack

- **Runtime**: Node.js v18+
- **Framework**: Express.js v4.18
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcryptjs
- **Validation**: express-validator
- **Environment**: dotenv

## Prerequisites

- Node.js v18 or higher
- MongoDB v5.0 or higher (local or MongoDB Atlas)
- npm or yarn package manager

## Installation

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create environment file**
   ```bash
   cp .env.example .env
   ```

4. **Configure environment variables**
   
   Edit `.env` file with your configuration:
   ```env
   # MongoDB Connection
   MONGODB_URI=mongodb://localhost:27017/kisan_sahayk
   # For MongoDB Atlas:
   # MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/kisan_sahayk

   # JWT Secret (use a strong random string)
   JWT_SECRET=your_very_strong_secret_key_here

   # Server Port
   PORT=3000

   # Node Environment
   NODE_ENV=development
   ```

## Database Setup

### Option 1: Local MongoDB

1. Install MongoDB Community Edition from [mongodb.com](https://www.mongodb.com/try/download/community)
2. Start MongoDB service:
   ```bash
   # Windows
   net start MongoDB

   # macOS/Linux
   sudo systemctl start mongod
   ```
3. Use connection string: `mongodb://localhost:27017/kisan_sahayk`

### Option 2: MongoDB Atlas (Cloud)

1. Create free account at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Create a new cluster
3. Add database user and whitelist IP address
4. Get connection string from "Connect" → "Connect your application"
5. Replace `<username>`, `<password>`, and `<cluster-url>` in `.env`

## Running the Server

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start at `http://localhost:3000`

## API Documentation

### Base URL
```
http://localhost:3000/api
```

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "phoneNumber": "9876543210",
  "password": "password123",
  "fullName": "John Doe",
  "role": "buyer"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "phoneNumber": "9876543210",
  "otp": "123456"
}
```
**Note**: For testing, any OTP works. In production, integrate with real SMS service.

#### Send OTP
```http
POST /api/auth/send-otp
Content-Type: application/json

{
  "phoneNumber": "9876543210"
}
```

### Protected Routes

All routes below require JWT token in header:
```
Authorization: Bearer <your_jwt_token>
```

### Buyer Routes (`/api/buyer`)

- `GET /products` - Get all products with filters
- `GET /products/:id` - Get product details
- `POST /products/:id/review` - Add product review
- `POST /orders` - Place new order
- `GET /orders` - Get buyer's orders
- `GET /orders/:id` - Get order details
- `PUT /orders/:id/cancel` - Cancel order
- `POST /addresses` - Add delivery address
- `GET /wallet` - Get wallet balance
- `POST /wallet/add` - Add money to wallet

### Seller Routes (`/api/seller`)

- `GET /products` - Get seller's products
- `POST /products` - Add new product
- `PUT /products/:id` - Update product
- `DELETE /products/:id` - Delete product
- `GET /orders` - Get seller's orders
- `GET /orders/:id` - Get order details
- `PUT /orders/:id/accept` - Accept order
- `PUT /orders/:id/pack` - Mark as packed
- `PUT /orders/:id/ship` - Mark as shipped
- `GET /analytics` - Get sales analytics

### Labour Routes (`/api/labour`)

- `GET /workers` - Get available labour workers
- `GET /workers/:id` - Get worker details
- `POST /bookings` - Book labour
- `GET /bookings` - Get farmer's bookings
- `GET /my-bookings` - Get labour's bookings
- `GET /bookings/:id` - Get booking details
- `PUT /bookings/:id/accept` - Accept booking (labour)
- `PUT /bookings/:id/start` - Start work
- `PUT /bookings/:id/complete` - Complete work
- `PUT /bookings/:id/cancel` - Cancel booking
- `POST /bookings/:id/rate` - Rate labour worker

### Transport Routes (`/api/transport`)

- `GET /drivers` - Get available drivers
- `GET /drivers/:id` - Get driver details
- `POST /bookings` - Book transport
- `GET /bookings` - Get user's bookings
- `GET /my-bookings` - Get driver's bookings
- `GET /bookings/:id` - Get booking details
- `PUT /bookings/:id/accept` - Accept booking (driver)
- `PUT /bookings/:id/pickup` - Mark as picked up
- `PUT /bookings/:id/transit` - Start transit
- `PUT /bookings/:id/deliver` - Mark as delivered
- `PUT /bookings/:id/complete` - Complete booking
- `PUT /bookings/:id/cancel` - Cancel booking
- `POST /bookings/:id/rate` - Rate driver
- `GET /bookings/:id/track` - Track booking

### Weather Routes (`/api/weather`)

- `GET /current` - Get current weather
- `GET /forecast` - Get weather forecast
- `GET /agriculture-advice` - Get agricultural advice

## Database Models

### User Schema
- Phone number authentication
- Role-based access (buyer, seller, labour, transport, delivery, admin)
- Password hashing with bcrypt
- Addresses array
- Wallet with transaction history
- Rating system

### Product Schema
- Name, category, price, stock
- Images array
- Reviews and ratings
- MOQ (Minimum Order Quantity)
- COD enabled flag
- Seller reference

### Order Schema
- Buyer and seller references
- Items array with products
- Status tracking (placed → shipped → delivered)
- Payment mode and status
- Delivery address
- Status history with timestamps

### Labour Booking Schema
- Worker and farmer references
- Work type and duration
- Location coordinates
- Status tracking
- Rating and review
- Payment status

### Transport Booking Schema
- Driver and user references
- Vehicle and load details
- Pickup and drop locations
- Status tracking with GPS
- Tracking number
- Rating and review

## Error Handling

All errors return JSON with format:
```json
{
  "error": "Error message here"
}
```

HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

## Testing the API

### Using cURL
```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"9876543210","password":"test123","fullName":"Test User","role":"buyer"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"9876543210","otp":"123456"}'
```

### Using Postman
1. Import the API collection (create one with above endpoints)
2. Set environment variable for JWT token
3. Test all routes with sample data

## Project Structure

```
backend/
├── models/           # Mongoose schemas
│   ├── User.js
│   ├── Product.js
│   └── Order.js
├── routes/           # API route handlers
│   ├── auth.js
│   ├── buyer.js
│   ├── seller.js
│   ├── labour.js
│   ├── transport.js
│   └── weather.js
├── middleware/       # Express middleware
│   └── auth.js       # JWT verification
├── server.js         # Main application
├── package.json      # Dependencies
├── .env.example      # Environment template
└── README.md         # This file
```

## Security

- Passwords are hashed using bcrypt (10 salt rounds)
- JWT tokens expire after 30 days
- Protected routes require valid JWT token
- Role-based authorization for specific actions
- Input validation using express-validator

## Future Enhancements

- [ ] Real SMS OTP integration (Twilio, MSG91)
- [ ] Image upload to cloud storage (AWS S3, Cloudinary)
- [ ] Real-time tracking with WebSockets
- [ ] Payment gateway integration (Razorpay, PayTM)
- [ ] Email notifications (SendGrid, Nodemailer)
- [ ] Rate limiting and API throttling
- [ ] Comprehensive logging system
- [ ] Unit and integration tests
- [ ] API documentation with Swagger/OpenAPI

## Troubleshooting

### MongoDB Connection Error
```
Error: connect ECONNREFUSED 127.0.0.1:27017
```
**Solution**: Ensure MongoDB is running. Check with `mongosh` command.

### JWT Secret Warning
```
Warning: JWT_SECRET not found in environment
```
**Solution**: Set `JWT_SECRET` in `.env` file with a strong random string.

### Port Already in Use
```
Error: listen EADDRINUSE: address already in use :::3000
```
**Solution**: Change `PORT` in `.env` or kill process using port 3000.

## Support

For issues and questions:
- GitHub Repository: https://github.com/vinaysahu-11/Kisan_Sahayk_app
- Open an issue with detailed description

## License

MIT License - See LICENSE file for details
