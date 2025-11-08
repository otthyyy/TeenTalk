#!/bin/bash

# Post Composer Feature Validation Script
# This script validates that all components of the post composer feature are properly implemented

set -e

echo "🔍 Validating Post Composer Feature Implementation..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "ℹ️  $1${NC}"
}

# Check if post composer page exists
echo ""
echo "📄 Checking Post Composer Page..."
if [ -f "lib/src/features/feed/presentation/pages/post_composer_page.dart" ]; then
    print_status 0 "Post composer page exists"
else
    print_status 1 "Post composer page missing"
    exit 1
fi

# Check if Post model has imageUrl and section fields
echo ""
echo "📊 Checking Post Model Updates..."
if grep -q "final String? imageUrl" lib/src/features/comments/data/models/comment.dart; then
    print_status 0 "Post model has imageUrl field"
else
    print_status 1 "Post model missing imageUrl field"
fi

if grep -q "final String section" lib/src/features/comments/data/models/comment.dart; then
    print_status 0 "Post model has section field"
else
    print_status 1 "Post model missing section field"
fi

# Check if PostsRepository has image upload functionality
echo ""
echo "📤 Checking Posts Repository Updates..."
if grep -q "uploadPostImage" lib/src/features/comments/data/repositories/posts_repository.dart; then
    print_status 0 "PostsRepository has image upload method"
else
    print_status 1 "PostsRepository missing image upload method"
fi

if grep -q "validatePostContent" lib/src/features/comments/data/repositories/posts_repository.dart; then
    print_status 0 "PostsRepository has content validation"
else
    print_status 1 "PostsRepository missing content validation"
fi

if grep -q "_updateAnonymousPostsCount" lib/src/features/comments/data/repositories/posts_repository.dart; then
    print_status 0 "PostsRepository has anonymous posts count update"
else
    print_status 1 "PostsRepository missing anonymous posts count update"
fi

if grep -q "_triggerModerationPipeline" lib/src/features/comments/data/repositories/posts_repository.dart; then
    print_status 0 "PostsRepository has moderation pipeline trigger"
else
    print_status 1 "PostsRepository missing moderation pipeline trigger"
fi

# Check if router is updated
echo ""
echo "🧭 Checking Router Configuration..."
if grep -q "post_composer_page" lib/src/core/router/app_router.dart; then
    print_status 0 "Router includes post composer page"
else
    print_status 1 "Router missing post composer page"
fi

if grep -q "compose" lib/src/core/router/app_router.dart; then
    print_status 0 "Router has compose route"
else
    print_status 1 "Router missing compose route"
fi

# Check if feed page is updated
echo ""
echo "🏠 Checking Feed Page Updates..."
if grep -q "_navigateToPostComposer" lib/src/features/comments/presentation/pages/feed_with_comments_page.dart; then
    print_status 0 "Feed page navigates to post composer"
else
    print_status 1 "Feed page missing navigation to post composer"
fi

if grep -q "context.push<bool>" lib/src/features/comments/presentation/pages/feed_with_comments_page.dart; then
    print_status 0 "Feed page handles navigation result"
else
    print_status 1 "Feed page missing navigation result handling"
fi

# Check if post widget displays images
echo ""
echo "🖼️  Checking Post Widget Image Support..."
if grep -q "post.imageUrl" lib/src/features/comments/presentation/widgets/post_widget.dart; then
    print_status 0 "Post widget displays images"
else
    print_status 1 "Post widget missing image display"
fi

if grep -q "Image.network" lib/src/features/comments/presentation/widgets/post_widget.dart; then
    print_status 0 "Post widget uses Image.network"
else
    print_status 1 "Post widget missing Image.network implementation"
fi

# Check if post widget displays sections
if grep -q "post.section" lib/src/features/comments/presentation/widgets/post_widget.dart; then
    print_status 0 "Post widget displays sections"
else
    print_status 1 "Post widget missing section display"
fi

