const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');

// Weather API endpoint (proxy to external weather service)
// You can integrate with OpenWeatherMap, WeatherAPI, or similar services
router.get('/current', authMiddleware, async (req, res) => {
  try {
    const { latitude, longitude, city } = req.query;

    if (!latitude && !longitude && !city) {
      return res.status(400).json({ 
        error: 'Please provide either latitude/longitude or city name' 
      });
    }

    // Mock weather data for demonstration
    // In production, replace with actual API call to weather service
    const mockWeatherData = {
      location: {
        name: city || 'Current Location',
        latitude: latitude || 28.6139,
        longitude: longitude || 77.2090
      },
      current: {
        temperature: 28,
        feelsLike: 30,
        humidity: 65,
        windSpeed: 12,
        windDirection: 'NW',
        description: 'Partly Cloudy',
        icon: '02d',
        uv: 6,
        visibility: 10,
        pressure: 1013
      },
      forecast: [
        {
          date: new Date().toISOString().split('T')[0],
          maxTemp: 32,
          minTemp: 22,
          description: 'Partly Cloudy',
          icon: '02d',
          rainfall: 0,
          humidity: 60
        },
        {
          date: new Date(Date.now() + 86400000).toISOString().split('T')[0],
          maxTemp: 30,
          minTemp: 21,
          description: 'Light Rain',
          icon: '10d',
          rainfall: 5,
          humidity: 75
        },
        {
          date: new Date(Date.now() + 172800000).toISOString().split('T')[0],
          maxTemp: 29,
          minTemp: 20,
          description: 'Cloudy',
          icon: '03d',
          rainfall: 2,
          humidity: 70
        },
        {
          date: new Date(Date.now() + 259200000).toISOString().split('T')[0],
          maxTemp: 31,
          minTemp: 22,
          description: 'Sunny',
          icon: '01d',
          rainfall: 0,
          humidity: 55
        },
        {
          date: new Date(Date.now() + 345600000).toISOString().split('T')[0],
          maxTemp: 33,
          minTemp: 23,
          description: 'Sunny',
          icon: '01d',
          rainfall: 0,
          humidity: 50
        }
      ],
      alerts: [
        {
          type: 'Heat Wave',
          severity: 'Moderate',
          description: 'High temperatures expected in the next 48 hours',
          startTime: new Date().toISOString(),
          endTime: new Date(Date.now() + 172800000).toISOString()
        }
      ],
      agriculture: {
        soilMoisture: 45, // percentage
        evapotranspiration: 4.5, // mm/day
        recommendation: 'Irrigation recommended in next 2-3 days'
      }
    };

    // TODO: Replace with actual weather API integration
    // Example with OpenWeatherMap:
    // const apiKey = process.env.WEATHER_API_KEY;
    // const response = await axios.get(`https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${apiKey}`);
    // const weatherData = response.data;

    res.json(mockWeatherData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get weather forecast
router.get('/forecast', authMiddleware, async (req, res) => {
  try {
    const { latitude, longitude, city, days = 7 } = req.query;

    if (!latitude && !longitude && !city) {
      return res.status(400).json({ 
        error: 'Please provide either latitude/longitude or city name' 
      });
    }

    // Mock forecast data
    const forecastData = {
      location: {
        name: city || 'Current Location',
        latitude: latitude || 28.6139,
        longitude: longitude || 77.2090
      },
      forecast: Array.from({ length: parseInt(days) }, (_, i) => ({
        date: new Date(Date.now() + i * 86400000).toISOString().split('T')[0],
        maxTemp: Math.floor(Math.random() * 10) + 28,
        minTemp: Math.floor(Math.random() * 5) + 18,
        description: ['Sunny', 'Partly Cloudy', 'Cloudy', 'Light Rain'][Math.floor(Math.random() * 4)],
        icon: ['01d', '02d', '03d', '10d'][Math.floor(Math.random() * 4)],
        rainfall: Math.floor(Math.random() * 10),
        humidity: Math.floor(Math.random() * 30) + 50,
        windSpeed: Math.floor(Math.random() * 15) + 5
      }))
    };

    res.json(forecastData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get agricultural weather advice
router.get('/agriculture-advice', authMiddleware, async (req, res) => {
  try {
    const { cropType, stage, latitude, longitude } = req.query;

    // Mock agricultural advice based on weather
    const advice = {
      cropType: cropType || 'General',
      stage: stage || 'Growing',
      recommendations: [
        {
          category: 'Irrigation',
          priority: 'High',
          advice: 'Water crops early morning or late evening. Soil moisture is low.',
          timing: 'Next 24-48 hours'
        },
        {
          category: 'Pest Control',
          priority: 'Medium',
          advice: 'High humidity may increase pest activity. Monitor crops regularly.',
          timing: 'Ongoing'
        },
        {
          category: 'Fertilizer',
          priority: 'Low',
          advice: 'Good time to apply fertilizer. No rain expected for next 3 days.',
          timing: 'Next 2-3 days'
        }
      ],
      weatherImpact: {
        temperature: 'Favorable for crop growth',
        rainfall: 'Insufficient rainfall expected',
        humidity: 'Moderate to high humidity levels',
        overall: 'Good conditions with irrigation support'
      }
    };

    res.json(advice);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
