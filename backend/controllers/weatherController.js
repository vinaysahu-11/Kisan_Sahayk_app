const axios = require('axios');

// OpenWeatherMap API configuration
// Get your free API key from: https://openweathermap.org/api
const WEATHER_API_KEY = process.env.WEATHER_API_KEY || 'demo_key';
const WEATHER_API_BASE = 'https://api.openweathermap.org/data/2.5';

/**
 * Get current weather data
 */
exports.getCurrentWeather = async (req, res) => {
  try {
    const { latitude, longitude, city } = req.query;

    if (!latitude && !longitude && !city) {
      return res.status(400).json({ 
        success: false,
        error: 'Please provide either latitude/longitude or city name' 
      });
    }

    console.log('Weather API Key:', WEATHER_API_KEY ? `${WEATHER_API_KEY.substring(0, 10)}...` : 'Not set');
    console.log('API Key Length:', WEATHER_API_KEY?.length);

    // Check if API key is valid (OpenWeatherMap keys are typically 32 characters)
    if (!WEATHER_API_KEY || WEATHER_API_KEY === 'demo_key' || WEATHER_API_KEY.length !== 32) {
      // Return mock data for testing when API key is invalid
      console.log('Using mock weather data');
      return res.json({
        success: true,
        data: {
          location: {
            name: city || 'Raipur',
            latitude: parseFloat(latitude) || 21.2514,
            longitude: parseFloat(longitude) || 81.6296,
            country: 'IN',
          },
          current: {
            temperature: 28,
            feelsLike: 30,
            humidity: 65,
            pressure: 1010,
            windSpeed: 12,
            windDirection: 'NE',
            description: 'partly cloudy',
            main: 'Clouds',
            icon: '02d',
          },
          timestamp: new Date().toISOString(),
        },
        note: 'Mock data - Please configure valid WEATHER_API_KEY in .env file'
      });
    }

    let weatherUrl = `${WEATHER_API_BASE}/weather?appid=${WEATHER_API_KEY}&units=metric`;
    
    if (latitude && longitude) {
      weatherUrl += `&lat=${latitude}&lon=${longitude}`;
    } else if (city) {
      weatherUrl += `&q=${city}`;
    }

    // Call OpenWeatherMap API
    const weatherResponse = await axios.get(weatherUrl);
    const data = weatherResponse.data;

    // Format response
    const weatherData = {
      location: {
        name: data.name,
        latitude: data.coord.lat,
        longitude: data.coord.lon,
        country: data.sys.country,
      },
      current: {
        temperature: Math.round(data.main.temp),
        feelsLike: Math.round(data.main.feels_like),
        humidity: data.main.humidity,
        pressure: data.main.pressure,
        windSpeed: Math.round(data.wind.speed * 3.6), // Convert m/s to km/h
        windDirection: degreesToDirection(data.wind.deg),
        description: data.weather[0].description,
        main: data.weather[0].main,
        icon: data.weather[0].icon,
        visibility: Math.round(data.visibility / 1000), // Convert to km
        cloudiness: data.clouds.all,
        sunrise: new Date(data.sys.sunrise * 1000).toISOString(),
        sunset: new Date(data.sys.sunset * 1000).toISOString(),
      },
      timestamp: new Date(data.dt * 1000).toISOString(),
    };

    res.json({
      success: true,
      data: weatherData,
    });
  } catch (error) {
    console.error('Weather API Error:', error.message);
    
    if (error.response?.status === 401) {
      return res.status(500).json({ 
        success: false,
        error: 'Weather API key is invalid. Please configure a valid API key.' 
      });
    }
    
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch weather data',
      message: error.message 
    });
  }
};

/**
 * Get weather forecast (5 day / 3 hour)
 */
