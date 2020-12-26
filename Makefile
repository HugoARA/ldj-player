### TARGET NAME ###
TARGET                := demo
### GIT REPO DEPENDENCIES ###
STM32CUBEF7           := $(PWD)/STM32CubeF7
### TOOLCHAIN SETUP ###
CXX                   := /usr/bin/arm-none-eabi-g++
CC                    := /usr/bin/arm-none-eabi-gcc
LD                    := /usr/bin/arm-none-eabi-gcc
OBJCOPY               := /usr/bin/arm-none-eabi-objcopy
### CPU, DEVELOPMENT PLATFORM AND BSP FLAGS ###
ARCH_FLAGS            := -mthumb -march=armv7e-m -mfloat-abi=hard -mfpu=fpv4-sp-d16 
MCU_FLAGS             := -DSTM32F746xx -DUSE_HAL_DRIVER
### LINKER SCRIPT ###
LDSCRIPT              := $(PWD)/ldscripts/STM32F746NGHx_FLASH.ld
### STM32F746G DISCOVERY DRIVER ###
STM32F746G_INC        := -I$(STM32CUBEF7)/Drivers/CMSIS/Include \
                         -I$(STM32CUBEF7)/Drivers/CMSIS/Core/Include \
                         -I$(STM32CUBEF7)/Drivers/CMSIS/Device/ST/STM32F7xx/Include

FWDIR                 := $(PWD)/fw
STARTUP_STM32F746G    := $(FWDIR)/startup_stm32f746xx.S
SYSTEM_STM32F746G     := $(FWDIR)/system_stm32f7xx.c
SD_DISKIO             := $(FWDIR)/sd_diskio.c
### STM32F7XX HAL Driver ###
STM32F7XX_HAL         := $(STM32CUBEF7)/Drivers/STM32F7xx_HAL_Driver
STM32F7XX_HAL_INC     := -I$(STM32F7XX_HAL)/Inc
STM32F7XX_HAL_SRC_DIR := $(STM32F7XX_HAL)/Src
STM32F7XX_HAL_SRC     := $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_rcc.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_pwr_ex.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_cortex.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_gpio.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_uart.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_i2c.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_sd.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_ll_sdmmc.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_dma.c \
                         $(STM32F7XX_HAL_SRC_DIR)/stm32f7xx_hal_sai.c
### STM32F746G-Discovery BSP ###
STM32F7_DISCOVERY_DIR := $(STM32CUBEF7)/Drivers/BSP/STM32746G-Discovery
STM32F7_DISCOVERY_INC := -I$(STM32F7_DISCOVERY_DIR)
STM32F7_DISCOVERY_SRC := $(STM32F7_DISCOVERY_DIR)/stm32746g_discovery.c \
                         $(STM32F7_DISCOVERY_DIR)/stm32746g_discovery_sd.c \
                         $(STM32F7_DISCOVERY_DIR)/stm32746g_discovery_audio.c
### wm8994 ###
WM8994_DIR            := $(STM32CUBEF7)/Drivers/BSP/Components/wm8994
WM8994_SRC            := $(WM8994_DIR)/wm8994.c
### FatFs ###
FATFS_DIR             := $(STM32CUBEF7)/Middlewares/Third_Party/FatFs
FATFS_INC             := -I$(FATFS_DIR)/src
FATFS_SRC_DIR         := $(FATFS_DIR)/src
FATFS_SRC             := $(FATFS_SRC_DIR)/ff.c \
                         $(FATFS_SRC_DIR)/diskio.c \
                         $(FATFS_SRC_DIR)/ff_gen_drv.c \
                         $(FATFS_SRC_DIR)/option/unicode.c \
                         $(FATFS_SRC_DIR)/option/syscall.c
### PROJECT INCLUDES ###
INCDIR                := -I$(PWD)/inc
INC                   := $(STM32F746G_INC) $(STM32F7XX_HAL_INC) $(STM32F7_DISCOVERY_INC) $(FATFS_INC) $(INCDIR)
### PROJECT SOURCES ###
SRCDIR                := $(PWD)/src
SOURCES               := $(SRCDIR)/main.cpp
### COMPILER AND LINKER FLAGS ###
CFLAGS                := -O0 -std=c11 -Wall -Wextra -Wno-unused-parameter $(ARCH_FLAGS) $(MCU_FLAGS) $(INC) -fdata-sections -ffunction-sections
CXXFLAGS              := -O0 -std=c++11 -Wall -Wextra -Wno-unused-parameter -fno-exceptions -fno-rtti $(ARCH_FLAGS) $(MCU_FLAGS) $(INC)
LDFLAGS               := -Wl,--gc-sections
### OBJECT FILES ###
BINDIR                := $(PWD)/bin
OBJDIR                := $(PWD)/obj
OBJS                  := $(addprefix $(OBJDIR)/, \
                            $(notdir $(STARTUP_STM32F746G:.S=.o)) \
                            $(notdir $(SYSTEM_STM32F746G:.c=.o)) \
                            $(notdir $(SOURCES:.cpp=.o)) \
                            $(notdir $(STM32F7XX_HAL_SRC:.c=.o)) \
                            $(notdir $(STM32F7_DISCOVERY_SRC:.c=.o)) \
                            $(notdir $(FATFS_SRC:.c=.o)) \
                            $(notdir $(SD_DISKIO:.c=.o)) \
                            $(notdir $(WM8994_SRC:.c=.o)))

.PHONY: all release debug clean flash openocd

all: debug

debug: CFLAGS += -DDEBUG -g3
debug: CXXFLAGS += -DDEBUG -g3
debug: LDFLAGS += --specs=rdimon.specs
debug: $(STM32CUBEF7) $(BINDIR)/$(TARGET).bin

release: CFLAGS += -O3
release: CXXFLAGS += -O3
release: LDFLAGS += --specs=nosys.specs
release: clean $(STM32CUBEF7) $(BINDIR)/$(TARGET).bin

$(BINDIR)/$(TARGET).bin: $(BINDIR)/$(TARGET).elf

$(BINDIR)/$(TARGET).elf: $(OBJS)
	@mkdir -p $(BINDIR)
	$(LD) $(ARCH_FLAGS) -T$(LDSCRIPT) -o $@ $^ $(LDFLAGS)
	@touch .blank

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJDIR)/startup_stm32f746xx.o: $(STARTUP_STM32F746G)
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/system_stm32f7xx.o: $(SYSTEM_STM32F746G)
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@ 

$(OBJDIR)/%.o: $(STM32F7XX_HAL_SRC_DIR)/%.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(STM32F7_DISCOVERY_DIR)/%.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(FATFS_SRC_DIR)/%.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(FATFS_SRC_DIR)/option/%.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(WM8994_DIR)/%.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(FWDIR)/%.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(STM32CUBEF7):
	@git clone https://github.com/STMicroelectronics/STM32CubeF7.git

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

flash: $(BINDIR)/$(TARGET).bin
	openocd -f /usr/share/openocd/scripts/interface/stlink-v2-1.cfg -f /usr/share/openocd/scripts/target/stm32f7x.cfg -c "program $< exit 0x08000000"

openocd:
	openocd -f /usr/share/openocd/scripts/interface/stlink-v2-1.cfg -f /usr/share/openocd/scripts/target/stm32f7x.cfg

clean:
	@rm -rf $(OBJDIR) $(BINDIR)
