
bin/app.elf:     file format elf32-littlearm


Disassembly of section .text:

c0d00000 <main>:
    libcall_params[2] = RUN_APPLICATION;
    os_lib_call((unsigned int *) &libcall_params);
}

// Weird low-level black magic. No need to edit this.
__attribute__((section(".boot"))) int main(int arg0) {
c0d00000:	b5b0      	push	{r4, r5, r7, lr}
c0d00002:	b090      	sub	sp, #64	; 0x40
c0d00004:	4604      	mov	r4, r0
    // Exit critical section
    __asm volatile("cpsie i");
c0d00006:	b662      	cpsie	i

    // Ensure exception will work as planned
    os_boot();
c0d00008:	f000 fabe 	bl	c0d00588 <os_boot>
c0d0000c:	ad01      	add	r5, sp, #4

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY {
        TRY {
c0d0000e:	4628      	mov	r0, r5
c0d00010:	f000 fdcf 	bl	c0d00bb2 <setjmp>
c0d00014:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0d00016:	0400      	lsls	r0, r0, #16
c0d00018:	d117      	bne.n	c0d0004a <main+0x4a>
c0d0001a:	a801      	add	r0, sp, #4
c0d0001c:	f000 fce0 	bl	c0d009e0 <try_context_set>
c0d00020:	900b      	str	r0, [sp, #44]	; 0x2c
// get API level
SYSCALL unsigned int get_api_level(void);

#ifndef HAVE_BOLOS
static inline void check_api_level(unsigned int apiLevel) {
  if (apiLevel < get_api_level()) {
c0d00022:	f000 fc9b 	bl	c0d0095c <get_api_level>
c0d00026:	280d      	cmp	r0, #13
c0d00028:	d302      	bcc.n	c0d00030 <main+0x30>
c0d0002a:	20ff      	movs	r0, #255	; 0xff
    os_sched_exit(-1);
c0d0002c:	f000 fcbe 	bl	c0d009ac <os_sched_exit>
c0d00030:	2001      	movs	r0, #1
c0d00032:	0201      	lsls	r1, r0, #8
            // Low-level black magic.
            check_api_level(CX_COMPAT_APILEVEL);

            // Check if we are called from the dashboard.
            if (!arg0) {
c0d00034:	2c00      	cmp	r4, #0
c0d00036:	d017      	beq.n	c0d00068 <main+0x68>
                // Not called from dashboard: called from the ethereum app!
                const unsigned int *args = (const unsigned int *) arg0;

                // If `ETH_PLUGIN_CHECK_PRESENCE` is set, this means the caller is just trying to
                // know whether this app exists or not. We can skip `dispatch_plugin_calls`.
                if (args[0] != ETH_PLUGIN_CHECK_PRESENCE) {
c0d00038:	6820      	ldr	r0, [r4, #0]
c0d0003a:	31ff      	adds	r1, #255	; 0xff
c0d0003c:	4288      	cmp	r0, r1
c0d0003e:	d002      	beq.n	c0d00046 <main+0x46>
                    dispatch_plugin_calls(args[0], (void *) args[1]);
c0d00040:	6861      	ldr	r1, [r4, #4]
c0d00042:	f000 fa65 	bl	c0d00510 <dispatch_plugin_calls>
                }

                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
c0d00046:	f000 fca5 	bl	c0d00994 <os_lib_end>
            }
        }
        FINALLY {
c0d0004a:	f000 fcbd 	bl	c0d009c8 <try_context_get>
c0d0004e:	a901      	add	r1, sp, #4
c0d00050:	4288      	cmp	r0, r1
c0d00052:	d102      	bne.n	c0d0005a <main+0x5a>
c0d00054:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d00056:	f000 fcc3 	bl	c0d009e0 <try_context_set>
c0d0005a:	a801      	add	r0, sp, #4
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
    libcall_params[0] = (unsigned int) "Ethereum";
c0d0006c:	4804      	ldr	r0, [pc, #16]	; (c0d00080 <main+0x80>)
c0d0006e:	4478      	add	r0, pc
c0d00070:	900d      	str	r0, [sp, #52]	; 0x34
c0d00072:	a80d      	add	r0, sp, #52	; 0x34
    os_lib_call((unsigned int *) &libcall_params);
c0d00074:	f000 fc80 	bl	c0d00978 <os_lib_call>
c0d00078:	e7f3      	b.n	c0d00062 <main+0x62>
    END_TRY;
c0d0007a:	f000 fa8a 	bl	c0d00592 <os_longjmp>
c0d0007e:	46c0      	nop			; (mov r8, r8)
c0d00080:	00001024 	.word	0x00001024

c0d00084 <handle_finalize>:
#include "nested_plugin.h"

void handle_finalize(void *parameters) {
c0d00084:	2104      	movs	r1, #4

    // set `tokenLookup1` (and maybe `tokenLookup2`) to point to
    // token addresses you will info for (such as decimals, ticker...).
    msg->tokenLookup1 = context->token_received;

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d00086:	7781      	strb	r1, [r0, #30]
c0d00088:	2181      	movs	r1, #129	; 0x81
c0d0008a:	0049      	lsls	r1, r1, #1
    msg->uiType = ETH_UI_TYPE_GENERIC;
c0d0008c:	8381      	strh	r1, [r0, #28]
    context_t *context = (context_t *) msg->pluginContext;
c0d0008e:	6881      	ldr	r1, [r0, #8]
    msg->tokenLookup1 = context->token_received;
c0d00090:	3135      	adds	r1, #53	; 0x35
c0d00092:	60c1      	str	r1, [r0, #12]
}
c0d00094:	4770      	bx	lr
	...

c0d00098 <handle_init_contract>:
    }
    return -1;
}

// Called once to init.
void handle_init_contract(void *parameters) {
c0d00098:	b570      	push	{r4, r5, r6, lr}
c0d0009a:	4604      	mov	r4, r0
    // Cast the msg to the type of structure we expect (here, ethPluginInitContract_t).
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *) parameters;

    // Make sure we are running a compatible version.
    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST) {
c0d0009c:	7800      	ldrb	r0, [r0, #0]
c0d0009e:	2804      	cmp	r0, #4
c0d000a0:	d108      	bne.n	c0d000b4 <handle_init_contract+0x1c>
        return;
    }

    // Double check that the `context_t` struct is not bigger than the maximum size (defined by
    // `msg->pluginContextLength`).
    if (msg->pluginContextLength < sizeof(context_t)) {
c0d000a2:	6920      	ldr	r0, [r4, #16]
c0d000a4:	2877      	cmp	r0, #119	; 0x77
c0d000a6:	d808      	bhi.n	c0d000ba <handle_init_contract+0x22>
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
c0d000a8:	481a      	ldr	r0, [pc, #104]	; (c0d00114 <handle_init_contract+0x7c>)
c0d000aa:	4478      	add	r0, pc
c0d000ac:	f000 fa78 	bl	c0d005a0 <semihosted_printf>
c0d000b0:	2300      	movs	r3, #0
c0d000b2:	e000      	b.n	c0d000b6 <handle_init_contract+0x1e>
c0d000b4:	2301      	movs	r3, #1
c0d000b6:	7063      	strb	r3, [r4, #1]
            return;
    }

    // Return valid status.
    msg->result = ETH_PLUGIN_RESULT_OK;
}
c0d000b8:	bd70      	pop	{r4, r5, r6, pc}
    context_t *context = (context_t *) msg->pluginContext;
c0d000ba:	68e5      	ldr	r5, [r4, #12]
c0d000bc:	2178      	movs	r1, #120	; 0x78
    memset(context, 0, sizeof(*context));
c0d000be:	4628      	mov	r0, r5
c0d000c0:	f000 fd56 	bl	c0d00b70 <__aeabi_memclr>
c0d000c4:	2604      	movs	r6, #4
    context->current_tuple_offset = SELECTOR_SIZE;
c0d000c6:	662e      	str	r6, [r5, #96]	; 0x60
    uint32_t selector = U4BE(msg->selector, 0);
c0d000c8:	6960      	ldr	r0, [r4, #20]
   ((lo0)&0xFFu))
static inline uint16_t U2BE(const uint8_t *buf, size_t off) {
  return (buf[off] << 8) | buf[off + 1];
}
static inline uint32_t U4BE(const uint8_t *buf, size_t off) {
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d000ca:	7801      	ldrb	r1, [r0, #0]
c0d000cc:	0609      	lsls	r1, r1, #24
c0d000ce:	7842      	ldrb	r2, [r0, #1]
c0d000d0:	0412      	lsls	r2, r2, #16
c0d000d2:	1851      	adds	r1, r2, r1
         (buf[off + 2] << 8) | buf[off + 3];
c0d000d4:	7882      	ldrb	r2, [r0, #2]
c0d000d6:	0212      	lsls	r2, r2, #8
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d000d8:	1889      	adds	r1, r1, r2
         (buf[off + 2] << 8) | buf[off + 3];
c0d000da:	78c0      	ldrb	r0, [r0, #3]
c0d000dc:	1808      	adds	r0, r1, r0
c0d000de:	3557      	adds	r5, #87	; 0x57
c0d000e0:	2100      	movs	r1, #0
c0d000e2:	4a0d      	ldr	r2, [pc, #52]	; (c0d00118 <handle_init_contract+0x80>)
c0d000e4:	447a      	add	r2, pc
        if (selector == selectors[i]) {
c0d000e6:	008b      	lsls	r3, r1, #2
c0d000e8:	58d3      	ldr	r3, [r2, r3]
c0d000ea:	4283      	cmp	r3, r0
c0d000ec:	d004      	beq.n	c0d000f8 <handle_init_contract+0x60>
c0d000ee:	2301      	movs	r3, #1
    for (selector_t i = 0; i < n; i++) {
c0d000f0:	2900      	cmp	r1, #0
c0d000f2:	4619      	mov	r1, r3
c0d000f4:	d0f7      	beq.n	c0d000e6 <handle_init_contract+0x4e>
c0d000f6:	e7de      	b.n	c0d000b6 <handle_init_contract+0x1e>
            *out = i;
c0d000f8:	7769      	strb	r1, [r5, #29]
    switch (context->selectorIndex) {
c0d000fa:	2900      	cmp	r1, #0
c0d000fc:	d002      	beq.n	c0d00104 <handle_init_contract+0x6c>
c0d000fe:	4808      	ldr	r0, [pc, #32]	; (c0d00120 <handle_init_contract+0x88>)
c0d00100:	4478      	add	r0, pc
c0d00102:	e001      	b.n	c0d00108 <handle_init_contract+0x70>
c0d00104:	4805      	ldr	r0, [pc, #20]	; (c0d0011c <handle_init_contract+0x84>)
c0d00106:	4478      	add	r0, pc
c0d00108:	f000 fa4a 	bl	c0d005a0 <semihosted_printf>
c0d0010c:	2001      	movs	r0, #1
            context->next_param = CREATE__TOKEN_ID;
c0d0010e:	7028      	strb	r0, [r5, #0]
c0d00110:	4633      	mov	r3, r6
c0d00112:	e7d0      	b.n	c0d000b6 <handle_init_contract+0x1e>
c0d00114:	00000b84 	.word	0x00000b84
c0d00118:	00000fd8 	.word	0x00000fd8
c0d0011c:	00000b61 	.word	0x00000b61
c0d00120:	00000b72 	.word	0x00000b72

c0d00124 <copy_offset>:
#include "nested_plugin.h"

void copy_offset(ethPluginProvideParameter_t *msg, context_t *context) {
c0d00124:	b5b0      	push	{r4, r5, r7, lr}
c0d00126:	460c      	mov	r4, r1
c0d00128:	4605      	mov	r5, r0
    PRINTF("msg->parameterOffset: %d\n", msg->parameterOffset);
c0d0012a:	6901      	ldr	r1, [r0, #16]
c0d0012c:	480d      	ldr	r0, [pc, #52]	; (c0d00164 <copy_offset+0x40>)
c0d0012e:	4478      	add	r0, pc
c0d00130:	f000 fa36 	bl	c0d005a0 <semihosted_printf>
    uint32_t test = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d00134:	68e8      	ldr	r0, [r5, #12]
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d00136:	7f01      	ldrb	r1, [r0, #28]
c0d00138:	0609      	lsls	r1, r1, #24
c0d0013a:	7f42      	ldrb	r2, [r0, #29]
c0d0013c:	0412      	lsls	r2, r2, #16
c0d0013e:	1851      	adds	r1, r2, r1
         (buf[off + 2] << 8) | buf[off + 3];
c0d00140:	7f82      	ldrb	r2, [r0, #30]
c0d00142:	0212      	lsls	r2, r2, #8
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d00144:	1889      	adds	r1, r1, r2
         (buf[off + 2] << 8) | buf[off + 3];
c0d00146:	7fc0      	ldrb	r0, [r0, #31]
c0d00148:	180d      	adds	r5, r1, r0
    PRINTF("U4BE msg->parameter: %d\n", test);
c0d0014a:	4807      	ldr	r0, [pc, #28]	; (c0d00168 <copy_offset+0x44>)
c0d0014c:	4478      	add	r0, pc
c0d0014e:	4629      	mov	r1, r5
c0d00150:	f000 fa26 	bl	c0d005a0 <semihosted_printf>
    context->next_offset = test + context->current_tuple_offset;
c0d00154:	6e20      	ldr	r0, [r4, #96]	; 0x60
c0d00156:	1829      	adds	r1, r5, r0
c0d00158:	6661      	str	r1, [r4, #100]	; 0x64
    PRINTF("copied offset: %d\n", context->next_offset);
c0d0015a:	4804      	ldr	r0, [pc, #16]	; (c0d0016c <copy_offset+0x48>)
c0d0015c:	4478      	add	r0, pc
c0d0015e:	f000 fa1f 	bl	c0d005a0 <semihosted_printf>
}
c0d00162:	bdb0      	pop	{r4, r5, r7, pc}
c0d00164:	00000b5e 	.word	0x00000b5e
c0d00168:	00000b5a 	.word	0x00000b5a
c0d0016c:	00000b63 	.word	0x00000b63

c0d00170 <handle_provide_parameter>:
            break;
    }
    context->next_param++;
}

void handle_provide_parameter(void *parameters) {
c0d00170:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00172:	b081      	sub	sp, #4
c0d00174:	4605      	mov	r5, r0
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;
c0d00176:	6884      	ldr	r4, [r0, #8]
    // the number of bytes you wish to print (in this case, `PARAMETER_LENGTH`) and then
    // the address (here `msg->parameter`).
    PRINTF("plugin provide parameter: offset %d\nBytes: \033[0;31m %.*H \033[0m \n",
           msg->parameterOffset,
           PARAMETER_LENGTH,
           msg->parameter);
c0d00178:	68c3      	ldr	r3, [r0, #12]
           msg->parameterOffset,
c0d0017a:	6901      	ldr	r1, [r0, #16]
    PRINTF("plugin provide parameter: offset %d\nBytes: \033[0;31m %.*H \033[0m \n",
c0d0017c:	4886      	ldr	r0, [pc, #536]	; (c0d00398 <handle_provide_parameter+0x228>)
c0d0017e:	4478      	add	r0, pc
c0d00180:	2220      	movs	r2, #32
c0d00182:	f000 fa0d 	bl	c0d005a0 <semihosted_printf>
c0d00186:	2004      	movs	r0, #4

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d00188:	7528      	strb	r0, [r5, #20]
c0d0018a:	2074      	movs	r0, #116	; 0x74

    switch (context->selectorIndex) {
c0d0018c:	5c21      	ldrb	r1, [r4, r0]
c0d0018e:	2900      	cmp	r1, #0
c0d00190:	d006      	beq.n	c0d001a0 <handle_provide_parameter+0x30>
        case CREATE:
            handle_create(msg, context);
            break;
        default:
            PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
c0d00192:	489c      	ldr	r0, [pc, #624]	; (c0d00404 <handle_provide_parameter+0x294>)
c0d00194:	4478      	add	r0, pc
c0d00196:	f000 fa03 	bl	c0d005a0 <semihosted_printf>
c0d0019a:	2000      	movs	r0, #0
            msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d0019c:	7528      	strb	r0, [r5, #20]
c0d0019e:	e0f0      	b.n	c0d00382 <handle_provide_parameter+0x212>
c0d001a0:	4626      	mov	r6, r4
c0d001a2:	3657      	adds	r6, #87	; 0x57
c0d001a4:	4627      	mov	r7, r4
c0d001a6:	3768      	adds	r7, #104	; 0x68
    if (context->on_struct) {
c0d001a8:	7820      	ldrb	r0, [r4, #0]
c0d001aa:	2800      	cmp	r0, #0
c0d001ac:	d018      	beq.n	c0d001e0 <handle_provide_parameter+0x70>
c0d001ae:	2803      	cmp	r0, #3
c0d001b0:	d029      	beq.n	c0d00206 <handle_provide_parameter+0x96>
c0d001b2:	2801      	cmp	r0, #1
c0d001b4:	d000      	beq.n	c0d001b8 <handle_provide_parameter+0x48>
c0d001b6:	e0e4      	b.n	c0d00382 <handle_provide_parameter+0x212>
    PRINTF("PARSING BIO step; %d\n", context->next_param);
c0d001b8:	7831      	ldrb	r1, [r6, #0]
c0d001ba:	4878      	ldr	r0, [pc, #480]	; (c0d0039c <handle_provide_parameter+0x22c>)
c0d001bc:	4478      	add	r0, pc
c0d001be:	f000 f9ef 	bl	c0d005a0 <semihosted_printf>
    switch ((batch_input_orders) context->next_param) {
c0d001c2:	7830      	ldrb	r0, [r6, #0]
c0d001c4:	2802      	cmp	r0, #2
c0d001c6:	dc2f      	bgt.n	c0d00228 <handle_provide_parameter+0xb8>
c0d001c8:	2800      	cmp	r0, #0
c0d001ca:	d100      	bne.n	c0d001ce <handle_provide_parameter+0x5e>
c0d001cc:	e0b6      	b.n	c0d0033c <handle_provide_parameter+0x1cc>
c0d001ce:	2801      	cmp	r0, #1
c0d001d0:	d100      	bne.n	c0d001d4 <handle_provide_parameter+0x64>
c0d001d2:	e0ba      	b.n	c0d0034a <handle_provide_parameter+0x1da>
c0d001d4:	2802      	cmp	r0, #2
c0d001d6:	d000      	beq.n	c0d001da <handle_provide_parameter+0x6a>
c0d001d8:	e0d0      	b.n	c0d0037c <handle_provide_parameter+0x20c>
            PRINTF("parse BIO__OFFSET_ORDERS\n");
c0d001da:	4871      	ldr	r0, [pc, #452]	; (c0d003a0 <handle_provide_parameter+0x230>)
c0d001dc:	4478      	add	r0, pc
c0d001de:	e086      	b.n	c0d002ee <handle_provide_parameter+0x17e>
    PRINTF("PARSING CREATE\n");
c0d001e0:	487f      	ldr	r0, [pc, #508]	; (c0d003e0 <handle_provide_parameter+0x270>)
c0d001e2:	4478      	add	r0, pc
c0d001e4:	f000 f9dc 	bl	c0d005a0 <semihosted_printf>
    switch ((create_parameter) context->next_param) {
c0d001e8:	7831      	ldrb	r1, [r6, #0]
c0d001ea:	2902      	cmp	r1, #2
c0d001ec:	dd4b      	ble.n	c0d00286 <handle_provide_parameter+0x116>
c0d001ee:	2903      	cmp	r1, #3
c0d001f0:	d057      	beq.n	c0d002a2 <handle_provide_parameter+0x132>
c0d001f2:	2904      	cmp	r1, #4
c0d001f4:	d058      	beq.n	c0d002a8 <handle_provide_parameter+0x138>
c0d001f6:	2905      	cmp	r1, #5
c0d001f8:	d000      	beq.n	c0d001fc <handle_provide_parameter+0x8c>
c0d001fa:	e08f      	b.n	c0d0031c <handle_provide_parameter+0x1ac>
            PRINTF("NOP NOP CREATE__BATCH_INPUT_ORDERS\n");
c0d001fc:	487a      	ldr	r0, [pc, #488]	; (c0d003e8 <handle_provide_parameter+0x278>)
c0d001fe:	4478      	add	r0, pc
c0d00200:	f000 f9ce 	bl	c0d005a0 <semihosted_printf>
c0d00204:	e0bd      	b.n	c0d00382 <handle_provide_parameter+0x212>
    PRINTF("PARSING ORDER\n");
c0d00206:	486f      	ldr	r0, [pc, #444]	; (c0d003c4 <handle_provide_parameter+0x254>)
c0d00208:	4478      	add	r0, pc
c0d0020a:	f000 f9c9 	bl	c0d005a0 <semihosted_printf>
    switch ((order) context->next_param) {
c0d0020e:	7830      	ldrb	r0, [r6, #0]
c0d00210:	2801      	cmp	r0, #1
c0d00212:	dd3f      	ble.n	c0d00294 <handle_provide_parameter+0x124>
c0d00214:	2802      	cmp	r0, #2
c0d00216:	d068      	beq.n	c0d002ea <handle_provide_parameter+0x17a>
c0d00218:	2803      	cmp	r0, #3
c0d0021a:	d06f      	beq.n	c0d002fc <handle_provide_parameter+0x18c>
c0d0021c:	2804      	cmp	r0, #4
c0d0021e:	d000      	beq.n	c0d00222 <handle_provide_parameter+0xb2>
c0d00220:	e0ac      	b.n	c0d0037c <handle_provide_parameter+0x20c>
            PRINTF("parse ORDER__CALLDATA\n");
c0d00222:	486a      	ldr	r0, [pc, #424]	; (c0d003cc <handle_provide_parameter+0x25c>)
c0d00224:	4478      	add	r0, pc
c0d00226:	e095      	b.n	c0d00354 <handle_provide_parameter+0x1e4>
    switch ((batch_input_orders) context->next_param) {
c0d00228:	2803      	cmp	r0, #3
c0d0022a:	d100      	bne.n	c0d0022e <handle_provide_parameter+0xbe>
c0d0022c:	e090      	b.n	c0d00350 <handle_provide_parameter+0x1e0>
c0d0022e:	2804      	cmp	r0, #4
c0d00230:	d100      	bne.n	c0d00234 <handle_provide_parameter+0xc4>
c0d00232:	e092      	b.n	c0d0035a <handle_provide_parameter+0x1ea>
c0d00234:	2805      	cmp	r0, #5
c0d00236:	d000      	beq.n	c0d0023a <handle_provide_parameter+0xca>
c0d00238:	e0a0      	b.n	c0d0037c <handle_provide_parameter+0x20c>
            context->length_offset_array--;
c0d0023a:	7ab8      	ldrb	r0, [r7, #10]
c0d0023c:	1e40      	subs	r0, r0, #1
c0d0023e:	72b8      	strb	r0, [r7, #10]
            PRINTF("parse BIO__OFFSET_ARRAY_ORDERS, index: %d\n", context->length_offset_array);
c0d00240:	b2c1      	uxtb	r1, r0
c0d00242:	4858      	ldr	r0, [pc, #352]	; (c0d003a4 <handle_provide_parameter+0x234>)
c0d00244:	4478      	add	r0, pc
c0d00246:	f000 f9ab 	bl	c0d005a0 <semihosted_printf>
            if (context->length_offset_array < 2) {
c0d0024a:	7ab9      	ldrb	r1, [r7, #10]
c0d0024c:	2901      	cmp	r1, #1
c0d0024e:	d900      	bls.n	c0d00252 <handle_provide_parameter+0xe2>
c0d00250:	e097      	b.n	c0d00382 <handle_provide_parameter+0x212>
                context->offsets_lvl1[context->length_offset_array] =
c0d00252:	0048      	lsls	r0, r1, #1
c0d00254:	1820      	adds	r0, r4, r0
                    U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d00256:	68ea      	ldr	r2, [r5, #12]
c0d00258:	7fd3      	ldrb	r3, [r2, #31]
c0d0025a:	7f92      	ldrb	r2, [r2, #30]
c0d0025c:	0212      	lsls	r2, r2, #8
c0d0025e:	18d2      	adds	r2, r2, r3
c0d00260:	236e      	movs	r3, #110	; 0x6e
                context->offsets_lvl1[context->length_offset_array] =
c0d00262:	52c2      	strh	r2, [r0, r3]
                       context->offsets_lvl1[context->length_offset_array]);
c0d00264:	b292      	uxth	r2, r2
                PRINTF("offsets_lvl1[%d]: %d\n",
c0d00266:	4850      	ldr	r0, [pc, #320]	; (c0d003a8 <handle_provide_parameter+0x238>)
c0d00268:	4478      	add	r0, pc
c0d0026a:	f000 f999 	bl	c0d005a0 <semihosted_printf>
            if (context->length_offset_array == 0) {
c0d0026e:	7ab8      	ldrb	r0, [r7, #10]
c0d00270:	2800      	cmp	r0, #0
c0d00272:	d000      	beq.n	c0d00276 <handle_provide_parameter+0x106>
c0d00274:	e085      	b.n	c0d00382 <handle_provide_parameter+0x212>
                PRINTF("parse BIO__OFFSET_ARRAY_ORDERS LAST\n");
c0d00276:	484d      	ldr	r0, [pc, #308]	; (c0d003ac <handle_provide_parameter+0x23c>)
c0d00278:	4478      	add	r0, pc
c0d0027a:	f000 f991 	bl	c0d005a0 <semihosted_printf>
c0d0027e:	2000      	movs	r0, #0
                context->next_param = (batch_input_orders) ORDER__OPERATOR;
c0d00280:	7030      	strb	r0, [r6, #0]
c0d00282:	2003      	movs	r0, #3
c0d00284:	e02f      	b.n	c0d002e6 <handle_provide_parameter+0x176>
    switch ((create_parameter) context->next_param) {
c0d00286:	2901      	cmp	r1, #1
c0d00288:	d03b      	beq.n	c0d00302 <handle_provide_parameter+0x192>
c0d0028a:	2902      	cmp	r1, #2
c0d0028c:	d146      	bne.n	c0d0031c <handle_provide_parameter+0x1ac>
            PRINTF("CREATE__OFFSET_BATCHINPUTORDER\n");
c0d0028e:	4855      	ldr	r0, [pc, #340]	; (c0d003e4 <handle_provide_parameter+0x274>)
c0d00290:	4478      	add	r0, pc
c0d00292:	e02c      	b.n	c0d002ee <handle_provide_parameter+0x17e>
    switch ((order) context->next_param) {
c0d00294:	2800      	cmp	r0, #0
c0d00296:	d048      	beq.n	c0d0032a <handle_provide_parameter+0x1ba>
c0d00298:	2801      	cmp	r0, #1
c0d0029a:	d16f      	bne.n	c0d0037c <handle_provide_parameter+0x20c>
            PRINTF("parse ORDER__TOKEN_ADDRESS\n");
c0d0029c:	484a      	ldr	r0, [pc, #296]	; (c0d003c8 <handle_provide_parameter+0x258>)
c0d0029e:	4478      	add	r0, pc
c0d002a0:	e058      	b.n	c0d00354 <handle_provide_parameter+0x1e4>
            PRINTF("CREATE__LEN_BATCHINPUTORDER\n");
c0d002a2:	4854      	ldr	r0, [pc, #336]	; (c0d003f4 <handle_provide_parameter+0x284>)
c0d002a4:	4478      	add	r0, pc
c0d002a6:	e05a      	b.n	c0d0035e <handle_provide_parameter+0x1ee>
            context->length_offset_array--;
c0d002a8:	7ab8      	ldrb	r0, [r7, #10]
c0d002aa:	1e40      	subs	r0, r0, #1
c0d002ac:	72b8      	strb	r0, [r7, #10]
                   context->length_offset_array);
c0d002ae:	b2c1      	uxtb	r1, r0
            PRINTF("CREATE__OFFSET_ARRAY_BATCHINPUTORDER, index: %d\n",
c0d002b0:	4851      	ldr	r0, [pc, #324]	; (c0d003f8 <handle_provide_parameter+0x288>)
c0d002b2:	4478      	add	r0, pc
c0d002b4:	f000 f974 	bl	c0d005a0 <semihosted_printf>
            if (context->length_offset_array < 2) {
c0d002b8:	7ab9      	ldrb	r1, [r7, #10]
c0d002ba:	2901      	cmp	r1, #1
c0d002bc:	d861      	bhi.n	c0d00382 <handle_provide_parameter+0x212>
                context->offsets_lvl0[context->length_offset_array] =
c0d002be:	0048      	lsls	r0, r1, #1
c0d002c0:	1820      	adds	r0, r4, r0
                    U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d002c2:	68ea      	ldr	r2, [r5, #12]
c0d002c4:	7fd3      	ldrb	r3, [r2, #31]
c0d002c6:	7f92      	ldrb	r2, [r2, #30]
c0d002c8:	0212      	lsls	r2, r2, #8
c0d002ca:	18d2      	adds	r2, r2, r3
c0d002cc:	236a      	movs	r3, #106	; 0x6a
                context->offsets_lvl0[context->length_offset_array] =
c0d002ce:	52c2      	strh	r2, [r0, r3]
                       context->offsets_lvl0[context->length_offset_array]);
c0d002d0:	b292      	uxth	r2, r2
                PRINTF("offsets_lvl0[%d]: %d\n",
c0d002d2:	484a      	ldr	r0, [pc, #296]	; (c0d003fc <handle_provide_parameter+0x28c>)
c0d002d4:	4478      	add	r0, pc
c0d002d6:	f000 f963 	bl	c0d005a0 <semihosted_printf>
            if (context->length_offset_array == 0) {
c0d002da:	7ab8      	ldrb	r0, [r7, #10]
c0d002dc:	2800      	cmp	r0, #0
c0d002de:	d150      	bne.n	c0d00382 <handle_provide_parameter+0x212>
c0d002e0:	2000      	movs	r0, #0
                context->next_param = (batch_input_orders) BIO__INPUTTOKEN;
c0d002e2:	7030      	strb	r0, [r6, #0]
c0d002e4:	2001      	movs	r0, #1
c0d002e6:	7020      	strb	r0, [r4, #0]
c0d002e8:	e04b      	b.n	c0d00382 <handle_provide_parameter+0x212>
            PRINTF("parse ORDER__OFFSET_CALLDATA\n");
c0d002ea:	483b      	ldr	r0, [pc, #236]	; (c0d003d8 <handle_provide_parameter+0x268>)
c0d002ec:	4478      	add	r0, pc
c0d002ee:	f000 f957 	bl	c0d005a0 <semihosted_printf>
c0d002f2:	4628      	mov	r0, r5
c0d002f4:	4621      	mov	r1, r4
c0d002f6:	f7ff ff15 	bl	c0d00124 <copy_offset>
c0d002fa:	e03f      	b.n	c0d0037c <handle_provide_parameter+0x20c>
            PRINTF("parse ORDER__LEN_CALLDATA\n");
c0d002fc:	4837      	ldr	r0, [pc, #220]	; (c0d003dc <handle_provide_parameter+0x26c>)
c0d002fe:	4478      	add	r0, pc
c0d00300:	e028      	b.n	c0d00354 <handle_provide_parameter+0x1e4>
            PRINTF("CREATE__TOKEN_ID\n");
c0d00302:	483a      	ldr	r0, [pc, #232]	; (c0d003ec <handle_provide_parameter+0x27c>)
c0d00304:	4478      	add	r0, pc
c0d00306:	f000 f94b 	bl	c0d005a0 <semihosted_printf>
c0d0030a:	68e8      	ldr	r0, [r5, #12]
c0d0030c:	2100      	movs	r1, #0
                if (msg->parameter[i] != 0) {
c0d0030e:	5c42      	ldrb	r2, [r0, r1]
c0d00310:	2a00      	cmp	r2, #0
c0d00312:	d138      	bne.n	c0d00386 <handle_provide_parameter+0x216>
            for (uint8_t i = 0; i < PARAMETER_LENGTH; i++) {
c0d00314:	1c49      	adds	r1, r1, #1
c0d00316:	2920      	cmp	r1, #32
c0d00318:	d1f9      	bne.n	c0d0030e <handle_provide_parameter+0x19e>
c0d0031a:	e02f      	b.n	c0d0037c <handle_provide_parameter+0x20c>
            PRINTF("Param not supported: %d\n", context->next_param);
c0d0031c:	4838      	ldr	r0, [pc, #224]	; (c0d00400 <handle_provide_parameter+0x290>)
c0d0031e:	4478      	add	r0, pc
c0d00320:	f000 f93e 	bl	c0d005a0 <semihosted_printf>
c0d00324:	2000      	movs	r0, #0
            msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d00326:	7528      	strb	r0, [r5, #20]
c0d00328:	e028      	b.n	c0d0037c <handle_provide_parameter+0x20c>
            PRINTF("parse ORDER__OPERATOR\n");
c0d0032a:	4829      	ldr	r0, [pc, #164]	; (c0d003d0 <handle_provide_parameter+0x260>)
c0d0032c:	4478      	add	r0, pc
c0d0032e:	f000 f937 	bl	c0d005a0 <semihosted_printf>
            context->current_tuple_offset = msg->parameterOffset;
c0d00332:	6929      	ldr	r1, [r5, #16]
c0d00334:	6621      	str	r1, [r4, #96]	; 0x60
            PRINTF("NEW current_tuple_offset: %d\n", context->current_tuple_offset);
c0d00336:	4827      	ldr	r0, [pc, #156]	; (c0d003d4 <handle_provide_parameter+0x264>)
c0d00338:	4478      	add	r0, pc
c0d0033a:	e01d      	b.n	c0d00378 <handle_provide_parameter+0x208>
            PRINTF("parse BIO__INPUTTOKEN\n");
c0d0033c:	4820      	ldr	r0, [pc, #128]	; (c0d003c0 <handle_provide_parameter+0x250>)
c0d0033e:	4478      	add	r0, pc
c0d00340:	f000 f92e 	bl	c0d005a0 <semihosted_printf>
            context->current_tuple_offset = msg->parameterOffset;
c0d00344:	6928      	ldr	r0, [r5, #16]
c0d00346:	6620      	str	r0, [r4, #96]	; 0x60
c0d00348:	e018      	b.n	c0d0037c <handle_provide_parameter+0x20c>
            PRINTF("parse BIO__AMOUNT\n");
c0d0034a:	4819      	ldr	r0, [pc, #100]	; (c0d003b0 <handle_provide_parameter+0x240>)
c0d0034c:	4478      	add	r0, pc
c0d0034e:	e001      	b.n	c0d00354 <handle_provide_parameter+0x1e4>
            PRINTF("parse BIO__FROM_RESERVE\n");
c0d00350:	4818      	ldr	r0, [pc, #96]	; (c0d003b4 <handle_provide_parameter+0x244>)
c0d00352:	4478      	add	r0, pc
c0d00354:	f000 f924 	bl	c0d005a0 <semihosted_printf>
c0d00358:	e010      	b.n	c0d0037c <handle_provide_parameter+0x20c>
            PRINTF("parse BIO__LEN_ORDERS\n");
c0d0035a:	4817      	ldr	r0, [pc, #92]	; (c0d003b8 <handle_provide_parameter+0x248>)
c0d0035c:	4478      	add	r0, pc
c0d0035e:	f000 f91f 	bl	c0d005a0 <semihosted_printf>
c0d00362:	68e8      	ldr	r0, [r5, #12]
c0d00364:	7fc1      	ldrb	r1, [r0, #31]
c0d00366:	7f82      	ldrb	r2, [r0, #30]
c0d00368:	0212      	lsls	r2, r2, #8
c0d0036a:	1851      	adds	r1, r2, r1
c0d0036c:	8039      	strh	r1, [r7, #0]
c0d0036e:	7fc0      	ldrb	r0, [r0, #31]
c0d00370:	72b8      	strb	r0, [r7, #10]
c0d00372:	b289      	uxth	r1, r1
c0d00374:	4811      	ldr	r0, [pc, #68]	; (c0d003bc <handle_provide_parameter+0x24c>)
c0d00376:	4478      	add	r0, pc
c0d00378:	f000 f912 	bl	c0d005a0 <semihosted_printf>
c0d0037c:	7830      	ldrb	r0, [r6, #0]
c0d0037e:	1c40      	adds	r0, r0, #1
c0d00380:	7030      	strb	r0, [r6, #0]
            break;
    }
c0d00382:	b001      	add	sp, #4
c0d00384:	bdf0      	pop	{r4, r5, r6, r7, pc}
                    PRINTF("IS NOT 0\n");
c0d00386:	481a      	ldr	r0, [pc, #104]	; (c0d003f0 <handle_provide_parameter+0x280>)
c0d00388:	4478      	add	r0, pc
c0d0038a:	f000 f909 	bl	c0d005a0 <semihosted_printf>
                    context->booleans |= IS_COPY;
c0d0038e:	7af8      	ldrb	r0, [r7, #11]
c0d00390:	2101      	movs	r1, #1
c0d00392:	4301      	orrs	r1, r0
c0d00394:	72f9      	strb	r1, [r7, #11]
c0d00396:	e7f1      	b.n	c0d0037c <handle_provide_parameter+0x20c>
c0d00398:	00000b54 	.word	0x00000b54
c0d0039c:	00000c78 	.word	0x00000c78
c0d003a0:	00000c98 	.word	0x00000c98
c0d003a4:	00000c7a 	.word	0x00000c7a
c0d003a8:	00000c81 	.word	0x00000c81
c0d003ac:	00000c87 	.word	0x00000c87
c0d003b0:	00000b15 	.word	0x00000b15
c0d003b4:	00000b3c 	.word	0x00000b3c
c0d003b8:	00000b4b 	.word	0x00000b4b
c0d003bc:	00000a26 	.word	0x00000a26
c0d003c0:	00000b0c 	.word	0x00000b0c
c0d003c4:	00000d1c 	.word	0x00000d1c
c0d003c8:	00000cca 	.word	0x00000cca
c0d003cc:	00000d99 	.word	0x00000d99
c0d003d0:	00000c07 	.word	0x00000c07
c0d003d4:	00000c12 	.word	0x00000c12
c0d003d8:	00000c98 	.word	0x00000c98
c0d003dc:	00000ca4 	.word	0x00000ca4
c0d003e0:	00000b51 	.word	0x00000b51
c0d003e4:	00000acf 	.word	0x00000acf
c0d003e8:	00000bf9 	.word	0x00000bf9
c0d003ec:	00000a3f 	.word	0x00000a3f
c0d003f0:	000009cd 	.word	0x000009cd
c0d003f4:	00000adb 	.word	0x00000adb
c0d003f8:	00000afe 	.word	0x00000afe
c0d003fc:	00000b0d 	.word	0x00000b0d
c0d00400:	00000afd 	.word	0x00000afd
c0d00404:	00000b7d 	.word	0x00000b7d

c0d00408 <handle_provide_token>:
#include "nested_plugin.h"

// EDIT THIS: Adapt this function to your needs! Remember, the information for tokens are held in
// `msg->token1` and `msg->token2`. If those pointers are `NULL`, this means the ethereum app didn't
// find any info regarding the requested tokens!
void handle_provide_token(void *parameters) {
c0d00408:	b570      	push	{r4, r5, r6, lr}
c0d0040a:	4604      	mov	r4, r0
    ethPluginProvideInfo_t *msg = (ethPluginProvideInfo_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;
c0d0040c:	6885      	ldr	r5, [r0, #8]

    if (msg->item1) {
c0d0040e:	68c0      	ldr	r0, [r0, #12]
c0d00410:	462e      	mov	r6, r5
c0d00412:	3655      	adds	r6, #85	; 0x55
c0d00414:	2800      	cmp	r0, #0
c0d00416:	d00f      	beq.n	c0d00438 <handle_provide_token+0x30>
        PRINTF("PENZO item1\n");
c0d00418:	480c      	ldr	r0, [pc, #48]	; (c0d0044c <handle_provide_token+0x44>)
c0d0041a:	4478      	add	r0, pc
c0d0041c:	f000 f8c0 	bl	c0d005a0 <semihosted_printf>
        // The Ethereum App found the information for the requested token!
        // Store its decimals.
        context->decimals = msg->item1->token.decimals;
c0d00420:	68e1      	ldr	r1, [r4, #12]
c0d00422:	2034      	movs	r0, #52	; 0x34
c0d00424:	5c08      	ldrb	r0, [r1, r0]
c0d00426:	7030      	strb	r0, [r6, #0]
        // Store its ticker.
        strlcpy(context->ticker, (char *) msg->item1->token.ticker, sizeof(context->ticker));
c0d00428:	3549      	adds	r5, #73	; 0x49
c0d0042a:	3114      	adds	r1, #20
c0d0042c:	220c      	movs	r2, #12
c0d0042e:	4628      	mov	r0, r5
c0d00430:	f000 fbd9 	bl	c0d00be6 <strlcpy>
c0d00434:	2001      	movs	r0, #1
c0d00436:	e004      	b.n	c0d00442 <handle_provide_token+0x3a>

        // Keep track that we found the token.
        context->token_found = true;
    } else {
        PRINTF("PENZO no item1\n");
c0d00438:	4805      	ldr	r0, [pc, #20]	; (c0d00450 <handle_provide_token+0x48>)
c0d0043a:	4478      	add	r0, pc
c0d0043c:	f000 f8b0 	bl	c0d005a0 <semihosted_printf>
c0d00440:	2000      	movs	r0, #0
        // The Ethereum App did not manage to find the info for the requested token.
        context->token_found = false;
c0d00442:	7070      	strb	r0, [r6, #1]
c0d00444:	2004      	movs	r0, #4
        // If we wanted to add a screen, say a warning screen for example, we could instruct the
        // ethereum app to add an additional screen by setting `msg->additionalScreens` here, just
        // like so:
        // msg->additionalScreens = 1;
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
c0d00446:	7560      	strb	r0, [r4, #21]
c0d00448:	bd70      	pop	{r4, r5, r6, pc}
c0d0044a:	46c0      	nop			; (mov r8, r8)
c0d0044c:	00000bba 	.word	0x00000bba
c0d00450:	00000ba7 	.word	0x00000ba7

c0d00454 <handle_query_contract_id>:
#include "nested_plugin.h"
#include "text.h"

// Sets the first screen to display.
void handle_query_contract_id(void *parameters) {
c0d00454:	b5b0      	push	{r4, r5, r7, lr}
c0d00456:	4604      	mov	r4, r0
    ethQueryContractID_t *msg = (ethQueryContractID_t *) parameters;
    const context_t *context = (const context_t *) msg->pluginContext;
c0d00458:	6885      	ldr	r5, [r0, #8]
    // msg->name will be the upper sentence displayed on the screen.
    // msg->version will be the lower sentence displayed on the screen.

    // For the first screen, display the plugin name.
    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);
c0d0045a:	68c0      	ldr	r0, [r0, #12]
c0d0045c:	6922      	ldr	r2, [r4, #16]
c0d0045e:	4912      	ldr	r1, [pc, #72]	; (c0d004a8 <handle_query_contract_id+0x54>)
c0d00460:	4479      	add	r1, pc
c0d00462:	f000 fbc0 	bl	c0d00be6 <strlcpy>
c0d00466:	2074      	movs	r0, #116	; 0x74

    if (context->selectorIndex == CREATE) {
c0d00468:	5c29      	ldrb	r1, [r5, r0]
c0d0046a:	2900      	cmp	r1, #0
c0d0046c:	d005      	beq.n	c0d0047a <handle_query_contract_id+0x26>
            strlcpy(msg->version, "Copy", msg->versionLength);
        else
            strlcpy(msg->version, "Create", msg->versionLength);
        msg->result = ETH_PLUGIN_RESULT_OK;
    } else {
        PRINTF("Selector index: %d not supported\n", context->selectorIndex);
c0d0046e:	4812      	ldr	r0, [pc, #72]	; (c0d004b8 <handle_query_contract_id+0x64>)
c0d00470:	4478      	add	r0, pc
c0d00472:	f000 f895 	bl	c0d005a0 <semihosted_printf>
c0d00476:	2000      	movs	r0, #0
c0d00478:	e014      	b.n	c0d004a4 <handle_query_contract_id+0x50>
c0d0047a:	3573      	adds	r5, #115	; 0x73
        PRINTF("context->booleans & IS_COPY: %d\n", context->booleans & IS_COPY);
c0d0047c:	7828      	ldrb	r0, [r5, #0]
c0d0047e:	2101      	movs	r1, #1
c0d00480:	4001      	ands	r1, r0
c0d00482:	480a      	ldr	r0, [pc, #40]	; (c0d004ac <handle_query_contract_id+0x58>)
c0d00484:	4478      	add	r0, pc
c0d00486:	f000 f88b 	bl	c0d005a0 <semihosted_printf>
        if (context->booleans & IS_COPY)
c0d0048a:	7828      	ldrb	r0, [r5, #0]
c0d0048c:	07c0      	lsls	r0, r0, #31
c0d0048e:	d002      	beq.n	c0d00496 <handle_query_contract_id+0x42>
c0d00490:	4908      	ldr	r1, [pc, #32]	; (c0d004b4 <handle_query_contract_id+0x60>)
c0d00492:	4479      	add	r1, pc
c0d00494:	e001      	b.n	c0d0049a <handle_query_contract_id+0x46>
c0d00496:	4906      	ldr	r1, [pc, #24]	; (c0d004b0 <handle_query_contract_id+0x5c>)
c0d00498:	4479      	add	r1, pc
c0d0049a:	6960      	ldr	r0, [r4, #20]
c0d0049c:	69a2      	ldr	r2, [r4, #24]
c0d0049e:	f000 fba2 	bl	c0d00be6 <strlcpy>
c0d004a2:	2004      	movs	r0, #4
c0d004a4:	7720      	strb	r0, [r4, #28]
        msg->result = ETH_PLUGIN_RESULT_ERROR;
    }
c0d004a6:	bdb0      	pop	{r4, r5, r7, pc}
c0d004a8:	00000b91 	.word	0x00000b91
c0d004ac:	00000b7c 	.word	0x00000b7c
c0d004b0:	00000b8e 	.word	0x00000b8e
c0d004b4:	00000b8f 	.word	0x00000b8f
c0d004b8:	00000bbd 	.word	0x00000bbd

c0d004bc <handle_query_contract_ui>:
#include "nested_plugin.h"

void handle_query_contract_ui(void *parameters) {
c0d004bc:	b5b0      	push	{r4, r5, r7, lr}
c0d004be:	4604      	mov	r4, r0

    // msg->title is the upper line displayed on the device.
    // msg->msg is the lower line displayed on the device.

    // Clean the display fields.
    memset(msg->title, 0, msg->titleLength);
c0d004c0:	6a40      	ldr	r0, [r0, #36]	; 0x24
c0d004c2:	6aa1      	ldr	r1, [r4, #40]	; 0x28
c0d004c4:	f000 fb54 	bl	c0d00b70 <__aeabi_memclr>
    memset(msg->msg, 0, msg->msgLength);
c0d004c8:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d004ca:	6b21      	ldr	r1, [r4, #48]	; 0x30
c0d004cc:	f000 fb50 	bl	c0d00b70 <__aeabi_memclr>
c0d004d0:	4625      	mov	r5, r4
c0d004d2:	3520      	adds	r5, #32
c0d004d4:	2004      	movs	r0, #4

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d004d6:	7528      	strb	r0, [r5, #20]
c0d004d8:	2020      	movs	r0, #32

    switch (msg->screenIndex) {
c0d004da:	5c20      	ldrb	r0, [r4, r0]
c0d004dc:	2800      	cmp	r0, #0
c0d004de:	d006      	beq.n	c0d004ee <handle_query_contract_ui+0x32>
            strlcpy(msg->title, "placeholder", msg->titleLength);
            strlcpy(msg->msg, "placeholder", msg->msgLength);
            break;
        // Keep this
        default:
            PRINTF("Received an invalid screenIndex\n");
c0d004e0:	480a      	ldr	r0, [pc, #40]	; (c0d0050c <handle_query_contract_ui+0x50>)
c0d004e2:	4478      	add	r0, pc
c0d004e4:	f000 f85c 	bl	c0d005a0 <semihosted_printf>
c0d004e8:	2000      	movs	r0, #0
            msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d004ea:	7528      	strb	r0, [r5, #20]
            return;
    }
}
c0d004ec:	bdb0      	pop	{r4, r5, r7, pc}
            strlcpy(msg->title, "placeholder", msg->titleLength);
c0d004ee:	6a60      	ldr	r0, [r4, #36]	; 0x24
c0d004f0:	6aa2      	ldr	r2, [r4, #40]	; 0x28
c0d004f2:	4d05      	ldr	r5, [pc, #20]	; (c0d00508 <handle_query_contract_ui+0x4c>)
c0d004f4:	447d      	add	r5, pc
c0d004f6:	4629      	mov	r1, r5
c0d004f8:	f000 fb75 	bl	c0d00be6 <strlcpy>
            strlcpy(msg->msg, "placeholder", msg->msgLength);
c0d004fc:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d004fe:	6b22      	ldr	r2, [r4, #48]	; 0x30
c0d00500:	4629      	mov	r1, r5
c0d00502:	f000 fb70 	bl	c0d00be6 <strlcpy>
}
c0d00506:	bdb0      	pop	{r4, r5, r7, pc}
c0d00508:	00000b5b 	.word	0x00000b5b
c0d0050c:	00000b79 	.word	0x00000b79

c0d00510 <dispatch_plugin_calls>:
void dispatch_plugin_calls(int message, void *parameters) {
c0d00510:	b580      	push	{r7, lr}
c0d00512:	4602      	mov	r2, r0
c0d00514:	20ff      	movs	r0, #255	; 0xff
c0d00516:	4603      	mov	r3, r0
c0d00518:	3304      	adds	r3, #4
    switch (message) {
c0d0051a:	429a      	cmp	r2, r3
c0d0051c:	dc0c      	bgt.n	c0d00538 <dispatch_plugin_calls+0x28>
c0d0051e:	3002      	adds	r0, #2
c0d00520:	4282      	cmp	r2, r0
c0d00522:	d018      	beq.n	c0d00556 <dispatch_plugin_calls+0x46>
c0d00524:	2081      	movs	r0, #129	; 0x81
c0d00526:	0040      	lsls	r0, r0, #1
c0d00528:	4282      	cmp	r2, r0
c0d0052a:	d018      	beq.n	c0d0055e <dispatch_plugin_calls+0x4e>
c0d0052c:	429a      	cmp	r2, r3
c0d0052e:	d122      	bne.n	c0d00576 <dispatch_plugin_calls+0x66>
            handle_finalize(parameters);
c0d00530:	4608      	mov	r0, r1
c0d00532:	f7ff fda7 	bl	c0d00084 <handle_finalize>
}
c0d00536:	bd80      	pop	{r7, pc}
c0d00538:	2341      	movs	r3, #65	; 0x41
c0d0053a:	009b      	lsls	r3, r3, #2
    switch (message) {
c0d0053c:	429a      	cmp	r2, r3
c0d0053e:	d012      	beq.n	c0d00566 <dispatch_plugin_calls+0x56>
c0d00540:	3006      	adds	r0, #6
c0d00542:	4282      	cmp	r2, r0
c0d00544:	d013      	beq.n	c0d0056e <dispatch_plugin_calls+0x5e>
c0d00546:	2083      	movs	r0, #131	; 0x83
c0d00548:	0040      	lsls	r0, r0, #1
c0d0054a:	4282      	cmp	r2, r0
c0d0054c:	d113      	bne.n	c0d00576 <dispatch_plugin_calls+0x66>
            handle_query_contract_ui(parameters);
c0d0054e:	4608      	mov	r0, r1
c0d00550:	f7ff ffb4 	bl	c0d004bc <handle_query_contract_ui>
}
c0d00554:	bd80      	pop	{r7, pc}
            handle_init_contract(parameters);
c0d00556:	4608      	mov	r0, r1
c0d00558:	f7ff fd9e 	bl	c0d00098 <handle_init_contract>
}
c0d0055c:	bd80      	pop	{r7, pc}
            handle_provide_parameter(parameters);
c0d0055e:	4608      	mov	r0, r1
c0d00560:	f7ff fe06 	bl	c0d00170 <handle_provide_parameter>
}
c0d00564:	bd80      	pop	{r7, pc}
            handle_provide_token(parameters);
c0d00566:	4608      	mov	r0, r1
c0d00568:	f7ff ff4e 	bl	c0d00408 <handle_provide_token>
}
c0d0056c:	bd80      	pop	{r7, pc}
            handle_query_contract_id(parameters);
c0d0056e:	4608      	mov	r0, r1
c0d00570:	f7ff ff70 	bl	c0d00454 <handle_query_contract_id>
}
c0d00574:	bd80      	pop	{r7, pc}
            PRINTF("Unhandled message %d\n", message);
c0d00576:	4803      	ldr	r0, [pc, #12]	; (c0d00584 <dispatch_plugin_calls+0x74>)
c0d00578:	4478      	add	r0, pc
c0d0057a:	4611      	mov	r1, r2
c0d0057c:	f000 f810 	bl	c0d005a0 <semihosted_printf>
}
c0d00580:	bd80      	pop	{r7, pc}
c0d00582:	46c0      	nop			; (mov r8, r8)
c0d00584:	00000b04 	.word	0x00000b04

c0d00588 <os_boot>:

// apdu buffer must hold a complete apdu to avoid troubles
unsigned char G_io_apdu_buffer[IO_APDU_BUFFER_SIZE];

#ifndef BOLOS_OS_UPGRADER_APP
void os_boot(void) {
c0d00588:	b580      	push	{r7, lr}
c0d0058a:	2000      	movs	r0, #0
  // // TODO patch entry point when romming (f)
  // // set the default try context to nothing
#ifndef HAVE_BOLOS
  try_context_set(NULL);
c0d0058c:	f000 fa28 	bl	c0d009e0 <try_context_set>
#endif // HAVE_BOLOS
}
c0d00590:	bd80      	pop	{r7, pc}

c0d00592 <os_longjmp>:
  }
  return xoracc;
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0d00592:	4604      	mov	r4, r0
#ifdef HAVE_PRINTF  
  unsigned int lr_val;
  __asm volatile("mov %0, lr" :"=r"(lr_val));
  PRINTF("exception[%d]: LR=0x%08X\n", exception, lr_val);
#endif // HAVE_PRINTF
  longjmp(try_context_get()->jmp_buf, exception);
c0d00594:	f000 fa18 	bl	c0d009c8 <try_context_get>
c0d00598:	4621      	mov	r1, r4
c0d0059a:	f000 fb16 	bl	c0d00bca <longjmp>
	...

c0d005a0 <semihosted_printf>:
    'D',
    'E',
    'F',
};

void semihosted_printf(const char *format, ...) {
c0d005a0:	b083      	sub	sp, #12
c0d005a2:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d005a4:	b09c      	sub	sp, #112	; 0x70
c0d005a6:	ac21      	add	r4, sp, #132	; 0x84
c0d005a8:	c40e      	stmia	r4!, {r1, r2, r3}
    char cStrlenSet;

    //
    // Check the arguments.
    //
    if (format == 0) {
c0d005aa:	2800      	cmp	r0, #0
c0d005ac:	d100      	bne.n	c0d005b0 <semihosted_printf+0x10>
c0d005ae:	e19e      	b.n	c0d008ee <semihosted_printf+0x34e>
c0d005b0:	4604      	mov	r4, r0
c0d005b2:	a821      	add	r0, sp, #132	; 0x84
    }

    //
    // Start the varargs processing.
    //
    va_start(vaArgP, format);
c0d005b4:	9006      	str	r0, [sp, #24]

    //
    // Loop while there are more characters in the string.
    //
    while (*format) {
c0d005b6:	7820      	ldrb	r0, [r4, #0]
c0d005b8:	2800      	cmp	r0, #0
c0d005ba:	d100      	bne.n	c0d005be <semihosted_printf+0x1e>
c0d005bc:	e197      	b.n	c0d008ee <semihosted_printf+0x34e>
c0d005be:	2600      	movs	r6, #0
        //
        // Find the first non-% character, or the end of the string.
        //
        for (ulIdx = 0; (format[ulIdx] != '%') && (format[ulIdx] != '\0'); ulIdx++) {
c0d005c0:	2800      	cmp	r0, #0
c0d005c2:	d005      	beq.n	c0d005d0 <semihosted_printf+0x30>
c0d005c4:	2825      	cmp	r0, #37	; 0x25
c0d005c6:	d003      	beq.n	c0d005d0 <semihosted_printf+0x30>
c0d005c8:	19a0      	adds	r0, r4, r6
c0d005ca:	7840      	ldrb	r0, [r0, #1]
c0d005cc:	1c76      	adds	r6, r6, #1
c0d005ce:	e7f7      	b.n	c0d005c0 <semihosted_printf+0x20>
        }

        //
        // Write this portion of the string.
        //
        prints(format, ulIdx);
c0d005d0:	b2b1      	uxth	r1, r6
c0d005d2:	4620      	mov	r0, r4
c0d005d4:	f000 f99a 	bl	c0d0090c <prints>
        format += ulIdx;

        //
        // See if the next character is a %.
        //
        if (*format == '%') {
c0d005d8:	5da0      	ldrb	r0, [r4, r6]
c0d005da:	2825      	cmp	r0, #37	; 0x25
c0d005dc:	d001      	beq.n	c0d005e2 <semihosted_printf+0x42>
c0d005de:	19a4      	adds	r4, r4, r6
c0d005e0:	e7ea      	b.n	c0d005b8 <semihosted_printf+0x18>
            ulCount = 0;
            cFill = ' ';
            ulStrlen = 0;
            cStrlenSet = 0;
            ulCap = 0;
            ulBase = 10;
c0d005e2:	19a0      	adds	r0, r4, r6
c0d005e4:	1c44      	adds	r4, r0, #1
c0d005e6:	2500      	movs	r5, #0
c0d005e8:	2020      	movs	r0, #32
c0d005ea:	9004      	str	r0, [sp, #16]
c0d005ec:	200a      	movs	r0, #10
c0d005ee:	9003      	str	r0, [sp, #12]
c0d005f0:	9505      	str	r5, [sp, #20]
c0d005f2:	462f      	mov	r7, r5
c0d005f4:	462b      	mov	r3, r5
c0d005f6:	4619      	mov	r1, r3
        again:

            //
            // Determine how to handle the next character.
            //
            switch (*format++) {
c0d005f8:	7820      	ldrb	r0, [r4, #0]
c0d005fa:	1c64      	adds	r4, r4, #1
c0d005fc:	2300      	movs	r3, #0
c0d005fe:	282d      	cmp	r0, #45	; 0x2d
c0d00600:	d0f9      	beq.n	c0d005f6 <semihosted_printf+0x56>
c0d00602:	2847      	cmp	r0, #71	; 0x47
c0d00604:	dc13      	bgt.n	c0d0062e <semihosted_printf+0x8e>
c0d00606:	282f      	cmp	r0, #47	; 0x2f
c0d00608:	dd1f      	ble.n	c0d0064a <semihosted_printf+0xaa>
c0d0060a:	4603      	mov	r3, r0
c0d0060c:	3b30      	subs	r3, #48	; 0x30
c0d0060e:	2b0a      	cmp	r3, #10
c0d00610:	d300      	bcc.n	c0d00614 <semihosted_printf+0x74>
c0d00612:	e0da      	b.n	c0d007ca <semihosted_printf+0x22a>
c0d00614:	2330      	movs	r3, #48	; 0x30
                case '9': {
                    //
                    // If this is a zero, and it is the first digit, then the
                    // fill character is a zero instead of a space.
                    //
                    if ((format[-1] == '0') && (ulCount == 0)) {
c0d00616:	4602      	mov	r2, r0
c0d00618:	405a      	eors	r2, r3
c0d0061a:	432a      	orrs	r2, r5
c0d0061c:	d000      	beq.n	c0d00620 <semihosted_printf+0x80>
c0d0061e:	9b04      	ldr	r3, [sp, #16]
c0d00620:	220a      	movs	r2, #10
                    }

                    //
                    // Update the digit count.
                    //
                    ulCount *= 10;
c0d00622:	436a      	muls	r2, r5
                    ulCount += format[-1] - '0';
c0d00624:	1815      	adds	r5, r2, r0
c0d00626:	3d30      	subs	r5, #48	; 0x30
c0d00628:	9304      	str	r3, [sp, #16]
c0d0062a:	460b      	mov	r3, r1
c0d0062c:	e7e3      	b.n	c0d005f6 <semihosted_printf+0x56>
            switch (*format++) {
c0d0062e:	2867      	cmp	r0, #103	; 0x67
c0d00630:	dd04      	ble.n	c0d0063c <semihosted_printf+0x9c>
c0d00632:	2872      	cmp	r0, #114	; 0x72
c0d00634:	dd20      	ble.n	c0d00678 <semihosted_printf+0xd8>
c0d00636:	2873      	cmp	r0, #115	; 0x73
c0d00638:	d13a      	bne.n	c0d006b0 <semihosted_printf+0x110>
c0d0063a:	e023      	b.n	c0d00684 <semihosted_printf+0xe4>
c0d0063c:	2862      	cmp	r0, #98	; 0x62
c0d0063e:	dc3d      	bgt.n	c0d006bc <semihosted_printf+0x11c>
c0d00640:	2848      	cmp	r0, #72	; 0x48
c0d00642:	d000      	beq.n	c0d00646 <semihosted_printf+0xa6>
c0d00644:	e08f      	b.n	c0d00766 <semihosted_printf+0x1c6>
c0d00646:	2701      	movs	r7, #1
c0d00648:	e01a      	b.n	c0d00680 <semihosted_printf+0xe0>
c0d0064a:	2825      	cmp	r0, #37	; 0x25
c0d0064c:	d100      	bne.n	c0d00650 <semihosted_printf+0xb0>
c0d0064e:	e099      	b.n	c0d00784 <semihosted_printf+0x1e4>
c0d00650:	282a      	cmp	r0, #42	; 0x2a
c0d00652:	d022      	beq.n	c0d0069a <semihosted_printf+0xfa>
c0d00654:	282e      	cmp	r0, #46	; 0x2e
c0d00656:	d000      	beq.n	c0d0065a <semihosted_printf+0xba>
c0d00658:	e0b7      	b.n	c0d007ca <semihosted_printf+0x22a>
                // special %.*H or %.*h format to print a given length of hex digits (case: H UPPER,
                // h lower)
                //
                case '.': {
                    // ensure next char is '*' and next one is 's'
                    if (format[0] == '*' &&
c0d0065a:	7820      	ldrb	r0, [r4, #0]
c0d0065c:	282a      	cmp	r0, #42	; 0x2a
c0d0065e:	d000      	beq.n	c0d00662 <semihosted_printf+0xc2>
c0d00660:	e0b3      	b.n	c0d007ca <semihosted_printf+0x22a>
                        (format[1] == 's' || format[1] == 'H' || format[1] == 'h')) {
c0d00662:	7861      	ldrb	r1, [r4, #1]
c0d00664:	2948      	cmp	r1, #72	; 0x48
c0d00666:	d004      	beq.n	c0d00672 <semihosted_printf+0xd2>
c0d00668:	2973      	cmp	r1, #115	; 0x73
c0d0066a:	d002      	beq.n	c0d00672 <semihosted_printf+0xd2>
c0d0066c:	2968      	cmp	r1, #104	; 0x68
c0d0066e:	d000      	beq.n	c0d00672 <semihosted_printf+0xd2>
c0d00670:	e0ab      	b.n	c0d007ca <semihosted_printf+0x22a>
c0d00672:	1c64      	adds	r4, r4, #1
c0d00674:	2301      	movs	r3, #1
c0d00676:	e015      	b.n	c0d006a4 <semihosted_printf+0x104>
            switch (*format++) {
c0d00678:	2868      	cmp	r0, #104	; 0x68
c0d0067a:	d000      	beq.n	c0d0067e <semihosted_printf+0xde>
c0d0067c:	e077      	b.n	c0d0076e <semihosted_printf+0x1ce>
c0d0067e:	2700      	movs	r7, #0
c0d00680:	2010      	movs	r0, #16
c0d00682:	9003      	str	r0, [sp, #12]
                case 's':
                case_s : {
                    //
                    // Get the string pointer from the varargs.
                    //
                    pcStr = va_arg(vaArgP, char *);
c0d00684:	9806      	ldr	r0, [sp, #24]
c0d00686:	1d02      	adds	r2, r0, #4
c0d00688:	9206      	str	r2, [sp, #24]

                    //
                    // Determine the length of the string. (if not specified using .*)
                    //
                    switch (cStrlenSet) {
c0d0068a:	b2cb      	uxtb	r3, r1
                    pcStr = va_arg(vaArgP, char *);
c0d0068c:	6802      	ldr	r2, [r0, #0]
                    switch (cStrlenSet) {
c0d0068e:	2b01      	cmp	r3, #1
c0d00690:	dd25      	ble.n	c0d006de <semihosted_printf+0x13e>
c0d00692:	2b02      	cmp	r3, #2
c0d00694:	460b      	mov	r3, r1
c0d00696:	d1ae      	bne.n	c0d005f6 <semihosted_printf+0x56>
c0d00698:	e094      	b.n	c0d007c4 <semihosted_printf+0x224>
                    if (*format == 's') {
c0d0069a:	7820      	ldrb	r0, [r4, #0]
c0d0069c:	2873      	cmp	r0, #115	; 0x73
c0d0069e:	d000      	beq.n	c0d006a2 <semihosted_printf+0x102>
c0d006a0:	e093      	b.n	c0d007ca <semihosted_printf+0x22a>
c0d006a2:	2302      	movs	r3, #2
c0d006a4:	9906      	ldr	r1, [sp, #24]
c0d006a6:	1d08      	adds	r0, r1, #4
c0d006a8:	9006      	str	r0, [sp, #24]
c0d006aa:	6808      	ldr	r0, [r1, #0]
            switch (*format++) {
c0d006ac:	9005      	str	r0, [sp, #20]
c0d006ae:	e7a2      	b.n	c0d005f6 <semihosted_printf+0x56>
c0d006b0:	2875      	cmp	r0, #117	; 0x75
c0d006b2:	d100      	bne.n	c0d006b6 <semihosted_printf+0x116>
c0d006b4:	e070      	b.n	c0d00798 <semihosted_printf+0x1f8>
c0d006b6:	2878      	cmp	r0, #120	; 0x78
c0d006b8:	d05b      	beq.n	c0d00772 <semihosted_printf+0x1d2>
c0d006ba:	e086      	b.n	c0d007ca <semihosted_printf+0x22a>
c0d006bc:	2863      	cmp	r0, #99	; 0x63
c0d006be:	d100      	bne.n	c0d006c2 <semihosted_printf+0x122>
c0d006c0:	e073      	b.n	c0d007aa <semihosted_printf+0x20a>
c0d006c2:	2864      	cmp	r0, #100	; 0x64
c0d006c4:	d000      	beq.n	c0d006c8 <semihosted_printf+0x128>
c0d006c6:	e080      	b.n	c0d007ca <semihosted_printf+0x22a>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d006c8:	9806      	ldr	r0, [sp, #24]
c0d006ca:	1d01      	adds	r1, r0, #4
c0d006cc:	9106      	str	r1, [sp, #24]
c0d006ce:	6806      	ldr	r6, [r0, #0]
c0d006d0:	960b      	str	r6, [sp, #44]	; 0x2c
c0d006d2:	200a      	movs	r0, #10
                    if ((long) ulValue < 0) {
c0d006d4:	2e00      	cmp	r6, #0
c0d006d6:	d500      	bpl.n	c0d006da <semihosted_printf+0x13a>
c0d006d8:	e085      	b.n	c0d007e6 <semihosted_printf+0x246>
c0d006da:	2100      	movs	r1, #0
c0d006dc:	e086      	b.n	c0d007ec <semihosted_printf+0x24c>
                    switch (cStrlenSet) {
c0d006de:	2b00      	cmp	r3, #0
c0d006e0:	9e05      	ldr	r6, [sp, #20]
c0d006e2:	d105      	bne.n	c0d006f0 <semihosted_printf+0x150>
c0d006e4:	2100      	movs	r1, #0
                        // compute length with strlen
                        case 0:
                            for (ulIdx = 0; pcStr[ulIdx] != '\0'; ulIdx++) {
c0d006e6:	5c50      	ldrb	r0, [r2, r1]
c0d006e8:	1c49      	adds	r1, r1, #1
c0d006ea:	2800      	cmp	r0, #0
c0d006ec:	d1fb      	bne.n	c0d006e6 <semihosted_printf+0x146>
                    }

                    //
                    // Write the string.
                    //
                    switch (ulBase) {
c0d006ee:	1e4e      	subs	r6, r1, #1
c0d006f0:	9803      	ldr	r0, [sp, #12]
c0d006f2:	2810      	cmp	r0, #16
c0d006f4:	d000      	beq.n	c0d006f8 <semihosted_printf+0x158>
c0d006f6:	e071      	b.n	c0d007dc <semihosted_printf+0x23c>
                        default:
                            prints(pcStr, ulIdx);
                            break;
                        case 16: {
                            unsigned char nibble1, nibble2;
                            for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d006f8:	2e00      	cmp	r6, #0
c0d006fa:	9702      	str	r7, [sp, #8]
c0d006fc:	d100      	bne.n	c0d00700 <semihosted_printf+0x160>
c0d006fe:	e75a      	b.n	c0d005b6 <semihosted_printf+0x16>
                                nibble1 = (pcStr[ulCount] >> 4) & 0xF;
c0d00700:	7810      	ldrb	r0, [r2, #0]
c0d00702:	230f      	movs	r3, #15
                                nibble2 = pcStr[ulCount] & 0xF;
c0d00704:	4003      	ands	r3, r0
                                nibble1 = (pcStr[ulCount] >> 4) & 0xF;
c0d00706:	0900      	lsrs	r0, r0, #4
                                switch (ulCap) {
c0d00708:	2f01      	cmp	r7, #1
c0d0070a:	d015      	beq.n	c0d00738 <semihosted_printf+0x198>
c0d0070c:	2f00      	cmp	r7, #0
c0d0070e:	d126      	bne.n	c0d0075e <semihosted_printf+0x1be>
c0d00710:	ad0c      	add	r5, sp, #48	; 0x30
c0d00712:	9605      	str	r6, [sp, #20]
c0d00714:	2600      	movs	r6, #0
    buf[1] = 0;
c0d00716:	706e      	strb	r6, [r5, #1]
                                    case 0:
                                        printc(g_pcHex[nibble1]);
c0d00718:	4f78      	ldr	r7, [pc, #480]	; (c0d008fc <semihosted_printf+0x35c>)
c0d0071a:	447f      	add	r7, pc
c0d0071c:	5c38      	ldrb	r0, [r7, r0]
    buf[0] = c;
c0d0071e:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00720:	2004      	movs	r0, #4
c0d00722:	0029      	movs	r1, r5
c0d00724:	dfab      	svc	171	; 0xab
    buf[1] = 0;
c0d00726:	706e      	strb	r6, [r5, #1]
c0d00728:	9e05      	ldr	r6, [sp, #20]
                                        printc(g_pcHex[nibble2]);
c0d0072a:	5cf8      	ldrb	r0, [r7, r3]
c0d0072c:	9f02      	ldr	r7, [sp, #8]
    buf[0] = c;
c0d0072e:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00730:	2004      	movs	r0, #4
c0d00732:	0029      	movs	r1, r5
c0d00734:	dfab      	svc	171	; 0xab
c0d00736:	e012      	b.n	c0d0075e <semihosted_printf+0x1be>
c0d00738:	ad0c      	add	r5, sp, #48	; 0x30
c0d0073a:	9605      	str	r6, [sp, #20]
c0d0073c:	2600      	movs	r6, #0
    buf[1] = 0;
c0d0073e:	706e      	strb	r6, [r5, #1]
                                        break;
                                    case 1:
                                        printc(g_pcHex_cap[nibble1]);
c0d00740:	4f6f      	ldr	r7, [pc, #444]	; (c0d00900 <semihosted_printf+0x360>)
c0d00742:	447f      	add	r7, pc
c0d00744:	5c38      	ldrb	r0, [r7, r0]
    buf[0] = c;
c0d00746:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00748:	2004      	movs	r0, #4
c0d0074a:	0029      	movs	r1, r5
c0d0074c:	dfab      	svc	171	; 0xab
    buf[1] = 0;
c0d0074e:	706e      	strb	r6, [r5, #1]
c0d00750:	9e05      	ldr	r6, [sp, #20]
                                        printc(g_pcHex_cap[nibble2]);
c0d00752:	5cf8      	ldrb	r0, [r7, r3]
c0d00754:	9f02      	ldr	r7, [sp, #8]
    buf[0] = c;
c0d00756:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00758:	2004      	movs	r0, #4
c0d0075a:	0029      	movs	r1, r5
c0d0075c:	dfab      	svc	171	; 0xab
                            for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d0075e:	1c52      	adds	r2, r2, #1
c0d00760:	1e76      	subs	r6, r6, #1
c0d00762:	d1cd      	bne.n	c0d00700 <semihosted_printf+0x160>
c0d00764:	e727      	b.n	c0d005b6 <semihosted_printf+0x16>
            switch (*format++) {
c0d00766:	2858      	cmp	r0, #88	; 0x58
c0d00768:	d12f      	bne.n	c0d007ca <semihosted_printf+0x22a>
c0d0076a:	2701      	movs	r7, #1
c0d0076c:	e001      	b.n	c0d00772 <semihosted_printf+0x1d2>
c0d0076e:	2870      	cmp	r0, #112	; 0x70
c0d00770:	d12b      	bne.n	c0d007ca <semihosted_printf+0x22a>
                case 'x':
                case 'p': {
                    //
                    // Get the value from the varargs.
                    //
                    ulValue = va_arg(vaArgP, unsigned long);
c0d00772:	9806      	ldr	r0, [sp, #24]
c0d00774:	1d01      	adds	r1, r0, #4
c0d00776:	9106      	str	r1, [sp, #24]
c0d00778:	6806      	ldr	r6, [r0, #0]
c0d0077a:	960b      	str	r6, [sp, #44]	; 0x2c
c0d0077c:	2000      	movs	r0, #0
c0d0077e:	9001      	str	r0, [sp, #4]
c0d00780:	2010      	movs	r0, #16
c0d00782:	e034      	b.n	c0d007ee <semihosted_printf+0x24e>
        memcpy(buf, str, written);
c0d00784:	1e60      	subs	r0, r4, #1
c0d00786:	7800      	ldrb	r0, [r0, #0]
c0d00788:	aa0c      	add	r2, sp, #48	; 0x30
c0d0078a:	2100      	movs	r1, #0
        buf[written] = 0;
c0d0078c:	7051      	strb	r1, [r2, #1]
        memcpy(buf, str, written);
c0d0078e:	7010      	strb	r0, [r2, #0]
    asm volatile(
c0d00790:	2004      	movs	r0, #4
c0d00792:	0011      	movs	r1, r2
c0d00794:	dfab      	svc	171	; 0xab
c0d00796:	e70e      	b.n	c0d005b6 <semihosted_printf+0x16>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d00798:	9806      	ldr	r0, [sp, #24]
c0d0079a:	1d01      	adds	r1, r0, #4
c0d0079c:	9106      	str	r1, [sp, #24]
c0d0079e:	6806      	ldr	r6, [r0, #0]
c0d007a0:	960b      	str	r6, [sp, #44]	; 0x2c
c0d007a2:	2000      	movs	r0, #0
c0d007a4:	9001      	str	r0, [sp, #4]
c0d007a6:	200a      	movs	r0, #10
c0d007a8:	e021      	b.n	c0d007ee <semihosted_printf+0x24e>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d007aa:	9806      	ldr	r0, [sp, #24]
c0d007ac:	1d01      	adds	r1, r0, #4
c0d007ae:	9106      	str	r1, [sp, #24]
c0d007b0:	6800      	ldr	r0, [r0, #0]
c0d007b2:	900b      	str	r0, [sp, #44]	; 0x2c
c0d007b4:	aa0c      	add	r2, sp, #48	; 0x30
c0d007b6:	2100      	movs	r1, #0
        buf[written] = 0;
c0d007b8:	7051      	strb	r1, [r2, #1]
        memcpy(buf, str, written);
c0d007ba:	7010      	strb	r0, [r2, #0]
    asm volatile(
c0d007bc:	2004      	movs	r0, #4
c0d007be:	0011      	movs	r1, r2
c0d007c0:	dfab      	svc	171	; 0xab
c0d007c2:	e6f8      	b.n	c0d005b6 <semihosted_printf+0x16>
                            if (pcStr[0] == '\0') {
c0d007c4:	7810      	ldrb	r0, [r2, #0]
c0d007c6:	2800      	cmp	r0, #0
c0d007c8:	d077      	beq.n	c0d008ba <semihosted_printf+0x31a>
c0d007ca:	aa0c      	add	r2, sp, #48	; 0x30
c0d007cc:	2052      	movs	r0, #82	; 0x52
        memcpy(buf, str, written);
c0d007ce:	8090      	strh	r0, [r2, #4]
c0d007d0:	4849      	ldr	r0, [pc, #292]	; (c0d008f8 <semihosted_printf+0x358>)
c0d007d2:	900c      	str	r0, [sp, #48]	; 0x30
    asm volatile(
c0d007d4:	2004      	movs	r0, #4
c0d007d6:	0011      	movs	r1, r2
c0d007d8:	dfab      	svc	171	; 0xab
c0d007da:	e6ec      	b.n	c0d005b6 <semihosted_printf+0x16>
                            prints(pcStr, ulIdx);
c0d007dc:	b2b1      	uxth	r1, r6
c0d007de:	4610      	mov	r0, r2
c0d007e0:	f000 f894 	bl	c0d0090c <prints>
c0d007e4:	e073      	b.n	c0d008ce <semihosted_printf+0x32e>
                        ulValue = -(long) ulValue;
c0d007e6:	4276      	negs	r6, r6
c0d007e8:	960b      	str	r6, [sp, #44]	; 0x2c
c0d007ea:	2101      	movs	r1, #1
c0d007ec:	9101      	str	r1, [sp, #4]
c0d007ee:	9702      	str	r7, [sp, #8]
                    // Determine the number of digits in the string version of
                    // the value.
                    //
                convert:
                    for (ulIdx = 1;
                         (((ulIdx * ulBase) <= ulValue) && (((ulIdx * ulBase) / ulBase) == ulIdx));
c0d007f0:	42b0      	cmp	r0, r6
c0d007f2:	9003      	str	r0, [sp, #12]
c0d007f4:	d901      	bls.n	c0d007fa <semihosted_printf+0x25a>
c0d007f6:	2701      	movs	r7, #1
c0d007f8:	e00f      	b.n	c0d0081a <semihosted_printf+0x27a>
                    for (ulIdx = 1;
c0d007fa:	1e6a      	subs	r2, r5, #1
c0d007fc:	4607      	mov	r7, r0
c0d007fe:	4615      	mov	r5, r2
c0d00800:	2100      	movs	r1, #0
                         (((ulIdx * ulBase) <= ulValue) && (((ulIdx * ulBase) / ulBase) == ulIdx));
c0d00802:	9803      	ldr	r0, [sp, #12]
c0d00804:	463a      	mov	r2, r7
c0d00806:	460b      	mov	r3, r1
c0d00808:	f000 f984 	bl	c0d00b14 <__aeabi_lmul>
c0d0080c:	1e4a      	subs	r2, r1, #1
c0d0080e:	4191      	sbcs	r1, r2
c0d00810:	42b0      	cmp	r0, r6
c0d00812:	d802      	bhi.n	c0d0081a <semihosted_printf+0x27a>
                    for (ulIdx = 1;
c0d00814:	1e6a      	subs	r2, r5, #1
c0d00816:	2900      	cmp	r1, #0
c0d00818:	d0f0      	beq.n	c0d007fc <semihosted_printf+0x25c>
c0d0081a:	9801      	ldr	r0, [sp, #4]

                    //
                    // If the value is negative, reduce the count of padding
                    // characters needed.
                    //
                    if (ulNeg) {
c0d0081c:	2800      	cmp	r0, #0
c0d0081e:	9605      	str	r6, [sp, #20]
c0d00820:	d000      	beq.n	c0d00824 <semihosted_printf+0x284>
c0d00822:	1e6d      	subs	r5, r5, #1
c0d00824:	9a04      	ldr	r2, [sp, #16]
c0d00826:	2600      	movs	r6, #0

                    //
                    // If the value is negative and the value is padded with
                    // zeros, then place the minus sign before the padding.
                    //
                    if (ulNeg && (cFill == '0')) {
c0d00828:	2800      	cmp	r0, #0
c0d0082a:	d009      	beq.n	c0d00840 <semihosted_printf+0x2a0>
c0d0082c:	b2d0      	uxtb	r0, r2
c0d0082e:	2830      	cmp	r0, #48	; 0x30
c0d00830:	d108      	bne.n	c0d00844 <semihosted_printf+0x2a4>
c0d00832:	a807      	add	r0, sp, #28
c0d00834:	212d      	movs	r1, #45	; 0x2d
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d00836:	7001      	strb	r1, [r0, #0]
c0d00838:	2001      	movs	r0, #1
c0d0083a:	4631      	mov	r1, r6
c0d0083c:	4606      	mov	r6, r0
c0d0083e:	e002      	b.n	c0d00846 <semihosted_printf+0x2a6>
c0d00840:	4631      	mov	r1, r6
c0d00842:	e000      	b.n	c0d00846 <semihosted_printf+0x2a6>
c0d00844:	2101      	movs	r1, #1

                    //
                    // Provide additional padding at the beginning of the
                    // string conversion if needed.
                    //
                    if ((ulCount > 1) && (ulCount < 16)) {
c0d00846:	1ea8      	subs	r0, r5, #2
c0d00848:	280d      	cmp	r0, #13
c0d0084a:	d80c      	bhi.n	c0d00866 <semihosted_printf+0x2c6>
c0d0084c:	a807      	add	r0, sp, #28
                        for (ulCount--; ulCount; ulCount--) {
c0d0084e:	1980      	adds	r0, r0, r6
c0d00850:	1e6d      	subs	r5, r5, #1
                            pcBuf[ulPos++] = cFill;
c0d00852:	b2d2      	uxtb	r2, r2
c0d00854:	9104      	str	r1, [sp, #16]
c0d00856:	4629      	mov	r1, r5
c0d00858:	f000 f993 	bl	c0d00b82 <__aeabi_memset>
c0d0085c:	9904      	ldr	r1, [sp, #16]
c0d0085e:	1e6d      	subs	r5, r5, #1
c0d00860:	1c76      	adds	r6, r6, #1
                        for (ulCount--; ulCount; ulCount--) {
c0d00862:	2d00      	cmp	r5, #0
c0d00864:	d1fb      	bne.n	c0d0085e <semihosted_printf+0x2be>

                    //
                    // If the value is negative, then place the minus sign
                    // before the number.
                    //
                    if (ulNeg) {
c0d00866:	2900      	cmp	r1, #0
c0d00868:	d003      	beq.n	c0d00872 <semihosted_printf+0x2d2>
c0d0086a:	a807      	add	r0, sp, #28
c0d0086c:	212d      	movs	r1, #45	; 0x2d
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d0086e:	5581      	strb	r1, [r0, r6]
c0d00870:	1c76      	adds	r6, r6, #1
                    }

                    //
                    // Convert the value into a string.
                    //
                    for (; ulIdx; ulIdx /= ulBase) {
c0d00872:	2f00      	cmp	r7, #0
c0d00874:	d01c      	beq.n	c0d008b0 <semihosted_printf+0x310>
c0d00876:	9802      	ldr	r0, [sp, #8]
c0d00878:	2800      	cmp	r0, #0
c0d0087a:	d002      	beq.n	c0d00882 <semihosted_printf+0x2e2>
c0d0087c:	4822      	ldr	r0, [pc, #136]	; (c0d00908 <semihosted_printf+0x368>)
c0d0087e:	4478      	add	r0, pc
c0d00880:	e001      	b.n	c0d00886 <semihosted_printf+0x2e6>
c0d00882:	4820      	ldr	r0, [pc, #128]	; (c0d00904 <semihosted_printf+0x364>)
c0d00884:	4478      	add	r0, pc
c0d00886:	9004      	str	r0, [sp, #16]
c0d00888:	9d03      	ldr	r5, [sp, #12]
c0d0088a:	9805      	ldr	r0, [sp, #20]
c0d0088c:	4639      	mov	r1, r7
c0d0088e:	f000 f8b5 	bl	c0d009fc <__udivsi3>
c0d00892:	4629      	mov	r1, r5
c0d00894:	f000 f938 	bl	c0d00b08 <__aeabi_uidivmod>
c0d00898:	9804      	ldr	r0, [sp, #16]
c0d0089a:	5c40      	ldrb	r0, [r0, r1]
c0d0089c:	a907      	add	r1, sp, #28
                        if (!ulCap) {
                            pcBuf[ulPos++] = g_pcHex[(ulValue / ulIdx) % ulBase];
c0d0089e:	5588      	strb	r0, [r1, r6]
                    for (; ulIdx; ulIdx /= ulBase) {
c0d008a0:	4638      	mov	r0, r7
c0d008a2:	4629      	mov	r1, r5
c0d008a4:	f000 f8aa 	bl	c0d009fc <__udivsi3>
c0d008a8:	1c76      	adds	r6, r6, #1
c0d008aa:	42bd      	cmp	r5, r7
c0d008ac:	4607      	mov	r7, r0
c0d008ae:	d9ec      	bls.n	c0d0088a <semihosted_printf+0x2ea>
                    }

                    //
                    // Write the string.
                    //
                    prints(pcBuf, ulPos);
c0d008b0:	b2b1      	uxth	r1, r6
c0d008b2:	a807      	add	r0, sp, #28
c0d008b4:	f000 f82a 	bl	c0d0090c <prints>
c0d008b8:	e67d      	b.n	c0d005b6 <semihosted_printf+0x16>
                                do {
c0d008ba:	9805      	ldr	r0, [sp, #20]
c0d008bc:	1c42      	adds	r2, r0, #1
c0d008be:	ab0c      	add	r3, sp, #48	; 0x30
c0d008c0:	2020      	movs	r0, #32
        memcpy(buf, str, written);
c0d008c2:	8018      	strh	r0, [r3, #0]
    asm volatile(
c0d008c4:	2004      	movs	r0, #4
c0d008c6:	0019      	movs	r1, r3
c0d008c8:	dfab      	svc	171	; 0xab
                                } while (ulStrlen-- > 0);
c0d008ca:	1e52      	subs	r2, r2, #1
c0d008cc:	d1f7      	bne.n	c0d008be <semihosted_printf+0x31e>
                    if (ulCount > ulIdx) {
c0d008ce:	42b5      	cmp	r5, r6
c0d008d0:	d800      	bhi.n	c0d008d4 <semihosted_printf+0x334>
c0d008d2:	e670      	b.n	c0d005b6 <semihosted_printf+0x16>
                        ulCount -= ulIdx;
c0d008d4:	1ba8      	subs	r0, r5, r6
c0d008d6:	d100      	bne.n	c0d008da <semihosted_printf+0x33a>
c0d008d8:	e66d      	b.n	c0d005b6 <semihosted_printf+0x16>
                        while (ulCount--) {
c0d008da:	1b72      	subs	r2, r6, r5
c0d008dc:	ab0c      	add	r3, sp, #48	; 0x30
c0d008de:	2020      	movs	r0, #32
        memcpy(buf, str, written);
c0d008e0:	8018      	strh	r0, [r3, #0]
    asm volatile(
c0d008e2:	2004      	movs	r0, #4
c0d008e4:	0019      	movs	r1, r3
c0d008e6:	dfab      	svc	171	; 0xab
                        while (ulCount--) {
c0d008e8:	1c52      	adds	r2, r2, #1
c0d008ea:	d3f7      	bcc.n	c0d008dc <semihosted_printf+0x33c>
c0d008ec:	e663      	b.n	c0d005b6 <semihosted_printf+0x16>

    //
    // End the varargs processing.
    //
    va_end(vaArgP);
c0d008ee:	b01c      	add	sp, #112	; 0x70
c0d008f0:	bcf0      	pop	{r4, r5, r6, r7}
c0d008f2:	bc01      	pop	{r0}
c0d008f4:	b003      	add	sp, #12
c0d008f6:	4700      	bx	r0
c0d008f8:	4f525245 	.word	0x4f525245
c0d008fc:	00000981 	.word	0x00000981
c0d00900:	00000969 	.word	0x00000969
c0d00904:	00000817 	.word	0x00000817
c0d00908:	0000082d 	.word	0x0000082d

c0d0090c <prints>:
static void prints(const char *str, uint16_t size) {
c0d0090c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0090e:	b091      	sub	sp, #68	; 0x44
    while (size > 0) {
c0d00910:	2900      	cmp	r1, #0
c0d00912:	d01a      	beq.n	c0d0094a <prints+0x3e>
c0d00914:	460c      	mov	r4, r1
c0d00916:	4605      	mov	r5, r0
c0d00918:	b2a6      	uxth	r6, r4
        uint8_t written = MIN(sizeof(buf) - 1, size);
c0d0091a:	2e3f      	cmp	r6, #63	; 0x3f
c0d0091c:	9600      	str	r6, [sp, #0]
c0d0091e:	d300      	bcc.n	c0d00922 <prints+0x16>
c0d00920:	263f      	movs	r6, #63	; 0x3f
c0d00922:	af01      	add	r7, sp, #4
        memcpy(buf, str, written);
c0d00924:	4638      	mov	r0, r7
c0d00926:	4629      	mov	r1, r5
c0d00928:	4632      	mov	r2, r6
c0d0092a:	f000 f926 	bl	c0d00b7a <__aeabi_memcpy>
c0d0092e:	2000      	movs	r0, #0
        buf[written] = 0;
c0d00930:	55b8      	strb	r0, [r7, r6]
    asm volatile(
c0d00932:	2004      	movs	r0, #4
c0d00934:	0039      	movs	r1, r7
c0d00936:	dfab      	svc	171	; 0xab
c0d00938:	9a00      	ldr	r2, [sp, #0]
c0d0093a:	4296      	cmp	r6, r2
c0d0093c:	da00      	bge.n	c0d00940 <prints+0x34>
c0d0093e:	19ad      	adds	r5, r5, r6
        if (written >= size) {
c0d00940:	1ba4      	subs	r4, r4, r6
    while (size > 0) {
c0d00942:	0420      	lsls	r0, r4, #16
c0d00944:	d001      	beq.n	c0d0094a <prints+0x3e>
c0d00946:	4296      	cmp	r6, r2
c0d00948:	dbe6      	blt.n	c0d00918 <prints+0xc>
}
c0d0094a:	b011      	add	sp, #68	; 0x44
c0d0094c:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d0094e <SVC_Call>:
.thumb
.thumb_func
.global SVC_Call

SVC_Call:
    svc 1
c0d0094e:	df01      	svc	1
    cmp r1, #0
c0d00950:	2900      	cmp	r1, #0
    bne exception
c0d00952:	d100      	bne.n	c0d00956 <exception>
    bx lr
c0d00954:	4770      	bx	lr

c0d00956 <exception>:
exception:
    // THROW(ex);
    mov r0, r1
c0d00956:	4608      	mov	r0, r1
    bl os_longjmp
c0d00958:	f7ff fe1b 	bl	c0d00592 <os_longjmp>

c0d0095c <get_api_level>:
#include <string.h>

unsigned int SVC_Call(unsigned int syscall_id, void *parameters);
unsigned int SVC_cx_call(unsigned int syscall_id, unsigned int * parameters);

unsigned int get_api_level(void) {
c0d0095c:	b580      	push	{r7, lr}
c0d0095e:	b084      	sub	sp, #16
c0d00960:	2000      	movs	r0, #0
  unsigned int parameters [2+1];
  parameters[0] = 0;
  parameters[1] = 0;
c0d00962:	9002      	str	r0, [sp, #8]
  parameters[0] = 0;
c0d00964:	9001      	str	r0, [sp, #4]
c0d00966:	4803      	ldr	r0, [pc, #12]	; (c0d00974 <get_api_level+0x18>)
c0d00968:	a901      	add	r1, sp, #4
  return SVC_Call(SYSCALL_get_api_level_ID_IN, parameters);
c0d0096a:	f7ff fff0 	bl	c0d0094e <SVC_Call>
c0d0096e:	b004      	add	sp, #16
c0d00970:	bd80      	pop	{r7, pc}
c0d00972:	46c0      	nop			; (mov r8, r8)
c0d00974:	60000138 	.word	0x60000138

c0d00978 <os_lib_call>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_ux_result_ID_IN, parameters);
  return;
}

void os_lib_call ( unsigned int * call_parameters ) {
c0d00978:	b580      	push	{r7, lr}
c0d0097a:	b084      	sub	sp, #16
c0d0097c:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)call_parameters;
  parameters[1] = 0;
c0d0097e:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)call_parameters;
c0d00980:	9001      	str	r0, [sp, #4]
c0d00982:	4803      	ldr	r0, [pc, #12]	; (c0d00990 <os_lib_call+0x18>)
c0d00984:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_lib_call_ID_IN, parameters);
c0d00986:	f7ff ffe2 	bl	c0d0094e <SVC_Call>
  return;
}
c0d0098a:	b004      	add	sp, #16
c0d0098c:	bd80      	pop	{r7, pc}
c0d0098e:	46c0      	nop			; (mov r8, r8)
c0d00990:	6000670d 	.word	0x6000670d

c0d00994 <os_lib_end>:

void os_lib_end ( void ) {
c0d00994:	b580      	push	{r7, lr}
c0d00996:	b082      	sub	sp, #8
c0d00998:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d0099a:	9001      	str	r0, [sp, #4]
c0d0099c:	4802      	ldr	r0, [pc, #8]	; (c0d009a8 <os_lib_end+0x14>)
c0d0099e:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_os_lib_end_ID_IN, parameters);
c0d009a0:	f7ff ffd5 	bl	c0d0094e <SVC_Call>
  return;
}
c0d009a4:	b002      	add	sp, #8
c0d009a6:	bd80      	pop	{r7, pc}
c0d009a8:	6000688d 	.word	0x6000688d

c0d009ac <os_sched_exit>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_exec_ID_IN, parameters);
  return;
}

void os_sched_exit ( bolos_task_status_t exit_code ) {
c0d009ac:	b580      	push	{r7, lr}
c0d009ae:	b084      	sub	sp, #16
c0d009b0:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)exit_code;
  parameters[1] = 0;
c0d009b2:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)exit_code;
c0d009b4:	9001      	str	r0, [sp, #4]
c0d009b6:	4803      	ldr	r0, [pc, #12]	; (c0d009c4 <os_sched_exit+0x18>)
c0d009b8:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0d009ba:	f7ff ffc8 	bl	c0d0094e <SVC_Call>
  return;
}
c0d009be:	b004      	add	sp, #16
c0d009c0:	bd80      	pop	{r7, pc}
c0d009c2:	46c0      	nop			; (mov r8, r8)
c0d009c4:	60009abe 	.word	0x60009abe

c0d009c8 <try_context_get>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_nvm_erase_page_ID_IN, parameters);
  return;
}

try_context_t * try_context_get ( void ) {
c0d009c8:	b580      	push	{r7, lr}
c0d009ca:	b082      	sub	sp, #8
c0d009cc:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d009ce:	9001      	str	r0, [sp, #4]
c0d009d0:	4802      	ldr	r0, [pc, #8]	; (c0d009dc <try_context_get+0x14>)
c0d009d2:	4669      	mov	r1, sp
  return (try_context_t *) SVC_Call(SYSCALL_try_context_get_ID_IN, parameters);
c0d009d4:	f7ff ffbb 	bl	c0d0094e <SVC_Call>
c0d009d8:	b002      	add	sp, #8
c0d009da:	bd80      	pop	{r7, pc}
c0d009dc:	600087b1 	.word	0x600087b1

c0d009e0 <try_context_set>:
}

try_context_t * try_context_set ( try_context_t *context ) {
c0d009e0:	b580      	push	{r7, lr}
c0d009e2:	b084      	sub	sp, #16
c0d009e4:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)context;
  parameters[1] = 0;
c0d009e6:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)context;
c0d009e8:	9001      	str	r0, [sp, #4]
c0d009ea:	4803      	ldr	r0, [pc, #12]	; (c0d009f8 <try_context_set+0x18>)
c0d009ec:	a901      	add	r1, sp, #4
  return (try_context_t *) SVC_Call(SYSCALL_try_context_set_ID_IN, parameters);
c0d009ee:	f7ff ffae 	bl	c0d0094e <SVC_Call>
c0d009f2:	b004      	add	sp, #16
c0d009f4:	bd80      	pop	{r7, pc}
c0d009f6:	46c0      	nop			; (mov r8, r8)
c0d009f8:	60010b06 	.word	0x60010b06

c0d009fc <__udivsi3>:
c0d009fc:	2200      	movs	r2, #0
c0d009fe:	0843      	lsrs	r3, r0, #1
c0d00a00:	428b      	cmp	r3, r1
c0d00a02:	d374      	bcc.n	c0d00aee <__udivsi3+0xf2>
c0d00a04:	0903      	lsrs	r3, r0, #4
c0d00a06:	428b      	cmp	r3, r1
c0d00a08:	d35f      	bcc.n	c0d00aca <__udivsi3+0xce>
c0d00a0a:	0a03      	lsrs	r3, r0, #8
c0d00a0c:	428b      	cmp	r3, r1
c0d00a0e:	d344      	bcc.n	c0d00a9a <__udivsi3+0x9e>
c0d00a10:	0b03      	lsrs	r3, r0, #12
c0d00a12:	428b      	cmp	r3, r1
c0d00a14:	d328      	bcc.n	c0d00a68 <__udivsi3+0x6c>
c0d00a16:	0c03      	lsrs	r3, r0, #16
c0d00a18:	428b      	cmp	r3, r1
c0d00a1a:	d30d      	bcc.n	c0d00a38 <__udivsi3+0x3c>
c0d00a1c:	22ff      	movs	r2, #255	; 0xff
c0d00a1e:	0209      	lsls	r1, r1, #8
c0d00a20:	ba12      	rev	r2, r2
c0d00a22:	0c03      	lsrs	r3, r0, #16
c0d00a24:	428b      	cmp	r3, r1
c0d00a26:	d302      	bcc.n	c0d00a2e <__udivsi3+0x32>
c0d00a28:	1212      	asrs	r2, r2, #8
c0d00a2a:	0209      	lsls	r1, r1, #8
c0d00a2c:	d065      	beq.n	c0d00afa <__udivsi3+0xfe>
c0d00a2e:	0b03      	lsrs	r3, r0, #12
c0d00a30:	428b      	cmp	r3, r1
c0d00a32:	d319      	bcc.n	c0d00a68 <__udivsi3+0x6c>
c0d00a34:	e000      	b.n	c0d00a38 <__udivsi3+0x3c>
c0d00a36:	0a09      	lsrs	r1, r1, #8
c0d00a38:	0bc3      	lsrs	r3, r0, #15
c0d00a3a:	428b      	cmp	r3, r1
c0d00a3c:	d301      	bcc.n	c0d00a42 <__udivsi3+0x46>
c0d00a3e:	03cb      	lsls	r3, r1, #15
c0d00a40:	1ac0      	subs	r0, r0, r3
c0d00a42:	4152      	adcs	r2, r2
c0d00a44:	0b83      	lsrs	r3, r0, #14
c0d00a46:	428b      	cmp	r3, r1
c0d00a48:	d301      	bcc.n	c0d00a4e <__udivsi3+0x52>
c0d00a4a:	038b      	lsls	r3, r1, #14
c0d00a4c:	1ac0      	subs	r0, r0, r3
c0d00a4e:	4152      	adcs	r2, r2
c0d00a50:	0b43      	lsrs	r3, r0, #13
c0d00a52:	428b      	cmp	r3, r1
c0d00a54:	d301      	bcc.n	c0d00a5a <__udivsi3+0x5e>
c0d00a56:	034b      	lsls	r3, r1, #13
c0d00a58:	1ac0      	subs	r0, r0, r3
c0d00a5a:	4152      	adcs	r2, r2
c0d00a5c:	0b03      	lsrs	r3, r0, #12
c0d00a5e:	428b      	cmp	r3, r1
c0d00a60:	d301      	bcc.n	c0d00a66 <__udivsi3+0x6a>
c0d00a62:	030b      	lsls	r3, r1, #12
c0d00a64:	1ac0      	subs	r0, r0, r3
c0d00a66:	4152      	adcs	r2, r2
c0d00a68:	0ac3      	lsrs	r3, r0, #11
c0d00a6a:	428b      	cmp	r3, r1
c0d00a6c:	d301      	bcc.n	c0d00a72 <__udivsi3+0x76>
c0d00a6e:	02cb      	lsls	r3, r1, #11
c0d00a70:	1ac0      	subs	r0, r0, r3
c0d00a72:	4152      	adcs	r2, r2
c0d00a74:	0a83      	lsrs	r3, r0, #10
c0d00a76:	428b      	cmp	r3, r1
c0d00a78:	d301      	bcc.n	c0d00a7e <__udivsi3+0x82>
c0d00a7a:	028b      	lsls	r3, r1, #10
c0d00a7c:	1ac0      	subs	r0, r0, r3
c0d00a7e:	4152      	adcs	r2, r2
c0d00a80:	0a43      	lsrs	r3, r0, #9
c0d00a82:	428b      	cmp	r3, r1
c0d00a84:	d301      	bcc.n	c0d00a8a <__udivsi3+0x8e>
c0d00a86:	024b      	lsls	r3, r1, #9
c0d00a88:	1ac0      	subs	r0, r0, r3
c0d00a8a:	4152      	adcs	r2, r2
c0d00a8c:	0a03      	lsrs	r3, r0, #8
c0d00a8e:	428b      	cmp	r3, r1
c0d00a90:	d301      	bcc.n	c0d00a96 <__udivsi3+0x9a>
c0d00a92:	020b      	lsls	r3, r1, #8
c0d00a94:	1ac0      	subs	r0, r0, r3
c0d00a96:	4152      	adcs	r2, r2
c0d00a98:	d2cd      	bcs.n	c0d00a36 <__udivsi3+0x3a>
c0d00a9a:	09c3      	lsrs	r3, r0, #7
c0d00a9c:	428b      	cmp	r3, r1
c0d00a9e:	d301      	bcc.n	c0d00aa4 <__udivsi3+0xa8>
c0d00aa0:	01cb      	lsls	r3, r1, #7
c0d00aa2:	1ac0      	subs	r0, r0, r3
c0d00aa4:	4152      	adcs	r2, r2
c0d00aa6:	0983      	lsrs	r3, r0, #6
c0d00aa8:	428b      	cmp	r3, r1
c0d00aaa:	d301      	bcc.n	c0d00ab0 <__udivsi3+0xb4>
c0d00aac:	018b      	lsls	r3, r1, #6
c0d00aae:	1ac0      	subs	r0, r0, r3
c0d00ab0:	4152      	adcs	r2, r2
c0d00ab2:	0943      	lsrs	r3, r0, #5
c0d00ab4:	428b      	cmp	r3, r1
c0d00ab6:	d301      	bcc.n	c0d00abc <__udivsi3+0xc0>
c0d00ab8:	014b      	lsls	r3, r1, #5
c0d00aba:	1ac0      	subs	r0, r0, r3
c0d00abc:	4152      	adcs	r2, r2
c0d00abe:	0903      	lsrs	r3, r0, #4
c0d00ac0:	428b      	cmp	r3, r1
c0d00ac2:	d301      	bcc.n	c0d00ac8 <__udivsi3+0xcc>
c0d00ac4:	010b      	lsls	r3, r1, #4
c0d00ac6:	1ac0      	subs	r0, r0, r3
c0d00ac8:	4152      	adcs	r2, r2
c0d00aca:	08c3      	lsrs	r3, r0, #3
c0d00acc:	428b      	cmp	r3, r1
c0d00ace:	d301      	bcc.n	c0d00ad4 <__udivsi3+0xd8>
c0d00ad0:	00cb      	lsls	r3, r1, #3
c0d00ad2:	1ac0      	subs	r0, r0, r3
c0d00ad4:	4152      	adcs	r2, r2
c0d00ad6:	0883      	lsrs	r3, r0, #2
c0d00ad8:	428b      	cmp	r3, r1
c0d00ada:	d301      	bcc.n	c0d00ae0 <__udivsi3+0xe4>
c0d00adc:	008b      	lsls	r3, r1, #2
c0d00ade:	1ac0      	subs	r0, r0, r3
c0d00ae0:	4152      	adcs	r2, r2
c0d00ae2:	0843      	lsrs	r3, r0, #1
c0d00ae4:	428b      	cmp	r3, r1
c0d00ae6:	d301      	bcc.n	c0d00aec <__udivsi3+0xf0>
c0d00ae8:	004b      	lsls	r3, r1, #1
c0d00aea:	1ac0      	subs	r0, r0, r3
c0d00aec:	4152      	adcs	r2, r2
c0d00aee:	1a41      	subs	r1, r0, r1
c0d00af0:	d200      	bcs.n	c0d00af4 <__udivsi3+0xf8>
c0d00af2:	4601      	mov	r1, r0
c0d00af4:	4152      	adcs	r2, r2
c0d00af6:	4610      	mov	r0, r2
c0d00af8:	4770      	bx	lr
c0d00afa:	e7ff      	b.n	c0d00afc <__udivsi3+0x100>
c0d00afc:	b501      	push	{r0, lr}
c0d00afe:	2000      	movs	r0, #0
c0d00b00:	f000 f806 	bl	c0d00b10 <__aeabi_idiv0>
c0d00b04:	bd02      	pop	{r1, pc}
c0d00b06:	46c0      	nop			; (mov r8, r8)

c0d00b08 <__aeabi_uidivmod>:
c0d00b08:	2900      	cmp	r1, #0
c0d00b0a:	d0f7      	beq.n	c0d00afc <__udivsi3+0x100>
c0d00b0c:	e776      	b.n	c0d009fc <__udivsi3>
c0d00b0e:	4770      	bx	lr

c0d00b10 <__aeabi_idiv0>:
c0d00b10:	4770      	bx	lr
c0d00b12:	46c0      	nop			; (mov r8, r8)

c0d00b14 <__aeabi_lmul>:
c0d00b14:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00b16:	46ce      	mov	lr, r9
c0d00b18:	4647      	mov	r7, r8
c0d00b1a:	b580      	push	{r7, lr}
c0d00b1c:	0007      	movs	r7, r0
c0d00b1e:	4699      	mov	r9, r3
c0d00b20:	0c3b      	lsrs	r3, r7, #16
c0d00b22:	469c      	mov	ip, r3
c0d00b24:	0413      	lsls	r3, r2, #16
c0d00b26:	0c1b      	lsrs	r3, r3, #16
c0d00b28:	001d      	movs	r5, r3
c0d00b2a:	000e      	movs	r6, r1
c0d00b2c:	4661      	mov	r1, ip
c0d00b2e:	0400      	lsls	r0, r0, #16
c0d00b30:	0c14      	lsrs	r4, r2, #16
c0d00b32:	0c00      	lsrs	r0, r0, #16
c0d00b34:	4345      	muls	r5, r0
c0d00b36:	434b      	muls	r3, r1
c0d00b38:	4360      	muls	r0, r4
c0d00b3a:	4361      	muls	r1, r4
c0d00b3c:	18c0      	adds	r0, r0, r3
c0d00b3e:	0c2c      	lsrs	r4, r5, #16
c0d00b40:	1820      	adds	r0, r4, r0
c0d00b42:	468c      	mov	ip, r1
c0d00b44:	4283      	cmp	r3, r0
c0d00b46:	d903      	bls.n	c0d00b50 <__aeabi_lmul+0x3c>
c0d00b48:	2380      	movs	r3, #128	; 0x80
c0d00b4a:	025b      	lsls	r3, r3, #9
c0d00b4c:	4698      	mov	r8, r3
c0d00b4e:	44c4      	add	ip, r8
c0d00b50:	4649      	mov	r1, r9
c0d00b52:	4379      	muls	r1, r7
c0d00b54:	4372      	muls	r2, r6
c0d00b56:	0c03      	lsrs	r3, r0, #16
c0d00b58:	4463      	add	r3, ip
c0d00b5a:	042d      	lsls	r5, r5, #16
c0d00b5c:	0c2d      	lsrs	r5, r5, #16
c0d00b5e:	18c9      	adds	r1, r1, r3
c0d00b60:	0400      	lsls	r0, r0, #16
c0d00b62:	1940      	adds	r0, r0, r5
c0d00b64:	1889      	adds	r1, r1, r2
c0d00b66:	bcc0      	pop	{r6, r7}
c0d00b68:	46b9      	mov	r9, r7
c0d00b6a:	46b0      	mov	r8, r6
c0d00b6c:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00b6e:	46c0      	nop			; (mov r8, r8)

c0d00b70 <__aeabi_memclr>:
c0d00b70:	b510      	push	{r4, lr}
c0d00b72:	2200      	movs	r2, #0
c0d00b74:	f000 f805 	bl	c0d00b82 <__aeabi_memset>
c0d00b78:	bd10      	pop	{r4, pc}

c0d00b7a <__aeabi_memcpy>:
c0d00b7a:	b510      	push	{r4, lr}
c0d00b7c:	f000 f808 	bl	c0d00b90 <memcpy>
c0d00b80:	bd10      	pop	{r4, pc}

c0d00b82 <__aeabi_memset>:
c0d00b82:	000b      	movs	r3, r1
c0d00b84:	b510      	push	{r4, lr}
c0d00b86:	0011      	movs	r1, r2
c0d00b88:	001a      	movs	r2, r3
c0d00b8a:	f000 f80a 	bl	c0d00ba2 <memset>
c0d00b8e:	bd10      	pop	{r4, pc}

c0d00b90 <memcpy>:
c0d00b90:	2300      	movs	r3, #0
c0d00b92:	b510      	push	{r4, lr}
c0d00b94:	429a      	cmp	r2, r3
c0d00b96:	d100      	bne.n	c0d00b9a <memcpy+0xa>
c0d00b98:	bd10      	pop	{r4, pc}
c0d00b9a:	5ccc      	ldrb	r4, [r1, r3]
c0d00b9c:	54c4      	strb	r4, [r0, r3]
c0d00b9e:	3301      	adds	r3, #1
c0d00ba0:	e7f8      	b.n	c0d00b94 <memcpy+0x4>

c0d00ba2 <memset>:
c0d00ba2:	0003      	movs	r3, r0
c0d00ba4:	1882      	adds	r2, r0, r2
c0d00ba6:	4293      	cmp	r3, r2
c0d00ba8:	d100      	bne.n	c0d00bac <memset+0xa>
c0d00baa:	4770      	bx	lr
c0d00bac:	7019      	strb	r1, [r3, #0]
c0d00bae:	3301      	adds	r3, #1
c0d00bb0:	e7f9      	b.n	c0d00ba6 <memset+0x4>

c0d00bb2 <setjmp>:
c0d00bb2:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0d00bb4:	4641      	mov	r1, r8
c0d00bb6:	464a      	mov	r2, r9
c0d00bb8:	4653      	mov	r3, sl
c0d00bba:	465c      	mov	r4, fp
c0d00bbc:	466d      	mov	r5, sp
c0d00bbe:	4676      	mov	r6, lr
c0d00bc0:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0d00bc2:	3828      	subs	r0, #40	; 0x28
c0d00bc4:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d00bc6:	2000      	movs	r0, #0
c0d00bc8:	4770      	bx	lr

c0d00bca <longjmp>:
c0d00bca:	3010      	adds	r0, #16
c0d00bcc:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0d00bce:	4690      	mov	r8, r2
c0d00bd0:	4699      	mov	r9, r3
c0d00bd2:	46a2      	mov	sl, r4
c0d00bd4:	46ab      	mov	fp, r5
c0d00bd6:	46b5      	mov	sp, r6
c0d00bd8:	c808      	ldmia	r0!, {r3}
c0d00bda:	3828      	subs	r0, #40	; 0x28
c0d00bdc:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d00bde:	1c08      	adds	r0, r1, #0
c0d00be0:	d100      	bne.n	c0d00be4 <longjmp+0x1a>
c0d00be2:	2001      	movs	r0, #1
c0d00be4:	4718      	bx	r3

c0d00be6 <strlcpy>:
c0d00be6:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00be8:	0005      	movs	r5, r0
c0d00bea:	2a00      	cmp	r2, #0
c0d00bec:	d014      	beq.n	c0d00c18 <strlcpy+0x32>
c0d00bee:	1e50      	subs	r0, r2, #1
c0d00bf0:	2a01      	cmp	r2, #1
c0d00bf2:	d01c      	beq.n	c0d00c2e <strlcpy+0x48>
c0d00bf4:	002c      	movs	r4, r5
c0d00bf6:	000a      	movs	r2, r1
c0d00bf8:	0016      	movs	r6, r2
c0d00bfa:	0027      	movs	r7, r4
c0d00bfc:	7836      	ldrb	r6, [r6, #0]
c0d00bfe:	3201      	adds	r2, #1
c0d00c00:	3401      	adds	r4, #1
c0d00c02:	0013      	movs	r3, r2
c0d00c04:	0025      	movs	r5, r4
c0d00c06:	703e      	strb	r6, [r7, #0]
c0d00c08:	2e00      	cmp	r6, #0
c0d00c0a:	d00d      	beq.n	c0d00c28 <strlcpy+0x42>
c0d00c0c:	3801      	subs	r0, #1
c0d00c0e:	2800      	cmp	r0, #0
c0d00c10:	d1f2      	bne.n	c0d00bf8 <strlcpy+0x12>
c0d00c12:	2200      	movs	r2, #0
c0d00c14:	702a      	strb	r2, [r5, #0]
c0d00c16:	e000      	b.n	c0d00c1a <strlcpy+0x34>
c0d00c18:	000b      	movs	r3, r1
c0d00c1a:	001a      	movs	r2, r3
c0d00c1c:	3201      	adds	r2, #1
c0d00c1e:	1e50      	subs	r0, r2, #1
c0d00c20:	7800      	ldrb	r0, [r0, #0]
c0d00c22:	0013      	movs	r3, r2
c0d00c24:	2800      	cmp	r0, #0
c0d00c26:	d1f9      	bne.n	c0d00c1c <strlcpy+0x36>
c0d00c28:	1a58      	subs	r0, r3, r1
c0d00c2a:	3801      	subs	r0, #1
c0d00c2c:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00c2e:	000b      	movs	r3, r1
c0d00c30:	e7ef      	b.n	c0d00c12 <strlcpy+0x2c>
c0d00c32:	6c50      	.short	0x6c50
c0d00c34:	6e696775 	.word	0x6e696775
c0d00c38:	72617020 	.word	0x72617020
c0d00c3c:	74656d61 	.word	0x74656d61
c0d00c40:	20737265 	.word	0x20737265
c0d00c44:	75727473 	.word	0x75727473
c0d00c48:	72757463 	.word	0x72757463
c0d00c4c:	73692065 	.word	0x73692065
c0d00c50:	67696220 	.word	0x67696220
c0d00c54:	20726567 	.word	0x20726567
c0d00c58:	6e616874 	.word	0x6e616874
c0d00c5c:	6c6c6120 	.word	0x6c6c6120
c0d00c60:	6465776f 	.word	0x6465776f
c0d00c64:	7a697320 	.word	0x7a697320
c0d00c68:	49000a65 	.word	0x49000a65
c0d00c6c:	5243204e 	.word	0x5243204e
c0d00c70:	45544145 	.word	0x45544145
c0d00c74:	4e49000a 	.word	0x4e49000a
c0d00c78:	4f525020 	.word	0x4f525020
c0d00c7c:	53534543 	.word	0x53534543
c0d00c80:	54554f5f 	.word	0x54554f5f
c0d00c84:	5f545550 	.word	0x5f545550
c0d00c88:	4544524f 	.word	0x4544524f
c0d00c8c:	000a5352 	.word	0x000a5352
c0d00c90:	2d67736d 	.word	0x2d67736d
c0d00c94:	7261703e 	.word	0x7261703e
c0d00c98:	74656d61 	.word	0x74656d61
c0d00c9c:	664f7265 	.word	0x664f7265
c0d00ca0:	74657366 	.word	0x74657366
c0d00ca4:	6425203a 	.word	0x6425203a
c0d00ca8:	3455000a 	.word	0x3455000a
c0d00cac:	6d204542 	.word	0x6d204542
c0d00cb0:	3e2d6773 	.word	0x3e2d6773
c0d00cb4:	61726170 	.word	0x61726170
c0d00cb8:	6574656d 	.word	0x6574656d
c0d00cbc:	25203a72 	.word	0x25203a72
c0d00cc0:	63000a64 	.word	0x63000a64
c0d00cc4:	6569706f 	.word	0x6569706f
c0d00cc8:	666f2064 	.word	0x666f2064
c0d00ccc:	74657366 	.word	0x74657366
c0d00cd0:	6425203a 	.word	0x6425203a
c0d00cd4:	6c70000a 	.word	0x6c70000a
c0d00cd8:	6e696775 	.word	0x6e696775
c0d00cdc:	6f727020 	.word	0x6f727020
c0d00ce0:	65646976 	.word	0x65646976
c0d00ce4:	72617020 	.word	0x72617020
c0d00ce8:	74656d61 	.word	0x74656d61
c0d00cec:	203a7265 	.word	0x203a7265
c0d00cf0:	7366666f 	.word	0x7366666f
c0d00cf4:	25207465 	.word	0x25207465
c0d00cf8:	79420a64 	.word	0x79420a64
c0d00cfc:	3a736574 	.word	0x3a736574
c0d00d00:	305b1b20 	.word	0x305b1b20
c0d00d04:	6d31333b 	.word	0x6d31333b
c0d00d08:	2a2e2520 	.word	0x2a2e2520
c0d00d0c:	5b1b2048 	.word	0x5b1b2048
c0d00d10:	0a206d30 	.word	0x0a206d30
c0d00d14:	6c655300 	.word	0x6c655300
c0d00d18:	6f746365 	.word	0x6f746365
c0d00d1c:	6e492072 	.word	0x6e492072
c0d00d20:	20786564 	.word	0x20786564
c0d00d24:	20746f6e 	.word	0x20746f6e
c0d00d28:	70707573 	.word	0x70707573
c0d00d2c:	6574726f 	.word	0x6574726f
c0d00d30:	25203a64 	.word	0x25203a64
c0d00d34:	50000a64 	.word	0x50000a64
c0d00d38:	49535241 	.word	0x49535241
c0d00d3c:	4320474e 	.word	0x4320474e
c0d00d40:	54414552 	.word	0x54414552
c0d00d44:	43000a45 	.word	0x43000a45
c0d00d48:	54414552 	.word	0x54414552
c0d00d4c:	545f5f45 	.word	0x545f5f45
c0d00d50:	4e454b4f 	.word	0x4e454b4f
c0d00d54:	0a44495f 	.word	0x0a44495f
c0d00d58:	20534900 	.word	0x20534900
c0d00d5c:	20544f4e 	.word	0x20544f4e
c0d00d60:	43000a30 	.word	0x43000a30
c0d00d64:	54414552 	.word	0x54414552
c0d00d68:	4f5f5f45 	.word	0x4f5f5f45
c0d00d6c:	45534646 	.word	0x45534646
c0d00d70:	41425f54 	.word	0x41425f54
c0d00d74:	49484354 	.word	0x49484354
c0d00d78:	5455504e 	.word	0x5455504e
c0d00d7c:	4544524f 	.word	0x4544524f
c0d00d80:	43000a52 	.word	0x43000a52
c0d00d84:	54414552 	.word	0x54414552
c0d00d88:	4c5f5f45 	.word	0x4c5f5f45
c0d00d8c:	425f4e45 	.word	0x425f4e45
c0d00d90:	48435441 	.word	0x48435441
c0d00d94:	55504e49 	.word	0x55504e49
c0d00d98:	44524f54 	.word	0x44524f54
c0d00d9c:	000a5245 	.word	0x000a5245
c0d00da0:	72727563 	.word	0x72727563
c0d00da4:	5f746e65 	.word	0x5f746e65
c0d00da8:	676e656c 	.word	0x676e656c
c0d00dac:	203a6874 	.word	0x203a6874
c0d00db0:	000a6425 	.word	0x000a6425
c0d00db4:	41455243 	.word	0x41455243
c0d00db8:	5f5f4554 	.word	0x5f5f4554
c0d00dbc:	5346464f 	.word	0x5346464f
c0d00dc0:	415f5445 	.word	0x415f5445
c0d00dc4:	59415252 	.word	0x59415252
c0d00dc8:	5441425f 	.word	0x5441425f
c0d00dcc:	4e494843 	.word	0x4e494843
c0d00dd0:	4f545550 	.word	0x4f545550
c0d00dd4:	52454452 	.word	0x52454452
c0d00dd8:	6e69202c 	.word	0x6e69202c
c0d00ddc:	3a786564 	.word	0x3a786564
c0d00de0:	0a642520 	.word	0x0a642520
c0d00de4:	66666f00 	.word	0x66666f00
c0d00de8:	73746573 	.word	0x73746573
c0d00dec:	6c766c5f 	.word	0x6c766c5f
c0d00df0:	64255b30 	.word	0x64255b30
c0d00df4:	25203a5d 	.word	0x25203a5d
c0d00df8:	4e000a64 	.word	0x4e000a64
c0d00dfc:	4e20504f 	.word	0x4e20504f
c0d00e00:	4320504f 	.word	0x4320504f
c0d00e04:	54414552 	.word	0x54414552
c0d00e08:	425f5f45 	.word	0x425f5f45
c0d00e0c:	48435441 	.word	0x48435441
c0d00e10:	504e495f 	.word	0x504e495f
c0d00e14:	4f5f5455 	.word	0x4f5f5455
c0d00e18:	52454452 	.word	0x52454452
c0d00e1c:	50000a53 	.word	0x50000a53
c0d00e20:	6d617261 	.word	0x6d617261
c0d00e24:	746f6e20 	.word	0x746f6e20
c0d00e28:	70757320 	.word	0x70757320
c0d00e2c:	74726f70 	.word	0x74726f70
c0d00e30:	203a6465 	.word	0x203a6465
c0d00e34:	000a6425 	.word	0x000a6425
c0d00e38:	53524150 	.word	0x53524150
c0d00e3c:	20474e49 	.word	0x20474e49
c0d00e40:	204f4942 	.word	0x204f4942
c0d00e44:	70657473 	.word	0x70657473
c0d00e48:	6425203b 	.word	0x6425203b
c0d00e4c:	6170000a 	.word	0x6170000a
c0d00e50:	20657372 	.word	0x20657372
c0d00e54:	5f4f4942 	.word	0x5f4f4942
c0d00e58:	504e495f 	.word	0x504e495f
c0d00e5c:	4f545455 	.word	0x4f545455
c0d00e60:	0a4e454b 	.word	0x0a4e454b
c0d00e64:	72617000 	.word	0x72617000
c0d00e68:	42206573 	.word	0x42206573
c0d00e6c:	5f5f4f49 	.word	0x5f5f4f49
c0d00e70:	554f4d41 	.word	0x554f4d41
c0d00e74:	000a544e 	.word	0x000a544e
c0d00e78:	73726170 	.word	0x73726170
c0d00e7c:	49422065 	.word	0x49422065
c0d00e80:	4f5f5f4f 	.word	0x4f5f5f4f
c0d00e84:	45534646 	.word	0x45534646
c0d00e88:	524f5f54 	.word	0x524f5f54
c0d00e8c:	53524544 	.word	0x53524544
c0d00e90:	6170000a 	.word	0x6170000a
c0d00e94:	20657372 	.word	0x20657372
c0d00e98:	5f4f4942 	.word	0x5f4f4942
c0d00e9c:	4f52465f 	.word	0x4f52465f
c0d00ea0:	45525f4d 	.word	0x45525f4d
c0d00ea4:	56524553 	.word	0x56524553
c0d00ea8:	70000a45 	.word	0x70000a45
c0d00eac:	65737261 	.word	0x65737261
c0d00eb0:	4f494220 	.word	0x4f494220
c0d00eb4:	454c5f5f 	.word	0x454c5f5f
c0d00eb8:	524f5f4e 	.word	0x524f5f4e
c0d00ebc:	53524544 	.word	0x53524544
c0d00ec0:	6170000a 	.word	0x6170000a
c0d00ec4:	20657372 	.word	0x20657372
c0d00ec8:	5f4f4942 	.word	0x5f4f4942
c0d00ecc:	46464f5f 	.word	0x46464f5f
c0d00ed0:	5f544553 	.word	0x5f544553
c0d00ed4:	41525241 	.word	0x41525241
c0d00ed8:	524f5f59 	.word	0x524f5f59
c0d00edc:	53524544 	.word	0x53524544
c0d00ee0:	6e69202c 	.word	0x6e69202c
c0d00ee4:	3a786564 	.word	0x3a786564
c0d00ee8:	0a642520 	.word	0x0a642520
c0d00eec:	66666f00 	.word	0x66666f00
c0d00ef0:	73746573 	.word	0x73746573
c0d00ef4:	6c766c5f 	.word	0x6c766c5f
c0d00ef8:	64255b31 	.word	0x64255b31
c0d00efc:	25203a5d 	.word	0x25203a5d
c0d00f00:	70000a64 	.word	0x70000a64
c0d00f04:	65737261 	.word	0x65737261
c0d00f08:	4f494220 	.word	0x4f494220
c0d00f0c:	464f5f5f 	.word	0x464f5f5f
c0d00f10:	54455346 	.word	0x54455346
c0d00f14:	5252415f 	.word	0x5252415f
c0d00f18:	4f5f5941 	.word	0x4f5f5941
c0d00f1c:	52454452 	.word	0x52454452
c0d00f20:	414c2053 	.word	0x414c2053
c0d00f24:	000a5453 	.word	0x000a5453
c0d00f28:	53524150 	.word	0x53524150
c0d00f2c:	20474e49 	.word	0x20474e49
c0d00f30:	4544524f 	.word	0x4544524f
c0d00f34:	70000a52 	.word	0x70000a52
c0d00f38:	65737261 	.word	0x65737261
c0d00f3c:	44524f20 	.word	0x44524f20
c0d00f40:	5f5f5245 	.word	0x5f5f5245
c0d00f44:	5245504f 	.word	0x5245504f
c0d00f48:	524f5441 	.word	0x524f5441
c0d00f4c:	454e000a 	.word	0x454e000a
c0d00f50:	75632057 	.word	0x75632057
c0d00f54:	6e657272 	.word	0x6e657272
c0d00f58:	75745f74 	.word	0x75745f74
c0d00f5c:	5f656c70 	.word	0x5f656c70
c0d00f60:	7366666f 	.word	0x7366666f
c0d00f64:	203a7465 	.word	0x203a7465
c0d00f68:	000a6425 	.word	0x000a6425
c0d00f6c:	73726170 	.word	0x73726170
c0d00f70:	524f2065 	.word	0x524f2065
c0d00f74:	5f524544 	.word	0x5f524544
c0d00f78:	4b4f545f 	.word	0x4b4f545f
c0d00f7c:	415f4e45 	.word	0x415f4e45
c0d00f80:	45524444 	.word	0x45524444
c0d00f84:	000a5353 	.word	0x000a5353
c0d00f88:	73726170 	.word	0x73726170
c0d00f8c:	524f2065 	.word	0x524f2065
c0d00f90:	5f524544 	.word	0x5f524544
c0d00f94:	46464f5f 	.word	0x46464f5f
c0d00f98:	5f544553 	.word	0x5f544553
c0d00f9c:	4c4c4143 	.word	0x4c4c4143
c0d00fa0:	41544144 	.word	0x41544144
c0d00fa4:	6170000a 	.word	0x6170000a
c0d00fa8:	20657372 	.word	0x20657372
c0d00fac:	4544524f 	.word	0x4544524f
c0d00fb0:	4c5f5f52 	.word	0x4c5f5f52
c0d00fb4:	435f4e45 	.word	0x435f4e45
c0d00fb8:	444c4c41 	.word	0x444c4c41
c0d00fbc:	0a415441 	.word	0x0a415441
c0d00fc0:	72617000 	.word	0x72617000
c0d00fc4:	4f206573 	.word	0x4f206573
c0d00fc8:	52454452 	.word	0x52454452
c0d00fcc:	41435f5f 	.word	0x41435f5f
c0d00fd0:	41444c4c 	.word	0x41444c4c
c0d00fd4:	000a4154 	.word	0x000a4154
c0d00fd8:	5a4e4550 	.word	0x5a4e4550
c0d00fdc:	7469204f 	.word	0x7469204f
c0d00fe0:	0a316d65 	.word	0x0a316d65
c0d00fe4:	4e455000 	.word	0x4e455000
c0d00fe8:	6e204f5a 	.word	0x6e204f5a
c0d00fec:	7469206f 	.word	0x7469206f
c0d00ff0:	0a316d65 	.word	0x0a316d65
c0d00ff4:	00          	.byte	0x00
c0d00ff5:	4e          	.byte	0x4e
c0d00ff6:	7365      	.short	0x7365
c0d00ff8:	20646574 	.word	0x20646574
c0d00ffc:	616e6946 	.word	0x616e6946
c0d01000:	0065636e 	.word	0x0065636e
c0d01004:	746e6f63 	.word	0x746e6f63
c0d01008:	2d747865 	.word	0x2d747865
c0d0100c:	6f6f623e 	.word	0x6f6f623e
c0d01010:	6e61656c 	.word	0x6e61656c
c0d01014:	20262073 	.word	0x20262073
c0d01018:	435f5349 	.word	0x435f5349
c0d0101c:	3a59504f 	.word	0x3a59504f
c0d01020:	0a642520 	.word	0x0a642520
c0d01024:	706f4300 	.word	0x706f4300
c0d01028:	72430079 	.word	0x72430079
c0d0102c:	65746165 	.word	0x65746165
c0d01030:	6c655300 	.word	0x6c655300
c0d01034:	6f746365 	.word	0x6f746365
c0d01038:	6e692072 	.word	0x6e692072
c0d0103c:	3a786564 	.word	0x3a786564
c0d01040:	20642520 	.word	0x20642520
c0d01044:	20746f6e 	.word	0x20746f6e
c0d01048:	70707573 	.word	0x70707573
c0d0104c:	6574726f 	.word	0x6574726f
c0d01050:	0a64      	.short	0x0a64
c0d01052:	00          	.byte	0x00
c0d01053:	70          	.byte	0x70
c0d01054:	6563616c 	.word	0x6563616c
c0d01058:	646c6f68 	.word	0x646c6f68
c0d0105c:	52007265 	.word	0x52007265
c0d01060:	69656365 	.word	0x69656365
c0d01064:	20646576 	.word	0x20646576
c0d01068:	69206e61 	.word	0x69206e61
c0d0106c:	6c61766e 	.word	0x6c61766e
c0d01070:	73206469 	.word	0x73206469
c0d01074:	65657263 	.word	0x65657263
c0d01078:	646e496e 	.word	0x646e496e
c0d0107c:	000a7865 	.word	0x000a7865
c0d01080:	61686e55 	.word	0x61686e55
c0d01084:	656c646e 	.word	0x656c646e
c0d01088:	656d2064 	.word	0x656d2064
c0d0108c:	67617373 	.word	0x67617373
c0d01090:	64252065 	.word	0x64252065
c0d01094:	7445000a 	.word	0x7445000a
c0d01098:	65726568 	.word	0x65726568
c0d0109c:	6d75      	.short	0x6d75
	...

c0d0109f <g_pcHex>:
c0d0109f:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef

c0d010af <g_pcHex_cap>:
c0d010af:	3130 3332 3534 3736 3938 4241 4443 4645     0123456789ABCDEF
	...

c0d010c0 <NESTED_SELECTORS>:
c0d010c0:	534b a378 7094 5122                         KSx..p"Q

c0d010c8 <_etext>:
	...