exports.getWeatherForecast = async (req, res) => {
  try {
    const { latitude, longitude, city, days = 5 } = req.query;

    if (!latitude && !longitude && !city) {
      return res.status(400).json({ 
        success: false,
        error: 'Please provide either latitude/longitude or city name' 
      });
    }

    // Check if API key is valid
    if (!WEATHER_API_KEY || WEATHER_API_KEY === 'demo_key' || WEATHER_API_KEY.length < 20) {
      // Return mock forecast data
      const mockForecast = [];
      for (let i = 0; i < parseInt(days); i++) {
        const date = new Date();
        date.setDate(date.getDate() + i);
        mockForecast.push({
          date: date.toISOString().split('T')[0],
          maxTemp: 32 + Math.floor(Math.random() * 5),
          minTemp: 22 + Math.floor(Math.random() * 3),
          avgTemp: 27 + Math.floor(Math.random() * 3),
          description: i % 2 === 0 ? 'partly cloudy' : 'clear sky',
          main: i % 2 === 0 ? 'Clouds' : 'Clear',
          icon: i % 2 === 0 ? '02d' : '01d',
          rainfall: i === 2 ? 2.5 : 0,
          humidity: 60 + Math.floor(Math.random() * 20),
          windSpeed: 10 + Math.floor(Math.random() * 10),
        });
      }

      return res.json({
        success: true,
        data: {
          location: {
            name: city || 'Raipur',
            latitude: parseFloat(latitude) || 21.2514,
            longitude: parseFloat(longitude) || 81.6296,
            country: 'IN',
          },
          forecast: mockForecast,
        },
        note: 'Mock data - Please configure valid WEATHER_API_KEY in .env file'
      });
    }

    let forecastUrl = `${WEATHER_API_BASE}/forecast?appid=${WEATHER_API_KEY}&units=metric`;
    
    if (latitude && longitude) {
      forecastUrl += `&lat=${latitude}&lon=${longitude}`;
    } else if (city) {
      forecastUrl += `&q=${city}`;
    }

    // Call OpenWeatherMap API
    const forecastResponse = await axios.get(forecastUrl);
    const data = forecastResponse.data;

    // Group forecast by day
    const dailyForecasts = {};
    data.list.forEach(item => {
      const date = item.dt_txt.split(' ')[0];
      if (!dailyForecasts[date]) {
        dailyForecasts[date] = {
          date,
          temps: [],
          conditions: [],
          humidity: [],
          rainfall: 0,
          windSpeed: [],
        };
      }
      dailyForecasts[date].temps.push(item.main.temp);
      dailyForecasts[date].conditions.push(item.weather[0]);
      dailyForecasts[date].humidity.push(item.main.humidity);
      dailyForecasts[date].windSpeed.push(item.wind.speed);
      if (item.rain) {
        dailyForecasts[date].rainfall += item.rain['3h'] || 0;
      }
    });

    // Format daily forecasts
    const forecast = Object.values(dailyForecasts).slice(0, parseInt(days)).map(day => ({
      date: day.date,
      maxTemp: Math.round(Math.max(...day.temps)),
      minTemp: Math.round(Math.min(...day.temps)),
      avgTemp: Math.round(day.temps.reduce((a, b) => a + b) / day.temps.length),
      description: day.conditions[0].description,
      main: day.conditions[0].main,
      icon: day.conditions[0].icon,
      rainfall: Math.round(day.rainfall * 10) / 10,
      humidity: Math.round(day.humidity.reduce((a, b) => a + b) / day.humidity.length),
      windSpeed: Math.round((day.windSpeed.reduce((a, b) => a + b) / day.windSpeed.length) * 3.6),
    }));

    res.json({
      success: true,
      data: {
        location: {
          name: data.city.name,
          latitude: data.city.coord.lat,
          longitude: data.city.coord.lon,
          country: data.city.country,
        },
        forecast,
      },
    });
  } catch (error) {
    console.error('Forecast API Error:', error.message);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch forecast data',
      message: error.message 
    });
  }
};

/**
 * Get agricultural weather advice
 */
