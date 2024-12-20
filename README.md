<p align="center">
    <img src="assets/readme_icon.png" alt="Awesome Period Tracker" width="120"/>
</p>

# Awesome Period Tracker

A simple yet awesome period tracker app, because your cycle deserves a standing ovulation. Built with Flutter. 🩵

## Features

- Track cycle events (period, fertile days, symptoms, intimacy).
- Generate insights powered by Google Gemini.
- More features coming soon(ish).

## Setup

1. Clone the repository:
    ```bash
    git clone https://github.com/sunenvidiado-nx/awesome-period-tracker.git
    ```

2. Set up Firebase:
    - Follow the instructions [here](https://firebase.google.com/docs/flutter/setup).

3. Create a Firebase account to log in to the app:
    - The email address used will be the `LOGIN_EMAIL` for the `.env` file.
    - The login screen is simplified for personal use. It only requires a 6-digit password. Feel free to modify this implementation as needed.

4. Generate an API key for Google Gemini. Follow the instructions [here](https://ai.google.dev/gemini-api/docs/api-key).

5. Add a `.env` file and set the values for `LOGIN_EMAIL`, `GEMINI_API_KEY`, `SYSTEM_ID`, and `CYCLE_EVENTS_PATH`.
    ```env
    LOGIN_EMAIL=your@email.here
    GEMINI_API_KEY=y0ur_ap1_k3y_h3r3
    SYSTEM_ID=systemId
    CYCLE_EVENTS_PATH=cycle_events_path_set_in_firebase
    ```

6. Run `build_runner` to generate the necessary code:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

7. Generate the localizations:
    ```bash
    flutter gen-l10n
    ```

8. Run the app:
    ```bash
    flutter run
    ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
