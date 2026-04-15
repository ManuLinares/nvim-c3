#!/usr/bin/env bash

# Sync tree-sitter queries with the version locked in init.lua or provided as argument

# Go to project root
cd "$(dirname "$0")/.." || exit 1

if [ -n "$1" ]; then
    VERSION="$1"
    echo "Updating M.TREE_SITTER_C3_VERSION in lua/c3/init.lua to $VERSION"
    # use a more robust sed pattern
    sed -i "s/M.TREE_SITTER_C3_VERSION = \".*\"/M.TREE_SITTER_C3_VERSION = \"$VERSION\"/g" lua/c3/init.lua
else
    VERSION=$(grep '^M.TREE_SITTER_C3_VERSION =' lua/c3/init.lua | cut -d'"' -f2)
fi

if [ -z "$VERSION" ]; then
    echo "Could not find M.TREE_SITTER_C3_VERSION in lua/c3/init.lua and no version provided"
    exit 1
fi

echo "Updating tree-sitter-c3 queries to version: $VERSION"

BASE_URL="https://raw.githubusercontent.com/c3lang/tree-sitter-c3"

mkdir -p queries/c3

for FILE in highlights.scm injections.scm folds.scm indents.scm unused_queries.scm; do
    echo "Downloading $FILE..."
    if ! curl -fsL "$BASE_URL/$VERSION/queries/$FILE" -o "queries/c3/$FILE"; then
        echo "Error: Failed to download $FILE for version $VERSION. Check if the tag exists on GitHub."
        exit 1
    fi
done

echo "Done."
