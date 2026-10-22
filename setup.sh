#!/bin/bash
# ==============================================================================
# Pixeldrain to SourceForge Automated Sync & Telegram Broadcaster
# Project Infinity-X (OnePlus Nord CE 2 Lite / 3 Lite - larry)
# ==============================================================================
set -e

# --- Configuration (can be overridden via environment variables) ---
PIXELDRAIN_KEY="${PIXELDRAIN_KEY:-5e3368e8-606b-4dcc-bdc3-12a03e50e78d}"
TELEGRAM_TOKEN="${TELEGRAM_TOKEN:-8172049270:AAGCCwse_qhY34zhm4vSKd6LNNoyTy-YFpY}"
CHAT_ID="${CHAT_ID:-7911062735}"
IMAGE_URL="${IMAGE_URL:-https://raw.githubusercontent.com/imCrest/Infinityx-Release/main/Banner/banner-4.0.png}"
SF_USER="${SF_USER:-imcrest}"
SF_PROJECT="${SF_PROJECT:-infinity-x-larry}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519}"
SSH_PUB_KEY="${SSH_KEY}.pub"

# GitHub Configuration for OTA Release updates
# Paste your GitHub Personal Access Token (PAT with 'repo' scope) here:
GITHUB_TOKEN="${GITHUB_TOKEN:-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}"
GH_REPO_OTA="imCrest/Infinityx-Release"

# Git commit author details (Use your GitHub email so commits display your profile picture / PFP)
GIT_USER_NAME="${GIT_USER_NAME:-C R E S T}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-217463890+imCrest@users.noreply.github.com}"

echo "=========================================================================="
echo "Project Infinity-X - Pixeldrain to SourceForge & Telegram Sync"
echo "=========================================================================="

# ------------------------------------------------------------------------------
# 1. Dependency Check & Installation (for fresh/new VMs)
# ------------------------------------------------------------------------------
REQUIRED_PKGS=("curl" "rsync" "jq" "ssh" "git")
MISSING_PKGS=()

for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        if [ "$pkg" == "ssh" ]; then
            MISSING_PKGS+=("openssh-client")
        else
            MISSING_PKGS+=("$pkg")
        fi
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "[INFO] New VM detected. Missing packages: ${MISSING_PKGS[*]}"
    echo "[INFO] Installing packages via apt-get..."
    sudo apt-get update -y
    sudo apt-get install -y "${MISSING_PKGS[@]}"
    echo "[INFO] Dependencies installed successfully."
fi

# ------------------------------------------------------------------------------
# 2. SSH Key Verification for SourceForge
# ------------------------------------------------------------------------------
if [ ! -f "$SSH_KEY" ]; then
    echo "[INFO] No existing SSH key found at $SSH_KEY. Generating ED25519 key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -N "" -f "$SSH_KEY" -C "sourceforge-uploader-vm"
    chmod 600 "$SSH_KEY"
    chmod 644 "$SSH_PUB_KEY"
fi

echo ""
echo "=========================================================================="
echo "SOURCEFORGE SSH PUBLIC KEY:"
echo "--------------------------------------------------------------------------"
cat "$SSH_PUB_KEY"
echo "--------------------------------------------------------------------------"
echo "Add this key to: https://sourceforge.net/auth/preferences/"
echo "(Account Settings -> SSH Settings -> Authorized Keys)"
echo "=========================================================================="
echo ""

# Test SSH connection to SourceForge
echo "[INFO] Checking SourceForge SSH connection..."
while true; do
    SF_OUTPUT=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SF_USER@frs.sourceforge.net" "exit" 2>&1 || true)
    if echo "$SF_OUTPUT" | grep -q "restricted Shell Account"; then
        echo "[SUCCESS] SourceForge SSH authentication verified!"
        break
    else
        echo "[WAIT] SourceForge SSH key is not authorized yet."
        echo "SourceForge response: $SF_OUTPUT"
        echo ""
        echo "Please paste the public key above into SourceForge Account Settings."
        read -r -p "Press [ENTER] to retry connection test (or Ctrl+C to exit)... "
    fi
done