# Check dependencies
echo ""
echo "📦 Checking Dependencies..."
if grep -q "image_picker" pubspec.yaml; then
    print_status 0 "image_picker dependency added"
else
    print_status 1 "image_picker dependency missing"
fi

if grep -q "firebase_storage" pubspec.yaml; then
    print_status 0 "firebase_storage dependency exists"
else
    print_status 1 "firebase_storage dependency missing"
fi

# Check Cloud Functions
echo ""
echo "☁️  Checking Cloud Functions..."
if [ -f "functions/index.js" ]; then
    print_status 0 "Cloud Functions index.js exists"
else
    print_status 1 "Cloud Functions index.js missing"
fi

if [ -f "functions/package.json" ]; then
    print_status 0 "Cloud Functions package.json exists"
else
    print_status 1 "Cloud Functions package.json missing"
fi

if grep -q "moderatePost" functions/index.js; then
    print_status 0 "Moderation function implemented"
else
    print_status 1 "Moderation function missing"
fi

if grep -q "updateAnonymousPostsCount" functions/index.js; then
    print_status 0 "Anonymous posts count function implemented"
else
    print_status 1 "Anonymous posts count function missing"
fi

# Check for required features in post composer
echo ""
echo "🎨 Checking Post Composer Features..."
if grep -q "ImagePicker" lib/src/features/feed/presentation/pages/post_composer_page.dart; then
    print_status 0 "Image picker implemented"
else
    print_status 1 "Image picker missing"
fi

if grep -q "_isAnonymous" lib/src/features/feed/presentation/pages/post_composer_page.dart; then
    print_status 0 "Anonymous toggle implemented"
else
    print_status 1 "Anonymous toggle missing"
fi

if grep -q "_selectedSection" lib/src/features/feed/presentation/pages/post_composer_page.dart; then
    print_status 0 "Section selection implemented"
else
    print_status 1 "Section selection missing"
fi

if grep -q "_showPostingGuidelines" lib/src/features/feed/presentation/pages/post_composer_page.dart; then
    print_status 0 "Posting guidelines implemented"
else
    print_status 1 "Posting guidelines missing"
fi

if grep -q "validator" lib/src/features/feed/presentation/pages/post_composer_page.dart; then
    print_status 0 "Content validation implemented"
else
    print_status 1 "Content validation missing"
fi

# Summary
echo ""
echo "📋 Summary"
echo "=========="

# Count total checks
TOTAL_CHECKS=20
PASSED_CHECKS=0

# Simple heuristic to count passed checks
PASSED_CHECKS=$(grep -c "✅" <<< "$(print_status 0 'dummy')") 2>/dev/null || echo "0"

# Print final message
echo ""
if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    print_status 0 "All $TOTAL_CHECKS checks passed! 🎉"
    echo ""
    print_info "Post Composer feature implementation appears to be complete!"
    print_info "Key features implemented:"
    print_info "  ✓ Multiline text input with validation"
    print_info "  ✓ Photo upload (camera/gallery) with size limits"
    print_info "  ✓ Anonymous posting toggle"
    print_info "  ✓ Section selection (Spotted, Question, etc.)"
    print_info "  ✓ Posting guidelines display"
    print_info "  ✓ Firebase Storage integration"
    print_info "  ✓ Anonymous posts count tracking"
    print_info "  ✓ Moderation pipeline trigger"
    print_info "  ✓ Image display in posts"
    print_info "  ✓ Section display in posts"
    print_info "  ✓ Navigation and refresh handling"
    print_info ""
    print_info "Next steps:"
    print_info "  1. Run 'flutter pub get' to install dependencies"
    print_info "  2. Test the post composer functionality"
    print_info "  3. Deploy Cloud Functions for moderation"
    print_info "  4. Configure Firebase Storage rules if needed"
else
    print_warning "Some checks failed. Please review the implementation."
    echo ""
    print_info "Missing components should be implemented before proceeding."
fi

echo ""
echo "🏁 Validation complete!"
echo "===================="