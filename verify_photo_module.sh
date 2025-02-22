#!/bin/bash

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Set the root directory
ROOT_DIR="/home/kmw/PycharmProjects/photo-module"
MODULE_DIR="$ROOT_DIR/custom_addons/user_photo_albums"

echo -e "${YELLOW}Starting Photo Module Verification...${NC}\n"

# Function to check if a file exists and has content
check_file() {
    local file=$1
    local min_size=${2:-10} # Minimum file size in bytes
    
    if [ -f "$file" ]; then
        size=$(wc -c < "$file")
        if [ $size -gt $min_size ]; then
            echo -e "${GREEN}✓ $file exists and has content${NC}"
            return 0
        else
            echo -e "${RED}✗ $file exists but appears empty or too small${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ $file is missing${NC}"
        return 1
    fi
}

# Function to check if a directory exists
check_directory() {
    local dir=$1
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ Directory $dir exists${NC}"
        return 0
    else
        echo -e "${RED}✗ Directory $dir is missing${NC}"
        return 1
    fi
}

# Function to check Python syntax
check_python_syntax() {
    local file=$1
    if python -m py_compile "$file" 2>/dev/null; then
        echo -e "${GREEN}✓ Python syntax OK in $file${NC}"
        return 0
    else
        echo -e "${RED}✗ Python syntax error in $file${NC}"
        return 1
    fi
}

# Function to check XML syntax
check_xml_syntax() {
    local file=$1
    if xmllint --noout "$file" 2>/dev/null; then
        echo -e "${GREEN}✓ XML syntax OK in $file${NC}"
        return 0
    else
        echo -e "${RED}✗ XML syntax error in $file${NC}"
        return 1
    fi
}

echo "1. Checking Directory Structure..."
echo "--------------------------------"
directories=(
    "$MODULE_DIR"
    "$MODULE_DIR/controllers"
    "$MODULE_DIR/models"
    "$MODULE_DIR/security"
    "$MODULE_DIR/static"
    "$MODULE_DIR/static/description"
    "$MODULE_DIR/static/src/js"
    "$MODULE_DIR/static/src/scss"
    "$MODULE_DIR/views"
)

dir_check_passed=true
for dir in "${directories[@]}"; do
    if ! check_directory "$dir"; then
        dir_check_passed=false
    fi
done

echo -e "\n2. Checking Core Files..."
echo "-------------------------"
core_files=(
    "$MODULE_DIR/__init__.py"
    "$MODULE_DIR/__manifest__.py"
    "$MODULE_DIR/controllers/__init__.py"
    "$MODULE_DIR/controllers/main.py"
    "$MODULE_DIR/models/__init__.py"
)

core_check_passed=true
for file in "${core_files[@]}"; do
    if ! check_file "$file"; then
        core_check_passed=false
    fi
    if [[ "$file" == *.py ]]; then
        if ! check_python_syntax "$file"; then
            core_check_passed=false
        fi
    fi
done

echo -e "\n3. Checking Model Files..."
echo "--------------------------"
model_files=(
    "$MODULE_DIR/models/photo_album.py"
    "$MODULE_DIR/models/photo_category.py"
    "$MODULE_DIR/models/photo.py"
)

model_check_passed=true
for file in "${model_files[@]}"; do
    if ! check_file "$file"; then
        model_check_passed=false
    fi
    if ! check_python_syntax "$file"; then
        model_check_passed=false
    fi
done

echo -e "\n4. Checking Security Files..."
echo "-----------------------------"
security_files=(
    "$MODULE_DIR/security/ir.model.access.csv"
    "$MODULE_DIR/security/photo_album_security.xml"
)

security_check_passed=true
for file in "${security_files[@]}"; do
    if ! check_file "$file"; then
        security_check_passed=false
    fi
    if [[ "$file" == *.xml ]]; then
        if ! check_xml_syntax "$file"; then
            security_check_passed=false
        fi
    fi
done

echo -e "\n5. Checking View Files..."
echo "-------------------------"
view_files=(
    "$MODULE_DIR/views/photo_album_views.xml"
    "$MODULE_DIR/views/photo_views.xml"
    "$MODULE_DIR/views/photo_category_views.xml"
    "$MODULE_DIR/views/templates.xml"
)

view_check_passed=true
for file in "${view_files[@]}"; do
    if ! check_file "$file"; then
        view_check_passed=false
    fi
    if ! check_xml_syntax "$file"; then
        view_check_passed=false
    fi
done

echo -e "\n6. Checking Required Fields in Manifest..."
echo "----------------------------------------"
manifest_check_passed=true
manifest_file="$MODULE_DIR/__manifest__.py"
required_fields=("name" "version" "category" "depends" "data")

if [ -f "$manifest_file" ]; then
    for field in "${required_fields[@]}"; do
        if ! grep -q "$field" "$manifest_file"; then
            echo -e "${RED}✗ Required field '$field' missing in manifest${NC}"
            manifest_check_passed=false
        else
            echo -e "${GREEN}✓ Required field '$field' found in manifest${NC}"
        fi
    done
else
    echo -e "${RED}✗ Manifest file not found${NC}"
    manifest_check_passed=false
fi

echo -e "\n7. Final Verification Summary"
echo "----------------------------"
all_passed=true

checks=(
    "Directory Structure:$dir_check_passed"
    "Core Files:$core_check_passed"
    "Model Files:$model_check_passed"
    "Security Files:$security_check_passed"
    "View Files:$view_check_passed"
    "Manifest Check:$manifest_check_passed"
)

for check in "${checks[@]}"; do
    IFS=':' read -r name status <<< "$check"
    if [ "$status" = "true" ]; then
        echo -e "${GREEN}✓ $name - PASSED${NC}"
    else
        echo -e "${RED}✗ $name - FAILED${NC}"
        all_passed=false
    fi
done

echo -e "\nFinal Result:"
if [ "$all_passed" = true ]; then
    echo -e "${GREEN}Module verification completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}Module verification failed. Please check the errors above.${NC}"
    exit 1
fi
