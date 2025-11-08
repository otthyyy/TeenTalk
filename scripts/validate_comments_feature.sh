#!/bin/bash

echo "=== Comments Feature Structure Validation ==="

# Check if all required directories exist
echo "Checking directory structure..."

REQUIRED_DIRS=(
    "lib/src/features/comments/data/models"
    "lib/src/features/comments/data/repositories"
    "lib/src/features/comments/data/services"
    "lib/src/features/comments/presentation/providers"
    "lib/src/features/comments/presentation/widgets"
    "lib/src/features/comments/presentation/pages"
    "test/src/features/comments/presentation/widgets"
    "test/src/features/comments"
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
    "lib/src/features/comments/data/repositories/comments_repository.dart"
    "lib/src/features/comments/data/repositories/posts_repository.dart"
    "lib/src/features/comments/data/services/notification_service.dart"
    "lib/src/features/comments/presentation/providers/comments_provider.dart"
    "lib/src/features/comments/presentation/widgets/comment_widget.dart"
    "lib/src/features/comments/presentation/widgets/comments_list_widget.dart"
    "lib/src/features/comments/presentation/widgets/comment_input_widget.dart"
    "lib/src/features/comments/presentation/widgets/post_widget.dart"
    "lib/src/features/comments/presentation/pages/feed_with_comments_page.dart"
    "test/src/features/comments/presentation/widgets/comment_widget_test.dart"
    "test/src/features/comments/presentation/widgets/comments_list_widget_test.dart"
    "test/src/features/comments/integration_test.dart"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

echo ""
echo "=== Validation Complete ==="