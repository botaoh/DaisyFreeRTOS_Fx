# Project Name
TARGET = DaisyFreeRTOSFX
TARGET_ELF = $(TARGET).elf

# Directories
LIBDAISY_DIR = libdaisy
DAISYSP_DIR = DaisySP
FREERTOS_DIR = Middlewares/Third_Party/FreeRTOS
BUILD_DIR = build
SRC_DIR = Core

# VPATH to help match nested sources
VPATH = $(sort $(dir $(APP_SRC)))

# Source Files (use wildcard to recursively grab all needed files)
APP_SRC := \
	$(wildcard $(SRC_DIR)/*.cpp) \
	$(wildcard $(SRC_DIR)/*.c) \
	$(wildcard $(FREERTOS_DIR)/*.c) \
	$(wildcard $(FREERTOS_DIR)/portable/MemMang/*.c) \
	$(wildcard $(FREERTOS_DIR)/portable/GCC/ARM_CM7/r0p1/*.c) \
	$(wildcard $(DAISYSP_DIR)/Source/**/*.cpp) \
	$(wildcard $(LIBDAISY_DIR)/src/**/*.c) \
	$(wildcard $(LIBDAISY_DIR)/src/**/*.cpp) \
	$(wildcard $(LIBDAISY_DIR)/Middlewares/**/*.c) \
	$(wildcard $(LIBDAISY_DIR)/Middlewares/**/*.cpp) \
	$(LIBDAISY_DIR)/core/startup_stm32h750xx.c

# Include Paths
# Patched USB Device Library headers are added first so that definitions for USBD_MODE_MIDI (and others) are used.
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
	-I$(LIBDAISY_DIR)/Middlewares/Patched/ST/STM32_USB_Device_Library/Class/CDC/Inc \
	-I$(LIBDAISY_DIR)/src \
	-I$(LIBDAISY_DIR)/src/sys \
	-I$(LIBDAISY_DIR)/src/usbh \
	-I$(LIBDAISY_DIR)/src/usbd \
	-I$(LIBDAISY_DIR)/src/util \
	-I$(LIBDAISY_DIR)/Drivers/STM32H7xx_HAL_Driver/Inc \
	-I$(LIBDAISY_DIR)/Drivers/CMSIS-Device/ST/STM32H7xx/Include \
	-I$(LIBDAISY_DIR)/Drivers/CMSIS_5/CMSIS/Core/Include \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Host_Library/Core/Inc \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Host_Library/Class/MIDI/Inc \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Device_Library/Core/Inc \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Src \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Device_Library/Core/Src \
	-I$(LIBDAISY_DIR)/Middlewares/Third_Party/FatFs/src \
	-I$(LIBDAISY_DIR)/core

# Compiler settings
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
CXX = $(PREFIX)g++
AR = $(PREFIX)ar

CFLAGS = -mcpu=cortex-m7 -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard \
	-DCORE_CM7 -DSTM32H750xx -DSTM32H750IB -DARM_MATH_CM7 -DUSE_HAL_DRIVER -D__CORTEX_M=7 \
	-Wall -O2 -fdata-sections -ffunction-sections $(C_INCLUDES)
CPPFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti -std=gnu++14

# Generate list of object files
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(filter %.c,$(APP_SRC))) \
          $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(filter %.cpp,$(APP_SRC)))

# Build Rules
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET).a: $(OBJECTS)
	$(AR) rcs $@ $^

LD = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy

# Linker script
LD_SCRIPT = $(LIBDAISY_DIR)/core/STM32H750IB_flash.lds

LDFLAGS = -T$(LD_SCRIPT) -L$(LIBDAISY_DIR)/build -L$(DAISYSP_DIR)/build \
	-Wl,--gc-sections -Wl,-Map=$(BUILD_DIR)/$(TARGET).map

LDLIBS = -ldaisy -ldaisysp -lm -lc -lnosys

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	$(LD) $(CPPFLAGS) $(OBJECTS) $(LDFLAGS) $(LDLIBS) -o $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
