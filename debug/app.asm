
bin/app.elf:     file format elf32-littlearm


Disassembly of section .text:

c0d00000 <main>:
    os_lib_call((unsigned int *)&libcall_params);
}

// Weird low-level black magic. No need to edit this.
__attribute__((section(".boot"))) int main(int arg0)
{
c0d00000:	b5b0      	push	{r4, r5, r7, lr}
c0d00002:	b090      	sub	sp, #64	; 0x40
c0d00004:	4604      	mov	r4, r0
    // Exit critical section
    __asm volatile("cpsie i");
c0d00006:	b662      	cpsie	i

    // Ensure exception will work as planned
    os_boot();
c0d00008:	f000 fce0 	bl	c0d009cc <os_boot>
c0d0000c:	ad01      	add	r5, sp, #4

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY
    {
        TRY
c0d0000e:	4628      	mov	r0, r5
c0d00010:	f001 f92c 	bl	c0d0126c <setjmp>
c0d00014:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0d00016:	0400      	lsls	r0, r0, #16
c0d00018:	d117      	bne.n	c0d0004a <main+0x4a>
c0d0001a:	a801      	add	r0, sp, #4
c0d0001c:	f000 ff02 	bl	c0d00e24 <try_context_set>
c0d00020:	900b      	str	r0, [sp, #44]	; 0x2c
// get API level
SYSCALL unsigned int get_api_level(void);

#ifndef HAVE_BOLOS
static inline void check_api_level(unsigned int apiLevel) {
  if (apiLevel < get_api_level()) {
c0d00022:	f000 febd 	bl	c0d00da0 <get_api_level>
c0d00026:	280d      	cmp	r0, #13
c0d00028:	d302      	bcc.n	c0d00030 <main+0x30>
c0d0002a:	20ff      	movs	r0, #255	; 0xff
    os_sched_exit(-1);
c0d0002c:	f000 fee0 	bl	c0d00df0 <os_sched_exit>
c0d00030:	2001      	movs	r0, #1
c0d00032:	0201      	lsls	r1, r0, #8
        {
            // Low-level black magic.
            check_api_level(CX_COMPAT_APILEVEL);

            // Check if we are called from the dashboard.
            if (!arg0)
c0d00034:	2c00      	cmp	r4, #0
c0d00036:	d017      	beq.n	c0d00068 <main+0x68>
                // Not called from dashboard: called from the ethereum app!
                const unsigned int *args = (const unsigned int *)arg0;

                // If `ETH_PLUGIN_CHECK_PRESENCE` is set, this means the caller is just trying to
                // know whether this app exists or not. We can skip `dispatch_plugin_calls`.
                if (args[0] != ETH_PLUGIN_CHECK_PRESENCE)
c0d00038:	6820      	ldr	r0, [r4, #0]
c0d0003a:	31ff      	adds	r1, #255	; 0xff
c0d0003c:	4288      	cmp	r0, r1
c0d0003e:	d002      	beq.n	c0d00046 <main+0x46>
                {
                    dispatch_plugin_calls(args[0], (void *)args[1]);
c0d00040:	6861      	ldr	r1, [r4, #4]
c0d00042:	f000 fc87 	bl	c0d00954 <dispatch_plugin_calls>
                }

                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
c0d00046:	f000 fec7 	bl	c0d00dd8 <os_lib_end>
            }
        }
        FINALLY
c0d0004a:	f000 fedf 	bl	c0d00e0c <try_context_get>
c0d0004e:	a901      	add	r1, sp, #4
c0d00050:	4288      	cmp	r0, r1
c0d00052:	d102      	bne.n	c0d0005a <main+0x5a>
c0d00054:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d00056:	f000 fee5 	bl	c0d00e24 <try_context_set>
c0d0005a:	a801      	add	r0, sp, #4
        {
        }
    }
    END_TRY;
c0d0005c:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d0005e:	2800      	cmp	r0, #0
c0d00060:	d10b      	bne.n	c0d0007a <main+0x7a>
c0d00062:	2000      	movs	r0, #0

    // Will not get reached.
    return 0;
}
c0d00064:	b010      	add	sp, #64	; 0x40
c0d00066:	bdb0      	pop	{r4, r5, r7, pc}
    libcall_params[2] = RUN_APPLICATION;
c0d00068:	900f      	str	r0, [sp, #60]	; 0x3c
    libcall_params[1] = 0x100;
c0d0006a:	910e      	str	r1, [sp, #56]	; 0x38
    libcall_params[0] = (unsigned int)"Ethereum";
c0d0006c:	4804      	ldr	r0, [pc, #16]	; (c0d00080 <main+0x80>)
c0d0006e:	4478      	add	r0, pc
c0d00070:	900d      	str	r0, [sp, #52]	; 0x34
c0d00072:	a80d      	add	r0, sp, #52	; 0x34
    os_lib_call((unsigned int *)&libcall_params);
c0d00074:	f000 fea2 	bl	c0d00dbc <os_lib_call>
c0d00078:	e7f3      	b.n	c0d00062 <main+0x62>
    END_TRY;
c0d0007a:	f000 fcac 	bl	c0d009d6 <os_longjmp>
c0d0007e:	46c0      	nop			; (mov r8, r8)
c0d00080:	00001730 	.word	0x00001730

c0d00084 <cx_hash_get_size>:
CX_TRAMPOLINE _NR_cx_groestl_get_output_size               cx_groestl_get_output_size
CX_TRAMPOLINE _NR_cx_groestl_init_no_throw                 cx_groestl_init_no_throw
CX_TRAMPOLINE _NR_cx_groestl_update                        cx_groestl_update
CX_TRAMPOLINE _NR_cx_hash_final                            cx_hash_final
CX_TRAMPOLINE _NR_cx_hash_get_info                         cx_hash_get_info
CX_TRAMPOLINE _NR_cx_hash_get_size                         cx_hash_get_size
c0d00084:	b403      	push	{r0, r1}
c0d00086:	4801      	ldr	r0, [pc, #4]	; (c0d0008c <cx_hash_get_size+0x8>)
c0d00088:	e011      	b.n	c0d000ae <cx_trampoline_helper>
c0d0008a:	0000      	.short	0x0000
c0d0008c:	0000002f 	.word	0x0000002f

c0d00090 <cx_hash_no_throw>:
CX_TRAMPOLINE _NR_cx_hash_init                             cx_hash_init
CX_TRAMPOLINE _NR_cx_hash_init_ex                          cx_hash_init_ex
CX_TRAMPOLINE _NR_cx_hash_no_throw                         cx_hash_no_throw
c0d00090:	b403      	push	{r0, r1}
c0d00092:	4801      	ldr	r0, [pc, #4]	; (c0d00098 <cx_hash_no_throw+0x8>)
c0d00094:	e00b      	b.n	c0d000ae <cx_trampoline_helper>
c0d00096:	0000      	.short	0x0000
c0d00098:	00000032 	.word	0x00000032

c0d0009c <cx_keccak_init_no_throw>:
CX_TRAMPOLINE _NR_cx_hmac_sha384_init                      cx_hmac_sha384_init
CX_TRAMPOLINE _NR_cx_hmac_sha512                           cx_hmac_sha512
CX_TRAMPOLINE _NR_cx_hmac_sha512_init_no_throw             cx_hmac_sha512_init_no_throw
CX_TRAMPOLINE _NR_cx_hmac_update                           cx_hmac_update
CX_TRAMPOLINE _NR_cx_init                                  cx_init
CX_TRAMPOLINE _NR_cx_keccak_init_no_throw                  cx_keccak_init_no_throw
c0d0009c:	b403      	push	{r0, r1}
c0d0009e:	4801      	ldr	r0, [pc, #4]	; (c0d000a4 <cx_keccak_init_no_throw+0x8>)
c0d000a0:	e005      	b.n	c0d000ae <cx_trampoline_helper>
c0d000a2:	0000      	.short	0x0000
c0d000a4:	00000044 	.word	0x00000044

c0d000a8 <cx_swap_uint64>:
CX_TRAMPOLINE _NR_cx_shake128_init_no_throw                cx_shake128_init_no_throw
CX_TRAMPOLINE _NR_cx_shake256_init_no_throw                cx_shake256_init_no_throw
CX_TRAMPOLINE _NR_cx_swap_buffer32                         cx_swap_buffer32
CX_TRAMPOLINE _NR_cx_swap_buffer64                         cx_swap_buffer64
CX_TRAMPOLINE _NR_cx_swap_uint32                           cx_swap_uint32
CX_TRAMPOLINE _NR_cx_swap_uint64                           cx_swap_uint64
c0d000a8:	b403      	push	{r0, r1}
c0d000aa:	4802      	ldr	r0, [pc, #8]	; (c0d000b4 <cx_trampoline_helper+0x6>)
c0d000ac:	e7ff      	b.n	c0d000ae <cx_trampoline_helper>

c0d000ae <cx_trampoline_helper>:

.thumb_func
cx_trampoline_helper:
  ldr  r1, =_cx_trampoline
c0d000ae:	4902      	ldr	r1, [pc, #8]	; (c0d000b8 <cx_trampoline_helper+0xa>)
  bx   r1
c0d000b0:	4708      	bx	r1
c0d000b2:	0000      	.short	0x0000
CX_TRAMPOLINE _NR_cx_swap_uint64                           cx_swap_uint64
c0d000b4:	0000006f 	.word	0x0000006f
  ldr  r1, =_cx_trampoline
c0d000b8:	00120001 	.word	0x00120001

c0d000bc <getEthAddressStringFromBinary>:
#include "eth_internals.h"

void getEthAddressStringFromBinary(uint8_t *address,
                                   char *out,
                                   cx_sha3_t *sha3Context,
                                   uint64_t chainId) {
c0d000bc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d000be:	b093      	sub	sp, #76	; 0x4c
c0d000c0:	9203      	str	r2, [sp, #12]
c0d000c2:	460d      	mov	r5, r1
c0d000c4:	4603      	mov	r3, r0
c0d000c6:	2201      	movs	r2, #1
c0d000c8:	9818      	ldr	r0, [sp, #96]	; 0x60
    } locals_union;

    uint8_t i;
    bool eip1191 = false;
    uint32_t offset = 0;
    switch (chainId) {
c0d000ca:	4601      	mov	r1, r0
c0d000cc:	9204      	str	r2, [sp, #16]
c0d000ce:	4391      	bics	r1, r2
c0d000d0:	221e      	movs	r2, #30
c0d000d2:	404a      	eors	r2, r1
c0d000d4:	9919      	ldr	r1, [sp, #100]	; 0x64
c0d000d6:	430a      	orrs	r2, r1
c0d000d8:	2700      	movs	r7, #0
        case 30:
        case 31:
            eip1191 = true;
            break;
    }
    if (eip1191) {
c0d000da:	2a00      	cmp	r2, #0
c0d000dc:	463a      	mov	r2, r7
c0d000de:	9305      	str	r3, [sp, #20]
c0d000e0:	d116      	bne.n	c0d00110 <getEthAddressStringFromBinary+0x54>
c0d000e2:	ae06      	add	r6, sp, #24
c0d000e4:	2433      	movs	r4, #51	; 0x33
        u64_to_string(chainId, (char *) locals_union.tmp, sizeof(locals_union.tmp));
c0d000e6:	4632      	mov	r2, r6
c0d000e8:	4623      	mov	r3, r4
c0d000ea:	f000 f865 	bl	c0d001b8 <u64_to_string>
        offset = strnlen((char *) locals_union.tmp, sizeof(locals_union.tmp));
c0d000ee:	4630      	mov	r0, r6
c0d000f0:	4621      	mov	r1, r4
c0d000f2:	f001 f924 	bl	c0d0133e <strnlen>
        strlcat((char *) locals_union.tmp + offset, "0x", sizeof(locals_union.tmp) - offset);
c0d000f6:	1833      	adds	r3, r6, r0
c0d000f8:	1a22      	subs	r2, r4, r0
c0d000fa:	492d      	ldr	r1, [pc, #180]	; (c0d001b0 <getEthAddressStringFromBinary+0xf4>)
c0d000fc:	4479      	add	r1, pc
c0d000fe:	4618      	mov	r0, r3
c0d00100:	f001 f8ce 	bl	c0d012a0 <strlcat>
        offset = strnlen((char *) locals_union.tmp, sizeof(locals_union.tmp));
c0d00104:	4630      	mov	r0, r6
c0d00106:	4621      	mov	r1, r4
c0d00108:	f001 f919 	bl	c0d0133e <strnlen>
c0d0010c:	9b05      	ldr	r3, [sp, #20]
c0d0010e:	4602      	mov	r2, r0
c0d00110:	a806      	add	r0, sp, #24
c0d00112:	9202      	str	r2, [sp, #8]
    }
    for (i = 0; i < 20; i++) {
c0d00114:	1880      	adds	r0, r0, r2
c0d00116:	4e27      	ldr	r6, [pc, #156]	; (c0d001b4 <getEthAddressStringFromBinary+0xf8>)
c0d00118:	447e      	add	r6, pc
        uint8_t digit = address[i];
c0d0011a:	5dd9      	ldrb	r1, [r3, r7]
c0d0011c:	240f      	movs	r4, #15
        locals_union.tmp[offset + 2 * i] = HEXDIGITS[(digit >> 4) & 0x0f];
c0d0011e:	090a      	lsrs	r2, r1, #4
        locals_union.tmp[offset + 2 * i + 1] = HEXDIGITS[digit & 0x0f];
c0d00120:	4021      	ands	r1, r4
c0d00122:	5c71      	ldrb	r1, [r6, r1]
c0d00124:	7041      	strb	r1, [r0, #1]
        locals_union.tmp[offset + 2 * i] = HEXDIGITS[(digit >> 4) & 0x0f];
c0d00126:	5cb1      	ldrb	r1, [r6, r2]
c0d00128:	7001      	strb	r1, [r0, #0]
    for (i = 0; i < 20; i++) {
c0d0012a:	1c80      	adds	r0, r0, #2
c0d0012c:	1c7f      	adds	r7, r7, #1
c0d0012e:	2f14      	cmp	r7, #20
c0d00130:	d1f3      	bne.n	c0d0011a <getEthAddressStringFromBinary+0x5e>
c0d00132:	9804      	ldr	r0, [sp, #16]
c0d00134:	0201      	lsls	r1, r0, #8
c0d00136:	9f03      	ldr	r7, [sp, #12]
 */
cx_err_t cx_keccak_init_no_throw(cx_sha3_t *hash, size_t size);

static inline int cx_keccak_init ( cx_sha3_t * hash, size_t size )
{
  CX_THROW(cx_keccak_init_no_throw(hash, size));
c0d00138:	4638      	mov	r0, r7
c0d0013a:	f7ff ffaf 	bl	c0d0009c <cx_keccak_init_no_throw>
c0d0013e:	2800      	cmp	r0, #0
c0d00140:	d134      	bne.n	c0d001ac <getEthAddressStringFromBinary+0xf0>
c0d00142:	2020      	movs	r0, #32
 */
cx_err_t cx_hash_no_throw(cx_hash_t *hash, uint32_t mode, const uint8_t *in, size_t len, uint8_t *out, size_t out_len);

static inline int cx_hash ( cx_hash_t * hash, int mode, const unsigned char * in, unsigned int len, unsigned char * out, unsigned int out_len )
{
  CX_THROW(cx_hash_no_throw(hash, mode, in, len, out, out_len));
c0d00144:	9001      	str	r0, [sp, #4]
c0d00146:	aa06      	add	r2, sp, #24
c0d00148:	9200      	str	r2, [sp, #0]
c0d0014a:	9b02      	ldr	r3, [sp, #8]
    }
    cx_keccak_init(sha3Context, 256);
    cx_hash((cx_hash_t *) sha3Context,
            CX_LAST,
            locals_union.tmp,
            offset + 40,
c0d0014c:	3328      	adds	r3, #40	; 0x28
c0d0014e:	2101      	movs	r1, #1
c0d00150:	4638      	mov	r0, r7
c0d00152:	9104      	str	r1, [sp, #16]
c0d00154:	f7ff ff9c 	bl	c0d00090 <cx_hash_no_throw>
c0d00158:	2800      	cmp	r0, #0
c0d0015a:	d127      	bne.n	c0d001ac <getEthAddressStringFromBinary+0xf0>
  return cx_hash_get_size(hash);
c0d0015c:	4638      	mov	r0, r7
c0d0015e:	f7ff ff91 	bl	c0d00084 <cx_hash_get_size>
c0d00162:	2000      	movs	r0, #0
            locals_union.hashChecksum,
            32);
    for (i = 0; i < 40; i++) {
        uint8_t digit = address[i / 2];
        if ((i % 2) == 0) {
c0d00164:	4602      	mov	r2, r0
c0d00166:	9904      	ldr	r1, [sp, #16]
c0d00168:	400a      	ands	r2, r1
        uint8_t digit = address[i / 2];
c0d0016a:	0843      	lsrs	r3, r0, #1
c0d0016c:	9905      	ldr	r1, [sp, #20]
c0d0016e:	5cc9      	ldrb	r1, [r1, r3]
        if ((i % 2) == 0) {
c0d00170:	2a00      	cmp	r2, #0
c0d00172:	d001      	beq.n	c0d00178 <getEthAddressStringFromBinary+0xbc>
c0d00174:	4021      	ands	r1, r4
c0d00176:	e000      	b.n	c0d0017a <getEthAddressStringFromBinary+0xbe>
c0d00178:	0909      	lsrs	r1, r1, #4
            digit = (digit >> 4) & 0x0f;
        } else {
            digit = digit & 0x0f;
        }
        if (digit < 10) {
c0d0017a:	2909      	cmp	r1, #9
c0d0017c:	d801      	bhi.n	c0d00182 <getEthAddressStringFromBinary+0xc6>
            out[i] = HEXDIGITS[digit];
c0d0017e:	5c71      	ldrb	r1, [r6, r1]
c0d00180:	e00b      	b.n	c0d0019a <getEthAddressStringFromBinary+0xde>
c0d00182:	462f      	mov	r7, r5
c0d00184:	ad06      	add	r5, sp, #24
        } else {
            int v = (locals_union.hashChecksum[i / 2] >> (4 * (1 - i % 2))) & 0x0f;
c0d00186:	5ceb      	ldrb	r3, [r5, r3]
c0d00188:	0092      	lsls	r2, r2, #2
c0d0018a:	2504      	movs	r5, #4
c0d0018c:	4055      	eors	r5, r2
            if (v >= 8) {
c0d0018e:	40eb      	lsrs	r3, r5
c0d00190:	071a      	lsls	r2, r3, #28
c0d00192:	5c71      	ldrb	r1, [r6, r1]
c0d00194:	d500      	bpl.n	c0d00198 <getEthAddressStringFromBinary+0xdc>
c0d00196:	3920      	subs	r1, #32
c0d00198:	463d      	mov	r5, r7
c0d0019a:	5429      	strb	r1, [r5, r0]
    for (i = 0; i < 40; i++) {
c0d0019c:	1c40      	adds	r0, r0, #1
c0d0019e:	2828      	cmp	r0, #40	; 0x28
c0d001a0:	d1e0      	bne.n	c0d00164 <getEthAddressStringFromBinary+0xa8>
c0d001a2:	2028      	movs	r0, #40	; 0x28
c0d001a4:	2100      	movs	r1, #0
            } else {
                out[i] = HEXDIGITS[digit];
            }
        }
    }
    out[40] = '\0';
c0d001a6:	5429      	strb	r1, [r5, r0]
}
c0d001a8:	b013      	add	sp, #76	; 0x4c
c0d001aa:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d001ac:	f000 fc13 	bl	c0d009d6 <os_longjmp>
c0d001b0:	00001254 	.word	0x00001254
c0d001b4:	0000123b 	.word	0x0000123b

c0d001b8 <u64_to_string>:
    }

    out_buffer[out_buffer_size - 1] = '\0';
}

void u64_to_string(uint64_t src, char *dst, uint8_t dst_size) {
c0d001b8:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d001ba:	b087      	sub	sp, #28
c0d001bc:	9301      	str	r3, [sp, #4]
c0d001be:	9202      	str	r2, [sp, #8]
c0d001c0:	460a      	mov	r2, r1
c0d001c2:	4607      	mov	r7, r0
c0d001c4:	2100      	movs	r1, #0
c0d001c6:	9106      	str	r1, [sp, #24]
    // Copy the numbers in ASCII format.
    uint8_t i = 0;
    do {
        // Checking `i + 1` to make sure we have enough space for '\0'.
        if (i + 1 >= dst_size) {
c0d001c8:	b2cc      	uxtb	r4, r1
c0d001ca:	1c60      	adds	r0, r4, #1
c0d001cc:	9901      	ldr	r1, [sp, #4]
c0d001ce:	4288      	cmp	r0, r1
c0d001d0:	d23b      	bcs.n	c0d0024a <u64_to_string+0x92>
c0d001d2:	260a      	movs	r6, #10
c0d001d4:	2500      	movs	r5, #0
            THROW(0x6502);
        }
        dst[i] = src % 10 + '0';
        src /= 10;
c0d001d6:	4638      	mov	r0, r7
c0d001d8:	4611      	mov	r1, r2
c0d001da:	9205      	str	r2, [sp, #20]
c0d001dc:	4632      	mov	r2, r6
c0d001de:	462b      	mov	r3, r5
c0d001e0:	f000 feba 	bl	c0d00f58 <__aeabi_uldivmod>
c0d001e4:	9004      	str	r0, [sp, #16]
c0d001e6:	9103      	str	r1, [sp, #12]
c0d001e8:	4632      	mov	r2, r6
c0d001ea:	462b      	mov	r3, r5
c0d001ec:	f000 fed4 	bl	c0d00f98 <__aeabi_lmul>
c0d001f0:	1a39      	subs	r1, r7, r0
c0d001f2:	2030      	movs	r0, #48	; 0x30
        dst[i] = src % 10 + '0';
c0d001f4:	4308      	orrs	r0, r1
c0d001f6:	9902      	ldr	r1, [sp, #8]
c0d001f8:	5508      	strb	r0, [r1, r4]
c0d001fa:	9e06      	ldr	r6, [sp, #24]
        i++;
c0d001fc:	1c71      	adds	r1, r6, #1
c0d001fe:	2209      	movs	r2, #9
    } while (src);
c0d00200:	1bd2      	subs	r2, r2, r7
c0d00202:	462a      	mov	r2, r5
c0d00204:	9b05      	ldr	r3, [sp, #20]
c0d00206:	419a      	sbcs	r2, r3
c0d00208:	9f04      	ldr	r7, [sp, #16]
c0d0020a:	9a03      	ldr	r2, [sp, #12]
c0d0020c:	d3db      	bcc.n	c0d001c6 <u64_to_string+0xe>

    // Null terminate string
    dst[i] = '\0';
c0d0020e:	b2c9      	uxtb	r1, r1
c0d00210:	9a02      	ldr	r2, [sp, #8]
c0d00212:	5455      	strb	r5, [r2, r1]

    // Revert the string
    i--;
    uint8_t j = 0;
    while (j < i) {
c0d00214:	0631      	lsls	r1, r6, #24
c0d00216:	d016      	beq.n	c0d00246 <u64_to_string+0x8e>
c0d00218:	4615      	mov	r5, r2
        char tmp = dst[i];
        dst[i] = dst[j];
c0d0021a:	7811      	ldrb	r1, [r2, #0]
c0d0021c:	5511      	strb	r1, [r2, r4]
        dst[j] = tmp;
c0d0021e:	7010      	strb	r0, [r2, #0]
        i--;
c0d00220:	1e60      	subs	r0, r4, #1
    while (j < i) {
c0d00222:	0600      	lsls	r0, r0, #24
c0d00224:	0e40      	lsrs	r0, r0, #25
c0d00226:	d00e      	beq.n	c0d00246 <u64_to_string+0x8e>
c0d00228:	20fe      	movs	r0, #254	; 0xfe
c0d0022a:	43c0      	mvns	r0, r0
c0d0022c:	34fe      	adds	r4, #254	; 0xfe
c0d0022e:	2101      	movs	r1, #1
        char tmp = dst[i];
c0d00230:	192a      	adds	r2, r5, r4
c0d00232:	4626      	mov	r6, r4
c0d00234:	5c13      	ldrb	r3, [r2, r0]
        dst[i] = dst[j];
c0d00236:	5c6c      	ldrb	r4, [r5, r1]
c0d00238:	5414      	strb	r4, [r2, r0]
        dst[j] = tmp;
c0d0023a:	546b      	strb	r3, [r5, r1]
    while (j < i) {
c0d0023c:	1e74      	subs	r4, r6, #1
        j++;
c0d0023e:	1c49      	adds	r1, r1, #1
    while (j < i) {
c0d00240:	b2f3      	uxtb	r3, r6
c0d00242:	4299      	cmp	r1, r3
c0d00244:	d3f4      	bcc.n	c0d00230 <u64_to_string+0x78>
    }
}
c0d00246:	b007      	add	sp, #28
c0d00248:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0024a:	4801      	ldr	r0, [pc, #4]	; (c0d00250 <u64_to_string+0x98>)
            THROW(0x6502);
c0d0024c:	f000 fbc3 	bl	c0d009d6 <os_longjmp>
c0d00250:	00006502 	.word	0x00006502

c0d00254 <adjustDecimals>:
                    uint8_t decimals) {
c0d00254:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00256:	b081      	sub	sp, #4
c0d00258:	4614      	mov	r4, r2
c0d0025a:	460e      	mov	r6, r1
c0d0025c:	4605      	mov	r5, r0
    if ((srcLength == 1) && (*src == '0')) {
c0d0025e:	2901      	cmp	r1, #1
c0d00260:	d10a      	bne.n	c0d00278 <adjustDecimals+0x24>
c0d00262:	7828      	ldrb	r0, [r5, #0]
c0d00264:	2830      	cmp	r0, #48	; 0x30
c0d00266:	d107      	bne.n	c0d00278 <adjustDecimals+0x24>
        if (targetLength < 2) {
c0d00268:	2b02      	cmp	r3, #2
c0d0026a:	d32e      	bcc.n	c0d002ca <adjustDecimals+0x76>
c0d0026c:	2000      	movs	r0, #0
        target[1] = '\0';
c0d0026e:	7060      	strb	r0, [r4, #1]
c0d00270:	2030      	movs	r0, #48	; 0x30
        target[0] = '0';
c0d00272:	7020      	strb	r0, [r4, #0]
c0d00274:	2001      	movs	r0, #1
c0d00276:	e061      	b.n	c0d0033c <adjustDecimals+0xe8>
c0d00278:	9806      	ldr	r0, [sp, #24]
    if (srcLength <= decimals) {
c0d0027a:	42b0      	cmp	r0, r6
c0d0027c:	d222      	bcs.n	c0d002c4 <adjustDecimals+0x70>
        if (targetLength < srcLength + 1 + 1) {
c0d0027e:	1cb1      	adds	r1, r6, #2
c0d00280:	4299      	cmp	r1, r3
c0d00282:	d822      	bhi.n	c0d002ca <adjustDecimals+0x76>
c0d00284:	1a31      	subs	r1, r6, r0
        while (offset < delta) {
c0d00286:	9100      	str	r1, [sp, #0]
c0d00288:	d009      	beq.n	c0d0029e <adjustDecimals+0x4a>
c0d0028a:	4629      	mov	r1, r5
c0d0028c:	9b00      	ldr	r3, [sp, #0]
c0d0028e:	4627      	mov	r7, r4
            target[offset++] = src[sourceOffset++];
c0d00290:	780a      	ldrb	r2, [r1, #0]
c0d00292:	703a      	strb	r2, [r7, #0]
        while (offset < delta) {
c0d00294:	1c49      	adds	r1, r1, #1
c0d00296:	1e5b      	subs	r3, r3, #1
c0d00298:	1c7f      	adds	r7, r7, #1
c0d0029a:	2b00      	cmp	r3, #0
c0d0029c:	d1f8      	bne.n	c0d00290 <adjustDecimals+0x3c>
        if (decimals != 0) {
c0d0029e:	2800      	cmp	r0, #0
c0d002a0:	9a00      	ldr	r2, [sp, #0]
c0d002a2:	4611      	mov	r1, r2
c0d002a4:	d002      	beq.n	c0d002ac <adjustDecimals+0x58>
c0d002a6:	212e      	movs	r1, #46	; 0x2e
            target[offset++] = '.';
c0d002a8:	54a1      	strb	r1, [r4, r2]
c0d002aa:	1c51      	adds	r1, r2, #1
        while (sourceOffset < srcLength) {
c0d002ac:	42b2      	cmp	r2, r6
c0d002ae:	d22a      	bcs.n	c0d00306 <adjustDecimals+0xb2>
c0d002b0:	1863      	adds	r3, r4, r1
c0d002b2:	18ad      	adds	r5, r5, r2
c0d002b4:	2200      	movs	r2, #0
            target[offset++] = src[sourceOffset++];
c0d002b6:	5cae      	ldrb	r6, [r5, r2]
c0d002b8:	549e      	strb	r6, [r3, r2]
        while (sourceOffset < srcLength) {
c0d002ba:	1c52      	adds	r2, r2, #1
c0d002bc:	4290      	cmp	r0, r2
c0d002be:	d1fa      	bne.n	c0d002b6 <adjustDecimals+0x62>
c0d002c0:	188a      	adds	r2, r1, r2
c0d002c2:	e021      	b.n	c0d00308 <adjustDecimals+0xb4>
        if (targetLength < srcLength + 1 + 2 + delta) {
c0d002c4:	1cc1      	adds	r1, r0, #3
c0d002c6:	4299      	cmp	r1, r3
c0d002c8:	d901      	bls.n	c0d002ce <adjustDecimals+0x7a>
c0d002ca:	2000      	movs	r0, #0
c0d002cc:	e036      	b.n	c0d0033c <adjustDecimals+0xe8>
c0d002ce:	1b87      	subs	r7, r0, r6
c0d002d0:	202e      	movs	r0, #46	; 0x2e
        target[offset++] = '.';
c0d002d2:	7060      	strb	r0, [r4, #1]
c0d002d4:	2030      	movs	r0, #48	; 0x30
        target[offset++] = '0';
c0d002d6:	7020      	strb	r0, [r4, #0]
        for (uint32_t i = 0; i < delta; i++) {
c0d002d8:	2f00      	cmp	r7, #0
c0d002da:	d008      	beq.n	c0d002ee <adjustDecimals+0x9a>
c0d002dc:	1ca0      	adds	r0, r4, #2
c0d002de:	2230      	movs	r2, #48	; 0x30
            target[offset++] = '0';
c0d002e0:	4639      	mov	r1, r7
c0d002e2:	f000 ff8a 	bl	c0d011fa <__aeabi_memset>
        for (uint32_t i = 0; i < delta; i++) {
c0d002e6:	1cb9      	adds	r1, r7, #2
c0d002e8:	1e7f      	subs	r7, r7, #1
c0d002ea:	d1fd      	bne.n	c0d002e8 <adjustDecimals+0x94>
c0d002ec:	e000      	b.n	c0d002f0 <adjustDecimals+0x9c>
c0d002ee:	2102      	movs	r1, #2
        for (uint32_t i = 0; i < srcLength; i++) {
c0d002f0:	2e00      	cmp	r6, #0
c0d002f2:	d008      	beq.n	c0d00306 <adjustDecimals+0xb2>
c0d002f4:	1862      	adds	r2, r4, r1
c0d002f6:	2000      	movs	r0, #0
            target[offset++] = src[i];
c0d002f8:	5c2b      	ldrb	r3, [r5, r0]
c0d002fa:	5413      	strb	r3, [r2, r0]
        for (uint32_t i = 0; i < srcLength; i++) {
c0d002fc:	1c40      	adds	r0, r0, #1
c0d002fe:	4286      	cmp	r6, r0
c0d00300:	d1fa      	bne.n	c0d002f8 <adjustDecimals+0xa4>
c0d00302:	180a      	adds	r2, r1, r0
c0d00304:	e000      	b.n	c0d00308 <adjustDecimals+0xb4>
c0d00306:	460a      	mov	r2, r1
c0d00308:	2500      	movs	r5, #0
c0d0030a:	54a5      	strb	r5, [r4, r2]
c0d0030c:	2001      	movs	r0, #1
    for (uint32_t i = startOffset; i < offset; i++) {
c0d0030e:	4291      	cmp	r1, r2
c0d00310:	d214      	bcs.n	c0d0033c <adjustDecimals+0xe8>
        if (target[i] == '0') {
c0d00312:	5c66      	ldrb	r6, [r4, r1]
c0d00314:	2d00      	cmp	r5, #0
c0d00316:	460b      	mov	r3, r1
c0d00318:	d000      	beq.n	c0d0031c <adjustDecimals+0xc8>
c0d0031a:	462b      	mov	r3, r5
c0d0031c:	2e30      	cmp	r6, #48	; 0x30
c0d0031e:	d000      	beq.n	c0d00322 <adjustDecimals+0xce>
c0d00320:	2300      	movs	r3, #0
    for (uint32_t i = startOffset; i < offset; i++) {
c0d00322:	1c49      	adds	r1, r1, #1
c0d00324:	428a      	cmp	r2, r1
c0d00326:	461d      	mov	r5, r3
c0d00328:	d1f3      	bne.n	c0d00312 <adjustDecimals+0xbe>
    if (lastZeroOffset != 0) {
c0d0032a:	2b00      	cmp	r3, #0
c0d0032c:	d006      	beq.n	c0d0033c <adjustDecimals+0xe8>
c0d0032e:	2100      	movs	r1, #0
        target[lastZeroOffset] = '\0';
c0d00330:	54e1      	strb	r1, [r4, r3]
        if (target[lastZeroOffset - 1] == '.') {
c0d00332:	1e5a      	subs	r2, r3, #1
c0d00334:	5ca3      	ldrb	r3, [r4, r2]
c0d00336:	2b2e      	cmp	r3, #46	; 0x2e
c0d00338:	d100      	bne.n	c0d0033c <adjustDecimals+0xe8>
            target[lastZeroOffset - 1] = '\0';
c0d0033a:	54a1      	strb	r1, [r4, r2]
}
c0d0033c:	b001      	add	sp, #4
c0d0033e:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d00340 <uint256_to_decimal>:
bool uint256_to_decimal(const uint8_t *value, size_t value_len, char *out, size_t out_len) {
c0d00340:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00342:	b08b      	sub	sp, #44	; 0x2c
    if (value_len > INT256_LENGTH) {
c0d00344:	2920      	cmp	r1, #32
c0d00346:	d901      	bls.n	c0d0034c <uint256_to_decimal+0xc>
c0d00348:	2000      	movs	r0, #0
c0d0034a:	e057      	b.n	c0d003fc <uint256_to_decimal+0xbc>
c0d0034c:	4614      	mov	r4, r2
c0d0034e:	460e      	mov	r6, r1
c0d00350:	4607      	mov	r7, r0
c0d00352:	ad03      	add	r5, sp, #12
c0d00354:	2120      	movs	r1, #32
    uint16_t n[16] = {0};
c0d00356:	4628      	mov	r0, r5
c0d00358:	9302      	str	r3, [sp, #8]
c0d0035a:	f000 ff41 	bl	c0d011e0 <__aeabi_memclr>
    memcpy((uint8_t *) n + INT256_LENGTH - value_len, value, value_len);
c0d0035e:	1ba8      	subs	r0, r5, r6
c0d00360:	3020      	adds	r0, #32
c0d00362:	4639      	mov	r1, r7
c0d00364:	4632      	mov	r2, r6
c0d00366:	f000 ff40 	bl	c0d011ea <__aeabi_memcpy>
c0d0036a:	9a02      	ldr	r2, [sp, #8]
c0d0036c:	2000      	movs	r0, #0
c0d0036e:	a903      	add	r1, sp, #12
} extraInfo_t;

static __attribute__((no_instrument_function)) inline int allzeroes(void *buf, size_t n) {
    uint8_t *p = (uint8_t *) buf;
    for (size_t i = 0; i < n; ++i) {
        if (p[i]) {
c0d00370:	5c09      	ldrb	r1, [r1, r0]
c0d00372:	2900      	cmp	r1, #0
c0d00374:	d10a      	bne.n	c0d0038c <uint256_to_decimal+0x4c>
    for (size_t i = 0; i < n; ++i) {
c0d00376:	1c40      	adds	r0, r0, #1
c0d00378:	2820      	cmp	r0, #32
c0d0037a:	d1f8      	bne.n	c0d0036e <uint256_to_decimal+0x2e>
        if (out_len < 2) {
c0d0037c:	2a02      	cmp	r2, #2
c0d0037e:	d3e3      	bcc.n	c0d00348 <uint256_to_decimal+0x8>
        strlcpy(out, "0", out_len);
c0d00380:	491f      	ldr	r1, [pc, #124]	; (c0d00400 <uint256_to_decimal+0xc0>)
c0d00382:	4479      	add	r1, pc
c0d00384:	4620      	mov	r0, r4
c0d00386:	f000 ffad 	bl	c0d012e4 <strlcpy>
c0d0038a:	e036      	b.n	c0d003fa <uint256_to_decimal+0xba>
c0d0038c:	2000      	movs	r0, #0
c0d0038e:	a903      	add	r1, sp, #12
        n[i] = __builtin_bswap16(*p++);
c0d00390:	5a0b      	ldrh	r3, [r1, r0]
c0d00392:	ba5b      	rev16	r3, r3
c0d00394:	520b      	strh	r3, [r1, r0]
    for (int i = 0; i < 16; i++) {
c0d00396:	1c80      	adds	r0, r0, #2
c0d00398:	2820      	cmp	r0, #32
c0d0039a:	d1f8      	bne.n	c0d0038e <uint256_to_decimal+0x4e>
c0d0039c:	4613      	mov	r3, r2
c0d0039e:	2000      	movs	r0, #0
c0d003a0:	a903      	add	r1, sp, #12
        if (p[i]) {
c0d003a2:	5c09      	ldrb	r1, [r1, r0]
c0d003a4:	2900      	cmp	r1, #0
c0d003a6:	d103      	bne.n	c0d003b0 <uint256_to_decimal+0x70>
    for (size_t i = 0; i < n; ++i) {
c0d003a8:	1c40      	adds	r0, r0, #1
c0d003aa:	2820      	cmp	r0, #32
c0d003ac:	d1f8      	bne.n	c0d003a0 <uint256_to_decimal+0x60>
c0d003ae:	e01c      	b.n	c0d003ea <uint256_to_decimal+0xaa>
        if (pos == 0) {
c0d003b0:	2b00      	cmp	r3, #0
c0d003b2:	d0c9      	beq.n	c0d00348 <uint256_to_decimal+0x8>
c0d003b4:	9300      	str	r3, [sp, #0]
c0d003b6:	9401      	str	r4, [sp, #4]
c0d003b8:	2400      	movs	r4, #0
c0d003ba:	4620      	mov	r0, r4
c0d003bc:	af03      	add	r7, sp, #12
            int rem = ((carry << 16) | n[i]) % 10;
c0d003be:	5b39      	ldrh	r1, [r7, r4]
c0d003c0:	0400      	lsls	r0, r0, #16
c0d003c2:	1845      	adds	r5, r0, r1
c0d003c4:	260a      	movs	r6, #10
            n[i] = ((carry << 16) | n[i]) / 10;
c0d003c6:	4628      	mov	r0, r5
c0d003c8:	4631      	mov	r1, r6
c0d003ca:	f000 fd39 	bl	c0d00e40 <__udivsi3>
c0d003ce:	5338      	strh	r0, [r7, r4]
c0d003d0:	4346      	muls	r6, r0
c0d003d2:	1ba8      	subs	r0, r5, r6
        for (int i = 0; i < 16; i++) {
c0d003d4:	1ca4      	adds	r4, r4, #2
c0d003d6:	2c20      	cmp	r4, #32
c0d003d8:	d1f0      	bne.n	c0d003bc <uint256_to_decimal+0x7c>
c0d003da:	2130      	movs	r1, #48	; 0x30
        out[pos] = '0' + carry;
c0d003dc:	4308      	orrs	r0, r1
c0d003de:	9b00      	ldr	r3, [sp, #0]
        pos -= 1;
c0d003e0:	1e5b      	subs	r3, r3, #1
c0d003e2:	9c01      	ldr	r4, [sp, #4]
        out[pos] = '0' + carry;
c0d003e4:	54e0      	strb	r0, [r4, r3]
c0d003e6:	9a02      	ldr	r2, [sp, #8]
c0d003e8:	e7d9      	b.n	c0d0039e <uint256_to_decimal+0x5e>
    memmove(out, out + pos, out_len - pos);
c0d003ea:	18e1      	adds	r1, r4, r3
c0d003ec:	1ad5      	subs	r5, r2, r3
c0d003ee:	4620      	mov	r0, r4
c0d003f0:	462a      	mov	r2, r5
c0d003f2:	f000 fefe 	bl	c0d011f2 <__aeabi_memmove>
c0d003f6:	2000      	movs	r0, #0
    out[out_len - pos] = 0;
c0d003f8:	5560      	strb	r0, [r4, r5]
c0d003fa:	2001      	movs	r0, #1
}
c0d003fc:	b00b      	add	sp, #44	; 0x2c
c0d003fe:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00400:	00000fe8 	.word	0x00000fe8

c0d00404 <amountToString>:
                    size_t out_buffer_size) {
c0d00404:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00406:	b09d      	sub	sp, #116	; 0x74
c0d00408:	9303      	str	r3, [sp, #12]
c0d0040a:	9202      	str	r2, [sp, #8]
c0d0040c:	460c      	mov	r4, r1
c0d0040e:	4606      	mov	r6, r0
c0d00410:	af04      	add	r7, sp, #16
c0d00412:	2564      	movs	r5, #100	; 0x64
    char tmp_buffer[100] = {0};
c0d00414:	4638      	mov	r0, r7
c0d00416:	4629      	mov	r1, r5
c0d00418:	f000 fee2 	bl	c0d011e0 <__aeabi_memclr>
    if (uint256_to_decimal(amount, amount_size, tmp_buffer, sizeof(tmp_buffer)) == false) {
c0d0041c:	4630      	mov	r0, r6
c0d0041e:	4621      	mov	r1, r4
c0d00420:	463a      	mov	r2, r7
c0d00422:	462b      	mov	r3, r5
c0d00424:	f7ff ff8c 	bl	c0d00340 <uint256_to_decimal>
c0d00428:	2800      	cmp	r0, #0
c0d0042a:	d026      	beq.n	c0d0047a <amountToString+0x76>
c0d0042c:	9d23      	ldr	r5, [sp, #140]	; 0x8c
c0d0042e:	9e22      	ldr	r6, [sp, #136]	; 0x88
c0d00430:	af04      	add	r7, sp, #16
c0d00432:	2164      	movs	r1, #100	; 0x64
    uint8_t amount_len = strnlen(tmp_buffer, sizeof(tmp_buffer));
c0d00434:	4638      	mov	r0, r7
c0d00436:	f000 ff82 	bl	c0d0133e <strnlen>
c0d0043a:	9001      	str	r0, [sp, #4]
c0d0043c:	210c      	movs	r1, #12
    uint8_t ticker_len = strnlen(ticker, MAX_TICKER_LEN);
c0d0043e:	9803      	ldr	r0, [sp, #12]
c0d00440:	f000 ff7d 	bl	c0d0133e <strnlen>
    memcpy(out_buffer, ticker, MIN(out_buffer_size, ticker_len));
c0d00444:	b2c4      	uxtb	r4, r0
c0d00446:	42ac      	cmp	r4, r5
c0d00448:	462a      	mov	r2, r5
c0d0044a:	d800      	bhi.n	c0d0044e <amountToString+0x4a>
c0d0044c:	4622      	mov	r2, r4
c0d0044e:	4630      	mov	r0, r6
c0d00450:	9903      	ldr	r1, [sp, #12]
c0d00452:	f000 feca 	bl	c0d011ea <__aeabi_memcpy>
    if (adjustDecimals(tmp_buffer,
c0d00456:	9802      	ldr	r0, [sp, #8]
c0d00458:	9000      	str	r0, [sp, #0]
                       out_buffer + ticker_len,
c0d0045a:	1932      	adds	r2, r6, r4
                       out_buffer_size - ticker_len - 1,
c0d0045c:	43e0      	mvns	r0, r4
c0d0045e:	1943      	adds	r3, r0, r5
                       amount_len,
c0d00460:	9801      	ldr	r0, [sp, #4]
c0d00462:	b2c1      	uxtb	r1, r0
    if (adjustDecimals(tmp_buffer,
c0d00464:	4638      	mov	r0, r7
c0d00466:	f7ff fef5 	bl	c0d00254 <adjustDecimals>
c0d0046a:	2800      	cmp	r0, #0
c0d0046c:	d005      	beq.n	c0d0047a <amountToString+0x76>
    out_buffer[out_buffer_size - 1] = '\0';
c0d0046e:	19a8      	adds	r0, r5, r6
c0d00470:	1e40      	subs	r0, r0, #1
c0d00472:	2100      	movs	r1, #0
c0d00474:	7001      	strb	r1, [r0, #0]
}
c0d00476:	b01d      	add	sp, #116	; 0x74
c0d00478:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0047a:	2007      	movs	r0, #7
c0d0047c:	f000 faab 	bl	c0d009d6 <os_longjmp>

c0d00480 <handle_finalize>:
#include "nested_plugin.h"

void handle_finalize(void *parameters)
{
c0d00480:	b5b0      	push	{r4, r5, r7, lr}
c0d00482:	4604      	mov	r4, r0
c0d00484:	4809      	ldr	r0, [pc, #36]	; (c0d004ac <handle_finalize+0x2c>)
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;

    msg->uiType = ETH_UI_TYPE_GENERIC;
c0d00486:	83a0      	strh	r0, [r4, #28]

    // EDIT THIS: Set the total number of screen you will need.
    msg->numScreens = 2;
    // EDIT THIS: Handle this case like you wish to (i.e. maybe no additional screen needed?).
    // If the beneficiary is NOT the sender, we will need an additional screen to display it.
    if (memcmp(msg->address, context->beneficiary, ADDRESS_LENGTH) != 0)
c0d00488:	69a0      	ldr	r0, [r4, #24]
    context_t *context = (context_t *)msg->pluginContext;
c0d0048a:	68a5      	ldr	r5, [r4, #8]
    if (memcmp(msg->address, context->beneficiary, ADDRESS_LENGTH) != 0)
c0d0048c:	4629      	mov	r1, r5
c0d0048e:	3121      	adds	r1, #33	; 0x21
c0d00490:	2214      	movs	r2, #20
c0d00492:	f000 feb9 	bl	c0d01208 <memcmp>
c0d00496:	2104      	movs	r1, #4

    // EDIT THIS: set `tokenLookup1` (and maybe `tokenLookup2`) to point to
    // token addresses you will info for (such as decimals, ticker...).
    msg->tokenLookup1 = context->token_received;

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d00498:	77a1      	strb	r1, [r4, #30]
    msg->tokenLookup1 = context->token_received;
c0d0049a:	3535      	adds	r5, #53	; 0x35
c0d0049c:	60e5      	str	r5, [r4, #12]
    if (memcmp(msg->address, context->beneficiary, ADDRESS_LENGTH) != 0)
c0d0049e:	2800      	cmp	r0, #0
c0d004a0:	d001      	beq.n	c0d004a6 <handle_finalize+0x26>
c0d004a2:	2003      	movs	r0, #3
c0d004a4:	e000      	b.n	c0d004a8 <handle_finalize+0x28>
c0d004a6:	2002      	movs	r0, #2
c0d004a8:	7760      	strb	r0, [r4, #29]
}
c0d004aa:	bdb0      	pop	{r4, r5, r7, pc}
c0d004ac:	00000202 	.word	0x00000202

c0d004b0 <handle_init_contract>:
    return -1;
}

// Called once to init.
void handle_init_contract(void *parameters)
{
c0d004b0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d004b2:	b081      	sub	sp, #4
c0d004b4:	4604      	mov	r4, r0
    // Cast the msg to the type of structure we expect (here, ethPluginInitContract_t).
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *)parameters;

    // Make sure we are running a compatible version.
    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST)
c0d004b6:	7800      	ldrb	r0, [r0, #0]
c0d004b8:	2601      	movs	r6, #1
c0d004ba:	2804      	cmp	r0, #4
c0d004bc:	d129      	bne.n	c0d00512 <handle_init_contract+0x62>
        return;
    }

    // Double check that the `context_t` struct is not bigger than the maximum size (defined by
    // `msg->pluginContextLength`).
    if (msg->pluginContextLength < sizeof(context_t))
c0d004be:	6920      	ldr	r0, [r4, #16]
c0d004c0:	2873      	cmp	r0, #115	; 0x73
c0d004c2:	d805      	bhi.n	c0d004d0 <handle_init_contract+0x20>
    {
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
c0d004c4:	4814      	ldr	r0, [pc, #80]	; (c0d00518 <handle_init_contract+0x68>)
c0d004c6:	4478      	add	r0, pc
c0d004c8:	f000 fa8c 	bl	c0d009e4 <semihosted_printf>
c0d004cc:	2600      	movs	r6, #0
c0d004ce:	e020      	b.n	c0d00512 <handle_init_contract+0x62>
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    context_t *context = (context_t *)msg->pluginContext;
c0d004d0:	68e5      	ldr	r5, [r4, #12]
c0d004d2:	2174      	movs	r1, #116	; 0x74

    // Initialize the context (to 0).
    memset(context, 0, sizeof(*context));
c0d004d4:	4628      	mov	r0, r5
c0d004d6:	f000 fe83 	bl	c0d011e0 <__aeabi_memclr>
c0d004da:	2704      	movs	r7, #4
    context->current_tuple_offset = SELECTOR_SIZE;
c0d004dc:	662f      	str	r7, [r5, #96]	; 0x60

    uint32_t selector = U4BE(msg->selector, 0);
c0d004de:	6960      	ldr	r0, [r4, #20]
   ((lo0)&0xFFu))
static inline uint16_t U2BE(const uint8_t *buf, size_t off) {
  return (buf[off] << 8) | buf[off + 1];
}
static inline uint32_t U4BE(const uint8_t *buf, size_t off) {
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d004e0:	7801      	ldrb	r1, [r0, #0]
c0d004e2:	0609      	lsls	r1, r1, #24
c0d004e4:	7842      	ldrb	r2, [r0, #1]
c0d004e6:	0412      	lsls	r2, r2, #16
c0d004e8:	1851      	adds	r1, r2, r1
         (buf[off + 2] << 8) | buf[off + 3];
c0d004ea:	7882      	ldrb	r2, [r0, #2]
c0d004ec:	0212      	lsls	r2, r2, #8
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d004ee:	1889      	adds	r1, r1, r2
         (buf[off + 2] << 8) | buf[off + 3];
c0d004f0:	78c0      	ldrb	r0, [r0, #3]
c0d004f2:	1808      	adds	r0, r1, r0
c0d004f4:	4909      	ldr	r1, [pc, #36]	; (c0d0051c <handle_init_contract+0x6c>)
c0d004f6:	4479      	add	r1, pc
c0d004f8:	6809      	ldr	r1, [r1, #0]
        if (selector == selectors[i])
c0d004fa:	4281      	cmp	r1, r0
c0d004fc:	d109      	bne.n	c0d00512 <handle_init_contract+0x62>
c0d004fe:	3557      	adds	r5, #87	; 0x57
c0d00500:	2000      	movs	r0, #0
            *out = i;
c0d00502:	7728      	strb	r0, [r5, #28]
    // EDIT THIS: Adapt the `cases`, and set the `next_param` to be the first parameter you expect
    // to parse.
    switch (context->selectorIndex)
    {
    case CREATE:
        PRINTF("PENZO IN CREATE\n");
c0d00504:	4806      	ldr	r0, [pc, #24]	; (c0d00520 <handle_init_contract+0x70>)
c0d00506:	4478      	add	r0, pc
c0d00508:	f000 fa6c 	bl	c0d009e4 <semihosted_printf>
c0d0050c:	2001      	movs	r0, #1
        context->next_param = CREATE__TOKEN_ID;
c0d0050e:	7028      	strb	r0, [r5, #0]
c0d00510:	463e      	mov	r6, r7
c0d00512:	7066      	strb	r6, [r4, #1]
        return;
    }

    // Return valid status.
    msg->result = ETH_PLUGIN_RESULT_OK;
}
c0d00514:	b001      	add	sp, #4
c0d00516:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00518:	00000ea6 	.word	0x00000ea6
c0d0051c:	000012d2 	.word	0x000012d2
c0d00520:	00000e9f 	.word	0x00000e9f

c0d00524 <copy_offset>:
    }
    PRINTF("\n");
}

void copy_offset(ethPluginProvideParameter_t *msg, context_t *context)
{
c0d00524:	b5b0      	push	{r4, r5, r7, lr}
c0d00526:	460c      	mov	r4, r1
c0d00528:	4605      	mov	r5, r0
    PRINTF("msg->parameterOffset: %d\n", msg->parameterOffset);
c0d0052a:	6901      	ldr	r1, [r0, #16]
c0d0052c:	480d      	ldr	r0, [pc, #52]	; (c0d00564 <copy_offset+0x40>)
c0d0052e:	4478      	add	r0, pc
c0d00530:	f000 fa58 	bl	c0d009e4 <semihosted_printf>
    uint32_t test = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d00534:	68e8      	ldr	r0, [r5, #12]
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d00536:	7f01      	ldrb	r1, [r0, #28]
c0d00538:	0609      	lsls	r1, r1, #24
c0d0053a:	7f42      	ldrb	r2, [r0, #29]
c0d0053c:	0412      	lsls	r2, r2, #16
c0d0053e:	1851      	adds	r1, r2, r1
         (buf[off + 2] << 8) | buf[off + 3];
c0d00540:	7f82      	ldrb	r2, [r0, #30]
c0d00542:	0212      	lsls	r2, r2, #8
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d00544:	1889      	adds	r1, r1, r2
         (buf[off + 2] << 8) | buf[off + 3];
c0d00546:	7fc0      	ldrb	r0, [r0, #31]
c0d00548:	180d      	adds	r5, r1, r0
    PRINTF("U4BE msg->parameter: %d\n", test);
c0d0054a:	4807      	ldr	r0, [pc, #28]	; (c0d00568 <copy_offset+0x44>)
c0d0054c:	4478      	add	r0, pc
c0d0054e:	4629      	mov	r1, r5
c0d00550:	f000 fa48 	bl	c0d009e4 <semihosted_printf>
    context->next_offset = test + context->current_tuple_offset;
c0d00554:	6e20      	ldr	r0, [r4, #96]	; 0x60
c0d00556:	1829      	adds	r1, r5, r0
c0d00558:	6661      	str	r1, [r4, #100]	; 0x64
    PRINTF("copied offset: %d\n", context->next_offset);
c0d0055a:	4804      	ldr	r0, [pc, #16]	; (c0d0056c <copy_offset+0x48>)
c0d0055c:	4478      	add	r0, pc
c0d0055e:	f000 fa41 	bl	c0d009e4 <semihosted_printf>
}
c0d00562:	bdb0      	pop	{r4, r5, r7, pc}
c0d00564:	00000e8b 	.word	0x00000e8b
c0d00568:	00000e87 	.word	0x00000e87
c0d0056c:	00000e90 	.word	0x00000e90

c0d00570 <handle_provide_parameter>:
    }
    context->next_param++;
}

void handle_provide_parameter(void *parameters)
{
c0d00570:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00572:	b081      	sub	sp, #4
c0d00574:	4605      	mov	r5, r0
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;
c0d00576:	6884      	ldr	r4, [r0, #8]
    // the number of bytes you wish to print (in this case, `PARAMETER_LENGTH`) and then
    // the address (here `msg->parameter`).
    PRINTF("plugin provide parameter: offset %d\nBytes: \033[0;31m %.*H \033[0m \n",
           msg->parameterOffset,
           PARAMETER_LENGTH,
           msg->parameter);
c0d00578:	68c3      	ldr	r3, [r0, #12]
           msg->parameterOffset,
c0d0057a:	6901      	ldr	r1, [r0, #16]
    PRINTF("plugin provide parameter: offset %d\nBytes: \033[0;31m %.*H \033[0m \n",
c0d0057c:	487c      	ldr	r0, [pc, #496]	; (c0d00770 <handle_provide_parameter+0x200>)
c0d0057e:	4478      	add	r0, pc
c0d00580:	2220      	movs	r2, #32
c0d00582:	f000 fa2f 	bl	c0d009e4 <semihosted_printf>
c0d00586:	2004      	movs	r0, #4

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d00588:	7528      	strb	r0, [r5, #20]
c0d0058a:	2073      	movs	r0, #115	; 0x73

    // EDIT THIS: adapt the cases and the names of the functions.
    switch (context->selectorIndex)
c0d0058c:	5c21      	ldrb	r1, [r4, r0]
c0d0058e:	2900      	cmp	r1, #0
c0d00590:	d006      	beq.n	c0d005a0 <handle_provide_parameter+0x30>
    {
    case CREATE:
        handle_create(msg, context);
        break;
    default:
        PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
c0d00592:	4891      	ldr	r0, [pc, #580]	; (c0d007d8 <handle_provide_parameter+0x268>)
c0d00594:	4478      	add	r0, pc
c0d00596:	f000 fa25 	bl	c0d009e4 <semihosted_printf>
c0d0059a:	2000      	movs	r0, #0
        msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d0059c:	7528      	strb	r0, [r5, #20]
c0d0059e:	e0e5      	b.n	c0d0076c <handle_provide_parameter+0x1fc>
c0d005a0:	4626      	mov	r6, r4
c0d005a2:	3657      	adds	r6, #87	; 0x57
c0d005a4:	4627      	mov	r7, r4
c0d005a6:	3768      	adds	r7, #104	; 0x68
    if (context->on_struct)
c0d005a8:	7820      	ldrb	r0, [r4, #0]
c0d005aa:	2800      	cmp	r0, #0
c0d005ac:	d018      	beq.n	c0d005e0 <handle_provide_parameter+0x70>
c0d005ae:	2803      	cmp	r0, #3
c0d005b0:	d029      	beq.n	c0d00606 <handle_provide_parameter+0x96>
c0d005b2:	2801      	cmp	r0, #1
c0d005b4:	d000      	beq.n	c0d005b8 <handle_provide_parameter+0x48>
c0d005b6:	e0d9      	b.n	c0d0076c <handle_provide_parameter+0x1fc>
    PRINTF("PARSING BIO step; %d\n", context->next_param);
c0d005b8:	7831      	ldrb	r1, [r6, #0]
c0d005ba:	486e      	ldr	r0, [pc, #440]	; (c0d00774 <handle_provide_parameter+0x204>)
c0d005bc:	4478      	add	r0, pc
c0d005be:	f000 fa11 	bl	c0d009e4 <semihosted_printf>
    switch ((batch_input_orders)context->next_param)
c0d005c2:	7830      	ldrb	r0, [r6, #0]
c0d005c4:	2802      	cmp	r0, #2
c0d005c6:	dc2f      	bgt.n	c0d00628 <handle_provide_parameter+0xb8>
c0d005c8:	2800      	cmp	r0, #0
c0d005ca:	d100      	bne.n	c0d005ce <handle_provide_parameter+0x5e>
c0d005cc:	e0ab      	b.n	c0d00726 <handle_provide_parameter+0x1b6>
c0d005ce:	2801      	cmp	r0, #1
c0d005d0:	d100      	bne.n	c0d005d4 <handle_provide_parameter+0x64>
c0d005d2:	e0af      	b.n	c0d00734 <handle_provide_parameter+0x1c4>
c0d005d4:	2802      	cmp	r0, #2
c0d005d6:	d000      	beq.n	c0d005da <handle_provide_parameter+0x6a>
c0d005d8:	e0c5      	b.n	c0d00766 <handle_provide_parameter+0x1f6>
        PRINTF("parse BIO__OFFSET_ORDERS\n");
c0d005da:	4867      	ldr	r0, [pc, #412]	; (c0d00778 <handle_provide_parameter+0x208>)
c0d005dc:	4478      	add	r0, pc
c0d005de:	e085      	b.n	c0d006ec <handle_provide_parameter+0x17c>
    PRINTF("PARSING CREATE\n");
c0d005e0:	4875      	ldr	r0, [pc, #468]	; (c0d007b8 <handle_provide_parameter+0x248>)
c0d005e2:	4478      	add	r0, pc
c0d005e4:	f000 f9fe 	bl	c0d009e4 <semihosted_printf>
    switch ((create_parameter)context->next_param)
c0d005e8:	7831      	ldrb	r1, [r6, #0]
c0d005ea:	2902      	cmp	r1, #2
c0d005ec:	dd4a      	ble.n	c0d00684 <handle_provide_parameter+0x114>
c0d005ee:	2903      	cmp	r1, #3
c0d005f0:	d056      	beq.n	c0d006a0 <handle_provide_parameter+0x130>
c0d005f2:	2904      	cmp	r1, #4
c0d005f4:	d057      	beq.n	c0d006a6 <handle_provide_parameter+0x136>
c0d005f6:	2905      	cmp	r1, #5
c0d005f8:	d000      	beq.n	c0d005fc <handle_provide_parameter+0x8c>
c0d005fa:	e084      	b.n	c0d00706 <handle_provide_parameter+0x196>
        PRINTF("NOP NOP CREATE__BATCH_INPUT_ORDERS\n");
c0d005fc:	4870      	ldr	r0, [pc, #448]	; (c0d007c0 <handle_provide_parameter+0x250>)
c0d005fe:	4478      	add	r0, pc
c0d00600:	f000 f9f0 	bl	c0d009e4 <semihosted_printf>
c0d00604:	e0b2      	b.n	c0d0076c <handle_provide_parameter+0x1fc>
    PRINTF("PARSING ORDER\n");
c0d00606:	4865      	ldr	r0, [pc, #404]	; (c0d0079c <handle_provide_parameter+0x22c>)
c0d00608:	4478      	add	r0, pc
c0d0060a:	f000 f9eb 	bl	c0d009e4 <semihosted_printf>
    switch ((order)context->next_param)
c0d0060e:	7830      	ldrb	r0, [r6, #0]
c0d00610:	2801      	cmp	r0, #1
c0d00612:	dd3e      	ble.n	c0d00692 <handle_provide_parameter+0x122>
c0d00614:	2802      	cmp	r0, #2
c0d00616:	d067      	beq.n	c0d006e8 <handle_provide_parameter+0x178>
c0d00618:	2803      	cmp	r0, #3
c0d0061a:	d06e      	beq.n	c0d006fa <handle_provide_parameter+0x18a>
c0d0061c:	2804      	cmp	r0, #4
c0d0061e:	d000      	beq.n	c0d00622 <handle_provide_parameter+0xb2>
c0d00620:	e0a1      	b.n	c0d00766 <handle_provide_parameter+0x1f6>
        PRINTF("parse ORDER__CALLDATA\n");
c0d00622:	4860      	ldr	r0, [pc, #384]	; (c0d007a4 <handle_provide_parameter+0x234>)
c0d00624:	4478      	add	r0, pc
c0d00626:	e08a      	b.n	c0d0073e <handle_provide_parameter+0x1ce>
    switch ((batch_input_orders)context->next_param)
c0d00628:	2803      	cmp	r0, #3
c0d0062a:	d100      	bne.n	c0d0062e <handle_provide_parameter+0xbe>
c0d0062c:	e085      	b.n	c0d0073a <handle_provide_parameter+0x1ca>
c0d0062e:	2804      	cmp	r0, #4
c0d00630:	d100      	bne.n	c0d00634 <handle_provide_parameter+0xc4>
c0d00632:	e087      	b.n	c0d00744 <handle_provide_parameter+0x1d4>
c0d00634:	2805      	cmp	r0, #5
c0d00636:	d000      	beq.n	c0d0063a <handle_provide_parameter+0xca>
c0d00638:	e095      	b.n	c0d00766 <handle_provide_parameter+0x1f6>
        context->length_offset_array--;
c0d0063a:	7ab8      	ldrb	r0, [r7, #10]
c0d0063c:	1e40      	subs	r0, r0, #1
c0d0063e:	72b8      	strb	r0, [r7, #10]
        PRINTF("parse BIO__OFFSET_ARRAY_ORDERS, index: %d\n", context->length_offset_array);
c0d00640:	b2c1      	uxtb	r1, r0
c0d00642:	484e      	ldr	r0, [pc, #312]	; (c0d0077c <handle_provide_parameter+0x20c>)
c0d00644:	4478      	add	r0, pc
c0d00646:	f000 f9cd 	bl	c0d009e4 <semihosted_printf>
        if (context->length_offset_array < 2)
c0d0064a:	7ab9      	ldrb	r1, [r7, #10]
c0d0064c:	2901      	cmp	r1, #1
c0d0064e:	d900      	bls.n	c0d00652 <handle_provide_parameter+0xe2>
c0d00650:	e08c      	b.n	c0d0076c <handle_provide_parameter+0x1fc>
            context->offsets_lvl1[context->length_offset_array] =
c0d00652:	0048      	lsls	r0, r1, #1
c0d00654:	1820      	adds	r0, r4, r0
                U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d00656:	68ea      	ldr	r2, [r5, #12]
c0d00658:	7fd3      	ldrb	r3, [r2, #31]
c0d0065a:	7f92      	ldrb	r2, [r2, #30]
c0d0065c:	0212      	lsls	r2, r2, #8
c0d0065e:	18d2      	adds	r2, r2, r3
c0d00660:	236e      	movs	r3, #110	; 0x6e
            context->offsets_lvl1[context->length_offset_array] =
c0d00662:	52c2      	strh	r2, [r0, r3]
                   context->offsets_lvl1[context->length_offset_array]);
c0d00664:	b292      	uxth	r2, r2
            PRINTF("offsets_lvl1[%d]: %d\n",
c0d00666:	4846      	ldr	r0, [pc, #280]	; (c0d00780 <handle_provide_parameter+0x210>)
c0d00668:	4478      	add	r0, pc
c0d0066a:	f000 f9bb 	bl	c0d009e4 <semihosted_printf>
        if (context->length_offset_array == 0)
c0d0066e:	7ab8      	ldrb	r0, [r7, #10]
c0d00670:	2800      	cmp	r0, #0
c0d00672:	d17b      	bne.n	c0d0076c <handle_provide_parameter+0x1fc>
            PRINTF("parse BIO__OFFSET_ARRAY_ORDERS LAST\n");
c0d00674:	4843      	ldr	r0, [pc, #268]	; (c0d00784 <handle_provide_parameter+0x214>)
c0d00676:	4478      	add	r0, pc
c0d00678:	f000 f9b4 	bl	c0d009e4 <semihosted_printf>
c0d0067c:	2000      	movs	r0, #0
            context->next_param = (batch_input_orders)ORDER__OPERATOR;
c0d0067e:	7030      	strb	r0, [r6, #0]
c0d00680:	2003      	movs	r0, #3
c0d00682:	e02f      	b.n	c0d006e4 <handle_provide_parameter+0x174>
    switch ((create_parameter)context->next_param)
c0d00684:	2901      	cmp	r1, #1
c0d00686:	d03b      	beq.n	c0d00700 <handle_provide_parameter+0x190>
c0d00688:	2902      	cmp	r1, #2
c0d0068a:	d13c      	bne.n	c0d00706 <handle_provide_parameter+0x196>
        PRINTF("CREATE__OFFSET_BATCHINPUTORDER\n");
c0d0068c:	484b      	ldr	r0, [pc, #300]	; (c0d007bc <handle_provide_parameter+0x24c>)
c0d0068e:	4478      	add	r0, pc
c0d00690:	e02c      	b.n	c0d006ec <handle_provide_parameter+0x17c>
    switch ((order)context->next_param)
c0d00692:	2800      	cmp	r0, #0
c0d00694:	d03e      	beq.n	c0d00714 <handle_provide_parameter+0x1a4>
c0d00696:	2801      	cmp	r0, #1
c0d00698:	d165      	bne.n	c0d00766 <handle_provide_parameter+0x1f6>
        PRINTF("parse ORDER__TOKEN_ADDRESS\n");
c0d0069a:	4841      	ldr	r0, [pc, #260]	; (c0d007a0 <handle_provide_parameter+0x230>)
c0d0069c:	4478      	add	r0, pc
c0d0069e:	e04e      	b.n	c0d0073e <handle_provide_parameter+0x1ce>
        PRINTF("CREATE__LEN_BATCHINPUTORDER\n");
c0d006a0:	4849      	ldr	r0, [pc, #292]	; (c0d007c8 <handle_provide_parameter+0x258>)
c0d006a2:	4478      	add	r0, pc
c0d006a4:	e050      	b.n	c0d00748 <handle_provide_parameter+0x1d8>
        context->length_offset_array--;
c0d006a6:	7ab8      	ldrb	r0, [r7, #10]
c0d006a8:	1e40      	subs	r0, r0, #1
c0d006aa:	72b8      	strb	r0, [r7, #10]
               context->length_offset_array);
c0d006ac:	b2c1      	uxtb	r1, r0
        PRINTF("CREATE__OFFSET_ARRAY_BATCHINPUTORDER, index: %d\n",
c0d006ae:	4847      	ldr	r0, [pc, #284]	; (c0d007cc <handle_provide_parameter+0x25c>)
c0d006b0:	4478      	add	r0, pc
c0d006b2:	f000 f997 	bl	c0d009e4 <semihosted_printf>
        if (context->length_offset_array < 2)
c0d006b6:	7ab9      	ldrb	r1, [r7, #10]
c0d006b8:	2901      	cmp	r1, #1
c0d006ba:	d857      	bhi.n	c0d0076c <handle_provide_parameter+0x1fc>
            context->offsets_lvl0[context->length_offset_array] =
c0d006bc:	0048      	lsls	r0, r1, #1
c0d006be:	1820      	adds	r0, r4, r0
                U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d006c0:	68ea      	ldr	r2, [r5, #12]
c0d006c2:	7fd3      	ldrb	r3, [r2, #31]
c0d006c4:	7f92      	ldrb	r2, [r2, #30]
c0d006c6:	0212      	lsls	r2, r2, #8
c0d006c8:	18d2      	adds	r2, r2, r3
c0d006ca:	236a      	movs	r3, #106	; 0x6a
            context->offsets_lvl0[context->length_offset_array] =
c0d006cc:	52c2      	strh	r2, [r0, r3]
                   context->offsets_lvl0[context->length_offset_array]);
c0d006ce:	b292      	uxth	r2, r2
            PRINTF("offsets_lvl0[%d]: %d\n",
c0d006d0:	483f      	ldr	r0, [pc, #252]	; (c0d007d0 <handle_provide_parameter+0x260>)
c0d006d2:	4478      	add	r0, pc
c0d006d4:	f000 f986 	bl	c0d009e4 <semihosted_printf>
        if (context->length_offset_array == 0)
c0d006d8:	7ab8      	ldrb	r0, [r7, #10]
c0d006da:	2800      	cmp	r0, #0
c0d006dc:	d146      	bne.n	c0d0076c <handle_provide_parameter+0x1fc>
c0d006de:	2000      	movs	r0, #0
            context->next_param = (batch_input_orders)BIO__INPUTTOKEN;
c0d006e0:	7030      	strb	r0, [r6, #0]
c0d006e2:	2001      	movs	r0, #1
c0d006e4:	7020      	strb	r0, [r4, #0]
c0d006e6:	e041      	b.n	c0d0076c <handle_provide_parameter+0x1fc>
        PRINTF("parse ORDER__OFFSET_CALLDATA\n");
c0d006e8:	4831      	ldr	r0, [pc, #196]	; (c0d007b0 <handle_provide_parameter+0x240>)
c0d006ea:	4478      	add	r0, pc
c0d006ec:	f000 f97a 	bl	c0d009e4 <semihosted_printf>
c0d006f0:	4628      	mov	r0, r5
c0d006f2:	4621      	mov	r1, r4
c0d006f4:	f7ff ff16 	bl	c0d00524 <copy_offset>
c0d006f8:	e035      	b.n	c0d00766 <handle_provide_parameter+0x1f6>
        PRINTF("parse ORDER__LEN_CALLDATA\n");
c0d006fa:	482e      	ldr	r0, [pc, #184]	; (c0d007b4 <handle_provide_parameter+0x244>)
c0d006fc:	4478      	add	r0, pc
c0d006fe:	e01e      	b.n	c0d0073e <handle_provide_parameter+0x1ce>
        PRINTF("CREATE__TOKEN_ID\n");
c0d00700:	4830      	ldr	r0, [pc, #192]	; (c0d007c4 <handle_provide_parameter+0x254>)
c0d00702:	4478      	add	r0, pc
c0d00704:	e01b      	b.n	c0d0073e <handle_provide_parameter+0x1ce>
        PRINTF("Param not supported: %d\n", context->next_param);
c0d00706:	4833      	ldr	r0, [pc, #204]	; (c0d007d4 <handle_provide_parameter+0x264>)
c0d00708:	4478      	add	r0, pc
c0d0070a:	f000 f96b 	bl	c0d009e4 <semihosted_printf>
c0d0070e:	2000      	movs	r0, #0
        msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d00710:	7528      	strb	r0, [r5, #20]
c0d00712:	e028      	b.n	c0d00766 <handle_provide_parameter+0x1f6>
        PRINTF("parse ORDER__OPERATOR\n");
c0d00714:	4824      	ldr	r0, [pc, #144]	; (c0d007a8 <handle_provide_parameter+0x238>)
c0d00716:	4478      	add	r0, pc
c0d00718:	f000 f964 	bl	c0d009e4 <semihosted_printf>
        context->current_tuple_offset = msg->parameterOffset;
c0d0071c:	6929      	ldr	r1, [r5, #16]
c0d0071e:	6621      	str	r1, [r4, #96]	; 0x60
        PRINTF("NEW current_tuple_offset: %d\n", context->current_tuple_offset);
c0d00720:	4822      	ldr	r0, [pc, #136]	; (c0d007ac <handle_provide_parameter+0x23c>)
c0d00722:	4478      	add	r0, pc
c0d00724:	e01d      	b.n	c0d00762 <handle_provide_parameter+0x1f2>
        PRINTF("parse BIO__INPUTTOKEN\n");
c0d00726:	481c      	ldr	r0, [pc, #112]	; (c0d00798 <handle_provide_parameter+0x228>)
c0d00728:	4478      	add	r0, pc
c0d0072a:	f000 f95b 	bl	c0d009e4 <semihosted_printf>
        context->current_tuple_offset = msg->parameterOffset;
c0d0072e:	6928      	ldr	r0, [r5, #16]
c0d00730:	6620      	str	r0, [r4, #96]	; 0x60
c0d00732:	e018      	b.n	c0d00766 <handle_provide_parameter+0x1f6>
        PRINTF("parse BIO__AMOUNT\n");
c0d00734:	4814      	ldr	r0, [pc, #80]	; (c0d00788 <handle_provide_parameter+0x218>)
c0d00736:	4478      	add	r0, pc
c0d00738:	e001      	b.n	c0d0073e <handle_provide_parameter+0x1ce>
        PRINTF("parse BIO__FROM_RESERVE\n");
c0d0073a:	4814      	ldr	r0, [pc, #80]	; (c0d0078c <handle_provide_parameter+0x21c>)
c0d0073c:	4478      	add	r0, pc
c0d0073e:	f000 f951 	bl	c0d009e4 <semihosted_printf>
c0d00742:	e010      	b.n	c0d00766 <handle_provide_parameter+0x1f6>
        PRINTF("parse BIO__LEN_ORDERS\n");
c0d00744:	4812      	ldr	r0, [pc, #72]	; (c0d00790 <handle_provide_parameter+0x220>)
c0d00746:	4478      	add	r0, pc
c0d00748:	f000 f94c 	bl	c0d009e4 <semihosted_printf>
c0d0074c:	68e8      	ldr	r0, [r5, #12]
c0d0074e:	7fc1      	ldrb	r1, [r0, #31]
c0d00750:	7f82      	ldrb	r2, [r0, #30]
c0d00752:	0212      	lsls	r2, r2, #8
c0d00754:	1851      	adds	r1, r2, r1
c0d00756:	8039      	strh	r1, [r7, #0]
c0d00758:	7fc0      	ldrb	r0, [r0, #31]
c0d0075a:	72b8      	strb	r0, [r7, #10]
c0d0075c:	b289      	uxth	r1, r1
c0d0075e:	480d      	ldr	r0, [pc, #52]	; (c0d00794 <handle_provide_parameter+0x224>)
c0d00760:	4478      	add	r0, pc
c0d00762:	f000 f93f 	bl	c0d009e4 <semihosted_printf>
c0d00766:	7830      	ldrb	r0, [r6, #0]
c0d00768:	1c40      	adds	r0, r0, #1
c0d0076a:	7030      	strb	r0, [r6, #0]
        break;
    }
c0d0076c:	b001      	add	sp, #4
c0d0076e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00770:	00000e81 	.word	0x00000e81
c0d00774:	00000f9b 	.word	0x00000f9b
c0d00778:	00000fbb 	.word	0x00000fbb
c0d0077c:	00000f9d 	.word	0x00000f9d
c0d00780:	00000fa4 	.word	0x00000fa4
c0d00784:	00000fac 	.word	0x00000fac
c0d00788:	00000e4e 	.word	0x00000e4e
c0d0078c:	00000e75 	.word	0x00000e75
c0d00790:	00000e84 	.word	0x00000e84
c0d00794:	00000d5f 	.word	0x00000d5f
c0d00798:	00000e45 	.word	0x00000e45
c0d0079c:	0000103f 	.word	0x0000103f
c0d007a0:	00000fef 	.word	0x00000fef
c0d007a4:	000010bc 	.word	0x000010bc
c0d007a8:	00000f40 	.word	0x00000f40
c0d007ac:	00000f4b 	.word	0x00000f4b
c0d007b0:	00000fbd 	.word	0x00000fbd
c0d007b4:	00000fc9 	.word	0x00000fc9
c0d007b8:	00000e7e 	.word	0x00000e7e
c0d007bc:	00000df4 	.word	0x00000df4
c0d007c0:	00000f1c 	.word	0x00000f1c
c0d007c4:	00000d6e 	.word	0x00000d6e
c0d007c8:	00000e00 	.word	0x00000e00
c0d007cc:	00000e23 	.word	0x00000e23
c0d007d0:	00000e32 	.word	0x00000e32
c0d007d4:	00000e36 	.word	0x00000e36
c0d007d8:	00000eaa 	.word	0x00000eaa

c0d007dc <handle_provide_token>:

// EDIT THIS: Adapt this function to your needs! Remember, the information for tokens are held in
// `msg->token1` and `msg->token2`. If those pointers are `NULL`, this means the ethereum app didn't
// find any info regarding the requested tokens!
void handle_provide_token(void *parameters)
{
c0d007dc:	b570      	push	{r4, r5, r6, lr}
c0d007de:	4604      	mov	r4, r0
    ethPluginProvideInfo_t *msg = (ethPluginProvideInfo_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;
c0d007e0:	6885      	ldr	r5, [r0, #8]

    if (msg->item1)
c0d007e2:	68c0      	ldr	r0, [r0, #12]
c0d007e4:	462e      	mov	r6, r5
c0d007e6:	3655      	adds	r6, #85	; 0x55
c0d007e8:	2800      	cmp	r0, #0
c0d007ea:	d00f      	beq.n	c0d0080c <handle_provide_token+0x30>
    {
        PRINTF("PENZO item1\n");
c0d007ec:	480c      	ldr	r0, [pc, #48]	; (c0d00820 <handle_provide_token+0x44>)
c0d007ee:	4478      	add	r0, pc
c0d007f0:	f000 f8f8 	bl	c0d009e4 <semihosted_printf>
        // The Ethereum App found the information for the requested token!
        // Store its decimals.
        context->decimals = msg->item1->token.decimals;
c0d007f4:	68e1      	ldr	r1, [r4, #12]
c0d007f6:	2034      	movs	r0, #52	; 0x34
c0d007f8:	5c08      	ldrb	r0, [r1, r0]
c0d007fa:	7030      	strb	r0, [r6, #0]
        // Store its ticker.
        strlcpy(context->ticker, (char *)msg->item1->token.ticker, sizeof(context->ticker));
c0d007fc:	3549      	adds	r5, #73	; 0x49
c0d007fe:	3114      	adds	r1, #20
c0d00800:	220c      	movs	r2, #12
c0d00802:	4628      	mov	r0, r5
c0d00804:	f000 fd6e 	bl	c0d012e4 <strlcpy>
c0d00808:	2001      	movs	r0, #1
c0d0080a:	e004      	b.n	c0d00816 <handle_provide_token+0x3a>
        // Keep track that we found the token.
        context->token_found = true;
    }
    else
    {
        PRINTF("PENZO no item1\n");
c0d0080c:	4805      	ldr	r0, [pc, #20]	; (c0d00824 <handle_provide_token+0x48>)
c0d0080e:	4478      	add	r0, pc
c0d00810:	f000 f8e8 	bl	c0d009e4 <semihosted_printf>
c0d00814:	2000      	movs	r0, #0
        // The Ethereum App did not manage to find the info for the requested token.
        context->token_found = false;
c0d00816:	7070      	strb	r0, [r6, #1]
c0d00818:	2004      	movs	r0, #4
        // If we wanted to add a screen, say a warning screen for example, we could instruct the
        // ethereum app to add an additional screen by setting `msg->additionalScreens` here, just
        // like so:
        // msg->additionalScreens = 1;
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
c0d0081a:	7560      	strb	r0, [r4, #21]
c0d0081c:	bd70      	pop	{r4, r5, r6, pc}
c0d0081e:	46c0      	nop			; (mov r8, r8)
c0d00820:	00000f09 	.word	0x00000f09
c0d00824:	00000ef6 	.word	0x00000ef6

c0d00828 <handle_query_contract_id>:
#include "nested_plugin.h"
#include "text.h"

// Sets the first screen to display.
void handle_query_contract_id(void *parameters)
{
c0d00828:	b5b0      	push	{r4, r5, r7, lr}
c0d0082a:	4604      	mov	r4, r0
    ethQueryContractID_t *msg = (ethQueryContractID_t *)parameters;
    const context_t *context = (const context_t *)msg->pluginContext;
c0d0082c:	6885      	ldr	r5, [r0, #8]
    // msg->name will be the upper sentence displayed on the screen.
    // msg->version will be the lower sentence displayed on the screen.

    // For the first screen, display the plugin name.
    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);
c0d0082e:	68c0      	ldr	r0, [r0, #12]
c0d00830:	6922      	ldr	r2, [r4, #16]
c0d00832:	490b      	ldr	r1, [pc, #44]	; (c0d00860 <handle_query_contract_id+0x38>)
c0d00834:	4479      	add	r1, pc
c0d00836:	f000 fd55 	bl	c0d012e4 <strlcpy>
c0d0083a:	2073      	movs	r0, #115	; 0x73

    if (context->selectorIndex == CREATE)
c0d0083c:	5c29      	ldrb	r1, [r5, r0]
c0d0083e:	2900      	cmp	r1, #0
c0d00840:	d005      	beq.n	c0d0084e <handle_query_contract_id+0x26>
        strlcpy(msg->version, "Create", msg->versionLength);
        msg->result = ETH_PLUGIN_RESULT_OK;
    }
    else
    {
        PRINTF("Selector index: %d not supported\n", context->selectorIndex);
c0d00842:	4809      	ldr	r0, [pc, #36]	; (c0d00868 <handle_query_contract_id+0x40>)
c0d00844:	4478      	add	r0, pc
c0d00846:	f000 f8cd 	bl	c0d009e4 <semihosted_printf>
c0d0084a:	2000      	movs	r0, #0
c0d0084c:	e006      	b.n	c0d0085c <handle_query_contract_id+0x34>
        strlcpy(msg->version, "Create", msg->versionLength);
c0d0084e:	6960      	ldr	r0, [r4, #20]
c0d00850:	69a2      	ldr	r2, [r4, #24]
c0d00852:	4904      	ldr	r1, [pc, #16]	; (c0d00864 <handle_query_contract_id+0x3c>)
c0d00854:	4479      	add	r1, pc
c0d00856:	f000 fd45 	bl	c0d012e4 <strlcpy>
c0d0085a:	2004      	movs	r0, #4
        msg->result = ETH_PLUGIN_RESULT_OK;
c0d0085c:	7720      	strb	r0, [r4, #28]
        msg->result = ETH_PLUGIN_RESULT_ERROR;
    }
c0d0085e:	bdb0      	pop	{r4, r5, r7, pc}
c0d00860:	00000ee0 	.word	0x00000ee0
c0d00864:	00000ec7 	.word	0x00000ec7
c0d00868:	00000ede 	.word	0x00000ede

c0d0086c <handle_query_contract_ui>:
        msg->pluginSharedRW->sha3,
        chainid);
}

void handle_query_contract_ui(void *parameters)
{
c0d0086c:	b570      	push	{r4, r5, r6, lr}
c0d0086e:	b082      	sub	sp, #8
c0d00870:	4604      	mov	r4, r0
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;
c0d00872:	69c5      	ldr	r5, [r0, #28]

    // msg->title is the upper line displayed on the device.
    // msg->msg is the lower line displayed on the device.

    // Clean the display fields.
    memset(msg->title, 0, msg->titleLength);
c0d00874:	6a40      	ldr	r0, [r0, #36]	; 0x24
c0d00876:	6aa1      	ldr	r1, [r4, #40]	; 0x28
c0d00878:	f000 fcb2 	bl	c0d011e0 <__aeabi_memclr>
    memset(msg->msg, 0, msg->msgLength);
c0d0087c:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d0087e:	6b21      	ldr	r1, [r4, #48]	; 0x30
c0d00880:	f000 fcae 	bl	c0d011e0 <__aeabi_memclr>
c0d00884:	4626      	mov	r6, r4
c0d00886:	3620      	adds	r6, #32
c0d00888:	2004      	movs	r0, #4

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d0088a:	7530      	strb	r0, [r6, #20]
c0d0088c:	2020      	movs	r0, #32

    // EDIT THIS: Adapt the cases for the screens you'd like to display.
    switch (msg->screenIndex)
c0d0088e:	5c20      	ldrb	r0, [r4, r0]
c0d00890:	2802      	cmp	r0, #2
c0d00892:	d016      	beq.n	c0d008c2 <handle_query_contract_ui+0x56>
c0d00894:	2801      	cmp	r0, #1
c0d00896:	d02c      	beq.n	c0d008f2 <handle_query_contract_ui+0x86>
c0d00898:	2800      	cmp	r0, #0
c0d0089a:	d13d      	bne.n	c0d00918 <handle_query_contract_ui+0xac>
    strlcpy(msg->title, "Send", msg->titleLength);
c0d0089c:	6a60      	ldr	r0, [r4, #36]	; 0x24
c0d0089e:	6aa2      	ldr	r2, [r4, #40]	; 0x28
c0d008a0:	4927      	ldr	r1, [pc, #156]	; (c0d00940 <handle_query_contract_ui+0xd4>)
c0d008a2:	4479      	add	r1, pc
c0d008a4:	f000 fd1e 	bl	c0d012e4 <strlcpy>
    const uint8_t *eth_amount = msg->pluginSharedRO->txContent->value.value;
c0d008a8:	6860      	ldr	r0, [r4, #4]
c0d008aa:	6800      	ldr	r0, [r0, #0]
c0d008ac:	2162      	movs	r1, #98	; 0x62
    uint8_t eth_amount_size = msg->pluginSharedRO->txContent->value.length;
c0d008ae:	5c41      	ldrb	r1, [r0, r1]
    amountToString(eth_amount, eth_amount_size, WEI_TO_ETHER, "ETH ", msg->msg, msg->msgLength);
c0d008b0:	6ae2      	ldr	r2, [r4, #44]	; 0x2c
c0d008b2:	6b23      	ldr	r3, [r4, #48]	; 0x30
c0d008b4:	9200      	str	r2, [sp, #0]
c0d008b6:	9301      	str	r3, [sp, #4]
    const uint8_t *eth_amount = msg->pluginSharedRO->txContent->value.value;
c0d008b8:	3042      	adds	r0, #66	; 0x42
c0d008ba:	2212      	movs	r2, #18
    amountToString(eth_amount, eth_amount_size, WEI_TO_ETHER, "ETH ", msg->msg, msg->msgLength);
c0d008bc:	4b21      	ldr	r3, [pc, #132]	; (c0d00944 <handle_query_contract_ui+0xd8>)
c0d008be:	447b      	add	r3, pc
c0d008c0:	e039      	b.n	c0d00936 <handle_query_contract_ui+0xca>
    strlcpy(msg->title, "Beneficiary", msg->titleLength);
c0d008c2:	6a60      	ldr	r0, [r4, #36]	; 0x24
c0d008c4:	6aa2      	ldr	r2, [r4, #40]	; 0x28
c0d008c6:	4921      	ldr	r1, [pc, #132]	; (c0d0094c <handle_query_contract_ui+0xe0>)
c0d008c8:	4479      	add	r1, pc
c0d008ca:	f000 fd0b 	bl	c0d012e4 <strlcpy>
    msg->msg[0] = '0';
c0d008ce:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d008d0:	2130      	movs	r1, #48	; 0x30
c0d008d2:	7001      	strb	r1, [r0, #0]
    msg->msg[1] = 'x';
c0d008d4:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d008d6:	2178      	movs	r1, #120	; 0x78
c0d008d8:	7041      	strb	r1, [r0, #1]
        msg->pluginSharedRW->sha3,
c0d008da:	6820      	ldr	r0, [r4, #0]
c0d008dc:	6802      	ldr	r2, [r0, #0]
        msg->msg + 2, // +2 here because we've already prefixed with '0x'.
c0d008de:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d008e0:	2100      	movs	r1, #0
    getEthAddressStringFromBinary(
c0d008e2:	9100      	str	r1, [sp, #0]
c0d008e4:	9101      	str	r1, [sp, #4]
        context->beneficiary,
c0d008e6:	3521      	adds	r5, #33	; 0x21
        msg->msg + 2, // +2 here because we've already prefixed with '0x'.
c0d008e8:	1c81      	adds	r1, r0, #2
    getEthAddressStringFromBinary(
c0d008ea:	4628      	mov	r0, r5
c0d008ec:	f7ff fbe6 	bl	c0d000bc <getEthAddressStringFromBinary>
c0d008f0:	e023      	b.n	c0d0093a <handle_query_contract_ui+0xce>
c0d008f2:	462e      	mov	r6, r5
c0d008f4:	3655      	adds	r6, #85	; 0x55
    strlcpy(msg->title, "Receive Min.", msg->titleLength);
c0d008f6:	6a60      	ldr	r0, [r4, #36]	; 0x24
c0d008f8:	6aa2      	ldr	r2, [r4, #40]	; 0x28
c0d008fa:	4913      	ldr	r1, [pc, #76]	; (c0d00948 <handle_query_contract_ui+0xdc>)
c0d008fc:	4479      	add	r1, pc
c0d008fe:	f000 fcf1 	bl	c0d012e4 <strlcpy>
    uint8_t decimals = context->decimals;
c0d00902:	7830      	ldrb	r0, [r6, #0]
    if (!context->token_found)
c0d00904:	7871      	ldrb	r1, [r6, #1]
                   msg->msg,
c0d00906:	6ae2      	ldr	r2, [r4, #44]	; 0x2c
                   msg->msgLength);
c0d00908:	6b23      	ldr	r3, [r4, #48]	; 0x30
    amountToString(context->amount_received,
c0d0090a:	9200      	str	r2, [sp, #0]
c0d0090c:	9301      	str	r3, [sp, #4]
    if (!context->token_found)
c0d0090e:	2900      	cmp	r1, #0
c0d00910:	d009      	beq.n	c0d00926 <handle_query_contract_ui+0xba>
c0d00912:	462c      	mov	r4, r5
c0d00914:	3449      	adds	r4, #73	; 0x49
c0d00916:	e007      	b.n	c0d00928 <handle_query_contract_ui+0xbc>
    case 2:
        set_beneficiary_ui(msg, context);
        break;
    // Keep this
    default:
        PRINTF("Received an invalid screenIndex\n");
c0d00918:	480d      	ldr	r0, [pc, #52]	; (c0d00950 <handle_query_contract_ui+0xe4>)
c0d0091a:	4478      	add	r0, pc
c0d0091c:	f000 f862 	bl	c0d009e4 <semihosted_printf>
c0d00920:	2000      	movs	r0, #0
        msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d00922:	7530      	strb	r0, [r6, #20]
c0d00924:	e009      	b.n	c0d0093a <handle_query_contract_ui+0xce>
c0d00926:	3410      	adds	r4, #16
    if (!context->token_found)
c0d00928:	2900      	cmp	r1, #0
c0d0092a:	d100      	bne.n	c0d0092e <handle_query_contract_ui+0xc2>
c0d0092c:	2012      	movs	r0, #18
    amountToString(context->amount_received,
c0d0092e:	b2c2      	uxtb	r2, r0
c0d00930:	1c68      	adds	r0, r5, #1
c0d00932:	2120      	movs	r1, #32
c0d00934:	4623      	mov	r3, r4
c0d00936:	f7ff fd65 	bl	c0d00404 <amountToString>
        return;
    }
}
c0d0093a:	b002      	add	sp, #8
c0d0093c:	bd70      	pop	{r4, r5, r6, pc}
c0d0093e:	46c0      	nop			; (mov r8, r8)
c0d00940:	00000ec3 	.word	0x00000ec3
c0d00944:	00000eac 	.word	0x00000eac
c0d00948:	00000e73 	.word	0x00000e73
c0d0094c:	00000eb4 	.word	0x00000eb4
c0d00950:	00000e2a 	.word	0x00000e2a

c0d00954 <dispatch_plugin_calls>:
{
c0d00954:	b580      	push	{r7, lr}
c0d00956:	4602      	mov	r2, r0
c0d00958:	20ff      	movs	r0, #255	; 0xff
c0d0095a:	4603      	mov	r3, r0
c0d0095c:	3304      	adds	r3, #4
    switch (message)
c0d0095e:	429a      	cmp	r2, r3
c0d00960:	dc0c      	bgt.n	c0d0097c <dispatch_plugin_calls+0x28>
c0d00962:	3002      	adds	r0, #2
c0d00964:	4282      	cmp	r2, r0
c0d00966:	d018      	beq.n	c0d0099a <dispatch_plugin_calls+0x46>
c0d00968:	2081      	movs	r0, #129	; 0x81
c0d0096a:	0040      	lsls	r0, r0, #1
c0d0096c:	4282      	cmp	r2, r0
c0d0096e:	d018      	beq.n	c0d009a2 <dispatch_plugin_calls+0x4e>
c0d00970:	429a      	cmp	r2, r3
c0d00972:	d122      	bne.n	c0d009ba <dispatch_plugin_calls+0x66>
        handle_finalize(parameters);
c0d00974:	4608      	mov	r0, r1
c0d00976:	f7ff fd83 	bl	c0d00480 <handle_finalize>
}
c0d0097a:	bd80      	pop	{r7, pc}
c0d0097c:	2341      	movs	r3, #65	; 0x41
c0d0097e:	009b      	lsls	r3, r3, #2
    switch (message)
c0d00980:	429a      	cmp	r2, r3
c0d00982:	d012      	beq.n	c0d009aa <dispatch_plugin_calls+0x56>
c0d00984:	3006      	adds	r0, #6
c0d00986:	4282      	cmp	r2, r0
c0d00988:	d013      	beq.n	c0d009b2 <dispatch_plugin_calls+0x5e>
c0d0098a:	2083      	movs	r0, #131	; 0x83
c0d0098c:	0040      	lsls	r0, r0, #1
c0d0098e:	4282      	cmp	r2, r0
c0d00990:	d113      	bne.n	c0d009ba <dispatch_plugin_calls+0x66>
        handle_query_contract_ui(parameters);
c0d00992:	4608      	mov	r0, r1
c0d00994:	f7ff ff6a 	bl	c0d0086c <handle_query_contract_ui>
}
c0d00998:	bd80      	pop	{r7, pc}
        handle_init_contract(parameters);
c0d0099a:	4608      	mov	r0, r1
c0d0099c:	f7ff fd88 	bl	c0d004b0 <handle_init_contract>
}
c0d009a0:	bd80      	pop	{r7, pc}
        handle_provide_parameter(parameters);
c0d009a2:	4608      	mov	r0, r1
c0d009a4:	f7ff fde4 	bl	c0d00570 <handle_provide_parameter>
}
c0d009a8:	bd80      	pop	{r7, pc}
        handle_provide_token(parameters);
c0d009aa:	4608      	mov	r0, r1
c0d009ac:	f7ff ff16 	bl	c0d007dc <handle_provide_token>
}
c0d009b0:	bd80      	pop	{r7, pc}
        handle_query_contract_id(parameters);
c0d009b2:	4608      	mov	r0, r1
c0d009b4:	f7ff ff38 	bl	c0d00828 <handle_query_contract_id>
}
c0d009b8:	bd80      	pop	{r7, pc}
        PRINTF("Unhandled message %d\n", message);
c0d009ba:	4803      	ldr	r0, [pc, #12]	; (c0d009c8 <dispatch_plugin_calls+0x74>)
c0d009bc:	4478      	add	r0, pc
c0d009be:	4611      	mov	r1, r2
c0d009c0:	f000 f810 	bl	c0d009e4 <semihosted_printf>
}
c0d009c4:	bd80      	pop	{r7, pc}
c0d009c6:	46c0      	nop			; (mov r8, r8)
c0d009c8:	00000dcc 	.word	0x00000dcc

c0d009cc <os_boot>:

// apdu buffer must hold a complete apdu to avoid troubles
unsigned char G_io_apdu_buffer[IO_APDU_BUFFER_SIZE];

#ifndef BOLOS_OS_UPGRADER_APP
void os_boot(void) {
c0d009cc:	b580      	push	{r7, lr}
c0d009ce:	2000      	movs	r0, #0
  // // TODO patch entry point when romming (f)
  // // set the default try context to nothing
#ifndef HAVE_BOLOS
  try_context_set(NULL);
c0d009d0:	f000 fa28 	bl	c0d00e24 <try_context_set>
#endif // HAVE_BOLOS
}
c0d009d4:	bd80      	pop	{r7, pc}

c0d009d6 <os_longjmp>:
  }
  return xoracc;
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0d009d6:	4604      	mov	r4, r0
#ifdef HAVE_PRINTF  
  unsigned int lr_val;
  __asm volatile("mov %0, lr" :"=r"(lr_val));
  PRINTF("exception[%d]: LR=0x%08X\n", exception, lr_val);
#endif // HAVE_PRINTF
  longjmp(try_context_get()->jmp_buf, exception);
c0d009d8:	f000 fa18 	bl	c0d00e0c <try_context_get>
c0d009dc:	4621      	mov	r1, r4
c0d009de:	f000 fc51 	bl	c0d01284 <longjmp>
	...

c0d009e4 <semihosted_printf>:
    'D',
    'E',
    'F',
};

void semihosted_printf(const char *format, ...) {
c0d009e4:	b083      	sub	sp, #12
c0d009e6:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d009e8:	b09c      	sub	sp, #112	; 0x70
c0d009ea:	ac21      	add	r4, sp, #132	; 0x84
c0d009ec:	c40e      	stmia	r4!, {r1, r2, r3}
    char cStrlenSet;

    //
    // Check the arguments.
    //
    if (format == 0) {
c0d009ee:	2800      	cmp	r0, #0
c0d009f0:	d100      	bne.n	c0d009f4 <semihosted_printf+0x10>
c0d009f2:	e19e      	b.n	c0d00d32 <semihosted_printf+0x34e>
c0d009f4:	4604      	mov	r4, r0
c0d009f6:	a821      	add	r0, sp, #132	; 0x84
    }

    //
    // Start the varargs processing.
    //
    va_start(vaArgP, format);
c0d009f8:	9006      	str	r0, [sp, #24]

    //
    // Loop while there are more characters in the string.
    //
    while (*format) {
c0d009fa:	7820      	ldrb	r0, [r4, #0]
c0d009fc:	2800      	cmp	r0, #0
c0d009fe:	d100      	bne.n	c0d00a02 <semihosted_printf+0x1e>
c0d00a00:	e197      	b.n	c0d00d32 <semihosted_printf+0x34e>
c0d00a02:	2600      	movs	r6, #0
        //
        // Find the first non-% character, or the end of the string.
        //
        for (ulIdx = 0; (format[ulIdx] != '%') && (format[ulIdx] != '\0'); ulIdx++) {
c0d00a04:	2800      	cmp	r0, #0
c0d00a06:	d005      	beq.n	c0d00a14 <semihosted_printf+0x30>
c0d00a08:	2825      	cmp	r0, #37	; 0x25
c0d00a0a:	d003      	beq.n	c0d00a14 <semihosted_printf+0x30>
c0d00a0c:	19a0      	adds	r0, r4, r6
c0d00a0e:	7840      	ldrb	r0, [r0, #1]
c0d00a10:	1c76      	adds	r6, r6, #1
c0d00a12:	e7f7      	b.n	c0d00a04 <semihosted_printf+0x20>
        }

        //
        // Write this portion of the string.
        //
        prints(format, ulIdx);
c0d00a14:	b2b1      	uxth	r1, r6
c0d00a16:	4620      	mov	r0, r4
c0d00a18:	f000 f99a 	bl	c0d00d50 <prints>
        format += ulIdx;

        //
        // See if the next character is a %.
        //
        if (*format == '%') {
c0d00a1c:	5da0      	ldrb	r0, [r4, r6]
c0d00a1e:	2825      	cmp	r0, #37	; 0x25
c0d00a20:	d001      	beq.n	c0d00a26 <semihosted_printf+0x42>
c0d00a22:	19a4      	adds	r4, r4, r6
c0d00a24:	e7ea      	b.n	c0d009fc <semihosted_printf+0x18>
            ulCount = 0;
            cFill = ' ';
            ulStrlen = 0;
            cStrlenSet = 0;
            ulCap = 0;
            ulBase = 10;
c0d00a26:	19a0      	adds	r0, r4, r6
c0d00a28:	1c44      	adds	r4, r0, #1
c0d00a2a:	2500      	movs	r5, #0
c0d00a2c:	2020      	movs	r0, #32
c0d00a2e:	9004      	str	r0, [sp, #16]
c0d00a30:	200a      	movs	r0, #10
c0d00a32:	9003      	str	r0, [sp, #12]
c0d00a34:	9505      	str	r5, [sp, #20]
c0d00a36:	462f      	mov	r7, r5
c0d00a38:	462b      	mov	r3, r5
c0d00a3a:	4619      	mov	r1, r3
        again:

            //
            // Determine how to handle the next character.
            //
            switch (*format++) {
c0d00a3c:	7820      	ldrb	r0, [r4, #0]
c0d00a3e:	1c64      	adds	r4, r4, #1
c0d00a40:	2300      	movs	r3, #0
c0d00a42:	282d      	cmp	r0, #45	; 0x2d
c0d00a44:	d0f9      	beq.n	c0d00a3a <semihosted_printf+0x56>
c0d00a46:	2847      	cmp	r0, #71	; 0x47
c0d00a48:	dc13      	bgt.n	c0d00a72 <semihosted_printf+0x8e>
c0d00a4a:	282f      	cmp	r0, #47	; 0x2f
c0d00a4c:	dd1f      	ble.n	c0d00a8e <semihosted_printf+0xaa>
c0d00a4e:	4603      	mov	r3, r0
c0d00a50:	3b30      	subs	r3, #48	; 0x30
c0d00a52:	2b0a      	cmp	r3, #10
c0d00a54:	d300      	bcc.n	c0d00a58 <semihosted_printf+0x74>
c0d00a56:	e0da      	b.n	c0d00c0e <semihosted_printf+0x22a>
c0d00a58:	2330      	movs	r3, #48	; 0x30
                case '9': {
                    //
                    // If this is a zero, and it is the first digit, then the
                    // fill character is a zero instead of a space.
                    //
                    if ((format[-1] == '0') && (ulCount == 0)) {
c0d00a5a:	4602      	mov	r2, r0
c0d00a5c:	405a      	eors	r2, r3
c0d00a5e:	432a      	orrs	r2, r5
c0d00a60:	d000      	beq.n	c0d00a64 <semihosted_printf+0x80>
c0d00a62:	9b04      	ldr	r3, [sp, #16]
c0d00a64:	220a      	movs	r2, #10
                    }

                    //
                    // Update the digit count.
                    //
                    ulCount *= 10;
c0d00a66:	436a      	muls	r2, r5
                    ulCount += format[-1] - '0';
c0d00a68:	1815      	adds	r5, r2, r0
c0d00a6a:	3d30      	subs	r5, #48	; 0x30
c0d00a6c:	9304      	str	r3, [sp, #16]
c0d00a6e:	460b      	mov	r3, r1
c0d00a70:	e7e3      	b.n	c0d00a3a <semihosted_printf+0x56>
            switch (*format++) {
c0d00a72:	2867      	cmp	r0, #103	; 0x67
c0d00a74:	dd04      	ble.n	c0d00a80 <semihosted_printf+0x9c>
c0d00a76:	2872      	cmp	r0, #114	; 0x72
c0d00a78:	dd20      	ble.n	c0d00abc <semihosted_printf+0xd8>
c0d00a7a:	2873      	cmp	r0, #115	; 0x73
c0d00a7c:	d13a      	bne.n	c0d00af4 <semihosted_printf+0x110>
c0d00a7e:	e023      	b.n	c0d00ac8 <semihosted_printf+0xe4>
c0d00a80:	2862      	cmp	r0, #98	; 0x62
c0d00a82:	dc3d      	bgt.n	c0d00b00 <semihosted_printf+0x11c>
c0d00a84:	2848      	cmp	r0, #72	; 0x48
c0d00a86:	d000      	beq.n	c0d00a8a <semihosted_printf+0xa6>
c0d00a88:	e08f      	b.n	c0d00baa <semihosted_printf+0x1c6>
c0d00a8a:	2701      	movs	r7, #1
c0d00a8c:	e01a      	b.n	c0d00ac4 <semihosted_printf+0xe0>
c0d00a8e:	2825      	cmp	r0, #37	; 0x25
c0d00a90:	d100      	bne.n	c0d00a94 <semihosted_printf+0xb0>
c0d00a92:	e099      	b.n	c0d00bc8 <semihosted_printf+0x1e4>
c0d00a94:	282a      	cmp	r0, #42	; 0x2a
c0d00a96:	d022      	beq.n	c0d00ade <semihosted_printf+0xfa>
c0d00a98:	282e      	cmp	r0, #46	; 0x2e
c0d00a9a:	d000      	beq.n	c0d00a9e <semihosted_printf+0xba>
c0d00a9c:	e0b7      	b.n	c0d00c0e <semihosted_printf+0x22a>
                // special %.*H or %.*h format to print a given length of hex digits (case: H UPPER,
                // h lower)
                //
                case '.': {
                    // ensure next char is '*' and next one is 's'
                    if (format[0] == '*' &&
c0d00a9e:	7820      	ldrb	r0, [r4, #0]
c0d00aa0:	282a      	cmp	r0, #42	; 0x2a
c0d00aa2:	d000      	beq.n	c0d00aa6 <semihosted_printf+0xc2>
c0d00aa4:	e0b3      	b.n	c0d00c0e <semihosted_printf+0x22a>
                        (format[1] == 's' || format[1] == 'H' || format[1] == 'h')) {
c0d00aa6:	7861      	ldrb	r1, [r4, #1]
c0d00aa8:	2948      	cmp	r1, #72	; 0x48
c0d00aaa:	d004      	beq.n	c0d00ab6 <semihosted_printf+0xd2>
c0d00aac:	2973      	cmp	r1, #115	; 0x73
c0d00aae:	d002      	beq.n	c0d00ab6 <semihosted_printf+0xd2>
c0d00ab0:	2968      	cmp	r1, #104	; 0x68
c0d00ab2:	d000      	beq.n	c0d00ab6 <semihosted_printf+0xd2>
c0d00ab4:	e0ab      	b.n	c0d00c0e <semihosted_printf+0x22a>
c0d00ab6:	1c64      	adds	r4, r4, #1
c0d00ab8:	2301      	movs	r3, #1
c0d00aba:	e015      	b.n	c0d00ae8 <semihosted_printf+0x104>
            switch (*format++) {
c0d00abc:	2868      	cmp	r0, #104	; 0x68
c0d00abe:	d000      	beq.n	c0d00ac2 <semihosted_printf+0xde>
c0d00ac0:	e077      	b.n	c0d00bb2 <semihosted_printf+0x1ce>
c0d00ac2:	2700      	movs	r7, #0
c0d00ac4:	2010      	movs	r0, #16
c0d00ac6:	9003      	str	r0, [sp, #12]
                case 's':
                case_s : {
                    //
                    // Get the string pointer from the varargs.
                    //
                    pcStr = va_arg(vaArgP, char *);
c0d00ac8:	9806      	ldr	r0, [sp, #24]
c0d00aca:	1d02      	adds	r2, r0, #4
c0d00acc:	9206      	str	r2, [sp, #24]

                    //
                    // Determine the length of the string. (if not specified using .*)
                    //
                    switch (cStrlenSet) {
c0d00ace:	b2cb      	uxtb	r3, r1
                    pcStr = va_arg(vaArgP, char *);
c0d00ad0:	6802      	ldr	r2, [r0, #0]
                    switch (cStrlenSet) {
c0d00ad2:	2b01      	cmp	r3, #1
c0d00ad4:	dd25      	ble.n	c0d00b22 <semihosted_printf+0x13e>
c0d00ad6:	2b02      	cmp	r3, #2
c0d00ad8:	460b      	mov	r3, r1
c0d00ada:	d1ae      	bne.n	c0d00a3a <semihosted_printf+0x56>
c0d00adc:	e094      	b.n	c0d00c08 <semihosted_printf+0x224>
                    if (*format == 's') {
c0d00ade:	7820      	ldrb	r0, [r4, #0]
c0d00ae0:	2873      	cmp	r0, #115	; 0x73
c0d00ae2:	d000      	beq.n	c0d00ae6 <semihosted_printf+0x102>
c0d00ae4:	e093      	b.n	c0d00c0e <semihosted_printf+0x22a>
c0d00ae6:	2302      	movs	r3, #2
c0d00ae8:	9906      	ldr	r1, [sp, #24]
c0d00aea:	1d08      	adds	r0, r1, #4
c0d00aec:	9006      	str	r0, [sp, #24]
c0d00aee:	6808      	ldr	r0, [r1, #0]
            switch (*format++) {
c0d00af0:	9005      	str	r0, [sp, #20]
c0d00af2:	e7a2      	b.n	c0d00a3a <semihosted_printf+0x56>
c0d00af4:	2875      	cmp	r0, #117	; 0x75
c0d00af6:	d100      	bne.n	c0d00afa <semihosted_printf+0x116>
c0d00af8:	e070      	b.n	c0d00bdc <semihosted_printf+0x1f8>
c0d00afa:	2878      	cmp	r0, #120	; 0x78
c0d00afc:	d05b      	beq.n	c0d00bb6 <semihosted_printf+0x1d2>
c0d00afe:	e086      	b.n	c0d00c0e <semihosted_printf+0x22a>
c0d00b00:	2863      	cmp	r0, #99	; 0x63
c0d00b02:	d100      	bne.n	c0d00b06 <semihosted_printf+0x122>
c0d00b04:	e073      	b.n	c0d00bee <semihosted_printf+0x20a>
c0d00b06:	2864      	cmp	r0, #100	; 0x64
c0d00b08:	d000      	beq.n	c0d00b0c <semihosted_printf+0x128>
c0d00b0a:	e080      	b.n	c0d00c0e <semihosted_printf+0x22a>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d00b0c:	9806      	ldr	r0, [sp, #24]
c0d00b0e:	1d01      	adds	r1, r0, #4
c0d00b10:	9106      	str	r1, [sp, #24]
c0d00b12:	6806      	ldr	r6, [r0, #0]
c0d00b14:	960b      	str	r6, [sp, #44]	; 0x2c
c0d00b16:	200a      	movs	r0, #10
                    if ((long) ulValue < 0) {
c0d00b18:	2e00      	cmp	r6, #0
c0d00b1a:	d500      	bpl.n	c0d00b1e <semihosted_printf+0x13a>
c0d00b1c:	e085      	b.n	c0d00c2a <semihosted_printf+0x246>
c0d00b1e:	2100      	movs	r1, #0
c0d00b20:	e086      	b.n	c0d00c30 <semihosted_printf+0x24c>
                    switch (cStrlenSet) {
c0d00b22:	2b00      	cmp	r3, #0
c0d00b24:	9e05      	ldr	r6, [sp, #20]
c0d00b26:	d105      	bne.n	c0d00b34 <semihosted_printf+0x150>
c0d00b28:	2100      	movs	r1, #0
                        // compute length with strlen
                        case 0:
                            for (ulIdx = 0; pcStr[ulIdx] != '\0'; ulIdx++) {
c0d00b2a:	5c50      	ldrb	r0, [r2, r1]
c0d00b2c:	1c49      	adds	r1, r1, #1
c0d00b2e:	2800      	cmp	r0, #0
c0d00b30:	d1fb      	bne.n	c0d00b2a <semihosted_printf+0x146>
                    }

                    //
                    // Write the string.
                    //
                    switch (ulBase) {
c0d00b32:	1e4e      	subs	r6, r1, #1
c0d00b34:	9803      	ldr	r0, [sp, #12]
c0d00b36:	2810      	cmp	r0, #16
c0d00b38:	d000      	beq.n	c0d00b3c <semihosted_printf+0x158>
c0d00b3a:	e071      	b.n	c0d00c20 <semihosted_printf+0x23c>
                        default:
                            prints(pcStr, ulIdx);
                            break;
                        case 16: {
                            unsigned char nibble1, nibble2;
                            for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d00b3c:	2e00      	cmp	r6, #0
c0d00b3e:	9702      	str	r7, [sp, #8]
c0d00b40:	d100      	bne.n	c0d00b44 <semihosted_printf+0x160>
c0d00b42:	e75a      	b.n	c0d009fa <semihosted_printf+0x16>
                                nibble1 = (pcStr[ulCount] >> 4) & 0xF;
c0d00b44:	7810      	ldrb	r0, [r2, #0]
c0d00b46:	230f      	movs	r3, #15
                                nibble2 = pcStr[ulCount] & 0xF;
c0d00b48:	4003      	ands	r3, r0
                                nibble1 = (pcStr[ulCount] >> 4) & 0xF;
c0d00b4a:	0900      	lsrs	r0, r0, #4
                                switch (ulCap) {
c0d00b4c:	2f01      	cmp	r7, #1
c0d00b4e:	d015      	beq.n	c0d00b7c <semihosted_printf+0x198>
c0d00b50:	2f00      	cmp	r7, #0
c0d00b52:	d126      	bne.n	c0d00ba2 <semihosted_printf+0x1be>
c0d00b54:	ad0c      	add	r5, sp, #48	; 0x30
c0d00b56:	9605      	str	r6, [sp, #20]
c0d00b58:	2600      	movs	r6, #0
    buf[1] = 0;
c0d00b5a:	706e      	strb	r6, [r5, #1]
                                    case 0:
                                        printc(g_pcHex[nibble1]);
c0d00b5c:	4f78      	ldr	r7, [pc, #480]	; (c0d00d40 <semihosted_printf+0x35c>)
c0d00b5e:	447f      	add	r7, pc
c0d00b60:	5c38      	ldrb	r0, [r7, r0]
    buf[0] = c;
c0d00b62:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00b64:	2004      	movs	r0, #4
c0d00b66:	0029      	movs	r1, r5
c0d00b68:	dfab      	svc	171	; 0xab
    buf[1] = 0;
c0d00b6a:	706e      	strb	r6, [r5, #1]
c0d00b6c:	9e05      	ldr	r6, [sp, #20]
                                        printc(g_pcHex[nibble2]);
c0d00b6e:	5cf8      	ldrb	r0, [r7, r3]
c0d00b70:	9f02      	ldr	r7, [sp, #8]
    buf[0] = c;
c0d00b72:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00b74:	2004      	movs	r0, #4
c0d00b76:	0029      	movs	r1, r5
c0d00b78:	dfab      	svc	171	; 0xab
c0d00b7a:	e012      	b.n	c0d00ba2 <semihosted_printf+0x1be>
c0d00b7c:	ad0c      	add	r5, sp, #48	; 0x30
c0d00b7e:	9605      	str	r6, [sp, #20]
c0d00b80:	2600      	movs	r6, #0
    buf[1] = 0;
c0d00b82:	706e      	strb	r6, [r5, #1]
                                        break;
                                    case 1:
                                        printc(g_pcHex_cap[nibble1]);
c0d00b84:	4f6f      	ldr	r7, [pc, #444]	; (c0d00d44 <semihosted_printf+0x360>)
c0d00b86:	447f      	add	r7, pc
c0d00b88:	5c38      	ldrb	r0, [r7, r0]
    buf[0] = c;
c0d00b8a:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00b8c:	2004      	movs	r0, #4
c0d00b8e:	0029      	movs	r1, r5
c0d00b90:	dfab      	svc	171	; 0xab
    buf[1] = 0;
c0d00b92:	706e      	strb	r6, [r5, #1]
c0d00b94:	9e05      	ldr	r6, [sp, #20]
                                        printc(g_pcHex_cap[nibble2]);
c0d00b96:	5cf8      	ldrb	r0, [r7, r3]
c0d00b98:	9f02      	ldr	r7, [sp, #8]
    buf[0] = c;
c0d00b9a:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00b9c:	2004      	movs	r0, #4
c0d00b9e:	0029      	movs	r1, r5
c0d00ba0:	dfab      	svc	171	; 0xab
                            for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d00ba2:	1c52      	adds	r2, r2, #1
c0d00ba4:	1e76      	subs	r6, r6, #1
c0d00ba6:	d1cd      	bne.n	c0d00b44 <semihosted_printf+0x160>
c0d00ba8:	e727      	b.n	c0d009fa <semihosted_printf+0x16>
            switch (*format++) {
c0d00baa:	2858      	cmp	r0, #88	; 0x58
c0d00bac:	d12f      	bne.n	c0d00c0e <semihosted_printf+0x22a>
c0d00bae:	2701      	movs	r7, #1
c0d00bb0:	e001      	b.n	c0d00bb6 <semihosted_printf+0x1d2>
c0d00bb2:	2870      	cmp	r0, #112	; 0x70
c0d00bb4:	d12b      	bne.n	c0d00c0e <semihosted_printf+0x22a>
                case 'x':
                case 'p': {
                    //
                    // Get the value from the varargs.
                    //
                    ulValue = va_arg(vaArgP, unsigned long);
c0d00bb6:	9806      	ldr	r0, [sp, #24]
c0d00bb8:	1d01      	adds	r1, r0, #4
c0d00bba:	9106      	str	r1, [sp, #24]
c0d00bbc:	6806      	ldr	r6, [r0, #0]
c0d00bbe:	960b      	str	r6, [sp, #44]	; 0x2c
c0d00bc0:	2000      	movs	r0, #0
c0d00bc2:	9001      	str	r0, [sp, #4]
c0d00bc4:	2010      	movs	r0, #16
c0d00bc6:	e034      	b.n	c0d00c32 <semihosted_printf+0x24e>
        memcpy(buf, str, written);
c0d00bc8:	1e60      	subs	r0, r4, #1
c0d00bca:	7800      	ldrb	r0, [r0, #0]
c0d00bcc:	aa0c      	add	r2, sp, #48	; 0x30
c0d00bce:	2100      	movs	r1, #0
        buf[written] = 0;
c0d00bd0:	7051      	strb	r1, [r2, #1]
        memcpy(buf, str, written);
c0d00bd2:	7010      	strb	r0, [r2, #0]
    asm volatile(
c0d00bd4:	2004      	movs	r0, #4
c0d00bd6:	0011      	movs	r1, r2
c0d00bd8:	dfab      	svc	171	; 0xab
c0d00bda:	e70e      	b.n	c0d009fa <semihosted_printf+0x16>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d00bdc:	9806      	ldr	r0, [sp, #24]
c0d00bde:	1d01      	adds	r1, r0, #4
c0d00be0:	9106      	str	r1, [sp, #24]
c0d00be2:	6806      	ldr	r6, [r0, #0]
c0d00be4:	960b      	str	r6, [sp, #44]	; 0x2c
c0d00be6:	2000      	movs	r0, #0
c0d00be8:	9001      	str	r0, [sp, #4]
c0d00bea:	200a      	movs	r0, #10
c0d00bec:	e021      	b.n	c0d00c32 <semihosted_printf+0x24e>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d00bee:	9806      	ldr	r0, [sp, #24]
c0d00bf0:	1d01      	adds	r1, r0, #4
c0d00bf2:	9106      	str	r1, [sp, #24]
c0d00bf4:	6800      	ldr	r0, [r0, #0]
c0d00bf6:	900b      	str	r0, [sp, #44]	; 0x2c
c0d00bf8:	aa0c      	add	r2, sp, #48	; 0x30
c0d00bfa:	2100      	movs	r1, #0
        buf[written] = 0;
c0d00bfc:	7051      	strb	r1, [r2, #1]
        memcpy(buf, str, written);
c0d00bfe:	7010      	strb	r0, [r2, #0]
    asm volatile(
c0d00c00:	2004      	movs	r0, #4
c0d00c02:	0011      	movs	r1, r2
c0d00c04:	dfab      	svc	171	; 0xab
c0d00c06:	e6f8      	b.n	c0d009fa <semihosted_printf+0x16>
                            if (pcStr[0] == '\0') {
c0d00c08:	7810      	ldrb	r0, [r2, #0]
c0d00c0a:	2800      	cmp	r0, #0
c0d00c0c:	d077      	beq.n	c0d00cfe <semihosted_printf+0x31a>
c0d00c0e:	aa0c      	add	r2, sp, #48	; 0x30
c0d00c10:	2052      	movs	r0, #82	; 0x52
        memcpy(buf, str, written);
c0d00c12:	8090      	strh	r0, [r2, #4]
c0d00c14:	4849      	ldr	r0, [pc, #292]	; (c0d00d3c <semihosted_printf+0x358>)
c0d00c16:	900c      	str	r0, [sp, #48]	; 0x30
    asm volatile(
c0d00c18:	2004      	movs	r0, #4
c0d00c1a:	0011      	movs	r1, r2
c0d00c1c:	dfab      	svc	171	; 0xab
c0d00c1e:	e6ec      	b.n	c0d009fa <semihosted_printf+0x16>
                            prints(pcStr, ulIdx);
c0d00c20:	b2b1      	uxth	r1, r6
c0d00c22:	4610      	mov	r0, r2
c0d00c24:	f000 f894 	bl	c0d00d50 <prints>
c0d00c28:	e073      	b.n	c0d00d12 <semihosted_printf+0x32e>
                        ulValue = -(long) ulValue;
c0d00c2a:	4276      	negs	r6, r6
c0d00c2c:	960b      	str	r6, [sp, #44]	; 0x2c
c0d00c2e:	2101      	movs	r1, #1
c0d00c30:	9101      	str	r1, [sp, #4]
c0d00c32:	9702      	str	r7, [sp, #8]
                    // Determine the number of digits in the string version of
                    // the value.
                    //
                convert:
                    for (ulIdx = 1;
                         (((ulIdx * ulBase) <= ulValue) && (((ulIdx * ulBase) / ulBase) == ulIdx));
c0d00c34:	42b0      	cmp	r0, r6
c0d00c36:	9003      	str	r0, [sp, #12]
c0d00c38:	d901      	bls.n	c0d00c3e <semihosted_printf+0x25a>
c0d00c3a:	2701      	movs	r7, #1
c0d00c3c:	e00f      	b.n	c0d00c5e <semihosted_printf+0x27a>
                    for (ulIdx = 1;
c0d00c3e:	1e6a      	subs	r2, r5, #1
c0d00c40:	4607      	mov	r7, r0
c0d00c42:	4615      	mov	r5, r2
c0d00c44:	2100      	movs	r1, #0
                         (((ulIdx * ulBase) <= ulValue) && (((ulIdx * ulBase) / ulBase) == ulIdx));
c0d00c46:	9803      	ldr	r0, [sp, #12]
c0d00c48:	463a      	mov	r2, r7
c0d00c4a:	460b      	mov	r3, r1
c0d00c4c:	f000 f9a4 	bl	c0d00f98 <__aeabi_lmul>
c0d00c50:	1e4a      	subs	r2, r1, #1
c0d00c52:	4191      	sbcs	r1, r2
c0d00c54:	42b0      	cmp	r0, r6
c0d00c56:	d802      	bhi.n	c0d00c5e <semihosted_printf+0x27a>
                    for (ulIdx = 1;
c0d00c58:	1e6a      	subs	r2, r5, #1
c0d00c5a:	2900      	cmp	r1, #0
c0d00c5c:	d0f0      	beq.n	c0d00c40 <semihosted_printf+0x25c>
c0d00c5e:	9801      	ldr	r0, [sp, #4]

                    //
                    // If the value is negative, reduce the count of padding
                    // characters needed.
                    //
                    if (ulNeg) {
c0d00c60:	2800      	cmp	r0, #0
c0d00c62:	9605      	str	r6, [sp, #20]
c0d00c64:	d000      	beq.n	c0d00c68 <semihosted_printf+0x284>
c0d00c66:	1e6d      	subs	r5, r5, #1
c0d00c68:	9a04      	ldr	r2, [sp, #16]
c0d00c6a:	2600      	movs	r6, #0

                    //
                    // If the value is negative and the value is padded with
                    // zeros, then place the minus sign before the padding.
                    //
                    if (ulNeg && (cFill == '0')) {
c0d00c6c:	2800      	cmp	r0, #0
c0d00c6e:	d009      	beq.n	c0d00c84 <semihosted_printf+0x2a0>
c0d00c70:	b2d0      	uxtb	r0, r2
c0d00c72:	2830      	cmp	r0, #48	; 0x30
c0d00c74:	d108      	bne.n	c0d00c88 <semihosted_printf+0x2a4>
c0d00c76:	a807      	add	r0, sp, #28
c0d00c78:	212d      	movs	r1, #45	; 0x2d
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d00c7a:	7001      	strb	r1, [r0, #0]
c0d00c7c:	2001      	movs	r0, #1
c0d00c7e:	4631      	mov	r1, r6
c0d00c80:	4606      	mov	r6, r0
c0d00c82:	e002      	b.n	c0d00c8a <semihosted_printf+0x2a6>
c0d00c84:	4631      	mov	r1, r6
c0d00c86:	e000      	b.n	c0d00c8a <semihosted_printf+0x2a6>
c0d00c88:	2101      	movs	r1, #1

                    //
                    // Provide additional padding at the beginning of the
                    // string conversion if needed.
                    //
                    if ((ulCount > 1) && (ulCount < 16)) {
c0d00c8a:	1ea8      	subs	r0, r5, #2
c0d00c8c:	280d      	cmp	r0, #13
c0d00c8e:	d80c      	bhi.n	c0d00caa <semihosted_printf+0x2c6>
c0d00c90:	a807      	add	r0, sp, #28
                        for (ulCount--; ulCount; ulCount--) {
c0d00c92:	1980      	adds	r0, r0, r6
c0d00c94:	1e6d      	subs	r5, r5, #1
                            pcBuf[ulPos++] = cFill;
c0d00c96:	b2d2      	uxtb	r2, r2
c0d00c98:	9104      	str	r1, [sp, #16]
c0d00c9a:	4629      	mov	r1, r5
c0d00c9c:	f000 faad 	bl	c0d011fa <__aeabi_memset>
c0d00ca0:	9904      	ldr	r1, [sp, #16]
c0d00ca2:	1e6d      	subs	r5, r5, #1
c0d00ca4:	1c76      	adds	r6, r6, #1
                        for (ulCount--; ulCount; ulCount--) {
c0d00ca6:	2d00      	cmp	r5, #0
c0d00ca8:	d1fb      	bne.n	c0d00ca2 <semihosted_printf+0x2be>

                    //
                    // If the value is negative, then place the minus sign
                    // before the number.
                    //
                    if (ulNeg) {
c0d00caa:	2900      	cmp	r1, #0
c0d00cac:	d003      	beq.n	c0d00cb6 <semihosted_printf+0x2d2>
c0d00cae:	a807      	add	r0, sp, #28
c0d00cb0:	212d      	movs	r1, #45	; 0x2d
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d00cb2:	5581      	strb	r1, [r0, r6]
c0d00cb4:	1c76      	adds	r6, r6, #1
                    }

                    //
                    // Convert the value into a string.
                    //
                    for (; ulIdx; ulIdx /= ulBase) {
c0d00cb6:	2f00      	cmp	r7, #0
c0d00cb8:	d01c      	beq.n	c0d00cf4 <semihosted_printf+0x310>
c0d00cba:	9802      	ldr	r0, [sp, #8]
c0d00cbc:	2800      	cmp	r0, #0
c0d00cbe:	d002      	beq.n	c0d00cc6 <semihosted_printf+0x2e2>
c0d00cc0:	4822      	ldr	r0, [pc, #136]	; (c0d00d4c <semihosted_printf+0x368>)
c0d00cc2:	4478      	add	r0, pc
c0d00cc4:	e001      	b.n	c0d00cca <semihosted_printf+0x2e6>
c0d00cc6:	4820      	ldr	r0, [pc, #128]	; (c0d00d48 <semihosted_printf+0x364>)
c0d00cc8:	4478      	add	r0, pc
c0d00cca:	9004      	str	r0, [sp, #16]
c0d00ccc:	9d03      	ldr	r5, [sp, #12]
c0d00cce:	9805      	ldr	r0, [sp, #20]
c0d00cd0:	4639      	mov	r1, r7
c0d00cd2:	f000 f8b5 	bl	c0d00e40 <__udivsi3>
c0d00cd6:	4629      	mov	r1, r5
c0d00cd8:	f000 f938 	bl	c0d00f4c <__aeabi_uidivmod>
c0d00cdc:	9804      	ldr	r0, [sp, #16]
c0d00cde:	5c40      	ldrb	r0, [r0, r1]
c0d00ce0:	a907      	add	r1, sp, #28
                        if (!ulCap) {
                            pcBuf[ulPos++] = g_pcHex[(ulValue / ulIdx) % ulBase];
c0d00ce2:	5588      	strb	r0, [r1, r6]
                    for (; ulIdx; ulIdx /= ulBase) {
c0d00ce4:	4638      	mov	r0, r7
c0d00ce6:	4629      	mov	r1, r5
c0d00ce8:	f000 f8aa 	bl	c0d00e40 <__udivsi3>
c0d00cec:	1c76      	adds	r6, r6, #1
c0d00cee:	42bd      	cmp	r5, r7
c0d00cf0:	4607      	mov	r7, r0
c0d00cf2:	d9ec      	bls.n	c0d00cce <semihosted_printf+0x2ea>
                    }

                    //
                    // Write the string.
                    //
                    prints(pcBuf, ulPos);
c0d00cf4:	b2b1      	uxth	r1, r6
c0d00cf6:	a807      	add	r0, sp, #28
c0d00cf8:	f000 f82a 	bl	c0d00d50 <prints>
c0d00cfc:	e67d      	b.n	c0d009fa <semihosted_printf+0x16>
                                do {
c0d00cfe:	9805      	ldr	r0, [sp, #20]
c0d00d00:	1c42      	adds	r2, r0, #1
c0d00d02:	ab0c      	add	r3, sp, #48	; 0x30
c0d00d04:	2020      	movs	r0, #32
        memcpy(buf, str, written);
c0d00d06:	8018      	strh	r0, [r3, #0]
    asm volatile(
c0d00d08:	2004      	movs	r0, #4
c0d00d0a:	0019      	movs	r1, r3
c0d00d0c:	dfab      	svc	171	; 0xab
                                } while (ulStrlen-- > 0);
c0d00d0e:	1e52      	subs	r2, r2, #1
c0d00d10:	d1f7      	bne.n	c0d00d02 <semihosted_printf+0x31e>
                    if (ulCount > ulIdx) {
c0d00d12:	42b5      	cmp	r5, r6
c0d00d14:	d800      	bhi.n	c0d00d18 <semihosted_printf+0x334>
c0d00d16:	e670      	b.n	c0d009fa <semihosted_printf+0x16>
                        ulCount -= ulIdx;
c0d00d18:	1ba8      	subs	r0, r5, r6
c0d00d1a:	d100      	bne.n	c0d00d1e <semihosted_printf+0x33a>
c0d00d1c:	e66d      	b.n	c0d009fa <semihosted_printf+0x16>
                        while (ulCount--) {
c0d00d1e:	1b72      	subs	r2, r6, r5
c0d00d20:	ab0c      	add	r3, sp, #48	; 0x30
c0d00d22:	2020      	movs	r0, #32
        memcpy(buf, str, written);
c0d00d24:	8018      	strh	r0, [r3, #0]
    asm volatile(
c0d00d26:	2004      	movs	r0, #4
c0d00d28:	0019      	movs	r1, r3
c0d00d2a:	dfab      	svc	171	; 0xab
                        while (ulCount--) {
c0d00d2c:	1c52      	adds	r2, r2, #1
c0d00d2e:	d3f7      	bcc.n	c0d00d20 <semihosted_printf+0x33c>
c0d00d30:	e663      	b.n	c0d009fa <semihosted_printf+0x16>

    //
    // End the varargs processing.
    //
    va_end(vaArgP);
c0d00d32:	b01c      	add	sp, #112	; 0x70
c0d00d34:	bcf0      	pop	{r4, r5, r6, r7}
c0d00d36:	bc01      	pop	{r0}
c0d00d38:	b003      	add	sp, #12
c0d00d3a:	4700      	bx	r0
c0d00d3c:	4f525245 	.word	0x4f525245
c0d00d40:	00000c49 	.word	0x00000c49
c0d00d44:	00000c31 	.word	0x00000c31
c0d00d48:	00000adf 	.word	0x00000adf
c0d00d4c:	00000af5 	.word	0x00000af5

c0d00d50 <prints>:
static void prints(const char *str, uint16_t size) {
c0d00d50:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00d52:	b091      	sub	sp, #68	; 0x44
    while (size > 0) {
c0d00d54:	2900      	cmp	r1, #0
c0d00d56:	d01a      	beq.n	c0d00d8e <prints+0x3e>
c0d00d58:	460c      	mov	r4, r1
c0d00d5a:	4605      	mov	r5, r0
c0d00d5c:	b2a6      	uxth	r6, r4
        uint8_t written = MIN(sizeof(buf) - 1, size);
c0d00d5e:	2e3f      	cmp	r6, #63	; 0x3f
c0d00d60:	9600      	str	r6, [sp, #0]
c0d00d62:	d300      	bcc.n	c0d00d66 <prints+0x16>
c0d00d64:	263f      	movs	r6, #63	; 0x3f
c0d00d66:	af01      	add	r7, sp, #4
        memcpy(buf, str, written);
c0d00d68:	4638      	mov	r0, r7
c0d00d6a:	4629      	mov	r1, r5
c0d00d6c:	4632      	mov	r2, r6
c0d00d6e:	f000 fa3c 	bl	c0d011ea <__aeabi_memcpy>
c0d00d72:	2000      	movs	r0, #0
        buf[written] = 0;
c0d00d74:	55b8      	strb	r0, [r7, r6]
    asm volatile(
c0d00d76:	2004      	movs	r0, #4
c0d00d78:	0039      	movs	r1, r7
c0d00d7a:	dfab      	svc	171	; 0xab
c0d00d7c:	9a00      	ldr	r2, [sp, #0]
c0d00d7e:	4296      	cmp	r6, r2
c0d00d80:	da00      	bge.n	c0d00d84 <prints+0x34>
c0d00d82:	19ad      	adds	r5, r5, r6
        if (written >= size) {
c0d00d84:	1ba4      	subs	r4, r4, r6
    while (size > 0) {
c0d00d86:	0420      	lsls	r0, r4, #16
c0d00d88:	d001      	beq.n	c0d00d8e <prints+0x3e>
c0d00d8a:	4296      	cmp	r6, r2
c0d00d8c:	dbe6      	blt.n	c0d00d5c <prints+0xc>
}
c0d00d8e:	b011      	add	sp, #68	; 0x44
c0d00d90:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d00d92 <SVC_Call>:
.thumb
.thumb_func
.global SVC_Call

SVC_Call:
    svc 1
c0d00d92:	df01      	svc	1
    cmp r1, #0
c0d00d94:	2900      	cmp	r1, #0
    bne exception
c0d00d96:	d100      	bne.n	c0d00d9a <exception>
    bx lr
c0d00d98:	4770      	bx	lr

c0d00d9a <exception>:
exception:
    // THROW(ex);
    mov r0, r1
c0d00d9a:	4608      	mov	r0, r1
    bl os_longjmp
c0d00d9c:	f7ff fe1b 	bl	c0d009d6 <os_longjmp>

c0d00da0 <get_api_level>:
#include <string.h>

unsigned int SVC_Call(unsigned int syscall_id, void *parameters);
unsigned int SVC_cx_call(unsigned int syscall_id, unsigned int * parameters);

unsigned int get_api_level(void) {
c0d00da0:	b580      	push	{r7, lr}
c0d00da2:	b084      	sub	sp, #16
c0d00da4:	2000      	movs	r0, #0
  unsigned int parameters [2+1];
  parameters[0] = 0;
  parameters[1] = 0;
c0d00da6:	9002      	str	r0, [sp, #8]
  parameters[0] = 0;
c0d00da8:	9001      	str	r0, [sp, #4]
c0d00daa:	4803      	ldr	r0, [pc, #12]	; (c0d00db8 <get_api_level+0x18>)
c0d00dac:	a901      	add	r1, sp, #4
  return SVC_Call(SYSCALL_get_api_level_ID_IN, parameters);
c0d00dae:	f7ff fff0 	bl	c0d00d92 <SVC_Call>
c0d00db2:	b004      	add	sp, #16
c0d00db4:	bd80      	pop	{r7, pc}
c0d00db6:	46c0      	nop			; (mov r8, r8)
c0d00db8:	60000138 	.word	0x60000138

c0d00dbc <os_lib_call>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_ux_result_ID_IN, parameters);
  return;
}

void os_lib_call ( unsigned int * call_parameters ) {
c0d00dbc:	b580      	push	{r7, lr}
c0d00dbe:	b084      	sub	sp, #16
c0d00dc0:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)call_parameters;
  parameters[1] = 0;
c0d00dc2:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)call_parameters;
c0d00dc4:	9001      	str	r0, [sp, #4]
c0d00dc6:	4803      	ldr	r0, [pc, #12]	; (c0d00dd4 <os_lib_call+0x18>)
c0d00dc8:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_lib_call_ID_IN, parameters);
c0d00dca:	f7ff ffe2 	bl	c0d00d92 <SVC_Call>
  return;
}
c0d00dce:	b004      	add	sp, #16
c0d00dd0:	bd80      	pop	{r7, pc}
c0d00dd2:	46c0      	nop			; (mov r8, r8)
c0d00dd4:	6000670d 	.word	0x6000670d

c0d00dd8 <os_lib_end>:

void os_lib_end ( void ) {
c0d00dd8:	b580      	push	{r7, lr}
c0d00dda:	b082      	sub	sp, #8
c0d00ddc:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d00dde:	9001      	str	r0, [sp, #4]
c0d00de0:	4802      	ldr	r0, [pc, #8]	; (c0d00dec <os_lib_end+0x14>)
c0d00de2:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_os_lib_end_ID_IN, parameters);
c0d00de4:	f7ff ffd5 	bl	c0d00d92 <SVC_Call>
  return;
}
c0d00de8:	b002      	add	sp, #8
c0d00dea:	bd80      	pop	{r7, pc}
c0d00dec:	6000688d 	.word	0x6000688d

c0d00df0 <os_sched_exit>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_exec_ID_IN, parameters);
  return;
}

void os_sched_exit ( bolos_task_status_t exit_code ) {
c0d00df0:	b580      	push	{r7, lr}
c0d00df2:	b084      	sub	sp, #16
c0d00df4:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)exit_code;
  parameters[1] = 0;
c0d00df6:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)exit_code;
c0d00df8:	9001      	str	r0, [sp, #4]
c0d00dfa:	4803      	ldr	r0, [pc, #12]	; (c0d00e08 <os_sched_exit+0x18>)
c0d00dfc:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0d00dfe:	f7ff ffc8 	bl	c0d00d92 <SVC_Call>
  return;
}
c0d00e02:	b004      	add	sp, #16
c0d00e04:	bd80      	pop	{r7, pc}
c0d00e06:	46c0      	nop			; (mov r8, r8)
c0d00e08:	60009abe 	.word	0x60009abe

c0d00e0c <try_context_get>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_nvm_erase_page_ID_IN, parameters);
  return;
}

try_context_t * try_context_get ( void ) {
c0d00e0c:	b580      	push	{r7, lr}
c0d00e0e:	b082      	sub	sp, #8
c0d00e10:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d00e12:	9001      	str	r0, [sp, #4]
c0d00e14:	4802      	ldr	r0, [pc, #8]	; (c0d00e20 <try_context_get+0x14>)
c0d00e16:	4669      	mov	r1, sp
  return (try_context_t *) SVC_Call(SYSCALL_try_context_get_ID_IN, parameters);
c0d00e18:	f7ff ffbb 	bl	c0d00d92 <SVC_Call>
c0d00e1c:	b002      	add	sp, #8
c0d00e1e:	bd80      	pop	{r7, pc}
c0d00e20:	600087b1 	.word	0x600087b1

c0d00e24 <try_context_set>:
}

try_context_t * try_context_set ( try_context_t *context ) {
c0d00e24:	b580      	push	{r7, lr}
c0d00e26:	b084      	sub	sp, #16
c0d00e28:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)context;
  parameters[1] = 0;
c0d00e2a:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)context;
c0d00e2c:	9001      	str	r0, [sp, #4]
c0d00e2e:	4803      	ldr	r0, [pc, #12]	; (c0d00e3c <try_context_set+0x18>)
c0d00e30:	a901      	add	r1, sp, #4
  return (try_context_t *) SVC_Call(SYSCALL_try_context_set_ID_IN, parameters);
c0d00e32:	f7ff ffae 	bl	c0d00d92 <SVC_Call>
c0d00e36:	b004      	add	sp, #16
c0d00e38:	bd80      	pop	{r7, pc}
c0d00e3a:	46c0      	nop			; (mov r8, r8)
c0d00e3c:	60010b06 	.word	0x60010b06

c0d00e40 <__udivsi3>:
c0d00e40:	2200      	movs	r2, #0
c0d00e42:	0843      	lsrs	r3, r0, #1
c0d00e44:	428b      	cmp	r3, r1
c0d00e46:	d374      	bcc.n	c0d00f32 <__udivsi3+0xf2>
c0d00e48:	0903      	lsrs	r3, r0, #4
c0d00e4a:	428b      	cmp	r3, r1
c0d00e4c:	d35f      	bcc.n	c0d00f0e <__udivsi3+0xce>
c0d00e4e:	0a03      	lsrs	r3, r0, #8
c0d00e50:	428b      	cmp	r3, r1
c0d00e52:	d344      	bcc.n	c0d00ede <__udivsi3+0x9e>
c0d00e54:	0b03      	lsrs	r3, r0, #12
c0d00e56:	428b      	cmp	r3, r1
c0d00e58:	d328      	bcc.n	c0d00eac <__udivsi3+0x6c>
c0d00e5a:	0c03      	lsrs	r3, r0, #16
c0d00e5c:	428b      	cmp	r3, r1
c0d00e5e:	d30d      	bcc.n	c0d00e7c <__udivsi3+0x3c>
c0d00e60:	22ff      	movs	r2, #255	; 0xff
c0d00e62:	0209      	lsls	r1, r1, #8
c0d00e64:	ba12      	rev	r2, r2
c0d00e66:	0c03      	lsrs	r3, r0, #16
c0d00e68:	428b      	cmp	r3, r1
c0d00e6a:	d302      	bcc.n	c0d00e72 <__udivsi3+0x32>
c0d00e6c:	1212      	asrs	r2, r2, #8
c0d00e6e:	0209      	lsls	r1, r1, #8
c0d00e70:	d065      	beq.n	c0d00f3e <__udivsi3+0xfe>
c0d00e72:	0b03      	lsrs	r3, r0, #12
c0d00e74:	428b      	cmp	r3, r1
c0d00e76:	d319      	bcc.n	c0d00eac <__udivsi3+0x6c>
c0d00e78:	e000      	b.n	c0d00e7c <__udivsi3+0x3c>
c0d00e7a:	0a09      	lsrs	r1, r1, #8
c0d00e7c:	0bc3      	lsrs	r3, r0, #15
c0d00e7e:	428b      	cmp	r3, r1
c0d00e80:	d301      	bcc.n	c0d00e86 <__udivsi3+0x46>
c0d00e82:	03cb      	lsls	r3, r1, #15
c0d00e84:	1ac0      	subs	r0, r0, r3
c0d00e86:	4152      	adcs	r2, r2
c0d00e88:	0b83      	lsrs	r3, r0, #14
c0d00e8a:	428b      	cmp	r3, r1
c0d00e8c:	d301      	bcc.n	c0d00e92 <__udivsi3+0x52>
c0d00e8e:	038b      	lsls	r3, r1, #14
c0d00e90:	1ac0      	subs	r0, r0, r3
c0d00e92:	4152      	adcs	r2, r2
c0d00e94:	0b43      	lsrs	r3, r0, #13
c0d00e96:	428b      	cmp	r3, r1
c0d00e98:	d301      	bcc.n	c0d00e9e <__udivsi3+0x5e>
c0d00e9a:	034b      	lsls	r3, r1, #13
c0d00e9c:	1ac0      	subs	r0, r0, r3
c0d00e9e:	4152      	adcs	r2, r2
c0d00ea0:	0b03      	lsrs	r3, r0, #12
c0d00ea2:	428b      	cmp	r3, r1
c0d00ea4:	d301      	bcc.n	c0d00eaa <__udivsi3+0x6a>
c0d00ea6:	030b      	lsls	r3, r1, #12
c0d00ea8:	1ac0      	subs	r0, r0, r3
c0d00eaa:	4152      	adcs	r2, r2
c0d00eac:	0ac3      	lsrs	r3, r0, #11
c0d00eae:	428b      	cmp	r3, r1
c0d00eb0:	d301      	bcc.n	c0d00eb6 <__udivsi3+0x76>
c0d00eb2:	02cb      	lsls	r3, r1, #11
c0d00eb4:	1ac0      	subs	r0, r0, r3
c0d00eb6:	4152      	adcs	r2, r2
c0d00eb8:	0a83      	lsrs	r3, r0, #10
c0d00eba:	428b      	cmp	r3, r1
c0d00ebc:	d301      	bcc.n	c0d00ec2 <__udivsi3+0x82>
c0d00ebe:	028b      	lsls	r3, r1, #10
c0d00ec0:	1ac0      	subs	r0, r0, r3
c0d00ec2:	4152      	adcs	r2, r2
c0d00ec4:	0a43      	lsrs	r3, r0, #9
c0d00ec6:	428b      	cmp	r3, r1
c0d00ec8:	d301      	bcc.n	c0d00ece <__udivsi3+0x8e>
c0d00eca:	024b      	lsls	r3, r1, #9
c0d00ecc:	1ac0      	subs	r0, r0, r3
c0d00ece:	4152      	adcs	r2, r2
c0d00ed0:	0a03      	lsrs	r3, r0, #8
c0d00ed2:	428b      	cmp	r3, r1
c0d00ed4:	d301      	bcc.n	c0d00eda <__udivsi3+0x9a>
c0d00ed6:	020b      	lsls	r3, r1, #8
c0d00ed8:	1ac0      	subs	r0, r0, r3
c0d00eda:	4152      	adcs	r2, r2
c0d00edc:	d2cd      	bcs.n	c0d00e7a <__udivsi3+0x3a>
c0d00ede:	09c3      	lsrs	r3, r0, #7
c0d00ee0:	428b      	cmp	r3, r1
c0d00ee2:	d301      	bcc.n	c0d00ee8 <__udivsi3+0xa8>
c0d00ee4:	01cb      	lsls	r3, r1, #7
c0d00ee6:	1ac0      	subs	r0, r0, r3
c0d00ee8:	4152      	adcs	r2, r2
c0d00eea:	0983      	lsrs	r3, r0, #6
c0d00eec:	428b      	cmp	r3, r1
c0d00eee:	d301      	bcc.n	c0d00ef4 <__udivsi3+0xb4>
c0d00ef0:	018b      	lsls	r3, r1, #6
c0d00ef2:	1ac0      	subs	r0, r0, r3
c0d00ef4:	4152      	adcs	r2, r2
c0d00ef6:	0943      	lsrs	r3, r0, #5
c0d00ef8:	428b      	cmp	r3, r1
c0d00efa:	d301      	bcc.n	c0d00f00 <__udivsi3+0xc0>
c0d00efc:	014b      	lsls	r3, r1, #5
c0d00efe:	1ac0      	subs	r0, r0, r3
c0d00f00:	4152      	adcs	r2, r2
c0d00f02:	0903      	lsrs	r3, r0, #4
c0d00f04:	428b      	cmp	r3, r1
c0d00f06:	d301      	bcc.n	c0d00f0c <__udivsi3+0xcc>
c0d00f08:	010b      	lsls	r3, r1, #4
c0d00f0a:	1ac0      	subs	r0, r0, r3
c0d00f0c:	4152      	adcs	r2, r2
c0d00f0e:	08c3      	lsrs	r3, r0, #3
c0d00f10:	428b      	cmp	r3, r1
c0d00f12:	d301      	bcc.n	c0d00f18 <__udivsi3+0xd8>
c0d00f14:	00cb      	lsls	r3, r1, #3
c0d00f16:	1ac0      	subs	r0, r0, r3
c0d00f18:	4152      	adcs	r2, r2
c0d00f1a:	0883      	lsrs	r3, r0, #2
c0d00f1c:	428b      	cmp	r3, r1
c0d00f1e:	d301      	bcc.n	c0d00f24 <__udivsi3+0xe4>
c0d00f20:	008b      	lsls	r3, r1, #2
c0d00f22:	1ac0      	subs	r0, r0, r3
c0d00f24:	4152      	adcs	r2, r2
c0d00f26:	0843      	lsrs	r3, r0, #1
c0d00f28:	428b      	cmp	r3, r1
c0d00f2a:	d301      	bcc.n	c0d00f30 <__udivsi3+0xf0>
c0d00f2c:	004b      	lsls	r3, r1, #1
c0d00f2e:	1ac0      	subs	r0, r0, r3
c0d00f30:	4152      	adcs	r2, r2
c0d00f32:	1a41      	subs	r1, r0, r1
c0d00f34:	d200      	bcs.n	c0d00f38 <__udivsi3+0xf8>
c0d00f36:	4601      	mov	r1, r0
c0d00f38:	4152      	adcs	r2, r2
c0d00f3a:	4610      	mov	r0, r2
c0d00f3c:	4770      	bx	lr
c0d00f3e:	e7ff      	b.n	c0d00f40 <__udivsi3+0x100>
c0d00f40:	b501      	push	{r0, lr}
c0d00f42:	2000      	movs	r0, #0
c0d00f44:	f000 f806 	bl	c0d00f54 <__aeabi_idiv0>
c0d00f48:	bd02      	pop	{r1, pc}
c0d00f4a:	46c0      	nop			; (mov r8, r8)

c0d00f4c <__aeabi_uidivmod>:
c0d00f4c:	2900      	cmp	r1, #0
c0d00f4e:	d0f7      	beq.n	c0d00f40 <__udivsi3+0x100>
c0d00f50:	e776      	b.n	c0d00e40 <__udivsi3>
c0d00f52:	4770      	bx	lr

c0d00f54 <__aeabi_idiv0>:
c0d00f54:	4770      	bx	lr
c0d00f56:	46c0      	nop			; (mov r8, r8)

c0d00f58 <__aeabi_uldivmod>:
c0d00f58:	2b00      	cmp	r3, #0
c0d00f5a:	d111      	bne.n	c0d00f80 <__aeabi_uldivmod+0x28>
c0d00f5c:	2a00      	cmp	r2, #0
c0d00f5e:	d10f      	bne.n	c0d00f80 <__aeabi_uldivmod+0x28>
c0d00f60:	2900      	cmp	r1, #0
c0d00f62:	d100      	bne.n	c0d00f66 <__aeabi_uldivmod+0xe>
c0d00f64:	2800      	cmp	r0, #0
c0d00f66:	d002      	beq.n	c0d00f6e <__aeabi_uldivmod+0x16>
c0d00f68:	2100      	movs	r1, #0
c0d00f6a:	43c9      	mvns	r1, r1
c0d00f6c:	0008      	movs	r0, r1
c0d00f6e:	b407      	push	{r0, r1, r2}
c0d00f70:	4802      	ldr	r0, [pc, #8]	; (c0d00f7c <__aeabi_uldivmod+0x24>)
c0d00f72:	a102      	add	r1, pc, #8	; (adr r1, c0d00f7c <__aeabi_uldivmod+0x24>)
c0d00f74:	1840      	adds	r0, r0, r1
c0d00f76:	9002      	str	r0, [sp, #8]
c0d00f78:	bd03      	pop	{r0, r1, pc}
c0d00f7a:	46c0      	nop			; (mov r8, r8)
c0d00f7c:	ffffffd9 	.word	0xffffffd9
c0d00f80:	b403      	push	{r0, r1}
c0d00f82:	4668      	mov	r0, sp
c0d00f84:	b501      	push	{r0, lr}
c0d00f86:	9802      	ldr	r0, [sp, #8]
c0d00f88:	f000 f834 	bl	c0d00ff4 <__udivmoddi4>
c0d00f8c:	9b01      	ldr	r3, [sp, #4]
c0d00f8e:	469e      	mov	lr, r3
c0d00f90:	b002      	add	sp, #8
c0d00f92:	bc0c      	pop	{r2, r3}
c0d00f94:	4770      	bx	lr
c0d00f96:	46c0      	nop			; (mov r8, r8)

c0d00f98 <__aeabi_lmul>:
c0d00f98:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00f9a:	46ce      	mov	lr, r9
c0d00f9c:	4647      	mov	r7, r8
c0d00f9e:	b580      	push	{r7, lr}
c0d00fa0:	0007      	movs	r7, r0
c0d00fa2:	4699      	mov	r9, r3
c0d00fa4:	0c3b      	lsrs	r3, r7, #16
c0d00fa6:	469c      	mov	ip, r3
c0d00fa8:	0413      	lsls	r3, r2, #16
c0d00faa:	0c1b      	lsrs	r3, r3, #16
c0d00fac:	001d      	movs	r5, r3
c0d00fae:	000e      	movs	r6, r1
c0d00fb0:	4661      	mov	r1, ip
c0d00fb2:	0400      	lsls	r0, r0, #16
c0d00fb4:	0c14      	lsrs	r4, r2, #16
c0d00fb6:	0c00      	lsrs	r0, r0, #16
c0d00fb8:	4345      	muls	r5, r0
c0d00fba:	434b      	muls	r3, r1
c0d00fbc:	4360      	muls	r0, r4
c0d00fbe:	4361      	muls	r1, r4
c0d00fc0:	18c0      	adds	r0, r0, r3
c0d00fc2:	0c2c      	lsrs	r4, r5, #16
c0d00fc4:	1820      	adds	r0, r4, r0
c0d00fc6:	468c      	mov	ip, r1
c0d00fc8:	4283      	cmp	r3, r0
c0d00fca:	d903      	bls.n	c0d00fd4 <__aeabi_lmul+0x3c>
c0d00fcc:	2380      	movs	r3, #128	; 0x80
c0d00fce:	025b      	lsls	r3, r3, #9
c0d00fd0:	4698      	mov	r8, r3
c0d00fd2:	44c4      	add	ip, r8
c0d00fd4:	4649      	mov	r1, r9
c0d00fd6:	4379      	muls	r1, r7
c0d00fd8:	4372      	muls	r2, r6
c0d00fda:	0c03      	lsrs	r3, r0, #16
c0d00fdc:	4463      	add	r3, ip
c0d00fde:	042d      	lsls	r5, r5, #16
c0d00fe0:	0c2d      	lsrs	r5, r5, #16
c0d00fe2:	18c9      	adds	r1, r1, r3
c0d00fe4:	0400      	lsls	r0, r0, #16
c0d00fe6:	1940      	adds	r0, r0, r5
c0d00fe8:	1889      	adds	r1, r1, r2
c0d00fea:	bcc0      	pop	{r6, r7}
c0d00fec:	46b9      	mov	r9, r7
c0d00fee:	46b0      	mov	r8, r6
c0d00ff0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00ff2:	46c0      	nop			; (mov r8, r8)

c0d00ff4 <__udivmoddi4>:
c0d00ff4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00ff6:	4657      	mov	r7, sl
c0d00ff8:	464e      	mov	r6, r9
c0d00ffa:	4645      	mov	r5, r8
c0d00ffc:	46de      	mov	lr, fp
c0d00ffe:	b5e0      	push	{r5, r6, r7, lr}
c0d01000:	0004      	movs	r4, r0
c0d01002:	000d      	movs	r5, r1
c0d01004:	4692      	mov	sl, r2
c0d01006:	4699      	mov	r9, r3
c0d01008:	b083      	sub	sp, #12
c0d0100a:	428b      	cmp	r3, r1
c0d0100c:	d830      	bhi.n	c0d01070 <__udivmoddi4+0x7c>
c0d0100e:	d02d      	beq.n	c0d0106c <__udivmoddi4+0x78>
c0d01010:	4649      	mov	r1, r9
c0d01012:	4650      	mov	r0, sl
c0d01014:	f000 f8ba 	bl	c0d0118c <__clzdi2>
c0d01018:	0029      	movs	r1, r5
c0d0101a:	0006      	movs	r6, r0
c0d0101c:	0020      	movs	r0, r4
c0d0101e:	f000 f8b5 	bl	c0d0118c <__clzdi2>
c0d01022:	1a33      	subs	r3, r6, r0
c0d01024:	4698      	mov	r8, r3
c0d01026:	3b20      	subs	r3, #32
c0d01028:	469b      	mov	fp, r3
c0d0102a:	d433      	bmi.n	c0d01094 <__udivmoddi4+0xa0>
c0d0102c:	465a      	mov	r2, fp
c0d0102e:	4653      	mov	r3, sl
c0d01030:	4093      	lsls	r3, r2
c0d01032:	4642      	mov	r2, r8
c0d01034:	001f      	movs	r7, r3
c0d01036:	4653      	mov	r3, sl
c0d01038:	4093      	lsls	r3, r2
c0d0103a:	001e      	movs	r6, r3
c0d0103c:	42af      	cmp	r7, r5
c0d0103e:	d83a      	bhi.n	c0d010b6 <__udivmoddi4+0xc2>
c0d01040:	42af      	cmp	r7, r5
c0d01042:	d100      	bne.n	c0d01046 <__udivmoddi4+0x52>
c0d01044:	e078      	b.n	c0d01138 <__udivmoddi4+0x144>
c0d01046:	465b      	mov	r3, fp
c0d01048:	1ba4      	subs	r4, r4, r6
c0d0104a:	41bd      	sbcs	r5, r7
c0d0104c:	2b00      	cmp	r3, #0
c0d0104e:	da00      	bge.n	c0d01052 <__udivmoddi4+0x5e>
c0d01050:	e075      	b.n	c0d0113e <__udivmoddi4+0x14a>
c0d01052:	2200      	movs	r2, #0
c0d01054:	2300      	movs	r3, #0
c0d01056:	9200      	str	r2, [sp, #0]
c0d01058:	9301      	str	r3, [sp, #4]
c0d0105a:	2301      	movs	r3, #1
c0d0105c:	465a      	mov	r2, fp
c0d0105e:	4093      	lsls	r3, r2
c0d01060:	9301      	str	r3, [sp, #4]
c0d01062:	2301      	movs	r3, #1
c0d01064:	4642      	mov	r2, r8
c0d01066:	4093      	lsls	r3, r2
c0d01068:	9300      	str	r3, [sp, #0]
c0d0106a:	e028      	b.n	c0d010be <__udivmoddi4+0xca>
c0d0106c:	4282      	cmp	r2, r0
c0d0106e:	d9cf      	bls.n	c0d01010 <__udivmoddi4+0x1c>
c0d01070:	2200      	movs	r2, #0
c0d01072:	2300      	movs	r3, #0
c0d01074:	9200      	str	r2, [sp, #0]
c0d01076:	9301      	str	r3, [sp, #4]
c0d01078:	9b0c      	ldr	r3, [sp, #48]	; 0x30
c0d0107a:	2b00      	cmp	r3, #0
c0d0107c:	d001      	beq.n	c0d01082 <__udivmoddi4+0x8e>
c0d0107e:	601c      	str	r4, [r3, #0]
c0d01080:	605d      	str	r5, [r3, #4]
c0d01082:	9800      	ldr	r0, [sp, #0]
c0d01084:	9901      	ldr	r1, [sp, #4]
c0d01086:	b003      	add	sp, #12
c0d01088:	bcf0      	pop	{r4, r5, r6, r7}
c0d0108a:	46bb      	mov	fp, r7
c0d0108c:	46b2      	mov	sl, r6
c0d0108e:	46a9      	mov	r9, r5
c0d01090:	46a0      	mov	r8, r4
c0d01092:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01094:	4642      	mov	r2, r8
c0d01096:	2320      	movs	r3, #32
c0d01098:	1a9b      	subs	r3, r3, r2
c0d0109a:	4652      	mov	r2, sl
c0d0109c:	40da      	lsrs	r2, r3
c0d0109e:	4641      	mov	r1, r8
c0d010a0:	0013      	movs	r3, r2
c0d010a2:	464a      	mov	r2, r9
c0d010a4:	408a      	lsls	r2, r1
c0d010a6:	0017      	movs	r7, r2
c0d010a8:	4642      	mov	r2, r8
c0d010aa:	431f      	orrs	r7, r3
c0d010ac:	4653      	mov	r3, sl
c0d010ae:	4093      	lsls	r3, r2
c0d010b0:	001e      	movs	r6, r3
c0d010b2:	42af      	cmp	r7, r5
c0d010b4:	d9c4      	bls.n	c0d01040 <__udivmoddi4+0x4c>
c0d010b6:	2200      	movs	r2, #0
c0d010b8:	2300      	movs	r3, #0
c0d010ba:	9200      	str	r2, [sp, #0]
c0d010bc:	9301      	str	r3, [sp, #4]
c0d010be:	4643      	mov	r3, r8
c0d010c0:	2b00      	cmp	r3, #0
c0d010c2:	d0d9      	beq.n	c0d01078 <__udivmoddi4+0x84>
c0d010c4:	07fb      	lsls	r3, r7, #31
c0d010c6:	0872      	lsrs	r2, r6, #1
c0d010c8:	431a      	orrs	r2, r3
c0d010ca:	4646      	mov	r6, r8
c0d010cc:	087b      	lsrs	r3, r7, #1
c0d010ce:	e00e      	b.n	c0d010ee <__udivmoddi4+0xfa>
c0d010d0:	42ab      	cmp	r3, r5
c0d010d2:	d101      	bne.n	c0d010d8 <__udivmoddi4+0xe4>
c0d010d4:	42a2      	cmp	r2, r4
c0d010d6:	d80c      	bhi.n	c0d010f2 <__udivmoddi4+0xfe>
c0d010d8:	1aa4      	subs	r4, r4, r2
c0d010da:	419d      	sbcs	r5, r3
c0d010dc:	2001      	movs	r0, #1
c0d010de:	1924      	adds	r4, r4, r4
c0d010e0:	416d      	adcs	r5, r5
c0d010e2:	2100      	movs	r1, #0
c0d010e4:	3e01      	subs	r6, #1
c0d010e6:	1824      	adds	r4, r4, r0
c0d010e8:	414d      	adcs	r5, r1
c0d010ea:	2e00      	cmp	r6, #0
c0d010ec:	d006      	beq.n	c0d010fc <__udivmoddi4+0x108>
c0d010ee:	42ab      	cmp	r3, r5
c0d010f0:	d9ee      	bls.n	c0d010d0 <__udivmoddi4+0xdc>
c0d010f2:	3e01      	subs	r6, #1
c0d010f4:	1924      	adds	r4, r4, r4
c0d010f6:	416d      	adcs	r5, r5
c0d010f8:	2e00      	cmp	r6, #0
c0d010fa:	d1f8      	bne.n	c0d010ee <__udivmoddi4+0xfa>
c0d010fc:	9800      	ldr	r0, [sp, #0]
c0d010fe:	9901      	ldr	r1, [sp, #4]
c0d01100:	465b      	mov	r3, fp
c0d01102:	1900      	adds	r0, r0, r4
c0d01104:	4169      	adcs	r1, r5
c0d01106:	2b00      	cmp	r3, #0
c0d01108:	db24      	blt.n	c0d01154 <__udivmoddi4+0x160>
c0d0110a:	002b      	movs	r3, r5
c0d0110c:	465a      	mov	r2, fp
c0d0110e:	4644      	mov	r4, r8
c0d01110:	40d3      	lsrs	r3, r2
c0d01112:	002a      	movs	r2, r5
c0d01114:	40e2      	lsrs	r2, r4
c0d01116:	001c      	movs	r4, r3
c0d01118:	465b      	mov	r3, fp
c0d0111a:	0015      	movs	r5, r2
c0d0111c:	2b00      	cmp	r3, #0
c0d0111e:	db2a      	blt.n	c0d01176 <__udivmoddi4+0x182>
c0d01120:	0026      	movs	r6, r4
c0d01122:	409e      	lsls	r6, r3
c0d01124:	0033      	movs	r3, r6
c0d01126:	0026      	movs	r6, r4
c0d01128:	4647      	mov	r7, r8
c0d0112a:	40be      	lsls	r6, r7
c0d0112c:	0032      	movs	r2, r6
c0d0112e:	1a80      	subs	r0, r0, r2
c0d01130:	4199      	sbcs	r1, r3
c0d01132:	9000      	str	r0, [sp, #0]
c0d01134:	9101      	str	r1, [sp, #4]
c0d01136:	e79f      	b.n	c0d01078 <__udivmoddi4+0x84>
c0d01138:	42a3      	cmp	r3, r4
c0d0113a:	d8bc      	bhi.n	c0d010b6 <__udivmoddi4+0xc2>
c0d0113c:	e783      	b.n	c0d01046 <__udivmoddi4+0x52>
c0d0113e:	4642      	mov	r2, r8
c0d01140:	2320      	movs	r3, #32
c0d01142:	2100      	movs	r1, #0
c0d01144:	1a9b      	subs	r3, r3, r2
c0d01146:	2200      	movs	r2, #0
c0d01148:	9100      	str	r1, [sp, #0]
c0d0114a:	9201      	str	r2, [sp, #4]
c0d0114c:	2201      	movs	r2, #1
c0d0114e:	40da      	lsrs	r2, r3
c0d01150:	9201      	str	r2, [sp, #4]
c0d01152:	e786      	b.n	c0d01062 <__udivmoddi4+0x6e>
c0d01154:	4642      	mov	r2, r8
c0d01156:	2320      	movs	r3, #32
c0d01158:	1a9b      	subs	r3, r3, r2
c0d0115a:	002a      	movs	r2, r5
c0d0115c:	4646      	mov	r6, r8
c0d0115e:	409a      	lsls	r2, r3
c0d01160:	0023      	movs	r3, r4
c0d01162:	40f3      	lsrs	r3, r6
c0d01164:	4644      	mov	r4, r8
c0d01166:	4313      	orrs	r3, r2
c0d01168:	002a      	movs	r2, r5
c0d0116a:	40e2      	lsrs	r2, r4
c0d0116c:	001c      	movs	r4, r3
c0d0116e:	465b      	mov	r3, fp
c0d01170:	0015      	movs	r5, r2
c0d01172:	2b00      	cmp	r3, #0
c0d01174:	dad4      	bge.n	c0d01120 <__udivmoddi4+0x12c>
c0d01176:	4642      	mov	r2, r8
c0d01178:	002f      	movs	r7, r5
c0d0117a:	2320      	movs	r3, #32
c0d0117c:	0026      	movs	r6, r4
c0d0117e:	4097      	lsls	r7, r2
c0d01180:	1a9b      	subs	r3, r3, r2
c0d01182:	40de      	lsrs	r6, r3
c0d01184:	003b      	movs	r3, r7
c0d01186:	4333      	orrs	r3, r6
c0d01188:	e7cd      	b.n	c0d01126 <__udivmoddi4+0x132>
c0d0118a:	46c0      	nop			; (mov r8, r8)

c0d0118c <__clzdi2>:
c0d0118c:	b510      	push	{r4, lr}
c0d0118e:	2900      	cmp	r1, #0
c0d01190:	d103      	bne.n	c0d0119a <__clzdi2+0xe>
c0d01192:	f000 f807 	bl	c0d011a4 <__clzsi2>
c0d01196:	3020      	adds	r0, #32
c0d01198:	e002      	b.n	c0d011a0 <__clzdi2+0x14>
c0d0119a:	0008      	movs	r0, r1
c0d0119c:	f000 f802 	bl	c0d011a4 <__clzsi2>
c0d011a0:	bd10      	pop	{r4, pc}
c0d011a2:	46c0      	nop			; (mov r8, r8)

c0d011a4 <__clzsi2>:
c0d011a4:	211c      	movs	r1, #28
c0d011a6:	2301      	movs	r3, #1
c0d011a8:	041b      	lsls	r3, r3, #16
c0d011aa:	4298      	cmp	r0, r3
c0d011ac:	d301      	bcc.n	c0d011b2 <__clzsi2+0xe>
c0d011ae:	0c00      	lsrs	r0, r0, #16
c0d011b0:	3910      	subs	r1, #16
c0d011b2:	0a1b      	lsrs	r3, r3, #8
c0d011b4:	4298      	cmp	r0, r3
c0d011b6:	d301      	bcc.n	c0d011bc <__clzsi2+0x18>
c0d011b8:	0a00      	lsrs	r0, r0, #8
c0d011ba:	3908      	subs	r1, #8
c0d011bc:	091b      	lsrs	r3, r3, #4
c0d011be:	4298      	cmp	r0, r3
c0d011c0:	d301      	bcc.n	c0d011c6 <__clzsi2+0x22>
c0d011c2:	0900      	lsrs	r0, r0, #4
c0d011c4:	3904      	subs	r1, #4
c0d011c6:	a202      	add	r2, pc, #8	; (adr r2, c0d011d0 <__clzsi2+0x2c>)
c0d011c8:	5c10      	ldrb	r0, [r2, r0]
c0d011ca:	1840      	adds	r0, r0, r1
c0d011cc:	4770      	bx	lr
c0d011ce:	46c0      	nop			; (mov r8, r8)
c0d011d0:	02020304 	.word	0x02020304
c0d011d4:	01010101 	.word	0x01010101
	...

c0d011e0 <__aeabi_memclr>:
c0d011e0:	b510      	push	{r4, lr}
c0d011e2:	2200      	movs	r2, #0
c0d011e4:	f000 f809 	bl	c0d011fa <__aeabi_memset>
c0d011e8:	bd10      	pop	{r4, pc}

c0d011ea <__aeabi_memcpy>:
c0d011ea:	b510      	push	{r4, lr}
c0d011ec:	f000 f81a 	bl	c0d01224 <memcpy>
c0d011f0:	bd10      	pop	{r4, pc}

c0d011f2 <__aeabi_memmove>:
c0d011f2:	b510      	push	{r4, lr}
c0d011f4:	f000 f81f 	bl	c0d01236 <memmove>
c0d011f8:	bd10      	pop	{r4, pc}

c0d011fa <__aeabi_memset>:
c0d011fa:	000b      	movs	r3, r1
c0d011fc:	b510      	push	{r4, lr}
c0d011fe:	0011      	movs	r1, r2
c0d01200:	001a      	movs	r2, r3
c0d01202:	f000 f82b 	bl	c0d0125c <memset>
c0d01206:	bd10      	pop	{r4, pc}

c0d01208 <memcmp>:
c0d01208:	b530      	push	{r4, r5, lr}
c0d0120a:	2400      	movs	r4, #0
c0d0120c:	3901      	subs	r1, #1
c0d0120e:	42a2      	cmp	r2, r4
c0d01210:	d101      	bne.n	c0d01216 <memcmp+0xe>
c0d01212:	2000      	movs	r0, #0
c0d01214:	e005      	b.n	c0d01222 <memcmp+0x1a>
c0d01216:	5d03      	ldrb	r3, [r0, r4]
c0d01218:	3401      	adds	r4, #1
c0d0121a:	5d0d      	ldrb	r5, [r1, r4]
c0d0121c:	42ab      	cmp	r3, r5
c0d0121e:	d0f6      	beq.n	c0d0120e <memcmp+0x6>
c0d01220:	1b58      	subs	r0, r3, r5
c0d01222:	bd30      	pop	{r4, r5, pc}

c0d01224 <memcpy>:
c0d01224:	2300      	movs	r3, #0
c0d01226:	b510      	push	{r4, lr}
c0d01228:	429a      	cmp	r2, r3
c0d0122a:	d100      	bne.n	c0d0122e <memcpy+0xa>
c0d0122c:	bd10      	pop	{r4, pc}
c0d0122e:	5ccc      	ldrb	r4, [r1, r3]
c0d01230:	54c4      	strb	r4, [r0, r3]
c0d01232:	3301      	adds	r3, #1
c0d01234:	e7f8      	b.n	c0d01228 <memcpy+0x4>

c0d01236 <memmove>:
c0d01236:	b510      	push	{r4, lr}
c0d01238:	4288      	cmp	r0, r1
c0d0123a:	d902      	bls.n	c0d01242 <memmove+0xc>
c0d0123c:	188b      	adds	r3, r1, r2
c0d0123e:	4298      	cmp	r0, r3
c0d01240:	d303      	bcc.n	c0d0124a <memmove+0x14>
c0d01242:	2300      	movs	r3, #0
c0d01244:	e007      	b.n	c0d01256 <memmove+0x20>
c0d01246:	5c8b      	ldrb	r3, [r1, r2]
c0d01248:	5483      	strb	r3, [r0, r2]
c0d0124a:	3a01      	subs	r2, #1
c0d0124c:	d2fb      	bcs.n	c0d01246 <memmove+0x10>
c0d0124e:	bd10      	pop	{r4, pc}
c0d01250:	5ccc      	ldrb	r4, [r1, r3]
c0d01252:	54c4      	strb	r4, [r0, r3]
c0d01254:	3301      	adds	r3, #1
c0d01256:	429a      	cmp	r2, r3
c0d01258:	d1fa      	bne.n	c0d01250 <memmove+0x1a>
c0d0125a:	e7f8      	b.n	c0d0124e <memmove+0x18>

c0d0125c <memset>:
c0d0125c:	0003      	movs	r3, r0
c0d0125e:	1882      	adds	r2, r0, r2
c0d01260:	4293      	cmp	r3, r2
c0d01262:	d100      	bne.n	c0d01266 <memset+0xa>
c0d01264:	4770      	bx	lr
c0d01266:	7019      	strb	r1, [r3, #0]
c0d01268:	3301      	adds	r3, #1
c0d0126a:	e7f9      	b.n	c0d01260 <memset+0x4>

c0d0126c <setjmp>:
c0d0126c:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0d0126e:	4641      	mov	r1, r8
c0d01270:	464a      	mov	r2, r9
c0d01272:	4653      	mov	r3, sl
c0d01274:	465c      	mov	r4, fp
c0d01276:	466d      	mov	r5, sp
c0d01278:	4676      	mov	r6, lr
c0d0127a:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0d0127c:	3828      	subs	r0, #40	; 0x28
c0d0127e:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d01280:	2000      	movs	r0, #0
c0d01282:	4770      	bx	lr

c0d01284 <longjmp>:
c0d01284:	3010      	adds	r0, #16
c0d01286:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0d01288:	4690      	mov	r8, r2
c0d0128a:	4699      	mov	r9, r3
c0d0128c:	46a2      	mov	sl, r4
c0d0128e:	46ab      	mov	fp, r5
c0d01290:	46b5      	mov	sp, r6
c0d01292:	c808      	ldmia	r0!, {r3}
c0d01294:	3828      	subs	r0, #40	; 0x28
c0d01296:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d01298:	1c08      	adds	r0, r1, #0
c0d0129a:	d100      	bne.n	c0d0129e <longjmp+0x1a>
c0d0129c:	2001      	movs	r0, #1
c0d0129e:	4718      	bx	r3

c0d012a0 <strlcat>:
c0d012a0:	b570      	push	{r4, r5, r6, lr}
c0d012a2:	0004      	movs	r4, r0
c0d012a4:	0008      	movs	r0, r1
c0d012a6:	0023      	movs	r3, r4
c0d012a8:	18a5      	adds	r5, r4, r2
c0d012aa:	42ab      	cmp	r3, r5
c0d012ac:	d10a      	bne.n	c0d012c4 <strlcat+0x24>
c0d012ae:	1b1c      	subs	r4, r3, r4
c0d012b0:	1b15      	subs	r5, r2, r4
c0d012b2:	42a2      	cmp	r2, r4
c0d012b4:	d00b      	beq.n	c0d012ce <strlcat+0x2e>
c0d012b6:	0002      	movs	r2, r0
c0d012b8:	7811      	ldrb	r1, [r2, #0]
c0d012ba:	2900      	cmp	r1, #0
c0d012bc:	d10b      	bne.n	c0d012d6 <strlcat+0x36>
c0d012be:	7019      	strb	r1, [r3, #0]
c0d012c0:	1a10      	subs	r0, r2, r0
c0d012c2:	e006      	b.n	c0d012d2 <strlcat+0x32>
c0d012c4:	7819      	ldrb	r1, [r3, #0]
c0d012c6:	2900      	cmp	r1, #0
c0d012c8:	d0f1      	beq.n	c0d012ae <strlcat+0xe>
c0d012ca:	3301      	adds	r3, #1
c0d012cc:	e7ed      	b.n	c0d012aa <strlcat+0xa>
c0d012ce:	f000 f82f 	bl	c0d01330 <strlen>
c0d012d2:	1900      	adds	r0, r0, r4
c0d012d4:	bd70      	pop	{r4, r5, r6, pc}
c0d012d6:	2d01      	cmp	r5, #1
c0d012d8:	d002      	beq.n	c0d012e0 <strlcat+0x40>
c0d012da:	7019      	strb	r1, [r3, #0]
c0d012dc:	3d01      	subs	r5, #1
c0d012de:	3301      	adds	r3, #1
c0d012e0:	3201      	adds	r2, #1
c0d012e2:	e7e9      	b.n	c0d012b8 <strlcat+0x18>

c0d012e4 <strlcpy>:
c0d012e4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d012e6:	0005      	movs	r5, r0
c0d012e8:	2a00      	cmp	r2, #0
c0d012ea:	d014      	beq.n	c0d01316 <strlcpy+0x32>
c0d012ec:	1e50      	subs	r0, r2, #1
c0d012ee:	2a01      	cmp	r2, #1
c0d012f0:	d01c      	beq.n	c0d0132c <strlcpy+0x48>
c0d012f2:	002c      	movs	r4, r5
c0d012f4:	000a      	movs	r2, r1
c0d012f6:	0016      	movs	r6, r2
c0d012f8:	0027      	movs	r7, r4
c0d012fa:	7836      	ldrb	r6, [r6, #0]
c0d012fc:	3201      	adds	r2, #1
c0d012fe:	3401      	adds	r4, #1
c0d01300:	0013      	movs	r3, r2
c0d01302:	0025      	movs	r5, r4
c0d01304:	703e      	strb	r6, [r7, #0]
c0d01306:	2e00      	cmp	r6, #0
c0d01308:	d00d      	beq.n	c0d01326 <strlcpy+0x42>
c0d0130a:	3801      	subs	r0, #1
c0d0130c:	2800      	cmp	r0, #0
c0d0130e:	d1f2      	bne.n	c0d012f6 <strlcpy+0x12>
c0d01310:	2200      	movs	r2, #0
c0d01312:	702a      	strb	r2, [r5, #0]
c0d01314:	e000      	b.n	c0d01318 <strlcpy+0x34>
c0d01316:	000b      	movs	r3, r1
c0d01318:	001a      	movs	r2, r3
c0d0131a:	3201      	adds	r2, #1
c0d0131c:	1e50      	subs	r0, r2, #1
c0d0131e:	7800      	ldrb	r0, [r0, #0]
c0d01320:	0013      	movs	r3, r2
c0d01322:	2800      	cmp	r0, #0
c0d01324:	d1f9      	bne.n	c0d0131a <strlcpy+0x36>
c0d01326:	1a58      	subs	r0, r3, r1
c0d01328:	3801      	subs	r0, #1
c0d0132a:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0132c:	000b      	movs	r3, r1
c0d0132e:	e7ef      	b.n	c0d01310 <strlcpy+0x2c>

c0d01330 <strlen>:
c0d01330:	2300      	movs	r3, #0
c0d01332:	5cc2      	ldrb	r2, [r0, r3]
c0d01334:	3301      	adds	r3, #1
c0d01336:	2a00      	cmp	r2, #0
c0d01338:	d1fb      	bne.n	c0d01332 <strlen+0x2>
c0d0133a:	1e58      	subs	r0, r3, #1
c0d0133c:	4770      	bx	lr

c0d0133e <strnlen>:
c0d0133e:	0003      	movs	r3, r0
c0d01340:	1841      	adds	r1, r0, r1
c0d01342:	428b      	cmp	r3, r1
c0d01344:	d002      	beq.n	c0d0134c <strnlen+0xe>
c0d01346:	781a      	ldrb	r2, [r3, #0]
c0d01348:	2a00      	cmp	r2, #0
c0d0134a:	d101      	bne.n	c0d01350 <strnlen+0x12>
c0d0134c:	1a18      	subs	r0, r3, r0
c0d0134e:	4770      	bx	lr
c0d01350:	3301      	adds	r3, #1
c0d01352:	e7f6      	b.n	c0d01342 <strnlen+0x4>
c0d01354:	7830      	.short	0x7830
	...

c0d01357 <HEXDIGITS>:
c0d01357:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef
c0d01367:	4500 5252 524f 3000 5000 756c 6967 206e     .ERROR.0.Plugin 
c0d01377:	6170 6172 656d 6574 7372 7320 7274 6375     parameters struc
c0d01387:	7574 6572 6920 2073 6962 6767 7265 7420     ture is bigger t
c0d01397:	6168 206e 6c61 6f6c 6577 2064 6973 657a     han allowed size
c0d013a7:	000a 4550 5a4e 204f 4e49 4320 4552 5441     ..PENZO IN CREAT
c0d013b7:	0a45 2500 0073 736d 2d67 703e 7261 6d61     E..%s.msg->param
c0d013c7:	7465 7265 664f 7366 7465 203a 6425 000a     eterOffset: %d..
c0d013d7:	3455 4542 6d20 6773 3e2d 6170 6172 656d     U4BE msg->parame
c0d013e7:	6574 3a72 2520 0a64 6300 706f 6569 2064     ter: %d..copied 
c0d013f7:	666f 7366 7465 203a 6425 000a 6c70 6775     offset: %d..plug
c0d01407:	6e69 7020 6f72 6976 6564 7020 7261 6d61     in provide param
c0d01417:	7465 7265 203a 666f 7366 7465 2520 0a64     eter: offset %d.
c0d01427:	7942 6574 3a73 1b20 305b 333b 6d31 2520     Bytes: .[0;31m %
c0d01437:	2a2e 2048 5b1b 6d30 0a20 5300 6c65 6365     .*H .[0m ..Selec
c0d01447:	6f74 2072 6e49 6564 2078 6f6e 2074 7573     tor Index not su
c0d01457:	7070 726f 6574 3a64 2520 0a64 5000 5241     pported: %d..PAR
c0d01467:	4953 474e 4320 4552 5441 0a45 4300 4552     SING CREATE..CRE
c0d01477:	5441 5f45 545f 4b4f 4e45 495f 0a44 4300     ATE__TOKEN_ID..C
c0d01487:	4552 5441 5f45 4f5f 4646 4553 5f54 4142     REATE__OFFSET_BA
c0d01497:	4354 4948 504e 5455 524f 4544 0a52 4300     TCHINPUTORDER..C
c0d014a7:	4552 5441 5f45 4c5f 4e45 425f 5441 4843     REATE__LEN_BATCH
c0d014b7:	4e49 5550 4f54 4452 5245 000a 7563 7272     INPUTORDER..curr
c0d014c7:	6e65 5f74 656c 676e 6874 203a 6425 000a     ent_length: %d..
c0d014d7:	5243 4145 4554 5f5f 464f 5346 5445 415f     CREATE__OFFSET_A
c0d014e7:	5252 5941 425f 5441 4843 4e49 5550 4f54     RRAY_BATCHINPUTO
c0d014f7:	4452 5245 202c 6e69 6564 3a78 2520 0a64     RDER, index: %d.
c0d01507:	6f00 6666 6573 7374 6c5f 6c76 5b30 6425     .offsets_lvl0[%d
c0d01517:	3a5d 2520 0a64 4e00 504f 4e20 504f 4320     ]: %d..NOP NOP C
c0d01527:	4552 5441 5f45 425f 5441 4843 495f 504e     REATE__BATCH_INP
c0d01537:	5455 4f5f 4452 5245 0a53 5000 7261 6d61     UT_ORDERS..Param
c0d01547:	6e20 746f 7320 7075 6f70 7472 6465 203a      not supported: 
c0d01557:	6425 000a 4150 5352 4e49 2047 4942 204f     %d..PARSING BIO 
c0d01567:	7473 7065 203b 6425 000a 6170 7372 2065     step; %d..parse 
c0d01577:	4942 5f4f 495f 504e 5455 4f54 454b 0a4e     BIO__INPUTTOKEN.
c0d01587:	7000 7261 6573 4220 4f49 5f5f 4d41 554f     .parse BIO__AMOU
c0d01597:	544e 000a 6170 7372 2065 4942 5f4f 4f5f     NT..parse BIO__O
c0d015a7:	4646 4553 5f54 524f 4544 5352 000a 6170     FFSET_ORDERS..pa
c0d015b7:	7372 2065 4942 5f4f 465f 4f52 5f4d 4552     rse BIO__FROM_RE
c0d015c7:	4553 5652 0a45 7000 7261 6573 4220 4f49     SERVE..parse BIO
c0d015d7:	5f5f 454c 5f4e 524f 4544 5352 000a 6170     __LEN_ORDERS..pa
c0d015e7:	7372 2065 4942 5f4f 4f5f 4646 4553 5f54     rse BIO__OFFSET_
c0d015f7:	5241 4152 5f59 524f 4544 5352 202c 6e69     ARRAY_ORDERS, in
c0d01607:	6564 3a78 2520 0a64 6f00 6666 6573 7374     dex: %d..offsets
c0d01617:	6c5f 6c76 5b31 6425 3a5d 2520 0a64 7000     _lvl1[%d]: %d..p
c0d01627:	7261 6573 4220 4f49 5f5f 464f 5346 5445     arse BIO__OFFSET
c0d01637:	415f 5252 5941 4f5f 4452 5245 2053 414c     _ARRAY_ORDERS LA
c0d01647:	5453 000a 4150 5352 4e49 2047 524f 4544     ST..PARSING ORDE
c0d01657:	0a52 7000 7261 6573 4f20 4452 5245 5f5f     R..parse ORDER__
c0d01667:	504f 5245 5441 524f 000a 454e 2057 7563     OPERATOR..NEW cu
c0d01677:	7272 6e65 5f74 7574 6c70 5f65 666f 7366     rrent_tuple_offs
c0d01687:	7465 203a 6425 000a 6170 7372 2065 524f     et: %d..parse OR
c0d01697:	4544 5f52 545f 4b4f 4e45 415f 4444 4552     DER__TOKEN_ADDRE
c0d016a7:	5353 000a 6170 7372 2065 524f 4544 5f52     SS..parse ORDER_
c0d016b7:	4f5f 4646 4553 5f54 4143 4c4c 4144 4154     _OFFSET_CALLDATA
c0d016c7:	000a 6170 7372 2065 524f 4544 5f52 4c5f     ..parse ORDER__L
c0d016d7:	4e45 435f 4c41 444c 5441 0a41 7000 7261     EN_CALLDATA..par
c0d016e7:	6573 4f20 4452 5245 5f5f 4143 4c4c 4144     se ORDER__CALLDA
c0d016f7:	4154 000a 4550 5a4e 204f 7469 6d65 0a31     TA..PENZO item1.
c0d01707:	5000 4e45 4f5a 6e20 206f 7469 6d65 0a31     .PENZO no item1.
c0d01717:	4e00 7365 6574 0064 7243 6165 6574 5300     .Nested.Create.S
c0d01727:	6c65 6365 6f74 2072 6e69 6564 3a78 2520     elector index: %
c0d01737:	2064 6f6e 2074 7573 7070 726f 6574 0a64     d not supported.
c0d01747:	5200 6365 6965 6576 2064 6e61 6920 766e     .Received an inv
c0d01757:	6c61 6469 7320 7263 6565 496e 646e 7865     alid screenIndex
c0d01767:	000a 6553 646e 4500 4854 0020 6552 6563     ..Send.ETH .Rece
c0d01777:	7669 2065 694d 2e6e 4200 6e65 6665 6369     ive Min..Benefic
c0d01787:	6169 7972 5500 686e 6e61 6c64 6465 6d20     iary.Unhandled m
c0d01797:	7365 6173 6567 2520 0a64 4500 6874 7265     essage %d..Ether
c0d017a7:	7565 006d                                   eum.

c0d017ab <g_pcHex>:
c0d017ab:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef

c0d017bb <g_pcHex_cap>:
c0d017bb:	3130 3332 3534 3736 3938 4241 4443 4645     0123456789ABCDEF
	...

c0d017cc <NESTED_SELECTORS>:
c0d017cc:	534b a378                                   KSx.

c0d017d0 <_etext>:
	...
