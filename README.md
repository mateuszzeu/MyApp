Stronger

Stronger is a fitness app that I am currently developing in my free time with SwiftUI, inspired by the personal need for a streamlined workout planner for myself and my close friends.
The app helps users create, manage, and track workout routines while seamlessly storing data in the cloud using Firebase.

Features
- Workout Management: 
  - Create custom workout days and exercises.
  - Edit, delete, and reorder exercises.
  - Save all progress to the cloud for easy access across devices.
- User Authentication: 
  - Register, log in, and reset your password using Firebase Authentication.
  - Secure account updates and data synchronization.
- Progress Tracking:
  - Interactive visualizations for monitoring progress.
  - Responsive, user-friendly design built entirely with SwiftUI.
- Water Intake Tracking:
  - Keep track of your daily hydration goals with an intuitive and visually engaging interface.

Getting Started

1. Clone the repository

2. Set up Firebase:

- Log in to the Firebase Console and create a new project.
- Enable the following services:
  Authentication → Select "Email and Password".
  Cloud Firestore → Create a database in test mode.
- Download the GoogleService-Info.plist file:
  Go to Project Settings → General → iOS app → Download the configuration file.
  
- Drag and drop the GoogleService-Info.plist file into the project in Xcode (place it in the main app folder).

3. Open the project in Xcode and run the app.


