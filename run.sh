#!/bin/bash

# Check if input and output arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: ./run.sh -i <input_file> -o <output_file>"
    exit 1
fi

# Build the lexer (this will generate lex.yy.c and a.out)
make

# Check if the compiled executable exists
if [ ! -f ./src/a.out ]; then
    echo "Error: a.out not found. Compilation failed!"
    exit 1
fi

# Run the lexical analyzer with input and output files
./src/a.out "$@"
