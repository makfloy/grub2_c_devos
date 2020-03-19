arch ?= i386
kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso

linker_script := src/arch/$(arch)/linker.ld
grub_cfg := src/arch/$(arch)/grub.cfg
asm_src_files := $(wildcard src/arch/$(arch)/*.asm)
asm_obj_files := $(patsubst src/arch/$(arch)/%.asm, \
    build/arch/$(arch)/%.o, $(asm_src_files))

c_src_files := $(wildcard src/arch/$(arch)/*.c)
c_obj_files := $(patsubst src/arch/$(arch)/%.c, \
    build/arch/$(arch)/%.o, $(c_src_files))


.PHONY: all clean run iso

all: iso

clean:
	@rm -fr build/*

run: $(iso)
	@qemu-system-$(arch) -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel)
	@mkdir -p build/isofs/boot/grub
	@cp $(kernel) build/isofs/boot/kernel.bin
	@cp $(grub_cfg) build/isofs/boot/grub
	@grub-mkrescue -o $(iso) build/isofs 

$(kernel): $(asm_obj_files) $(c_obj_files)
	@ld -n -T $(linker_script) -o $(kernel) $^

AS=nasm
ASFLAGS=-f elf32
build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	@mkdir -p $(@D)
	@$(AS) $(ASFLAGS) $< -o $@

CC=gcc
CGLAGS=-m32 -std=gnu99 -ffreestanding -O2 -Wall -Wextra -c
build/arch/$(arch)/%.o: src/arch/$(arch)/%.c
	mkdir -p $(@D)
	@$(CC) $(CFLAGS) $< -o $@

