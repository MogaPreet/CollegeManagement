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
- **Expense Tracker**
- Record and categorize educational expenses
- Generate monthly spending reports
- Set budget limits with alerts
- Export financial data for reimbursements
- **AI Features**
- Text-to-speech for document reading and accessibility
- Speech-to-text for hands-free note taking
- Gemini AI integration for academic assistance and research
- Smart notifications with context-aware reminders

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
│   ├── expense_model.dart
│   ├── event_model.dart
│   └── ...
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── ...
│   ├── student/
│   │   ├── dashboard_screen.dart
│   │   ├── attendance_screen.dart
│   │   ├── expense_tracker/
│   │   ├── ai_features/
│   │   └── ...
│   ├── teacher/
│   │   ├── teacher_dashboard.dart
│   │   ├── class_management.dart
│   │   └── ...
│   ├── common/
│   └── ...
├── services/
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   ├── expense_service.dart
│   ├── ai_service.dart
│   ├── tts_service.dart
│   ├── stt_service.dart
│   └── ...
├── utils/
│   ├── constants.dart
│   ├── theme.dart
│   ├── helpers.dart
│   └── ...
└── widgets/
    ├── custom_button.dart
    ├── custom_text_field.dart
    ├── expense_card.dart
    ├── ai_chat_widget.dart
    └── ...
```

## 📚 Dependencies

- **Firebase Packages**
- **firebase_core**: ^2.4.1 - Firebase core functionality
- **firebase_auth**: ^4.2.5 - Authentication services
- **cloud_firestore**: ^4.3.1 - NoSQL database by Firebase
- **firebase_storage**: ^11.0.10 - File storage solution

- **State Management**
- **provider**: ^6.0.5 - State management solution
- **shared_preferences**: ^2.0.17 - Local storage for app preferences

- **UI & Functionality**
- **google_fonts**: ^4.0.3 - Custom typography
- **flutter_spinkit**: ^5.1.0 - Loading animations
- **intl**: ^0.17.0 - Internationalization and formatting
- **http**: ^0.13.5 - Network requests
- **path_provider**: ^2.0.12 - File system locations
- **file_picker**: ^5.2.5 - Select files from device
- **url_launcher**: ^6.1.8 - Launch URLs externally

- **AI & Media Features**
- **flutter_tts**: ^3.6.3 - Text-to-speech functionality
- **speech_to_text**: ^6.1.1 - Voice recognition and dictation
- **google_generative_ai**: ^0.1.0 - Gemini AI integration
- **flutter_pdfview**: ^1.2.5 - PDF document viewing
- **camera**: ^0.10.3 - Camera access for document scanning

- **Data & Analytics**
- **fl_chart**: ^0.62.0 - Interactive charts for expense tracking
- **sqflite**: ^2.2.4+1 - Local SQLite database
- **excel**: ^2.1.0 - Export data to spreadsheets
- **pdf**: ^3.9.0 - Generate PDF reports

## 📱 Screenshots

*Coming soon*

## 🔮 Future Enhancements

- Implementing video conferencing for virtual classes
- Adding a chat system for student-teacher communication
- Integration with third-party academic tools
- Extending AI capabilities for personalized learning experiences
- Implementing offline mode with data synchronization
- Adding gamification elements to increase student engagement
- Mobile payment integration for fee payments

## 👥 Contributors

- *List of contributors goes here*

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

For any inquiries or support, please contact:
- Email: preetmoga777@gmail.com
- Website: [www.collegemanagement.com](http://www.collegemanagement.com)[WIP]
