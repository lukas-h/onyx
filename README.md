<div align="center">
    <img src="https://onyx.md/assets/images/Onyx%20Logo.png" alt="Onyx.md Logo" width="80" height="80">
    <h3 align="center">onyx.md</h3>
    <p align="center">
        Open-source, lightweight knowledge management and Obsidian alternative with Flutter!
        <br />
        <br />
        <a href="#"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/lukas-h/onyx?style=for-the-badge" /></a>
    </p>
</div>

<details>
    <summary>Table of Contents</summary>
    <ol>
        <li>
        <a href="#about-the-project">About The Project</a>
        <ul>
            <li><a href="#built-with">Built With</a></li>
        </ul>
        </li>
        <li>
        <a href="#getting-started">Getting Started</a>
        <ul>
            <li><a href="#installation">Installation</a></li>
        </ul>
        <li><a href="#contributing">Contributing</a></li>
    </ol>
</details>

## About The Project

Onyx.md is an open-source project originally developed and maintained by Lukas Himsel of Scalabs UB as a simple and lightweight alternative to Obsidian. It functions as a knowledge base and note-taking app using markdown files. The project was taken over in March 2025 by Ben Rycroft, Ryan Comerford, Rohan Shreshta, and Rohan Yogesh Mhadgut from RMIT University Melbourne as our final-year project, supervised by Amir Homayoon Ashrafzadeh.

The objective of the capstone project is to develop essential features to compete with existing popular note-taking apps including while also adding AI integrations by default to give Onyx.md an edge.

We hope you find Onyx.md useful to all those with a need a to organise their knowledge! If it helps you, don't forget to give the project a star! Thanks again!

Key Features:

-   Markdown editing
-   Daily journals and calendar view
-   AI integration
-   Local file synchronisation
-   Cloud storage with PocketBase
-   Git integration
-   Knowledge graph
-   LaTeX support
-   Calculator functionality
-   Codeblocks
-   Favourites & recents

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

Onyx.md uses flutter and dart to natively compile to pretty much any device! Data is synchronised across devices using a user-hosted Pocketbase backend.

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />  
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/PocketBase-B8DBE4?style=for-the-badge&logo=PocketBase&logoColor=white" />

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

Onyx.md is a multi-platform application developed for Web, Android, iOS, macOS, Windows, and Linux.
The app is built using Flutter, which eliminates the need for different tech stacks for each platform during development. However, to test and deploy Onyx across platforms, contributors will need to set up specific tools based on the target platform.
Below is a list of tools and environments that must be installed on your machine to fully support Onyx development, testing, and deployment.

Framework: The specific Flutter version for the developer machine can be downloaded and installed from their website.

IDE: [Visual Studio Code (VS Code)](https://code.visualstudio.com/download) and [Android Studio](https://developer.android.com/studio) are two most popular IDEs for Flutter development.

Once you have installed the preferred IDE you will need to install the Flutter extension which is also explained in the Flutter installation website mentioned above.

Additional tools for testing and deployment

-   Android Studio – Required for testing and deploying the Android app.
-   Xcode – Required for testing and deploying iOS and macOS apps. It can be downloaded from App Store.
-   Google Chrome – Required for testing web apps.
-   Visual Studio – Required for C++ build tools to test and deploy Windows app.

### Installation

1. Clone the repo
    ```sh
    git clone https://github.com/lukas-h/onyx.git
    ```
1. Install [pub.dev](https://pub.dev) packages
    ```sh
    flutter pub get
    ```
1. Launch the app
    ```sh
    flutter run
    ```
1. Select the platform you'd like to run and away you go!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

Contributions are welcome to help make Onyx.md the best open-source knowledge management app. They are are **greatly appreciated**.

If you have a suggestion, please fork the repo and create a pull request. You can also simply open an issue with the tag "feature request".

1.  Fork the Project
2.  Create your feature branch prefixed with feature/ or bug/.
3.  Commit your changes. Please ensure they are small and focused with a clear message.
4.  Push to the branch
5.  Open a pull request. The PR will be reviewed before merging. The reviewer will check for:
    -   Code correctness
    -   Flutter & Dart best practices
    -   Readability and maintainability
    -   UI consistency

### Top Contributors

<a href="https://github.com/lukas-h/onyx/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=lukas-h/onyx" alt="Onyx.md Top Contributors" />
</a>

### Code & Comment Standards

#### Files and Folder Structure:

Use lowercase_with_underscore for file and folder name. For example, profile_screen.dart or home_page.dart.

#### Formatting & Naming Conventions

-   Use PascalCase for classes and enums: `class UserProfile{}`
-   Use camelCase for variables, functions and parameters: `var name;`, `void fetchUserData() {}`
-   Use camelCase or UPPERCASE_WITH_UNDERSCORES for constants: `const maxItemCount = 100;`, `const String API_URL = “https://api.example.com”;`
-   Keep line length below 80 characters if possible with a maximum of 120 characters
-   Always use curly braces for control statements
    ```dart
    if (isLoggedIn) {
      navigateToHome();
    }
    ```
-   Use proper indentation (2 spaces)
    ```dart
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
          child: Text("Hello"),
        ),
      );
    }
    ```

#### Null-safety

Use nullable type only when necessary.

-   `String? name; // nullable`
-   `String fullName; // non-nullable`

#### Widget Building

Prefer extracting widgets into smaller classes for readability and reusability, and use const constructors where possible for performance.

#### Commenting Standards

Documentation comments (`///`) are is used for public APIs such as classes, methods and fields. Triple slashes are used to describe what function/class does.

```dart
/// A widget that displays a user profile picture.
class ProfileAvatar extends StatelessWidget {
  /// Creates a [ProfileAvatar] with an optional image URL.
  const ProfileAvatar({this.imageUrl});
}
```

Inline comments (`//`) are used for short, meaningful explanations inside code blocks.

```dart
// Check if the user is logged in
if (user == null) {
  navigateToLogin();
}
```

Block comments (`/\* \*/`) are used to temporarily disable code blocks or long explanations.

#### Help Tools

The `flutter_lint` package is used in the project to identify, suggest and fix issue while coding to maintain the coding standard. You can add linting rules to the `analysis_options.yaml file` in the project.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