exports.getAgricultureAdvice = async (req, res) => {
  try {
    const { cropType = 'General', stage = 'Growing', latitude, longitude } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ 
        success: false,
        error: 'Latitude and longitude are required' 
      });
    }
    // Check if API key is valid - if not, return mock agriculture advice
    if (!WEATHER_API_KEY || WEATHER_API_KEY === 'demo_key' || WEATHER_API_KEY.length < 20) {
      return res.json({
        success: true,
        data: {
          advice: [
            {
              priority: 'high',
              category: 'irrigation',
              title: 'Irrigation Schedule',
              description: 'Moderate temperature conditions. Water crops in early morning or late evening.',
              icon: '💧'
            },
            {
              priority: 'medium',
              category: 'pest',
              title: 'Pest Control',
              description: 'Current weather conditions may favor pest activity. Monitor crops regularly.',
              icon: '🐛'
            },
            {
              priority: 'low',
              category: 'fertilizer',
              title: 'Fertilizer Application',
              description: 'Good conditions for fertilizer application. Apply before evening.',
              icon: '🌱'
            }
          ],
          cropType,
          stage,
          timestamp: new Date().toISOString(),
        },
        note: 'Mock data - Please configure valid WEATHER_API_KEY in .env file'
      });
    }
    // Get current weather and forecast
    const weatherUrl = `${WEATHER_API_BASE}/weather?lat=${latitude}&lon=${longitude}&appid=${WEATHER_API_KEY}&units=metric`;
    const forecastUrl = `${WEATHER_API_BASE}/forecast?lat=${latitude}&lon=${longitude}&appid=${WEATHER_API_KEY}&units=metric&cnt=16`;

    const [weatherRes, forecastRes] = await Promise.all([
      axios.get(weatherUrl),
      axios.get(forecastUrl),
    ]);

    const current = weatherRes.data;
    const forecast = forecastRes.data;

    // Calculate total rainfall expected in next 48 hours
    let totalRainfall = 0;
    forecast.list.forEach(item => {
      if (item.rain) {
        totalRainfall += item.rain['3h'] || 0;
      }
    });

    // Generate recommendations based on weather
    const recommendations = [];

    // Irrigation advice
    if (totalRainfall < 5 && current.main.humidity < 60) {
      recommendations.push({
        category: 'Irrigation',
        priority: 'High',
        advice: `Low rainfall expected (${totalRainfall.toFixed(1)}mm in 48hrs). Irrigation recommended.`,
        timing: 'Next 24-48 hours',
        icon: '💧',
      });
    } else if (totalRainfall > 20) {
      recommendations.push({
        category: 'Drainage',
        priority: 'High',
        advice: `Heavy rainfall expected (${totalRainfall.toFixed(1)}mm). Ensure proper drainage.`,
        timing: 'Next 48 hours',
        icon: '🌧️',
      });
    }

    // Temperature advice
    if (current.main.temp > 35) {
      recommendations.push({
        category: 'Heat Protection',
        priority: 'High',
        advice: 'High temperatures. Provide shade for crops, increase irrigation frequency.',
        timing: 'Immediate',
        icon: '🌡️',
      });
    } else if (current.main.temp < 15) {
      recommendations.push({
        category: 'Cold Protection',
        priority: 'Medium',
        advice: 'Low temperatures. Protect sensitive crops from cold stress.',
        timing: 'Immediate',
        icon: '❄️',
      });
    }

    // Humidity and pest advice
    if (current.main.humidity > 75) {
      recommendations.push({
        category: 'Pest Control',
        priority: 'Medium',
        advice: 'High humidity increases pest and disease risk. Monitor crops regularly.',
        timing: 'Ongoing',
        icon: '🐛',
      });
    }

    // Wind advice
    if (current.wind.speed > 8) {
      recommendations.push({
        category: 'Wind Protection',
        priority: 'Medium',
        advice: `Strong winds (${Math.round(current.wind.speed * 3.6)} km/h). Provide support for crops.`,
        timing: 'Immediate',
        icon: '💨',
      });
    }

    // Fertilizer timing
    if (totalRainfall < 2) {
      recommendations.push({
        category: 'Fertilizer Application',
        priority: 'Low',
        advice: 'Good time for fertilizer application. No heavy rain expected.',
        timing: 'Next 2-3 days',
        icon: '🌱',
      });
    }

    const advice = {
      cropType,
      stage,
      location: {
        latitude: current.coord.lat,
        longitude: current.coord.lon,
        name: current.name,
      },
      recommendations,
      weatherSummary: {
        temperature: `${Math.round(current.main.temp)}°C`,
        humidity: `${current.main.humidity}%`,
        rainfall48h: `${totalRainfall.toFixed(1)}mm`,
        windSpeed: `${Math.round(current.wind.speed * 3.6)} km/h`,
        condition: current.weather[0].description,
      },
      soilConditions: {
        estimatedMoisture: calculateSoilMoisture(current.main.humidity, totalRainfall),
        recommendation: getSoilRecommendation(current.main.humidity, totalRainfall),
      },
    };

    res.json({
      success: true,
      data: advice,
    });
  } catch (error) {
    console.error('Agriculture Advice Error:', error.message);
    res.status(500).json({ 
      success: false,
      error: 'Failed to generate agriculture advice',
      message: error.message 
    });
  }
};

// Helper functions
function degreesToDirection(degrees) {
  const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
  const index = Math.round(degrees / 22.5) % 16;
  return directions[index];
}

function calculateSoilMoisture(humidity, rainfall) {
  let moisture = 'Medium';
  if (humidity > 70 || rainfall > 10) {
    moisture = 'High';
  } else if (humidity < 50 && rainfall < 2) {
    moisture = 'Low';
  }
  return moisture;
}

function getSoilRecommendation(humidity, rainfall) {
  if (humidity < 50 && rainfall < 2) {
    return 'Soil moisture is likely low. Irrigation recommended.';
  } else if (humidity > 70 || rainfall > 15) {
    return 'Soil moisture is high. Avoid over-watering and ensure drainage.';
  }
  return 'Soil moisture is adequate. Monitor regularly.';
}
