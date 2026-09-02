/* Linker script for bare-metal RV32I core (Harvard: separate IMEM/DMEM)
 * IMEM: hex-loaded, starts at 0x0000
 * DMEM: 4096 bytes, addresses 0x0000 - 0x0FFF
 * Signature region: 0x0000 in DMEM (relocatable via begin_signature symbol)
 */
RAM_ORIGIN = 0x00000000;
RAM_LENGTH = 0x00001000;  /* 4096 bytes */
TEST_BASE  = 0x00000000;
NUM_HARTS  = 1;

STACK_SIZE = 0x400;

OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

MEMORY
{
  ram (rwx) : ORIGIN = RAM_ORIGIN, LENGTH = RAM_LENGTH
}

PROVIDE(__stack_size = STACK_SIZE);
PROVIDE(__num_harts = NUM_HARTS);

SECTIONS
{
  .text.init  TEST_BASE : { *(.text.init) } > ram
  .text.rvtest . : { *(.text.rvtest) *(.text.rvtest.*) } > ram

  . = ALIGN(0x400);
  .rodata . : { *(.rodata) *(.rodata.*) *(.srodata) *(.srodata.*) } > ram
  .data   . : { *(.data) *(.data.*) *(.sdata) *(.sdata.*) } > ram

  . = ALIGN(16);
  .bss . : {
    __bss_start = .;
    *(.sbss) *(.sbss.*) *(.bss) *(.bss.*) *(COMMON)
    . = ALIGN(16);
    __bss_end = .;
  } > ram

  . = ALIGN(16);
  __stack_bottom = .;
  . += __stack_size * __num_harts;
  __stack_top = .;

  . = ALIGN(0x100);
  .text.rvmodel . : { *(.text.rvmodel) *(.text.rvmodel.*) *(.text) *(.text.*) } > ram

  . = ALIGN(0x100);
  _end = .;
}