#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_latex_project> [main_file.tex]"
    exit 1
fi

LATEX_PROJECT_DIR="$1"

if [ -z "$2" ]; then
    LATEX_MAIN_FILE="main.tex"
else
    LATEX_MAIN_FILE="$2"
fi

LATEX_CMD="xelatex -interaction=nonstopmode -output-directory=build"

if [ ! -d "$LATEX_PROJECT_DIR" ]; then
    echo "Error: Directory '$LATEX_PROJECT_DIR' does not exist."
    exit 1
fi

if [ ! -f "$LATEX_PROJECT_DIR/$LATEX_MAIN_FILE" ]; then
    echo "Error: Main LaTeX file '$LATEX_MAIN_FILE' not found in '$LATEX_PROJECT_DIR'."
    exit 1
fi

mkdir -p "$LATEX_PROJECT_DIR/build"

echo "Compiling '$LATEX_MAIN_FILE' once..."
cd "$LATEX_PROJECT_DIR"
$LATEX_CMD "$LATEX_MAIN_FILE"
echo "Recompilation done once!"

echo "Setting up watches. Changes will trigger recompilation..."
inotifywait -m -r -e modify "$LATEX_PROJECT_DIR" --format '%w%f' |
while read FILE; do
    if [[ "$FILE" =~ \.(tex|bib|sty|cls)$ ]]; then
        echo "Detected change in $FILE, recompiling..."
        cd "$LATEX_PROJECT_DIR"
        $LATEX_CMD "$LATEX_MAIN_FILE"
        echo "Recompilation done!"
    fi
done

