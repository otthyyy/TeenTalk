#!/bin/bash

# Firebase Setup Script
# This script helps with initial Firebase project setup

set -e

echo "🔥 Firebase Setup Script"
echo "========================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if user is logged in to Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install Firebase CLI first."
    echo "Visit: https://firebase.google.com/docs/cli#install-cli"
    exit 1
fi

echo "✅ Flutter and Firebase CLI are installed"

# Get project information
echo ""
echo "Please provide your Firebase project information:"
read -p "Firebase Project ID: " project_id
read -p "Firebase API Key: " api_key
read -p "Firebase Auth Domain (e.g., project.firebaseapp.com): " auth_domain
read -p "Firebase Storage Bucket (e.g., project.appspot.com): " storage_bucket
read -p "Firebase Messaging Sender ID: " sender_id
read -p "Firebase App ID: " app_id

# Create .env file
echo ""
echo "Creating .env file..."

cat > .env << EOF
# Firebase Configuration - Development Environment
FIREBASE_API_KEY=$api_key
FIREBASE_AUTH_DOMAIN=$auth_domain
FIREBASE_PROJECT_ID=$project_id
FIREBASE_STORAGE_BUCKET=$storage_bucket
FIREBASE_MESSAGING_SENDER_ID=$sender_id
FIREBASE_APP_ID=$app_id

# Environment
FLUTTER_ENV=dev
EOF

echo "✅ .env file created"

# Install Flutter dependencies
echo ""
echo "Installing Flutter dependencies..."
flutter pub get

echo "✅ Dependencies installed"

# iOS setup (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo "Setting up iOS dependencies..."
    cd ios
    pod install
    cd ..
    echo "✅ iOS dependencies installed"
fi

echo ""
echo "🎉 Firebase setup completed!"
echo ""
echo "Next steps:"
echo "1. Download google-services.json from Firebase Console and place it in android/app/"
echo "2. Download GoogleService-Info.plist from Firebase Console and place it in ios/Runner/"
echo "3. Run 'flutter run' to start the application"
echo "4. Test Firebase services using the built-in test screen"
echo ""
echo "For detailed instructions, see FIREBASE_SETUP.md"