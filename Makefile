# Project Name
TARGET = DaisyFreeRTOSFX
TARGET_ELF = $(TARGET).elf

# Directories
LIBDAISY_DIR = libdaisy
DAISYSP_DIR = DaisySP
FREERTOS_DIR = Middlewares/Third_Party/FreeRTOS
BUILD_DIR = build
SRC_DIR = Core

# Source Files
APP_SRC = \
	$(SRC_DIR)/main.cpp \
	$(SRC_DIR)/DelayReverb.cpp \
	$(FREERTOS_DIR)/croutine.c \
	$(FREERTOS_DIR)/event_groups.c \
	$(FREERTOS_DIR)/list.c \
	$(FREERTOS_DIR)/queue.c \
	$(FREERTOS_DIR)/stream_buffer.c \
	$(FREERTOS_DIR)/tasks.c \
	$(FREERTOS_DIR)/timers.c \
	$(FREERTOS_DIR)/portable/MemMang/heap_4.c \
	$(FREERTOS_DIR)/portable/GCC/ARM_CM7/r0p1/port.c \
	$(DAISYSP_DIR)/Source/Effects/chorus.cpp

# Include Paths
C_INCLUDES = \
	-I$(FREERTOS_DIR)/include \
	-I$(FREERTOS_DIR)/portable/GCC/ARM_CM7/r0p1 \
	-I$(DAISYSP_DIR)/Source \
	-I$(DAISYSP_DIR)/Source/Utility \
	-I$(DAISYSP_DIR)/Source/Effects \
	-I$(DAISYSP_DIR)/Source/Synthesis \
	-I$(DAISYSP_DIR)/Source/Filters \
	-I$(DAISYSP_DIR)/Source/Dynamics \
	-I$(DAISYSP_DIR)/Source/PhysicalModeling \
	-I$(DAISYSP_DIR)/Source/Noise \
	-I$(DAISYSP_DIR)/Source/Control \
	-I$(LIBDAISY_DIR)/src \
	-I$(LIBDAISY_DIR)/src/sys \
	-I$(LIBDAISY_DIR)/src/usbh \
	-I$(LIBDAISY_DIR)/Drivers/STM32H7xx_HAL_Driver/Inc \
	-I$(LIBDAISY_DIR)/Drivers/CMSIS-Device/ST/STM32H7xx/Include \
	-I$(LIBDAISY_DIR)/Drivers/CMSIS_5/CMSIS/Core/Include \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Host_Library/Core/Inc \
	-I$(LIBDAISY_DIR)/Middlewares/Third_Party/FatFs/src

# Compiler settings
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
CXX = $(PREFIX)g++
AR = $(PREFIX)ar

CFLAGS = -mcpu=cortex-m7 -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard \
	-DCORE_CM7 -DSTM32H750xx -DSTM32H750IB -DARM_MATH_CM7 -DUSE_HAL_DRIVER -D__CORTEX_M=7 \
	-Wall -O2 -fdata-sections -ffunction-sections $(C_INCLUDES)
CPPFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti -std=gnu++14

# Object Files (split by extension)
C_SRCS   := $(filter %.c, $(APP_SRC))
CPP_SRCS := $(filter %.cpp, $(APP_SRC))

OBJECTS = $(addprefix $(BUILD_DIR)/, $(C_SRCS:.c=.o)) \
		  $(addprefix $(BUILD_DIR)/, $(CPP_SRCS:.cpp=.o))

# Build Rules
all: $(BUILD_DIR)/$(TARGET).a

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET).a: $(OBJECTS)
	$(AR) rcs $@ $^

LD = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy

# Linker script (change path if needed)
LD_SCRIPT = $(LIBDAISY_DIR)/core/STM32H750IB_flash.lds

LDFLAGS = -T$(LD_SCRIPT) -Wl,--gc-sections -Wl,-Map=$(BUILD_DIR)/$(TARGET).map

BIN_FILE = $(BUILD_DIR)/$(TARGET).bin

# Add to the build rules
all: $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	$(LD) $(CPPFLAGS) $(OBJECTS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
