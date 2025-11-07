#!/bin/bash
# Convenience script to build and serve the website

echo "🏗️  Building website..."
bun run build:website

echo ""
echo "🌐 Starting local server..."
echo "📍 Open http://localhost:8080 in your browser"
echo "⏹️  Press Ctrl+C to stop"
echo ""

cd dist && npx http-server -p 8080

