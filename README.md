# College Management System

A comprehensive Flutter-based mobile application designed to streamline college administrative tasks and enhance communication between students and teachers.

## 📱 Overview

The College Management System is a multi-module Flutter application that provides separate interfaces for students and teachers. It integrates various features essential for academic management, including attendance tracking, assignment submissions, event management, and more, all backed by Firebase services.

## ✨ Features

### For Students
- **Secure Authentication** - Login/signup with email verification
- **Attendance Tracking** - View and monitor class attendance
- **Assignment Management** - Access, submit, and track assignments
- **Event Calendar** - Stay updated with college events and schedules
- **Notice Board** - Receive important announcements and notices
- **Expense Tracker** - Manage and track educational expenses
- **AI Features** - Text-to-speech for accessibility

### For Teachers
- **Attendance Management** - Mark and manage student attendance
- **Assignment Creation** - Create, distribute, and grade assignments
- **Event Planning** - Create and manage college events
- **Notice Publishing** - Post important announcements
- **Student Performance Analytics** - Track and analyze student progress
- **File Management** - Upload and share study materials

## 🛠️ Technologies Used

- **Frontend**: Flutter & Dart
- **Backend**: Firebase
- Authentication
- Firestore Database
- Storage
- Cloud Functions
- **State Management**: Provider
- **UI Components**: Custom widgets, Material Design

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Git

### Installation

1. Clone the repository
```bash
git clone https://github.com/MogaPreet/college-management-system.git
```

2. Navigate to the project directory
```bash
cd college-management-system
```

3. Install dependencies
```bash
flutter pub get
```

4. Configure Firebase
- Create a new Firebase project
- Add Android/iOS apps to your Firebase project
- Download and add the google-services.json/GoogleService-Info.plist to the appropriate directory
- Enable Authentication, Firestore, and Storage services

5. Run the app
```bash
flutter run
```

## 📂 Project Structure

```
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   ├── assignment_model.dart
│   └── ...
├── screens/
│   ├── auth/
│   ├── student/
│   ├── teacher/
│   └── ...
├── services/
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   └── ...
├── utils/
│   ├── constants.dart
│   ├── theme.dart
│   └── ...
└── widgets/
    ├── custom_button.dart
    ├── custom_text_field.dart
    └── ...
```

## 📚 Dependencies

- **firebase_core**: Firebase core functionality
- **firebase_auth**: Authentication services
- **cloud_firestore**: NoSQL database by Firebase
- **firebase_storage**: File storage solution
- **provider**: State management
- **http**: Network requests
- **intl**: Internationalization and formatting
- **shared_preferences**: Local storage
- **path_provider**: File system locations
- **file_picker**: Select files from device
- **flutter_tts**: Text-to-speech functionality
- **flutter_pdfview**: PDF document viewing
- **charts_flutter**: Data visualization

## 📱 Screenshots

*Coming soon*

## 🔮 Future Enhancements

- Implementing video conferencing for virtual classes
- Adding a chat system for student-teacher communication
- Integration with third-party academic tools
- Extending AI capabilities for personalized learning
- Mobile payment integration for fee payments

## 👥 Contributors

- *List of contributors goes here*

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

For any inquiries or support, please contact:
- Email: preetmoga777@gmail.com
- Website: [www.collegemanagement.com](http://www.collegemanagement.com)[WIP]
