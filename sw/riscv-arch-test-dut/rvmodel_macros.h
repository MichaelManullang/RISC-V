/* rvmodel_macros.h - Minimal macros for bare-metal RV32I core (no CSRs, no traps)
 *
 * Our core has:
 *   - RV32I base instructions only
 *   - No M-mode, no CSRs, no traps, no interrupts
 *   - Separate IMEM (hex-loaded) and DMEM (4096 bytes)
 *   - Halt: write magic value to DMEM[0x0FFC]
 *
 * IMPORTANT: Do NOT define STANDARD_SM_SUPPORTED (we have no trap support).
 *            Do NOT define RVMODEL_BOOT_TO_MMODE (let default be empty label, no CSR writes).
 */

#ifndef _RVMODEL_MACROS_H
#define _RVMODEL_MACROS_H

/* ----- Data section (empty — nothing special needed) ----- */
#define RVMODEL_DATA_SECTION

/* ----- Terminate with PASS ----- */
#define RVMODEL_HALT_PASS  \
  li x1, 0xCAFEBABE       ;\
  li t0, 0x00000FFC       ;\
  sw x1, 0(t0)            ;\
1:                         ;\
  j 1b                    ;\

/* ----- Terminate with FAIL ----- */
#define RVMODEL_HALT_FAIL \
  li x1, 0xDEADBEEF       ;\
  li t0, 0x00000FFC       ;\
  sw x1, 0(t0)            ;\
1:                         ;\
  j 1b                    ;\

/* ----- No IO (no UART in our core) ----- */
#define RVMODEL_IO_WRITE_STR(_R1, _R2, _R3, _STR_PTR)

/* ----- No interrupts (all empty macros) ----- */
#define RVMODEL_INTERRUPT_LATENCY 10
#define RVMODEL_TIMER_INT_SOON_DELAY 100
#define RVMODEL_MAX_CYCLES_PER_TIMER_TICK 1
#define RVMODEL_SET_MEXT_INT(_R1, _R2)
#define RVMODEL_CLR_MEXT_INT(_R1, _R2)
#define RVMODEL_SET_MSW_INT(_R1, _R2)
#define RVMODEL_CLR_MSW_INT(_R1, _R2)
#define RVMODEL_SET_SEXT_INT(_R1, _R2)
#define RVMODEL_CLR_SEXT_INT(_R1, _R2)
#define RVMODEL_SET_SSW_INT(_R1, _R2)
#define RVMODEL_CLR_SSW_INT(_R1, _R2)

#endif /* _RVMODEL_MACROS_H */