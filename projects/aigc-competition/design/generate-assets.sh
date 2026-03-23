#!/bin/bash
# Iris 🎨 Brand Asset Generator
# Hand-drawn style, warm color palette

ASSETS_DIR="/Users/minimax/.openclaw/workspace/projects/aigc-competition/design/assets"
API_URL="https://api.minimax.chat/v1/image_generation"

# Color constants for prompts
STYLE_BASE="hand-drawn style, warm artisan illustration, slightly irregular brush strokes, pencil and ink texture, warm color palette, cream white background (#FDF8F3), warm apricot orange (#E8855A), coral pink (#F2B49B), deep warm brown (#2C1F14), cozy handcraft aesthetic, like Mon Ami Café brand identity or HANDPIE bakery brand identity"
ICON_SUFFIX="app icon, simple, recognizable, centered composition, clean edges, minimal details, suitable for small size display"

generate_image() {
  local prompt="$1"
  local output_file="$2"
  local aspect_ratio="${3:-1:1}"
  local max_retries=2
  local attempt=0

  echo "🎨 Generating: $(basename $output_file)..."

  while [ $attempt -lt $max_retries ]; do
    RESPONSE=$(curl -s -X POST "$API_URL" \
      -H "Authorization: Bearer $MINIMAX_TOKENPLAN_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"image-01\",
        \"prompt\": \"$prompt\",
        \"aspect_ratio\": \"$aspect_ratio\",
        \"n\": 1,
        \"prompt_optimizer\": true
      }")

    IMAGE_URL=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', {}).get('image_urls', [''])[0] if isinstance(data.get('data', {}).get('image_urls', []), list) else '')" 2>/dev/null)

    if [ -z "$IMAGE_URL" ] || [ "$IMAGE_URL" = "None" ] || [ "$IMAGE_URL" = "" ]; then
      echo "  ⚠️  Attempt $((attempt+1)) failed. Response: $(echo $RESPONSE | head -c 200)"
      attempt=$((attempt + 1))
      sleep 3
    else
      curl -s -o "$output_file" "$IMAGE_URL"
      FILE_TYPE=$(file "$output_file" | grep -i "PNG\|JPEG\|image")
      if [ -n "$FILE_TYPE" ]; then
        echo "  ✅ Saved: $output_file"
        return 0
      else
        echo "  ⚠️  Downloaded file is invalid. Retrying..."
        attempt=$((attempt + 1))
        sleep 3
      fi
    fi
  done

  echo "  ❌ Failed after $max_retries attempts: $(basename $output_file)"
  echo "  Last response: $RESPONSE" | head -c 300
  return 1
}

echo "========================================="
echo "🎨 Iris Brand Asset Generator Starting..."
echo "========================================="

# ============================================================
# 1. APP LOGOS (4 variants)
# ============================================================
echo ""
echo "📱 [1/4] Generating App Logos..."

# Logo A - Journal/Diary
generate_image "Hand-drawn app icon logo design, centered composition on cream white background (#FDF8F3), a cute hand-drawn open diary journal book with warm apricot orange cover (#E8855A), small decorative stars and doodles around it, slightly rough ink line art style, watercolor wash texture, cozy handcraft aesthetic, simple recognizable silhouette, app icon design, square format, clean minimal illustration, Mon Ami Cafe brand style" \
  "$ASSETS_DIR/brand/logo-a-journal.png" "1:1"
sleep 3

# Logo B - Sun/Warm Glow
generate_image "Hand-drawn app icon logo design, centered composition on cream white background (#FDF8F3), a charming hand-drawn sun with warm rays and gentle glow halo, warm apricot orange (#E8855A) and coral pink (#F2B49B) colors, slightly irregular brushstroke sun rays, watercolor texture, small decorative dots and dashes, cozy warm feeling, simple recognizable icon, app icon design, square format, clean minimal handcraft illustration" \
  "$ASSETS_DIR/brand/logo-b-sun.png" "1:1"
