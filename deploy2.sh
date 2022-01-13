#!/usr/bin/env sh

# abort on errors
set -e

# build
npm run build

cd dist
git add .
git commit -m "deploying..."
git push https://github.com/tenzint/snakegame.git gh-pages
cd ..