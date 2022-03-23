
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
c0d00008:	f000 fb36 	bl	c0d00678 <os_boot>
c0d0000c:	ad01      	add	r5, sp, #4

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY
    {
        TRY
c0d0000e:	4628      	mov	r0, r5
c0d00010:	f000 fe47 	bl	c0d00ca2 <setjmp>
c0d00014:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0d00016:	0400      	lsls	r0, r0, #16
c0d00018:	d117      	bne.n	c0d0004a <main+0x4a>
c0d0001a:	a801      	add	r0, sp, #4
c0d0001c:	f000 fd58 	bl	c0d00ad0 <try_context_set>
c0d00020:	900b      	str	r0, [sp, #44]	; 0x2c
// get API level
SYSCALL unsigned int get_api_level(void);

#ifndef HAVE_BOLOS
static inline void check_api_level(unsigned int apiLevel) {
  if (apiLevel < get_api_level()) {
c0d00022:	f000 fd13 	bl	c0d00a4c <get_api_level>
c0d00026:	280d      	cmp	r0, #13
c0d00028:	d302      	bcc.n	c0d00030 <main+0x30>
c0d0002a:	20ff      	movs	r0, #255	; 0xff
    os_sched_exit(-1);
c0d0002c:	f000 fd36 	bl	c0d00a9c <os_sched_exit>
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
c0d00042:	f000 fadd 	bl	c0d00600 <dispatch_plugin_calls>
                }
                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
c0d00046:	f000 fd1d 	bl	c0d00a84 <os_lib_end>
            }
        }
        FINALLY
c0d0004a:	f000 fd35 	bl	c0d00ab8 <try_context_get>
c0d0004e:	a901      	add	r1, sp, #4
c0d00050:	4288      	cmp	r0, r1
c0d00052:	d102      	bne.n	c0d0005a <main+0x5a>
c0d00054:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d00056:	f000 fd3b 	bl	c0d00ad0 <try_context_set>
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
c0d00074:	f000 fcf8 	bl	c0d00a68 <os_lib_call>
c0d00078:	e7f3      	b.n	c0d00062 <main+0x62>
    END_TRY;
c0d0007a:	f000 fb02 	bl	c0d00682 <os_longjmp>
c0d0007e:	46c0      	nop			; (mov r8, r8)
c0d00080:	00001236 	.word	0x00001236

c0d00084 <handle_finalize>:
#include "nested_plugin.h"

void handle_finalize(void *parameters)
{
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
    context_t *context = (context_t *)msg->pluginContext;
c0d0008e:	6881      	ldr	r1, [r0, #8]
    msg->tokenLookup1 = context->token_received;
c0d00090:	3135      	adds	r1, #53	; 0x35
c0d00092:	60c1      	str	r1, [r0, #12]
}
c0d00094:	4770      	bx	lr
	...

c0d00098 <handle_init_contract>:
    return -1;
}

// Called once to init.
void handle_init_contract(void *parameters)
{
c0d00098:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0009a:	b081      	sub	sp, #4
c0d0009c:	4604      	mov	r4, r0
    PRINTF("IN handle_init_contract\n");
c0d0009e:	4830      	ldr	r0, [pc, #192]	; (c0d00160 <handle_init_contract+0xc8>)
c0d000a0:	4478      	add	r0, pc
c0d000a2:	f000 faf5 	bl	c0d00690 <semihosted_printf>
    // Cast the msg to the type of structure we expect (here, ethPluginInitContract_t).
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *)parameters;

    // Make sure we are running a compatible version.
    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST)
c0d000a6:	7820      	ldrb	r0, [r4, #0]
c0d000a8:	2701      	movs	r7, #1
c0d000aa:	2804      	cmp	r0, #4
c0d000ac:	d129      	bne.n	c0d00102 <handle_init_contract+0x6a>
        return;
    }

    // Double check that the `context_t` struct is not bigger than the maximum size (defined by
    // `msg->pluginContextLength`).
    if (msg->pluginContextLength < sizeof(context_t))
c0d000ae:	6920      	ldr	r0, [r4, #16]
c0d000b0:	2877      	cmp	r0, #119	; 0x77
c0d000b2:	d805      	bhi.n	c0d000c0 <handle_init_contract+0x28>
    {
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
c0d000b4:	482b      	ldr	r0, [pc, #172]	; (c0d00164 <handle_init_contract+0xcc>)
c0d000b6:	4478      	add	r0, pc
c0d000b8:	f000 faea 	bl	c0d00690 <semihosted_printf>
c0d000bc:	2600      	movs	r6, #0
c0d000be:	e021      	b.n	c0d00104 <handle_init_contract+0x6c>
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    context_t *context = (context_t *)msg->pluginContext;
c0d000c0:	68e5      	ldr	r5, [r4, #12]
c0d000c2:	2178      	movs	r1, #120	; 0x78

    // Initialize the context (to 0).
    memset(context, 0, sizeof(*context));
c0d000c4:	4628      	mov	r0, r5
c0d000c6:	f000 fdcb 	bl	c0d00c60 <__aeabi_memclr>
c0d000ca:	2604      	movs	r6, #4
    context->current_tuple_offset = SELECTOR_SIZE;
c0d000cc:	662e      	str	r6, [r5, #96]	; 0x60

    uint32_t selector = U4BE(msg->selector, 0);
c0d000ce:	6960      	ldr	r0, [r4, #20]
   ((lo0)&0xFFu))
static inline uint16_t U2BE(const uint8_t *buf, size_t off) {
  return (buf[off] << 8) | buf[off + 1];
}
static inline uint32_t U4BE(const uint8_t *buf, size_t off) {
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d000d0:	7801      	ldrb	r1, [r0, #0]
c0d000d2:	0609      	lsls	r1, r1, #24
c0d000d4:	7842      	ldrb	r2, [r0, #1]
c0d000d6:	0412      	lsls	r2, r2, #16
c0d000d8:	1851      	adds	r1, r2, r1
         (buf[off + 2] << 8) | buf[off + 3];
c0d000da:	7882      	ldrb	r2, [r0, #2]
c0d000dc:	0212      	lsls	r2, r2, #8
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d000de:	1889      	adds	r1, r1, r2
         (buf[off + 2] << 8) | buf[off + 3];
c0d000e0:	78c0      	ldrb	r0, [r0, #3]
c0d000e2:	1808      	adds	r0, r1, r0
c0d000e4:	3557      	adds	r5, #87	; 0x57
c0d000e6:	2100      	movs	r1, #0
c0d000e8:	4a1f      	ldr	r2, [pc, #124]	; (c0d00168 <handle_init_contract+0xd0>)
c0d000ea:	447a      	add	r2, pc
        if (selector == selectors[i])
c0d000ec:	6813      	ldr	r3, [r2, #0]
c0d000ee:	4283      	cmp	r3, r0
c0d000f0:	d00b      	beq.n	c0d0010a <handle_init_contract+0x72>
    for (selector_t i = 0; i < n; i++)
c0d000f2:	1d12      	adds	r2, r2, #4
c0d000f4:	1c49      	adds	r1, r1, #1
c0d000f6:	2906      	cmp	r1, #6
c0d000f8:	d1f8      	bne.n	c0d000ec <handle_init_contract+0x54>
    if (find_selector(selector, NESTED_SELECTORS, NUM_SELECTORS, &context->selectorIndex))
    {
        PRINTF("can't find selector\n");
c0d000fa:	481c      	ldr	r0, [pc, #112]	; (c0d0016c <handle_init_contract+0xd4>)
c0d000fc:	4478      	add	r0, pc
c0d000fe:	f000 fac7 	bl	c0d00690 <semihosted_printf>
c0d00102:	463e      	mov	r6, r7
c0d00104:	7066      	strb	r6, [r4, #1]
        return;
    }

    // Return valid status.
    msg->result = ETH_PLUGIN_RESULT_OK;
}
c0d00106:	b001      	add	sp, #4
c0d00108:	bdf0      	pop	{r4, r5, r6, r7, pc}
            *out = i;
c0d0010a:	7769      	strb	r1, [r5, #29]
    switch (context->selectorIndex)
c0d0010c:	b2c8      	uxtb	r0, r1
c0d0010e:	2802      	cmp	r0, #2
c0d00110:	dc08      	bgt.n	c0d00124 <handle_init_contract+0x8c>
c0d00112:	2800      	cmp	r0, #0
c0d00114:	d00f      	beq.n	c0d00136 <handle_init_contract+0x9e>
c0d00116:	2801      	cmp	r0, #1
c0d00118:	d010      	beq.n	c0d0013c <handle_init_contract+0xa4>
c0d0011a:	2802      	cmp	r0, #2
c0d0011c:	d11b      	bne.n	c0d00156 <handle_init_contract+0xbe>
c0d0011e:	4815      	ldr	r0, [pc, #84]	; (c0d00174 <handle_init_contract+0xdc>)
c0d00120:	4478      	add	r0, pc
c0d00122:	e013      	b.n	c0d0014c <handle_init_contract+0xb4>
c0d00124:	2803      	cmp	r0, #3
c0d00126:	d00c      	beq.n	c0d00142 <handle_init_contract+0xaa>
c0d00128:	2804      	cmp	r0, #4
c0d0012a:	d00d      	beq.n	c0d00148 <handle_init_contract+0xb0>
c0d0012c:	2805      	cmp	r0, #5
c0d0012e:	d112      	bne.n	c0d00156 <handle_init_contract+0xbe>
c0d00130:	4811      	ldr	r0, [pc, #68]	; (c0d00178 <handle_init_contract+0xe0>)
c0d00132:	4478      	add	r0, pc
c0d00134:	e00a      	b.n	c0d0014c <handle_init_contract+0xb4>
c0d00136:	480e      	ldr	r0, [pc, #56]	; (c0d00170 <handle_init_contract+0xd8>)
c0d00138:	4478      	add	r0, pc
c0d0013a:	e007      	b.n	c0d0014c <handle_init_contract+0xb4>
c0d0013c:	4812      	ldr	r0, [pc, #72]	; (c0d00188 <handle_init_contract+0xf0>)
c0d0013e:	4478      	add	r0, pc
c0d00140:	e004      	b.n	c0d0014c <handle_init_contract+0xb4>
c0d00142:	480e      	ldr	r0, [pc, #56]	; (c0d0017c <handle_init_contract+0xe4>)
c0d00144:	4478      	add	r0, pc
c0d00146:	e001      	b.n	c0d0014c <handle_init_contract+0xb4>
c0d00148:	480d      	ldr	r0, [pc, #52]	; (c0d00180 <handle_init_contract+0xe8>)
c0d0014a:	4478      	add	r0, pc
c0d0014c:	f000 faa0 	bl	c0d00690 <semihosted_printf>
c0d00150:	2001      	movs	r0, #1
c0d00152:	7028      	strb	r0, [r5, #0]
c0d00154:	e7d6      	b.n	c0d00104 <handle_init_contract+0x6c>
        PRINTF("Missing selectorIndex: %d\n", context->selectorIndex);
c0d00156:	480b      	ldr	r0, [pc, #44]	; (c0d00184 <handle_init_contract+0xec>)
c0d00158:	4478      	add	r0, pc
c0d0015a:	f000 fa99 	bl	c0d00690 <semihosted_printf>
c0d0015e:	e7ad      	b.n	c0d000bc <handle_init_contract+0x24>
c0d00160:	00000c7e 	.word	0x00000c7e
c0d00164:	00000c81 	.word	0x00000c81
c0d00168:	000011e6 	.word	0x000011e6
c0d0016c:	00000c74 	.word	0x00000c74
c0d00170:	00000c4d 	.word	0x00000c4d
c0d00174:	00000c89 	.word	0x00000c89
c0d00178:	00000cb0 	.word	0x00000cb0
c0d0017c:	00000c7f 	.word	0x00000c7f
c0d00180:	00000c85 	.word	0x00000c85
c0d00184:	00000c9c 	.word	0x00000c9c
c0d00188:	00000c52 	.word	0x00000c52

c0d0018c <copy_offset>:
#include "nested_plugin.h"

void copy_offset(ethPluginProvideParameter_t *msg, context_t *context)
{
c0d0018c:	b5b0      	push	{r4, r5, r7, lr}
c0d0018e:	460c      	mov	r4, r1
c0d00190:	4605      	mov	r5, r0
    PRINTF("msg->parameterOffset: %d\n", msg->parameterOffset);
c0d00192:	6901      	ldr	r1, [r0, #16]
c0d00194:	480d      	ldr	r0, [pc, #52]	; (c0d001cc <copy_offset+0x40>)
c0d00196:	4478      	add	r0, pc
c0d00198:	f000 fa7a 	bl	c0d00690 <semihosted_printf>
    uint32_t test = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d0019c:	68e8      	ldr	r0, [r5, #12]
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d0019e:	7f01      	ldrb	r1, [r0, #28]
c0d001a0:	0609      	lsls	r1, r1, #24
c0d001a2:	7f42      	ldrb	r2, [r0, #29]
c0d001a4:	0412      	lsls	r2, r2, #16
c0d001a6:	1851      	adds	r1, r2, r1
         (buf[off + 2] << 8) | buf[off + 3];
c0d001a8:	7f82      	ldrb	r2, [r0, #30]
c0d001aa:	0212      	lsls	r2, r2, #8
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
c0d001ac:	1889      	adds	r1, r1, r2
         (buf[off + 2] << 8) | buf[off + 3];
c0d001ae:	7fc0      	ldrb	r0, [r0, #31]
c0d001b0:	180d      	adds	r5, r1, r0
    PRINTF("U4BE msg->parameter: %d\n", test);
c0d001b2:	4807      	ldr	r0, [pc, #28]	; (c0d001d0 <copy_offset+0x44>)
c0d001b4:	4478      	add	r0, pc
c0d001b6:	4629      	mov	r1, r5
c0d001b8:	f000 fa6a 	bl	c0d00690 <semihosted_printf>
    context->next_offset = test + context->current_tuple_offset;
c0d001bc:	6e20      	ldr	r0, [r4, #96]	; 0x60
c0d001be:	1829      	adds	r1, r5, r0
c0d001c0:	6661      	str	r1, [r4, #100]	; 0x64
    PRINTF("copied offset: %d\n", context->next_offset);
c0d001c2:	4804      	ldr	r0, [pc, #16]	; (c0d001d4 <copy_offset+0x48>)
c0d001c4:	4478      	add	r0, pc
c0d001c6:	f000 fa63 	bl	c0d00690 <semihosted_printf>
}
c0d001ca:	bdb0      	pop	{r4, r5, r7, pc}
c0d001cc:	00000c79 	.word	0x00000c79
c0d001d0:	00000c75 	.word	0x00000c75
c0d001d4:	00000c7e 	.word	0x00000c7e

c0d001d8 <handle_provide_parameter>:
    }
    context->next_param++;
}

void handle_provide_parameter(void *parameters)
{
c0d001d8:	b570      	push	{r4, r5, r6, lr}
c0d001da:	4604      	mov	r4, r0
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;
c0d001dc:	6885      	ldr	r5, [r0, #8]
    // the number of bytes you wish to print (in this case, `PARAMETER_LENGTH`) and then
    // the address (here `msg->parameter`).
    PRINTF("plugin provide parameter: offset %d\nBytes: \033[0;31m %.*H \033[0m \n",
           msg->parameterOffset,
           PARAMETER_LENGTH,
           msg->parameter);
c0d001de:	68c3      	ldr	r3, [r0, #12]
           msg->parameterOffset,
c0d001e0:	6901      	ldr	r1, [r0, #16]
    PRINTF("plugin provide parameter: offset %d\nBytes: \033[0;31m %.*H \033[0m \n",
c0d001e2:	480f      	ldr	r0, [pc, #60]	; (c0d00220 <handle_provide_parameter+0x48>)
c0d001e4:	4478      	add	r0, pc
c0d001e6:	2220      	movs	r2, #32
c0d001e8:	f000 fa52 	bl	c0d00690 <semihosted_printf>
c0d001ec:	2604      	movs	r6, #4

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d001ee:	7526      	strb	r6, [r4, #20]
c0d001f0:	2074      	movs	r0, #116	; 0x74

    switch (context->selectorIndex)
c0d001f2:	5c29      	ldrb	r1, [r5, r0]
c0d001f4:	1e88      	subs	r0, r1, #2
c0d001f6:	2802      	cmp	r0, #2
c0d001f8:	d308      	bcc.n	c0d0020c <handle_provide_parameter+0x34>
c0d001fa:	2901      	cmp	r1, #1
c0d001fc:	d007      	beq.n	c0d0020e <handle_provide_parameter+0x36>
c0d001fe:	2900      	cmp	r1, #0
c0d00200:	d009      	beq.n	c0d00216 <handle_provide_parameter+0x3e>
    case PROCESS_OUTPUT_ORDERS:
        break;
    case DESTROY:
        break;
    default:
        PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
c0d00202:	4809      	ldr	r0, [pc, #36]	; (c0d00228 <handle_provide_parameter+0x50>)
c0d00204:	4478      	add	r0, pc
c0d00206:	f000 fa43 	bl	c0d00690 <semihosted_printf>
        // msg->result = ETH_PLUGIN_RESULT_ERROR;
        msg->result = ETH_PLUGIN_RESULT_OK;
c0d0020a:	7526      	strb	r6, [r4, #20]
        break;
    }
c0d0020c:	bd70      	pop	{r4, r5, r6, pc}
        PRINTF("handle_provide_parameter IN PBIO\n");
c0d0020e:	4805      	ldr	r0, [pc, #20]	; (c0d00224 <handle_provide_parameter+0x4c>)
c0d00210:	4478      	add	r0, pc
c0d00212:	f000 fa3d 	bl	c0d00690 <semihosted_printf>
c0d00216:	4620      	mov	r0, r4
c0d00218:	4629      	mov	r1, r5
c0d0021a:	f000 f807 	bl	c0d0022c <handle_create>
c0d0021e:	bd70      	pop	{r4, r5, r6, pc}
c0d00220:	00000c71 	.word	0x00000c71
c0d00224:	00000c84 	.word	0x00000c84
c0d00228:	00000cb2 	.word	0x00000cb2

c0d0022c <handle_create>:
{
c0d0022c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0022e:	b081      	sub	sp, #4
c0d00230:	460c      	mov	r4, r1
c0d00232:	4605      	mov	r5, r0
    if (context->on_struct)
c0d00234:	7808      	ldrb	r0, [r1, #0]
c0d00236:	460e      	mov	r6, r1
c0d00238:	3657      	adds	r6, #87	; 0x57
c0d0023a:	460f      	mov	r7, r1
c0d0023c:	3768      	adds	r7, #104	; 0x68
c0d0023e:	2800      	cmp	r0, #0
c0d00240:	d018      	beq.n	c0d00274 <handle_create+0x48>
c0d00242:	2803      	cmp	r0, #3
c0d00244:	d029      	beq.n	c0d0029a <handle_create+0x6e>
c0d00246:	2801      	cmp	r0, #1
c0d00248:	d000      	beq.n	c0d0024c <handle_create+0x20>
c0d0024a:	e0e4      	b.n	c0d00416 <handle_create+0x1ea>
    PRINTF("PARSING BIO step; %d\n", context->next_param);
c0d0024c:	7831      	ldrb	r1, [r6, #0]
c0d0024e:	4877      	ldr	r0, [pc, #476]	; (c0d0042c <handle_create+0x200>)
c0d00250:	4478      	add	r0, pc
c0d00252:	f000 fa1d 	bl	c0d00690 <semihosted_printf>
    switch ((batch_input_orders)context->next_param)
c0d00256:	7830      	ldrb	r0, [r6, #0]
c0d00258:	2802      	cmp	r0, #2
c0d0025a:	dc2f      	bgt.n	c0d002bc <handle_create+0x90>
c0d0025c:	2800      	cmp	r0, #0
c0d0025e:	d100      	bne.n	c0d00262 <handle_create+0x36>
c0d00260:	e0b6      	b.n	c0d003d0 <handle_create+0x1a4>
c0d00262:	2801      	cmp	r0, #1
c0d00264:	d100      	bne.n	c0d00268 <handle_create+0x3c>
c0d00266:	e0ba      	b.n	c0d003de <handle_create+0x1b2>
c0d00268:	2802      	cmp	r0, #2
c0d0026a:	d000      	beq.n	c0d0026e <handle_create+0x42>
c0d0026c:	e0d0      	b.n	c0d00410 <handle_create+0x1e4>
        PRINTF("parse BIO__OFFSET_ORDERS\n");
c0d0026e:	4870      	ldr	r0, [pc, #448]	; (c0d00430 <handle_create+0x204>)
c0d00270:	4478      	add	r0, pc
c0d00272:	e086      	b.n	c0d00382 <handle_create+0x156>
    PRINTF("PARSING CREATE\n");
c0d00274:	487e      	ldr	r0, [pc, #504]	; (c0d00470 <handle_create+0x244>)
c0d00276:	4478      	add	r0, pc
c0d00278:	f000 fa0a 	bl	c0d00690 <semihosted_printf>
    switch ((create_parameter)context->next_param)
c0d0027c:	7831      	ldrb	r1, [r6, #0]
c0d0027e:	2902      	cmp	r1, #2
c0d00280:	dd4b      	ble.n	c0d0031a <handle_create+0xee>
c0d00282:	2903      	cmp	r1, #3
c0d00284:	d057      	beq.n	c0d00336 <handle_create+0x10a>
c0d00286:	2904      	cmp	r1, #4
c0d00288:	d058      	beq.n	c0d0033c <handle_create+0x110>
c0d0028a:	2905      	cmp	r1, #5
c0d0028c:	d000      	beq.n	c0d00290 <handle_create+0x64>
c0d0028e:	e08f      	b.n	c0d003b0 <handle_create+0x184>
        PRINTF("NOP NOP CREATE__BATCH_INPUT_ORDERS\n");
c0d00290:	4879      	ldr	r0, [pc, #484]	; (c0d00478 <handle_create+0x24c>)
c0d00292:	4478      	add	r0, pc
c0d00294:	f000 f9fc 	bl	c0d00690 <semihosted_printf>
c0d00298:	e0bd      	b.n	c0d00416 <handle_create+0x1ea>
    PRINTF("PARSING ORDER\n");
c0d0029a:	486e      	ldr	r0, [pc, #440]	; (c0d00454 <handle_create+0x228>)
c0d0029c:	4478      	add	r0, pc
c0d0029e:	f000 f9f7 	bl	c0d00690 <semihosted_printf>
    switch ((order)context->next_param)
c0d002a2:	7830      	ldrb	r0, [r6, #0]
c0d002a4:	2801      	cmp	r0, #1
c0d002a6:	dd3f      	ble.n	c0d00328 <handle_create+0xfc>
c0d002a8:	2802      	cmp	r0, #2
c0d002aa:	d068      	beq.n	c0d0037e <handle_create+0x152>
c0d002ac:	2803      	cmp	r0, #3
c0d002ae:	d06f      	beq.n	c0d00390 <handle_create+0x164>
c0d002b0:	2804      	cmp	r0, #4
c0d002b2:	d000      	beq.n	c0d002b6 <handle_create+0x8a>
c0d002b4:	e0ac      	b.n	c0d00410 <handle_create+0x1e4>
        PRINTF("parse ORDER__CALLDATA\n");
c0d002b6:	4869      	ldr	r0, [pc, #420]	; (c0d0045c <handle_create+0x230>)
c0d002b8:	4478      	add	r0, pc
c0d002ba:	e095      	b.n	c0d003e8 <handle_create+0x1bc>
    switch ((batch_input_orders)context->next_param)
c0d002bc:	2803      	cmp	r0, #3
c0d002be:	d100      	bne.n	c0d002c2 <handle_create+0x96>
c0d002c0:	e090      	b.n	c0d003e4 <handle_create+0x1b8>
c0d002c2:	2804      	cmp	r0, #4
c0d002c4:	d100      	bne.n	c0d002c8 <handle_create+0x9c>
c0d002c6:	e092      	b.n	c0d003ee <handle_create+0x1c2>
c0d002c8:	2805      	cmp	r0, #5
c0d002ca:	d000      	beq.n	c0d002ce <handle_create+0xa2>
c0d002cc:	e0a0      	b.n	c0d00410 <handle_create+0x1e4>
        context->length_offset_array--;
c0d002ce:	7ab8      	ldrb	r0, [r7, #10]
c0d002d0:	1e40      	subs	r0, r0, #1
c0d002d2:	72b8      	strb	r0, [r7, #10]
        PRINTF("parse BIO__OFFSET_ARRAY_ORDERS, index: %d\n", context->length_offset_array);
c0d002d4:	b2c1      	uxtb	r1, r0
c0d002d6:	4857      	ldr	r0, [pc, #348]	; (c0d00434 <handle_create+0x208>)
c0d002d8:	4478      	add	r0, pc
c0d002da:	f000 f9d9 	bl	c0d00690 <semihosted_printf>
        if (context->length_offset_array < 2)
c0d002de:	7ab9      	ldrb	r1, [r7, #10]
c0d002e0:	2901      	cmp	r1, #1
c0d002e2:	d900      	bls.n	c0d002e6 <handle_create+0xba>
c0d002e4:	e097      	b.n	c0d00416 <handle_create+0x1ea>
            context->offsets_lvl1[context->length_offset_array] =
c0d002e6:	0048      	lsls	r0, r1, #1
c0d002e8:	1820      	adds	r0, r4, r0
                U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d002ea:	68ea      	ldr	r2, [r5, #12]
c0d002ec:	7fd3      	ldrb	r3, [r2, #31]
c0d002ee:	7f92      	ldrb	r2, [r2, #30]
c0d002f0:	0212      	lsls	r2, r2, #8
c0d002f2:	18d2      	adds	r2, r2, r3
c0d002f4:	236e      	movs	r3, #110	; 0x6e
            context->offsets_lvl1[context->length_offset_array] =
c0d002f6:	52c2      	strh	r2, [r0, r3]
                   context->offsets_lvl1[context->length_offset_array]);
c0d002f8:	b292      	uxth	r2, r2
            PRINTF("offsets_lvl1[%d]: %d\n",
c0d002fa:	484f      	ldr	r0, [pc, #316]	; (c0d00438 <handle_create+0x20c>)
c0d002fc:	4478      	add	r0, pc
c0d002fe:	f000 f9c7 	bl	c0d00690 <semihosted_printf>
        if (context->length_offset_array == 0)
c0d00302:	7ab8      	ldrb	r0, [r7, #10]
c0d00304:	2800      	cmp	r0, #0
c0d00306:	d000      	beq.n	c0d0030a <handle_create+0xde>
c0d00308:	e085      	b.n	c0d00416 <handle_create+0x1ea>
            PRINTF("parse BIO__OFFSET_ARRAY_ORDERS LAST\n");
c0d0030a:	484c      	ldr	r0, [pc, #304]	; (c0d0043c <handle_create+0x210>)
c0d0030c:	4478      	add	r0, pc
c0d0030e:	f000 f9bf 	bl	c0d00690 <semihosted_printf>
c0d00312:	2000      	movs	r0, #0
            context->next_param = (batch_input_orders)ORDER__OPERATOR;
c0d00314:	7030      	strb	r0, [r6, #0]
c0d00316:	2003      	movs	r0, #3
c0d00318:	e02f      	b.n	c0d0037a <handle_create+0x14e>
    switch ((create_parameter)context->next_param)
c0d0031a:	2901      	cmp	r1, #1
c0d0031c:	d03b      	beq.n	c0d00396 <handle_create+0x16a>
c0d0031e:	2902      	cmp	r1, #2
c0d00320:	d146      	bne.n	c0d003b0 <handle_create+0x184>
        PRINTF("CREATE__OFFSET_BATCHINPUTORDER\n");
c0d00322:	4854      	ldr	r0, [pc, #336]	; (c0d00474 <handle_create+0x248>)
c0d00324:	4478      	add	r0, pc
c0d00326:	e02c      	b.n	c0d00382 <handle_create+0x156>
    switch ((order)context->next_param)
c0d00328:	2800      	cmp	r0, #0
c0d0032a:	d048      	beq.n	c0d003be <handle_create+0x192>
c0d0032c:	2801      	cmp	r0, #1
c0d0032e:	d16f      	bne.n	c0d00410 <handle_create+0x1e4>
        PRINTF("parse ORDER__TOKEN_ADDRESS\n");
c0d00330:	4849      	ldr	r0, [pc, #292]	; (c0d00458 <handle_create+0x22c>)
c0d00332:	4478      	add	r0, pc
c0d00334:	e058      	b.n	c0d003e8 <handle_create+0x1bc>
        PRINTF("CREATE__LEN_BATCHINPUTORDER\n");
c0d00336:	4853      	ldr	r0, [pc, #332]	; (c0d00484 <handle_create+0x258>)
c0d00338:	4478      	add	r0, pc
c0d0033a:	e05a      	b.n	c0d003f2 <handle_create+0x1c6>
        context->length_offset_array--;
c0d0033c:	7ab8      	ldrb	r0, [r7, #10]
c0d0033e:	1e40      	subs	r0, r0, #1
c0d00340:	72b8      	strb	r0, [r7, #10]
               context->length_offset_array);
c0d00342:	b2c1      	uxtb	r1, r0
        PRINTF("CREATE__OFFSET_ARRAY_BATCHINPUTORDER, index: %d\n",
c0d00344:	4850      	ldr	r0, [pc, #320]	; (c0d00488 <handle_create+0x25c>)
c0d00346:	4478      	add	r0, pc
c0d00348:	f000 f9a2 	bl	c0d00690 <semihosted_printf>
        if (context->length_offset_array < 2)
c0d0034c:	7ab9      	ldrb	r1, [r7, #10]
c0d0034e:	2901      	cmp	r1, #1
c0d00350:	d861      	bhi.n	c0d00416 <handle_create+0x1ea>
            context->offsets_lvl0[context->length_offset_array] =
c0d00352:	0048      	lsls	r0, r1, #1
c0d00354:	1820      	adds	r0, r4, r0
                U4BE(msg->parameter, PARAMETER_LENGTH - 4);
c0d00356:	68ea      	ldr	r2, [r5, #12]
c0d00358:	7fd3      	ldrb	r3, [r2, #31]
c0d0035a:	7f92      	ldrb	r2, [r2, #30]
c0d0035c:	0212      	lsls	r2, r2, #8
c0d0035e:	18d2      	adds	r2, r2, r3
c0d00360:	236a      	movs	r3, #106	; 0x6a
            context->offsets_lvl0[context->length_offset_array] =
c0d00362:	52c2      	strh	r2, [r0, r3]
                   context->offsets_lvl0[context->length_offset_array]);
c0d00364:	b292      	uxth	r2, r2
            PRINTF("offsets_lvl0[%d]: %d\n",
c0d00366:	4849      	ldr	r0, [pc, #292]	; (c0d0048c <handle_create+0x260>)
c0d00368:	4478      	add	r0, pc
c0d0036a:	f000 f991 	bl	c0d00690 <semihosted_printf>
        if (context->length_offset_array == 0)
c0d0036e:	7ab8      	ldrb	r0, [r7, #10]
c0d00370:	2800      	cmp	r0, #0
c0d00372:	d150      	bne.n	c0d00416 <handle_create+0x1ea>
c0d00374:	2000      	movs	r0, #0
            context->next_param = (batch_input_orders)BIO__INPUTTOKEN;
c0d00376:	7030      	strb	r0, [r6, #0]
c0d00378:	2001      	movs	r0, #1
c0d0037a:	7020      	strb	r0, [r4, #0]
c0d0037c:	e04b      	b.n	c0d00416 <handle_create+0x1ea>
        PRINTF("parse ORDER__OFFSET_CALLDATA\n");
c0d0037e:	483a      	ldr	r0, [pc, #232]	; (c0d00468 <handle_create+0x23c>)
c0d00380:	4478      	add	r0, pc
c0d00382:	f000 f985 	bl	c0d00690 <semihosted_printf>
c0d00386:	4628      	mov	r0, r5
c0d00388:	4621      	mov	r1, r4
c0d0038a:	f7ff feff 	bl	c0d0018c <copy_offset>
c0d0038e:	e03f      	b.n	c0d00410 <handle_create+0x1e4>
        PRINTF("parse ORDER__LEN_CALLDATA\n");
c0d00390:	4836      	ldr	r0, [pc, #216]	; (c0d0046c <handle_create+0x240>)
c0d00392:	4478      	add	r0, pc
c0d00394:	e028      	b.n	c0d003e8 <handle_create+0x1bc>
        PRINTF("CREATE__TOKEN_ID\n");
c0d00396:	4839      	ldr	r0, [pc, #228]	; (c0d0047c <handle_create+0x250>)
c0d00398:	4478      	add	r0, pc
c0d0039a:	f000 f979 	bl	c0d00690 <semihosted_printf>
c0d0039e:	68e8      	ldr	r0, [r5, #12]
c0d003a0:	2100      	movs	r1, #0
            if (msg->parameter[i] != 0)
c0d003a2:	5c42      	ldrb	r2, [r0, r1]
c0d003a4:	2a00      	cmp	r2, #0
c0d003a6:	d138      	bne.n	c0d0041a <handle_create+0x1ee>
        for (uint8_t i = 0; i < PARAMETER_LENGTH; i++)
c0d003a8:	1c49      	adds	r1, r1, #1
c0d003aa:	2920      	cmp	r1, #32
c0d003ac:	d1f9      	bne.n	c0d003a2 <handle_create+0x176>
c0d003ae:	e02f      	b.n	c0d00410 <handle_create+0x1e4>
        PRINTF("Param not supported: %d\n", context->next_param);
c0d003b0:	4837      	ldr	r0, [pc, #220]	; (c0d00490 <handle_create+0x264>)
c0d003b2:	4478      	add	r0, pc
c0d003b4:	f000 f96c 	bl	c0d00690 <semihosted_printf>
c0d003b8:	2000      	movs	r0, #0
        msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d003ba:	7528      	strb	r0, [r5, #20]
c0d003bc:	e028      	b.n	c0d00410 <handle_create+0x1e4>
        PRINTF("parse ORDER__OPERATOR\n");
c0d003be:	4828      	ldr	r0, [pc, #160]	; (c0d00460 <handle_create+0x234>)
c0d003c0:	4478      	add	r0, pc
c0d003c2:	f000 f965 	bl	c0d00690 <semihosted_printf>
        context->current_tuple_offset = msg->parameterOffset;
c0d003c6:	6929      	ldr	r1, [r5, #16]
c0d003c8:	6621      	str	r1, [r4, #96]	; 0x60
        PRINTF("NEW current_tuple_offset: %d\n", context->current_tuple_offset);
c0d003ca:	4826      	ldr	r0, [pc, #152]	; (c0d00464 <handle_create+0x238>)
c0d003cc:	4478      	add	r0, pc
c0d003ce:	e01d      	b.n	c0d0040c <handle_create+0x1e0>
        PRINTF("parse BIO__INPUTTOKEN\n");
c0d003d0:	481f      	ldr	r0, [pc, #124]	; (c0d00450 <handle_create+0x224>)
c0d003d2:	4478      	add	r0, pc
c0d003d4:	f000 f95c 	bl	c0d00690 <semihosted_printf>
        context->current_tuple_offset = msg->parameterOffset;
c0d003d8:	6928      	ldr	r0, [r5, #16]
c0d003da:	6620      	str	r0, [r4, #96]	; 0x60
c0d003dc:	e018      	b.n	c0d00410 <handle_create+0x1e4>
        PRINTF("parse BIO__AMOUNT\n");
c0d003de:	4818      	ldr	r0, [pc, #96]	; (c0d00440 <handle_create+0x214>)
c0d003e0:	4478      	add	r0, pc
c0d003e2:	e001      	b.n	c0d003e8 <handle_create+0x1bc>
        PRINTF("parse BIO__FROM_RESERVE\n");
c0d003e4:	4817      	ldr	r0, [pc, #92]	; (c0d00444 <handle_create+0x218>)
c0d003e6:	4478      	add	r0, pc
c0d003e8:	f000 f952 	bl	c0d00690 <semihosted_printf>
c0d003ec:	e010      	b.n	c0d00410 <handle_create+0x1e4>
        PRINTF("parse BIO__LEN_ORDERS\n");
c0d003ee:	4816      	ldr	r0, [pc, #88]	; (c0d00448 <handle_create+0x21c>)
c0d003f0:	4478      	add	r0, pc
c0d003f2:	f000 f94d 	bl	c0d00690 <semihosted_printf>
c0d003f6:	68e8      	ldr	r0, [r5, #12]
c0d003f8:	7fc1      	ldrb	r1, [r0, #31]
c0d003fa:	7f82      	ldrb	r2, [r0, #30]
c0d003fc:	0212      	lsls	r2, r2, #8
c0d003fe:	1851      	adds	r1, r2, r1
c0d00400:	8039      	strh	r1, [r7, #0]
c0d00402:	7fc0      	ldrb	r0, [r0, #31]
c0d00404:	72b8      	strb	r0, [r7, #10]
c0d00406:	b289      	uxth	r1, r1
c0d00408:	4810      	ldr	r0, [pc, #64]	; (c0d0044c <handle_create+0x220>)
c0d0040a:	4478      	add	r0, pc
c0d0040c:	f000 f940 	bl	c0d00690 <semihosted_printf>
c0d00410:	7830      	ldrb	r0, [r6, #0]
c0d00412:	1c40      	adds	r0, r0, #1
c0d00414:	7030      	strb	r0, [r6, #0]
}
c0d00416:	b001      	add	sp, #4
c0d00418:	bdf0      	pop	{r4, r5, r6, r7, pc}
                PRINTF("IS NOT 0\n");
c0d0041a:	4819      	ldr	r0, [pc, #100]	; (c0d00480 <handle_create+0x254>)
c0d0041c:	4478      	add	r0, pc
c0d0041e:	f000 f937 	bl	c0d00690 <semihosted_printf>
                context->booleans |= IS_COPY;
c0d00422:	7af8      	ldrb	r0, [r7, #11]
c0d00424:	2101      	movs	r1, #1
c0d00426:	4301      	orrs	r1, r0
c0d00428:	72f9      	strb	r1, [r7, #11]
c0d0042a:	e7f1      	b.n	c0d00410 <handle_create+0x1e4>
c0d0042c:	00000d89 	.word	0x00000d89
c0d00430:	00000da9 	.word	0x00000da9
c0d00434:	00000d8b 	.word	0x00000d8b
c0d00438:	00000d92 	.word	0x00000d92
c0d0043c:	00000d98 	.word	0x00000d98
c0d00440:	00000c26 	.word	0x00000c26
c0d00444:	00000c4d 	.word	0x00000c4d
c0d00448:	00000c5c 	.word	0x00000c5c
c0d0044c:	00000b37 	.word	0x00000b37
c0d00450:	00000c1d 	.word	0x00000c1d
c0d00454:	00000e2d 	.word	0x00000e2d
c0d00458:	00000ddb 	.word	0x00000ddb
c0d0045c:	00000eaa 	.word	0x00000eaa
c0d00460:	00000d18 	.word	0x00000d18
c0d00464:	00000d23 	.word	0x00000d23
c0d00468:	00000da9 	.word	0x00000da9
c0d0046c:	00000db5 	.word	0x00000db5
c0d00470:	00000c62 	.word	0x00000c62
c0d00474:	00000be0 	.word	0x00000be0
c0d00478:	00000d0a 	.word	0x00000d0a
c0d0047c:	00000b50 	.word	0x00000b50
c0d00480:	00000ade 	.word	0x00000ade
c0d00484:	00000bec 	.word	0x00000bec
c0d00488:	00000c0f 	.word	0x00000c0f
c0d0048c:	00000c1e 	.word	0x00000c1e
c0d00490:	00000c0e 	.word	0x00000c0e

c0d00494 <handle_provide_token>:

// EDIT THIS: Adapt this function to your needs! Remember, the information for tokens are held in
// `msg->token1` and `msg->token2`. If those pointers are `NULL`, this means the ethereum app didn't
// find any info regarding the requested tokens!
void handle_provide_token(void *parameters)
{
c0d00494:	b570      	push	{r4, r5, r6, lr}
c0d00496:	4604      	mov	r4, r0
    ethPluginProvideInfo_t *msg = (ethPluginProvideInfo_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;
c0d00498:	6885      	ldr	r5, [r0, #8]

    if (msg->item1)
c0d0049a:	68c0      	ldr	r0, [r0, #12]
c0d0049c:	462e      	mov	r6, r5
c0d0049e:	3655      	adds	r6, #85	; 0x55
c0d004a0:	2800      	cmp	r0, #0
c0d004a2:	d00f      	beq.n	c0d004c4 <handle_provide_token+0x30>
    {
        PRINTF("handle_provide_token item1\n");
c0d004a4:	480c      	ldr	r0, [pc, #48]	; (c0d004d8 <handle_provide_token+0x44>)
c0d004a6:	4478      	add	r0, pc
c0d004a8:	f000 f8f2 	bl	c0d00690 <semihosted_printf>
        // The Ethereum App found the information for the requested token!
        // Store its decimals.
        context->decimals = msg->item1->token.decimals;
c0d004ac:	68e1      	ldr	r1, [r4, #12]
c0d004ae:	2034      	movs	r0, #52	; 0x34
c0d004b0:	5c08      	ldrb	r0, [r1, r0]
c0d004b2:	7030      	strb	r0, [r6, #0]
        // Store its ticker.
        strlcpy(context->ticker, (char *)msg->item1->token.ticker, sizeof(context->ticker));
c0d004b4:	3549      	adds	r5, #73	; 0x49
c0d004b6:	3114      	adds	r1, #20
c0d004b8:	220c      	movs	r2, #12
c0d004ba:	4628      	mov	r0, r5
c0d004bc:	f000 fc0b 	bl	c0d00cd6 <strlcpy>
c0d004c0:	2001      	movs	r0, #1
c0d004c2:	e004      	b.n	c0d004ce <handle_provide_token+0x3a>
        // Keep track that we found the token.
        context->token_found = true;
    }
    else
    {
        PRINTF("handle_provide_token no item1\n");
c0d004c4:	4805      	ldr	r0, [pc, #20]	; (c0d004dc <handle_provide_token+0x48>)
c0d004c6:	4478      	add	r0, pc
c0d004c8:	f000 f8e2 	bl	c0d00690 <semihosted_printf>
c0d004cc:	2000      	movs	r0, #0
        // The Ethereum App did not manage to find the info for the requested token.
        context->token_found = false;
c0d004ce:	7070      	strb	r0, [r6, #1]
c0d004d0:	2004      	movs	r0, #4
        // If we wanted to add a screen, say a warning screen for example, we could instruct the
        // ethereum app to add an additional screen by setting `msg->additionalScreens` here, just
        // like so:
        // msg->additionalScreens = 1;
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
c0d004d2:	7560      	strb	r0, [r4, #21]
c0d004d4:	bd70      	pop	{r4, r5, r6, pc}
c0d004d6:	46c0      	nop			; (mov r8, r8)
c0d004d8:	00000cd3 	.word	0x00000cd3
c0d004dc:	00000ccf 	.word	0x00000ccf

c0d004e0 <handle_query_contract_id>:
#include "nested_plugin.h"
#include "text.h"

// Sets the first screen to display.
void handle_query_contract_id(void *parameters)
{
c0d004e0:	b5b0      	push	{r4, r5, r7, lr}
c0d004e2:	4604      	mov	r4, r0
    ethQueryContractID_t *msg = (ethQueryContractID_t *)parameters;
    const context_t *context = (const context_t *)msg->pluginContext;
c0d004e4:	6885      	ldr	r5, [r0, #8]
    // msg->name will be the upper sentence displayed on the screen.
    // msg->version will be the lower sentence displayed on the screen.

    // For the first screen, display the plugin name.
    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);
c0d004e6:	68c0      	ldr	r0, [r0, #12]
c0d004e8:	6922      	ldr	r2, [r4, #16]
c0d004ea:	4926      	ldr	r1, [pc, #152]	; (c0d00584 <handle_query_contract_id+0xa4>)
c0d004ec:	4479      	add	r1, pc
c0d004ee:	f000 fbf2 	bl	c0d00cd6 <strlcpy>
c0d004f2:	2074      	movs	r0, #116	; 0x74

    if (context->selectorIndex == CREATE)
c0d004f4:	5c29      	ldrb	r1, [r5, r0]
c0d004f6:	2902      	cmp	r1, #2
c0d004f8:	dc0a      	bgt.n	c0d00510 <handle_query_contract_id+0x30>
c0d004fa:	2900      	cmp	r1, #0
c0d004fc:	d013      	beq.n	c0d00526 <handle_query_contract_id+0x46>
c0d004fe:	2901      	cmp	r1, #1
c0d00500:	d01f      	beq.n	c0d00542 <handle_query_contract_id+0x62>
c0d00502:	2902      	cmp	r1, #2
c0d00504:	d12e      	bne.n	c0d00564 <handle_query_contract_id+0x84>
    {
        strlcpy(msg->version, "PROCESS_INPUT_ORDERS", msg->versionLength);
    }
    else if (context->selectorIndex == PROCESS_OUTPUT_ORDERS)
    {
        strlcpy(msg->version, "PROCESS_OUTPUT_ORDERS", msg->versionLength);
c0d00506:	6960      	ldr	r0, [r4, #20]
c0d00508:	69a2      	ldr	r2, [r4, #24]
c0d0050a:	491f      	ldr	r1, [pc, #124]	; (c0d00588 <handle_query_contract_id+0xa8>)
c0d0050c:	4479      	add	r1, pc
c0d0050e:	e026      	b.n	c0d0055e <handle_query_contract_id+0x7e>
    if (context->selectorIndex == CREATE)
c0d00510:	2903      	cmp	r1, #3
c0d00512:	d01b      	beq.n	c0d0054c <handle_query_contract_id+0x6c>
c0d00514:	2904      	cmp	r1, #4
c0d00516:	d01e      	beq.n	c0d00556 <handle_query_contract_id+0x76>
c0d00518:	2905      	cmp	r1, #5
c0d0051a:	d123      	bne.n	c0d00564 <handle_query_contract_id+0x84>
    {
        strlcpy(msg->version, "Claim Royalties", msg->versionLength);
    }
    else if (context->selectorIndex == TRANSFER_FROM)
    {
        strlcpy(msg->version, "Send", msg->versionLength);
c0d0051c:	6960      	ldr	r0, [r4, #20]
c0d0051e:	69a2      	ldr	r2, [r4, #24]
c0d00520:	491a      	ldr	r1, [pc, #104]	; (c0d0058c <handle_query_contract_id+0xac>)
c0d00522:	4479      	add	r1, pc
c0d00524:	e01b      	b.n	c0d0055e <handle_query_contract_id+0x7e>
c0d00526:	3573      	adds	r5, #115	; 0x73
        PRINTF("context->booleans & IS_COPY: %d\n", context->booleans & IS_COPY);
c0d00528:	7828      	ldrb	r0, [r5, #0]
c0d0052a:	2101      	movs	r1, #1
c0d0052c:	4001      	ands	r1, r0
c0d0052e:	4818      	ldr	r0, [pc, #96]	; (c0d00590 <handle_query_contract_id+0xb0>)
c0d00530:	4478      	add	r0, pc
c0d00532:	f000 f8ad 	bl	c0d00690 <semihosted_printf>
        if (context->booleans & IS_COPY)
c0d00536:	7828      	ldrb	r0, [r5, #0]
c0d00538:	07c0      	lsls	r0, r0, #31
c0d0053a:	d019      	beq.n	c0d00570 <handle_query_contract_id+0x90>
c0d0053c:	4916      	ldr	r1, [pc, #88]	; (c0d00598 <handle_query_contract_id+0xb8>)
c0d0053e:	4479      	add	r1, pc
c0d00540:	e018      	b.n	c0d00574 <handle_query_contract_id+0x94>
        strlcpy(msg->version, "PROCESS_INPUT_ORDERS", msg->versionLength);
c0d00542:	6960      	ldr	r0, [r4, #20]
c0d00544:	69a2      	ldr	r2, [r4, #24]
c0d00546:	4915      	ldr	r1, [pc, #84]	; (c0d0059c <handle_query_contract_id+0xbc>)
c0d00548:	4479      	add	r1, pc
c0d0054a:	e008      	b.n	c0d0055e <handle_query_contract_id+0x7e>
        strlcpy(msg->version, "Sell Portfolio", msg->versionLength);
c0d0054c:	6960      	ldr	r0, [r4, #20]
c0d0054e:	69a2      	ldr	r2, [r4, #24]
c0d00550:	4913      	ldr	r1, [pc, #76]	; (c0d005a0 <handle_query_contract_id+0xc0>)
c0d00552:	4479      	add	r1, pc
c0d00554:	e003      	b.n	c0d0055e <handle_query_contract_id+0x7e>
        strlcpy(msg->version, "Claim Royalties", msg->versionLength);
c0d00556:	6960      	ldr	r0, [r4, #20]
c0d00558:	69a2      	ldr	r2, [r4, #24]
c0d0055a:	4912      	ldr	r1, [pc, #72]	; (c0d005a4 <handle_query_contract_id+0xc4>)
c0d0055c:	4479      	add	r1, pc
c0d0055e:	f000 fbba 	bl	c0d00cd6 <strlcpy>
    else
    {
        PRINTF("Selector index: %d not supported\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
    }
c0d00562:	bdb0      	pop	{r4, r5, r7, pc}
        PRINTF("Selector index: %d not supported\n", context->selectorIndex);
c0d00564:	4810      	ldr	r0, [pc, #64]	; (c0d005a8 <handle_query_contract_id+0xc8>)
c0d00566:	4478      	add	r0, pc
c0d00568:	f000 f892 	bl	c0d00690 <semihosted_printf>
c0d0056c:	2000      	movs	r0, #0
c0d0056e:	e006      	b.n	c0d0057e <handle_query_contract_id+0x9e>
c0d00570:	4908      	ldr	r1, [pc, #32]	; (c0d00594 <handle_query_contract_id+0xb4>)
c0d00572:	4479      	add	r1, pc
c0d00574:	6960      	ldr	r0, [r4, #20]
c0d00576:	69a2      	ldr	r2, [r4, #24]
c0d00578:	f000 fbad 	bl	c0d00cd6 <strlcpy>
c0d0057c:	2004      	movs	r0, #4
c0d0057e:	7720      	strb	r0, [r4, #28]
c0d00580:	bdb0      	pop	{r4, r5, r7, pc}
c0d00582:	46c0      	nop			; (mov r8, r8)
c0d00584:	00000cc8 	.word	0x00000cc8
c0d00588:	00000cf9 	.word	0x00000cf9
c0d0058c:	00000d18 	.word	0x00000d18
c0d00590:	00000c93 	.word	0x00000c93
c0d00594:	00000c77 	.word	0x00000c77
c0d00598:	00000ca6 	.word	0x00000ca6
c0d0059c:	00000ca8 	.word	0x00000ca8
c0d005a0:	00000cc9 	.word	0x00000cc9
c0d005a4:	00000cce 	.word	0x00000cce
c0d005a8:	00000cd9 	.word	0x00000cd9

c0d005ac <handle_query_contract_ui>:
#include "nested_plugin.h"

void handle_query_contract_ui(void *parameters)
{
c0d005ac:	b5b0      	push	{r4, r5, r7, lr}
c0d005ae:	4604      	mov	r4, r0

    // msg->title is the upper line displayed on the device.
    // msg->msg is the lower line displayed on the device.

    // Clean the display fields.
    memset(msg->title, 0, msg->titleLength);
c0d005b0:	6a40      	ldr	r0, [r0, #36]	; 0x24
c0d005b2:	6aa1      	ldr	r1, [r4, #40]	; 0x28
c0d005b4:	f000 fb54 	bl	c0d00c60 <__aeabi_memclr>
    memset(msg->msg, 0, msg->msgLength);
c0d005b8:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d005ba:	6b21      	ldr	r1, [r4, #48]	; 0x30
c0d005bc:	f000 fb50 	bl	c0d00c60 <__aeabi_memclr>
c0d005c0:	4625      	mov	r5, r4
c0d005c2:	3520      	adds	r5, #32
c0d005c4:	2004      	movs	r0, #4

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d005c6:	7528      	strb	r0, [r5, #20]
c0d005c8:	2020      	movs	r0, #32

    switch (msg->screenIndex)
c0d005ca:	5c20      	ldrb	r0, [r4, r0]
c0d005cc:	2800      	cmp	r0, #0
c0d005ce:	d006      	beq.n	c0d005de <handle_query_contract_ui+0x32>
        strlcpy(msg->title, "placeholder", msg->titleLength);
        strlcpy(msg->msg, "placeholder", msg->msgLength);
        break;
    // Keep this
    default:
        PRINTF("Received an invalid screenIndex\n");
c0d005d0:	480a      	ldr	r0, [pc, #40]	; (c0d005fc <handle_query_contract_ui+0x50>)
c0d005d2:	4478      	add	r0, pc
c0d005d4:	f000 f85c 	bl	c0d00690 <semihosted_printf>
c0d005d8:	2000      	movs	r0, #0
        msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d005da:	7528      	strb	r0, [r5, #20]
        return;
    }
}
c0d005dc:	bdb0      	pop	{r4, r5, r7, pc}
        strlcpy(msg->title, "placeholder", msg->titleLength);
c0d005de:	6a60      	ldr	r0, [r4, #36]	; 0x24
c0d005e0:	6aa2      	ldr	r2, [r4, #40]	; 0x28
c0d005e2:	4d05      	ldr	r5, [pc, #20]	; (c0d005f8 <handle_query_contract_ui+0x4c>)
c0d005e4:	447d      	add	r5, pc
c0d005e6:	4629      	mov	r1, r5
c0d005e8:	f000 fb75 	bl	c0d00cd6 <strlcpy>
        strlcpy(msg->msg, "placeholder", msg->msgLength);
c0d005ec:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d005ee:	6b22      	ldr	r2, [r4, #48]	; 0x30
c0d005f0:	4629      	mov	r1, r5
c0d005f2:	f000 fb70 	bl	c0d00cd6 <strlcpy>
}
c0d005f6:	bdb0      	pop	{r4, r5, r7, pc}
c0d005f8:	00000c7d 	.word	0x00000c7d
c0d005fc:	00000c9b 	.word	0x00000c9b

c0d00600 <dispatch_plugin_calls>:
{
c0d00600:	b580      	push	{r7, lr}
c0d00602:	4602      	mov	r2, r0
c0d00604:	20ff      	movs	r0, #255	; 0xff
c0d00606:	4603      	mov	r3, r0
c0d00608:	3304      	adds	r3, #4
    switch (message)
c0d0060a:	429a      	cmp	r2, r3
c0d0060c:	dc0c      	bgt.n	c0d00628 <dispatch_plugin_calls+0x28>
c0d0060e:	3002      	adds	r0, #2
c0d00610:	4282      	cmp	r2, r0
c0d00612:	d018      	beq.n	c0d00646 <dispatch_plugin_calls+0x46>
c0d00614:	2081      	movs	r0, #129	; 0x81
c0d00616:	0040      	lsls	r0, r0, #1
c0d00618:	4282      	cmp	r2, r0
c0d0061a:	d018      	beq.n	c0d0064e <dispatch_plugin_calls+0x4e>
c0d0061c:	429a      	cmp	r2, r3
c0d0061e:	d122      	bne.n	c0d00666 <dispatch_plugin_calls+0x66>
        handle_finalize(parameters);
c0d00620:	4608      	mov	r0, r1
c0d00622:	f7ff fd2f 	bl	c0d00084 <handle_finalize>
}
c0d00626:	bd80      	pop	{r7, pc}
c0d00628:	2341      	movs	r3, #65	; 0x41
c0d0062a:	009b      	lsls	r3, r3, #2
    switch (message)
c0d0062c:	429a      	cmp	r2, r3
c0d0062e:	d012      	beq.n	c0d00656 <dispatch_plugin_calls+0x56>
c0d00630:	3006      	adds	r0, #6
c0d00632:	4282      	cmp	r2, r0
c0d00634:	d013      	beq.n	c0d0065e <dispatch_plugin_calls+0x5e>
c0d00636:	2083      	movs	r0, #131	; 0x83
c0d00638:	0040      	lsls	r0, r0, #1
c0d0063a:	4282      	cmp	r2, r0
c0d0063c:	d113      	bne.n	c0d00666 <dispatch_plugin_calls+0x66>
        handle_query_contract_ui(parameters);
c0d0063e:	4608      	mov	r0, r1
c0d00640:	f7ff ffb4 	bl	c0d005ac <handle_query_contract_ui>
}
c0d00644:	bd80      	pop	{r7, pc}
        handle_init_contract(parameters);
c0d00646:	4608      	mov	r0, r1
c0d00648:	f7ff fd26 	bl	c0d00098 <handle_init_contract>
}
c0d0064c:	bd80      	pop	{r7, pc}
        handle_provide_parameter(parameters);
c0d0064e:	4608      	mov	r0, r1
c0d00650:	f7ff fdc2 	bl	c0d001d8 <handle_provide_parameter>
}
c0d00654:	bd80      	pop	{r7, pc}
        handle_provide_token(parameters);
c0d00656:	4608      	mov	r0, r1
c0d00658:	f7ff ff1c 	bl	c0d00494 <handle_provide_token>
}
c0d0065c:	bd80      	pop	{r7, pc}
        handle_query_contract_id(parameters);
c0d0065e:	4608      	mov	r0, r1
c0d00660:	f7ff ff3e 	bl	c0d004e0 <handle_query_contract_id>
}
c0d00664:	bd80      	pop	{r7, pc}
        PRINTF("Unhandled message %d\n", message);
c0d00666:	4803      	ldr	r0, [pc, #12]	; (c0d00674 <dispatch_plugin_calls+0x74>)
c0d00668:	4478      	add	r0, pc
c0d0066a:	4611      	mov	r1, r2
c0d0066c:	f000 f810 	bl	c0d00690 <semihosted_printf>
}
c0d00670:	bd80      	pop	{r7, pc}
c0d00672:	46c0      	nop			; (mov r8, r8)
c0d00674:	00000c26 	.word	0x00000c26

c0d00678 <os_boot>:

// apdu buffer must hold a complete apdu to avoid troubles
unsigned char G_io_apdu_buffer[IO_APDU_BUFFER_SIZE];

#ifndef BOLOS_OS_UPGRADER_APP
void os_boot(void) {
c0d00678:	b580      	push	{r7, lr}
c0d0067a:	2000      	movs	r0, #0
  // // TODO patch entry point when romming (f)
  // // set the default try context to nothing
#ifndef HAVE_BOLOS
  try_context_set(NULL);
c0d0067c:	f000 fa28 	bl	c0d00ad0 <try_context_set>
#endif // HAVE_BOLOS
}
c0d00680:	bd80      	pop	{r7, pc}

c0d00682 <os_longjmp>:
  }
  return xoracc;
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0d00682:	4604      	mov	r4, r0
#ifdef HAVE_PRINTF  
  unsigned int lr_val;
  __asm volatile("mov %0, lr" :"=r"(lr_val));
  PRINTF("exception[%d]: LR=0x%08X\n", exception, lr_val);
#endif // HAVE_PRINTF
  longjmp(try_context_get()->jmp_buf, exception);
c0d00684:	f000 fa18 	bl	c0d00ab8 <try_context_get>
c0d00688:	4621      	mov	r1, r4
c0d0068a:	f000 fb16 	bl	c0d00cba <longjmp>
	...

c0d00690 <semihosted_printf>:
    'D',
    'E',
    'F',
};

void semihosted_printf(const char *format, ...) {
c0d00690:	b083      	sub	sp, #12
c0d00692:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00694:	b09c      	sub	sp, #112	; 0x70
c0d00696:	ac21      	add	r4, sp, #132	; 0x84
c0d00698:	c40e      	stmia	r4!, {r1, r2, r3}
    char cStrlenSet;

    //
    // Check the arguments.
    //
    if (format == 0) {
c0d0069a:	2800      	cmp	r0, #0
c0d0069c:	d100      	bne.n	c0d006a0 <semihosted_printf+0x10>
c0d0069e:	e19e      	b.n	c0d009de <semihosted_printf+0x34e>
c0d006a0:	4604      	mov	r4, r0
c0d006a2:	a821      	add	r0, sp, #132	; 0x84
    }

    //
    // Start the varargs processing.
    //
    va_start(vaArgP, format);
c0d006a4:	9006      	str	r0, [sp, #24]

    //
    // Loop while there are more characters in the string.
    //
    while (*format) {
c0d006a6:	7820      	ldrb	r0, [r4, #0]
c0d006a8:	2800      	cmp	r0, #0
c0d006aa:	d100      	bne.n	c0d006ae <semihosted_printf+0x1e>
c0d006ac:	e197      	b.n	c0d009de <semihosted_printf+0x34e>
c0d006ae:	2600      	movs	r6, #0
        //
        // Find the first non-% character, or the end of the string.
        //
        for (ulIdx = 0; (format[ulIdx] != '%') && (format[ulIdx] != '\0'); ulIdx++) {
c0d006b0:	2800      	cmp	r0, #0
c0d006b2:	d005      	beq.n	c0d006c0 <semihosted_printf+0x30>
c0d006b4:	2825      	cmp	r0, #37	; 0x25
c0d006b6:	d003      	beq.n	c0d006c0 <semihosted_printf+0x30>
c0d006b8:	19a0      	adds	r0, r4, r6
c0d006ba:	7840      	ldrb	r0, [r0, #1]
c0d006bc:	1c76      	adds	r6, r6, #1
c0d006be:	e7f7      	b.n	c0d006b0 <semihosted_printf+0x20>
        }

        //
        // Write this portion of the string.
        //
        prints(format, ulIdx);
c0d006c0:	b2b1      	uxth	r1, r6
c0d006c2:	4620      	mov	r0, r4
c0d006c4:	f000 f99a 	bl	c0d009fc <prints>
        format += ulIdx;

        //
        // See if the next character is a %.
        //
        if (*format == '%') {
c0d006c8:	5da0      	ldrb	r0, [r4, r6]
c0d006ca:	2825      	cmp	r0, #37	; 0x25
c0d006cc:	d001      	beq.n	c0d006d2 <semihosted_printf+0x42>
c0d006ce:	19a4      	adds	r4, r4, r6
c0d006d0:	e7ea      	b.n	c0d006a8 <semihosted_printf+0x18>
            ulCount = 0;
            cFill = ' ';
            ulStrlen = 0;
            cStrlenSet = 0;
            ulCap = 0;
            ulBase = 10;
c0d006d2:	19a0      	adds	r0, r4, r6
c0d006d4:	1c44      	adds	r4, r0, #1
c0d006d6:	2500      	movs	r5, #0
c0d006d8:	2020      	movs	r0, #32
c0d006da:	9004      	str	r0, [sp, #16]
c0d006dc:	200a      	movs	r0, #10
c0d006de:	9003      	str	r0, [sp, #12]
c0d006e0:	9505      	str	r5, [sp, #20]
c0d006e2:	462f      	mov	r7, r5
c0d006e4:	462b      	mov	r3, r5
c0d006e6:	4619      	mov	r1, r3
        again:

            //
            // Determine how to handle the next character.
            //
            switch (*format++) {
c0d006e8:	7820      	ldrb	r0, [r4, #0]
c0d006ea:	1c64      	adds	r4, r4, #1
c0d006ec:	2300      	movs	r3, #0
c0d006ee:	282d      	cmp	r0, #45	; 0x2d
c0d006f0:	d0f9      	beq.n	c0d006e6 <semihosted_printf+0x56>
c0d006f2:	2847      	cmp	r0, #71	; 0x47
c0d006f4:	dc13      	bgt.n	c0d0071e <semihosted_printf+0x8e>
c0d006f6:	282f      	cmp	r0, #47	; 0x2f
c0d006f8:	dd1f      	ble.n	c0d0073a <semihosted_printf+0xaa>
c0d006fa:	4603      	mov	r3, r0
c0d006fc:	3b30      	subs	r3, #48	; 0x30
c0d006fe:	2b0a      	cmp	r3, #10
c0d00700:	d300      	bcc.n	c0d00704 <semihosted_printf+0x74>
c0d00702:	e0da      	b.n	c0d008ba <semihosted_printf+0x22a>
c0d00704:	2330      	movs	r3, #48	; 0x30
                case '9': {
                    //
                    // If this is a zero, and it is the first digit, then the
                    // fill character is a zero instead of a space.
                    //
                    if ((format[-1] == '0') && (ulCount == 0)) {
c0d00706:	4602      	mov	r2, r0
c0d00708:	405a      	eors	r2, r3
c0d0070a:	432a      	orrs	r2, r5
c0d0070c:	d000      	beq.n	c0d00710 <semihosted_printf+0x80>
c0d0070e:	9b04      	ldr	r3, [sp, #16]
c0d00710:	220a      	movs	r2, #10
                    }

                    //
                    // Update the digit count.
                    //
                    ulCount *= 10;
c0d00712:	436a      	muls	r2, r5
                    ulCount += format[-1] - '0';
c0d00714:	1815      	adds	r5, r2, r0
c0d00716:	3d30      	subs	r5, #48	; 0x30
c0d00718:	9304      	str	r3, [sp, #16]
c0d0071a:	460b      	mov	r3, r1
c0d0071c:	e7e3      	b.n	c0d006e6 <semihosted_printf+0x56>
            switch (*format++) {
c0d0071e:	2867      	cmp	r0, #103	; 0x67
c0d00720:	dd04      	ble.n	c0d0072c <semihosted_printf+0x9c>
c0d00722:	2872      	cmp	r0, #114	; 0x72
c0d00724:	dd20      	ble.n	c0d00768 <semihosted_printf+0xd8>
c0d00726:	2873      	cmp	r0, #115	; 0x73
c0d00728:	d13a      	bne.n	c0d007a0 <semihosted_printf+0x110>
c0d0072a:	e023      	b.n	c0d00774 <semihosted_printf+0xe4>
c0d0072c:	2862      	cmp	r0, #98	; 0x62
c0d0072e:	dc3d      	bgt.n	c0d007ac <semihosted_printf+0x11c>
c0d00730:	2848      	cmp	r0, #72	; 0x48
c0d00732:	d000      	beq.n	c0d00736 <semihosted_printf+0xa6>
c0d00734:	e08f      	b.n	c0d00856 <semihosted_printf+0x1c6>
c0d00736:	2701      	movs	r7, #1
c0d00738:	e01a      	b.n	c0d00770 <semihosted_printf+0xe0>
c0d0073a:	2825      	cmp	r0, #37	; 0x25
c0d0073c:	d100      	bne.n	c0d00740 <semihosted_printf+0xb0>
c0d0073e:	e099      	b.n	c0d00874 <semihosted_printf+0x1e4>
c0d00740:	282a      	cmp	r0, #42	; 0x2a
c0d00742:	d022      	beq.n	c0d0078a <semihosted_printf+0xfa>
c0d00744:	282e      	cmp	r0, #46	; 0x2e
c0d00746:	d000      	beq.n	c0d0074a <semihosted_printf+0xba>
c0d00748:	e0b7      	b.n	c0d008ba <semihosted_printf+0x22a>
                // special %.*H or %.*h format to print a given length of hex digits (case: H UPPER,
                // h lower)
                //
                case '.': {
                    // ensure next char is '*' and next one is 's'
                    if (format[0] == '*' &&
c0d0074a:	7820      	ldrb	r0, [r4, #0]
c0d0074c:	282a      	cmp	r0, #42	; 0x2a
c0d0074e:	d000      	beq.n	c0d00752 <semihosted_printf+0xc2>
c0d00750:	e0b3      	b.n	c0d008ba <semihosted_printf+0x22a>
                        (format[1] == 's' || format[1] == 'H' || format[1] == 'h')) {
c0d00752:	7861      	ldrb	r1, [r4, #1]
c0d00754:	2948      	cmp	r1, #72	; 0x48
c0d00756:	d004      	beq.n	c0d00762 <semihosted_printf+0xd2>
c0d00758:	2973      	cmp	r1, #115	; 0x73
c0d0075a:	d002      	beq.n	c0d00762 <semihosted_printf+0xd2>
c0d0075c:	2968      	cmp	r1, #104	; 0x68
c0d0075e:	d000      	beq.n	c0d00762 <semihosted_printf+0xd2>
c0d00760:	e0ab      	b.n	c0d008ba <semihosted_printf+0x22a>
c0d00762:	1c64      	adds	r4, r4, #1
c0d00764:	2301      	movs	r3, #1
c0d00766:	e015      	b.n	c0d00794 <semihosted_printf+0x104>
            switch (*format++) {
c0d00768:	2868      	cmp	r0, #104	; 0x68
c0d0076a:	d000      	beq.n	c0d0076e <semihosted_printf+0xde>
c0d0076c:	e077      	b.n	c0d0085e <semihosted_printf+0x1ce>
c0d0076e:	2700      	movs	r7, #0
c0d00770:	2010      	movs	r0, #16
c0d00772:	9003      	str	r0, [sp, #12]
                case 's':
                case_s : {
                    //
                    // Get the string pointer from the varargs.
                    //
                    pcStr = va_arg(vaArgP, char *);
c0d00774:	9806      	ldr	r0, [sp, #24]
c0d00776:	1d02      	adds	r2, r0, #4
c0d00778:	9206      	str	r2, [sp, #24]

                    //
                    // Determine the length of the string. (if not specified using .*)
                    //
                    switch (cStrlenSet) {
c0d0077a:	b2cb      	uxtb	r3, r1
                    pcStr = va_arg(vaArgP, char *);
c0d0077c:	6802      	ldr	r2, [r0, #0]
                    switch (cStrlenSet) {
c0d0077e:	2b01      	cmp	r3, #1
c0d00780:	dd25      	ble.n	c0d007ce <semihosted_printf+0x13e>
c0d00782:	2b02      	cmp	r3, #2
c0d00784:	460b      	mov	r3, r1
c0d00786:	d1ae      	bne.n	c0d006e6 <semihosted_printf+0x56>
c0d00788:	e094      	b.n	c0d008b4 <semihosted_printf+0x224>
                    if (*format == 's') {
c0d0078a:	7820      	ldrb	r0, [r4, #0]
c0d0078c:	2873      	cmp	r0, #115	; 0x73
c0d0078e:	d000      	beq.n	c0d00792 <semihosted_printf+0x102>
c0d00790:	e093      	b.n	c0d008ba <semihosted_printf+0x22a>
c0d00792:	2302      	movs	r3, #2
c0d00794:	9906      	ldr	r1, [sp, #24]
c0d00796:	1d08      	adds	r0, r1, #4
c0d00798:	9006      	str	r0, [sp, #24]
c0d0079a:	6808      	ldr	r0, [r1, #0]
            switch (*format++) {
c0d0079c:	9005      	str	r0, [sp, #20]
c0d0079e:	e7a2      	b.n	c0d006e6 <semihosted_printf+0x56>
c0d007a0:	2875      	cmp	r0, #117	; 0x75
c0d007a2:	d100      	bne.n	c0d007a6 <semihosted_printf+0x116>
c0d007a4:	e070      	b.n	c0d00888 <semihosted_printf+0x1f8>
c0d007a6:	2878      	cmp	r0, #120	; 0x78
c0d007a8:	d05b      	beq.n	c0d00862 <semihosted_printf+0x1d2>
c0d007aa:	e086      	b.n	c0d008ba <semihosted_printf+0x22a>
c0d007ac:	2863      	cmp	r0, #99	; 0x63
c0d007ae:	d100      	bne.n	c0d007b2 <semihosted_printf+0x122>
c0d007b0:	e073      	b.n	c0d0089a <semihosted_printf+0x20a>
c0d007b2:	2864      	cmp	r0, #100	; 0x64
c0d007b4:	d000      	beq.n	c0d007b8 <semihosted_printf+0x128>
c0d007b6:	e080      	b.n	c0d008ba <semihosted_printf+0x22a>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d007b8:	9806      	ldr	r0, [sp, #24]
c0d007ba:	1d01      	adds	r1, r0, #4
c0d007bc:	9106      	str	r1, [sp, #24]
c0d007be:	6806      	ldr	r6, [r0, #0]
c0d007c0:	960b      	str	r6, [sp, #44]	; 0x2c
c0d007c2:	200a      	movs	r0, #10
                    if ((long) ulValue < 0) {
c0d007c4:	2e00      	cmp	r6, #0
c0d007c6:	d500      	bpl.n	c0d007ca <semihosted_printf+0x13a>
c0d007c8:	e085      	b.n	c0d008d6 <semihosted_printf+0x246>
c0d007ca:	2100      	movs	r1, #0
c0d007cc:	e086      	b.n	c0d008dc <semihosted_printf+0x24c>
                    switch (cStrlenSet) {
c0d007ce:	2b00      	cmp	r3, #0
c0d007d0:	9e05      	ldr	r6, [sp, #20]
c0d007d2:	d105      	bne.n	c0d007e0 <semihosted_printf+0x150>
c0d007d4:	2100      	movs	r1, #0
                        // compute length with strlen
                        case 0:
                            for (ulIdx = 0; pcStr[ulIdx] != '\0'; ulIdx++) {
c0d007d6:	5c50      	ldrb	r0, [r2, r1]
c0d007d8:	1c49      	adds	r1, r1, #1
c0d007da:	2800      	cmp	r0, #0
c0d007dc:	d1fb      	bne.n	c0d007d6 <semihosted_printf+0x146>
                    }

                    //
                    // Write the string.
                    //
                    switch (ulBase) {
c0d007de:	1e4e      	subs	r6, r1, #1
c0d007e0:	9803      	ldr	r0, [sp, #12]
c0d007e2:	2810      	cmp	r0, #16
c0d007e4:	d000      	beq.n	c0d007e8 <semihosted_printf+0x158>
c0d007e6:	e071      	b.n	c0d008cc <semihosted_printf+0x23c>
                        default:
                            prints(pcStr, ulIdx);
                            break;
                        case 16: {
                            unsigned char nibble1, nibble2;
                            for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d007e8:	2e00      	cmp	r6, #0
c0d007ea:	9702      	str	r7, [sp, #8]
c0d007ec:	d100      	bne.n	c0d007f0 <semihosted_printf+0x160>
c0d007ee:	e75a      	b.n	c0d006a6 <semihosted_printf+0x16>
                                nibble1 = (pcStr[ulCount] >> 4) & 0xF;
c0d007f0:	7810      	ldrb	r0, [r2, #0]
c0d007f2:	230f      	movs	r3, #15
                                nibble2 = pcStr[ulCount] & 0xF;
c0d007f4:	4003      	ands	r3, r0
                                nibble1 = (pcStr[ulCount] >> 4) & 0xF;
c0d007f6:	0900      	lsrs	r0, r0, #4
                                switch (ulCap) {
c0d007f8:	2f01      	cmp	r7, #1
c0d007fa:	d015      	beq.n	c0d00828 <semihosted_printf+0x198>
c0d007fc:	2f00      	cmp	r7, #0
c0d007fe:	d126      	bne.n	c0d0084e <semihosted_printf+0x1be>
c0d00800:	ad0c      	add	r5, sp, #48	; 0x30
c0d00802:	9605      	str	r6, [sp, #20]
c0d00804:	2600      	movs	r6, #0
    buf[1] = 0;
c0d00806:	706e      	strb	r6, [r5, #1]
                                    case 0:
                                        printc(g_pcHex[nibble1]);
c0d00808:	4f78      	ldr	r7, [pc, #480]	; (c0d009ec <semihosted_printf+0x35c>)
c0d0080a:	447f      	add	r7, pc
c0d0080c:	5c38      	ldrb	r0, [r7, r0]
    buf[0] = c;
c0d0080e:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00810:	2004      	movs	r0, #4
c0d00812:	0029      	movs	r1, r5
c0d00814:	dfab      	svc	171	; 0xab
    buf[1] = 0;
c0d00816:	706e      	strb	r6, [r5, #1]
c0d00818:	9e05      	ldr	r6, [sp, #20]
                                        printc(g_pcHex[nibble2]);
c0d0081a:	5cf8      	ldrb	r0, [r7, r3]
c0d0081c:	9f02      	ldr	r7, [sp, #8]
    buf[0] = c;
c0d0081e:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00820:	2004      	movs	r0, #4
c0d00822:	0029      	movs	r1, r5
c0d00824:	dfab      	svc	171	; 0xab
c0d00826:	e012      	b.n	c0d0084e <semihosted_printf+0x1be>
c0d00828:	ad0c      	add	r5, sp, #48	; 0x30
c0d0082a:	9605      	str	r6, [sp, #20]
c0d0082c:	2600      	movs	r6, #0
    buf[1] = 0;
c0d0082e:	706e      	strb	r6, [r5, #1]
                                        break;
                                    case 1:
                                        printc(g_pcHex_cap[nibble1]);
c0d00830:	4f6f      	ldr	r7, [pc, #444]	; (c0d009f0 <semihosted_printf+0x360>)
c0d00832:	447f      	add	r7, pc
c0d00834:	5c38      	ldrb	r0, [r7, r0]
    buf[0] = c;
c0d00836:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00838:	2004      	movs	r0, #4
c0d0083a:	0029      	movs	r1, r5
c0d0083c:	dfab      	svc	171	; 0xab
    buf[1] = 0;
c0d0083e:	706e      	strb	r6, [r5, #1]
c0d00840:	9e05      	ldr	r6, [sp, #20]
                                        printc(g_pcHex_cap[nibble2]);
c0d00842:	5cf8      	ldrb	r0, [r7, r3]
c0d00844:	9f02      	ldr	r7, [sp, #8]
    buf[0] = c;
c0d00846:	7028      	strb	r0, [r5, #0]
    asm volatile(
c0d00848:	2004      	movs	r0, #4
c0d0084a:	0029      	movs	r1, r5
c0d0084c:	dfab      	svc	171	; 0xab
                            for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d0084e:	1c52      	adds	r2, r2, #1
c0d00850:	1e76      	subs	r6, r6, #1
c0d00852:	d1cd      	bne.n	c0d007f0 <semihosted_printf+0x160>
c0d00854:	e727      	b.n	c0d006a6 <semihosted_printf+0x16>
            switch (*format++) {
c0d00856:	2858      	cmp	r0, #88	; 0x58
c0d00858:	d12f      	bne.n	c0d008ba <semihosted_printf+0x22a>
c0d0085a:	2701      	movs	r7, #1
c0d0085c:	e001      	b.n	c0d00862 <semihosted_printf+0x1d2>
c0d0085e:	2870      	cmp	r0, #112	; 0x70
c0d00860:	d12b      	bne.n	c0d008ba <semihosted_printf+0x22a>
                case 'x':
                case 'p': {
                    //
                    // Get the value from the varargs.
                    //
                    ulValue = va_arg(vaArgP, unsigned long);
c0d00862:	9806      	ldr	r0, [sp, #24]
c0d00864:	1d01      	adds	r1, r0, #4
c0d00866:	9106      	str	r1, [sp, #24]
c0d00868:	6806      	ldr	r6, [r0, #0]
c0d0086a:	960b      	str	r6, [sp, #44]	; 0x2c
c0d0086c:	2000      	movs	r0, #0
c0d0086e:	9001      	str	r0, [sp, #4]
c0d00870:	2010      	movs	r0, #16
c0d00872:	e034      	b.n	c0d008de <semihosted_printf+0x24e>
        memcpy(buf, str, written);
c0d00874:	1e60      	subs	r0, r4, #1
c0d00876:	7800      	ldrb	r0, [r0, #0]
c0d00878:	aa0c      	add	r2, sp, #48	; 0x30
c0d0087a:	2100      	movs	r1, #0
        buf[written] = 0;
c0d0087c:	7051      	strb	r1, [r2, #1]
        memcpy(buf, str, written);
c0d0087e:	7010      	strb	r0, [r2, #0]
    asm volatile(
c0d00880:	2004      	movs	r0, #4
c0d00882:	0011      	movs	r1, r2
c0d00884:	dfab      	svc	171	; 0xab
c0d00886:	e70e      	b.n	c0d006a6 <semihosted_printf+0x16>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d00888:	9806      	ldr	r0, [sp, #24]
c0d0088a:	1d01      	adds	r1, r0, #4
c0d0088c:	9106      	str	r1, [sp, #24]
c0d0088e:	6806      	ldr	r6, [r0, #0]
c0d00890:	960b      	str	r6, [sp, #44]	; 0x2c
c0d00892:	2000      	movs	r0, #0
c0d00894:	9001      	str	r0, [sp, #4]
c0d00896:	200a      	movs	r0, #10
c0d00898:	e021      	b.n	c0d008de <semihosted_printf+0x24e>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d0089a:	9806      	ldr	r0, [sp, #24]
c0d0089c:	1d01      	adds	r1, r0, #4
c0d0089e:	9106      	str	r1, [sp, #24]
c0d008a0:	6800      	ldr	r0, [r0, #0]
c0d008a2:	900b      	str	r0, [sp, #44]	; 0x2c
c0d008a4:	aa0c      	add	r2, sp, #48	; 0x30
c0d008a6:	2100      	movs	r1, #0
        buf[written] = 0;
c0d008a8:	7051      	strb	r1, [r2, #1]
        memcpy(buf, str, written);
c0d008aa:	7010      	strb	r0, [r2, #0]
    asm volatile(
c0d008ac:	2004      	movs	r0, #4
c0d008ae:	0011      	movs	r1, r2
c0d008b0:	dfab      	svc	171	; 0xab
c0d008b2:	e6f8      	b.n	c0d006a6 <semihosted_printf+0x16>
                            if (pcStr[0] == '\0') {
c0d008b4:	7810      	ldrb	r0, [r2, #0]
c0d008b6:	2800      	cmp	r0, #0
c0d008b8:	d077      	beq.n	c0d009aa <semihosted_printf+0x31a>
c0d008ba:	aa0c      	add	r2, sp, #48	; 0x30
c0d008bc:	2052      	movs	r0, #82	; 0x52
        memcpy(buf, str, written);
c0d008be:	8090      	strh	r0, [r2, #4]
c0d008c0:	4849      	ldr	r0, [pc, #292]	; (c0d009e8 <semihosted_printf+0x358>)
c0d008c2:	900c      	str	r0, [sp, #48]	; 0x30
    asm volatile(
c0d008c4:	2004      	movs	r0, #4
c0d008c6:	0011      	movs	r1, r2
c0d008c8:	dfab      	svc	171	; 0xab
c0d008ca:	e6ec      	b.n	c0d006a6 <semihosted_printf+0x16>
                            prints(pcStr, ulIdx);
c0d008cc:	b2b1      	uxth	r1, r6
c0d008ce:	4610      	mov	r0, r2
c0d008d0:	f000 f894 	bl	c0d009fc <prints>
c0d008d4:	e073      	b.n	c0d009be <semihosted_printf+0x32e>
                        ulValue = -(long) ulValue;
c0d008d6:	4276      	negs	r6, r6
c0d008d8:	960b      	str	r6, [sp, #44]	; 0x2c
c0d008da:	2101      	movs	r1, #1
c0d008dc:	9101      	str	r1, [sp, #4]
c0d008de:	9702      	str	r7, [sp, #8]
                    // Determine the number of digits in the string version of
                    // the value.
                    //
                convert:
                    for (ulIdx = 1;
                         (((ulIdx * ulBase) <= ulValue) && (((ulIdx * ulBase) / ulBase) == ulIdx));
c0d008e0:	42b0      	cmp	r0, r6
c0d008e2:	9003      	str	r0, [sp, #12]
c0d008e4:	d901      	bls.n	c0d008ea <semihosted_printf+0x25a>
c0d008e6:	2701      	movs	r7, #1
c0d008e8:	e00f      	b.n	c0d0090a <semihosted_printf+0x27a>
                    for (ulIdx = 1;
c0d008ea:	1e6a      	subs	r2, r5, #1
c0d008ec:	4607      	mov	r7, r0
c0d008ee:	4615      	mov	r5, r2
c0d008f0:	2100      	movs	r1, #0
                         (((ulIdx * ulBase) <= ulValue) && (((ulIdx * ulBase) / ulBase) == ulIdx));
c0d008f2:	9803      	ldr	r0, [sp, #12]
c0d008f4:	463a      	mov	r2, r7
c0d008f6:	460b      	mov	r3, r1
c0d008f8:	f000 f984 	bl	c0d00c04 <__aeabi_lmul>
c0d008fc:	1e4a      	subs	r2, r1, #1
c0d008fe:	4191      	sbcs	r1, r2
c0d00900:	42b0      	cmp	r0, r6
c0d00902:	d802      	bhi.n	c0d0090a <semihosted_printf+0x27a>
                    for (ulIdx = 1;
c0d00904:	1e6a      	subs	r2, r5, #1
c0d00906:	2900      	cmp	r1, #0
c0d00908:	d0f0      	beq.n	c0d008ec <semihosted_printf+0x25c>
c0d0090a:	9801      	ldr	r0, [sp, #4]

                    //
                    // If the value is negative, reduce the count of padding
                    // characters needed.
                    //
                    if (ulNeg) {
c0d0090c:	2800      	cmp	r0, #0
c0d0090e:	9605      	str	r6, [sp, #20]
c0d00910:	d000      	beq.n	c0d00914 <semihosted_printf+0x284>
c0d00912:	1e6d      	subs	r5, r5, #1
c0d00914:	9a04      	ldr	r2, [sp, #16]
c0d00916:	2600      	movs	r6, #0

                    //
                    // If the value is negative and the value is padded with
                    // zeros, then place the minus sign before the padding.
                    //
                    if (ulNeg && (cFill == '0')) {
c0d00918:	2800      	cmp	r0, #0
c0d0091a:	d009      	beq.n	c0d00930 <semihosted_printf+0x2a0>
c0d0091c:	b2d0      	uxtb	r0, r2
c0d0091e:	2830      	cmp	r0, #48	; 0x30
c0d00920:	d108      	bne.n	c0d00934 <semihosted_printf+0x2a4>
c0d00922:	a807      	add	r0, sp, #28
c0d00924:	212d      	movs	r1, #45	; 0x2d
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d00926:	7001      	strb	r1, [r0, #0]
c0d00928:	2001      	movs	r0, #1
c0d0092a:	4631      	mov	r1, r6
c0d0092c:	4606      	mov	r6, r0
c0d0092e:	e002      	b.n	c0d00936 <semihosted_printf+0x2a6>
c0d00930:	4631      	mov	r1, r6
c0d00932:	e000      	b.n	c0d00936 <semihosted_printf+0x2a6>
c0d00934:	2101      	movs	r1, #1

                    //
                    // Provide additional padding at the beginning of the
                    // string conversion if needed.
                    //
                    if ((ulCount > 1) && (ulCount < 16)) {
c0d00936:	1ea8      	subs	r0, r5, #2
c0d00938:	280d      	cmp	r0, #13
c0d0093a:	d80c      	bhi.n	c0d00956 <semihosted_printf+0x2c6>
c0d0093c:	a807      	add	r0, sp, #28
                        for (ulCount--; ulCount; ulCount--) {
c0d0093e:	1980      	adds	r0, r0, r6
c0d00940:	1e6d      	subs	r5, r5, #1
                            pcBuf[ulPos++] = cFill;
c0d00942:	b2d2      	uxtb	r2, r2
c0d00944:	9104      	str	r1, [sp, #16]
c0d00946:	4629      	mov	r1, r5
c0d00948:	f000 f993 	bl	c0d00c72 <__aeabi_memset>
c0d0094c:	9904      	ldr	r1, [sp, #16]
c0d0094e:	1e6d      	subs	r5, r5, #1
c0d00950:	1c76      	adds	r6, r6, #1
                        for (ulCount--; ulCount; ulCount--) {
c0d00952:	2d00      	cmp	r5, #0
c0d00954:	d1fb      	bne.n	c0d0094e <semihosted_printf+0x2be>

                    //
                    // If the value is negative, then place the minus sign
                    // before the number.
                    //
                    if (ulNeg) {
c0d00956:	2900      	cmp	r1, #0
c0d00958:	d003      	beq.n	c0d00962 <semihosted_printf+0x2d2>
c0d0095a:	a807      	add	r0, sp, #28
c0d0095c:	212d      	movs	r1, #45	; 0x2d
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d0095e:	5581      	strb	r1, [r0, r6]
c0d00960:	1c76      	adds	r6, r6, #1
                    }

                    //
                    // Convert the value into a string.
                    //
                    for (; ulIdx; ulIdx /= ulBase) {
c0d00962:	2f00      	cmp	r7, #0
c0d00964:	d01c      	beq.n	c0d009a0 <semihosted_printf+0x310>
c0d00966:	9802      	ldr	r0, [sp, #8]
c0d00968:	2800      	cmp	r0, #0
c0d0096a:	d002      	beq.n	c0d00972 <semihosted_printf+0x2e2>
c0d0096c:	4822      	ldr	r0, [pc, #136]	; (c0d009f8 <semihosted_printf+0x368>)
c0d0096e:	4478      	add	r0, pc
c0d00970:	e001      	b.n	c0d00976 <semihosted_printf+0x2e6>
c0d00972:	4820      	ldr	r0, [pc, #128]	; (c0d009f4 <semihosted_printf+0x364>)
c0d00974:	4478      	add	r0, pc
c0d00976:	9004      	str	r0, [sp, #16]
c0d00978:	9d03      	ldr	r5, [sp, #12]
c0d0097a:	9805      	ldr	r0, [sp, #20]
c0d0097c:	4639      	mov	r1, r7
c0d0097e:	f000 f8b5 	bl	c0d00aec <__udivsi3>
c0d00982:	4629      	mov	r1, r5
c0d00984:	f000 f938 	bl	c0d00bf8 <__aeabi_uidivmod>
c0d00988:	9804      	ldr	r0, [sp, #16]
c0d0098a:	5c40      	ldrb	r0, [r0, r1]
c0d0098c:	a907      	add	r1, sp, #28
                        if (!ulCap) {
                            pcBuf[ulPos++] = g_pcHex[(ulValue / ulIdx) % ulBase];
c0d0098e:	5588      	strb	r0, [r1, r6]
                    for (; ulIdx; ulIdx /= ulBase) {
c0d00990:	4638      	mov	r0, r7
c0d00992:	4629      	mov	r1, r5
c0d00994:	f000 f8aa 	bl	c0d00aec <__udivsi3>
c0d00998:	1c76      	adds	r6, r6, #1
c0d0099a:	42bd      	cmp	r5, r7
c0d0099c:	4607      	mov	r7, r0
c0d0099e:	d9ec      	bls.n	c0d0097a <semihosted_printf+0x2ea>
                    }

                    //
                    // Write the string.
                    //
                    prints(pcBuf, ulPos);
c0d009a0:	b2b1      	uxth	r1, r6
c0d009a2:	a807      	add	r0, sp, #28
c0d009a4:	f000 f82a 	bl	c0d009fc <prints>
c0d009a8:	e67d      	b.n	c0d006a6 <semihosted_printf+0x16>
                                do {
c0d009aa:	9805      	ldr	r0, [sp, #20]
c0d009ac:	1c42      	adds	r2, r0, #1
c0d009ae:	ab0c      	add	r3, sp, #48	; 0x30
c0d009b0:	2020      	movs	r0, #32
        memcpy(buf, str, written);
c0d009b2:	8018      	strh	r0, [r3, #0]
    asm volatile(
c0d009b4:	2004      	movs	r0, #4
c0d009b6:	0019      	movs	r1, r3
c0d009b8:	dfab      	svc	171	; 0xab
                                } while (ulStrlen-- > 0);
c0d009ba:	1e52      	subs	r2, r2, #1
c0d009bc:	d1f7      	bne.n	c0d009ae <semihosted_printf+0x31e>
                    if (ulCount > ulIdx) {
c0d009be:	42b5      	cmp	r5, r6
c0d009c0:	d800      	bhi.n	c0d009c4 <semihosted_printf+0x334>
c0d009c2:	e670      	b.n	c0d006a6 <semihosted_printf+0x16>
                        ulCount -= ulIdx;
c0d009c4:	1ba8      	subs	r0, r5, r6
c0d009c6:	d100      	bne.n	c0d009ca <semihosted_printf+0x33a>
c0d009c8:	e66d      	b.n	c0d006a6 <semihosted_printf+0x16>
                        while (ulCount--) {
c0d009ca:	1b72      	subs	r2, r6, r5
c0d009cc:	ab0c      	add	r3, sp, #48	; 0x30
c0d009ce:	2020      	movs	r0, #32
        memcpy(buf, str, written);
c0d009d0:	8018      	strh	r0, [r3, #0]
    asm volatile(
c0d009d2:	2004      	movs	r0, #4
c0d009d4:	0019      	movs	r1, r3
c0d009d6:	dfab      	svc	171	; 0xab
                        while (ulCount--) {
c0d009d8:	1c52      	adds	r2, r2, #1
c0d009da:	d3f7      	bcc.n	c0d009cc <semihosted_printf+0x33c>
c0d009dc:	e663      	b.n	c0d006a6 <semihosted_printf+0x16>

    //
    // End the varargs processing.
    //
    va_end(vaArgP);
c0d009de:	b01c      	add	sp, #112	; 0x70
c0d009e0:	bcf0      	pop	{r4, r5, r6, r7}
c0d009e2:	bc01      	pop	{r0}
c0d009e4:	b003      	add	sp, #12
c0d009e6:	4700      	bx	r0
c0d009e8:	4f525245 	.word	0x4f525245
c0d009ec:	00000aa3 	.word	0x00000aa3
c0d009f0:	00000a8b 	.word	0x00000a8b
c0d009f4:	00000939 	.word	0x00000939
c0d009f8:	0000094f 	.word	0x0000094f

c0d009fc <prints>:
static void prints(const char *str, uint16_t size) {
c0d009fc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d009fe:	b091      	sub	sp, #68	; 0x44
    while (size > 0) {
c0d00a00:	2900      	cmp	r1, #0
c0d00a02:	d01a      	beq.n	c0d00a3a <prints+0x3e>
c0d00a04:	460c      	mov	r4, r1
c0d00a06:	4605      	mov	r5, r0
c0d00a08:	b2a6      	uxth	r6, r4
        uint8_t written = MIN(sizeof(buf) - 1, size);
c0d00a0a:	2e3f      	cmp	r6, #63	; 0x3f
c0d00a0c:	9600      	str	r6, [sp, #0]
c0d00a0e:	d300      	bcc.n	c0d00a12 <prints+0x16>
c0d00a10:	263f      	movs	r6, #63	; 0x3f
c0d00a12:	af01      	add	r7, sp, #4
        memcpy(buf, str, written);
c0d00a14:	4638      	mov	r0, r7
c0d00a16:	4629      	mov	r1, r5
c0d00a18:	4632      	mov	r2, r6
c0d00a1a:	f000 f926 	bl	c0d00c6a <__aeabi_memcpy>
c0d00a1e:	2000      	movs	r0, #0
        buf[written] = 0;
c0d00a20:	55b8      	strb	r0, [r7, r6]
    asm volatile(
c0d00a22:	2004      	movs	r0, #4
c0d00a24:	0039      	movs	r1, r7
c0d00a26:	dfab      	svc	171	; 0xab
c0d00a28:	9a00      	ldr	r2, [sp, #0]
c0d00a2a:	4296      	cmp	r6, r2
c0d00a2c:	da00      	bge.n	c0d00a30 <prints+0x34>
c0d00a2e:	19ad      	adds	r5, r5, r6
        if (written >= size) {
c0d00a30:	1ba4      	subs	r4, r4, r6
    while (size > 0) {
c0d00a32:	0420      	lsls	r0, r4, #16
c0d00a34:	d001      	beq.n	c0d00a3a <prints+0x3e>
c0d00a36:	4296      	cmp	r6, r2
c0d00a38:	dbe6      	blt.n	c0d00a08 <prints+0xc>
}
c0d00a3a:	b011      	add	sp, #68	; 0x44
c0d00a3c:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d00a3e <SVC_Call>:
.thumb
.thumb_func
.global SVC_Call

SVC_Call:
    svc 1
c0d00a3e:	df01      	svc	1
    cmp r1, #0
c0d00a40:	2900      	cmp	r1, #0
    bne exception
c0d00a42:	d100      	bne.n	c0d00a46 <exception>
    bx lr
c0d00a44:	4770      	bx	lr

c0d00a46 <exception>:
exception:
    // THROW(ex);
    mov r0, r1
c0d00a46:	4608      	mov	r0, r1
    bl os_longjmp
c0d00a48:	f7ff fe1b 	bl	c0d00682 <os_longjmp>

c0d00a4c <get_api_level>:
#include <string.h>

unsigned int SVC_Call(unsigned int syscall_id, void *parameters);
unsigned int SVC_cx_call(unsigned int syscall_id, unsigned int * parameters);

unsigned int get_api_level(void) {
c0d00a4c:	b580      	push	{r7, lr}
c0d00a4e:	b084      	sub	sp, #16
c0d00a50:	2000      	movs	r0, #0
  unsigned int parameters [2+1];
  parameters[0] = 0;
  parameters[1] = 0;
c0d00a52:	9002      	str	r0, [sp, #8]
  parameters[0] = 0;
c0d00a54:	9001      	str	r0, [sp, #4]
c0d00a56:	4803      	ldr	r0, [pc, #12]	; (c0d00a64 <get_api_level+0x18>)
c0d00a58:	a901      	add	r1, sp, #4
  return SVC_Call(SYSCALL_get_api_level_ID_IN, parameters);
c0d00a5a:	f7ff fff0 	bl	c0d00a3e <SVC_Call>
c0d00a5e:	b004      	add	sp, #16
c0d00a60:	bd80      	pop	{r7, pc}
c0d00a62:	46c0      	nop			; (mov r8, r8)
c0d00a64:	60000138 	.word	0x60000138

c0d00a68 <os_lib_call>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_ux_result_ID_IN, parameters);
  return;
}

void os_lib_call ( unsigned int * call_parameters ) {
c0d00a68:	b580      	push	{r7, lr}
c0d00a6a:	b084      	sub	sp, #16
c0d00a6c:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)call_parameters;
  parameters[1] = 0;
c0d00a6e:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)call_parameters;
c0d00a70:	9001      	str	r0, [sp, #4]
c0d00a72:	4803      	ldr	r0, [pc, #12]	; (c0d00a80 <os_lib_call+0x18>)
c0d00a74:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_lib_call_ID_IN, parameters);
c0d00a76:	f7ff ffe2 	bl	c0d00a3e <SVC_Call>
  return;
}
c0d00a7a:	b004      	add	sp, #16
c0d00a7c:	bd80      	pop	{r7, pc}
c0d00a7e:	46c0      	nop			; (mov r8, r8)
c0d00a80:	6000670d 	.word	0x6000670d

c0d00a84 <os_lib_end>:

void os_lib_end ( void ) {
c0d00a84:	b580      	push	{r7, lr}
c0d00a86:	b082      	sub	sp, #8
c0d00a88:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d00a8a:	9001      	str	r0, [sp, #4]
c0d00a8c:	4802      	ldr	r0, [pc, #8]	; (c0d00a98 <os_lib_end+0x14>)
c0d00a8e:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_os_lib_end_ID_IN, parameters);
c0d00a90:	f7ff ffd5 	bl	c0d00a3e <SVC_Call>
  return;
}
c0d00a94:	b002      	add	sp, #8
c0d00a96:	bd80      	pop	{r7, pc}
c0d00a98:	6000688d 	.word	0x6000688d

c0d00a9c <os_sched_exit>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_exec_ID_IN, parameters);
  return;
}

void os_sched_exit ( bolos_task_status_t exit_code ) {
c0d00a9c:	b580      	push	{r7, lr}
c0d00a9e:	b084      	sub	sp, #16
c0d00aa0:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)exit_code;
  parameters[1] = 0;
c0d00aa2:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)exit_code;
c0d00aa4:	9001      	str	r0, [sp, #4]
c0d00aa6:	4803      	ldr	r0, [pc, #12]	; (c0d00ab4 <os_sched_exit+0x18>)
c0d00aa8:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0d00aaa:	f7ff ffc8 	bl	c0d00a3e <SVC_Call>
  return;
}
c0d00aae:	b004      	add	sp, #16
c0d00ab0:	bd80      	pop	{r7, pc}
c0d00ab2:	46c0      	nop			; (mov r8, r8)
c0d00ab4:	60009abe 	.word	0x60009abe

c0d00ab8 <try_context_get>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_nvm_erase_page_ID_IN, parameters);
  return;
}

try_context_t * try_context_get ( void ) {
c0d00ab8:	b580      	push	{r7, lr}
c0d00aba:	b082      	sub	sp, #8
c0d00abc:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d00abe:	9001      	str	r0, [sp, #4]
c0d00ac0:	4802      	ldr	r0, [pc, #8]	; (c0d00acc <try_context_get+0x14>)
c0d00ac2:	4669      	mov	r1, sp
  return (try_context_t *) SVC_Call(SYSCALL_try_context_get_ID_IN, parameters);
c0d00ac4:	f7ff ffbb 	bl	c0d00a3e <SVC_Call>
c0d00ac8:	b002      	add	sp, #8
c0d00aca:	bd80      	pop	{r7, pc}
c0d00acc:	600087b1 	.word	0x600087b1

c0d00ad0 <try_context_set>:
}

try_context_t * try_context_set ( try_context_t *context ) {
c0d00ad0:	b580      	push	{r7, lr}
c0d00ad2:	b084      	sub	sp, #16
c0d00ad4:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)context;
  parameters[1] = 0;
c0d00ad6:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)context;
c0d00ad8:	9001      	str	r0, [sp, #4]
c0d00ada:	4803      	ldr	r0, [pc, #12]	; (c0d00ae8 <try_context_set+0x18>)
c0d00adc:	a901      	add	r1, sp, #4
  return (try_context_t *) SVC_Call(SYSCALL_try_context_set_ID_IN, parameters);
c0d00ade:	f7ff ffae 	bl	c0d00a3e <SVC_Call>
c0d00ae2:	b004      	add	sp, #16
c0d00ae4:	bd80      	pop	{r7, pc}
c0d00ae6:	46c0      	nop			; (mov r8, r8)
c0d00ae8:	60010b06 	.word	0x60010b06

c0d00aec <__udivsi3>:
c0d00aec:	2200      	movs	r2, #0
c0d00aee:	0843      	lsrs	r3, r0, #1
c0d00af0:	428b      	cmp	r3, r1
c0d00af2:	d374      	bcc.n	c0d00bde <__udivsi3+0xf2>
c0d00af4:	0903      	lsrs	r3, r0, #4
c0d00af6:	428b      	cmp	r3, r1
c0d00af8:	d35f      	bcc.n	c0d00bba <__udivsi3+0xce>
c0d00afa:	0a03      	lsrs	r3, r0, #8
c0d00afc:	428b      	cmp	r3, r1
c0d00afe:	d344      	bcc.n	c0d00b8a <__udivsi3+0x9e>
c0d00b00:	0b03      	lsrs	r3, r0, #12
c0d00b02:	428b      	cmp	r3, r1
c0d00b04:	d328      	bcc.n	c0d00b58 <__udivsi3+0x6c>
c0d00b06:	0c03      	lsrs	r3, r0, #16
c0d00b08:	428b      	cmp	r3, r1
c0d00b0a:	d30d      	bcc.n	c0d00b28 <__udivsi3+0x3c>
c0d00b0c:	22ff      	movs	r2, #255	; 0xff
c0d00b0e:	0209      	lsls	r1, r1, #8
c0d00b10:	ba12      	rev	r2, r2
c0d00b12:	0c03      	lsrs	r3, r0, #16
c0d00b14:	428b      	cmp	r3, r1
c0d00b16:	d302      	bcc.n	c0d00b1e <__udivsi3+0x32>
c0d00b18:	1212      	asrs	r2, r2, #8
c0d00b1a:	0209      	lsls	r1, r1, #8
c0d00b1c:	d065      	beq.n	c0d00bea <__udivsi3+0xfe>
c0d00b1e:	0b03      	lsrs	r3, r0, #12
c0d00b20:	428b      	cmp	r3, r1
c0d00b22:	d319      	bcc.n	c0d00b58 <__udivsi3+0x6c>
c0d00b24:	e000      	b.n	c0d00b28 <__udivsi3+0x3c>
c0d00b26:	0a09      	lsrs	r1, r1, #8
c0d00b28:	0bc3      	lsrs	r3, r0, #15
c0d00b2a:	428b      	cmp	r3, r1
c0d00b2c:	d301      	bcc.n	c0d00b32 <__udivsi3+0x46>
c0d00b2e:	03cb      	lsls	r3, r1, #15
c0d00b30:	1ac0      	subs	r0, r0, r3
c0d00b32:	4152      	adcs	r2, r2
c0d00b34:	0b83      	lsrs	r3, r0, #14
c0d00b36:	428b      	cmp	r3, r1
c0d00b38:	d301      	bcc.n	c0d00b3e <__udivsi3+0x52>
c0d00b3a:	038b      	lsls	r3, r1, #14
c0d00b3c:	1ac0      	subs	r0, r0, r3
c0d00b3e:	4152      	adcs	r2, r2
c0d00b40:	0b43      	lsrs	r3, r0, #13
c0d00b42:	428b      	cmp	r3, r1
c0d00b44:	d301      	bcc.n	c0d00b4a <__udivsi3+0x5e>
c0d00b46:	034b      	lsls	r3, r1, #13
c0d00b48:	1ac0      	subs	r0, r0, r3
c0d00b4a:	4152      	adcs	r2, r2
c0d00b4c:	0b03      	lsrs	r3, r0, #12
c0d00b4e:	428b      	cmp	r3, r1
c0d00b50:	d301      	bcc.n	c0d00b56 <__udivsi3+0x6a>
c0d00b52:	030b      	lsls	r3, r1, #12
c0d00b54:	1ac0      	subs	r0, r0, r3
c0d00b56:	4152      	adcs	r2, r2
c0d00b58:	0ac3      	lsrs	r3, r0, #11
c0d00b5a:	428b      	cmp	r3, r1
c0d00b5c:	d301      	bcc.n	c0d00b62 <__udivsi3+0x76>
c0d00b5e:	02cb      	lsls	r3, r1, #11
c0d00b60:	1ac0      	subs	r0, r0, r3
c0d00b62:	4152      	adcs	r2, r2
c0d00b64:	0a83      	lsrs	r3, r0, #10
c0d00b66:	428b      	cmp	r3, r1
c0d00b68:	d301      	bcc.n	c0d00b6e <__udivsi3+0x82>
c0d00b6a:	028b      	lsls	r3, r1, #10
c0d00b6c:	1ac0      	subs	r0, r0, r3
c0d00b6e:	4152      	adcs	r2, r2
c0d00b70:	0a43      	lsrs	r3, r0, #9
c0d00b72:	428b      	cmp	r3, r1
c0d00b74:	d301      	bcc.n	c0d00b7a <__udivsi3+0x8e>
c0d00b76:	024b      	lsls	r3, r1, #9
c0d00b78:	1ac0      	subs	r0, r0, r3
c0d00b7a:	4152      	adcs	r2, r2
c0d00b7c:	0a03      	lsrs	r3, r0, #8
c0d00b7e:	428b      	cmp	r3, r1
c0d00b80:	d301      	bcc.n	c0d00b86 <__udivsi3+0x9a>
c0d00b82:	020b      	lsls	r3, r1, #8
c0d00b84:	1ac0      	subs	r0, r0, r3
c0d00b86:	4152      	adcs	r2, r2
c0d00b88:	d2cd      	bcs.n	c0d00b26 <__udivsi3+0x3a>
c0d00b8a:	09c3      	lsrs	r3, r0, #7
c0d00b8c:	428b      	cmp	r3, r1
c0d00b8e:	d301      	bcc.n	c0d00b94 <__udivsi3+0xa8>
c0d00b90:	01cb      	lsls	r3, r1, #7
c0d00b92:	1ac0      	subs	r0, r0, r3
c0d00b94:	4152      	adcs	r2, r2
c0d00b96:	0983      	lsrs	r3, r0, #6
c0d00b98:	428b      	cmp	r3, r1
c0d00b9a:	d301      	bcc.n	c0d00ba0 <__udivsi3+0xb4>
c0d00b9c:	018b      	lsls	r3, r1, #6
c0d00b9e:	1ac0      	subs	r0, r0, r3
c0d00ba0:	4152      	adcs	r2, r2
c0d00ba2:	0943      	lsrs	r3, r0, #5
c0d00ba4:	428b      	cmp	r3, r1
c0d00ba6:	d301      	bcc.n	c0d00bac <__udivsi3+0xc0>
c0d00ba8:	014b      	lsls	r3, r1, #5
c0d00baa:	1ac0      	subs	r0, r0, r3
c0d00bac:	4152      	adcs	r2, r2
c0d00bae:	0903      	lsrs	r3, r0, #4
c0d00bb0:	428b      	cmp	r3, r1
c0d00bb2:	d301      	bcc.n	c0d00bb8 <__udivsi3+0xcc>
c0d00bb4:	010b      	lsls	r3, r1, #4
c0d00bb6:	1ac0      	subs	r0, r0, r3
c0d00bb8:	4152      	adcs	r2, r2
c0d00bba:	08c3      	lsrs	r3, r0, #3
c0d00bbc:	428b      	cmp	r3, r1
c0d00bbe:	d301      	bcc.n	c0d00bc4 <__udivsi3+0xd8>
c0d00bc0:	00cb      	lsls	r3, r1, #3
c0d00bc2:	1ac0      	subs	r0, r0, r3
c0d00bc4:	4152      	adcs	r2, r2
c0d00bc6:	0883      	lsrs	r3, r0, #2
c0d00bc8:	428b      	cmp	r3, r1
c0d00bca:	d301      	bcc.n	c0d00bd0 <__udivsi3+0xe4>
c0d00bcc:	008b      	lsls	r3, r1, #2
c0d00bce:	1ac0      	subs	r0, r0, r3
c0d00bd0:	4152      	adcs	r2, r2
c0d00bd2:	0843      	lsrs	r3, r0, #1
c0d00bd4:	428b      	cmp	r3, r1
c0d00bd6:	d301      	bcc.n	c0d00bdc <__udivsi3+0xf0>
c0d00bd8:	004b      	lsls	r3, r1, #1
c0d00bda:	1ac0      	subs	r0, r0, r3
c0d00bdc:	4152      	adcs	r2, r2
c0d00bde:	1a41      	subs	r1, r0, r1
c0d00be0:	d200      	bcs.n	c0d00be4 <__udivsi3+0xf8>
c0d00be2:	4601      	mov	r1, r0
c0d00be4:	4152      	adcs	r2, r2
c0d00be6:	4610      	mov	r0, r2
c0d00be8:	4770      	bx	lr
c0d00bea:	e7ff      	b.n	c0d00bec <__udivsi3+0x100>
c0d00bec:	b501      	push	{r0, lr}
c0d00bee:	2000      	movs	r0, #0
c0d00bf0:	f000 f806 	bl	c0d00c00 <__aeabi_idiv0>
c0d00bf4:	bd02      	pop	{r1, pc}
c0d00bf6:	46c0      	nop			; (mov r8, r8)

c0d00bf8 <__aeabi_uidivmod>:
c0d00bf8:	2900      	cmp	r1, #0
c0d00bfa:	d0f7      	beq.n	c0d00bec <__udivsi3+0x100>
c0d00bfc:	e776      	b.n	c0d00aec <__udivsi3>
c0d00bfe:	4770      	bx	lr

c0d00c00 <__aeabi_idiv0>:
c0d00c00:	4770      	bx	lr
c0d00c02:	46c0      	nop			; (mov r8, r8)

c0d00c04 <__aeabi_lmul>:
c0d00c04:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00c06:	46ce      	mov	lr, r9
c0d00c08:	4647      	mov	r7, r8
c0d00c0a:	b580      	push	{r7, lr}
c0d00c0c:	0007      	movs	r7, r0
c0d00c0e:	4699      	mov	r9, r3
c0d00c10:	0c3b      	lsrs	r3, r7, #16
c0d00c12:	469c      	mov	ip, r3
c0d00c14:	0413      	lsls	r3, r2, #16
c0d00c16:	0c1b      	lsrs	r3, r3, #16
c0d00c18:	001d      	movs	r5, r3
c0d00c1a:	000e      	movs	r6, r1
c0d00c1c:	4661      	mov	r1, ip
c0d00c1e:	0400      	lsls	r0, r0, #16
c0d00c20:	0c14      	lsrs	r4, r2, #16
c0d00c22:	0c00      	lsrs	r0, r0, #16
c0d00c24:	4345      	muls	r5, r0
c0d00c26:	434b      	muls	r3, r1
c0d00c28:	4360      	muls	r0, r4
c0d00c2a:	4361      	muls	r1, r4
c0d00c2c:	18c0      	adds	r0, r0, r3
c0d00c2e:	0c2c      	lsrs	r4, r5, #16
c0d00c30:	1820      	adds	r0, r4, r0
c0d00c32:	468c      	mov	ip, r1
c0d00c34:	4283      	cmp	r3, r0
c0d00c36:	d903      	bls.n	c0d00c40 <__aeabi_lmul+0x3c>
c0d00c38:	2380      	movs	r3, #128	; 0x80
c0d00c3a:	025b      	lsls	r3, r3, #9
c0d00c3c:	4698      	mov	r8, r3
c0d00c3e:	44c4      	add	ip, r8
c0d00c40:	4649      	mov	r1, r9
c0d00c42:	4379      	muls	r1, r7
c0d00c44:	4372      	muls	r2, r6
c0d00c46:	0c03      	lsrs	r3, r0, #16
c0d00c48:	4463      	add	r3, ip
c0d00c4a:	042d      	lsls	r5, r5, #16
c0d00c4c:	0c2d      	lsrs	r5, r5, #16
c0d00c4e:	18c9      	adds	r1, r1, r3
c0d00c50:	0400      	lsls	r0, r0, #16
c0d00c52:	1940      	adds	r0, r0, r5
c0d00c54:	1889      	adds	r1, r1, r2
c0d00c56:	bcc0      	pop	{r6, r7}
c0d00c58:	46b9      	mov	r9, r7
c0d00c5a:	46b0      	mov	r8, r6
c0d00c5c:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00c5e:	46c0      	nop			; (mov r8, r8)

c0d00c60 <__aeabi_memclr>:
c0d00c60:	b510      	push	{r4, lr}
c0d00c62:	2200      	movs	r2, #0
c0d00c64:	f000 f805 	bl	c0d00c72 <__aeabi_memset>
c0d00c68:	bd10      	pop	{r4, pc}

c0d00c6a <__aeabi_memcpy>:
c0d00c6a:	b510      	push	{r4, lr}
c0d00c6c:	f000 f808 	bl	c0d00c80 <memcpy>
c0d00c70:	bd10      	pop	{r4, pc}

c0d00c72 <__aeabi_memset>:
c0d00c72:	000b      	movs	r3, r1
c0d00c74:	b510      	push	{r4, lr}
c0d00c76:	0011      	movs	r1, r2
c0d00c78:	001a      	movs	r2, r3
c0d00c7a:	f000 f80a 	bl	c0d00c92 <memset>
c0d00c7e:	bd10      	pop	{r4, pc}

c0d00c80 <memcpy>:
c0d00c80:	2300      	movs	r3, #0
c0d00c82:	b510      	push	{r4, lr}
c0d00c84:	429a      	cmp	r2, r3
c0d00c86:	d100      	bne.n	c0d00c8a <memcpy+0xa>
c0d00c88:	bd10      	pop	{r4, pc}
c0d00c8a:	5ccc      	ldrb	r4, [r1, r3]
c0d00c8c:	54c4      	strb	r4, [r0, r3]
c0d00c8e:	3301      	adds	r3, #1
c0d00c90:	e7f8      	b.n	c0d00c84 <memcpy+0x4>

c0d00c92 <memset>:
c0d00c92:	0003      	movs	r3, r0
c0d00c94:	1882      	adds	r2, r0, r2
c0d00c96:	4293      	cmp	r3, r2
c0d00c98:	d100      	bne.n	c0d00c9c <memset+0xa>
c0d00c9a:	4770      	bx	lr
c0d00c9c:	7019      	strb	r1, [r3, #0]
c0d00c9e:	3301      	adds	r3, #1
c0d00ca0:	e7f9      	b.n	c0d00c96 <memset+0x4>

c0d00ca2 <setjmp>:
c0d00ca2:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0d00ca4:	4641      	mov	r1, r8
c0d00ca6:	464a      	mov	r2, r9
c0d00ca8:	4653      	mov	r3, sl
c0d00caa:	465c      	mov	r4, fp
c0d00cac:	466d      	mov	r5, sp
c0d00cae:	4676      	mov	r6, lr
c0d00cb0:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0d00cb2:	3828      	subs	r0, #40	; 0x28
c0d00cb4:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d00cb6:	2000      	movs	r0, #0
c0d00cb8:	4770      	bx	lr

c0d00cba <longjmp>:
c0d00cba:	3010      	adds	r0, #16
c0d00cbc:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0d00cbe:	4690      	mov	r8, r2
c0d00cc0:	4699      	mov	r9, r3
c0d00cc2:	46a2      	mov	sl, r4
c0d00cc4:	46ab      	mov	fp, r5
c0d00cc6:	46b5      	mov	sp, r6
c0d00cc8:	c808      	ldmia	r0!, {r3}
c0d00cca:	3828      	subs	r0, #40	; 0x28
c0d00ccc:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d00cce:	1c08      	adds	r0, r1, #0
c0d00cd0:	d100      	bne.n	c0d00cd4 <longjmp+0x1a>
c0d00cd2:	2001      	movs	r0, #1
c0d00cd4:	4718      	bx	r3

c0d00cd6 <strlcpy>:
c0d00cd6:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00cd8:	0005      	movs	r5, r0
c0d00cda:	2a00      	cmp	r2, #0
c0d00cdc:	d014      	beq.n	c0d00d08 <strlcpy+0x32>
c0d00cde:	1e50      	subs	r0, r2, #1
c0d00ce0:	2a01      	cmp	r2, #1
c0d00ce2:	d01c      	beq.n	c0d00d1e <strlcpy+0x48>
c0d00ce4:	002c      	movs	r4, r5
c0d00ce6:	000a      	movs	r2, r1
c0d00ce8:	0016      	movs	r6, r2
c0d00cea:	0027      	movs	r7, r4
c0d00cec:	7836      	ldrb	r6, [r6, #0]
c0d00cee:	3201      	adds	r2, #1
c0d00cf0:	3401      	adds	r4, #1
c0d00cf2:	0013      	movs	r3, r2
c0d00cf4:	0025      	movs	r5, r4
c0d00cf6:	703e      	strb	r6, [r7, #0]
c0d00cf8:	2e00      	cmp	r6, #0
c0d00cfa:	d00d      	beq.n	c0d00d18 <strlcpy+0x42>
c0d00cfc:	3801      	subs	r0, #1
c0d00cfe:	2800      	cmp	r0, #0
c0d00d00:	d1f2      	bne.n	c0d00ce8 <strlcpy+0x12>
c0d00d02:	2200      	movs	r2, #0
c0d00d04:	702a      	strb	r2, [r5, #0]
c0d00d06:	e000      	b.n	c0d00d0a <strlcpy+0x34>
c0d00d08:	000b      	movs	r3, r1
c0d00d0a:	001a      	movs	r2, r3
c0d00d0c:	3201      	adds	r2, #1
c0d00d0e:	1e50      	subs	r0, r2, #1
c0d00d10:	7800      	ldrb	r0, [r0, #0]
c0d00d12:	0013      	movs	r3, r2
c0d00d14:	2800      	cmp	r0, #0
c0d00d16:	d1f9      	bne.n	c0d00d0c <strlcpy+0x36>
c0d00d18:	1a58      	subs	r0, r3, r1
c0d00d1a:	3801      	subs	r0, #1
c0d00d1c:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00d1e:	000b      	movs	r3, r1
c0d00d20:	e7ef      	b.n	c0d00d02 <strlcpy+0x2c>
c0d00d22:	4e49      	.short	0x4e49
c0d00d24:	6e616820 	.word	0x6e616820
c0d00d28:	5f656c64 	.word	0x5f656c64
c0d00d2c:	74696e69 	.word	0x74696e69
c0d00d30:	6e6f635f 	.word	0x6e6f635f
c0d00d34:	63617274 	.word	0x63617274
c0d00d38:	50000a74 	.word	0x50000a74
c0d00d3c:	6967756c 	.word	0x6967756c
c0d00d40:	6170206e 	.word	0x6170206e
c0d00d44:	656d6172 	.word	0x656d6172
c0d00d48:	73726574 	.word	0x73726574
c0d00d4c:	72747320 	.word	0x72747320
c0d00d50:	75746375 	.word	0x75746375
c0d00d54:	69206572 	.word	0x69206572
c0d00d58:	69622073 	.word	0x69622073
c0d00d5c:	72656767 	.word	0x72656767
c0d00d60:	61687420 	.word	0x61687420
c0d00d64:	6c61206e 	.word	0x6c61206e
c0d00d68:	65776f6c 	.word	0x65776f6c
c0d00d6c:	69732064 	.word	0x69732064
c0d00d70:	000a657a 	.word	0x000a657a
c0d00d74:	276e6163 	.word	0x276e6163
c0d00d78:	69662074 	.word	0x69662074
c0d00d7c:	7320646e 	.word	0x7320646e
c0d00d80:	63656c65 	.word	0x63656c65
c0d00d84:	0a726f74 	.word	0x0a726f74
c0d00d88:	204e4900 	.word	0x204e4900
c0d00d8c:	41455243 	.word	0x41455243
c0d00d90:	000a4554 	.word	0x000a4554
c0d00d94:	50204e49 	.word	0x50204e49
c0d00d98:	45434f52 	.word	0x45434f52
c0d00d9c:	495f5353 	.word	0x495f5353
c0d00da0:	5455504e 	.word	0x5455504e
c0d00da4:	44524f5f 	.word	0x44524f5f
c0d00da8:	0a535245 	.word	0x0a535245
c0d00dac:	204e4900 	.word	0x204e4900
c0d00db0:	434f5250 	.word	0x434f5250
c0d00db4:	5f535345 	.word	0x5f535345
c0d00db8:	5054554f 	.word	0x5054554f
c0d00dbc:	4f5f5455 	.word	0x4f5f5455
c0d00dc0:	52454452 	.word	0x52454452
c0d00dc4:	49000a53 	.word	0x49000a53
c0d00dc8:	4544204e 	.word	0x4544204e
c0d00dcc:	4f525453 	.word	0x4f525453
c0d00dd0:	49000a59 	.word	0x49000a59
c0d00dd4:	4552204e 	.word	0x4552204e
c0d00dd8:	5341454c 	.word	0x5341454c
c0d00ddc:	4f542045 	.word	0x4f542045
c0d00de0:	534e454b 	.word	0x534e454b
c0d00de4:	4e49000a 	.word	0x4e49000a
c0d00de8:	41525420 	.word	0x41525420
c0d00dec:	4546534e 	.word	0x4546534e
c0d00df0:	52462052 	.word	0x52462052
c0d00df4:	000a4d4f 	.word	0x000a4d4f
c0d00df8:	7373694d 	.word	0x7373694d
c0d00dfc:	20676e69 	.word	0x20676e69
c0d00e00:	656c6573 	.word	0x656c6573
c0d00e04:	726f7463 	.word	0x726f7463
c0d00e08:	65646e49 	.word	0x65646e49
c0d00e0c:	25203a78 	.word	0x25203a78
c0d00e10:	0a64      	.short	0x0a64
c0d00e12:	00          	.byte	0x00
c0d00e13:	6d          	.byte	0x6d
c0d00e14:	3e2d6773 	.word	0x3e2d6773
c0d00e18:	61726170 	.word	0x61726170
c0d00e1c:	6574656d 	.word	0x6574656d
c0d00e20:	66664f72 	.word	0x66664f72
c0d00e24:	3a746573 	.word	0x3a746573
c0d00e28:	0a642520 	.word	0x0a642520
c0d00e2c:	42345500 	.word	0x42345500
c0d00e30:	736d2045 	.word	0x736d2045
c0d00e34:	703e2d67 	.word	0x703e2d67
c0d00e38:	6d617261 	.word	0x6d617261
c0d00e3c:	72657465 	.word	0x72657465
c0d00e40:	6425203a 	.word	0x6425203a
c0d00e44:	6f63000a 	.word	0x6f63000a
c0d00e48:	64656970 	.word	0x64656970
c0d00e4c:	66666f20 	.word	0x66666f20
c0d00e50:	3a746573 	.word	0x3a746573
c0d00e54:	0a642520 	.word	0x0a642520
c0d00e58:	756c7000 	.word	0x756c7000
c0d00e5c:	206e6967 	.word	0x206e6967
c0d00e60:	766f7270 	.word	0x766f7270
c0d00e64:	20656469 	.word	0x20656469
c0d00e68:	61726170 	.word	0x61726170
c0d00e6c:	6574656d 	.word	0x6574656d
c0d00e70:	6f203a72 	.word	0x6f203a72
c0d00e74:	65736666 	.word	0x65736666
c0d00e78:	64252074 	.word	0x64252074
c0d00e7c:	7479420a 	.word	0x7479420a
c0d00e80:	203a7365 	.word	0x203a7365
c0d00e84:	3b305b1b 	.word	0x3b305b1b
c0d00e88:	206d3133 	.word	0x206d3133
c0d00e8c:	482a2e25 	.word	0x482a2e25
c0d00e90:	305b1b20 	.word	0x305b1b20
c0d00e94:	000a206d 	.word	0x000a206d
c0d00e98:	646e6168 	.word	0x646e6168
c0d00e9c:	705f656c 	.word	0x705f656c
c0d00ea0:	69766f72 	.word	0x69766f72
c0d00ea4:	705f6564 	.word	0x705f6564
c0d00ea8:	6d617261 	.word	0x6d617261
c0d00eac:	72657465 	.word	0x72657465
c0d00eb0:	204e4920 	.word	0x204e4920
c0d00eb4:	4f494250 	.word	0x4f494250
c0d00eb8:	6553000a 	.word	0x6553000a
c0d00ebc:	7463656c 	.word	0x7463656c
c0d00ec0:	4920726f 	.word	0x4920726f
c0d00ec4:	7865646e 	.word	0x7865646e
c0d00ec8:	746f6e20 	.word	0x746f6e20
c0d00ecc:	70757320 	.word	0x70757320
c0d00ed0:	74726f70 	.word	0x74726f70
c0d00ed4:	203a6465 	.word	0x203a6465
c0d00ed8:	000a6425 	.word	0x000a6425
c0d00edc:	53524150 	.word	0x53524150
c0d00ee0:	20474e49 	.word	0x20474e49
c0d00ee4:	41455243 	.word	0x41455243
c0d00ee8:	000a4554 	.word	0x000a4554
c0d00eec:	41455243 	.word	0x41455243
c0d00ef0:	5f5f4554 	.word	0x5f5f4554
c0d00ef4:	454b4f54 	.word	0x454b4f54
c0d00ef8:	44495f4e 	.word	0x44495f4e
c0d00efc:	5349000a 	.word	0x5349000a
c0d00f00:	544f4e20 	.word	0x544f4e20
c0d00f04:	000a3020 	.word	0x000a3020
c0d00f08:	41455243 	.word	0x41455243
c0d00f0c:	5f5f4554 	.word	0x5f5f4554
c0d00f10:	5346464f 	.word	0x5346464f
c0d00f14:	425f5445 	.word	0x425f5445
c0d00f18:	48435441 	.word	0x48435441
c0d00f1c:	55504e49 	.word	0x55504e49
c0d00f20:	44524f54 	.word	0x44524f54
c0d00f24:	000a5245 	.word	0x000a5245
c0d00f28:	41455243 	.word	0x41455243
c0d00f2c:	5f5f4554 	.word	0x5f5f4554
c0d00f30:	5f4e454c 	.word	0x5f4e454c
c0d00f34:	43544142 	.word	0x43544142
c0d00f38:	504e4948 	.word	0x504e4948
c0d00f3c:	524f5455 	.word	0x524f5455
c0d00f40:	0a524544 	.word	0x0a524544
c0d00f44:	72756300 	.word	0x72756300
c0d00f48:	746e6572 	.word	0x746e6572
c0d00f4c:	6e656c5f 	.word	0x6e656c5f
c0d00f50:	3a687467 	.word	0x3a687467
c0d00f54:	0a642520 	.word	0x0a642520
c0d00f58:	45524300 	.word	0x45524300
c0d00f5c:	5f455441 	.word	0x5f455441
c0d00f60:	46464f5f 	.word	0x46464f5f
c0d00f64:	5f544553 	.word	0x5f544553
c0d00f68:	41525241 	.word	0x41525241
c0d00f6c:	41425f59 	.word	0x41425f59
c0d00f70:	49484354 	.word	0x49484354
c0d00f74:	5455504e 	.word	0x5455504e
c0d00f78:	4544524f 	.word	0x4544524f
c0d00f7c:	69202c52 	.word	0x69202c52
c0d00f80:	7865646e 	.word	0x7865646e
c0d00f84:	6425203a 	.word	0x6425203a
c0d00f88:	666f000a 	.word	0x666f000a
c0d00f8c:	74657366 	.word	0x74657366
c0d00f90:	766c5f73 	.word	0x766c5f73
c0d00f94:	255b306c 	.word	0x255b306c
c0d00f98:	203a5d64 	.word	0x203a5d64
c0d00f9c:	000a6425 	.word	0x000a6425
c0d00fa0:	20504f4e 	.word	0x20504f4e
c0d00fa4:	20504f4e 	.word	0x20504f4e
c0d00fa8:	41455243 	.word	0x41455243
c0d00fac:	5f5f4554 	.word	0x5f5f4554
c0d00fb0:	43544142 	.word	0x43544142
c0d00fb4:	4e495f48 	.word	0x4e495f48
c0d00fb8:	5f545550 	.word	0x5f545550
c0d00fbc:	4544524f 	.word	0x4544524f
c0d00fc0:	000a5352 	.word	0x000a5352
c0d00fc4:	61726150 	.word	0x61726150
c0d00fc8:	6f6e206d 	.word	0x6f6e206d
c0d00fcc:	75732074 	.word	0x75732074
c0d00fd0:	726f7070 	.word	0x726f7070
c0d00fd4:	3a646574 	.word	0x3a646574
c0d00fd8:	0a642520 	.word	0x0a642520
c0d00fdc:	52415000 	.word	0x52415000
c0d00fe0:	474e4953 	.word	0x474e4953
c0d00fe4:	4f494220 	.word	0x4f494220
c0d00fe8:	65747320 	.word	0x65747320
c0d00fec:	25203b70 	.word	0x25203b70
c0d00ff0:	70000a64 	.word	0x70000a64
c0d00ff4:	65737261 	.word	0x65737261
c0d00ff8:	4f494220 	.word	0x4f494220
c0d00ffc:	4e495f5f 	.word	0x4e495f5f
c0d01000:	54545550 	.word	0x54545550
c0d01004:	4e454b4f 	.word	0x4e454b4f
c0d01008:	6170000a 	.word	0x6170000a
c0d0100c:	20657372 	.word	0x20657372
c0d01010:	5f4f4942 	.word	0x5f4f4942
c0d01014:	4f4d415f 	.word	0x4f4d415f
c0d01018:	0a544e55 	.word	0x0a544e55
c0d0101c:	72617000 	.word	0x72617000
c0d01020:	42206573 	.word	0x42206573
c0d01024:	5f5f4f49 	.word	0x5f5f4f49
c0d01028:	5346464f 	.word	0x5346464f
c0d0102c:	4f5f5445 	.word	0x4f5f5445
c0d01030:	52454452 	.word	0x52454452
c0d01034:	70000a53 	.word	0x70000a53
c0d01038:	65737261 	.word	0x65737261
c0d0103c:	4f494220 	.word	0x4f494220
c0d01040:	52465f5f 	.word	0x52465f5f
c0d01044:	525f4d4f 	.word	0x525f4d4f
c0d01048:	52455345 	.word	0x52455345
c0d0104c:	000a4556 	.word	0x000a4556
c0d01050:	73726170 	.word	0x73726170
c0d01054:	49422065 	.word	0x49422065
c0d01058:	4c5f5f4f 	.word	0x4c5f5f4f
c0d0105c:	4f5f4e45 	.word	0x4f5f4e45
c0d01060:	52454452 	.word	0x52454452
c0d01064:	70000a53 	.word	0x70000a53
c0d01068:	65737261 	.word	0x65737261
c0d0106c:	4f494220 	.word	0x4f494220
c0d01070:	464f5f5f 	.word	0x464f5f5f
c0d01074:	54455346 	.word	0x54455346
c0d01078:	5252415f 	.word	0x5252415f
c0d0107c:	4f5f5941 	.word	0x4f5f5941
c0d01080:	52454452 	.word	0x52454452
c0d01084:	69202c53 	.word	0x69202c53
c0d01088:	7865646e 	.word	0x7865646e
c0d0108c:	6425203a 	.word	0x6425203a
c0d01090:	666f000a 	.word	0x666f000a
c0d01094:	74657366 	.word	0x74657366
c0d01098:	766c5f73 	.word	0x766c5f73
c0d0109c:	255b316c 	.word	0x255b316c
c0d010a0:	203a5d64 	.word	0x203a5d64
c0d010a4:	000a6425 	.word	0x000a6425
c0d010a8:	73726170 	.word	0x73726170
c0d010ac:	49422065 	.word	0x49422065
c0d010b0:	4f5f5f4f 	.word	0x4f5f5f4f
c0d010b4:	45534646 	.word	0x45534646
c0d010b8:	52415f54 	.word	0x52415f54
c0d010bc:	5f594152 	.word	0x5f594152
c0d010c0:	4544524f 	.word	0x4544524f
c0d010c4:	4c205352 	.word	0x4c205352
c0d010c8:	0a545341 	.word	0x0a545341
c0d010cc:	52415000 	.word	0x52415000
c0d010d0:	474e4953 	.word	0x474e4953
c0d010d4:	44524f20 	.word	0x44524f20
c0d010d8:	000a5245 	.word	0x000a5245
c0d010dc:	73726170 	.word	0x73726170
c0d010e0:	524f2065 	.word	0x524f2065
c0d010e4:	5f524544 	.word	0x5f524544
c0d010e8:	45504f5f 	.word	0x45504f5f
c0d010ec:	4f544152 	.word	0x4f544152
c0d010f0:	4e000a52 	.word	0x4e000a52
c0d010f4:	63205745 	.word	0x63205745
c0d010f8:	65727275 	.word	0x65727275
c0d010fc:	745f746e 	.word	0x745f746e
c0d01100:	656c7075 	.word	0x656c7075
c0d01104:	66666f5f 	.word	0x66666f5f
c0d01108:	3a746573 	.word	0x3a746573
c0d0110c:	0a642520 	.word	0x0a642520
c0d01110:	72617000 	.word	0x72617000
c0d01114:	4f206573 	.word	0x4f206573
c0d01118:	52454452 	.word	0x52454452
c0d0111c:	4f545f5f 	.word	0x4f545f5f
c0d01120:	5f4e454b 	.word	0x5f4e454b
c0d01124:	52444441 	.word	0x52444441
c0d01128:	0a535345 	.word	0x0a535345
c0d0112c:	72617000 	.word	0x72617000
c0d01130:	4f206573 	.word	0x4f206573
c0d01134:	52454452 	.word	0x52454452
c0d01138:	464f5f5f 	.word	0x464f5f5f
c0d0113c:	54455346 	.word	0x54455346
c0d01140:	4c41435f 	.word	0x4c41435f
c0d01144:	5441444c 	.word	0x5441444c
c0d01148:	70000a41 	.word	0x70000a41
c0d0114c:	65737261 	.word	0x65737261
c0d01150:	44524f20 	.word	0x44524f20
c0d01154:	5f5f5245 	.word	0x5f5f5245
c0d01158:	5f4e454c 	.word	0x5f4e454c
c0d0115c:	4c4c4143 	.word	0x4c4c4143
c0d01160:	41544144 	.word	0x41544144
c0d01164:	6170000a 	.word	0x6170000a
c0d01168:	20657372 	.word	0x20657372
c0d0116c:	4544524f 	.word	0x4544524f
c0d01170:	435f5f52 	.word	0x435f5f52
c0d01174:	444c4c41 	.word	0x444c4c41
c0d01178:	0a415441 	.word	0x0a415441
c0d0117c:	00          	.byte	0x00
c0d0117d:	68          	.byte	0x68
c0d0117e:	6e61      	.short	0x6e61
c0d01180:	5f656c64 	.word	0x5f656c64
c0d01184:	766f7270 	.word	0x766f7270
c0d01188:	5f656469 	.word	0x5f656469
c0d0118c:	656b6f74 	.word	0x656b6f74
c0d01190:	7469206e 	.word	0x7469206e
c0d01194:	0a316d65 	.word	0x0a316d65
c0d01198:	6e616800 	.word	0x6e616800
c0d0119c:	5f656c64 	.word	0x5f656c64
c0d011a0:	766f7270 	.word	0x766f7270
c0d011a4:	5f656469 	.word	0x5f656469
c0d011a8:	656b6f74 	.word	0x656b6f74
c0d011ac:	6f6e206e 	.word	0x6f6e206e
c0d011b0:	65746920 	.word	0x65746920
c0d011b4:	000a316d 	.word	0x000a316d
c0d011b8:	7473654e 	.word	0x7473654e
c0d011bc:	46206465 	.word	0x46206465
c0d011c0:	6e616e69 	.word	0x6e616e69
c0d011c4:	63006563 	.word	0x63006563
c0d011c8:	65746e6f 	.word	0x65746e6f
c0d011cc:	3e2d7478 	.word	0x3e2d7478
c0d011d0:	6c6f6f62 	.word	0x6c6f6f62
c0d011d4:	736e6165 	.word	0x736e6165
c0d011d8:	49202620 	.word	0x49202620
c0d011dc:	4f435f53 	.word	0x4f435f53
c0d011e0:	203a5950 	.word	0x203a5950
c0d011e4:	000a6425 	.word	0x000a6425
c0d011e8:	79706f43 	.word	0x79706f43
c0d011ec:	65724300 	.word	0x65724300
c0d011f0:	00657461 	.word	0x00657461
c0d011f4:	434f5250 	.word	0x434f5250
c0d011f8:	5f535345 	.word	0x5f535345
c0d011fc:	55504e49 	.word	0x55504e49
c0d01200:	524f5f54 	.word	0x524f5f54
c0d01204:	53524544 	.word	0x53524544
c0d01208:	4f525000 	.word	0x4f525000
c0d0120c:	53534543 	.word	0x53534543
c0d01210:	54554f5f 	.word	0x54554f5f
c0d01214:	5f545550 	.word	0x5f545550
c0d01218:	4544524f 	.word	0x4544524f
c0d0121c:	53005352 	.word	0x53005352
c0d01220:	206c6c65 	.word	0x206c6c65
c0d01224:	74726f50 	.word	0x74726f50
c0d01228:	696c6f66 	.word	0x696c6f66
c0d0122c:	6c43006f 	.word	0x6c43006f
c0d01230:	206d6961 	.word	0x206d6961
c0d01234:	61796f52 	.word	0x61796f52
c0d01238:	6569746c 	.word	0x6569746c
c0d0123c:	65530073 	.word	0x65530073
c0d01240:	5300646e 	.word	0x5300646e
c0d01244:	63656c65 	.word	0x63656c65
c0d01248:	20726f74 	.word	0x20726f74
c0d0124c:	65646e69 	.word	0x65646e69
c0d01250:	25203a78 	.word	0x25203a78
c0d01254:	6f6e2064 	.word	0x6f6e2064
c0d01258:	75732074 	.word	0x75732074
c0d0125c:	726f7070 	.word	0x726f7070
c0d01260:	0a646574 	.word	0x0a646574
c0d01264:	00          	.byte	0x00
c0d01265:	70          	.byte	0x70
c0d01266:	616c      	.short	0x616c
c0d01268:	6f686563 	.word	0x6f686563
c0d0126c:	7265646c 	.word	0x7265646c
c0d01270:	63655200 	.word	0x63655200
c0d01274:	65766965 	.word	0x65766965
c0d01278:	6e612064 	.word	0x6e612064
c0d0127c:	766e6920 	.word	0x766e6920
c0d01280:	64696c61 	.word	0x64696c61
c0d01284:	72637320 	.word	0x72637320
c0d01288:	496e6565 	.word	0x496e6565
c0d0128c:	7865646e 	.word	0x7865646e
c0d01290:	000a      	.short	0x000a
c0d01292:	6e55      	.short	0x6e55
c0d01294:	646e6168 	.word	0x646e6168
c0d01298:	2064656c 	.word	0x2064656c
c0d0129c:	7373656d 	.word	0x7373656d
c0d012a0:	20656761 	.word	0x20656761
c0d012a4:	000a6425 	.word	0x000a6425
c0d012a8:	65687445 	.word	0x65687445
c0d012ac:	6d756572 	.word	0x6d756572
	...

c0d012b1 <g_pcHex>:
c0d012b1:	33323130 37363534 62613938 66656463     0123456789abcdef

c0d012c1 <g_pcHex_cap>:
c0d012c1:	33323130 37363534 42413938 46454443     0123456789ABCDEF
c0d012d1:	                                         ...

c0d012d4 <NESTED_SELECTORS>:
c0d012d4:	a378534b 90e1aa69 51227094 bba9b10c     KSx.i....p"Q....
c0d012e4:	6d9634b7 23b872dd                       .4.m.r.#

c0d012ec <_etext>:
	...
