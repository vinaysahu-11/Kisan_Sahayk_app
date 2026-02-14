const express = require('express');
const router = express.Router();
const weatherController = require('../controllers/weatherController');

// Get current weather (public)
router.get('/current', weatherController.getCurrentWeather);

// Get weather forecast (public)
router.get('/forecast', weatherController.getWeatherForecast);

// Get agricultural weather advice (public)
router.get('/agriculture-advice', weatherController.getAgricultureAdvice);

module.exports = router;
