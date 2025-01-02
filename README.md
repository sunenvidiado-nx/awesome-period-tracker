<p align="center">
    <img src="assets/readme_icon.png" alt="Awesome Period Tracker" width="120"/>
</p>

# Awesome Period Tracker

An awesome period tracker app, because your cycle deserves a standing ovulation. Built with Flutter. 🩵

## Features

- Track cycle events (period, fertile days, symptoms, intimacy).
- Generate insights powered by Google Gemini.
- Get accurate cycle phase predictions.
- More features coming soon(ish).

## Setup

1. Clone the repository:
    ```bash
    git clone https://github.com/sunenvidiado-nx/awesome-period-tracker.git
    ```

2. Set up Firebase:
    - Follow the instructions [here](https://firebase.google.com/docs/flutter/setup).

3. Create a Firebase account to log in to the app:
    - The email address used will be the `LOGIN_EMAIL` for the environment configuration.
    - The login screen is simplified for personal use. It only requires a 6-digit password. Feel free to modify this implementation as needed.

4. Generate an API key for Google Gemini:
    - Follow the instructions [here](https://ai.google.dev/gemini-api/docs/api-key).
    - This will be your `GEMINI_API_KEY`.

5. Get an API key for Women's Health API:
    - Sign up at [RapidAPI](https://rapidapi.com/datafenix-datafenix-default/api/womens-health-menstrual-cycle-phase-predictions-insights).
    - Subscribe to get your API key.
    - This will be your `CYCLE_PHASE_API_KEY`.
    - Copy the API URL from RapidAPI for `CYCLE_PHASE_API_URL`.

6. Create a `.env` file in the root directory with your values:
    ```env
    LOGIN_EMAIL=your@email.here
    GEMINI_API_KEY=your_gemini_api_key
    SYSTEM_ID=your_system_id
    CYCLE_PHASE_API_KEY=your_rapidapi_key
    CYCLE_PHASE_API_URL=your_rapidapi_url
    ```

7. Run `build_runner` to generate the necessary code:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

8. Generate the localizations:
    ```bash
    flutter gen-l10n
    ```

9. Run the app:
    ```bash
    flutter run
    ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
