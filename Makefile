# Compiler and tools
LEX = flex
CXX = g++
SRC_DIR = src
LEX_FILE = $(SRC_DIR)/lexer.l
SRC_FILE = $(SRC_DIR)/lex.yy.c
TARGET = $(SRC_DIR)/a.out

# Default target
all: $(TARGET)

# Generate lex.yy.c using flex
$(SRC_FILE): $(LEX_FILE)
	cd $(SRC_DIR) && $(LEX) lexer.l

# Compile lex.yy.c into a.out
$(TARGET): $(SRC_FILE)
	cd $(SRC_DIR) && $(CXX) -o a.out lex.yy.c

# Clean up generated files
clean:
	rm -f $(SRC_DIR)/a.out $(SRC_DIR)/lex.yy.c