sleep 3

# Logo C - Chat bubble + Pen
generate_image "Hand-drawn app icon logo design, centered composition on cream white background (#FDF8F3), a cute hand-drawn speech bubble with a small pen or pencil crossing through it, warm apricot orange (#E8855A) bubble, deep warm brown (#2C1F14) pen, small sparkle stars indicating AI magic, slightly rough ink line art texture, cozy handcraft aesthetic, simple recognizable icon, app icon design, square format, minimal illustration, HANDPIE bakery brand style warmth" \
  "$ASSETS_DIR/brand/logo-c-bubble.png" "1:1"
sleep 3

# Logo D - Cute Animal Mascot (fox)
generate_image "Hand-drawn app icon logo design, centered composition on cream white background (#FDF8F3), a cute tiny hand-drawn fox or small deer with big sparkly eyes, warm apricot orange (#E8855A) fur, small rounded ears, friendly gentle expression, holding a tiny book or diary, sketchy ink line art style with watercolor wash, cozy kawaii handcraft aesthetic, simple recognizable mascot, app icon design, square format, clean minimal illustration" \
  "$ASSETS_DIR/brand/logo-d-mascot.png" "1:1"
sleep 3

# ============================================================
# 2. MODULE ICONS (5 icons)
# ============================================================
echo ""
echo "📦 [2/4] Generating Module Icons..."

# AI Diary Module
generate_image "Hand-drawn icon, a small open diary notebook with a pencil or quill pen beside it, warm apricot orange (#E8855A) notebook cover, cream white pages, deep brown pen, small star sparkles indicating AI magic, rough ink line art style, watercolor texture, on cream white background (#FDF8F3), centered composition, simple minimal icon design, cozy handcraft feel" \
  "$ASSETS_DIR/icons/module-diary.png" "1:1"
sleep 3

# Study Partner Module
generate_image "Hand-drawn icon, a stack of books with a small cute tomato timer (pomodoro) beside them, warm coral pink (#F2B49B) books, apricot orange timer, simple rough ink line art, watercolor wash texture, on cream white background (#FDF8F3), centered composition, cozy study vibes, simple minimal icon design, handcraft illustration style" \
  "$ASSETS_DIR/icons/module-study.png" "1:1"
sleep 3

# Smart Social Module
generate_image "Hand-drawn icon, two cute small people figures standing together with a connecting line or heart between them, warm apricot orange (#E8855A) and coral pink (#F2B49B) colors, round simple character shapes, rough ink line art, watercolor texture, on cream white background (#FDF8F3), centered composition, friendly warm feeling, simple minimal icon design, handcraft illustration" \
  "$ASSETS_DIR/icons/module-social.png" "1:1"
sleep 3

# Growth Track Module
generate_image "Hand-drawn icon, a small cute seedling plant sprouting upward with a gentle upward arrow or growth curve, warm green and apricot orange (#E8855A) colors, small leaves and tiny stars around it, rough ink line art, watercolor texture, on cream white background (#FDF8F3), centered composition, hopeful growing feeling, simple minimal icon design, handcraft illustration style" \
  "$ASSETS_DIR/icons/module-growth.png" "1:1"
sleep 3

# Fortune/AI Module
generate_image "Hand-drawn icon, a cute small crystal ball with stars and sparkles inside, warm apricot orange (#E8855A) glow, small constellation dots around it, rough ink line art style, watercolor texture, slightly mystical but cozy feel, on cream white background (#FDF8F3), centered composition, simple minimal icon design, handcraft illustration" \
  "$ASSETS_DIR/icons/module-fortune.png" "1:1"
sleep 3

# ============================================================
# 3. TABBAR ICONS (5 icons)
# ============================================================
echo ""
echo "📂 [3/4] Generating TabBar Icons..."

