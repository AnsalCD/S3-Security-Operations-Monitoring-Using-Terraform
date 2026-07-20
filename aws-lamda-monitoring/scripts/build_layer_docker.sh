#!/bin/bash
set -e

echo "🚀 Building Lambda Layer with Pillow using Docker..."

# Get script + project directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

# ✅ Use OUTPUT folder instead of terraform
OUTPUT_DIR="$PROJECT_DIR/output"

# ✅ Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# ✅ Convert to Windows path (important for Docker on Windows)
if command -v cygpath &> /dev/null; then
    OUTPUT_DIR_WIN=$(cygpath -w "$OUTPUT_DIR")
else
    OUTPUT_DIR_WIN="$OUTPUT_DIR"
fi

echo "📁 Output directory: $OUTPUT_DIR"
echo "🪟 Windows path used for Docker: $OUTPUT_DIR_WIN"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Install from: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info &> /dev/null 2>&1; then
    echo "❌ Docker is not running. Start Docker Desktop."
    exit 1
fi

echo "📦 Building layer in Linux container (Python 3.12)..."

# ✅ Run Docker with FIXED mount
docker run --rm \
  --platform linux/amd64 \
  -v "$OUTPUT_DIR_WIN:/output" \
  python:3.12-slim \
  bash -c "
    set -e
    echo '📦 Installing Pillow...' && \
    mkdir -p /tmp/python/lib/python3.12/site-packages && \
    pip install --quiet Pillow==10.4.0 -t /tmp/python/lib/python3.12/site-packages/ && \
    cd /tmp && \
    echo '📦 Creating layer zip file...' && \
    apt-get update -qq && apt-get install -y -qq zip > /dev/null 2>&1 && \
    zip -q -r pillow_layer.zip python/ && \
    echo '📂 Checking /output mount...' && \
    ls -ld /output && \
    cp pillow_layer.zip /output/ && \
    echo '✅ Layer built successfully!'
  "

echo "📍 Location: $OUTPUT_DIR/pillow_layer.zip"
echo "✅ Layer is now compatible with AWS Lambda!"