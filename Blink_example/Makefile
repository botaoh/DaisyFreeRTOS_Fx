# Project Name
TARGET = Blink

# Sources
CPP_SOURCES = Blink.cpp

# Directories
BUILD_DIR = build

# Library Locations (adjust paths as needed)
LIBDAISY_DIR = ../libDaisy
DAISYSP_DIR = ../DaisySP

# Library Search Paths
LDFLAGS += -L$(LIBDAISY_DIR)/build -L$(DAISYSP_DIR)/build

# Linker libraries
LDLIBS += -ldaisy -ldaisysp -lc -lm -lnosys

# Compiler settings
PREFIX = arm-none-eabi-
CXX = $(PREFIX)g++
CPPFLAGS += -O2 -Wall -fdata-sections -ffunction-sections

# Object Files: compile all CPP sources into object files.
# This simple rule assumes all sources are in the current directory.
OBJECTS = $(CPP_SOURCES:.cpp=.o)

# Compilation Rule (if not provided by libdaisy's makefile)
%.o: %.cpp
	$(CXX) -c $(CPPFLAGS) $< -o $@

# Linking Rule: produce the ELF file in the build directory.
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	mkdir -p $(BUILD_DIR)
	$(CXX) $(CPPFLAGS) $(OBJECTS) $(LDFLAGS) $(LDLIBS) \
	    --specs=nano.specs --specs=nosys.specs \
	    -T$(LIBDAISY_DIR)/core/STM32H750IB_flash.lds \
	    -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections -Wl,--print-memory-usage \
	    -o $@

# Default target
all: $(BUILD_DIR)/$(TARGET).elf

clean:
	rm -rf $(BUILD_DIR) *.o

.PHONY: all clean

# Include the libdaisy core Makefile for additional rules (if needed)
SYSTEM_FILES_DIR = $(LIBDAISY_DIR)/core
include $(SYSTEM_FILES_DIR)/Makefile