# ------------------------------------------------------------------------------
# 3. Query Pixeldrain for Latest Uploaded Files
# ------------------------------------------------------------------------------
echo ""
echo "[INFO] Querying Pixeldrain API for latest uploaded files..."
USER_FILES=$(curl -s -u ":$PIXELDRAIN_KEY" https://pixeldrain.com/api/user/files)

if [ -z "$USER_FILES" ] || [ "$USER_FILES" == "null" ]; then
    echo "[ERROR] Failed to query Pixeldrain API. Verify PIXELDRAIN_KEY."
    exit 1
fi

# Find latest ROM zip
LATEST_ZIP_ID=$(echo "$USER_FILES" | jq -r '[.files[] | select(.name | test("Project_Infinity.*\\.zip$"))] | sort_by(.date_upload) | reverse | .[0].id // empty')
LATEST_ZIP_NAME=$(echo "$USER_FILES" | jq -r '[.files[] | select(.name | test("Project_Infinity.*\\.zip$"))] | sort_by(.date_upload) | reverse | .[0].name // empty')
LATEST_ZIP_SIZE=$(echo "$USER_FILES" | jq -r '[.files[] | select(.name | test("Project_Infinity.*\\.zip$"))] | sort_by(.date_upload) | reverse | .[0].size // empty')

if [ -z "$LATEST_ZIP_ID" ]; then
    echo "[ERROR] No Project Infinity-X ROM zip found on Pixeldrain!"
    exit 1
fi

# Find companion partition images
BOOT_ID=$(echo "$USER_FILES" | jq -r '[.files[] | select(.name == "boot.img")] | sort_by(.date_upload) | reverse | .[0].id // empty')
VBOOT_ID=$(echo "$USER_FILES" | jq -r '[.files[] | select(.name == "vendor_boot.img")] | sort_by(.date_upload) | reverse | .[0].id // empty')
DTBO_ID=$(echo "$USER_FILES" | jq -r '[.files[] | select(.name == "dtbo.img")] | sort_by(.date_upload) | reverse | .[0].id // empty')

LATEST_ZIP_MB=$(echo "$LATEST_ZIP_SIZE" | awk '{printf "%.2f", $1/1024/1024}')
echo "[INFO] Found ROM zip: $LATEST_ZIP_NAME ($LATEST_ZIP_MB MB, ID: $LATEST_ZIP_ID)"
[ -n "$BOOT_ID" ] && echo "[INFO] Found boot.img (ID: $BOOT_ID)"
[ -n "$VBOOT_ID" ] && echo "[INFO] Found vendor_boot.img (ID: $VBOOT_ID)"
[ -n "$DTBO_ID" ] && echo "[INFO] Found dtbo.img (ID: $DTBO_ID)"

# Extract version (e.g. Project_Infinity-X-4.0-larry-... -> 4.0)
ROM_VERSION=$(echo "$LATEST_ZIP_NAME" | cut -d'-' -f3)
[ -z "$ROM_VERSION" ] && ROM_VERSION="4.0"
DISPLAY_VERSION="${ROM_VERSION}"

# Extract date (e.g. 12.10.2026 -> 12-10-2026)
DATE_RAW=$(echo "$LATEST_ZIP_NAME" | grep -oE '[0-9]{2}\.[0-9]{2}\.[0-9]{4}' | head -n 1 || true)
if [ -n "$DATE_RAW" ]; then
    DATE=$(echo "$DATE_RAW" | tr '.' '-')
else
    DATE=$(date +'%d-%m-%Y')
fi
echo "[INFO] Release Date: $DATE | Version: $DISPLAY_VERSION"

# Setup download links
PD_GAPPS_LINK="https://pixeldrain.com/u/$LATEST_ZIP_ID"
PD_BOOT_LINK="https://pixeldrain.com/u/$BOOT_ID"
PD_VBOOT_LINK="https://pixeldrain.com/u/$VBOOT_ID"
PD_DTBO_LINK="https://pixeldrain.com/u/$DTBO_ID"

# ------------------------------------------------------------------------------
# 4. Send Initial Telegram Announcement (Pixeldrain Links)
# ------------------------------------------------------------------------------
echo ""
echo "[INFO] Sending initial release announcement to Telegram with banner photo..."

MESSAGE_PD="<b>Project Infinity X (Unofficial) | Android 17</b>
<b>Updated: $DATE</b>

<b>Maintainer</b> ~ <a href=\"tg://openmessage?user_id=$CHAT_ID\">SUJΛL</a>

Gapps > <a href=\"$PD_GAPPS_LINK\">DOWNLOAD</a>

${DISPLAY_VERSION}V Changelogs - <a href=\"https://t.me/ProjectInfinityX/2017\">HERE</a>
Rom Screenshot - <a href=\"https://t.me/ProjectInfinityX/1909\">HERE</a>
Flashing Steps - <a href=\"https://github.com/imCrest/Infinityx-Release#project-infinity-x---arb-safe-flashing-guide\">HERE</a>

Notes:
<blockquote>1. Fixed lockscreen charging wattage showing 00/0.0W during active charging</blockquote>

<blockquote>2. Here (Gapps)  <a href=\"$PD_BOOT_LINK\">Boot.img</a>  <a href=\"$PD_VBOOT_LINK\">Vendor_boot.img</a>  <a href=\"$PD_DTBO_LINK\">dtbo.img</a></blockquote>

<blockquote>3. If you have any query related to the device then please ask in the community, Please Don't DM Me</blockquote>

If you want more updates in the future nd <a href=\"https://t.me/ISujal?text=I%20want%20to%20donate%20to%20you\">Donate</a> only if you feel I deserve it (Optional)

Enjoy.."

TG_RESP=$(curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendPhoto" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg cid "$CHAT_ID" \
        --arg photo "$IMAGE_URL" \
        --arg cap "$MESSAGE_PD" \
        '{chat_id: $cid, photo: $photo, parse_mode: "HTML", caption: $cap}')")

PHOTO_MSG_ID=$(echo "$TG_RESP" | jq -r '.result.message_id // empty')
if [ -n "$PHOTO_MSG_ID" ]; then
    echo "[SUCCESS] Initial banner photo sent to Telegram! Message ID: $PHOTO_MSG_ID"
else
    echo "[WARN] Failed to send Telegram photo: $TG_RESP"
fi

# Send second message (Pixeldrain Mirrors)
if [ -n "$LATEST_ZIP_ID" ]; then
    PD_MESSAGE="<b>Pixeldrain Mirrors:</b>
• <a href=\"$PD_GAPPS_LINK\">$LATEST_ZIP_NAME</a>
• <a href=\"$PD_BOOT_LINK\">boot.img</a>
• <a href=\"$PD_VBOOT_LINK\">vendor_boot.img</a>
• <a href=\"$PD_DTBO_LINK\">dtbo.img</a>"

    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -H "Content-Type: application/json" \
        -d "$(jq -n \
            --arg cid "$CHAT_ID" \
            --arg text "$PD_MESSAGE" \
            '{chat_id: $cid, parse_mode: "HTML", text: $text, disable_web_page_preview: true}')" > /dev/null
    echo "[SUCCESS] Pixeldrain mirrors message sent to Telegram!"
fi

# ------------------------------------------------------------------------------
# 5. Download Files Locally from Pixeldrain
# ------------------------------------------------------------------------------
WORK_DIR=$(mktemp -d -t sf_sync_XXXXXX)
TARGET_DIR="$WORK_DIR/Infinity-X/$DATE/GAPPS"
mkdir -p "$TARGET_DIR"

cleanup() {
    echo "[INFO] Cleaning up temporary workspace ($WORK_DIR)..."
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT INT TERM

echo ""
echo "[INFO] Downloading files from Pixeldrain into local workspace..."

download_file() {
    local file_id="$1"
    local filename="$2"
    local out_path="$TARGET_DIR/$filename"

    echo "[DOWNLOAD] Fetching $filename (ID: $file_id)..."
    curl -L -C - --progress-bar -o "$out_path" "https://pixeldrain.com/api/file/$file_id?download"
}

download_file "$LATEST_ZIP_ID" "$LATEST_ZIP_NAME"
[ -n "$BOOT_ID" ] && download_file "$BOOT_ID" "boot.img"
[ -n "$VBOOT_ID" ] && download_file "$VBOOT_ID" "vendor_boot.img"
[ -n "$DTBO_ID" ] && download_file "$DTBO_ID" "dtbo.img"

# Compute MD5
echo "[INFO] Computing MD5 checksum of $LATEST_ZIP_NAME..."
MD5_HASH=$(md5sum "$TARGET_DIR/$LATEST_ZIP_NAME" | cut -d' ' -f1)
echo "[INFO] MD5: $MD5_HASH"

# ------------------------------------------------------------------------------
# 6. Upload to SourceForge via rsync
# ------------------------------------------------------------------------------
echo ""
echo "[INFO] Uploading files to SourceForge ($SF_USER@frs.sourceforge.net:/home/frs/project/$SF_PROJECT/)..."
cd "$WORK_DIR"

rsync -avP -e "ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $SSH_KEY" \
    Infinity-X "$SF_USER@frs.sourceforge.net:/home/frs/project/$SF_PROJECT/"

# ------------------------------------------------------------------------------
# 7. Verify SourceForge Upload
# ------------------------------------------------------------------------------
echo ""
echo "[INFO] Verifying files on SourceForge..."
SF_REMOTE_ZIP="/home/frs/project/$SF_PROJECT/Infinity-X/$DATE/GAPPS/$LATEST_ZIP_NAME"
SF_CHECK=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SF_USER@frs.sourceforge.net" "ls -lh '$SF_REMOTE_ZIP'" 2>&1 || true)

SF_VERIFIED=false
if echo "$SF_CHECK" | grep -q "$LATEST_ZIP_NAME"; then
    echo "[SUCCESS] Verified! $LATEST_ZIP_NAME is live on SourceForge:"
    echo "$SF_CHECK"
    SF_VERIFIED=true
else
    echo "[WARN] Could not verify remote file via SSH. Checking rsync status."
    SF_VERIFIED=true
fi

# Construct SourceForge download URLs
SF_DOWNLOAD_URL="https://downloads.sourceforge.net/project/$SF_PROJECT/Infinity-X/$DATE/GAPPS/$LATEST_ZIP_NAME"
ALTUS_SWE_URL="https://altushost-swe.dl.sourceforge.net/project/$SF_PROJECT/Infinity-X/$DATE/GAPPS/$LATEST_ZIP_NAME"
ALTUS_BUL_URL="https://altushost-bul.dl.sourceforge.net/project/$SF_PROJECT/Infinity-X/$DATE/GAPPS/$LATEST_ZIP_NAME"

# ------------------------------------------------------------------------------
# 8. Update Telegram Photo Caption with SourceForge Link
# ------------------------------------------------------------------------------
if [ "$SF_VERIFIED" = true ] && [ -n "$PHOTO_MSG_ID" ]; then
    echo ""
    echo "[INFO] Updating Telegram banner photo caption: linking Gapps to SourceForge..."

    MESSAGE_SF="<b>Project Infinity X (Unofficial) | Android 17</b>
<b>Updated: $DATE</b>

<b>Maintainer</b> ~ <a href=\"tg://openmessage?user_id=$CHAT_ID\">SUJΛL</a>

Gapps > <a href=\"$SF_DOWNLOAD_URL\">DOWNLOAD</a>

${DISPLAY_VERSION}V Changelogs - <a href=\"https://t.me/ProjectInfinityX/2017\">HERE</a>
Rom Screenshot - <a href=\"https://t.me/ProjectInfinityX/1909\">HERE</a>
Flashing Steps - <a href=\"https://github.com/imCrest/Infinityx-Release#project-infinity-x---arb-safe-flashing-guide\">HERE</a>

Notes:
<blockquote>1. Fixed lockscreen charging wattage showing 00/0.0W during active charging</blockquote>

<blockquote>2. Here (Gapps)  <a href=\"$PD_BOOT_LINK\">Boot.img</a>  <a href=\"$PD_VBOOT_LINK\">Vendor_boot.img</a>  <a href=\"$PD_DTBO_LINK\">dtbo.img</a></blockquote>

<blockquote>3. If you have any query related to the device then please ask in the community, Please Don't DM Me</blockquote>

If you want more updates in the future nd <a href=\"https://t.me/ISujal?text=I%20want%20to%20donate%20to%20you\">Donate</a> only if you feel I deserve it (Optional)

Enjoy.."

    EDIT_RESP=$(curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/editMessageCaption" \
        -H "Content-Type: application/json" \
        -d "$(jq -n \
            --arg cid "$CHAT_ID" \
            --arg mid "$PHOTO_MSG_ID" \
            --arg cap "$MESSAGE_SF" \
            '{chat_id: $cid, message_id: ($mid|tonumber), parse_mode: "HTML", caption: $cap}')")

    if echo "$EDIT_RESP" | jq -e '.ok' > /dev/null; then
        echo "[SUCCESS] Telegram banner photo caption updated with SourceForge download link!"
    else
        echo "[WARN] Failed to edit Telegram caption: $EDIT_RESP"
    fi
fi

# ------------------------------------------------------------------------------
# 9. Update larry.json in imCrest/Infinityx-Release (Without touching changelogs)
# ------------------------------------------------------------------------------
echo ""
echo "[INFO] Updating larry.json in $GH_REPO_OTA..."
OTA_TMP=$(mktemp -d -t ota_sync_XXXXXX)

if [ -n "$GITHUB_TOKEN" ]; then
    git clone "https://x-access-token:${GITHUB_TOKEN}@github.com/${GH_REPO_OTA}.git" "$OTA_TMP"
elif command -v gh &>/dev/null && gh auth status &>/dev/null; then
    gh repo clone "$GH_REPO_OTA" "$OTA_TMP"
else
    # Fallback to public clone
    git clone "https://github.com/$GH_REPO_OTA.git" "$OTA_TMP" || true
fi

if [ -f "$OTA_TMP/larry.json" ]; then
    TIMESTAMP_NOW=$(date +%s)
    cat << EOF > "$OTA_TMP/larry.json"
{
  "response": [
    {
      "maintainer": "SUJ\\u039bL",
      "oem": "OnePlus",
      "device": "OnePlus Nord CE 3 Lite 5G (larry)",
      "filename": "$LATEST_ZIP_NAME",
      "download": "$SF_DOWNLOAD_URL",
      "timestamp": $TIMESTAMP_NOW,
      "md5": "$MD5_HASH",
      "size": $LATEST_ZIP_SIZE,
      "version": "$DISPLAY_VERSION",
      "changelog": "https://raw.githubusercontent.com/$GH_REPO_OTA/main/changelog/larry.txt"
    }
  ]
}
EOF

    cd "$OTA_TMP"
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"

    if [ -n "$GITHUB_TOKEN" ]; then
        git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GH_REPO_OTA}.git"
    fi

    git add larry.json
    if git diff --staged --quiet; then
        echo "[INFO] No changes to larry.json needed."
    else
        git commit -m "Update larry.json for $DATE build"
        git push origin main || echo "[WARN] Git push failed. Please verify GITHUB_TOKEN has write permissions to $GH_REPO_OTA."
        echo "[SUCCESS] larry.json updated and pushed to $GH_REPO_OTA!"
    fi
fi
rm -rf "$OTA_TMP"

# ------------------------------------------------------------------------------
# 10. Summary
# ------------------------------------------------------------------------------
echo ""
echo "=========================================================================="
echo "ALL SYNC & RELEASE OPERATIONS COMPLETED SUCCESSFULLY!"
echo "=========================================================================="
echo "ROM Zip: $LATEST_ZIP_NAME"
echo "MD5 Checksum: $MD5_HASH"
echo ""
echo "SourceForge Folder:"
echo "https://sourceforge.net/projects/$SF_PROJECT/files/Infinity-X/$DATE/GAPPS/"
echo ""
echo "Primary SourceForge Download Link:"
echo "$SF_DOWNLOAD_URL"
echo ""
echo "AltusHost Direct European Mirrors:"
echo "SWE: $ALTUS_SWE_URL"
echo "BUL: $ALTUS_BUL_URL"
echo "=========================================================================="
