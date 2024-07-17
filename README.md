<center>
    <img src="assets/readme_icon.png" alt="Awesome Period Tracker" width="120"/>
</center>

# Awesome Period Tracker

A simple yet awesome period tracker app, because your cycle deserves a standing ovulation. Built with Flutter. 🩵

## Features

- Track your period.
- That's it (for now).

## Setup

1. Clone the repository.
    ```bash
    git clone https://github.com/sunenvidiado-nx/awesome-period-tracker.git
    ```

2. Set up Firebase. More info here: https://firebase.google.com/docs/flutter/setup. After that, move the generated `firebase_options.dart` file to the `lib/core` directory.

3. Add a `.env` file and set a value for the `LOGIN_EMAIL` key.
    ```bash
    LOGIN_EMAIL=your_email_here
    ```

4. Run `build_runner`.
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
    Generate the localizations.
    ```bash
    flutter gen-l10n
    ```

5. Run the app.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.