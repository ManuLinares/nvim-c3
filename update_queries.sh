#!/usr/bin/env bash

# Sync tree-sitter queries with the version locked in init.lua

VERSION=$(grep '^M.TREE_SITTER_C3_VERSION =' lua/c3/init.lua | cut -d'"' -f2)

if [ -z "$VERSION" ]; then
    echo "Could not find M.TREE_SITTER_C3_VERSION in lua/c3/init.lua"
    exit 1
fi

echo "Updating tree-sitter-c3 queries to version: $VERSION"

BASE_URL="https://raw.githubusercontent.com/c3lang/tree-sitter-c3"

mkdir -p queries/c3

for FILE in highlights.scm injections.scm folds.scm indents.scm unused_queries.scm; do
    echo "Downloading $FILE..."
    curl -sL "$BASE_URL/$VERSION/queries/$FILE" -o "queries/c3/$FILE"
done

echo "Done."
