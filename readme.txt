Installation Guide for Flutter Application
1. Install Required Tools:
    Flutter SDK: Download and install from flutter.dev
    Dart SDK: Bundled with Flutter, no need for a separate installation.
    Android Studio (or another IDE like Visual Studio Code): Install from developer.android.com.
    Device/Emulator: Use a physical device with developer mode enabled or set up an emulator via Android Studio.
 * Verify Flutter Installation:
     flutter doctor
2. Install Packages
     flutter pub get
3. Set Up API Keys
    Locate the Config class in the project (lib/config.dart).
    Add the required API keys in the Config class
    class Config {
    static const String api_weather_key = '<your_weather_api_key>';
    static const String api_geo_key = '<your_geo_api_key>';
    static const String api_mapbox_key = '<your_mapbox_api_key>';
    static const String api_opencage_key = '<your_opencage_api_key>';
    static const String api_gongmap_key = '<your_gongmap_api_key>';
    Config();
    }
 *  Example of Key Usage
        If you are using services like Mapbox, OpenCage, or other APIs, ensure the API keys are properly integrated in 
        the widgets or functions requiring them.
4. Run the Application
    Connect your device or start an emulator.
    Run the following command in the terminal:
        flutter run
5. Build for Deployment:
    For Android:
        flutter build apk
    For iOS (requires a macOS system with Xcode installed)
        flutter build ios
6. Notes:
    Test all API keys and configurations in a development environment before deploying.
    Ensure that API keys are stored securely and are not hardcoded in the production environment. Use Flutter's environment 
    configurations or .env packages for better security if needed.