# Diary Tab
generate_image "Minimalist hand-drawn tabbar icon, a tiny simple notebook or notepad with a small pencil mark, single line art style, warm apricot orange (#E8855A) color, on cream white background (#FDF8F3), very simple clean silhouette, suitable for mobile app tab bar, ultra minimal design, rough ink texture" \
  "$ASSETS_DIR/tabbar/tab-diary.png" "1:1"
sleep 3

# Study Tab
generate_image "Minimalist hand-drawn tabbar icon, a tiny simple open book with pages, single line art style, warm apricot orange (#E8855A) color, on cream white background (#FDF8F3), very simple clean silhouette, suitable for mobile app tab bar, ultra minimal design, rough ink texture" \
  "$ASSETS_DIR/tabbar/tab-study.png" "1:1"
sleep 3

# Home Tab
generate_image "Minimalist hand-drawn tabbar icon, a tiny simple cute house with a small chimney, single line art style, warm apricot orange (#E8855A) color, on cream white background (#FDF8F3), very simple clean silhouette, suitable for mobile app tab bar, ultra minimal design, rough ink texture, cozy home feel" \
  "$ASSETS_DIR/tabbar/tab-home.png" "1:1"
sleep 3

# Social Tab
generate_image "Minimalist hand-drawn tabbar icon, two tiny simple person silhouettes side by side, single line art style, warm apricot orange (#E8855A) color, on cream white background (#FDF8F3), very simple clean silhouette, suitable for mobile app tab bar, ultra minimal design, rough ink texture" \
  "$ASSETS_DIR/tabbar/tab-social.png" "1:1"
sleep 3

# Profile Tab
generate_image "Minimalist hand-drawn tabbar icon, a tiny simple round face or head silhouette with gentle features, single line art style, warm apricot orange (#E8855A) color, on cream white background (#FDF8F3), very simple clean silhouette, suitable for mobile app tab bar, ultra minimal design, rough ink texture" \
  "$ASSETS_DIR/tabbar/tab-profile.png" "1:1"
sleep 3

# ============================================================
# 4. ILLUSTRATIONS
# ============================================================
echo ""
echo "🖼️  [4/4] Generating Illustrations..."

# Splash Screen
generate_image "Hand-drawn illustration, vertical composition, a cozy warm scene of a college student sitting by a window writing in a diary or using phone, warm afternoon light streaming through window, a cute small glowing AI companion spirit floating nearby as soft light orbs or tiny fairy figure, warm apricot orange (#E8855A) and cream white (#FDF8F3) color palette, watercolor and ink illustration style, cozy handcraft aesthetic, Mon Ami Cafe warmth, detailed scene illustration" \
  "$ASSETS_DIR/illustrations/splash-screen.png" "9:16"
sleep 3

# Empty State - No Diary
generate_image "Hand-drawn empty state illustration, centered composition, a cute open blank diary notebook with a small pen resting on it, small twinkling stars and tiny doodles floating around, warm apricot orange (#E8855A) notebook, cream white pages, gentle sparkle effect, hand-drawn ink and watercolor style, on cream white background (#FDF8F3), cozy nostalgic feeling, simple charming illustration for empty state UI" \
  "$ASSETS_DIR/illustrations/empty-no-diary.png" "1:1"
sleep 3

# Empty State - No Buddy
generate_image "Hand-drawn empty state illustration, centered composition, two cute empty chairs or seats facing each other with a small steaming coffee cup on a tiny table between them, warm apricot orange (#E8855A) and coral pink (#F2B49B) colors, small hearts or sparkles floating, hand-drawn ink and watercolor style, on cream white background (#FDF8F3), cozy cafe feeling, simple charming illustration for empty state UI" \
  "$ASSETS_DIR/illustrations/empty-no-buddy.png" "1:1"

echo ""
echo "========================================="
echo "✅ Generation Complete!"
echo "========================================="

# List all generated files
echo ""
echo "📁 Generated files:"
find "$ASSETS_DIR" -name "*.png" -exec sh -c 'echo "  $(basename {}) - $(file {} | cut -d: -f2)"' \;
