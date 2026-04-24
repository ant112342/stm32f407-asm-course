PROJECT ?= examples/mov_operations
PROJECT := $(patsubst %/,%,$(PROJECT))

TARGET := $(notdir $(PROJECT))

CORE_DIR = core
BUILD_DIR = build/$(TARGET)
ACTIVE_ELF = build/current.elf

PREFIX  = arm-none-eabi-
CC      = $(PREFIX)gcc
AS      = $(PREFIX)gcc
LD      = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
OBJDUMP = $(PREFIX)objdump
SIZE    = $(PREFIX)size
GDB     = gdb-multiarch

CPU     = -mcpu=cortex-m4
FPU     = -mfpu=fpv4-sp-d16
FLOAT   = -mfloat-abi=hard
ARCH    = $(CPU) $(FPU) $(FLOAT) -mthumb

LDSCRIPT = $(CORE_DIR)/stm32f407.ld

ASFLAGS = $(ARCH) -g -Wall -x assembler-with-cpp

LDFLAGS = $(ARCH) -nostdlib -nostartfiles \
          -T $(LDSCRIPT) \
          -Wl,--gc-sections \
          -Wl,-Map=$(BUILD_DIR)/$(TARGET).map

SRCS = \
    $(PROJECT)/main.s \
    $(CORE_DIR)/startup.s

OBJS = $(patsubst %.s,$(BUILD_DIR)/%.o,$(notdir $(SRCS)))

.PHONY: all clean flash debug disasm size openocd

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin size
	@cp $(BUILD_DIR)/$(TARGET).elf $(ACTIVE_ELF)

$(BUILD_DIR)/%.o: $(PROJECT)/%.s | $(BUILD_DIR)
	$(AS) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/startup.o: $(CORE_DIR)/startup.s | $(BUILD_DIR)
	$(AS) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

size: $(BUILD_DIR)/$(TARGET).elf
	@$(SIZE) $<

disasm: $(BUILD_DIR)/$(TARGET).elf
	$(OBJDUMP) -d -S $< | less

flash: $(BUILD_DIR)/$(TARGET).elf
	openocd \
		-f interface/stlink.cfg \
		-f target/stm32f4x.cfg \
		-c "program $< verify reset exit"

openocd:
	openocd \
		-f interface/stlink.cfg \
		-f target/stm32f4x.cfg \
		-c "init" \
		-c "reset halt"

debug: $(BUILD_DIR)/$(TARGET).elf
	$(GDB) \
		-ex "target extended-remote localhost:3333" \
		-ex "monitor reset halt" \
		-ex "load" \
		-ex "monitor reset halt" \
		$<

clean:
	rm -rf build