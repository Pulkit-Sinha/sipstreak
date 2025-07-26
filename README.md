# SipStreak - Smart Water Tracker

Stay hydrated with personalized daily water goals! SipStreak calculates your ideal water intake based on your body stats, activity level, and local weather conditions.

## Features

- **Smart Goals** - Personalized targets that adjust to weather and your lifestyle
- **Quick Logging** - One-tap tracking with customizable container presets
- **Progress Charts** - Visual tracking with weekly and monthly insights  
- **Achievement Celebrations** - Fun animations when you hit your daily goal
- **Weather Integration** - Automatic adjustments for hot or humid days
- **Complete History** - Track your hydration habits over time

## Setup

### Prerequisites

- Flutter SDK (>=3.4.4)
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sipstreak.git
   cd sipstreak
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   
   Get a free API key from [OpenWeatherMap](https://openweathermap.org/api) and add it to your `.env` file:
   ```
   OPENWEATHERMAP_API_KEY=your_actual_api_key_here
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Environment Configuration

The app requires an OpenWeatherMap API key for weather-based hydration calculations:

1. Sign up for a free account at [OpenWeatherMap](https://openweathermap.org/api)
2. Generate an API key from your account dashboard
3. Add the key to your `.env` file (never commit this file!)

The app will gracefully fall back to basic hydration calculations if weather data is unavailable.

## Privacy & Permissions

SipStreak respects your privacy:

- **Location**: Uses approximate location only for local weather data
- **Data Storage**: All personal data stored locally on your device
- **No Tracking**: No analytics or user tracking
- **No Account**: No account creation required

Required permissions:
- **Location (Coarse)**: For weather-based hydration adjustments

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions, please open an issue on GitHub or contact aryantopulkit2@gmail.com