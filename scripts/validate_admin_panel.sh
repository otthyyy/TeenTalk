#!/bin/bash

# Admin Panel MVP Validation Script
# Checks that all required files are in place and properly structured

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Admin Panel MVP Validation"
echo "========================================="

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
ERRORS=0
WARNINGS=0

# Helper functions
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

check_directory() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Found directory: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing directory: $1"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Found '$2' in $1"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Could not find '$2' in $1"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

echo ""
echo "Checking Data Layer..."
check_file "$PROJECT_ROOT/lib/src/features/admin/data/models/report.dart"
check_file "$PROJECT_ROOT/lib/src/features/admin/data/repositories/admin_repository.dart"

echo ""
echo "Checking Presentation Layer..."
check_directory "$PROJECT_ROOT/lib/src/features/admin/presentation/pages"
check_directory "$PROJECT_ROOT/lib/src/features/admin/presentation/widgets"
check_directory "$PROJECT_ROOT/lib/src/features/admin/presentation/providers"

check_file "$PROJECT_ROOT/lib/src/features/admin/presentation/pages/admin_page.dart"
check_file "$PROJECT_ROOT/lib/src/features/admin/presentation/widgets/reports_list_widget.dart"
check_file "$PROJECT_ROOT/lib/src/features/admin/presentation/widgets/report_detail_widget.dart"
check_file "$PROJECT_ROOT/lib/src/features/admin/presentation/widgets/analytics_widget.dart"
check_file "$PROJECT_ROOT/lib/src/features/admin/presentation/providers/admin_providers.dart"

echo ""
echo "Checking Integration Points..."
check_content "$PROJECT_ROOT/lib/src/core/router/app_router.dart" "isAdminUser"
check_content "$PROJECT_ROOT/lib/src/core/router/app_router.dart" "isOnAdminPage"
check_content "$PROJECT_ROOT/lib/src/features/auth/data/models/auth_user.dart" "isAdmin"

echo ""
echo "Checking Repository Updates..."
check_content "$PROJECT_ROOT/lib/src/features/comments/data/repositories/comments_repository.dart" "itemType.*comment"
check_content "$PROJECT_ROOT/lib/src/features/comments/data/repositories/posts_repository.dart" "itemType.*post"

echo ""
echo "Checking Firestore Configuration..."
check_file "$PROJECT_ROOT/firestore.rules"
check_content "$PROJECT_ROOT/firestore.rules" "isAdmin()"
check_content "$PROJECT_ROOT/firestore.rules" "match /reports/"
check_content "$PROJECT_ROOT/firestore.rules" "match /moderationDecisions/"
check_content "$PROJECT_ROOT/firestore.rules" "match /comments/"

echo ""
echo "Checking Documentation..."
check_file "$PROJECT_ROOT/ADMIN_PANEL_MVP.md"

echo ""
echo "========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warnings found${NC}"
    fi
    exit 0
else
    echo -e "${RED}✗ $ERRORS errors found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warnings found${NC}"
    fi
    exit 1
fi
