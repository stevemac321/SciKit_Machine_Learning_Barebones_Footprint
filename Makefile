# Project name
PROJECT = BareBones

# Toolchain
CC      = arm-none-eabi-gcc
AS      = arm-none-eabi-as
LD      = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
SIZE    = arm-none-eabi-size

# Flags
LDFLAGS = -TSTM32F401RETX_FLASH.ld -nostdlib -Wl,--gc-sections

CFLAGS  = -mcpu=cortex-m4 -mthumb -Wall -Og -ffreestanding -g -DSTM32F401xE -DDEBUG \
          -I./Core/Inc \
          -I./Drivers/CMSIS/Include \
          -I./Drivers/CMSIS/Device/ST/STM32F4xx/Include \
          -I./Drivers/CMSIS/DSP/Include \
          -mfpu=fpv4-sp-d16 -mfloat-abi=hard

# Source files
SRCS = \
  Core/Src/main.c \
  Core/Src/stm32f4xx_it.c \
  Core/Src/syscalls.c \
  Core/Src/sysmem.c \
  Core/Src/system_stm32f4xx.c \
  Core/Startup/startup_stm32f401retx.s \
#  Drivers/CMSIS/DSP/Source/SVMFunctions/*.c 

# DSP source files
SVM_SRCS := $(wildcard Drivers/CMSIS/DSP/Source/SVMFunctions/*.c)
SRCS += $(SVM_SRCS)

# Object files
OBJS = $(SRCS:.c=.o)
OBJS := $(OBJS:.s=.o)


# Default target
all: $(PROJECT).bin

# ELF file
$(PROJECT).elf: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)
	$(SIZE) $@

# BIN file
$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary $< $@

# Compile C files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble startup file
%.o: %.s
	$(CC) -c $< -o $@

# Flash using st-flash
flash: $(PROJECT).bin
	st-flash write $(PROJECT).bin 0x08000000

# Clean
clean:
	rm -f $(PROJECT).elf $(PROJECT).bin $(OBJS)


.PHONY: all clean flash

