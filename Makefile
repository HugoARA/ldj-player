### TARGET NAME ###
TARGET 				:= demo
### GIT REPO DEPENDENCIES ###
STM32CUBEF7 		:= $(PWD)/STM32CubeF7
### TOOLCHAIN SETUP ###
CXX					:= /usr/bin/arm-none-eabi-g++
CC 					:= /usr/bin/arm-none-eabi-gcc
LD 					:= /usr/bin/arm-none-eabi-gcc
OBJCOPY				:= /usr/bin/arm-none-eabi-objcopy
### CPU, DEVELOPMENT PLATFORM AND BSP FLAGS ###
ARCH_FLAGS 			:= -mthumb -march=armv7e-m -mfloat-abi=hard -mfpu=fpv4-sp-d16 
MCU_FLAGS 			:= -DSTM32F746xx -DUSE_HAL_DRIVER
### LINKER SCRIPT ###
LDSCRIPT			:= $(PWD)/ldscripts/STM32F746NGHx_FLASH.ld
### STM32F746G DISCOVERY DRIVER ###
STM32F746G_INC 		:= 	-I$(STM32CUBEF7)/Drivers/CMSIS/Include \
						-I$(STM32CUBEF7)/Drivers/CMSIS/Core/Include \
						-I$(STM32CUBEF7)/Drivers/CMSIS/Device/ST/STM32F7xx/Include \
						-I$(STM32CUBEF7)/Drivers/STM32F7xx_HAL_Driver/Inc

STARTUP_STM32F746G 	:= $(STM32CUBEF7)/Drivers/CMSIS/Device/ST/STM32F7xx/Source/Templates/gcc/startup_stm32f746xx.s
SYSTEM_STM32F746G	:= $(STM32CUBEF7)/Drivers/CMSIS/Device/ST/STM32F7xx/Source/Templates/system_stm32f7xx.c
### PROJECT INCLUDES ###
INCDIR 				:= -I$(PWD)/inc
INC 				:= $(STM32F746G_INC) $(INCDIR)
### PROJECT SOURCES ###
SRCDIR 				:= $(PWD)/src
SOURCES				:= $(SRCDIR)/main.cpp
### COMPILER AND LINKER FLAGS ###
CFLAGS	 			:= -O0 -std=c11 -Wall -Wextra -Wno-unused-parameter $(ARCH_FLAGS) $(MCU_FLAGS) $(INC)
CXXFLAGS			:= -O0 -std=c++11 -Wall -Wextra -Wno-unused-parameter $(ARCH_FLAGS) $(MCU_FLAGS) $(INC)
LDFLAGS				:= --specs=rdimon.specs
### OBJECT FILES ###
BINDIR				:= $(PWD)/bin
OBJDIR 				:= $(PWD)/obj
OBJS 				:= $(addprefix $(OBJDIR)/,$(notdir $(STARTUP_STM32F746G:.s=.o)) $(notdir $(SYSTEM_STM32F746G:.c=.o)) $(notdir $(SOURCES:.cpp=.o)))

.PHONY: all release debug clean flash openocd

all: debug

debug: CFLAGS += -DDEBUG -g3
debug: CXXFLAGS += -DDEBUG -g3
debug: $(STM32CUBEF7) $(BINDIR)/$(TARGET).bin

release: CFLAGS += -O2
release: CXXFLAGS += -O2
release: $(STM32CUBEF7) $(BINDIR)/$(TARGET).bin

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
