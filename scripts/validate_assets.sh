#!/bin/bash

# Asset validation script for TeenTalk Flutter app
# This script validates that the required asset structure exists

echo "🔍 Validating TeenTalk asset structure..."

# Check if assets directory exists
if [ ! -d "assets" ]; then
    echo "❌ assets directory not found"
    exit 1
fi
echo "✅ assets directory exists"

# Check if images directory exists
if [ ! -d "assets/images" ]; then
    echo "❌ assets/images directory not found"
    exit 1
fi
echo "✅ assets/images directory exists"

# Check if icons directory exists
if [ ! -d "assets/icons" ]; then
    echo "❌ assets/icons directory not found"
    exit 1
fi
echo "✅ assets/icons directory exists"

# Check for placeholder files
echo ""
echo "📁 Checking placeholder files in assets/images:"
for file in logo.png.placeholder logo@2x.png.placeholder logo@3x.png.placeholder splash.png.placeholder splash@2x.png.placeholder splash@3x.png.placeholder; do
    if [ -f "assets/images/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
    fi
done

echo ""
echo "📁 Checking placeholder files in assets/icons:"
for file in home.png.placeholder chat.png.placeholder profile.png.placeholder settings.png.placeholder; do
    if [ -f "assets/icons/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
    fi
done

# Check pubspec.yaml assets section
echo ""
echo "📄 Checking pubspec.yaml assets configuration:"
if grep -q "assets:" pubspec.yaml; then
    echo "  ✅ assets section found in pubspec.yaml"
else
    echo "  ❌ assets section not found in pubspec.yaml"
    exit 1
fi

if grep -q "assets/images/" pubspec.yaml; then
    echo "  ✅ assets/images/ configured in pubspec.yaml"
else
    echo "  ❌ assets/images/ not configured in pubspec.yaml"
    exit 1
fi

if grep -q "assets/icons/" pubspec.yaml; then
    echo "  ✅ assets/icons/ configured in pubspec.yaml"
else
    echo "  ❌ assets/icons/ not configured in pubspec.yaml"
    exit 1
fi

echo ""
echo "🎉 Asset structure validation complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Replace .placeholder files with actual PNG images"
echo "   2. Run 'flutter pub get' to update dependencies"
echo "   3. Test the app with 'flutter run'"
echo ""
echo "💡 See assets/README.md for detailed guidelines"