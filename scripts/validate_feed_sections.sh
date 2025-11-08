#!/bin/bash

echo "=== Feed Sections Feature Structure Validation ==="

# Check if all required directories exist
echo "Checking directory structure..."

REQUIRED_DIRS=(
    "lib/src/features/feed/data/models"
    "lib/src/features/feed/data/repositories"
    "lib/src/features/feed/presentation/providers"
    "lib/src/features/feed/presentation/widgets"
    "lib/src/features/feed/presentation/pages"
    "test/src/features/feed"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir exists"
    else
        echo "❌ $dir missing"
    fi
done

echo ""
echo "Checking key files..."

REQUIRED_FILES=(
    "lib/src/features/comments/data/models/comment.dart"
    "lib/src/features/comments/data/repositories/posts_repository.dart"
    "lib/src/features/feed/presentation/pages/feed_sections_page.dart"
    "lib/src/features/feed/presentation/pages/feed_page.dart"
    "lib/src/features/feed/presentation/providers/feed_provider.dart"
    "lib/src/features/feed/presentation/widgets/post_card_widget.dart"
    "lib/src/features/feed/presentation/widgets/skeleton_loader_widget.dart"
    "lib/src/features/feed/presentation/widgets/empty_state_widget.dart"
    "test/src/features/feed/feed_provider_test.dart"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

echo ""
echo "Checking Post model for section field..."

if grep -q "final String section" lib/src/features/comments/data/models/comment.dart; then
    echo "✅ Post model has section field"
else
    echo "❌ Post model missing section field"
fi

echo ""
echo "Checking PostsRepository for section filtering..."

if grep -q "String? section" lib/src/features/comments/data/repositories/posts_repository.dart; then
    echo "✅ PostsRepository supports section filtering"
else
    echo "❌ PostsRepository missing section filtering"
fi

if grep -q "getPostsStream" lib/src/features/comments/data/repositories/posts_repository.dart; then
    echo "✅ PostsRepository has real-time stream support"
else
    echo "❌ PostsRepository missing real-time stream support"
fi

echo ""
echo "=== Validation Complete ==="