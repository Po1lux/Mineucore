
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 88 af 11 c0       	mov    $0xc011af88,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 90 58 00 00       	call   c01058f2 <memset>

    cons_init();                // init the console
c0100062:	e8 74 15 00 00       	call   c01015db <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 61 10 c0 	movl   $0xc0106100,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c 61 10 c0 	movl   $0xc010611c,(%esp)
c010007c:	e8 11 02 00 00       	call   c0100292 <cprintf>

    print_kerninfo();
c0100081:	e8 b2 08 00 00       	call   c0100938 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 89 00 00 00       	call   c0100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 57 32 00 00       	call   c01032e7 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 aa 16 00 00       	call   c010173f <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 03 18 00 00       	call   c010189d <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 ef 0c 00 00       	call   c0100d8e <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 ce 17 00 00       	call   c0101872 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 b4 0c 00 00       	call   c0100d7c <mon_backtrace>
}
c01000c8:	90                   	nop
c01000c9:	c9                   	leave  
c01000ca:	c3                   	ret    

c01000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000cb:	55                   	push   %ebp
c01000cc:	89 e5                	mov    %esp,%ebp
c01000ce:	53                   	push   %ebx
c01000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b4 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	83 c4 14             	add    $0x14,%esp
c01000f6:	5b                   	pop    %ebx
c01000f7:	5d                   	pop    %ebp
c01000f8:	c3                   	ret    

c01000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f9:	55                   	push   %ebp
c01000fa:	89 e5                	mov    %esp,%ebp
c01000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0100102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100106:	8b 45 08             	mov    0x8(%ebp),%eax
c0100109:	89 04 24             	mov    %eax,(%esp)
c010010c:	e8 ba ff ff ff       	call   c01000cb <grade_backtrace1>
}
c0100111:	90                   	nop
c0100112:	c9                   	leave  
c0100113:	c3                   	ret    

c0100114 <grade_backtrace>:

void
grade_backtrace(void) {
c0100114:	55                   	push   %ebp
c0100115:	89 e5                	mov    %esp,%ebp
c0100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011a:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100126:	ff 
c0100127:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100132:	e8 c2 ff ff ff       	call   c01000f9 <grade_backtrace0>
}
c0100137:	90                   	nop
c0100138:	c9                   	leave  
c0100139:	c3                   	ret    

c010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013a:	55                   	push   %ebp
c010013b:	89 e5                	mov    %esp,%ebp
c010013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100150:	83 e0 03             	and    $0x3,%eax
c0100153:	89 c2                	mov    %eax,%edx
c0100155:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010015a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100162:	c7 04 24 21 61 10 c0 	movl   $0xc0106121,(%esp)
c0100169:	e8 24 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 2f 61 10 c0 	movl   $0xc010612f,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 3d 61 10 c0 	movl   $0xc010613d,(%esp)
c01001a7:	e8 e6 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 4b 61 10 c0 	movl   $0xc010614b,(%esp)
c01001c6:	e8 c7 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 59 61 10 c0 	movl   $0xc0106159,(%esp)
c01001e5:	e8 a8 00 00 00       	call   c0100292 <cprintf>
    round ++;
c01001ea:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001ef:	40                   	inc    %eax
c01001f0:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001f5:	90                   	nop
c01001f6:	c9                   	leave  
c01001f7:	c3                   	ret    

c01001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001f8:	55                   	push   %ebp
c01001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001fb:	90                   	nop
c01001fc:	5d                   	pop    %ebp
c01001fd:	c3                   	ret    

c01001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001fe:	55                   	push   %ebp
c01001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100201:	90                   	nop
c0100202:	5d                   	pop    %ebp
c0100203:	c3                   	ret    

c0100204 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100204:	55                   	push   %ebp
c0100205:	89 e5                	mov    %esp,%ebp
c0100207:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020a:	e8 2b ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010020f:	c7 04 24 68 61 10 c0 	movl   $0xc0106168,(%esp)
c0100216:	e8 77 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021b:	e8 d8 ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100220:	e8 15 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100225:	c7 04 24 88 61 10 c0 	movl   $0xc0106188,(%esp)
c010022c:	e8 61 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_kernel();
c0100231:	e8 c8 ff ff ff       	call   c01001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100236:	e8 ff fe ff ff       	call   c010013a <lab1_print_cur_status>
}
c010023b:	90                   	nop
c010023c:	c9                   	leave  
c010023d:	c3                   	ret    

c010023e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010023e:	55                   	push   %ebp
c010023f:	89 e5                	mov    %esp,%ebp
c0100241:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100244:	8b 45 08             	mov    0x8(%ebp),%eax
c0100247:	89 04 24             	mov    %eax,(%esp)
c010024a:	e8 b9 13 00 00       	call   c0101608 <cons_putc>
    (*cnt) ++;
c010024f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100252:	8b 00                	mov    (%eax),%eax
c0100254:	8d 50 01             	lea    0x1(%eax),%edx
c0100257:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025a:	89 10                	mov    %edx,(%eax)
}
c010025c:	90                   	nop
c010025d:	c9                   	leave  
c010025e:	c3                   	ret    

c010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010025f:	55                   	push   %ebp
c0100260:	89 e5                	mov    %esp,%ebp
c0100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010026c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100273:	8b 45 08             	mov    0x8(%ebp),%eax
c0100276:	89 44 24 08          	mov    %eax,0x8(%esp)
c010027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010027d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100281:	c7 04 24 3e 02 10 c0 	movl   $0xc010023e,(%esp)
c0100288:	e8 b8 59 00 00       	call   c0105c45 <vprintfmt>
    return cnt;
c010028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100290:	c9                   	leave  
c0100291:	c3                   	ret    

c0100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100292:	55                   	push   %ebp
c0100293:	89 e5                	mov    %esp,%ebp
c0100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100298:	8d 45 0c             	lea    0xc(%ebp),%eax
c010029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002a8:	89 04 24             	mov    %eax,(%esp)
c01002ab:	e8 af ff ff ff       	call   c010025f <vcprintf>
c01002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002b6:	c9                   	leave  
c01002b7:	c3                   	ret    

c01002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002b8:	55                   	push   %ebp
c01002b9:	89 e5                	mov    %esp,%ebp
c01002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002be:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c1:	89 04 24             	mov    %eax,(%esp)
c01002c4:	e8 3f 13 00 00       	call   c0101608 <cons_putc>
}
c01002c9:	90                   	nop
c01002ca:	c9                   	leave  
c01002cb:	c3                   	ret    

c01002cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002cc:	55                   	push   %ebp
c01002cd:	89 e5                	mov    %esp,%ebp
c01002cf:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002d9:	eb 13                	jmp    c01002ee <cputs+0x22>
        cputch(c, &cnt);
c01002db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002df:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002e6:	89 04 24             	mov    %eax,(%esp)
c01002e9:	e8 50 ff ff ff       	call   c010023e <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01002f1:	8d 50 01             	lea    0x1(%eax),%edx
c01002f4:	89 55 08             	mov    %edx,0x8(%ebp)
c01002f7:	0f b6 00             	movzbl (%eax),%eax
c01002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002fd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100301:	75 d8                	jne    c01002db <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0100303:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100306:	89 44 24 04          	mov    %eax,0x4(%esp)
c010030a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100311:	e8 28 ff ff ff       	call   c010023e <cputch>
    return cnt;
c0100316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100319:	c9                   	leave  
c010031a:	c3                   	ret    

c010031b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010031b:	55                   	push   %ebp
c010031c:	89 e5                	mov    %esp,%ebp
c010031e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100321:	e8 1f 13 00 00       	call   c0101645 <cons_getc>
c0100326:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010032d:	74 f2                	je     c0100321 <getchar+0x6>
        /* do nothing */;
    return c;
c010032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100332:	c9                   	leave  
c0100333:	c3                   	ret    

c0100334 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100334:	55                   	push   %ebp
c0100335:	89 e5                	mov    %esp,%ebp
c0100337:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010033a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010033e:	74 13                	je     c0100353 <readline+0x1f>
        cprintf("%s", prompt);
c0100340:	8b 45 08             	mov    0x8(%ebp),%eax
c0100343:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100347:	c7 04 24 a7 61 10 c0 	movl   $0xc01061a7,(%esp)
c010034e:	e8 3f ff ff ff       	call   c0100292 <cprintf>
    }
    int i = 0, c;
c0100353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010035a:	e8 bc ff ff ff       	call   c010031b <getchar>
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100366:	79 07                	jns    c010036f <readline+0x3b>
            return NULL;
c0100368:	b8 00 00 00 00       	mov    $0x0,%eax
c010036d:	eb 78                	jmp    c01003e7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010036f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100373:	7e 28                	jle    c010039d <readline+0x69>
c0100375:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010037c:	7f 1f                	jg     c010039d <readline+0x69>
            cputchar(c);
c010037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100381:	89 04 24             	mov    %eax,(%esp)
c0100384:	e8 2f ff ff ff       	call   c01002b8 <cputchar>
            buf[i ++] = c;
c0100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010038c:	8d 50 01             	lea    0x1(%eax),%edx
c010038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100395:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c010039b:	eb 45                	jmp    c01003e2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c010039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003a1:	75 16                	jne    c01003b9 <readline+0x85>
c01003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003a7:	7e 10                	jle    c01003b9 <readline+0x85>
            cputchar(c);
c01003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ac:	89 04 24             	mov    %eax,(%esp)
c01003af:	e8 04 ff ff ff       	call   c01002b8 <cputchar>
            i --;
c01003b4:	ff 4d f4             	decl   -0xc(%ebp)
c01003b7:	eb 29                	jmp    c01003e2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003bd:	74 06                	je     c01003c5 <readline+0x91>
c01003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003c3:	75 95                	jne    c010035a <readline+0x26>
            cputchar(c);
c01003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c8:	89 04 24             	mov    %eax,(%esp)
c01003cb:	e8 e8 fe ff ff       	call   c01002b8 <cputchar>
            buf[i] = '\0';
c01003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d3:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003db:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01003e0:	eb 05                	jmp    c01003e7 <readline+0xb3>
        }
    }
c01003e2:	e9 73 ff ff ff       	jmp    c010035a <readline+0x26>
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003ef:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c01003f4:	85 c0                	test   %eax,%eax
c01003f6:	75 5b                	jne    c0100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c01003f8:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c01003ff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100402:	8d 45 14             	lea    0x14(%ebp),%eax
c0100405:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100408:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010040f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100412:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100416:	c7 04 24 aa 61 10 c0 	movl   $0xc01061aa,(%esp)
c010041d:	e8 70 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100429:	8b 45 10             	mov    0x10(%ebp),%eax
c010042c:	89 04 24             	mov    %eax,(%esp)
c010042f:	e8 2b fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100434:	c7 04 24 c6 61 10 c0 	movl   $0xc01061c6,(%esp)
c010043b:	e8 52 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100440:	c7 04 24 c8 61 10 c0 	movl   $0xc01061c8,(%esp)
c0100447:	e8 46 fe ff ff       	call   c0100292 <cprintf>
    print_stackframe();
c010044c:	e8 32 06 00 00       	call   c0100a83 <print_stackframe>
c0100451:	eb 01                	jmp    c0100454 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c0100453:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100454:	e8 20 14 00 00       	call   c0101879 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100460:	e8 4a 08 00 00       	call   c0100caf <kmonitor>
    }
c0100465:	eb f2                	jmp    c0100459 <__panic+0x70>

c0100467 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100467:	55                   	push   %ebp
c0100468:	89 e5                	mov    %esp,%ebp
c010046a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010046d:	8d 45 14             	lea    0x14(%ebp),%eax
c0100470:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100473:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100476:	89 44 24 08          	mov    %eax,0x8(%esp)
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100481:	c7 04 24 da 61 10 c0 	movl   $0xc01061da,(%esp)
c0100488:	e8 05 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100494:	8b 45 10             	mov    0x10(%ebp),%eax
c0100497:	89 04 24             	mov    %eax,(%esp)
c010049a:	e8 c0 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049f:	c7 04 24 c6 61 10 c0 	movl   $0xc01061c6,(%esp)
c01004a6:	e8 e7 fd ff ff       	call   c0100292 <cprintf>
    va_end(ap);
}
c01004ab:	90                   	nop
c01004ac:	c9                   	leave  
c01004ad:	c3                   	ret    

c01004ae <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004ae:	55                   	push   %ebp
c01004af:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004b1:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c01004b6:	5d                   	pop    %ebp
c01004b7:	c3                   	ret    

c01004b8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004b8:	55                   	push   %ebp
c01004b9:	89 e5                	mov    %esp,%ebp
c01004bb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c1:	8b 00                	mov    (%eax),%eax
c01004c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c9:	8b 00                	mov    (%eax),%eax
c01004cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004d5:	e9 ca 00 00 00       	jmp    c01005a4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004da:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004e0:	01 d0                	add    %edx,%eax
c01004e2:	89 c2                	mov    %eax,%edx
c01004e4:	c1 ea 1f             	shr    $0x1f,%edx
c01004e7:	01 d0                	add    %edx,%eax
c01004e9:	d1 f8                	sar    %eax
c01004eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f4:	eb 03                	jmp    c01004f9 <stab_binsearch+0x41>
            m --;
c01004f6:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004ff:	7c 1f                	jl     c0100520 <stab_binsearch+0x68>
c0100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100504:	89 d0                	mov    %edx,%eax
c0100506:	01 c0                	add    %eax,%eax
c0100508:	01 d0                	add    %edx,%eax
c010050a:	c1 e0 02             	shl    $0x2,%eax
c010050d:	89 c2                	mov    %eax,%edx
c010050f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100512:	01 d0                	add    %edx,%eax
c0100514:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100518:	0f b6 c0             	movzbl %al,%eax
c010051b:	3b 45 14             	cmp    0x14(%ebp),%eax
c010051e:	75 d6                	jne    c01004f6 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100520:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100523:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100526:	7d 09                	jge    c0100531 <stab_binsearch+0x79>
            l = true_m + 1;
c0100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010052b:	40                   	inc    %eax
c010052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010052f:	eb 73                	jmp    c01005a4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010053b:	89 d0                	mov    %edx,%eax
c010053d:	01 c0                	add    %eax,%eax
c010053f:	01 d0                	add    %edx,%eax
c0100541:	c1 e0 02             	shl    $0x2,%eax
c0100544:	89 c2                	mov    %eax,%edx
c0100546:	8b 45 08             	mov    0x8(%ebp),%eax
c0100549:	01 d0                	add    %edx,%eax
c010054b:	8b 40 08             	mov    0x8(%eax),%eax
c010054e:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100551:	73 11                	jae    c0100564 <stab_binsearch+0xac>
            *region_left = m;
c0100553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100559:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010055b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010055e:	40                   	inc    %eax
c010055f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100562:	eb 40                	jmp    c01005a4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100564:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100567:	89 d0                	mov    %edx,%eax
c0100569:	01 c0                	add    %eax,%eax
c010056b:	01 d0                	add    %edx,%eax
c010056d:	c1 e0 02             	shl    $0x2,%eax
c0100570:	89 c2                	mov    %eax,%edx
c0100572:	8b 45 08             	mov    0x8(%ebp),%eax
c0100575:	01 d0                	add    %edx,%eax
c0100577:	8b 40 08             	mov    0x8(%eax),%eax
c010057a:	3b 45 18             	cmp    0x18(%ebp),%eax
c010057d:	76 14                	jbe    c0100593 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100582:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100585:	8b 45 10             	mov    0x10(%ebp),%eax
c0100588:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010058d:	48                   	dec    %eax
c010058e:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100591:	eb 11                	jmp    c01005a4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0100593:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100596:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100599:	89 10                	mov    %edx,(%eax)
            l = m;
c010059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059e:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005a1:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005aa:	0f 8e 2a ff ff ff    	jle    c01004da <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005b4:	75 0f                	jne    c01005c5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b9:	8b 00                	mov    (%eax),%eax
c01005bb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005be:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005c3:	eb 3e                	jmp    c0100603 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c8:	8b 00                	mov    (%eax),%eax
c01005ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005cd:	eb 03                	jmp    c01005d2 <stab_binsearch+0x11a>
c01005cf:	ff 4d fc             	decl   -0x4(%ebp)
c01005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d5:	8b 00                	mov    (%eax),%eax
c01005d7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005da:	7d 1f                	jge    c01005fb <stab_binsearch+0x143>
c01005dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005df:	89 d0                	mov    %edx,%eax
c01005e1:	01 c0                	add    %eax,%eax
c01005e3:	01 d0                	add    %edx,%eax
c01005e5:	c1 e0 02             	shl    $0x2,%eax
c01005e8:	89 c2                	mov    %eax,%edx
c01005ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ed:	01 d0                	add    %edx,%eax
c01005ef:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005f3:	0f b6 c0             	movzbl %al,%eax
c01005f6:	3b 45 14             	cmp    0x14(%ebp),%eax
c01005f9:	75 d4                	jne    c01005cf <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
c01005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100601:	89 10                	mov    %edx,(%eax)
    }
}
c0100603:	90                   	nop
c0100604:	c9                   	leave  
c0100605:	c3                   	ret    

c0100606 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100606:	55                   	push   %ebp
c0100607:	89 e5                	mov    %esp,%ebp
c0100609:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010060c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060f:	c7 00 f8 61 10 c0    	movl   $0xc01061f8,(%eax)
    info->eip_line = 0;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100622:	c7 40 08 f8 61 10 c0 	movl   $0xc01061f8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100629:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100633:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100636:	8b 55 08             	mov    0x8(%ebp),%edx
c0100639:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010063c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100646:	c7 45 f4 20 74 10 c0 	movl   $0xc0107420,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064d:	c7 45 f0 34 23 11 c0 	movl   $0xc0112334,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100654:	c7 45 ec 35 23 11 c0 	movl   $0xc0112335,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010065b:	c7 45 e8 c9 4d 11 c0 	movl   $0xc0114dc9,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100662:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100665:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100668:	76 0b                	jbe    c0100675 <debuginfo_eip+0x6f>
c010066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010066d:	48                   	dec    %eax
c010066e:	0f b6 00             	movzbl (%eax),%eax
c0100671:	84 c0                	test   %al,%al
c0100673:	74 0a                	je     c010067f <debuginfo_eip+0x79>
        return -1;
c0100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010067a:	e9 b7 02 00 00       	jmp    c0100936 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068c:	29 c2                	sub    %eax,%edx
c010068e:	89 d0                	mov    %edx,%eax
c0100690:	c1 f8 02             	sar    $0x2,%eax
c0100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100699:	48                   	dec    %eax
c010069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c010069d:	8b 45 08             	mov    0x8(%ebp),%eax
c01006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006a4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006ab:	00 
c01006ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006af:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006bd:	89 04 24             	mov    %eax,(%esp)
c01006c0:	e8 f3 fd ff ff       	call   c01004b8 <stab_binsearch>
    if (lfile == 0)
c01006c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006c8:	85 c0                	test   %eax,%eax
c01006ca:	75 0a                	jne    c01006d6 <debuginfo_eip+0xd0>
        return -1;
c01006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d1:	e9 60 02 00 00       	jmp    c0100936 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006e9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006f0:	00 
c01006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100702:	89 04 24             	mov    %eax,(%esp)
c0100705:	e8 ae fd ff ff       	call   c01004b8 <stab_binsearch>

    if (lfun <= rfun) {
c010070a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100710:	39 c2                	cmp    %eax,%edx
c0100712:	7f 7c                	jg     c0100790 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100717:	89 c2                	mov    %eax,%edx
c0100719:	89 d0                	mov    %edx,%eax
c010071b:	01 c0                	add    %eax,%eax
c010071d:	01 d0                	add    %edx,%eax
c010071f:	c1 e0 02             	shl    $0x2,%eax
c0100722:	89 c2                	mov    %eax,%edx
c0100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100727:	01 d0                	add    %edx,%eax
c0100729:	8b 00                	mov    (%eax),%eax
c010072b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010072e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100731:	29 d1                	sub    %edx,%ecx
c0100733:	89 ca                	mov    %ecx,%edx
c0100735:	39 d0                	cmp    %edx,%eax
c0100737:	73 22                	jae    c010075b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100739:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010073c:	89 c2                	mov    %eax,%edx
c010073e:	89 d0                	mov    %edx,%eax
c0100740:	01 c0                	add    %eax,%eax
c0100742:	01 d0                	add    %edx,%eax
c0100744:	c1 e0 02             	shl    $0x2,%eax
c0100747:	89 c2                	mov    %eax,%edx
c0100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074c:	01 d0                	add    %edx,%eax
c010074e:	8b 10                	mov    (%eax),%edx
c0100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100753:	01 c2                	add    %eax,%edx
c0100755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100758:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010075e:	89 c2                	mov    %eax,%edx
c0100760:	89 d0                	mov    %edx,%eax
c0100762:	01 c0                	add    %eax,%eax
c0100764:	01 d0                	add    %edx,%eax
c0100766:	c1 e0 02             	shl    $0x2,%eax
c0100769:	89 c2                	mov    %eax,%edx
c010076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076e:	01 d0                	add    %edx,%eax
c0100770:	8b 50 08             	mov    0x8(%eax),%edx
c0100773:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100776:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100779:	8b 45 0c             	mov    0xc(%ebp),%eax
c010077c:	8b 40 10             	mov    0x10(%eax),%eax
c010077f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100782:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100788:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010078e:	eb 15                	jmp    c01007a5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100790:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100793:	8b 55 08             	mov    0x8(%ebp),%edx
c0100796:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c010079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a8:	8b 40 08             	mov    0x8(%eax),%eax
c01007ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007b2:	00 
c01007b3:	89 04 24             	mov    %eax,(%esp)
c01007b6:	e8 b3 4f 00 00       	call   c010576e <strfind>
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c0:	8b 40 08             	mov    0x8(%eax),%eax
c01007c3:	29 c2                	sub    %eax,%edx
c01007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007d2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007d9:	00 
c01007da:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007eb:	89 04 24             	mov    %eax,(%esp)
c01007ee:	e8 c5 fc ff ff       	call   c01004b8 <stab_binsearch>
    if (lline <= rline) {
c01007f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007f9:	39 c2                	cmp    %eax,%edx
c01007fb:	7f 23                	jg     c0100820 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c01007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100800:	89 c2                	mov    %eax,%edx
c0100802:	89 d0                	mov    %edx,%eax
c0100804:	01 c0                	add    %eax,%eax
c0100806:	01 d0                	add    %edx,%eax
c0100808:	c1 e0 02             	shl    $0x2,%eax
c010080b:	89 c2                	mov    %eax,%edx
c010080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100810:	01 d0                	add    %edx,%eax
c0100812:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100816:	89 c2                	mov    %eax,%edx
c0100818:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010081e:	eb 11                	jmp    c0100831 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100825:	e9 0c 01 00 00       	jmp    c0100936 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010082a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010082d:	48                   	dec    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100837:	39 c2                	cmp    %eax,%edx
c0100839:	7c 56                	jl     c0100891 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c010083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083e:	89 c2                	mov    %eax,%edx
c0100840:	89 d0                	mov    %edx,%eax
c0100842:	01 c0                	add    %eax,%eax
c0100844:	01 d0                	add    %edx,%eax
c0100846:	c1 e0 02             	shl    $0x2,%eax
c0100849:	89 c2                	mov    %eax,%edx
c010084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010084e:	01 d0                	add    %edx,%eax
c0100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100854:	3c 84                	cmp    $0x84,%al
c0100856:	74 39                	je     c0100891 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c 64                	cmp    $0x64,%al
c0100873:	75 b5                	jne    c010082a <debuginfo_eip+0x224>
c0100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100878:	89 c2                	mov    %eax,%edx
c010087a:	89 d0                	mov    %edx,%eax
c010087c:	01 c0                	add    %eax,%eax
c010087e:	01 d0                	add    %edx,%eax
c0100880:	c1 e0 02             	shl    $0x2,%eax
c0100883:	89 c2                	mov    %eax,%edx
c0100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100888:	01 d0                	add    %edx,%eax
c010088a:	8b 40 08             	mov    0x8(%eax),%eax
c010088d:	85 c0                	test   %eax,%eax
c010088f:	74 99                	je     c010082a <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100897:	39 c2                	cmp    %eax,%edx
c0100899:	7c 46                	jl     c01008e1 <debuginfo_eip+0x2db>
c010089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010089e:	89 c2                	mov    %eax,%edx
c01008a0:	89 d0                	mov    %edx,%eax
c01008a2:	01 c0                	add    %eax,%eax
c01008a4:	01 d0                	add    %edx,%eax
c01008a6:	c1 e0 02             	shl    $0x2,%eax
c01008a9:	89 c2                	mov    %eax,%edx
c01008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	8b 00                	mov    (%eax),%eax
c01008b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008b8:	29 d1                	sub    %edx,%ecx
c01008ba:	89 ca                	mov    %ecx,%edx
c01008bc:	39 d0                	cmp    %edx,%eax
c01008be:	73 21                	jae    c01008e1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008c3:	89 c2                	mov    %eax,%edx
c01008c5:	89 d0                	mov    %edx,%eax
c01008c7:	01 c0                	add    %eax,%eax
c01008c9:	01 d0                	add    %edx,%eax
c01008cb:	c1 e0 02             	shl    $0x2,%eax
c01008ce:	89 c2                	mov    %eax,%edx
c01008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d3:	01 d0                	add    %edx,%eax
c01008d5:	8b 10                	mov    (%eax),%edx
c01008d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008da:	01 c2                	add    %eax,%edx
c01008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008df:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008e7:	39 c2                	cmp    %eax,%edx
c01008e9:	7d 46                	jge    c0100931 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008ee:	40                   	inc    %eax
c01008ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008f2:	eb 16                	jmp    c010090a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008f7:	8b 40 14             	mov    0x14(%eax),%eax
c01008fa:	8d 50 01             	lea    0x1(%eax),%edx
c01008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100900:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100906:	40                   	inc    %eax
c0100907:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010090a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010090d:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100910:	39 c2                	cmp    %eax,%edx
c0100912:	7d 1d                	jge    c0100931 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100917:	89 c2                	mov    %eax,%edx
c0100919:	89 d0                	mov    %edx,%eax
c010091b:	01 c0                	add    %eax,%eax
c010091d:	01 d0                	add    %edx,%eax
c010091f:	c1 e0 02             	shl    $0x2,%eax
c0100922:	89 c2                	mov    %eax,%edx
c0100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100927:	01 d0                	add    %edx,%eax
c0100929:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010092d:	3c a0                	cmp    $0xa0,%al
c010092f:	74 c3                	je     c01008f4 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100931:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100936:	c9                   	leave  
c0100937:	c3                   	ret    

c0100938 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100938:	55                   	push   %ebp
c0100939:	89 e5                	mov    %esp,%ebp
c010093b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010093e:	c7 04 24 02 62 10 c0 	movl   $0xc0106202,(%esp)
c0100945:	e8 48 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100951:	c0 
c0100952:	c7 04 24 1b 62 10 c0 	movl   $0xc010621b,(%esp)
c0100959:	e8 34 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010095e:	c7 44 24 04 ec 60 10 	movl   $0xc01060ec,0x4(%esp)
c0100965:	c0 
c0100966:	c7 04 24 33 62 10 c0 	movl   $0xc0106233,(%esp)
c010096d:	e8 20 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100972:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 4b 62 10 c0 	movl   $0xc010624b,(%esp)
c0100981:	e8 0c f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100986:	c7 44 24 04 88 af 11 	movl   $0xc011af88,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 63 62 10 c0 	movl   $0xc0106263,(%esp)
c0100995:	e8 f8 f8 ff ff       	call   c0100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010099a:	b8 88 af 11 c0       	mov    $0xc011af88,%eax
c010099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009a5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009aa:	29 c2                	sub    %eax,%edx
c01009ac:	89 d0                	mov    %edx,%eax
c01009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b4:	85 c0                	test   %eax,%eax
c01009b6:	0f 48 c2             	cmovs  %edx,%eax
c01009b9:	c1 f8 0a             	sar    $0xa,%eax
c01009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009c0:	c7 04 24 7c 62 10 c0 	movl   $0xc010627c,(%esp)
c01009c7:	e8 c6 f8 ff ff       	call   c0100292 <cprintf>
}
c01009cc:	90                   	nop
c01009cd:	c9                   	leave  
c01009ce:	c3                   	ret    

c01009cf <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009cf:	55                   	push   %ebp
c01009d0:	89 e5                	mov    %esp,%ebp
c01009d2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009df:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e2:	89 04 24             	mov    %eax,(%esp)
c01009e5:	e8 1c fc ff ff       	call   c0100606 <debuginfo_eip>
c01009ea:	85 c0                	test   %eax,%eax
c01009ec:	74 15                	je     c0100a03 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f5:	c7 04 24 a6 62 10 c0 	movl   $0xc01062a6,(%esp)
c01009fc:	e8 91 f8 ff ff       	call   c0100292 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a01:	eb 6c                	jmp    c0100a6f <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a0a:	eb 1b                	jmp    c0100a27 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a12:	01 d0                	add    %edx,%eax
c0100a14:	0f b6 00             	movzbl (%eax),%eax
c0100a17:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a20:	01 ca                	add    %ecx,%edx
c0100a22:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a24:	ff 45 f4             	incl   -0xc(%ebp)
c0100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a2a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a2d:	7f dd                	jg     c0100a0c <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a2f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a38:	01 d0                	add    %edx,%eax
c0100a3a:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a40:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a43:	89 d1                	mov    %edx,%ecx
c0100a45:	29 c1                	sub    %eax,%ecx
c0100a47:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a51:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a63:	c7 04 24 c2 62 10 c0 	movl   $0xc01062c2,(%esp)
c0100a6a:	e8 23 f8 ff ff       	call   c0100292 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a6f:	90                   	nop
c0100a70:	c9                   	leave  
c0100a71:	c3                   	ret    

c0100a72 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a72:	55                   	push   %ebp
c0100a73:	89 e5                	mov    %esp,%ebp
c0100a75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a78:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a81:	c9                   	leave  
c0100a82:	c3                   	ret    

c0100a83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a83:	55                   	push   %ebp
c0100a84:	89 e5                	mov    %esp,%ebp
c0100a86:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a89:	89 e8                	mov    %ebp,%eax
c0100a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a94:	e8 d9 ff ff ff       	call   c0100a72 <read_eip>
c0100a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aa3:	e9 84 00 00 00       	jmp    c0100b2c <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aab:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab6:	c7 04 24 d4 62 10 c0 	movl   $0xc01062d4,(%esp)
c0100abd:	e8 d0 f7 ff ff       	call   c0100292 <cprintf>

        //C语言的函数调用约定为参数从右到左压栈，所以EBP高8字节保存的是第一个参数
        uint32_t *args = (uint32_t *)ebp + 2;
c0100ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac5:	83 c0 08             	add    $0x8,%eax
c0100ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100acb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ad2:	eb 24                	jmp    c0100af8 <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
c0100ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ad7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ae1:	01 d0                	add    %edx,%eax
c0100ae3:	8b 00                	mov    (%eax),%eax
c0100ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae9:	c7 04 24 f0 62 10 c0 	movl   $0xc01062f0,(%esp)
c0100af0:	e8 9d f7 ff ff       	call   c0100292 <cprintf>
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);

        //C语言的函数调用约定为参数从右到左压栈，所以EBP高8字节保存的是第一个参数
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100af5:	ff 45 e8             	incl   -0x18(%ebp)
c0100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100afc:	7e d6                	jle    c0100ad4 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100afe:	c7 04 24 f8 62 10 c0 	movl   $0xc01062f8,(%esp)
c0100b05:	e8 88 f7 ff ff       	call   c0100292 <cprintf>
        print_debuginfo(eip - 1);
c0100b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b0d:	48                   	dec    %eax
c0100b0e:	89 04 24             	mov    %eax,(%esp)
c0100b11:	e8 b9 fe ff ff       	call   c01009cf <print_debuginfo>
        //当前帧指针EBP指向的栈地址保存的是上一个函数栈的我帧指针
        //当前帧指针EBP指向的栈地址的高4字节，保存的返回地址
        eip = ((uint32_t *)ebp)[1];
c0100b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b19:	83 c0 04             	add    $0x4,%eax
c0100b1c:	8b 00                	mov    (%eax),%eax
c0100b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b24:	8b 00                	mov    (%eax),%eax
c0100b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100b29:	ff 45 ec             	incl   -0x14(%ebp)
c0100b2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b30:	74 0a                	je     c0100b3c <print_stackframe+0xb9>
c0100b32:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b36:	0f 8e 6c ff ff ff    	jle    c0100aa8 <print_stackframe+0x25>
        //当前帧指针EBP指向的栈地址保存的是上一个函数栈的我帧指针
        //当前帧指针EBP指向的栈地址的高4字节，保存的返回地址
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100b3c:	90                   	nop
c0100b3d:	c9                   	leave  
c0100b3e:	c3                   	ret    

c0100b3f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b3f:	55                   	push   %ebp
c0100b40:	89 e5                	mov    %esp,%ebp
c0100b42:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4c:	eb 0c                	jmp    c0100b5a <parse+0x1b>
            *buf ++ = '\0';
c0100b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b51:	8d 50 01             	lea    0x1(%eax),%edx
c0100b54:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b57:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5d:	0f b6 00             	movzbl (%eax),%eax
c0100b60:	84 c0                	test   %al,%al
c0100b62:	74 1d                	je     c0100b81 <parse+0x42>
c0100b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b67:	0f b6 00             	movzbl (%eax),%eax
c0100b6a:	0f be c0             	movsbl %al,%eax
c0100b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b71:	c7 04 24 7c 63 10 c0 	movl   $0xc010637c,(%esp)
c0100b78:	e8 bf 4b 00 00       	call   c010573c <strchr>
c0100b7d:	85 c0                	test   %eax,%eax
c0100b7f:	75 cd                	jne    c0100b4e <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b84:	0f b6 00             	movzbl (%eax),%eax
c0100b87:	84 c0                	test   %al,%al
c0100b89:	74 69                	je     c0100bf4 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b8b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b8f:	75 14                	jne    c0100ba5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b91:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b98:	00 
c0100b99:	c7 04 24 81 63 10 c0 	movl   $0xc0106381,(%esp)
c0100ba0:	e8 ed f6 ff ff       	call   c0100292 <cprintf>
        }
        argv[argc ++] = buf;
c0100ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ba8:	8d 50 01             	lea    0x1(%eax),%edx
c0100bab:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bb8:	01 c2                	add    %eax,%edx
c0100bba:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bbd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bbf:	eb 03                	jmp    c0100bc4 <parse+0x85>
            buf ++;
c0100bc1:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc7:	0f b6 00             	movzbl (%eax),%eax
c0100bca:	84 c0                	test   %al,%al
c0100bcc:	0f 84 7a ff ff ff    	je     c0100b4c <parse+0xd>
c0100bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd5:	0f b6 00             	movzbl (%eax),%eax
c0100bd8:	0f be c0             	movsbl %al,%eax
c0100bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdf:	c7 04 24 7c 63 10 c0 	movl   $0xc010637c,(%esp)
c0100be6:	e8 51 4b 00 00       	call   c010573c <strchr>
c0100beb:	85 c0                	test   %eax,%eax
c0100bed:	74 d2                	je     c0100bc1 <parse+0x82>
            buf ++;
        }
    }
c0100bef:	e9 58 ff ff ff       	jmp    c0100b4c <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100bf4:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bf8:	c9                   	leave  
c0100bf9:	c3                   	ret    

c0100bfa <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bfa:	55                   	push   %ebp
c0100bfb:	89 e5                	mov    %esp,%ebp
c0100bfd:	53                   	push   %ebx
c0100bfe:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c01:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c08:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c0b:	89 04 24             	mov    %eax,(%esp)
c0100c0e:	e8 2c ff ff ff       	call   c0100b3f <parse>
c0100c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c1a:	75 0a                	jne    c0100c26 <runcmd+0x2c>
        return 0;
c0100c1c:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c21:	e9 83 00 00 00       	jmp    c0100ca9 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c2d:	eb 5a                	jmp    c0100c89 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c2f:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c35:	89 d0                	mov    %edx,%eax
c0100c37:	01 c0                	add    %eax,%eax
c0100c39:	01 d0                	add    %edx,%eax
c0100c3b:	c1 e0 02             	shl    $0x2,%eax
c0100c3e:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c43:	8b 00                	mov    (%eax),%eax
c0100c45:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c49:	89 04 24             	mov    %eax,(%esp)
c0100c4c:	e8 4e 4a 00 00       	call   c010569f <strcmp>
c0100c51:	85 c0                	test   %eax,%eax
c0100c53:	75 31                	jne    c0100c86 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c58:	89 d0                	mov    %edx,%eax
c0100c5a:	01 c0                	add    %eax,%eax
c0100c5c:	01 d0                	add    %edx,%eax
c0100c5e:	c1 e0 02             	shl    $0x2,%eax
c0100c61:	05 08 70 11 c0       	add    $0xc0117008,%eax
c0100c66:	8b 10                	mov    (%eax),%edx
c0100c68:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c6b:	83 c0 04             	add    $0x4,%eax
c0100c6e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c71:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c7f:	89 1c 24             	mov    %ebx,(%esp)
c0100c82:	ff d2                	call   *%edx
c0100c84:	eb 23                	jmp    c0100ca9 <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c86:	ff 45 f4             	incl   -0xc(%ebp)
c0100c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c8c:	83 f8 02             	cmp    $0x2,%eax
c0100c8f:	76 9e                	jbe    c0100c2f <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c91:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c94:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c98:	c7 04 24 9f 63 10 c0 	movl   $0xc010639f,(%esp)
c0100c9f:	e8 ee f5 ff ff       	call   c0100292 <cprintf>
    return 0;
c0100ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ca9:	83 c4 64             	add    $0x64,%esp
c0100cac:	5b                   	pop    %ebx
c0100cad:	5d                   	pop    %ebp
c0100cae:	c3                   	ret    

c0100caf <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100caf:	55                   	push   %ebp
c0100cb0:	89 e5                	mov    %esp,%ebp
c0100cb2:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cb5:	c7 04 24 b8 63 10 c0 	movl   $0xc01063b8,(%esp)
c0100cbc:	e8 d1 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cc1:	c7 04 24 e0 63 10 c0 	movl   $0xc01063e0,(%esp)
c0100cc8:	e8 c5 f5 ff ff       	call   c0100292 <cprintf>

    if (tf != NULL) {
c0100ccd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cd1:	74 0b                	je     c0100cde <kmonitor+0x2f>
        print_trapframe(tf);
c0100cd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd6:	89 04 24             	mov    %eax,(%esp)
c0100cd9:	e8 76 0d 00 00       	call   c0101a54 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cde:	c7 04 24 05 64 10 c0 	movl   $0xc0106405,(%esp)
c0100ce5:	e8 4a f6 ff ff       	call   c0100334 <readline>
c0100cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ced:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100cf1:	74 eb                	je     c0100cde <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100cf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cfd:	89 04 24             	mov    %eax,(%esp)
c0100d00:	e8 f5 fe ff ff       	call   c0100bfa <runcmd>
c0100d05:	85 c0                	test   %eax,%eax
c0100d07:	78 02                	js     c0100d0b <kmonitor+0x5c>
                break;
            }
        }
    }
c0100d09:	eb d3                	jmp    c0100cde <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100d0b:	90                   	nop
            }
        }
    }
}
c0100d0c:	90                   	nop
c0100d0d:	c9                   	leave  
c0100d0e:	c3                   	ret    

c0100d0f <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d0f:	55                   	push   %ebp
c0100d10:	89 e5                	mov    %esp,%ebp
c0100d12:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d1c:	eb 3d                	jmp    c0100d5b <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d21:	89 d0                	mov    %edx,%eax
c0100d23:	01 c0                	add    %eax,%eax
c0100d25:	01 d0                	add    %edx,%eax
c0100d27:	c1 e0 02             	shl    $0x2,%eax
c0100d2a:	05 04 70 11 c0       	add    $0xc0117004,%eax
c0100d2f:	8b 08                	mov    (%eax),%ecx
c0100d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d34:	89 d0                	mov    %edx,%eax
c0100d36:	01 c0                	add    %eax,%eax
c0100d38:	01 d0                	add    %edx,%eax
c0100d3a:	c1 e0 02             	shl    $0x2,%eax
c0100d3d:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100d42:	8b 00                	mov    (%eax),%eax
c0100d44:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d4c:	c7 04 24 09 64 10 c0 	movl   $0xc0106409,(%esp)
c0100d53:	e8 3a f5 ff ff       	call   c0100292 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d58:	ff 45 f4             	incl   -0xc(%ebp)
c0100d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5e:	83 f8 02             	cmp    $0x2,%eax
c0100d61:	76 bb                	jbe    c0100d1e <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d68:	c9                   	leave  
c0100d69:	c3                   	ret    

c0100d6a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d6a:	55                   	push   %ebp
c0100d6b:	89 e5                	mov    %esp,%ebp
c0100d6d:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d70:	e8 c3 fb ff ff       	call   c0100938 <print_kerninfo>
    return 0;
c0100d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d7a:	c9                   	leave  
c0100d7b:	c3                   	ret    

c0100d7c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d7c:	55                   	push   %ebp
c0100d7d:	89 e5                	mov    %esp,%ebp
c0100d7f:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d82:	e8 fc fc ff ff       	call   c0100a83 <print_stackframe>
    return 0;
c0100d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d8c:	c9                   	leave  
c0100d8d:	c3                   	ret    

c0100d8e <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d8e:	55                   	push   %ebp
c0100d8f:	89 e5                	mov    %esp,%ebp
c0100d91:	83 ec 28             	sub    $0x28,%esp
c0100d94:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d9a:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d9e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0100da2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100da6:	ee                   	out    %al,(%dx)
c0100da7:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0100dad:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0100db1:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0100db5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100db8:	ee                   	out    %al,(%dx)
c0100db9:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dbf:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0100dc3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dcb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dcc:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100dd3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dd6:	c7 04 24 12 64 10 c0 	movl   $0xc0106412,(%esp)
c0100ddd:	e8 b0 f4 ff ff       	call   c0100292 <cprintf>
    pic_enable(IRQ_TIMER);
c0100de2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100de9:	e8 1e 09 00 00       	call   c010170c <pic_enable>
}
c0100dee:	90                   	nop
c0100def:	c9                   	leave  
c0100df0:	c3                   	ret    

c0100df1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100df1:	55                   	push   %ebp
c0100df2:	89 e5                	mov    %esp,%ebp
c0100df4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100df7:	9c                   	pushf  
c0100df8:	58                   	pop    %eax
c0100df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100dff:	25 00 02 00 00       	and    $0x200,%eax
c0100e04:	85 c0                	test   %eax,%eax
c0100e06:	74 0c                	je     c0100e14 <__intr_save+0x23>
        intr_disable();
c0100e08:	e8 6c 0a 00 00       	call   c0101879 <intr_disable>
        return 1;
c0100e0d:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e12:	eb 05                	jmp    c0100e19 <__intr_save+0x28>
    }
    return 0;
c0100e14:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e19:	c9                   	leave  
c0100e1a:	c3                   	ret    

c0100e1b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e1b:	55                   	push   %ebp
c0100e1c:	89 e5                	mov    %esp,%ebp
c0100e1e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e21:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e25:	74 05                	je     c0100e2c <__intr_restore+0x11>
        intr_enable();
c0100e27:	e8 46 0a 00 00       	call   c0101872 <intr_enable>
    }
}
c0100e2c:	90                   	nop
c0100e2d:	c9                   	leave  
c0100e2e:	c3                   	ret    

c0100e2f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e2f:	55                   	push   %ebp
c0100e30:	89 e5                	mov    %esp,%ebp
c0100e32:	83 ec 10             	sub    $0x10,%esp
c0100e35:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e3b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e3f:	89 c2                	mov    %eax,%edx
c0100e41:	ec                   	in     (%dx),%al
c0100e42:	88 45 f4             	mov    %al,-0xc(%ebp)
c0100e45:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c0100e4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e4e:	89 c2                	mov    %eax,%edx
c0100e50:	ec                   	in     (%dx),%al
c0100e51:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e54:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e5a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5e:	89 c2                	mov    %eax,%edx
c0100e60:	ec                   	in     (%dx),%al
c0100e61:	88 45 f6             	mov    %al,-0xa(%ebp)
c0100e64:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c0100e6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100e6d:	89 c2                	mov    %eax,%edx
c0100e6f:	ec                   	in     (%dx),%al
c0100e70:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e73:	90                   	nop
c0100e74:	c9                   	leave  
c0100e75:	c3                   	ret    

c0100e76 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e76:	55                   	push   %ebp
c0100e77:	89 e5                	mov    %esp,%ebp
c0100e79:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e7c:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e86:	0f b7 00             	movzwl (%eax),%eax
c0100e89:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e90:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e98:	0f b7 00             	movzwl (%eax),%eax
c0100e9b:	0f b7 c0             	movzwl %ax,%eax
c0100e9e:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ea3:	74 12                	je     c0100eb7 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ea5:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eac:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100eb3:	b4 03 
c0100eb5:	eb 13                	jmp    c0100eca <cga_init+0x54>
    } else {
        *cp = was;
c0100eb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eba:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ebe:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ec1:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ec8:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100eca:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ed1:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0100ed5:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed9:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0100edd:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ee1:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ee8:	40                   	inc    %eax
c0100ee9:	0f b7 c0             	movzwl %ax,%eax
c0100eec:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ef0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ef4:	89 c2                	mov    %eax,%edx
c0100ef6:	ec                   	in     (%dx),%al
c0100ef7:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0100efa:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0100efe:	0f b6 c0             	movzbl %al,%eax
c0100f01:	c1 e0 08             	shl    $0x8,%eax
c0100f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f07:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f0e:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0100f12:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f16:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0100f1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100f1d:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f1e:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f25:	40                   	inc    %eax
c0100f26:	0f b7 c0             	movzwl %ax,%eax
c0100f29:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f2d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f31:	89 c2                	mov    %eax,%edx
c0100f33:	ec                   	in     (%dx),%al
c0100f34:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f37:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f3b:	0f b6 c0             	movzbl %al,%eax
c0100f3e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f41:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f44:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f4c:	0f b7 c0             	movzwl %ax,%eax
c0100f4f:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f55:	90                   	nop
c0100f56:	c9                   	leave  
c0100f57:	c3                   	ret    

c0100f58 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f58:	55                   	push   %ebp
c0100f59:	89 e5                	mov    %esp,%ebp
c0100f5b:	83 ec 38             	sub    $0x38,%esp
c0100f5e:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f64:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f68:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0100f6c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f70:	ee                   	out    %al,(%dx)
c0100f71:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c0100f77:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c0100f7b:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0100f7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100f82:	ee                   	out    %al,(%dx)
c0100f83:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0100f89:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0100f8d:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0100f91:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f95:	ee                   	out    %al,(%dx)
c0100f96:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0100f9c:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100fa0:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fa4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100fa7:	ee                   	out    %al,(%dx)
c0100fa8:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0100fae:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0100fb2:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0100fb6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fba:	ee                   	out    %al,(%dx)
c0100fbb:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0100fc1:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0100fc5:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0100fc9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100fcc:	ee                   	out    %al,(%dx)
c0100fcd:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fd3:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0100fd7:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0100fdb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fdf:	ee                   	out    %al,(%dx)
c0100fe0:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fe6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100fe9:	89 c2                	mov    %eax,%edx
c0100feb:	ec                   	in     (%dx),%al
c0100fec:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0100fef:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100ff3:	3c ff                	cmp    $0xff,%al
c0100ff5:	0f 95 c0             	setne  %al
c0100ff8:	0f b6 c0             	movzbl %al,%eax
c0100ffb:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101000:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101006:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c010100a:	89 c2                	mov    %eax,%edx
c010100c:	ec                   	in     (%dx),%al
c010100d:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0101010:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0101016:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101019:	89 c2                	mov    %eax,%edx
c010101b:	ec                   	in     (%dx),%al
c010101c:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010101f:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101024:	85 c0                	test   %eax,%eax
c0101026:	74 0c                	je     c0101034 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
c0101028:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010102f:	e8 d8 06 00 00       	call   c010170c <pic_enable>
    }
}
c0101034:	90                   	nop
c0101035:	c9                   	leave  
c0101036:	c3                   	ret    

c0101037 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101037:	55                   	push   %ebp
c0101038:	89 e5                	mov    %esp,%ebp
c010103a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010103d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101044:	eb 08                	jmp    c010104e <lpt_putc_sub+0x17>
        delay();
c0101046:	e8 e4 fd ff ff       	call   c0100e2f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010104b:	ff 45 fc             	incl   -0x4(%ebp)
c010104e:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0101054:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101057:	89 c2                	mov    %eax,%edx
c0101059:	ec                   	in     (%dx),%al
c010105a:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c010105d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101061:	84 c0                	test   %al,%al
c0101063:	78 09                	js     c010106e <lpt_putc_sub+0x37>
c0101065:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010106c:	7e d8                	jle    c0101046 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c010106e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101071:	0f b6 c0             	movzbl %al,%eax
c0101074:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c010107a:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010107d:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0101081:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101084:	ee                   	out    %al,(%dx)
c0101085:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c010108b:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c010108f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101093:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101097:	ee                   	out    %al,(%dx)
c0101098:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c010109e:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c01010a2:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c01010a6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01010aa:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010ab:	90                   	nop
c01010ac:	c9                   	leave  
c01010ad:	c3                   	ret    

c01010ae <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010ae:	55                   	push   %ebp
c01010af:	89 e5                	mov    %esp,%ebp
c01010b1:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010b4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010b8:	74 0d                	je     c01010c7 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01010bd:	89 04 24             	mov    %eax,(%esp)
c01010c0:	e8 72 ff ff ff       	call   c0101037 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010c5:	eb 24                	jmp    c01010eb <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c01010c7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010ce:	e8 64 ff ff ff       	call   c0101037 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010d3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010da:	e8 58 ff ff ff       	call   c0101037 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010df:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e6:	e8 4c ff ff ff       	call   c0101037 <lpt_putc_sub>
    }
}
c01010eb:	90                   	nop
c01010ec:	c9                   	leave  
c01010ed:	c3                   	ret    

c01010ee <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010ee:	55                   	push   %ebp
c01010ef:	89 e5                	mov    %esp,%ebp
c01010f1:	53                   	push   %ebx
c01010f2:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f8:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01010fd:	85 c0                	test   %eax,%eax
c01010ff:	75 07                	jne    c0101108 <cga_putc+0x1a>
        c |= 0x0700;
c0101101:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101108:	8b 45 08             	mov    0x8(%ebp),%eax
c010110b:	0f b6 c0             	movzbl %al,%eax
c010110e:	83 f8 0a             	cmp    $0xa,%eax
c0101111:	74 54                	je     c0101167 <cga_putc+0x79>
c0101113:	83 f8 0d             	cmp    $0xd,%eax
c0101116:	74 62                	je     c010117a <cga_putc+0x8c>
c0101118:	83 f8 08             	cmp    $0x8,%eax
c010111b:	0f 85 93 00 00 00    	jne    c01011b4 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
c0101121:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101128:	85 c0                	test   %eax,%eax
c010112a:	0f 84 ae 00 00 00    	je     c01011de <cga_putc+0xf0>
            crt_pos --;
c0101130:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101137:	48                   	dec    %eax
c0101138:	0f b7 c0             	movzwl %ax,%eax
c010113b:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101141:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101146:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c010114d:	01 d2                	add    %edx,%edx
c010114f:	01 c2                	add    %eax,%edx
c0101151:	8b 45 08             	mov    0x8(%ebp),%eax
c0101154:	98                   	cwtl   
c0101155:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010115a:	98                   	cwtl   
c010115b:	83 c8 20             	or     $0x20,%eax
c010115e:	98                   	cwtl   
c010115f:	0f b7 c0             	movzwl %ax,%eax
c0101162:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101165:	eb 77                	jmp    c01011de <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
c0101167:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010116e:	83 c0 50             	add    $0x50,%eax
c0101171:	0f b7 c0             	movzwl %ax,%eax
c0101174:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010117a:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c0101181:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101188:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c010118d:	89 c8                	mov    %ecx,%eax
c010118f:	f7 e2                	mul    %edx
c0101191:	c1 ea 06             	shr    $0x6,%edx
c0101194:	89 d0                	mov    %edx,%eax
c0101196:	c1 e0 02             	shl    $0x2,%eax
c0101199:	01 d0                	add    %edx,%eax
c010119b:	c1 e0 04             	shl    $0x4,%eax
c010119e:	29 c1                	sub    %eax,%ecx
c01011a0:	89 c8                	mov    %ecx,%eax
c01011a2:	0f b7 c0             	movzwl %ax,%eax
c01011a5:	29 c3                	sub    %eax,%ebx
c01011a7:	89 d8                	mov    %ebx,%eax
c01011a9:	0f b7 c0             	movzwl %ax,%eax
c01011ac:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011b2:	eb 2b                	jmp    c01011df <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011b4:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011ba:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011c1:	8d 50 01             	lea    0x1(%eax),%edx
c01011c4:	0f b7 d2             	movzwl %dx,%edx
c01011c7:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011ce:	01 c0                	add    %eax,%eax
c01011d0:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01011d6:	0f b7 c0             	movzwl %ax,%eax
c01011d9:	66 89 02             	mov    %ax,(%edx)
        break;
c01011dc:	eb 01                	jmp    c01011df <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c01011de:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011df:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011e6:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c01011eb:	76 5d                	jbe    c010124a <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011ed:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011f2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011f8:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011fd:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101204:	00 
c0101205:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101209:	89 04 24             	mov    %eax,(%esp)
c010120c:	e8 21 47 00 00       	call   c0105932 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101211:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101218:	eb 14                	jmp    c010122e <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c010121a:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010121f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101222:	01 d2                	add    %edx,%edx
c0101224:	01 d0                	add    %edx,%eax
c0101226:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010122b:	ff 45 f4             	incl   -0xc(%ebp)
c010122e:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101235:	7e e3                	jle    c010121a <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101237:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010123e:	83 e8 50             	sub    $0x50,%eax
c0101241:	0f b7 c0             	movzwl %ax,%eax
c0101244:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010124a:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101251:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101255:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c0101259:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c010125d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101261:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101262:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101269:	c1 e8 08             	shr    $0x8,%eax
c010126c:	0f b7 c0             	movzwl %ax,%eax
c010126f:	0f b6 c0             	movzbl %al,%eax
c0101272:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c0101279:	42                   	inc    %edx
c010127a:	0f b7 d2             	movzwl %dx,%edx
c010127d:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101281:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101284:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101288:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010128b:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c010128c:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101293:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101297:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c010129b:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c010129f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012a3:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012a4:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012ab:	0f b6 c0             	movzbl %al,%eax
c01012ae:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012b5:	42                   	inc    %edx
c01012b6:	0f b7 d2             	movzwl %dx,%edx
c01012b9:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c01012bd:	88 45 eb             	mov    %al,-0x15(%ebp)
c01012c0:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c01012c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01012c7:	ee                   	out    %al,(%dx)
}
c01012c8:	90                   	nop
c01012c9:	83 c4 24             	add    $0x24,%esp
c01012cc:	5b                   	pop    %ebx
c01012cd:	5d                   	pop    %ebp
c01012ce:	c3                   	ret    

c01012cf <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012cf:	55                   	push   %ebp
c01012d0:	89 e5                	mov    %esp,%ebp
c01012d2:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012dc:	eb 08                	jmp    c01012e6 <serial_putc_sub+0x17>
        delay();
c01012de:	e8 4c fb ff ff       	call   c0100e2f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e3:	ff 45 fc             	incl   -0x4(%ebp)
c01012e6:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01012ef:	89 c2                	mov    %eax,%edx
c01012f1:	ec                   	in     (%dx),%al
c01012f2:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01012f5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01012f9:	0f b6 c0             	movzbl %al,%eax
c01012fc:	83 e0 20             	and    $0x20,%eax
c01012ff:	85 c0                	test   %eax,%eax
c0101301:	75 09                	jne    c010130c <serial_putc_sub+0x3d>
c0101303:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010130a:	7e d2                	jle    c01012de <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010130c:	8b 45 08             	mov    0x8(%ebp),%eax
c010130f:	0f b6 c0             	movzbl %al,%eax
c0101312:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101318:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010131b:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c010131f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101323:	ee                   	out    %al,(%dx)
}
c0101324:	90                   	nop
c0101325:	c9                   	leave  
c0101326:	c3                   	ret    

c0101327 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101327:	55                   	push   %ebp
c0101328:	89 e5                	mov    %esp,%ebp
c010132a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010132d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101331:	74 0d                	je     c0101340 <serial_putc+0x19>
        serial_putc_sub(c);
c0101333:	8b 45 08             	mov    0x8(%ebp),%eax
c0101336:	89 04 24             	mov    %eax,(%esp)
c0101339:	e8 91 ff ff ff       	call   c01012cf <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c010133e:	eb 24                	jmp    c0101364 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101340:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101347:	e8 83 ff ff ff       	call   c01012cf <serial_putc_sub>
        serial_putc_sub(' ');
c010134c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101353:	e8 77 ff ff ff       	call   c01012cf <serial_putc_sub>
        serial_putc_sub('\b');
c0101358:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010135f:	e8 6b ff ff ff       	call   c01012cf <serial_putc_sub>
    }
}
c0101364:	90                   	nop
c0101365:	c9                   	leave  
c0101366:	c3                   	ret    

c0101367 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101367:	55                   	push   %ebp
c0101368:	89 e5                	mov    %esp,%ebp
c010136a:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010136d:	eb 33                	jmp    c01013a2 <cons_intr+0x3b>
        if (c != 0) {
c010136f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101373:	74 2d                	je     c01013a2 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101375:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010137a:	8d 50 01             	lea    0x1(%eax),%edx
c010137d:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c0101383:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101386:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c010138c:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101391:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101396:	75 0a                	jne    c01013a2 <cons_intr+0x3b>
                cons.wpos = 0;
c0101398:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c010139f:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01013a5:	ff d0                	call   *%eax
c01013a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013aa:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013ae:	75 bf                	jne    c010136f <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013b0:	90                   	nop
c01013b1:	c9                   	leave  
c01013b2:	c3                   	ret    

c01013b3 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013b3:	55                   	push   %ebp
c01013b4:	89 e5                	mov    %esp,%ebp
c01013b6:	83 ec 10             	sub    $0x10,%esp
c01013b9:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01013c2:	89 c2                	mov    %eax,%edx
c01013c4:	ec                   	in     (%dx),%al
c01013c5:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01013c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013cc:	0f b6 c0             	movzbl %al,%eax
c01013cf:	83 e0 01             	and    $0x1,%eax
c01013d2:	85 c0                	test   %eax,%eax
c01013d4:	75 07                	jne    c01013dd <serial_proc_data+0x2a>
        return -1;
c01013d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013db:	eb 2a                	jmp    c0101407 <serial_proc_data+0x54>
c01013dd:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013e3:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013e7:	89 c2                	mov    %eax,%edx
c01013e9:	ec                   	in     (%dx),%al
c01013ea:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c01013ed:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013f1:	0f b6 c0             	movzbl %al,%eax
c01013f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01013f7:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01013fb:	75 07                	jne    c0101404 <serial_proc_data+0x51>
        c = '\b';
c01013fd:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101404:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101407:	c9                   	leave  
c0101408:	c3                   	ret    

c0101409 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101409:	55                   	push   %ebp
c010140a:	89 e5                	mov    %esp,%ebp
c010140c:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010140f:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101414:	85 c0                	test   %eax,%eax
c0101416:	74 0c                	je     c0101424 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101418:	c7 04 24 b3 13 10 c0 	movl   $0xc01013b3,(%esp)
c010141f:	e8 43 ff ff ff       	call   c0101367 <cons_intr>
    }
}
c0101424:	90                   	nop
c0101425:	c9                   	leave  
c0101426:	c3                   	ret    

c0101427 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101427:	55                   	push   %ebp
c0101428:	89 e5                	mov    %esp,%ebp
c010142a:	83 ec 28             	sub    $0x28,%esp
c010142d:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101433:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101436:	89 c2                	mov    %eax,%edx
c0101438:	ec                   	in     (%dx),%al
c0101439:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010143c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101440:	0f b6 c0             	movzbl %al,%eax
c0101443:	83 e0 01             	and    $0x1,%eax
c0101446:	85 c0                	test   %eax,%eax
c0101448:	75 0a                	jne    c0101454 <kbd_proc_data+0x2d>
        return -1;
c010144a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010144f:	e9 56 01 00 00       	jmp    c01015aa <kbd_proc_data+0x183>
c0101454:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010145a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010145d:	89 c2                	mov    %eax,%edx
c010145f:	ec                   	in     (%dx),%al
c0101460:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101463:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101467:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010146a:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010146e:	75 17                	jne    c0101487 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101470:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101475:	83 c8 40             	or     $0x40,%eax
c0101478:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c010147d:	b8 00 00 00 00       	mov    $0x0,%eax
c0101482:	e9 23 01 00 00       	jmp    c01015aa <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101487:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010148b:	84 c0                	test   %al,%al
c010148d:	79 45                	jns    c01014d4 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010148f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101494:	83 e0 40             	and    $0x40,%eax
c0101497:	85 c0                	test   %eax,%eax
c0101499:	75 08                	jne    c01014a3 <kbd_proc_data+0x7c>
c010149b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010149f:	24 7f                	and    $0x7f,%al
c01014a1:	eb 04                	jmp    c01014a7 <kbd_proc_data+0x80>
c01014a3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a7:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014aa:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ae:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014b5:	0c 40                	or     $0x40,%al
c01014b7:	0f b6 c0             	movzbl %al,%eax
c01014ba:	f7 d0                	not    %eax
c01014bc:	89 c2                	mov    %eax,%edx
c01014be:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014c3:	21 d0                	and    %edx,%eax
c01014c5:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014ca:	b8 00 00 00 00       	mov    $0x0,%eax
c01014cf:	e9 d6 00 00 00       	jmp    c01015aa <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c01014d4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d9:	83 e0 40             	and    $0x40,%eax
c01014dc:	85 c0                	test   %eax,%eax
c01014de:	74 11                	je     c01014f1 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014e0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014e4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014e9:	83 e0 bf             	and    $0xffffffbf,%eax
c01014ec:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c01014f1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014f5:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014fc:	0f b6 d0             	movzbl %al,%edx
c01014ff:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101504:	09 d0                	or     %edx,%eax
c0101506:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c010150b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010150f:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101516:	0f b6 d0             	movzbl %al,%edx
c0101519:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010151e:	31 d0                	xor    %edx,%eax
c0101520:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101525:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152a:	83 e0 03             	and    $0x3,%eax
c010152d:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101534:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101538:	01 d0                	add    %edx,%eax
c010153a:	0f b6 00             	movzbl (%eax),%eax
c010153d:	0f b6 c0             	movzbl %al,%eax
c0101540:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101543:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101548:	83 e0 08             	and    $0x8,%eax
c010154b:	85 c0                	test   %eax,%eax
c010154d:	74 22                	je     c0101571 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c010154f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101553:	7e 0c                	jle    c0101561 <kbd_proc_data+0x13a>
c0101555:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101559:	7f 06                	jg     c0101561 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c010155b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010155f:	eb 10                	jmp    c0101571 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101561:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101565:	7e 0a                	jle    c0101571 <kbd_proc_data+0x14a>
c0101567:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010156b:	7f 04                	jg     c0101571 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010156d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101571:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101576:	f7 d0                	not    %eax
c0101578:	83 e0 06             	and    $0x6,%eax
c010157b:	85 c0                	test   %eax,%eax
c010157d:	75 28                	jne    c01015a7 <kbd_proc_data+0x180>
c010157f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101586:	75 1f                	jne    c01015a7 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101588:	c7 04 24 2d 64 10 c0 	movl   $0xc010642d,(%esp)
c010158f:	e8 fe ec ff ff       	call   c0100292 <cprintf>
c0101594:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c010159a:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010159e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01015a2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01015a6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015aa:	c9                   	leave  
c01015ab:	c3                   	ret    

c01015ac <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015ac:	55                   	push   %ebp
c01015ad:	89 e5                	mov    %esp,%ebp
c01015af:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015b2:	c7 04 24 27 14 10 c0 	movl   $0xc0101427,(%esp)
c01015b9:	e8 a9 fd ff ff       	call   c0101367 <cons_intr>
}
c01015be:	90                   	nop
c01015bf:	c9                   	leave  
c01015c0:	c3                   	ret    

c01015c1 <kbd_init>:

static void
kbd_init(void) {
c01015c1:	55                   	push   %ebp
c01015c2:	89 e5                	mov    %esp,%ebp
c01015c4:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015c7:	e8 e0 ff ff ff       	call   c01015ac <kbd_intr>
    pic_enable(IRQ_KBD);
c01015cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015d3:	e8 34 01 00 00       	call   c010170c <pic_enable>
}
c01015d8:	90                   	nop
c01015d9:	c9                   	leave  
c01015da:	c3                   	ret    

c01015db <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015db:	55                   	push   %ebp
c01015dc:	89 e5                	mov    %esp,%ebp
c01015de:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015e1:	e8 90 f8 ff ff       	call   c0100e76 <cga_init>
    serial_init();
c01015e6:	e8 6d f9 ff ff       	call   c0100f58 <serial_init>
    kbd_init();
c01015eb:	e8 d1 ff ff ff       	call   c01015c1 <kbd_init>
    if (!serial_exists) {
c01015f0:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c01015f5:	85 c0                	test   %eax,%eax
c01015f7:	75 0c                	jne    c0101605 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01015f9:	c7 04 24 39 64 10 c0 	movl   $0xc0106439,(%esp)
c0101600:	e8 8d ec ff ff       	call   c0100292 <cprintf>
    }
}
c0101605:	90                   	nop
c0101606:	c9                   	leave  
c0101607:	c3                   	ret    

c0101608 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101608:	55                   	push   %ebp
c0101609:	89 e5                	mov    %esp,%ebp
c010160b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010160e:	e8 de f7 ff ff       	call   c0100df1 <__intr_save>
c0101613:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101616:	8b 45 08             	mov    0x8(%ebp),%eax
c0101619:	89 04 24             	mov    %eax,(%esp)
c010161c:	e8 8d fa ff ff       	call   c01010ae <lpt_putc>
        cga_putc(c);
c0101621:	8b 45 08             	mov    0x8(%ebp),%eax
c0101624:	89 04 24             	mov    %eax,(%esp)
c0101627:	e8 c2 fa ff ff       	call   c01010ee <cga_putc>
        serial_putc(c);
c010162c:	8b 45 08             	mov    0x8(%ebp),%eax
c010162f:	89 04 24             	mov    %eax,(%esp)
c0101632:	e8 f0 fc ff ff       	call   c0101327 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101637:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010163a:	89 04 24             	mov    %eax,(%esp)
c010163d:	e8 d9 f7 ff ff       	call   c0100e1b <__intr_restore>
}
c0101642:	90                   	nop
c0101643:	c9                   	leave  
c0101644:	c3                   	ret    

c0101645 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101645:	55                   	push   %ebp
c0101646:	89 e5                	mov    %esp,%ebp
c0101648:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010164b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101652:	e8 9a f7 ff ff       	call   c0100df1 <__intr_save>
c0101657:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010165a:	e8 aa fd ff ff       	call   c0101409 <serial_intr>
        kbd_intr();
c010165f:	e8 48 ff ff ff       	call   c01015ac <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101664:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c010166a:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010166f:	39 c2                	cmp    %eax,%edx
c0101671:	74 31                	je     c01016a4 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101673:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101678:	8d 50 01             	lea    0x1(%eax),%edx
c010167b:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c0101681:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c0101688:	0f b6 c0             	movzbl %al,%eax
c010168b:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010168e:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101693:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101698:	75 0a                	jne    c01016a4 <cons_getc+0x5f>
                cons.rpos = 0;
c010169a:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016a1:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016a7:	89 04 24             	mov    %eax,(%esp)
c01016aa:	e8 6c f7 ff ff       	call   c0100e1b <__intr_restore>
    return c;
c01016af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016b2:	c9                   	leave  
c01016b3:	c3                   	ret    

c01016b4 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016b4:	55                   	push   %ebp
c01016b5:	89 e5                	mov    %esp,%ebp
c01016b7:	83 ec 14             	sub    $0x14,%esp
c01016ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01016bd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016c4:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016ca:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016cf:	85 c0                	test   %eax,%eax
c01016d1:	74 36                	je     c0101709 <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
c01016d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016d6:	0f b6 c0             	movzbl %al,%eax
c01016d9:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016df:	88 45 fa             	mov    %al,-0x6(%ebp)
c01016e2:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c01016e6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016ea:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016eb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016ef:	c1 e8 08             	shr    $0x8,%eax
c01016f2:	0f b7 c0             	movzwl %ax,%eax
c01016f5:	0f b6 c0             	movzbl %al,%eax
c01016f8:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c01016fe:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101701:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0101705:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101708:	ee                   	out    %al,(%dx)
    }
}
c0101709:	90                   	nop
c010170a:	c9                   	leave  
c010170b:	c3                   	ret    

c010170c <pic_enable>:

void
pic_enable(unsigned int irq) {
c010170c:	55                   	push   %ebp
c010170d:	89 e5                	mov    %esp,%ebp
c010170f:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101712:	8b 45 08             	mov    0x8(%ebp),%eax
c0101715:	ba 01 00 00 00       	mov    $0x1,%edx
c010171a:	88 c1                	mov    %al,%cl
c010171c:	d3 e2                	shl    %cl,%edx
c010171e:	89 d0                	mov    %edx,%eax
c0101720:	98                   	cwtl   
c0101721:	f7 d0                	not    %eax
c0101723:	0f bf d0             	movswl %ax,%edx
c0101726:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010172d:	98                   	cwtl   
c010172e:	21 d0                	and    %edx,%eax
c0101730:	98                   	cwtl   
c0101731:	0f b7 c0             	movzwl %ax,%eax
c0101734:	89 04 24             	mov    %eax,(%esp)
c0101737:	e8 78 ff ff ff       	call   c01016b4 <pic_setmask>
}
c010173c:	90                   	nop
c010173d:	c9                   	leave  
c010173e:	c3                   	ret    

c010173f <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010173f:	55                   	push   %ebp
c0101740:	89 e5                	mov    %esp,%ebp
c0101742:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
c0101745:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010174c:	00 00 00 
c010174f:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101755:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c0101759:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c010175d:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101761:	ee                   	out    %al,(%dx)
c0101762:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101768:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c010176c:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101770:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101773:	ee                   	out    %al,(%dx)
c0101774:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c010177a:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c010177e:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101782:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101786:	ee                   	out    %al,(%dx)
c0101787:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c010178d:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0101791:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101795:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101798:	ee                   	out    %al,(%dx)
c0101799:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c010179f:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c01017a3:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017a7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017ab:	ee                   	out    %al,(%dx)
c01017ac:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c01017b2:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c01017b6:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01017bd:	ee                   	out    %al,(%dx)
c01017be:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c01017c4:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c01017c8:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01017cc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017d0:	ee                   	out    %al,(%dx)
c01017d1:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c01017d7:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c01017db:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017df:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01017e2:	ee                   	out    %al,(%dx)
c01017e3:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01017e9:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c01017ed:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c01017f1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017f5:	ee                   	out    %al,(%dx)
c01017f6:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c01017fc:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0101800:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101804:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101807:	ee                   	out    %al,(%dx)
c0101808:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c010180e:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c0101812:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101816:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010181a:	ee                   	out    %al,(%dx)
c010181b:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c0101821:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c0101825:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101829:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010182c:	ee                   	out    %al,(%dx)
c010182d:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101833:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c0101837:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c010183b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010183f:	ee                   	out    %al,(%dx)
c0101840:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c0101846:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c010184a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c010184e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101851:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101852:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101859:	3d ff ff 00 00       	cmp    $0xffff,%eax
c010185e:	74 0f                	je     c010186f <pic_init+0x130>
        pic_setmask(irq_mask);
c0101860:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101867:	89 04 24             	mov    %eax,(%esp)
c010186a:	e8 45 fe ff ff       	call   c01016b4 <pic_setmask>
    }
}
c010186f:	90                   	nop
c0101870:	c9                   	leave  
c0101871:	c3                   	ret    

c0101872 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101872:	55                   	push   %ebp
c0101873:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101875:	fb                   	sti    
    sti();
}
c0101876:	90                   	nop
c0101877:	5d                   	pop    %ebp
c0101878:	c3                   	ret    

c0101879 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101879:	55                   	push   %ebp
c010187a:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010187c:	fa                   	cli    
    cli();
}
c010187d:	90                   	nop
c010187e:	5d                   	pop    %ebp
c010187f:	c3                   	ret    

c0101880 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101880:	55                   	push   %ebp
c0101881:	89 e5                	mov    %esp,%ebp
c0101883:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101886:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010188d:	00 
c010188e:	c7 04 24 60 64 10 c0 	movl   $0xc0106460,(%esp)
c0101895:	e8 f8 e9 ff ff       	call   c0100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010189a:	90                   	nop
c010189b:	c9                   	leave  
c010189c:	c3                   	ret    

c010189d <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010189d:	55                   	push   %ebp
c010189e:	89 e5                	mov    %esp,%ebp
c01018a0:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
	//初始化IDT
    for (i = 0; i < 256; i ++) {
c01018a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018aa:	e9 c4 00 00 00       	jmp    c0101973 <idt_init+0xd6>
        //0为中断门，GD_KTEXT为系统段选择子，DPL_KERNEL=0
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018b2:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018b9:	0f b7 d0             	movzwl %ax,%edx
c01018bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018bf:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018c6:	c0 
c01018c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ca:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c01018d1:	c0 08 00 
c01018d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d7:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018de:	c0 
c01018df:	80 e2 e0             	and    $0xe0,%dl
c01018e2:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ec:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018f3:	c0 
c01018f4:	80 e2 1f             	and    $0x1f,%dl
c01018f7:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101901:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101908:	c0 
c0101909:	80 e2 f0             	and    $0xf0,%dl
c010190c:	80 ca 0e             	or     $0xe,%dl
c010190f:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101916:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101919:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101920:	c0 
c0101921:	80 e2 ef             	and    $0xef,%dl
c0101924:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010192b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010192e:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101935:	c0 
c0101936:	80 e2 9f             	and    $0x9f,%dl
c0101939:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101940:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101943:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010194a:	c0 
c010194b:	80 ca 80             	or     $0x80,%dl
c010194e:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101955:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101958:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c010195f:	c1 e8 10             	shr    $0x10,%eax
c0101962:	0f b7 d0             	movzwl %ax,%edx
c0101965:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101968:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c010196f:	c0 
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
	//初始化IDT
    for (i = 0; i < 256; i ++) {
c0101970:	ff 45 fc             	incl   -0x4(%ebp)
c0101973:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c010197a:	0f 8e 2f ff ff ff    	jle    c01018af <idt_init+0x12>
        //0为中断门，GD_KTEXT为系统段选择子，DPL_KERNEL=0
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0101980:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101985:	0f b7 c0             	movzwl %ax,%eax
c0101988:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c010198e:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c0101995:	08 00 
c0101997:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c010199e:	24 e0                	and    $0xe0,%al
c01019a0:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019a5:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019ac:	24 1f                	and    $0x1f,%al
c01019ae:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019b3:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019ba:	24 f0                	and    $0xf0,%al
c01019bc:	0c 0e                	or     $0xe,%al
c01019be:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019c3:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019ca:	24 ef                	and    $0xef,%al
c01019cc:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019d1:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019d8:	0c 60                	or     $0x60,%al
c01019da:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019df:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019e6:	0c 80                	or     $0x80,%al
c01019e8:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019ed:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c01019f2:	c1 e8 10             	shr    $0x10,%eax
c01019f5:	0f b7 c0             	movzwl %ax,%eax
c01019f8:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c01019fe:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a05:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a08:	0f 01 18             	lidtl  (%eax)
	// 加载IDT
    lidt(&idt_pd);
}
c0101a0b:	90                   	nop
c0101a0c:	c9                   	leave  
c0101a0d:	c3                   	ret    

c0101a0e <trapname>:

static const char *
trapname(int trapno) {
c0101a0e:	55                   	push   %ebp
c0101a0f:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a11:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a14:	83 f8 13             	cmp    $0x13,%eax
c0101a17:	77 0c                	ja     c0101a25 <trapname+0x17>
        return excnames[trapno];
c0101a19:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1c:	8b 04 85 c0 67 10 c0 	mov    -0x3fef9840(,%eax,4),%eax
c0101a23:	eb 18                	jmp    c0101a3d <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a25:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a29:	7e 0d                	jle    c0101a38 <trapname+0x2a>
c0101a2b:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a2f:	7f 07                	jg     c0101a38 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a31:	b8 6a 64 10 c0       	mov    $0xc010646a,%eax
c0101a36:	eb 05                	jmp    c0101a3d <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a38:	b8 7d 64 10 c0       	mov    $0xc010647d,%eax
}
c0101a3d:	5d                   	pop    %ebp
c0101a3e:	c3                   	ret    

c0101a3f <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a3f:	55                   	push   %ebp
c0101a40:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a42:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a45:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a49:	83 f8 08             	cmp    $0x8,%eax
c0101a4c:	0f 94 c0             	sete   %al
c0101a4f:	0f b6 c0             	movzbl %al,%eax
}
c0101a52:	5d                   	pop    %ebp
c0101a53:	c3                   	ret    

c0101a54 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a54:	55                   	push   %ebp
c0101a55:	89 e5                	mov    %esp,%ebp
c0101a57:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a61:	c7 04 24 be 64 10 c0 	movl   $0xc01064be,(%esp)
c0101a68:	e8 25 e8 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101a6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a70:	89 04 24             	mov    %eax,(%esp)
c0101a73:	e8 91 01 00 00       	call   c0101c09 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7b:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a83:	c7 04 24 cf 64 10 c0 	movl   $0xc01064cf,(%esp)
c0101a8a:	e8 03 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a92:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a9a:	c7 04 24 e2 64 10 c0 	movl   $0xc01064e2,(%esp)
c0101aa1:	e8 ec e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa9:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101aad:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab1:	c7 04 24 f5 64 10 c0 	movl   $0xc01064f5,(%esp)
c0101ab8:	e8 d5 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101abd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac8:	c7 04 24 08 65 10 c0 	movl   $0xc0106508,(%esp)
c0101acf:	e8 be e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad7:	8b 40 30             	mov    0x30(%eax),%eax
c0101ada:	89 04 24             	mov    %eax,(%esp)
c0101add:	e8 2c ff ff ff       	call   c0101a0e <trapname>
c0101ae2:	89 c2                	mov    %eax,%edx
c0101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae7:	8b 40 30             	mov    0x30(%eax),%eax
c0101aea:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101aee:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101af2:	c7 04 24 1b 65 10 c0 	movl   $0xc010651b,(%esp)
c0101af9:	e8 94 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b01:	8b 40 34             	mov    0x34(%eax),%eax
c0101b04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b08:	c7 04 24 2d 65 10 c0 	movl   $0xc010652d,(%esp)
c0101b0f:	e8 7e e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b17:	8b 40 38             	mov    0x38(%eax),%eax
c0101b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b1e:	c7 04 24 3c 65 10 c0 	movl   $0xc010653c,(%esp)
c0101b25:	e8 68 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b35:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0101b3c:	e8 51 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b44:	8b 40 40             	mov    0x40(%eax),%eax
c0101b47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4b:	c7 04 24 5e 65 10 c0 	movl   $0xc010655e,(%esp)
c0101b52:	e8 3b e7 ff ff       	call   c0100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b5e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b65:	eb 3d                	jmp    c0101ba4 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6a:	8b 50 40             	mov    0x40(%eax),%edx
c0101b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b70:	21 d0                	and    %edx,%eax
c0101b72:	85 c0                	test   %eax,%eax
c0101b74:	74 28                	je     c0101b9e <print_trapframe+0x14a>
c0101b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b79:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b80:	85 c0                	test   %eax,%eax
c0101b82:	74 1a                	je     c0101b9e <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b87:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b92:	c7 04 24 6d 65 10 c0 	movl   $0xc010656d,(%esp)
c0101b99:	e8 f4 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b9e:	ff 45 f4             	incl   -0xc(%ebp)
c0101ba1:	d1 65 f0             	shll   -0x10(%ebp)
c0101ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ba7:	83 f8 17             	cmp    $0x17,%eax
c0101baa:	76 bb                	jbe    c0101b67 <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bac:	8b 45 08             	mov    0x8(%ebp),%eax
c0101baf:	8b 40 40             	mov    0x40(%eax),%eax
c0101bb2:	25 00 30 00 00       	and    $0x3000,%eax
c0101bb7:	c1 e8 0c             	shr    $0xc,%eax
c0101bba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bbe:	c7 04 24 71 65 10 c0 	movl   $0xc0106571,(%esp)
c0101bc5:	e8 c8 e6 ff ff       	call   c0100292 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101bca:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bcd:	89 04 24             	mov    %eax,(%esp)
c0101bd0:	e8 6a fe ff ff       	call   c0101a3f <trap_in_kernel>
c0101bd5:	85 c0                	test   %eax,%eax
c0101bd7:	75 2d                	jne    c0101c06 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bdc:	8b 40 44             	mov    0x44(%eax),%eax
c0101bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be3:	c7 04 24 7a 65 10 c0 	movl   $0xc010657a,(%esp)
c0101bea:	e8 a3 e6 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101bef:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf2:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bfa:	c7 04 24 89 65 10 c0 	movl   $0xc0106589,(%esp)
c0101c01:	e8 8c e6 ff ff       	call   c0100292 <cprintf>
    }
}
c0101c06:	90                   	nop
c0101c07:	c9                   	leave  
c0101c08:	c3                   	ret    

c0101c09 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c09:	55                   	push   %ebp
c0101c0a:	89 e5                	mov    %esp,%ebp
c0101c0c:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c12:	8b 00                	mov    (%eax),%eax
c0101c14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c18:	c7 04 24 9c 65 10 c0 	movl   $0xc010659c,(%esp)
c0101c1f:	e8 6e e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c24:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c27:	8b 40 04             	mov    0x4(%eax),%eax
c0101c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c2e:	c7 04 24 ab 65 10 c0 	movl   $0xc01065ab,(%esp)
c0101c35:	e8 58 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3d:	8b 40 08             	mov    0x8(%eax),%eax
c0101c40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c44:	c7 04 24 ba 65 10 c0 	movl   $0xc01065ba,(%esp)
c0101c4b:	e8 42 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c50:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c53:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c5a:	c7 04 24 c9 65 10 c0 	movl   $0xc01065c9,(%esp)
c0101c61:	e8 2c e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c66:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c69:	8b 40 10             	mov    0x10(%eax),%eax
c0101c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c70:	c7 04 24 d8 65 10 c0 	movl   $0xc01065d8,(%esp)
c0101c77:	e8 16 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7f:	8b 40 14             	mov    0x14(%eax),%eax
c0101c82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c86:	c7 04 24 e7 65 10 c0 	movl   $0xc01065e7,(%esp)
c0101c8d:	e8 00 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c92:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c95:	8b 40 18             	mov    0x18(%eax),%eax
c0101c98:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c9c:	c7 04 24 f6 65 10 c0 	movl   $0xc01065f6,(%esp)
c0101ca3:	e8 ea e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101ca8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cab:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb2:	c7 04 24 05 66 10 c0 	movl   $0xc0106605,(%esp)
c0101cb9:	e8 d4 e5 ff ff       	call   c0100292 <cprintf>
}
c0101cbe:	90                   	nop
c0101cbf:	c9                   	leave  
c0101cc0:	c3                   	ret    

c0101cc1 <trap_dispatch>:

struct trapframe switchk2u, *switchu2k;
/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101cc1:	55                   	push   %ebp
c0101cc2:	89 e5                	mov    %esp,%ebp
c0101cc4:	57                   	push   %edi
c0101cc5:	56                   	push   %esi
c0101cc6:	53                   	push   %ebx
c0101cc7:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
c0101cca:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ccd:	8b 40 30             	mov    0x30(%eax),%eax
c0101cd0:	83 f8 2f             	cmp    $0x2f,%eax
c0101cd3:	77 21                	ja     c0101cf6 <trap_dispatch+0x35>
c0101cd5:	83 f8 2e             	cmp    $0x2e,%eax
c0101cd8:	0f 83 5d 02 00 00    	jae    c0101f3b <trap_dispatch+0x27a>
c0101cde:	83 f8 21             	cmp    $0x21,%eax
c0101ce1:	0f 84 95 00 00 00    	je     c0101d7c <trap_dispatch+0xbb>
c0101ce7:	83 f8 24             	cmp    $0x24,%eax
c0101cea:	74 67                	je     c0101d53 <trap_dispatch+0x92>
c0101cec:	83 f8 20             	cmp    $0x20,%eax
c0101cef:	74 1c                	je     c0101d0d <trap_dispatch+0x4c>
c0101cf1:	e9 10 02 00 00       	jmp    c0101f06 <trap_dispatch+0x245>
c0101cf6:	83 f8 78             	cmp    $0x78,%eax
c0101cf9:	0f 84 a6 00 00 00    	je     c0101da5 <trap_dispatch+0xe4>
c0101cff:	83 f8 79             	cmp    $0x79,%eax
c0101d02:	0f 84 81 01 00 00    	je     c0101e89 <trap_dispatch+0x1c8>
c0101d08:	e9 f9 01 00 00       	jmp    c0101f06 <trap_dispatch+0x245>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101d0d:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d12:	40                   	inc    %eax
c0101d13:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if (ticks % TICK_NUM == 0) {
c0101d18:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101d1e:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d23:	89 c8                	mov    %ecx,%eax
c0101d25:	f7 e2                	mul    %edx
c0101d27:	c1 ea 05             	shr    $0x5,%edx
c0101d2a:	89 d0                	mov    %edx,%eax
c0101d2c:	c1 e0 02             	shl    $0x2,%eax
c0101d2f:	01 d0                	add    %edx,%eax
c0101d31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101d38:	01 d0                	add    %edx,%eax
c0101d3a:	c1 e0 02             	shl    $0x2,%eax
c0101d3d:	29 c1                	sub    %eax,%ecx
c0101d3f:	89 ca                	mov    %ecx,%edx
c0101d41:	85 d2                	test   %edx,%edx
c0101d43:	0f 85 f5 01 00 00    	jne    c0101f3e <trap_dispatch+0x27d>
            print_ticks();
c0101d49:	e8 32 fb ff ff       	call   c0101880 <print_ticks>
        }
        break;
c0101d4e:	e9 eb 01 00 00       	jmp    c0101f3e <trap_dispatch+0x27d>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d53:	e8 ed f8 ff ff       	call   c0101645 <cons_getc>
c0101d58:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d5b:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101d5f:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101d63:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d6b:	c7 04 24 14 66 10 c0 	movl   $0xc0106614,(%esp)
c0101d72:	e8 1b e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d77:	e9 c9 01 00 00       	jmp    c0101f45 <trap_dispatch+0x284>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d7c:	e8 c4 f8 ff ff       	call   c0101645 <cons_getc>
c0101d81:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d84:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101d88:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101d8c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d94:	c7 04 24 26 66 10 c0 	movl   $0xc0106626,(%esp)
c0101d9b:	e8 f2 e4 ff ff       	call   c0100292 <cprintf>
        break;
c0101da0:	e9 a0 01 00 00       	jmp    c0101f45 <trap_dispatch+0x284>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
c0101da5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101da8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101dac:	83 f8 1b             	cmp    $0x1b,%eax
c0101daf:	0f 84 8c 01 00 00    	je     c0101f41 <trap_dispatch+0x280>
        //当前在内核态，需要建立切换到用户态所需的trapframe结构的数据switchk2u，即修改栈上的段寄存器为用户态段寄存器
            switchk2u = *tf;
c0101db5:	8b 55 08             	mov    0x8(%ebp),%edx
c0101db8:	b8 20 af 11 c0       	mov    $0xc011af20,%eax
c0101dbd:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0101dc2:	89 c1                	mov    %eax,%ecx
c0101dc4:	83 e1 01             	and    $0x1,%ecx
c0101dc7:	85 c9                	test   %ecx,%ecx
c0101dc9:	74 0c                	je     c0101dd7 <trap_dispatch+0x116>
c0101dcb:	0f b6 0a             	movzbl (%edx),%ecx
c0101dce:	88 08                	mov    %cl,(%eax)
c0101dd0:	8d 40 01             	lea    0x1(%eax),%eax
c0101dd3:	8d 52 01             	lea    0x1(%edx),%edx
c0101dd6:	4b                   	dec    %ebx
c0101dd7:	89 c1                	mov    %eax,%ecx
c0101dd9:	83 e1 02             	and    $0x2,%ecx
c0101ddc:	85 c9                	test   %ecx,%ecx
c0101dde:	74 0f                	je     c0101def <trap_dispatch+0x12e>
c0101de0:	0f b7 0a             	movzwl (%edx),%ecx
c0101de3:	66 89 08             	mov    %cx,(%eax)
c0101de6:	8d 40 02             	lea    0x2(%eax),%eax
c0101de9:	8d 52 02             	lea    0x2(%edx),%edx
c0101dec:	83 eb 02             	sub    $0x2,%ebx
c0101def:	89 df                	mov    %ebx,%edi
c0101df1:	83 e7 fc             	and    $0xfffffffc,%edi
c0101df4:	b9 00 00 00 00       	mov    $0x0,%ecx
c0101df9:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0101dfc:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0101dff:	83 c1 04             	add    $0x4,%ecx
c0101e02:	39 f9                	cmp    %edi,%ecx
c0101e04:	72 f3                	jb     c0101df9 <trap_dispatch+0x138>
c0101e06:	01 c8                	add    %ecx,%eax
c0101e08:	01 ca                	add    %ecx,%edx
c0101e0a:	b9 00 00 00 00       	mov    $0x0,%ecx
c0101e0f:	89 de                	mov    %ebx,%esi
c0101e11:	83 e6 02             	and    $0x2,%esi
c0101e14:	85 f6                	test   %esi,%esi
c0101e16:	74 0b                	je     c0101e23 <trap_dispatch+0x162>
c0101e18:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0101e1c:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0101e20:	83 c1 02             	add    $0x2,%ecx
c0101e23:	83 e3 01             	and    $0x1,%ebx
c0101e26:	85 db                	test   %ebx,%ebx
c0101e28:	74 07                	je     c0101e31 <trap_dispatch+0x170>
c0101e2a:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0101e2e:	88 14 08             	mov    %dl,(%eax,%ecx,1)
            switchk2u.tf_cs = USER_CS;
c0101e31:	66 c7 05 5c af 11 c0 	movw   $0x1b,0xc011af5c
c0101e38:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0101e3a:	66 c7 05 68 af 11 c0 	movw   $0x23,0xc011af68
c0101e41:	23 00 
c0101e43:	0f b7 05 68 af 11 c0 	movzwl 0xc011af68,%eax
c0101e4a:	66 a3 48 af 11 c0    	mov    %ax,0xc011af48
c0101e50:	0f b7 05 48 af 11 c0 	movzwl 0xc011af48,%eax
c0101e57:	66 a3 4c af 11 c0    	mov    %ax,0xc011af4c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c0101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e60:	83 c0 44             	add    $0x44,%eax
c0101e63:	a3 64 af 11 c0       	mov    %eax,0xc011af64
            //设置EFLAG的I/O特权位，使得在用户态可使用in/out指令
            switchk2u.tf_eflags |= (3 << 12);
c0101e68:	a1 60 af 11 c0       	mov    0xc011af60,%eax
c0101e6d:	0d 00 30 00 00       	or     $0x3000,%eax
c0101e72:	a3 60 af 11 c0       	mov    %eax,0xc011af60
            //设置临时栈，指向switchk2u，这样iret返回时，CPU会从switchk2u恢复数据，
            //而不是从现有栈恢复数据。
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0101e77:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e7a:	83 e8 04             	sub    $0x4,%eax
c0101e7d:	ba 20 af 11 c0       	mov    $0xc011af20,%edx
c0101e82:	89 10                	mov    %edx,(%eax)
        }
        break;
c0101e84:	e9 b8 00 00 00       	jmp    c0101f41 <trap_dispatch+0x280>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
c0101e89:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e8c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e90:	83 f8 08             	cmp    $0x8,%eax
c0101e93:	0f 84 ab 00 00 00    	je     c0101f44 <trap_dispatch+0x283>
            //发出中断时，CPU处于用户态，我们希望处理完此中断后，CPU继续在内核态运行，
            //修改栈上的段寄存器值为内核代码段和内核数据段
            tf->tf_cs = KERNEL_CS;
c0101e99:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e9c:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea5:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101eab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eae:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101eb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb5:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            //设置EFLAGS，让用户态不能执行in/out指令
            tf->tf_eflags &= ~(3 << 12);
c0101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ebc:	8b 40 40             	mov    0x40(%eax),%eax
c0101ebf:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0101ec4:	89 c2                	mov    %eax,%edx
c0101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ec9:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0101ecc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ecf:	8b 40 44             	mov    0x44(%eax),%eax
c0101ed2:	83 e8 44             	sub    $0x44,%eax
c0101ed5:	a3 6c af 11 c0       	mov    %eax,0xc011af6c
            //设置临时栈，指向switchu2k，这样iret返回时，CPU会从switchu2k恢复数据，
            //而不是从现有栈恢复数据。
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0101eda:	a1 6c af 11 c0       	mov    0xc011af6c,%eax
c0101edf:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0101ee6:	00 
c0101ee7:	8b 55 08             	mov    0x8(%ebp),%edx
c0101eea:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101eee:	89 04 24             	mov    %eax,(%esp)
c0101ef1:	e8 3c 3a 00 00       	call   c0105932 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef9:	83 e8 04             	sub    $0x4,%eax
c0101efc:	8b 15 6c af 11 c0    	mov    0xc011af6c,%edx
c0101f02:	89 10                	mov    %edx,(%eax)
        }
        break;
c0101f04:	eb 3e                	jmp    c0101f44 <trap_dispatch+0x283>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101f06:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f09:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f0d:	83 e0 03             	and    $0x3,%eax
c0101f10:	85 c0                	test   %eax,%eax
c0101f12:	75 31                	jne    c0101f45 <trap_dispatch+0x284>
            print_trapframe(tf);
c0101f14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f17:	89 04 24             	mov    %eax,(%esp)
c0101f1a:	e8 35 fb ff ff       	call   c0101a54 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101f1f:	c7 44 24 08 35 66 10 	movl   $0xc0106635,0x8(%esp)
c0101f26:	c0 
c0101f27:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0101f2e:	00 
c0101f2f:	c7 04 24 51 66 10 c0 	movl   $0xc0106651,(%esp)
c0101f36:	e8 ae e4 ff ff       	call   c01003e9 <__panic>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101f3b:	90                   	nop
c0101f3c:	eb 07                	jmp    c0101f45 <trap_dispatch+0x284>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
c0101f3e:	90                   	nop
c0101f3f:	eb 04                	jmp    c0101f45 <trap_dispatch+0x284>
            switchk2u.tf_eflags |= (3 << 12);
            //设置临时栈，指向switchk2u，这样iret返回时，CPU会从switchk2u恢复数据，
            //而不是从现有栈恢复数据。
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
        }
        break;
c0101f41:	90                   	nop
c0101f42:	eb 01                	jmp    c0101f45 <trap_dispatch+0x284>
            //设置临时栈，指向switchu2k，这样iret返回时，CPU会从switchu2k恢复数据，
            //而不是从现有栈恢复数据。
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
        }
        break;
c0101f44:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101f45:	90                   	nop
c0101f46:	83 c4 2c             	add    $0x2c,%esp
c0101f49:	5b                   	pop    %ebx
c0101f4a:	5e                   	pop    %esi
c0101f4b:	5f                   	pop    %edi
c0101f4c:	5d                   	pop    %ebp
c0101f4d:	c3                   	ret    

c0101f4e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101f4e:	55                   	push   %ebp
c0101f4f:	89 e5                	mov    %esp,%ebp
c0101f51:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101f54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f57:	89 04 24             	mov    %eax,(%esp)
c0101f5a:	e8 62 fd ff ff       	call   c0101cc1 <trap_dispatch>
}
c0101f5f:	90                   	nop
c0101f60:	c9                   	leave  
c0101f61:	c3                   	ret    

c0101f62 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101f62:	6a 00                	push   $0x0
  pushl $0
c0101f64:	6a 00                	push   $0x0
  jmp __alltraps
c0101f66:	e9 69 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101f6b <vector1>:
.globl vector1
vector1:
  pushl $0
c0101f6b:	6a 00                	push   $0x0
  pushl $1
c0101f6d:	6a 01                	push   $0x1
  jmp __alltraps
c0101f6f:	e9 60 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101f74 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101f74:	6a 00                	push   $0x0
  pushl $2
c0101f76:	6a 02                	push   $0x2
  jmp __alltraps
c0101f78:	e9 57 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101f7d <vector3>:
.globl vector3
vector3:
  pushl $0
c0101f7d:	6a 00                	push   $0x0
  pushl $3
c0101f7f:	6a 03                	push   $0x3
  jmp __alltraps
c0101f81:	e9 4e 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101f86 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101f86:	6a 00                	push   $0x0
  pushl $4
c0101f88:	6a 04                	push   $0x4
  jmp __alltraps
c0101f8a:	e9 45 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101f8f <vector5>:
.globl vector5
vector5:
  pushl $0
c0101f8f:	6a 00                	push   $0x0
  pushl $5
c0101f91:	6a 05                	push   $0x5
  jmp __alltraps
c0101f93:	e9 3c 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101f98 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101f98:	6a 00                	push   $0x0
  pushl $6
c0101f9a:	6a 06                	push   $0x6
  jmp __alltraps
c0101f9c:	e9 33 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101fa1 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101fa1:	6a 00                	push   $0x0
  pushl $7
c0101fa3:	6a 07                	push   $0x7
  jmp __alltraps
c0101fa5:	e9 2a 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101faa <vector8>:
.globl vector8
vector8:
  pushl $8
c0101faa:	6a 08                	push   $0x8
  jmp __alltraps
c0101fac:	e9 23 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101fb1 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101fb1:	6a 00                	push   $0x0
  pushl $9
c0101fb3:	6a 09                	push   $0x9
  jmp __alltraps
c0101fb5:	e9 1a 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101fba <vector10>:
.globl vector10
vector10:
  pushl $10
c0101fba:	6a 0a                	push   $0xa
  jmp __alltraps
c0101fbc:	e9 13 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101fc1 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101fc1:	6a 0b                	push   $0xb
  jmp __alltraps
c0101fc3:	e9 0c 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101fc8 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101fc8:	6a 0c                	push   $0xc
  jmp __alltraps
c0101fca:	e9 05 0a 00 00       	jmp    c01029d4 <__alltraps>

c0101fcf <vector13>:
.globl vector13
vector13:
  pushl $13
c0101fcf:	6a 0d                	push   $0xd
  jmp __alltraps
c0101fd1:	e9 fe 09 00 00       	jmp    c01029d4 <__alltraps>

c0101fd6 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101fd6:	6a 0e                	push   $0xe
  jmp __alltraps
c0101fd8:	e9 f7 09 00 00       	jmp    c01029d4 <__alltraps>

c0101fdd <vector15>:
.globl vector15
vector15:
  pushl $0
c0101fdd:	6a 00                	push   $0x0
  pushl $15
c0101fdf:	6a 0f                	push   $0xf
  jmp __alltraps
c0101fe1:	e9 ee 09 00 00       	jmp    c01029d4 <__alltraps>

c0101fe6 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101fe6:	6a 00                	push   $0x0
  pushl $16
c0101fe8:	6a 10                	push   $0x10
  jmp __alltraps
c0101fea:	e9 e5 09 00 00       	jmp    c01029d4 <__alltraps>

c0101fef <vector17>:
.globl vector17
vector17:
  pushl $17
c0101fef:	6a 11                	push   $0x11
  jmp __alltraps
c0101ff1:	e9 de 09 00 00       	jmp    c01029d4 <__alltraps>

c0101ff6 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101ff6:	6a 00                	push   $0x0
  pushl $18
c0101ff8:	6a 12                	push   $0x12
  jmp __alltraps
c0101ffa:	e9 d5 09 00 00       	jmp    c01029d4 <__alltraps>

c0101fff <vector19>:
.globl vector19
vector19:
  pushl $0
c0101fff:	6a 00                	push   $0x0
  pushl $19
c0102001:	6a 13                	push   $0x13
  jmp __alltraps
c0102003:	e9 cc 09 00 00       	jmp    c01029d4 <__alltraps>

c0102008 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102008:	6a 00                	push   $0x0
  pushl $20
c010200a:	6a 14                	push   $0x14
  jmp __alltraps
c010200c:	e9 c3 09 00 00       	jmp    c01029d4 <__alltraps>

c0102011 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102011:	6a 00                	push   $0x0
  pushl $21
c0102013:	6a 15                	push   $0x15
  jmp __alltraps
c0102015:	e9 ba 09 00 00       	jmp    c01029d4 <__alltraps>

c010201a <vector22>:
.globl vector22
vector22:
  pushl $0
c010201a:	6a 00                	push   $0x0
  pushl $22
c010201c:	6a 16                	push   $0x16
  jmp __alltraps
c010201e:	e9 b1 09 00 00       	jmp    c01029d4 <__alltraps>

c0102023 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102023:	6a 00                	push   $0x0
  pushl $23
c0102025:	6a 17                	push   $0x17
  jmp __alltraps
c0102027:	e9 a8 09 00 00       	jmp    c01029d4 <__alltraps>

c010202c <vector24>:
.globl vector24
vector24:
  pushl $0
c010202c:	6a 00                	push   $0x0
  pushl $24
c010202e:	6a 18                	push   $0x18
  jmp __alltraps
c0102030:	e9 9f 09 00 00       	jmp    c01029d4 <__alltraps>

c0102035 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102035:	6a 00                	push   $0x0
  pushl $25
c0102037:	6a 19                	push   $0x19
  jmp __alltraps
c0102039:	e9 96 09 00 00       	jmp    c01029d4 <__alltraps>

c010203e <vector26>:
.globl vector26
vector26:
  pushl $0
c010203e:	6a 00                	push   $0x0
  pushl $26
c0102040:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102042:	e9 8d 09 00 00       	jmp    c01029d4 <__alltraps>

c0102047 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102047:	6a 00                	push   $0x0
  pushl $27
c0102049:	6a 1b                	push   $0x1b
  jmp __alltraps
c010204b:	e9 84 09 00 00       	jmp    c01029d4 <__alltraps>

c0102050 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102050:	6a 00                	push   $0x0
  pushl $28
c0102052:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102054:	e9 7b 09 00 00       	jmp    c01029d4 <__alltraps>

c0102059 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102059:	6a 00                	push   $0x0
  pushl $29
c010205b:	6a 1d                	push   $0x1d
  jmp __alltraps
c010205d:	e9 72 09 00 00       	jmp    c01029d4 <__alltraps>

c0102062 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102062:	6a 00                	push   $0x0
  pushl $30
c0102064:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102066:	e9 69 09 00 00       	jmp    c01029d4 <__alltraps>

c010206b <vector31>:
.globl vector31
vector31:
  pushl $0
c010206b:	6a 00                	push   $0x0
  pushl $31
c010206d:	6a 1f                	push   $0x1f
  jmp __alltraps
c010206f:	e9 60 09 00 00       	jmp    c01029d4 <__alltraps>

c0102074 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102074:	6a 00                	push   $0x0
  pushl $32
c0102076:	6a 20                	push   $0x20
  jmp __alltraps
c0102078:	e9 57 09 00 00       	jmp    c01029d4 <__alltraps>

c010207d <vector33>:
.globl vector33
vector33:
  pushl $0
c010207d:	6a 00                	push   $0x0
  pushl $33
c010207f:	6a 21                	push   $0x21
  jmp __alltraps
c0102081:	e9 4e 09 00 00       	jmp    c01029d4 <__alltraps>

c0102086 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102086:	6a 00                	push   $0x0
  pushl $34
c0102088:	6a 22                	push   $0x22
  jmp __alltraps
c010208a:	e9 45 09 00 00       	jmp    c01029d4 <__alltraps>

c010208f <vector35>:
.globl vector35
vector35:
  pushl $0
c010208f:	6a 00                	push   $0x0
  pushl $35
c0102091:	6a 23                	push   $0x23
  jmp __alltraps
c0102093:	e9 3c 09 00 00       	jmp    c01029d4 <__alltraps>

c0102098 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102098:	6a 00                	push   $0x0
  pushl $36
c010209a:	6a 24                	push   $0x24
  jmp __alltraps
c010209c:	e9 33 09 00 00       	jmp    c01029d4 <__alltraps>

c01020a1 <vector37>:
.globl vector37
vector37:
  pushl $0
c01020a1:	6a 00                	push   $0x0
  pushl $37
c01020a3:	6a 25                	push   $0x25
  jmp __alltraps
c01020a5:	e9 2a 09 00 00       	jmp    c01029d4 <__alltraps>

c01020aa <vector38>:
.globl vector38
vector38:
  pushl $0
c01020aa:	6a 00                	push   $0x0
  pushl $38
c01020ac:	6a 26                	push   $0x26
  jmp __alltraps
c01020ae:	e9 21 09 00 00       	jmp    c01029d4 <__alltraps>

c01020b3 <vector39>:
.globl vector39
vector39:
  pushl $0
c01020b3:	6a 00                	push   $0x0
  pushl $39
c01020b5:	6a 27                	push   $0x27
  jmp __alltraps
c01020b7:	e9 18 09 00 00       	jmp    c01029d4 <__alltraps>

c01020bc <vector40>:
.globl vector40
vector40:
  pushl $0
c01020bc:	6a 00                	push   $0x0
  pushl $40
c01020be:	6a 28                	push   $0x28
  jmp __alltraps
c01020c0:	e9 0f 09 00 00       	jmp    c01029d4 <__alltraps>

c01020c5 <vector41>:
.globl vector41
vector41:
  pushl $0
c01020c5:	6a 00                	push   $0x0
  pushl $41
c01020c7:	6a 29                	push   $0x29
  jmp __alltraps
c01020c9:	e9 06 09 00 00       	jmp    c01029d4 <__alltraps>

c01020ce <vector42>:
.globl vector42
vector42:
  pushl $0
c01020ce:	6a 00                	push   $0x0
  pushl $42
c01020d0:	6a 2a                	push   $0x2a
  jmp __alltraps
c01020d2:	e9 fd 08 00 00       	jmp    c01029d4 <__alltraps>

c01020d7 <vector43>:
.globl vector43
vector43:
  pushl $0
c01020d7:	6a 00                	push   $0x0
  pushl $43
c01020d9:	6a 2b                	push   $0x2b
  jmp __alltraps
c01020db:	e9 f4 08 00 00       	jmp    c01029d4 <__alltraps>

c01020e0 <vector44>:
.globl vector44
vector44:
  pushl $0
c01020e0:	6a 00                	push   $0x0
  pushl $44
c01020e2:	6a 2c                	push   $0x2c
  jmp __alltraps
c01020e4:	e9 eb 08 00 00       	jmp    c01029d4 <__alltraps>

c01020e9 <vector45>:
.globl vector45
vector45:
  pushl $0
c01020e9:	6a 00                	push   $0x0
  pushl $45
c01020eb:	6a 2d                	push   $0x2d
  jmp __alltraps
c01020ed:	e9 e2 08 00 00       	jmp    c01029d4 <__alltraps>

c01020f2 <vector46>:
.globl vector46
vector46:
  pushl $0
c01020f2:	6a 00                	push   $0x0
  pushl $46
c01020f4:	6a 2e                	push   $0x2e
  jmp __alltraps
c01020f6:	e9 d9 08 00 00       	jmp    c01029d4 <__alltraps>

c01020fb <vector47>:
.globl vector47
vector47:
  pushl $0
c01020fb:	6a 00                	push   $0x0
  pushl $47
c01020fd:	6a 2f                	push   $0x2f
  jmp __alltraps
c01020ff:	e9 d0 08 00 00       	jmp    c01029d4 <__alltraps>

c0102104 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102104:	6a 00                	push   $0x0
  pushl $48
c0102106:	6a 30                	push   $0x30
  jmp __alltraps
c0102108:	e9 c7 08 00 00       	jmp    c01029d4 <__alltraps>

c010210d <vector49>:
.globl vector49
vector49:
  pushl $0
c010210d:	6a 00                	push   $0x0
  pushl $49
c010210f:	6a 31                	push   $0x31
  jmp __alltraps
c0102111:	e9 be 08 00 00       	jmp    c01029d4 <__alltraps>

c0102116 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102116:	6a 00                	push   $0x0
  pushl $50
c0102118:	6a 32                	push   $0x32
  jmp __alltraps
c010211a:	e9 b5 08 00 00       	jmp    c01029d4 <__alltraps>

c010211f <vector51>:
.globl vector51
vector51:
  pushl $0
c010211f:	6a 00                	push   $0x0
  pushl $51
c0102121:	6a 33                	push   $0x33
  jmp __alltraps
c0102123:	e9 ac 08 00 00       	jmp    c01029d4 <__alltraps>

c0102128 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102128:	6a 00                	push   $0x0
  pushl $52
c010212a:	6a 34                	push   $0x34
  jmp __alltraps
c010212c:	e9 a3 08 00 00       	jmp    c01029d4 <__alltraps>

c0102131 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102131:	6a 00                	push   $0x0
  pushl $53
c0102133:	6a 35                	push   $0x35
  jmp __alltraps
c0102135:	e9 9a 08 00 00       	jmp    c01029d4 <__alltraps>

c010213a <vector54>:
.globl vector54
vector54:
  pushl $0
c010213a:	6a 00                	push   $0x0
  pushl $54
c010213c:	6a 36                	push   $0x36
  jmp __alltraps
c010213e:	e9 91 08 00 00       	jmp    c01029d4 <__alltraps>

c0102143 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102143:	6a 00                	push   $0x0
  pushl $55
c0102145:	6a 37                	push   $0x37
  jmp __alltraps
c0102147:	e9 88 08 00 00       	jmp    c01029d4 <__alltraps>

c010214c <vector56>:
.globl vector56
vector56:
  pushl $0
c010214c:	6a 00                	push   $0x0
  pushl $56
c010214e:	6a 38                	push   $0x38
  jmp __alltraps
c0102150:	e9 7f 08 00 00       	jmp    c01029d4 <__alltraps>

c0102155 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102155:	6a 00                	push   $0x0
  pushl $57
c0102157:	6a 39                	push   $0x39
  jmp __alltraps
c0102159:	e9 76 08 00 00       	jmp    c01029d4 <__alltraps>

c010215e <vector58>:
.globl vector58
vector58:
  pushl $0
c010215e:	6a 00                	push   $0x0
  pushl $58
c0102160:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102162:	e9 6d 08 00 00       	jmp    c01029d4 <__alltraps>

c0102167 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102167:	6a 00                	push   $0x0
  pushl $59
c0102169:	6a 3b                	push   $0x3b
  jmp __alltraps
c010216b:	e9 64 08 00 00       	jmp    c01029d4 <__alltraps>

c0102170 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102170:	6a 00                	push   $0x0
  pushl $60
c0102172:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102174:	e9 5b 08 00 00       	jmp    c01029d4 <__alltraps>

c0102179 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102179:	6a 00                	push   $0x0
  pushl $61
c010217b:	6a 3d                	push   $0x3d
  jmp __alltraps
c010217d:	e9 52 08 00 00       	jmp    c01029d4 <__alltraps>

c0102182 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102182:	6a 00                	push   $0x0
  pushl $62
c0102184:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102186:	e9 49 08 00 00       	jmp    c01029d4 <__alltraps>

c010218b <vector63>:
.globl vector63
vector63:
  pushl $0
c010218b:	6a 00                	push   $0x0
  pushl $63
c010218d:	6a 3f                	push   $0x3f
  jmp __alltraps
c010218f:	e9 40 08 00 00       	jmp    c01029d4 <__alltraps>

c0102194 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102194:	6a 00                	push   $0x0
  pushl $64
c0102196:	6a 40                	push   $0x40
  jmp __alltraps
c0102198:	e9 37 08 00 00       	jmp    c01029d4 <__alltraps>

c010219d <vector65>:
.globl vector65
vector65:
  pushl $0
c010219d:	6a 00                	push   $0x0
  pushl $65
c010219f:	6a 41                	push   $0x41
  jmp __alltraps
c01021a1:	e9 2e 08 00 00       	jmp    c01029d4 <__alltraps>

c01021a6 <vector66>:
.globl vector66
vector66:
  pushl $0
c01021a6:	6a 00                	push   $0x0
  pushl $66
c01021a8:	6a 42                	push   $0x42
  jmp __alltraps
c01021aa:	e9 25 08 00 00       	jmp    c01029d4 <__alltraps>

c01021af <vector67>:
.globl vector67
vector67:
  pushl $0
c01021af:	6a 00                	push   $0x0
  pushl $67
c01021b1:	6a 43                	push   $0x43
  jmp __alltraps
c01021b3:	e9 1c 08 00 00       	jmp    c01029d4 <__alltraps>

c01021b8 <vector68>:
.globl vector68
vector68:
  pushl $0
c01021b8:	6a 00                	push   $0x0
  pushl $68
c01021ba:	6a 44                	push   $0x44
  jmp __alltraps
c01021bc:	e9 13 08 00 00       	jmp    c01029d4 <__alltraps>

c01021c1 <vector69>:
.globl vector69
vector69:
  pushl $0
c01021c1:	6a 00                	push   $0x0
  pushl $69
c01021c3:	6a 45                	push   $0x45
  jmp __alltraps
c01021c5:	e9 0a 08 00 00       	jmp    c01029d4 <__alltraps>

c01021ca <vector70>:
.globl vector70
vector70:
  pushl $0
c01021ca:	6a 00                	push   $0x0
  pushl $70
c01021cc:	6a 46                	push   $0x46
  jmp __alltraps
c01021ce:	e9 01 08 00 00       	jmp    c01029d4 <__alltraps>

c01021d3 <vector71>:
.globl vector71
vector71:
  pushl $0
c01021d3:	6a 00                	push   $0x0
  pushl $71
c01021d5:	6a 47                	push   $0x47
  jmp __alltraps
c01021d7:	e9 f8 07 00 00       	jmp    c01029d4 <__alltraps>

c01021dc <vector72>:
.globl vector72
vector72:
  pushl $0
c01021dc:	6a 00                	push   $0x0
  pushl $72
c01021de:	6a 48                	push   $0x48
  jmp __alltraps
c01021e0:	e9 ef 07 00 00       	jmp    c01029d4 <__alltraps>

c01021e5 <vector73>:
.globl vector73
vector73:
  pushl $0
c01021e5:	6a 00                	push   $0x0
  pushl $73
c01021e7:	6a 49                	push   $0x49
  jmp __alltraps
c01021e9:	e9 e6 07 00 00       	jmp    c01029d4 <__alltraps>

c01021ee <vector74>:
.globl vector74
vector74:
  pushl $0
c01021ee:	6a 00                	push   $0x0
  pushl $74
c01021f0:	6a 4a                	push   $0x4a
  jmp __alltraps
c01021f2:	e9 dd 07 00 00       	jmp    c01029d4 <__alltraps>

c01021f7 <vector75>:
.globl vector75
vector75:
  pushl $0
c01021f7:	6a 00                	push   $0x0
  pushl $75
c01021f9:	6a 4b                	push   $0x4b
  jmp __alltraps
c01021fb:	e9 d4 07 00 00       	jmp    c01029d4 <__alltraps>

c0102200 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102200:	6a 00                	push   $0x0
  pushl $76
c0102202:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102204:	e9 cb 07 00 00       	jmp    c01029d4 <__alltraps>

c0102209 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102209:	6a 00                	push   $0x0
  pushl $77
c010220b:	6a 4d                	push   $0x4d
  jmp __alltraps
c010220d:	e9 c2 07 00 00       	jmp    c01029d4 <__alltraps>

c0102212 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102212:	6a 00                	push   $0x0
  pushl $78
c0102214:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102216:	e9 b9 07 00 00       	jmp    c01029d4 <__alltraps>

c010221b <vector79>:
.globl vector79
vector79:
  pushl $0
c010221b:	6a 00                	push   $0x0
  pushl $79
c010221d:	6a 4f                	push   $0x4f
  jmp __alltraps
c010221f:	e9 b0 07 00 00       	jmp    c01029d4 <__alltraps>

c0102224 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102224:	6a 00                	push   $0x0
  pushl $80
c0102226:	6a 50                	push   $0x50
  jmp __alltraps
c0102228:	e9 a7 07 00 00       	jmp    c01029d4 <__alltraps>

c010222d <vector81>:
.globl vector81
vector81:
  pushl $0
c010222d:	6a 00                	push   $0x0
  pushl $81
c010222f:	6a 51                	push   $0x51
  jmp __alltraps
c0102231:	e9 9e 07 00 00       	jmp    c01029d4 <__alltraps>

c0102236 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102236:	6a 00                	push   $0x0
  pushl $82
c0102238:	6a 52                	push   $0x52
  jmp __alltraps
c010223a:	e9 95 07 00 00       	jmp    c01029d4 <__alltraps>

c010223f <vector83>:
.globl vector83
vector83:
  pushl $0
c010223f:	6a 00                	push   $0x0
  pushl $83
c0102241:	6a 53                	push   $0x53
  jmp __alltraps
c0102243:	e9 8c 07 00 00       	jmp    c01029d4 <__alltraps>

c0102248 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102248:	6a 00                	push   $0x0
  pushl $84
c010224a:	6a 54                	push   $0x54
  jmp __alltraps
c010224c:	e9 83 07 00 00       	jmp    c01029d4 <__alltraps>

c0102251 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102251:	6a 00                	push   $0x0
  pushl $85
c0102253:	6a 55                	push   $0x55
  jmp __alltraps
c0102255:	e9 7a 07 00 00       	jmp    c01029d4 <__alltraps>

c010225a <vector86>:
.globl vector86
vector86:
  pushl $0
c010225a:	6a 00                	push   $0x0
  pushl $86
c010225c:	6a 56                	push   $0x56
  jmp __alltraps
c010225e:	e9 71 07 00 00       	jmp    c01029d4 <__alltraps>

c0102263 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102263:	6a 00                	push   $0x0
  pushl $87
c0102265:	6a 57                	push   $0x57
  jmp __alltraps
c0102267:	e9 68 07 00 00       	jmp    c01029d4 <__alltraps>

c010226c <vector88>:
.globl vector88
vector88:
  pushl $0
c010226c:	6a 00                	push   $0x0
  pushl $88
c010226e:	6a 58                	push   $0x58
  jmp __alltraps
c0102270:	e9 5f 07 00 00       	jmp    c01029d4 <__alltraps>

c0102275 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102275:	6a 00                	push   $0x0
  pushl $89
c0102277:	6a 59                	push   $0x59
  jmp __alltraps
c0102279:	e9 56 07 00 00       	jmp    c01029d4 <__alltraps>

c010227e <vector90>:
.globl vector90
vector90:
  pushl $0
c010227e:	6a 00                	push   $0x0
  pushl $90
c0102280:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102282:	e9 4d 07 00 00       	jmp    c01029d4 <__alltraps>

c0102287 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102287:	6a 00                	push   $0x0
  pushl $91
c0102289:	6a 5b                	push   $0x5b
  jmp __alltraps
c010228b:	e9 44 07 00 00       	jmp    c01029d4 <__alltraps>

c0102290 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102290:	6a 00                	push   $0x0
  pushl $92
c0102292:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102294:	e9 3b 07 00 00       	jmp    c01029d4 <__alltraps>

c0102299 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102299:	6a 00                	push   $0x0
  pushl $93
c010229b:	6a 5d                	push   $0x5d
  jmp __alltraps
c010229d:	e9 32 07 00 00       	jmp    c01029d4 <__alltraps>

c01022a2 <vector94>:
.globl vector94
vector94:
  pushl $0
c01022a2:	6a 00                	push   $0x0
  pushl $94
c01022a4:	6a 5e                	push   $0x5e
  jmp __alltraps
c01022a6:	e9 29 07 00 00       	jmp    c01029d4 <__alltraps>

c01022ab <vector95>:
.globl vector95
vector95:
  pushl $0
c01022ab:	6a 00                	push   $0x0
  pushl $95
c01022ad:	6a 5f                	push   $0x5f
  jmp __alltraps
c01022af:	e9 20 07 00 00       	jmp    c01029d4 <__alltraps>

c01022b4 <vector96>:
.globl vector96
vector96:
  pushl $0
c01022b4:	6a 00                	push   $0x0
  pushl $96
c01022b6:	6a 60                	push   $0x60
  jmp __alltraps
c01022b8:	e9 17 07 00 00       	jmp    c01029d4 <__alltraps>

c01022bd <vector97>:
.globl vector97
vector97:
  pushl $0
c01022bd:	6a 00                	push   $0x0
  pushl $97
c01022bf:	6a 61                	push   $0x61
  jmp __alltraps
c01022c1:	e9 0e 07 00 00       	jmp    c01029d4 <__alltraps>

c01022c6 <vector98>:
.globl vector98
vector98:
  pushl $0
c01022c6:	6a 00                	push   $0x0
  pushl $98
c01022c8:	6a 62                	push   $0x62
  jmp __alltraps
c01022ca:	e9 05 07 00 00       	jmp    c01029d4 <__alltraps>

c01022cf <vector99>:
.globl vector99
vector99:
  pushl $0
c01022cf:	6a 00                	push   $0x0
  pushl $99
c01022d1:	6a 63                	push   $0x63
  jmp __alltraps
c01022d3:	e9 fc 06 00 00       	jmp    c01029d4 <__alltraps>

c01022d8 <vector100>:
.globl vector100
vector100:
  pushl $0
c01022d8:	6a 00                	push   $0x0
  pushl $100
c01022da:	6a 64                	push   $0x64
  jmp __alltraps
c01022dc:	e9 f3 06 00 00       	jmp    c01029d4 <__alltraps>

c01022e1 <vector101>:
.globl vector101
vector101:
  pushl $0
c01022e1:	6a 00                	push   $0x0
  pushl $101
c01022e3:	6a 65                	push   $0x65
  jmp __alltraps
c01022e5:	e9 ea 06 00 00       	jmp    c01029d4 <__alltraps>

c01022ea <vector102>:
.globl vector102
vector102:
  pushl $0
c01022ea:	6a 00                	push   $0x0
  pushl $102
c01022ec:	6a 66                	push   $0x66
  jmp __alltraps
c01022ee:	e9 e1 06 00 00       	jmp    c01029d4 <__alltraps>

c01022f3 <vector103>:
.globl vector103
vector103:
  pushl $0
c01022f3:	6a 00                	push   $0x0
  pushl $103
c01022f5:	6a 67                	push   $0x67
  jmp __alltraps
c01022f7:	e9 d8 06 00 00       	jmp    c01029d4 <__alltraps>

c01022fc <vector104>:
.globl vector104
vector104:
  pushl $0
c01022fc:	6a 00                	push   $0x0
  pushl $104
c01022fe:	6a 68                	push   $0x68
  jmp __alltraps
c0102300:	e9 cf 06 00 00       	jmp    c01029d4 <__alltraps>

c0102305 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102305:	6a 00                	push   $0x0
  pushl $105
c0102307:	6a 69                	push   $0x69
  jmp __alltraps
c0102309:	e9 c6 06 00 00       	jmp    c01029d4 <__alltraps>

c010230e <vector106>:
.globl vector106
vector106:
  pushl $0
c010230e:	6a 00                	push   $0x0
  pushl $106
c0102310:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102312:	e9 bd 06 00 00       	jmp    c01029d4 <__alltraps>

c0102317 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102317:	6a 00                	push   $0x0
  pushl $107
c0102319:	6a 6b                	push   $0x6b
  jmp __alltraps
c010231b:	e9 b4 06 00 00       	jmp    c01029d4 <__alltraps>

c0102320 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102320:	6a 00                	push   $0x0
  pushl $108
c0102322:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102324:	e9 ab 06 00 00       	jmp    c01029d4 <__alltraps>

c0102329 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102329:	6a 00                	push   $0x0
  pushl $109
c010232b:	6a 6d                	push   $0x6d
  jmp __alltraps
c010232d:	e9 a2 06 00 00       	jmp    c01029d4 <__alltraps>

c0102332 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102332:	6a 00                	push   $0x0
  pushl $110
c0102334:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102336:	e9 99 06 00 00       	jmp    c01029d4 <__alltraps>

c010233b <vector111>:
.globl vector111
vector111:
  pushl $0
c010233b:	6a 00                	push   $0x0
  pushl $111
c010233d:	6a 6f                	push   $0x6f
  jmp __alltraps
c010233f:	e9 90 06 00 00       	jmp    c01029d4 <__alltraps>

c0102344 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102344:	6a 00                	push   $0x0
  pushl $112
c0102346:	6a 70                	push   $0x70
  jmp __alltraps
c0102348:	e9 87 06 00 00       	jmp    c01029d4 <__alltraps>

c010234d <vector113>:
.globl vector113
vector113:
  pushl $0
c010234d:	6a 00                	push   $0x0
  pushl $113
c010234f:	6a 71                	push   $0x71
  jmp __alltraps
c0102351:	e9 7e 06 00 00       	jmp    c01029d4 <__alltraps>

c0102356 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102356:	6a 00                	push   $0x0
  pushl $114
c0102358:	6a 72                	push   $0x72
  jmp __alltraps
c010235a:	e9 75 06 00 00       	jmp    c01029d4 <__alltraps>

c010235f <vector115>:
.globl vector115
vector115:
  pushl $0
c010235f:	6a 00                	push   $0x0
  pushl $115
c0102361:	6a 73                	push   $0x73
  jmp __alltraps
c0102363:	e9 6c 06 00 00       	jmp    c01029d4 <__alltraps>

c0102368 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102368:	6a 00                	push   $0x0
  pushl $116
c010236a:	6a 74                	push   $0x74
  jmp __alltraps
c010236c:	e9 63 06 00 00       	jmp    c01029d4 <__alltraps>

c0102371 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102371:	6a 00                	push   $0x0
  pushl $117
c0102373:	6a 75                	push   $0x75
  jmp __alltraps
c0102375:	e9 5a 06 00 00       	jmp    c01029d4 <__alltraps>

c010237a <vector118>:
.globl vector118
vector118:
  pushl $0
c010237a:	6a 00                	push   $0x0
  pushl $118
c010237c:	6a 76                	push   $0x76
  jmp __alltraps
c010237e:	e9 51 06 00 00       	jmp    c01029d4 <__alltraps>

c0102383 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102383:	6a 00                	push   $0x0
  pushl $119
c0102385:	6a 77                	push   $0x77
  jmp __alltraps
c0102387:	e9 48 06 00 00       	jmp    c01029d4 <__alltraps>

c010238c <vector120>:
.globl vector120
vector120:
  pushl $0
c010238c:	6a 00                	push   $0x0
  pushl $120
c010238e:	6a 78                	push   $0x78
  jmp __alltraps
c0102390:	e9 3f 06 00 00       	jmp    c01029d4 <__alltraps>

c0102395 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102395:	6a 00                	push   $0x0
  pushl $121
c0102397:	6a 79                	push   $0x79
  jmp __alltraps
c0102399:	e9 36 06 00 00       	jmp    c01029d4 <__alltraps>

c010239e <vector122>:
.globl vector122
vector122:
  pushl $0
c010239e:	6a 00                	push   $0x0
  pushl $122
c01023a0:	6a 7a                	push   $0x7a
  jmp __alltraps
c01023a2:	e9 2d 06 00 00       	jmp    c01029d4 <__alltraps>

c01023a7 <vector123>:
.globl vector123
vector123:
  pushl $0
c01023a7:	6a 00                	push   $0x0
  pushl $123
c01023a9:	6a 7b                	push   $0x7b
  jmp __alltraps
c01023ab:	e9 24 06 00 00       	jmp    c01029d4 <__alltraps>

c01023b0 <vector124>:
.globl vector124
vector124:
  pushl $0
c01023b0:	6a 00                	push   $0x0
  pushl $124
c01023b2:	6a 7c                	push   $0x7c
  jmp __alltraps
c01023b4:	e9 1b 06 00 00       	jmp    c01029d4 <__alltraps>

c01023b9 <vector125>:
.globl vector125
vector125:
  pushl $0
c01023b9:	6a 00                	push   $0x0
  pushl $125
c01023bb:	6a 7d                	push   $0x7d
  jmp __alltraps
c01023bd:	e9 12 06 00 00       	jmp    c01029d4 <__alltraps>

c01023c2 <vector126>:
.globl vector126
vector126:
  pushl $0
c01023c2:	6a 00                	push   $0x0
  pushl $126
c01023c4:	6a 7e                	push   $0x7e
  jmp __alltraps
c01023c6:	e9 09 06 00 00       	jmp    c01029d4 <__alltraps>

c01023cb <vector127>:
.globl vector127
vector127:
  pushl $0
c01023cb:	6a 00                	push   $0x0
  pushl $127
c01023cd:	6a 7f                	push   $0x7f
  jmp __alltraps
c01023cf:	e9 00 06 00 00       	jmp    c01029d4 <__alltraps>

c01023d4 <vector128>:
.globl vector128
vector128:
  pushl $0
c01023d4:	6a 00                	push   $0x0
  pushl $128
c01023d6:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01023db:	e9 f4 05 00 00       	jmp    c01029d4 <__alltraps>

c01023e0 <vector129>:
.globl vector129
vector129:
  pushl $0
c01023e0:	6a 00                	push   $0x0
  pushl $129
c01023e2:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01023e7:	e9 e8 05 00 00       	jmp    c01029d4 <__alltraps>

c01023ec <vector130>:
.globl vector130
vector130:
  pushl $0
c01023ec:	6a 00                	push   $0x0
  pushl $130
c01023ee:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01023f3:	e9 dc 05 00 00       	jmp    c01029d4 <__alltraps>

c01023f8 <vector131>:
.globl vector131
vector131:
  pushl $0
c01023f8:	6a 00                	push   $0x0
  pushl $131
c01023fa:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01023ff:	e9 d0 05 00 00       	jmp    c01029d4 <__alltraps>

c0102404 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102404:	6a 00                	push   $0x0
  pushl $132
c0102406:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010240b:	e9 c4 05 00 00       	jmp    c01029d4 <__alltraps>

c0102410 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102410:	6a 00                	push   $0x0
  pushl $133
c0102412:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102417:	e9 b8 05 00 00       	jmp    c01029d4 <__alltraps>

c010241c <vector134>:
.globl vector134
vector134:
  pushl $0
c010241c:	6a 00                	push   $0x0
  pushl $134
c010241e:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102423:	e9 ac 05 00 00       	jmp    c01029d4 <__alltraps>

c0102428 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102428:	6a 00                	push   $0x0
  pushl $135
c010242a:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c010242f:	e9 a0 05 00 00       	jmp    c01029d4 <__alltraps>

c0102434 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102434:	6a 00                	push   $0x0
  pushl $136
c0102436:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010243b:	e9 94 05 00 00       	jmp    c01029d4 <__alltraps>

c0102440 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102440:	6a 00                	push   $0x0
  pushl $137
c0102442:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102447:	e9 88 05 00 00       	jmp    c01029d4 <__alltraps>

c010244c <vector138>:
.globl vector138
vector138:
  pushl $0
c010244c:	6a 00                	push   $0x0
  pushl $138
c010244e:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102453:	e9 7c 05 00 00       	jmp    c01029d4 <__alltraps>

c0102458 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102458:	6a 00                	push   $0x0
  pushl $139
c010245a:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c010245f:	e9 70 05 00 00       	jmp    c01029d4 <__alltraps>

c0102464 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102464:	6a 00                	push   $0x0
  pushl $140
c0102466:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010246b:	e9 64 05 00 00       	jmp    c01029d4 <__alltraps>

c0102470 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102470:	6a 00                	push   $0x0
  pushl $141
c0102472:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102477:	e9 58 05 00 00       	jmp    c01029d4 <__alltraps>

c010247c <vector142>:
.globl vector142
vector142:
  pushl $0
c010247c:	6a 00                	push   $0x0
  pushl $142
c010247e:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102483:	e9 4c 05 00 00       	jmp    c01029d4 <__alltraps>

c0102488 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102488:	6a 00                	push   $0x0
  pushl $143
c010248a:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010248f:	e9 40 05 00 00       	jmp    c01029d4 <__alltraps>

c0102494 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102494:	6a 00                	push   $0x0
  pushl $144
c0102496:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010249b:	e9 34 05 00 00       	jmp    c01029d4 <__alltraps>

c01024a0 <vector145>:
.globl vector145
vector145:
  pushl $0
c01024a0:	6a 00                	push   $0x0
  pushl $145
c01024a2:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01024a7:	e9 28 05 00 00       	jmp    c01029d4 <__alltraps>

c01024ac <vector146>:
.globl vector146
vector146:
  pushl $0
c01024ac:	6a 00                	push   $0x0
  pushl $146
c01024ae:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01024b3:	e9 1c 05 00 00       	jmp    c01029d4 <__alltraps>

c01024b8 <vector147>:
.globl vector147
vector147:
  pushl $0
c01024b8:	6a 00                	push   $0x0
  pushl $147
c01024ba:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01024bf:	e9 10 05 00 00       	jmp    c01029d4 <__alltraps>

c01024c4 <vector148>:
.globl vector148
vector148:
  pushl $0
c01024c4:	6a 00                	push   $0x0
  pushl $148
c01024c6:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01024cb:	e9 04 05 00 00       	jmp    c01029d4 <__alltraps>

c01024d0 <vector149>:
.globl vector149
vector149:
  pushl $0
c01024d0:	6a 00                	push   $0x0
  pushl $149
c01024d2:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01024d7:	e9 f8 04 00 00       	jmp    c01029d4 <__alltraps>

c01024dc <vector150>:
.globl vector150
vector150:
  pushl $0
c01024dc:	6a 00                	push   $0x0
  pushl $150
c01024de:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01024e3:	e9 ec 04 00 00       	jmp    c01029d4 <__alltraps>

c01024e8 <vector151>:
.globl vector151
vector151:
  pushl $0
c01024e8:	6a 00                	push   $0x0
  pushl $151
c01024ea:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01024ef:	e9 e0 04 00 00       	jmp    c01029d4 <__alltraps>

c01024f4 <vector152>:
.globl vector152
vector152:
  pushl $0
c01024f4:	6a 00                	push   $0x0
  pushl $152
c01024f6:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01024fb:	e9 d4 04 00 00       	jmp    c01029d4 <__alltraps>

c0102500 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102500:	6a 00                	push   $0x0
  pushl $153
c0102502:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102507:	e9 c8 04 00 00       	jmp    c01029d4 <__alltraps>

c010250c <vector154>:
.globl vector154
vector154:
  pushl $0
c010250c:	6a 00                	push   $0x0
  pushl $154
c010250e:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102513:	e9 bc 04 00 00       	jmp    c01029d4 <__alltraps>

c0102518 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102518:	6a 00                	push   $0x0
  pushl $155
c010251a:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c010251f:	e9 b0 04 00 00       	jmp    c01029d4 <__alltraps>

c0102524 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102524:	6a 00                	push   $0x0
  pushl $156
c0102526:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010252b:	e9 a4 04 00 00       	jmp    c01029d4 <__alltraps>

c0102530 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102530:	6a 00                	push   $0x0
  pushl $157
c0102532:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102537:	e9 98 04 00 00       	jmp    c01029d4 <__alltraps>

c010253c <vector158>:
.globl vector158
vector158:
  pushl $0
c010253c:	6a 00                	push   $0x0
  pushl $158
c010253e:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102543:	e9 8c 04 00 00       	jmp    c01029d4 <__alltraps>

c0102548 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102548:	6a 00                	push   $0x0
  pushl $159
c010254a:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010254f:	e9 80 04 00 00       	jmp    c01029d4 <__alltraps>

c0102554 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102554:	6a 00                	push   $0x0
  pushl $160
c0102556:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010255b:	e9 74 04 00 00       	jmp    c01029d4 <__alltraps>

c0102560 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102560:	6a 00                	push   $0x0
  pushl $161
c0102562:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102567:	e9 68 04 00 00       	jmp    c01029d4 <__alltraps>

c010256c <vector162>:
.globl vector162
vector162:
  pushl $0
c010256c:	6a 00                	push   $0x0
  pushl $162
c010256e:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102573:	e9 5c 04 00 00       	jmp    c01029d4 <__alltraps>

c0102578 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102578:	6a 00                	push   $0x0
  pushl $163
c010257a:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010257f:	e9 50 04 00 00       	jmp    c01029d4 <__alltraps>

c0102584 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102584:	6a 00                	push   $0x0
  pushl $164
c0102586:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010258b:	e9 44 04 00 00       	jmp    c01029d4 <__alltraps>

c0102590 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102590:	6a 00                	push   $0x0
  pushl $165
c0102592:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102597:	e9 38 04 00 00       	jmp    c01029d4 <__alltraps>

c010259c <vector166>:
.globl vector166
vector166:
  pushl $0
c010259c:	6a 00                	push   $0x0
  pushl $166
c010259e:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01025a3:	e9 2c 04 00 00       	jmp    c01029d4 <__alltraps>

c01025a8 <vector167>:
.globl vector167
vector167:
  pushl $0
c01025a8:	6a 00                	push   $0x0
  pushl $167
c01025aa:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01025af:	e9 20 04 00 00       	jmp    c01029d4 <__alltraps>

c01025b4 <vector168>:
.globl vector168
vector168:
  pushl $0
c01025b4:	6a 00                	push   $0x0
  pushl $168
c01025b6:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01025bb:	e9 14 04 00 00       	jmp    c01029d4 <__alltraps>

c01025c0 <vector169>:
.globl vector169
vector169:
  pushl $0
c01025c0:	6a 00                	push   $0x0
  pushl $169
c01025c2:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01025c7:	e9 08 04 00 00       	jmp    c01029d4 <__alltraps>

c01025cc <vector170>:
.globl vector170
vector170:
  pushl $0
c01025cc:	6a 00                	push   $0x0
  pushl $170
c01025ce:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01025d3:	e9 fc 03 00 00       	jmp    c01029d4 <__alltraps>

c01025d8 <vector171>:
.globl vector171
vector171:
  pushl $0
c01025d8:	6a 00                	push   $0x0
  pushl $171
c01025da:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01025df:	e9 f0 03 00 00       	jmp    c01029d4 <__alltraps>

c01025e4 <vector172>:
.globl vector172
vector172:
  pushl $0
c01025e4:	6a 00                	push   $0x0
  pushl $172
c01025e6:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01025eb:	e9 e4 03 00 00       	jmp    c01029d4 <__alltraps>

c01025f0 <vector173>:
.globl vector173
vector173:
  pushl $0
c01025f0:	6a 00                	push   $0x0
  pushl $173
c01025f2:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01025f7:	e9 d8 03 00 00       	jmp    c01029d4 <__alltraps>

c01025fc <vector174>:
.globl vector174
vector174:
  pushl $0
c01025fc:	6a 00                	push   $0x0
  pushl $174
c01025fe:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102603:	e9 cc 03 00 00       	jmp    c01029d4 <__alltraps>

c0102608 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102608:	6a 00                	push   $0x0
  pushl $175
c010260a:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010260f:	e9 c0 03 00 00       	jmp    c01029d4 <__alltraps>

c0102614 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102614:	6a 00                	push   $0x0
  pushl $176
c0102616:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010261b:	e9 b4 03 00 00       	jmp    c01029d4 <__alltraps>

c0102620 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102620:	6a 00                	push   $0x0
  pushl $177
c0102622:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102627:	e9 a8 03 00 00       	jmp    c01029d4 <__alltraps>

c010262c <vector178>:
.globl vector178
vector178:
  pushl $0
c010262c:	6a 00                	push   $0x0
  pushl $178
c010262e:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102633:	e9 9c 03 00 00       	jmp    c01029d4 <__alltraps>

c0102638 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102638:	6a 00                	push   $0x0
  pushl $179
c010263a:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010263f:	e9 90 03 00 00       	jmp    c01029d4 <__alltraps>

c0102644 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102644:	6a 00                	push   $0x0
  pushl $180
c0102646:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010264b:	e9 84 03 00 00       	jmp    c01029d4 <__alltraps>

c0102650 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102650:	6a 00                	push   $0x0
  pushl $181
c0102652:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102657:	e9 78 03 00 00       	jmp    c01029d4 <__alltraps>

c010265c <vector182>:
.globl vector182
vector182:
  pushl $0
c010265c:	6a 00                	push   $0x0
  pushl $182
c010265e:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102663:	e9 6c 03 00 00       	jmp    c01029d4 <__alltraps>

c0102668 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102668:	6a 00                	push   $0x0
  pushl $183
c010266a:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010266f:	e9 60 03 00 00       	jmp    c01029d4 <__alltraps>

c0102674 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102674:	6a 00                	push   $0x0
  pushl $184
c0102676:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010267b:	e9 54 03 00 00       	jmp    c01029d4 <__alltraps>

c0102680 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102680:	6a 00                	push   $0x0
  pushl $185
c0102682:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102687:	e9 48 03 00 00       	jmp    c01029d4 <__alltraps>

c010268c <vector186>:
.globl vector186
vector186:
  pushl $0
c010268c:	6a 00                	push   $0x0
  pushl $186
c010268e:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102693:	e9 3c 03 00 00       	jmp    c01029d4 <__alltraps>

c0102698 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102698:	6a 00                	push   $0x0
  pushl $187
c010269a:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010269f:	e9 30 03 00 00       	jmp    c01029d4 <__alltraps>

c01026a4 <vector188>:
.globl vector188
vector188:
  pushl $0
c01026a4:	6a 00                	push   $0x0
  pushl $188
c01026a6:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01026ab:	e9 24 03 00 00       	jmp    c01029d4 <__alltraps>

c01026b0 <vector189>:
.globl vector189
vector189:
  pushl $0
c01026b0:	6a 00                	push   $0x0
  pushl $189
c01026b2:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01026b7:	e9 18 03 00 00       	jmp    c01029d4 <__alltraps>

c01026bc <vector190>:
.globl vector190
vector190:
  pushl $0
c01026bc:	6a 00                	push   $0x0
  pushl $190
c01026be:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01026c3:	e9 0c 03 00 00       	jmp    c01029d4 <__alltraps>

c01026c8 <vector191>:
.globl vector191
vector191:
  pushl $0
c01026c8:	6a 00                	push   $0x0
  pushl $191
c01026ca:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01026cf:	e9 00 03 00 00       	jmp    c01029d4 <__alltraps>

c01026d4 <vector192>:
.globl vector192
vector192:
  pushl $0
c01026d4:	6a 00                	push   $0x0
  pushl $192
c01026d6:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01026db:	e9 f4 02 00 00       	jmp    c01029d4 <__alltraps>

c01026e0 <vector193>:
.globl vector193
vector193:
  pushl $0
c01026e0:	6a 00                	push   $0x0
  pushl $193
c01026e2:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01026e7:	e9 e8 02 00 00       	jmp    c01029d4 <__alltraps>

c01026ec <vector194>:
.globl vector194
vector194:
  pushl $0
c01026ec:	6a 00                	push   $0x0
  pushl $194
c01026ee:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01026f3:	e9 dc 02 00 00       	jmp    c01029d4 <__alltraps>

c01026f8 <vector195>:
.globl vector195
vector195:
  pushl $0
c01026f8:	6a 00                	push   $0x0
  pushl $195
c01026fa:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01026ff:	e9 d0 02 00 00       	jmp    c01029d4 <__alltraps>

c0102704 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102704:	6a 00                	push   $0x0
  pushl $196
c0102706:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010270b:	e9 c4 02 00 00       	jmp    c01029d4 <__alltraps>

c0102710 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102710:	6a 00                	push   $0x0
  pushl $197
c0102712:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102717:	e9 b8 02 00 00       	jmp    c01029d4 <__alltraps>

c010271c <vector198>:
.globl vector198
vector198:
  pushl $0
c010271c:	6a 00                	push   $0x0
  pushl $198
c010271e:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102723:	e9 ac 02 00 00       	jmp    c01029d4 <__alltraps>

c0102728 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102728:	6a 00                	push   $0x0
  pushl $199
c010272a:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010272f:	e9 a0 02 00 00       	jmp    c01029d4 <__alltraps>

c0102734 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102734:	6a 00                	push   $0x0
  pushl $200
c0102736:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010273b:	e9 94 02 00 00       	jmp    c01029d4 <__alltraps>

c0102740 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102740:	6a 00                	push   $0x0
  pushl $201
c0102742:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102747:	e9 88 02 00 00       	jmp    c01029d4 <__alltraps>

c010274c <vector202>:
.globl vector202
vector202:
  pushl $0
c010274c:	6a 00                	push   $0x0
  pushl $202
c010274e:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102753:	e9 7c 02 00 00       	jmp    c01029d4 <__alltraps>

c0102758 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102758:	6a 00                	push   $0x0
  pushl $203
c010275a:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010275f:	e9 70 02 00 00       	jmp    c01029d4 <__alltraps>

c0102764 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102764:	6a 00                	push   $0x0
  pushl $204
c0102766:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010276b:	e9 64 02 00 00       	jmp    c01029d4 <__alltraps>

c0102770 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102770:	6a 00                	push   $0x0
  pushl $205
c0102772:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102777:	e9 58 02 00 00       	jmp    c01029d4 <__alltraps>

c010277c <vector206>:
.globl vector206
vector206:
  pushl $0
c010277c:	6a 00                	push   $0x0
  pushl $206
c010277e:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102783:	e9 4c 02 00 00       	jmp    c01029d4 <__alltraps>

c0102788 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102788:	6a 00                	push   $0x0
  pushl $207
c010278a:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010278f:	e9 40 02 00 00       	jmp    c01029d4 <__alltraps>

c0102794 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102794:	6a 00                	push   $0x0
  pushl $208
c0102796:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010279b:	e9 34 02 00 00       	jmp    c01029d4 <__alltraps>

c01027a0 <vector209>:
.globl vector209
vector209:
  pushl $0
c01027a0:	6a 00                	push   $0x0
  pushl $209
c01027a2:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01027a7:	e9 28 02 00 00       	jmp    c01029d4 <__alltraps>

c01027ac <vector210>:
.globl vector210
vector210:
  pushl $0
c01027ac:	6a 00                	push   $0x0
  pushl $210
c01027ae:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01027b3:	e9 1c 02 00 00       	jmp    c01029d4 <__alltraps>

c01027b8 <vector211>:
.globl vector211
vector211:
  pushl $0
c01027b8:	6a 00                	push   $0x0
  pushl $211
c01027ba:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01027bf:	e9 10 02 00 00       	jmp    c01029d4 <__alltraps>

c01027c4 <vector212>:
.globl vector212
vector212:
  pushl $0
c01027c4:	6a 00                	push   $0x0
  pushl $212
c01027c6:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01027cb:	e9 04 02 00 00       	jmp    c01029d4 <__alltraps>

c01027d0 <vector213>:
.globl vector213
vector213:
  pushl $0
c01027d0:	6a 00                	push   $0x0
  pushl $213
c01027d2:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01027d7:	e9 f8 01 00 00       	jmp    c01029d4 <__alltraps>

c01027dc <vector214>:
.globl vector214
vector214:
  pushl $0
c01027dc:	6a 00                	push   $0x0
  pushl $214
c01027de:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01027e3:	e9 ec 01 00 00       	jmp    c01029d4 <__alltraps>

c01027e8 <vector215>:
.globl vector215
vector215:
  pushl $0
c01027e8:	6a 00                	push   $0x0
  pushl $215
c01027ea:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01027ef:	e9 e0 01 00 00       	jmp    c01029d4 <__alltraps>

c01027f4 <vector216>:
.globl vector216
vector216:
  pushl $0
c01027f4:	6a 00                	push   $0x0
  pushl $216
c01027f6:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01027fb:	e9 d4 01 00 00       	jmp    c01029d4 <__alltraps>

c0102800 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102800:	6a 00                	push   $0x0
  pushl $217
c0102802:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102807:	e9 c8 01 00 00       	jmp    c01029d4 <__alltraps>

c010280c <vector218>:
.globl vector218
vector218:
  pushl $0
c010280c:	6a 00                	push   $0x0
  pushl $218
c010280e:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102813:	e9 bc 01 00 00       	jmp    c01029d4 <__alltraps>

c0102818 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102818:	6a 00                	push   $0x0
  pushl $219
c010281a:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010281f:	e9 b0 01 00 00       	jmp    c01029d4 <__alltraps>

c0102824 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102824:	6a 00                	push   $0x0
  pushl $220
c0102826:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010282b:	e9 a4 01 00 00       	jmp    c01029d4 <__alltraps>

c0102830 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102830:	6a 00                	push   $0x0
  pushl $221
c0102832:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102837:	e9 98 01 00 00       	jmp    c01029d4 <__alltraps>

c010283c <vector222>:
.globl vector222
vector222:
  pushl $0
c010283c:	6a 00                	push   $0x0
  pushl $222
c010283e:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102843:	e9 8c 01 00 00       	jmp    c01029d4 <__alltraps>

c0102848 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102848:	6a 00                	push   $0x0
  pushl $223
c010284a:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010284f:	e9 80 01 00 00       	jmp    c01029d4 <__alltraps>

c0102854 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102854:	6a 00                	push   $0x0
  pushl $224
c0102856:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010285b:	e9 74 01 00 00       	jmp    c01029d4 <__alltraps>

c0102860 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102860:	6a 00                	push   $0x0
  pushl $225
c0102862:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102867:	e9 68 01 00 00       	jmp    c01029d4 <__alltraps>

c010286c <vector226>:
.globl vector226
vector226:
  pushl $0
c010286c:	6a 00                	push   $0x0
  pushl $226
c010286e:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102873:	e9 5c 01 00 00       	jmp    c01029d4 <__alltraps>

c0102878 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102878:	6a 00                	push   $0x0
  pushl $227
c010287a:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010287f:	e9 50 01 00 00       	jmp    c01029d4 <__alltraps>

c0102884 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102884:	6a 00                	push   $0x0
  pushl $228
c0102886:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010288b:	e9 44 01 00 00       	jmp    c01029d4 <__alltraps>

c0102890 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102890:	6a 00                	push   $0x0
  pushl $229
c0102892:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102897:	e9 38 01 00 00       	jmp    c01029d4 <__alltraps>

c010289c <vector230>:
.globl vector230
vector230:
  pushl $0
c010289c:	6a 00                	push   $0x0
  pushl $230
c010289e:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01028a3:	e9 2c 01 00 00       	jmp    c01029d4 <__alltraps>

c01028a8 <vector231>:
.globl vector231
vector231:
  pushl $0
c01028a8:	6a 00                	push   $0x0
  pushl $231
c01028aa:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01028af:	e9 20 01 00 00       	jmp    c01029d4 <__alltraps>

c01028b4 <vector232>:
.globl vector232
vector232:
  pushl $0
c01028b4:	6a 00                	push   $0x0
  pushl $232
c01028b6:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01028bb:	e9 14 01 00 00       	jmp    c01029d4 <__alltraps>

c01028c0 <vector233>:
.globl vector233
vector233:
  pushl $0
c01028c0:	6a 00                	push   $0x0
  pushl $233
c01028c2:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01028c7:	e9 08 01 00 00       	jmp    c01029d4 <__alltraps>

c01028cc <vector234>:
.globl vector234
vector234:
  pushl $0
c01028cc:	6a 00                	push   $0x0
  pushl $234
c01028ce:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01028d3:	e9 fc 00 00 00       	jmp    c01029d4 <__alltraps>

c01028d8 <vector235>:
.globl vector235
vector235:
  pushl $0
c01028d8:	6a 00                	push   $0x0
  pushl $235
c01028da:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01028df:	e9 f0 00 00 00       	jmp    c01029d4 <__alltraps>

c01028e4 <vector236>:
.globl vector236
vector236:
  pushl $0
c01028e4:	6a 00                	push   $0x0
  pushl $236
c01028e6:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01028eb:	e9 e4 00 00 00       	jmp    c01029d4 <__alltraps>

c01028f0 <vector237>:
.globl vector237
vector237:
  pushl $0
c01028f0:	6a 00                	push   $0x0
  pushl $237
c01028f2:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01028f7:	e9 d8 00 00 00       	jmp    c01029d4 <__alltraps>

c01028fc <vector238>:
.globl vector238
vector238:
  pushl $0
c01028fc:	6a 00                	push   $0x0
  pushl $238
c01028fe:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102903:	e9 cc 00 00 00       	jmp    c01029d4 <__alltraps>

c0102908 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102908:	6a 00                	push   $0x0
  pushl $239
c010290a:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010290f:	e9 c0 00 00 00       	jmp    c01029d4 <__alltraps>

c0102914 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102914:	6a 00                	push   $0x0
  pushl $240
c0102916:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010291b:	e9 b4 00 00 00       	jmp    c01029d4 <__alltraps>

c0102920 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102920:	6a 00                	push   $0x0
  pushl $241
c0102922:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102927:	e9 a8 00 00 00       	jmp    c01029d4 <__alltraps>

c010292c <vector242>:
.globl vector242
vector242:
  pushl $0
c010292c:	6a 00                	push   $0x0
  pushl $242
c010292e:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102933:	e9 9c 00 00 00       	jmp    c01029d4 <__alltraps>

c0102938 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102938:	6a 00                	push   $0x0
  pushl $243
c010293a:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010293f:	e9 90 00 00 00       	jmp    c01029d4 <__alltraps>

c0102944 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102944:	6a 00                	push   $0x0
  pushl $244
c0102946:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010294b:	e9 84 00 00 00       	jmp    c01029d4 <__alltraps>

c0102950 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102950:	6a 00                	push   $0x0
  pushl $245
c0102952:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102957:	e9 78 00 00 00       	jmp    c01029d4 <__alltraps>

c010295c <vector246>:
.globl vector246
vector246:
  pushl $0
c010295c:	6a 00                	push   $0x0
  pushl $246
c010295e:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102963:	e9 6c 00 00 00       	jmp    c01029d4 <__alltraps>

c0102968 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102968:	6a 00                	push   $0x0
  pushl $247
c010296a:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010296f:	e9 60 00 00 00       	jmp    c01029d4 <__alltraps>

c0102974 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102974:	6a 00                	push   $0x0
  pushl $248
c0102976:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010297b:	e9 54 00 00 00       	jmp    c01029d4 <__alltraps>

c0102980 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102980:	6a 00                	push   $0x0
  pushl $249
c0102982:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102987:	e9 48 00 00 00       	jmp    c01029d4 <__alltraps>

c010298c <vector250>:
.globl vector250
vector250:
  pushl $0
c010298c:	6a 00                	push   $0x0
  pushl $250
c010298e:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102993:	e9 3c 00 00 00       	jmp    c01029d4 <__alltraps>

c0102998 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102998:	6a 00                	push   $0x0
  pushl $251
c010299a:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010299f:	e9 30 00 00 00       	jmp    c01029d4 <__alltraps>

c01029a4 <vector252>:
.globl vector252
vector252:
  pushl $0
c01029a4:	6a 00                	push   $0x0
  pushl $252
c01029a6:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01029ab:	e9 24 00 00 00       	jmp    c01029d4 <__alltraps>

c01029b0 <vector253>:
.globl vector253
vector253:
  pushl $0
c01029b0:	6a 00                	push   $0x0
  pushl $253
c01029b2:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01029b7:	e9 18 00 00 00       	jmp    c01029d4 <__alltraps>

c01029bc <vector254>:
.globl vector254
vector254:
  pushl $0
c01029bc:	6a 00                	push   $0x0
  pushl $254
c01029be:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01029c3:	e9 0c 00 00 00       	jmp    c01029d4 <__alltraps>

c01029c8 <vector255>:
.globl vector255
vector255:
  pushl $0
c01029c8:	6a 00                	push   $0x0
  pushl $255
c01029ca:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01029cf:	e9 00 00 00 00       	jmp    c01029d4 <__alltraps>

c01029d4 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01029d4:	1e                   	push   %ds
    pushl %es
c01029d5:	06                   	push   %es
    pushl %fs
c01029d6:	0f a0                	push   %fs
    pushl %gs
c01029d8:	0f a8                	push   %gs
    pushal
c01029da:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01029db:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01029e0:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01029e2:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01029e4:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01029e5:	e8 64 f5 ff ff       	call   c0101f4e <trap>

    # pop the pushed stack pointer
    popl %esp
c01029ea:	5c                   	pop    %esp

c01029eb <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01029eb:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01029ec:	0f a9                	pop    %gs
    popl %fs
c01029ee:	0f a1                	pop    %fs
    popl %es
c01029f0:	07                   	pop    %es
    popl %ds
c01029f1:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01029f2:	83 c4 08             	add    $0x8,%esp
    iret
c01029f5:	cf                   	iret   

c01029f6 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01029f6:	55                   	push   %ebp
c01029f7:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01029f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01029fc:	8b 15 78 af 11 c0    	mov    0xc011af78,%edx
c0102a02:	29 d0                	sub    %edx,%eax
c0102a04:	c1 f8 02             	sar    $0x2,%eax
c0102a07:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102a0d:	5d                   	pop    %ebp
c0102a0e:	c3                   	ret    

c0102a0f <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102a0f:	55                   	push   %ebp
c0102a10:	89 e5                	mov    %esp,%ebp
c0102a12:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a18:	89 04 24             	mov    %eax,(%esp)
c0102a1b:	e8 d6 ff ff ff       	call   c01029f6 <page2ppn>
c0102a20:	c1 e0 0c             	shl    $0xc,%eax
}
c0102a23:	c9                   	leave  
c0102a24:	c3                   	ret    

c0102a25 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102a25:	55                   	push   %ebp
c0102a26:	89 e5                	mov    %esp,%ebp
c0102a28:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102a2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a2e:	c1 e8 0c             	shr    $0xc,%eax
c0102a31:	89 c2                	mov    %eax,%edx
c0102a33:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102a38:	39 c2                	cmp    %eax,%edx
c0102a3a:	72 1c                	jb     c0102a58 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102a3c:	c7 44 24 08 10 68 10 	movl   $0xc0106810,0x8(%esp)
c0102a43:	c0 
c0102a44:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102a4b:	00 
c0102a4c:	c7 04 24 2f 68 10 c0 	movl   $0xc010682f,(%esp)
c0102a53:	e8 91 d9 ff ff       	call   c01003e9 <__panic>
    }
    return &pages[PPN(pa)];
c0102a58:	8b 0d 78 af 11 c0    	mov    0xc011af78,%ecx
c0102a5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a61:	c1 e8 0c             	shr    $0xc,%eax
c0102a64:	89 c2                	mov    %eax,%edx
c0102a66:	89 d0                	mov    %edx,%eax
c0102a68:	c1 e0 02             	shl    $0x2,%eax
c0102a6b:	01 d0                	add    %edx,%eax
c0102a6d:	c1 e0 02             	shl    $0x2,%eax
c0102a70:	01 c8                	add    %ecx,%eax
}
c0102a72:	c9                   	leave  
c0102a73:	c3                   	ret    

c0102a74 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102a74:	55                   	push   %ebp
c0102a75:	89 e5                	mov    %esp,%ebp
c0102a77:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102a7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a7d:	89 04 24             	mov    %eax,(%esp)
c0102a80:	e8 8a ff ff ff       	call   c0102a0f <page2pa>
c0102a85:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a8b:	c1 e8 0c             	shr    $0xc,%eax
c0102a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102a91:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102a96:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102a99:	72 23                	jb     c0102abe <page2kva+0x4a>
c0102a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102aa2:	c7 44 24 08 40 68 10 	movl   $0xc0106840,0x8(%esp)
c0102aa9:	c0 
c0102aaa:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0102ab1:	00 
c0102ab2:	c7 04 24 2f 68 10 c0 	movl   $0xc010682f,(%esp)
c0102ab9:	e8 2b d9 ff ff       	call   c01003e9 <__panic>
c0102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ac1:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102ac6:	c9                   	leave  
c0102ac7:	c3                   	ret    

c0102ac8 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102ac8:	55                   	push   %ebp
c0102ac9:	89 e5                	mov    %esp,%ebp
c0102acb:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102ace:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ad1:	83 e0 01             	and    $0x1,%eax
c0102ad4:	85 c0                	test   %eax,%eax
c0102ad6:	75 1c                	jne    c0102af4 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102ad8:	c7 44 24 08 64 68 10 	movl   $0xc0106864,0x8(%esp)
c0102adf:	c0 
c0102ae0:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0102ae7:	00 
c0102ae8:	c7 04 24 2f 68 10 c0 	movl   $0xc010682f,(%esp)
c0102aef:	e8 f5 d8 ff ff       	call   c01003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102af4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102af7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102afc:	89 04 24             	mov    %eax,(%esp)
c0102aff:	e8 21 ff ff ff       	call   c0102a25 <pa2page>
}
c0102b04:	c9                   	leave  
c0102b05:	c3                   	ret    

c0102b06 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102b06:	55                   	push   %ebp
c0102b07:	89 e5                	mov    %esp,%ebp
c0102b09:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102b0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102b14:	89 04 24             	mov    %eax,(%esp)
c0102b17:	e8 09 ff ff ff       	call   c0102a25 <pa2page>
}
c0102b1c:	c9                   	leave  
c0102b1d:	c3                   	ret    

c0102b1e <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102b1e:	55                   	push   %ebp
c0102b1f:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102b21:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b24:	8b 00                	mov    (%eax),%eax
}
c0102b26:	5d                   	pop    %ebp
c0102b27:	c3                   	ret    

c0102b28 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102b28:	55                   	push   %ebp
c0102b29:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b31:	89 10                	mov    %edx,(%eax)
}
c0102b33:	90                   	nop
c0102b34:	5d                   	pop    %ebp
c0102b35:	c3                   	ret    

c0102b36 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102b36:	55                   	push   %ebp
c0102b37:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102b39:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b3c:	8b 00                	mov    (%eax),%eax
c0102b3e:	8d 50 01             	lea    0x1(%eax),%edx
c0102b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b44:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102b46:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b49:	8b 00                	mov    (%eax),%eax
}
c0102b4b:	5d                   	pop    %ebp
c0102b4c:	c3                   	ret    

c0102b4d <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102b4d:	55                   	push   %ebp
c0102b4e:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b53:	8b 00                	mov    (%eax),%eax
c0102b55:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b5b:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102b5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b60:	8b 00                	mov    (%eax),%eax
}
c0102b62:	5d                   	pop    %ebp
c0102b63:	c3                   	ret    

c0102b64 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0102b64:	55                   	push   %ebp
c0102b65:	89 e5                	mov    %esp,%ebp
c0102b67:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102b6a:	9c                   	pushf  
c0102b6b:	58                   	pop    %eax
c0102b6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102b72:	25 00 02 00 00       	and    $0x200,%eax
c0102b77:	85 c0                	test   %eax,%eax
c0102b79:	74 0c                	je     c0102b87 <__intr_save+0x23>
        intr_disable();
c0102b7b:	e8 f9 ec ff ff       	call   c0101879 <intr_disable>
        return 1;
c0102b80:	b8 01 00 00 00       	mov    $0x1,%eax
c0102b85:	eb 05                	jmp    c0102b8c <__intr_save+0x28>
    }
    return 0;
c0102b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102b8c:	c9                   	leave  
c0102b8d:	c3                   	ret    

c0102b8e <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0102b8e:	55                   	push   %ebp
c0102b8f:	89 e5                	mov    %esp,%ebp
c0102b91:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102b94:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102b98:	74 05                	je     c0102b9f <__intr_restore+0x11>
        intr_enable();
c0102b9a:	e8 d3 ec ff ff       	call   c0101872 <intr_enable>
    }
}
c0102b9f:	90                   	nop
c0102ba0:	c9                   	leave  
c0102ba1:	c3                   	ret    

c0102ba2 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102ba2:	55                   	push   %ebp
c0102ba3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102ba5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ba8:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102bab:	b8 23 00 00 00       	mov    $0x23,%eax
c0102bb0:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102bb2:	b8 23 00 00 00       	mov    $0x23,%eax
c0102bb7:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102bb9:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bbe:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102bc0:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bc5:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102bc7:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bcc:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102bce:	ea d5 2b 10 c0 08 00 	ljmp   $0x8,$0xc0102bd5
}
c0102bd5:	90                   	nop
c0102bd6:	5d                   	pop    %ebp
c0102bd7:	c3                   	ret    

c0102bd8 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102bd8:	55                   	push   %ebp
c0102bd9:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bde:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0102be3:	90                   	nop
c0102be4:	5d                   	pop    %ebp
c0102be5:	c3                   	ret    

c0102be6 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102be6:	55                   	push   %ebp
c0102be7:	89 e5                	mov    %esp,%ebp
c0102be9:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102bec:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0102bf1:	89 04 24             	mov    %eax,(%esp)
c0102bf4:	e8 df ff ff ff       	call   c0102bd8 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102bf9:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0102c00:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102c02:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0102c09:	68 00 
c0102c0b:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102c10:	0f b7 c0             	movzwl %ax,%eax
c0102c13:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0102c19:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102c1e:	c1 e8 10             	shr    $0x10,%eax
c0102c21:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0102c26:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102c2d:	24 f0                	and    $0xf0,%al
c0102c2f:	0c 09                	or     $0x9,%al
c0102c31:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102c36:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102c3d:	24 ef                	and    $0xef,%al
c0102c3f:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102c44:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102c4b:	24 9f                	and    $0x9f,%al
c0102c4d:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102c52:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102c59:	0c 80                	or     $0x80,%al
c0102c5b:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102c60:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c67:	24 f0                	and    $0xf0,%al
c0102c69:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102c6e:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c75:	24 ef                	and    $0xef,%al
c0102c77:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102c7c:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c83:	24 df                	and    $0xdf,%al
c0102c85:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102c8a:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c91:	0c 40                	or     $0x40,%al
c0102c93:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102c98:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c9f:	24 7f                	and    $0x7f,%al
c0102ca1:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102ca6:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102cab:	c1 e8 18             	shr    $0x18,%eax
c0102cae:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102cb3:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0102cba:	e8 e3 fe ff ff       	call   c0102ba2 <lgdt>
c0102cbf:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102cc5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102cc9:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102ccc:	90                   	nop
c0102ccd:	c9                   	leave  
c0102cce:	c3                   	ret    

c0102ccf <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102ccf:	55                   	push   %ebp
c0102cd0:	89 e5                	mov    %esp,%ebp
c0102cd2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102cd5:	c7 05 70 af 11 c0 08 	movl   $0xc0107208,0xc011af70
c0102cdc:	72 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102cdf:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c0102ce4:	8b 00                	mov    (%eax),%eax
c0102ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102cea:	c7 04 24 90 68 10 c0 	movl   $0xc0106890,(%esp)
c0102cf1:	e8 9c d5 ff ff       	call   c0100292 <cprintf>
    pmm_manager->init();
c0102cf6:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c0102cfb:	8b 40 04             	mov    0x4(%eax),%eax
c0102cfe:	ff d0                	call   *%eax
}
c0102d00:	90                   	nop
c0102d01:	c9                   	leave  
c0102d02:	c3                   	ret    

c0102d03 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102d03:	55                   	push   %ebp
c0102d04:	89 e5                	mov    %esp,%ebp
c0102d06:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102d09:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c0102d0e:	8b 40 08             	mov    0x8(%eax),%eax
c0102d11:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d14:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102d18:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d1b:	89 14 24             	mov    %edx,(%esp)
c0102d1e:	ff d0                	call   *%eax
}
c0102d20:	90                   	nop
c0102d21:	c9                   	leave  
c0102d22:	c3                   	ret    

c0102d23 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102d23:	55                   	push   %ebp
c0102d24:	89 e5                	mov    %esp,%ebp
c0102d26:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102d29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102d30:	e8 2f fe ff ff       	call   c0102b64 <__intr_save>
c0102d35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102d38:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c0102d3d:	8b 40 0c             	mov    0xc(%eax),%eax
c0102d40:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d43:	89 14 24             	mov    %edx,(%esp)
c0102d46:	ff d0                	call   *%eax
c0102d48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d4e:	89 04 24             	mov    %eax,(%esp)
c0102d51:	e8 38 fe ff ff       	call   c0102b8e <__intr_restore>
    return page;
c0102d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102d59:	c9                   	leave  
c0102d5a:	c3                   	ret    

c0102d5b <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102d5b:	55                   	push   %ebp
c0102d5c:	89 e5                	mov    %esp,%ebp
c0102d5e:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102d61:	e8 fe fd ff ff       	call   c0102b64 <__intr_save>
c0102d66:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102d69:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c0102d6e:	8b 40 10             	mov    0x10(%eax),%eax
c0102d71:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d74:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102d78:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d7b:	89 14 24             	mov    %edx,(%esp)
c0102d7e:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d83:	89 04 24             	mov    %eax,(%esp)
c0102d86:	e8 03 fe ff ff       	call   c0102b8e <__intr_restore>
}
c0102d8b:	90                   	nop
c0102d8c:	c9                   	leave  
c0102d8d:	c3                   	ret    

c0102d8e <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102d8e:	55                   	push   %ebp
c0102d8f:	89 e5                	mov    %esp,%ebp
c0102d91:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102d94:	e8 cb fd ff ff       	call   c0102b64 <__intr_save>
c0102d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102d9c:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c0102da1:	8b 40 14             	mov    0x14(%eax),%eax
c0102da4:	ff d0                	call   *%eax
c0102da6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dac:	89 04 24             	mov    %eax,(%esp)
c0102daf:	e8 da fd ff ff       	call   c0102b8e <__intr_restore>
    return ret;
c0102db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102db7:	c9                   	leave  
c0102db8:	c3                   	ret    

c0102db9 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102db9:	55                   	push   %ebp
c0102dba:	89 e5                	mov    %esp,%ebp
c0102dbc:	57                   	push   %edi
c0102dbd:	56                   	push   %esi
c0102dbe:	53                   	push   %ebx
c0102dbf:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102dc5:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102dcc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102dd3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102dda:	c7 04 24 a7 68 10 c0 	movl   $0xc01068a7,(%esp)
c0102de1:	e8 ac d4 ff ff       	call   c0100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102de6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102ded:	e9 22 01 00 00       	jmp    c0102f14 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102df2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102df5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102df8:	89 d0                	mov    %edx,%eax
c0102dfa:	c1 e0 02             	shl    $0x2,%eax
c0102dfd:	01 d0                	add    %edx,%eax
c0102dff:	c1 e0 02             	shl    $0x2,%eax
c0102e02:	01 c8                	add    %ecx,%eax
c0102e04:	8b 50 08             	mov    0x8(%eax),%edx
c0102e07:	8b 40 04             	mov    0x4(%eax),%eax
c0102e0a:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102e0d:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0102e10:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e13:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e16:	89 d0                	mov    %edx,%eax
c0102e18:	c1 e0 02             	shl    $0x2,%eax
c0102e1b:	01 d0                	add    %edx,%eax
c0102e1d:	c1 e0 02             	shl    $0x2,%eax
c0102e20:	01 c8                	add    %ecx,%eax
c0102e22:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e25:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e28:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102e2b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102e2e:	01 c8                	add    %ecx,%eax
c0102e30:	11 da                	adc    %ebx,%edx
c0102e32:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102e35:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102e38:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e3e:	89 d0                	mov    %edx,%eax
c0102e40:	c1 e0 02             	shl    $0x2,%eax
c0102e43:	01 d0                	add    %edx,%eax
c0102e45:	c1 e0 02             	shl    $0x2,%eax
c0102e48:	01 c8                	add    %ecx,%eax
c0102e4a:	83 c0 14             	add    $0x14,%eax
c0102e4d:	8b 00                	mov    (%eax),%eax
c0102e4f:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102e52:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102e55:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102e58:	83 c0 ff             	add    $0xffffffff,%eax
c0102e5b:	83 d2 ff             	adc    $0xffffffff,%edx
c0102e5e:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102e64:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102e6a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e6d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e70:	89 d0                	mov    %edx,%eax
c0102e72:	c1 e0 02             	shl    $0x2,%eax
c0102e75:	01 d0                	add    %edx,%eax
c0102e77:	c1 e0 02             	shl    $0x2,%eax
c0102e7a:	01 c8                	add    %ecx,%eax
c0102e7c:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e7f:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e82:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102e85:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102e89:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102e8f:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102e95:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102e99:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102e9d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ea0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ea7:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102eab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102eaf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102eb3:	c7 04 24 b4 68 10 c0 	movl   $0xc01068b4,(%esp)
c0102eba:	e8 d3 d3 ff ff       	call   c0100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102ebf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ec2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ec5:	89 d0                	mov    %edx,%eax
c0102ec7:	c1 e0 02             	shl    $0x2,%eax
c0102eca:	01 d0                	add    %edx,%eax
c0102ecc:	c1 e0 02             	shl    $0x2,%eax
c0102ecf:	01 c8                	add    %ecx,%eax
c0102ed1:	83 c0 14             	add    $0x14,%eax
c0102ed4:	8b 00                	mov    (%eax),%eax
c0102ed6:	83 f8 01             	cmp    $0x1,%eax
c0102ed9:	75 36                	jne    c0102f11 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ede:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102ee1:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102ee4:	77 2b                	ja     c0102f11 <page_init+0x158>
c0102ee6:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102ee9:	72 05                	jb     c0102ef0 <page_init+0x137>
c0102eeb:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0102eee:	73 21                	jae    c0102f11 <page_init+0x158>
c0102ef0:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102ef4:	77 1b                	ja     c0102f11 <page_init+0x158>
c0102ef6:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102efa:	72 09                	jb     c0102f05 <page_init+0x14c>
c0102efc:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0102f03:	77 0c                	ja     c0102f11 <page_init+0x158>
                maxpa = end;
c0102f05:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102f08:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102f0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102f0e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102f11:	ff 45 dc             	incl   -0x24(%ebp)
c0102f14:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102f17:	8b 00                	mov    (%eax),%eax
c0102f19:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102f1c:	0f 8f d0 fe ff ff    	jg     c0102df2 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102f22:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f26:	72 1d                	jb     c0102f45 <page_init+0x18c>
c0102f28:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f2c:	77 09                	ja     c0102f37 <page_init+0x17e>
c0102f2e:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102f35:	76 0e                	jbe    c0102f45 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102f37:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102f3e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE; //物理页个数0x7fe0
c0102f45:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102f48:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102f4b:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102f4f:	c1 ea 0c             	shr    $0xc,%edx
c0102f52:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);    //空闲内存开始的虚拟地址0xc011b000
c0102f57:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0102f5e:	b8 88 af 11 c0       	mov    $0xc011af88,%eax
c0102f63:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102f66:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f69:	01 d0                	add    %edx,%eax
c0102f6b:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102f6e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102f71:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f76:	f7 75 ac             	divl   -0x54(%ebp)
c0102f79:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102f7c:	29 d0                	sub    %edx,%eax
c0102f7e:	a3 78 af 11 c0       	mov    %eax,0xc011af78

    for (i = 0; i < npage; i ++) {
c0102f83:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102f8a:	eb 2e                	jmp    c0102fba <page_init+0x201>
        SetPageReserved(pages + i);     //讲全部物理页设为保留页，之后再初始化空闲页标记
c0102f8c:	8b 0d 78 af 11 c0    	mov    0xc011af78,%ecx
c0102f92:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f95:	89 d0                	mov    %edx,%eax
c0102f97:	c1 e0 02             	shl    $0x2,%eax
c0102f9a:	01 d0                	add    %edx,%eax
c0102f9c:	c1 e0 02             	shl    $0x2,%eax
c0102f9f:	01 c8                	add    %ecx,%eax
c0102fa1:	83 c0 04             	add    $0x4,%eax
c0102fa4:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0102fab:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102fae:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102fb1:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102fb4:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE; //物理页个数0x7fe0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);    //空闲内存开始的虚拟地址0xc011b000

    for (i = 0; i < npage; i ++) {
c0102fb7:	ff 45 dc             	incl   -0x24(%ebp)
c0102fba:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102fbd:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102fc2:	39 c2                	cmp    %eax,%edx
c0102fc4:	72 c6                	jb     c0102f8c <page_init+0x1d3>
    }

    //hex(0xc011b000+0x7fe0*20-0xC0000000) = 0x1bad80
    //sizeof(struct Page) = 20
    //PADDR将虚拟地址根据映射机制，转换为物理地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102fc6:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102fcc:	89 d0                	mov    %edx,%eax
c0102fce:	c1 e0 02             	shl    $0x2,%eax
c0102fd1:	01 d0                	add    %edx,%eax
c0102fd3:	c1 e0 02             	shl    $0x2,%eax
c0102fd6:	89 c2                	mov    %eax,%edx
c0102fd8:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0102fdd:	01 d0                	add    %edx,%eax
c0102fdf:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0102fe2:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0102fe9:	77 23                	ja     c010300e <page_init+0x255>
c0102feb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102fee:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ff2:	c7 44 24 08 e4 68 10 	movl   $0xc01068e4,0x8(%esp)
c0102ff9:	c0 
c0102ffa:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0103001:	00 
c0103002:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103009:	e8 db d3 ff ff       	call   c01003e9 <__panic>
c010300e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103011:	05 00 00 00 40       	add    $0x40000000,%eax
c0103016:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103019:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103020:	e9 61 01 00 00       	jmp    c0103186 <page_init+0x3cd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103025:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103028:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010302b:	89 d0                	mov    %edx,%eax
c010302d:	c1 e0 02             	shl    $0x2,%eax
c0103030:	01 d0                	add    %edx,%eax
c0103032:	c1 e0 02             	shl    $0x2,%eax
c0103035:	01 c8                	add    %ecx,%eax
c0103037:	8b 50 08             	mov    0x8(%eax),%edx
c010303a:	8b 40 04             	mov    0x4(%eax),%eax
c010303d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103040:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103043:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103046:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103049:	89 d0                	mov    %edx,%eax
c010304b:	c1 e0 02             	shl    $0x2,%eax
c010304e:	01 d0                	add    %edx,%eax
c0103050:	c1 e0 02             	shl    $0x2,%eax
c0103053:	01 c8                	add    %ecx,%eax
c0103055:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103058:	8b 58 10             	mov    0x10(%eax),%ebx
c010305b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010305e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103061:	01 c8                	add    %ecx,%eax
c0103063:	11 da                	adc    %ebx,%edx
c0103065:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103068:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010306b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010306e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103071:	89 d0                	mov    %edx,%eax
c0103073:	c1 e0 02             	shl    $0x2,%eax
c0103076:	01 d0                	add    %edx,%eax
c0103078:	c1 e0 02             	shl    $0x2,%eax
c010307b:	01 c8                	add    %ecx,%eax
c010307d:	83 c0 14             	add    $0x14,%eax
c0103080:	8b 00                	mov    (%eax),%eax
c0103082:	83 f8 01             	cmp    $0x1,%eax
c0103085:	0f 85 f8 00 00 00    	jne    c0103183 <page_init+0x3ca>
            if (begin < freemem) {
c010308b:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010308e:	ba 00 00 00 00       	mov    $0x0,%edx
c0103093:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0103096:	72 17                	jb     c01030af <page_init+0x2f6>
c0103098:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010309b:	77 05                	ja     c01030a2 <page_init+0x2e9>
c010309d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01030a0:	76 0d                	jbe    c01030af <page_init+0x2f6>
                begin = freemem;
c01030a2:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01030a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030a8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01030af:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030b3:	72 1d                	jb     c01030d2 <page_init+0x319>
c01030b5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030b9:	77 09                	ja     c01030c4 <page_init+0x30b>
c01030bb:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01030c2:	76 0e                	jbe    c01030d2 <page_init+0x319>
                end = KMEMSIZE;
c01030c4:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01030cb:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01030d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01030d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01030d8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01030db:	0f 87 a2 00 00 00    	ja     c0103183 <page_init+0x3ca>
c01030e1:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01030e4:	72 09                	jb     c01030ef <page_init+0x336>
c01030e6:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01030e9:	0f 83 94 00 00 00    	jae    c0103183 <page_init+0x3ca>
                begin = ROUNDUP(begin, PGSIZE);
c01030ef:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01030f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01030f9:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01030fc:	01 d0                	add    %edx,%eax
c01030fe:	48                   	dec    %eax
c01030ff:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103102:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103105:	ba 00 00 00 00       	mov    $0x0,%edx
c010310a:	f7 75 9c             	divl   -0x64(%ebp)
c010310d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103110:	29 d0                	sub    %edx,%eax
c0103112:	ba 00 00 00 00       	mov    $0x0,%edx
c0103117:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010311a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010311d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103120:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103123:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103126:	ba 00 00 00 00       	mov    $0x0,%edx
c010312b:	89 c3                	mov    %eax,%ebx
c010312d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0103133:	89 de                	mov    %ebx,%esi
c0103135:	89 d0                	mov    %edx,%eax
c0103137:	83 e0 00             	and    $0x0,%eax
c010313a:	89 c7                	mov    %eax,%edi
c010313c:	89 75 c8             	mov    %esi,-0x38(%ebp)
c010313f:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0103142:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103145:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103148:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010314b:	77 36                	ja     c0103183 <page_init+0x3ca>
c010314d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103150:	72 05                	jb     c0103157 <page_init+0x39e>
c0103152:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103155:	73 2c                	jae    c0103183 <page_init+0x3ca>
                    //pa2page，根据当前物理地址，得到对应维护页的虚拟地址，即page结构体的虚拟地址
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103157:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010315a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010315d:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103160:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0103163:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103167:	c1 ea 0c             	shr    $0xc,%edx
c010316a:	89 c3                	mov    %eax,%ebx
c010316c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010316f:	89 04 24             	mov    %eax,(%esp)
c0103172:	e8 ae f8 ff ff       	call   c0102a25 <pa2page>
c0103177:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010317b:	89 04 24             	mov    %eax,(%esp)
c010317e:	e8 80 fb ff ff       	call   c0102d03 <init_memmap>
    //hex(0xc011b000+0x7fe0*20-0xC0000000) = 0x1bad80
    //sizeof(struct Page) = 20
    //PADDR将虚拟地址根据映射机制，转换为物理地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0103183:	ff 45 dc             	incl   -0x24(%ebp)
c0103186:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103189:	8b 00                	mov    (%eax),%eax
c010318b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010318e:	0f 8f 91 fe ff ff    	jg     c0103025 <page_init+0x26c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0103194:	90                   	nop
c0103195:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010319b:	5b                   	pop    %ebx
c010319c:	5e                   	pop    %esi
c010319d:	5f                   	pop    %edi
c010319e:	5d                   	pop    %ebp
c010319f:	c3                   	ret    

c01031a0 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01031a0:	55                   	push   %ebp
c01031a1:	89 e5                	mov    %esp,%ebp
c01031a3:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01031a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01031a9:	33 45 14             	xor    0x14(%ebp),%eax
c01031ac:	25 ff 0f 00 00       	and    $0xfff,%eax
c01031b1:	85 c0                	test   %eax,%eax
c01031b3:	74 24                	je     c01031d9 <boot_map_segment+0x39>
c01031b5:	c7 44 24 0c 16 69 10 	movl   $0xc0106916,0xc(%esp)
c01031bc:	c0 
c01031bd:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c01031c4:	c0 
c01031c5:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c01031cc:	00 
c01031cd:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01031d4:	e8 10 d2 ff ff       	call   c01003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01031d9:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01031e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01031e3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01031e8:	89 c2                	mov    %eax,%edx
c01031ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01031ed:	01 c2                	add    %eax,%edx
c01031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031f2:	01 d0                	add    %edx,%eax
c01031f4:	48                   	dec    %eax
c01031f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01031f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031fb:	ba 00 00 00 00       	mov    $0x0,%edx
c0103200:	f7 75 f0             	divl   -0x10(%ebp)
c0103203:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103206:	29 d0                	sub    %edx,%eax
c0103208:	c1 e8 0c             	shr    $0xc,%eax
c010320b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010320e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103211:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103214:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103217:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010321c:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010321f:	8b 45 14             	mov    0x14(%ebp),%eax
c0103222:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103225:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103228:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010322d:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103230:	eb 68                	jmp    c010329a <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103232:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103239:	00 
c010323a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010323d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103241:	8b 45 08             	mov    0x8(%ebp),%eax
c0103244:	89 04 24             	mov    %eax,(%esp)
c0103247:	e8 81 01 00 00       	call   c01033cd <get_pte>
c010324c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010324f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103253:	75 24                	jne    c0103279 <boot_map_segment+0xd9>
c0103255:	c7 44 24 0c 42 69 10 	movl   $0xc0106942,0xc(%esp)
c010325c:	c0 
c010325d:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103264:	c0 
c0103265:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c010326c:	00 
c010326d:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103274:	e8 70 d1 ff ff       	call   c01003e9 <__panic>
        *ptep = pa | PTE_P | perm;
c0103279:	8b 45 14             	mov    0x14(%ebp),%eax
c010327c:	0b 45 18             	or     0x18(%ebp),%eax
c010327f:	83 c8 01             	or     $0x1,%eax
c0103282:	89 c2                	mov    %eax,%edx
c0103284:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103287:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103289:	ff 4d f4             	decl   -0xc(%ebp)
c010328c:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103293:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010329a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010329e:	75 92                	jne    c0103232 <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c01032a0:	90                   	nop
c01032a1:	c9                   	leave  
c01032a2:	c3                   	ret    

c01032a3 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01032a3:	55                   	push   %ebp
c01032a4:	89 e5                	mov    %esp,%ebp
c01032a6:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01032a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032b0:	e8 6e fa ff ff       	call   c0102d23 <alloc_pages>
c01032b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01032b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032bc:	75 1c                	jne    c01032da <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01032be:	c7 44 24 08 4f 69 10 	movl   $0xc010694f,0x8(%esp)
c01032c5:	c0 
c01032c6:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01032cd:	00 
c01032ce:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01032d5:	e8 0f d1 ff ff       	call   c01003e9 <__panic>
    }
    return page2kva(p);
c01032da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032dd:	89 04 24             	mov    %eax,(%esp)
c01032e0:	e8 8f f7 ff ff       	call   c0102a74 <page2kva>
}
c01032e5:	c9                   	leave  
c01032e6:	c3                   	ret    

c01032e7 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01032e7:	55                   	push   %ebp
c01032e8:	89 e5                	mov    %esp,%ebp
c01032ea:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01032ed:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01032f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01032f5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01032fc:	77 23                	ja     c0103321 <pmm_init+0x3a>
c01032fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103301:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103305:	c7 44 24 08 e4 68 10 	movl   $0xc01068e4,0x8(%esp)
c010330c:	c0 
c010330d:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0103314:	00 
c0103315:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c010331c:	e8 c8 d0 ff ff       	call   c01003e9 <__panic>
c0103321:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103324:	05 00 00 00 40       	add    $0x40000000,%eax
c0103329:	a3 74 af 11 c0       	mov    %eax,0xc011af74
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager(); //初始化物理内存管理器
c010332e:	e8 9c f9 ff ff       	call   c0102ccf <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();    //根据空间内存初始化每个空闲物理页对应的page结构体
c0103333:	e8 81 fa ff ff       	call   c0102db9 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103338:	e8 de 03 00 00       	call   c010371b <check_alloc_page>

    check_pgdir();
c010333d:	e8 f8 03 00 00       	call   c010373a <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103342:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103347:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c010334d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103352:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103355:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010335c:	77 23                	ja     c0103381 <pmm_init+0x9a>
c010335e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103361:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103365:	c7 44 24 08 e4 68 10 	movl   $0xc01068e4,0x8(%esp)
c010336c:	c0 
c010336d:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103374:	00 
c0103375:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c010337c:	e8 68 d0 ff ff       	call   c01003e9 <__panic>
c0103381:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103384:	05 00 00 00 40       	add    $0x40000000,%eax
c0103389:	83 c8 03             	or     $0x3,%eax
c010338c:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010338e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103393:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010339a:	00 
c010339b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01033a2:	00 
c01033a3:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01033aa:	38 
c01033ab:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01033b2:	c0 
c01033b3:	89 04 24             	mov    %eax,(%esp)
c01033b6:	e8 e5 fd ff ff       	call   c01031a0 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01033bb:	e8 26 f8 ff ff       	call   c0102be6 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01033c0:	e8 11 0a 00 00       	call   c0103dd6 <check_boot_pgdir>

    print_pgdir();
c01033c5:	e8 8a 0e 00 00       	call   c0104254 <print_pgdir>

}
c01033ca:	90                   	nop
c01033cb:	c9                   	leave  
c01033cc:	c3                   	ret    

c01033cd <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01033cd:	55                   	push   %ebp
c01033ce:	89 e5                	mov    %esp,%ebp
c01033d0:	83 ec 38             	sub    $0x38,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
//----------------------------------------------------
    pde_t *pdep = &pgdir[PDX(la)];
c01033d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033d6:	c1 e8 16             	shr    $0x16,%eax
c01033d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01033e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01033e3:	01 d0                	add    %edx,%eax
c01033e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) { //页表项不存在
c01033e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033eb:	8b 00                	mov    (%eax),%eax
c01033ed:	83 e0 01             	and    $0x1,%eax
c01033f0:	85 c0                	test   %eax,%eax
c01033f2:	0f 85 af 00 00 00    	jne    c01034a7 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01033f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01033fc:	74 15                	je     c0103413 <get_pte+0x46>
c01033fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103405:	e8 19 f9 ff ff       	call   c0102d23 <alloc_pages>
c010340a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010340d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103411:	75 0a                	jne    c010341d <get_pte+0x50>
            return NULL;
c0103413:	b8 00 00 00 00       	mov    $0x0,%eax
c0103418:	e9 e7 00 00 00       	jmp    c0103504 <get_pte+0x137>
        }
        set_page_ref(page, 1);
c010341d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103424:	00 
c0103425:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103428:	89 04 24             	mov    %eax,(%esp)
c010342b:	e8 f8 f6 ff ff       	call   c0102b28 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0103430:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103433:	89 04 24             	mov    %eax,(%esp)
c0103436:	e8 d4 f5 ff ff       	call   c0102a0f <page2pa>
c010343b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c010343e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103441:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103444:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103447:	c1 e8 0c             	shr    $0xc,%eax
c010344a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010344d:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103452:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103455:	72 23                	jb     c010347a <get_pte+0xad>
c0103457:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010345a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010345e:	c7 44 24 08 40 68 10 	movl   $0xc0106840,0x8(%esp)
c0103465:	c0 
c0103466:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
c010346d:	00 
c010346e:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103475:	e8 6f cf ff ff       	call   c01003e9 <__panic>
c010347a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010347d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103482:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103489:	00 
c010348a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103491:	00 
c0103492:	89 04 24             	mov    %eax,(%esp)
c0103495:	e8 58 24 00 00       	call   c01058f2 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;     //更新页表内容
c010349a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010349d:	83 c8 07             	or     $0x7,%eax
c01034a0:	89 c2                	mov    %eax,%edx
c01034a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034a5:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01034a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034aa:	8b 00                	mov    (%eax),%eax
c01034ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01034b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01034b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034b7:	c1 e8 0c             	shr    $0xc,%eax
c01034ba:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01034bd:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01034c2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01034c5:	72 23                	jb     c01034ea <get_pte+0x11d>
c01034c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01034ce:	c7 44 24 08 40 68 10 	movl   $0xc0106840,0x8(%esp)
c01034d5:	c0 
c01034d6:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
c01034dd:	00 
c01034de:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01034e5:	e8 ff ce ff ff       	call   c01003e9 <__panic>
c01034ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034ed:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01034f2:	89 c2                	mov    %eax,%edx
c01034f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034f7:	c1 e8 0c             	shr    $0xc,%eax
c01034fa:	25 ff 03 00 00       	and    $0x3ff,%eax
c01034ff:	c1 e0 02             	shl    $0x2,%eax
c0103502:	01 d0                	add    %edx,%eax
//----------------------------------------------------
}
c0103504:	c9                   	leave  
c0103505:	c3                   	ret    

c0103506 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103506:	55                   	push   %ebp
c0103507:	89 e5                	mov    %esp,%ebp
c0103509:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);    //返回页表项
c010350c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103513:	00 
c0103514:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103517:	89 44 24 04          	mov    %eax,0x4(%esp)
c010351b:	8b 45 08             	mov    0x8(%ebp),%eax
c010351e:	89 04 24             	mov    %eax,(%esp)
c0103521:	e8 a7 fe ff ff       	call   c01033cd <get_pte>
c0103526:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103529:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010352d:	74 08                	je     c0103537 <get_page+0x31>
        *ptep_store = ptep;
c010352f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103532:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103535:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103537:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010353b:	74 1b                	je     c0103558 <get_page+0x52>
c010353d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103540:	8b 00                	mov    (%eax),%eax
c0103542:	83 e0 01             	and    $0x1,%eax
c0103545:	85 c0                	test   %eax,%eax
c0103547:	74 0f                	je     c0103558 <get_page+0x52>
        return pte2page(*ptep);
c0103549:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354c:	8b 00                	mov    (%eax),%eax
c010354e:	89 04 24             	mov    %eax,(%esp)
c0103551:	e8 72 f5 ff ff       	call   c0102ac8 <pte2page>
c0103556:	eb 05                	jmp    c010355d <get_page+0x57>
    }
    return NULL;
c0103558:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010355d:	c9                   	leave  
c010355e:	c3                   	ret    

c010355f <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010355f:	55                   	push   %ebp
c0103560:	89 e5                	mov    %esp,%ebp
c0103562:	83 ec 28             	sub    $0x28,%esp
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
//-------------------------------------
    if (*ptep & PTE_P) {
c0103565:	8b 45 10             	mov    0x10(%ebp),%eax
c0103568:	8b 00                	mov    (%eax),%eax
c010356a:	83 e0 01             	and    $0x1,%eax
c010356d:	85 c0                	test   %eax,%eax
c010356f:	74 4d                	je     c01035be <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0103571:	8b 45 10             	mov    0x10(%ebp),%eax
c0103574:	8b 00                	mov    (%eax),%eax
c0103576:	89 04 24             	mov    %eax,(%esp)
c0103579:	e8 4a f5 ff ff       	call   c0102ac8 <pte2page>
c010357e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0103581:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103584:	89 04 24             	mov    %eax,(%esp)
c0103587:	e8 c1 f5 ff ff       	call   c0102b4d <page_ref_dec>
c010358c:	85 c0                	test   %eax,%eax
c010358e:	75 13                	jne    c01035a3 <page_remove_pte+0x44>
            free_page(page);
c0103590:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103597:	00 
c0103598:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010359b:	89 04 24             	mov    %eax,(%esp)
c010359e:	e8 b8 f7 ff ff       	call   c0102d5b <free_pages>
        }
        *ptep = 0;  //清空页表项
c01035a3:	8b 45 10             	mov    0x10(%ebp),%eax
c01035a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01035ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01035b6:	89 04 24             	mov    %eax,(%esp)
c01035b9:	e8 01 01 00 00       	call   c01036bf <tlb_invalidate>
    }
//-------------------------------------
}
c01035be:	90                   	nop
c01035bf:	c9                   	leave  
c01035c0:	c3                   	ret    

c01035c1 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01035c1:	55                   	push   %ebp
c01035c2:	89 e5                	mov    %esp,%ebp
c01035c4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01035c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01035ce:	00 
c01035cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01035d9:	89 04 24             	mov    %eax,(%esp)
c01035dc:	e8 ec fd ff ff       	call   c01033cd <get_pte>
c01035e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01035e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035e8:	74 19                	je     c0103603 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01035ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01035f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01035fb:	89 04 24             	mov    %eax,(%esp)
c01035fe:	e8 5c ff ff ff       	call   c010355f <page_remove_pte>
    }
}
c0103603:	90                   	nop
c0103604:	c9                   	leave  
c0103605:	c3                   	ret    

c0103606 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103606:	55                   	push   %ebp
c0103607:	89 e5                	mov    %esp,%ebp
c0103609:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010360c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103613:	00 
c0103614:	8b 45 10             	mov    0x10(%ebp),%eax
c0103617:	89 44 24 04          	mov    %eax,0x4(%esp)
c010361b:	8b 45 08             	mov    0x8(%ebp),%eax
c010361e:	89 04 24             	mov    %eax,(%esp)
c0103621:	e8 a7 fd ff ff       	call   c01033cd <get_pte>
c0103626:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103629:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010362d:	75 0a                	jne    c0103639 <page_insert+0x33>
        return -E_NO_MEM;
c010362f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103634:	e9 84 00 00 00       	jmp    c01036bd <page_insert+0xb7>
    }
    page_ref_inc(page);
c0103639:	8b 45 0c             	mov    0xc(%ebp),%eax
c010363c:	89 04 24             	mov    %eax,(%esp)
c010363f:	e8 f2 f4 ff ff       	call   c0102b36 <page_ref_inc>
    if (*ptep & PTE_P) {
c0103644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103647:	8b 00                	mov    (%eax),%eax
c0103649:	83 e0 01             	and    $0x1,%eax
c010364c:	85 c0                	test   %eax,%eax
c010364e:	74 3e                	je     c010368e <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0103650:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103653:	8b 00                	mov    (%eax),%eax
c0103655:	89 04 24             	mov    %eax,(%esp)
c0103658:	e8 6b f4 ff ff       	call   c0102ac8 <pte2page>
c010365d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103660:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103663:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103666:	75 0d                	jne    c0103675 <page_insert+0x6f>
            page_ref_dec(page);
c0103668:	8b 45 0c             	mov    0xc(%ebp),%eax
c010366b:	89 04 24             	mov    %eax,(%esp)
c010366e:	e8 da f4 ff ff       	call   c0102b4d <page_ref_dec>
c0103673:	eb 19                	jmp    c010368e <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103675:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103678:	89 44 24 08          	mov    %eax,0x8(%esp)
c010367c:	8b 45 10             	mov    0x10(%ebp),%eax
c010367f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103683:	8b 45 08             	mov    0x8(%ebp),%eax
c0103686:	89 04 24             	mov    %eax,(%esp)
c0103689:	e8 d1 fe ff ff       	call   c010355f <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010368e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103691:	89 04 24             	mov    %eax,(%esp)
c0103694:	e8 76 f3 ff ff       	call   c0102a0f <page2pa>
c0103699:	0b 45 14             	or     0x14(%ebp),%eax
c010369c:	83 c8 01             	or     $0x1,%eax
c010369f:	89 c2                	mov    %eax,%edx
c01036a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a4:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01036a6:	8b 45 10             	mov    0x10(%ebp),%eax
c01036a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01036b0:	89 04 24             	mov    %eax,(%esp)
c01036b3:	e8 07 00 00 00       	call   c01036bf <tlb_invalidate>
    return 0;
c01036b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01036bd:	c9                   	leave  
c01036be:	c3                   	ret    

c01036bf <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01036bf:	55                   	push   %ebp
c01036c0:	89 e5                	mov    %esp,%ebp
c01036c2:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01036c5:	0f 20 d8             	mov    %cr3,%eax
c01036c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c01036cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01036ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036d4:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01036db:	77 23                	ja     c0103700 <tlb_invalidate+0x41>
c01036dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01036e4:	c7 44 24 08 e4 68 10 	movl   $0xc01068e4,0x8(%esp)
c01036eb:	c0 
c01036ec:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
c01036f3:	00 
c01036f4:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01036fb:	e8 e9 cc ff ff       	call   c01003e9 <__panic>
c0103700:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103703:	05 00 00 00 40       	add    $0x40000000,%eax
c0103708:	39 c2                	cmp    %eax,%edx
c010370a:	75 0c                	jne    c0103718 <tlb_invalidate+0x59>
        invlpg((void *)la);
c010370c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010370f:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103712:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103715:	0f 01 38             	invlpg (%eax)
    }
}
c0103718:	90                   	nop
c0103719:	c9                   	leave  
c010371a:	c3                   	ret    

c010371b <check_alloc_page>:

static void
check_alloc_page(void) {
c010371b:	55                   	push   %ebp
c010371c:	89 e5                	mov    %esp,%ebp
c010371e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0103721:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c0103726:	8b 40 18             	mov    0x18(%eax),%eax
c0103729:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010372b:	c7 04 24 68 69 10 c0 	movl   $0xc0106968,(%esp)
c0103732:	e8 5b cb ff ff       	call   c0100292 <cprintf>
}
c0103737:	90                   	nop
c0103738:	c9                   	leave  
c0103739:	c3                   	ret    

c010373a <check_pgdir>:

static void
check_pgdir(void) {
c010373a:	55                   	push   %ebp
c010373b:	89 e5                	mov    %esp,%ebp
c010373d:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0103740:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103745:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010374a:	76 24                	jbe    c0103770 <check_pgdir+0x36>
c010374c:	c7 44 24 0c 87 69 10 	movl   $0xc0106987,0xc(%esp)
c0103753:	c0 
c0103754:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c010375b:	c0 
c010375c:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0103763:	00 
c0103764:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c010376b:	e8 79 cc ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103770:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103775:	85 c0                	test   %eax,%eax
c0103777:	74 0e                	je     c0103787 <check_pgdir+0x4d>
c0103779:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010377e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103783:	85 c0                	test   %eax,%eax
c0103785:	74 24                	je     c01037ab <check_pgdir+0x71>
c0103787:	c7 44 24 0c a4 69 10 	movl   $0xc01069a4,0xc(%esp)
c010378e:	c0 
c010378f:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103796:	c0 
c0103797:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c010379e:	00 
c010379f:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01037a6:	e8 3e cc ff ff       	call   c01003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01037ab:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01037b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037b7:	00 
c01037b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01037bf:	00 
c01037c0:	89 04 24             	mov    %eax,(%esp)
c01037c3:	e8 3e fd ff ff       	call   c0103506 <get_page>
c01037c8:	85 c0                	test   %eax,%eax
c01037ca:	74 24                	je     c01037f0 <check_pgdir+0xb6>
c01037cc:	c7 44 24 0c dc 69 10 	movl   $0xc01069dc,0xc(%esp)
c01037d3:	c0 
c01037d4:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c01037db:	c0 
c01037dc:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c01037e3:	00 
c01037e4:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01037eb:	e8 f9 cb ff ff       	call   c01003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01037f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037f7:	e8 27 f5 ff ff       	call   c0102d23 <alloc_pages>
c01037fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01037ff:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103804:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010380b:	00 
c010380c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103813:	00 
c0103814:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103817:	89 54 24 04          	mov    %edx,0x4(%esp)
c010381b:	89 04 24             	mov    %eax,(%esp)
c010381e:	e8 e3 fd ff ff       	call   c0103606 <page_insert>
c0103823:	85 c0                	test   %eax,%eax
c0103825:	74 24                	je     c010384b <check_pgdir+0x111>
c0103827:	c7 44 24 0c 04 6a 10 	movl   $0xc0106a04,0xc(%esp)
c010382e:	c0 
c010382f:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103836:	c0 
c0103837:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c010383e:	00 
c010383f:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103846:	e8 9e cb ff ff       	call   c01003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010384b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103850:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103857:	00 
c0103858:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010385f:	00 
c0103860:	89 04 24             	mov    %eax,(%esp)
c0103863:	e8 65 fb ff ff       	call   c01033cd <get_pte>
c0103868:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010386b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010386f:	75 24                	jne    c0103895 <check_pgdir+0x15b>
c0103871:	c7 44 24 0c 30 6a 10 	movl   $0xc0106a30,0xc(%esp)
c0103878:	c0 
c0103879:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103880:	c0 
c0103881:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103888:	00 
c0103889:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103890:	e8 54 cb ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103895:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103898:	8b 00                	mov    (%eax),%eax
c010389a:	89 04 24             	mov    %eax,(%esp)
c010389d:	e8 26 f2 ff ff       	call   c0102ac8 <pte2page>
c01038a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01038a5:	74 24                	je     c01038cb <check_pgdir+0x191>
c01038a7:	c7 44 24 0c 5d 6a 10 	movl   $0xc0106a5d,0xc(%esp)
c01038ae:	c0 
c01038af:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c01038b6:	c0 
c01038b7:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c01038be:	00 
c01038bf:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01038c6:	e8 1e cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c01038cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038ce:	89 04 24             	mov    %eax,(%esp)
c01038d1:	e8 48 f2 ff ff       	call   c0102b1e <page_ref>
c01038d6:	83 f8 01             	cmp    $0x1,%eax
c01038d9:	74 24                	je     c01038ff <check_pgdir+0x1c5>
c01038db:	c7 44 24 0c 73 6a 10 	movl   $0xc0106a73,0xc(%esp)
c01038e2:	c0 
c01038e3:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c01038ea:	c0 
c01038eb:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c01038f2:	00 
c01038f3:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01038fa:	e8 ea ca ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01038ff:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103904:	8b 00                	mov    (%eax),%eax
c0103906:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010390b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010390e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103911:	c1 e8 0c             	shr    $0xc,%eax
c0103914:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103917:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010391c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010391f:	72 23                	jb     c0103944 <check_pgdir+0x20a>
c0103921:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103924:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103928:	c7 44 24 08 40 68 10 	movl   $0xc0106840,0x8(%esp)
c010392f:	c0 
c0103930:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103937:	00 
c0103938:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c010393f:	e8 a5 ca ff ff       	call   c01003e9 <__panic>
c0103944:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103947:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010394c:	83 c0 04             	add    $0x4,%eax
c010394f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103952:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103957:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010395e:	00 
c010395f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103966:	00 
c0103967:	89 04 24             	mov    %eax,(%esp)
c010396a:	e8 5e fa ff ff       	call   c01033cd <get_pte>
c010396f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103972:	74 24                	je     c0103998 <check_pgdir+0x25e>
c0103974:	c7 44 24 0c 88 6a 10 	movl   $0xc0106a88,0xc(%esp)
c010397b:	c0 
c010397c:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103983:	c0 
c0103984:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c010398b:	00 
c010398c:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103993:	e8 51 ca ff ff       	call   c01003e9 <__panic>

    p2 = alloc_page();
c0103998:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010399f:	e8 7f f3 ff ff       	call   c0102d23 <alloc_pages>
c01039a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01039a7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01039ac:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01039b3:	00 
c01039b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01039bb:	00 
c01039bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01039bf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01039c3:	89 04 24             	mov    %eax,(%esp)
c01039c6:	e8 3b fc ff ff       	call   c0103606 <page_insert>
c01039cb:	85 c0                	test   %eax,%eax
c01039cd:	74 24                	je     c01039f3 <check_pgdir+0x2b9>
c01039cf:	c7 44 24 0c b0 6a 10 	movl   $0xc0106ab0,0xc(%esp)
c01039d6:	c0 
c01039d7:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c01039de:	c0 
c01039df:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c01039e6:	00 
c01039e7:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01039ee:	e8 f6 c9 ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01039f3:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01039f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01039ff:	00 
c0103a00:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a07:	00 
c0103a08:	89 04 24             	mov    %eax,(%esp)
c0103a0b:	e8 bd f9 ff ff       	call   c01033cd <get_pte>
c0103a10:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a17:	75 24                	jne    c0103a3d <check_pgdir+0x303>
c0103a19:	c7 44 24 0c e8 6a 10 	movl   $0xc0106ae8,0xc(%esp)
c0103a20:	c0 
c0103a21:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103a28:	c0 
c0103a29:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0103a30:	00 
c0103a31:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103a38:	e8 ac c9 ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_U);
c0103a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a40:	8b 00                	mov    (%eax),%eax
c0103a42:	83 e0 04             	and    $0x4,%eax
c0103a45:	85 c0                	test   %eax,%eax
c0103a47:	75 24                	jne    c0103a6d <check_pgdir+0x333>
c0103a49:	c7 44 24 0c 18 6b 10 	movl   $0xc0106b18,0xc(%esp)
c0103a50:	c0 
c0103a51:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103a58:	c0 
c0103a59:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0103a60:	00 
c0103a61:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103a68:	e8 7c c9 ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
c0103a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a70:	8b 00                	mov    (%eax),%eax
c0103a72:	83 e0 02             	and    $0x2,%eax
c0103a75:	85 c0                	test   %eax,%eax
c0103a77:	75 24                	jne    c0103a9d <check_pgdir+0x363>
c0103a79:	c7 44 24 0c 26 6b 10 	movl   $0xc0106b26,0xc(%esp)
c0103a80:	c0 
c0103a81:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103a88:	c0 
c0103a89:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103a90:	00 
c0103a91:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103a98:	e8 4c c9 ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103a9d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103aa2:	8b 00                	mov    (%eax),%eax
c0103aa4:	83 e0 04             	and    $0x4,%eax
c0103aa7:	85 c0                	test   %eax,%eax
c0103aa9:	75 24                	jne    c0103acf <check_pgdir+0x395>
c0103aab:	c7 44 24 0c 34 6b 10 	movl   $0xc0106b34,0xc(%esp)
c0103ab2:	c0 
c0103ab3:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103aba:	c0 
c0103abb:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0103ac2:	00 
c0103ac3:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103aca:	e8 1a c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 1);
c0103acf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ad2:	89 04 24             	mov    %eax,(%esp)
c0103ad5:	e8 44 f0 ff ff       	call   c0102b1e <page_ref>
c0103ada:	83 f8 01             	cmp    $0x1,%eax
c0103add:	74 24                	je     c0103b03 <check_pgdir+0x3c9>
c0103adf:	c7 44 24 0c 4a 6b 10 	movl   $0xc0106b4a,0xc(%esp)
c0103ae6:	c0 
c0103ae7:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103aee:	c0 
c0103aef:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0103af6:	00 
c0103af7:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103afe:	e8 e6 c8 ff ff       	call   c01003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103b03:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103b0f:	00 
c0103b10:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103b17:	00 
c0103b18:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b1b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b1f:	89 04 24             	mov    %eax,(%esp)
c0103b22:	e8 df fa ff ff       	call   c0103606 <page_insert>
c0103b27:	85 c0                	test   %eax,%eax
c0103b29:	74 24                	je     c0103b4f <check_pgdir+0x415>
c0103b2b:	c7 44 24 0c 5c 6b 10 	movl   $0xc0106b5c,0xc(%esp)
c0103b32:	c0 
c0103b33:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103b3a:	c0 
c0103b3b:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103b42:	00 
c0103b43:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103b4a:	e8 9a c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c0103b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b52:	89 04 24             	mov    %eax,(%esp)
c0103b55:	e8 c4 ef ff ff       	call   c0102b1e <page_ref>
c0103b5a:	83 f8 02             	cmp    $0x2,%eax
c0103b5d:	74 24                	je     c0103b83 <check_pgdir+0x449>
c0103b5f:	c7 44 24 0c 88 6b 10 	movl   $0xc0106b88,0xc(%esp)
c0103b66:	c0 
c0103b67:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103b6e:	c0 
c0103b6f:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0103b76:	00 
c0103b77:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103b7e:	e8 66 c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b86:	89 04 24             	mov    %eax,(%esp)
c0103b89:	e8 90 ef ff ff       	call   c0102b1e <page_ref>
c0103b8e:	85 c0                	test   %eax,%eax
c0103b90:	74 24                	je     c0103bb6 <check_pgdir+0x47c>
c0103b92:	c7 44 24 0c 9a 6b 10 	movl   $0xc0106b9a,0xc(%esp)
c0103b99:	c0 
c0103b9a:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103ba1:	c0 
c0103ba2:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0103ba9:	00 
c0103baa:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103bb1:	e8 33 c8 ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103bb6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103bbb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103bc2:	00 
c0103bc3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103bca:	00 
c0103bcb:	89 04 24             	mov    %eax,(%esp)
c0103bce:	e8 fa f7 ff ff       	call   c01033cd <get_pte>
c0103bd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103bd6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103bda:	75 24                	jne    c0103c00 <check_pgdir+0x4c6>
c0103bdc:	c7 44 24 0c e8 6a 10 	movl   $0xc0106ae8,0xc(%esp)
c0103be3:	c0 
c0103be4:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103beb:	c0 
c0103bec:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103bf3:	00 
c0103bf4:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103bfb:	e8 e9 c7 ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c03:	8b 00                	mov    (%eax),%eax
c0103c05:	89 04 24             	mov    %eax,(%esp)
c0103c08:	e8 bb ee ff ff       	call   c0102ac8 <pte2page>
c0103c0d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103c10:	74 24                	je     c0103c36 <check_pgdir+0x4fc>
c0103c12:	c7 44 24 0c 5d 6a 10 	movl   $0xc0106a5d,0xc(%esp)
c0103c19:	c0 
c0103c1a:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103c21:	c0 
c0103c22:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0103c29:	00 
c0103c2a:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103c31:	e8 b3 c7 ff ff       	call   c01003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c39:	8b 00                	mov    (%eax),%eax
c0103c3b:	83 e0 04             	and    $0x4,%eax
c0103c3e:	85 c0                	test   %eax,%eax
c0103c40:	74 24                	je     c0103c66 <check_pgdir+0x52c>
c0103c42:	c7 44 24 0c ac 6b 10 	movl   $0xc0106bac,0xc(%esp)
c0103c49:	c0 
c0103c4a:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103c51:	c0 
c0103c52:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103c59:	00 
c0103c5a:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103c61:	e8 83 c7 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103c66:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103c72:	00 
c0103c73:	89 04 24             	mov    %eax,(%esp)
c0103c76:	e8 46 f9 ff ff       	call   c01035c1 <page_remove>
    assert(page_ref(p1) == 1);
c0103c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c7e:	89 04 24             	mov    %eax,(%esp)
c0103c81:	e8 98 ee ff ff       	call   c0102b1e <page_ref>
c0103c86:	83 f8 01             	cmp    $0x1,%eax
c0103c89:	74 24                	je     c0103caf <check_pgdir+0x575>
c0103c8b:	c7 44 24 0c 73 6a 10 	movl   $0xc0106a73,0xc(%esp)
c0103c92:	c0 
c0103c93:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103c9a:	c0 
c0103c9b:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0103ca2:	00 
c0103ca3:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103caa:	e8 3a c7 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103caf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103cb2:	89 04 24             	mov    %eax,(%esp)
c0103cb5:	e8 64 ee ff ff       	call   c0102b1e <page_ref>
c0103cba:	85 c0                	test   %eax,%eax
c0103cbc:	74 24                	je     c0103ce2 <check_pgdir+0x5a8>
c0103cbe:	c7 44 24 0c 9a 6b 10 	movl   $0xc0106b9a,0xc(%esp)
c0103cc5:	c0 
c0103cc6:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103ccd:	c0 
c0103cce:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0103cd5:	00 
c0103cd6:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103cdd:	e8 07 c7 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103ce2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ce7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103cee:	00 
c0103cef:	89 04 24             	mov    %eax,(%esp)
c0103cf2:	e8 ca f8 ff ff       	call   c01035c1 <page_remove>
    assert(page_ref(p1) == 0);
c0103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cfa:	89 04 24             	mov    %eax,(%esp)
c0103cfd:	e8 1c ee ff ff       	call   c0102b1e <page_ref>
c0103d02:	85 c0                	test   %eax,%eax
c0103d04:	74 24                	je     c0103d2a <check_pgdir+0x5f0>
c0103d06:	c7 44 24 0c c1 6b 10 	movl   $0xc0106bc1,0xc(%esp)
c0103d0d:	c0 
c0103d0e:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103d15:	c0 
c0103d16:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0103d1d:	00 
c0103d1e:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103d25:	e8 bf c6 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103d2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d2d:	89 04 24             	mov    %eax,(%esp)
c0103d30:	e8 e9 ed ff ff       	call   c0102b1e <page_ref>
c0103d35:	85 c0                	test   %eax,%eax
c0103d37:	74 24                	je     c0103d5d <check_pgdir+0x623>
c0103d39:	c7 44 24 0c 9a 6b 10 	movl   $0xc0106b9a,0xc(%esp)
c0103d40:	c0 
c0103d41:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103d48:	c0 
c0103d49:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0103d50:	00 
c0103d51:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103d58:	e8 8c c6 ff ff       	call   c01003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103d5d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d62:	8b 00                	mov    (%eax),%eax
c0103d64:	89 04 24             	mov    %eax,(%esp)
c0103d67:	e8 9a ed ff ff       	call   c0102b06 <pde2page>
c0103d6c:	89 04 24             	mov    %eax,(%esp)
c0103d6f:	e8 aa ed ff ff       	call   c0102b1e <page_ref>
c0103d74:	83 f8 01             	cmp    $0x1,%eax
c0103d77:	74 24                	je     c0103d9d <check_pgdir+0x663>
c0103d79:	c7 44 24 0c d4 6b 10 	movl   $0xc0106bd4,0xc(%esp)
c0103d80:	c0 
c0103d81:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103d88:	c0 
c0103d89:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0103d90:	00 
c0103d91:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103d98:	e8 4c c6 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103d9d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103da2:	8b 00                	mov    (%eax),%eax
c0103da4:	89 04 24             	mov    %eax,(%esp)
c0103da7:	e8 5a ed ff ff       	call   c0102b06 <pde2page>
c0103dac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103db3:	00 
c0103db4:	89 04 24             	mov    %eax,(%esp)
c0103db7:	e8 9f ef ff ff       	call   c0102d5b <free_pages>
    boot_pgdir[0] = 0;
c0103dbc:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103dc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103dc7:	c7 04 24 fb 6b 10 c0 	movl   $0xc0106bfb,(%esp)
c0103dce:	e8 bf c4 ff ff       	call   c0100292 <cprintf>
}
c0103dd3:	90                   	nop
c0103dd4:	c9                   	leave  
c0103dd5:	c3                   	ret    

c0103dd6 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103dd6:	55                   	push   %ebp
c0103dd7:	89 e5                	mov    %esp,%ebp
c0103dd9:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103ddc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103de3:	e9 ca 00 00 00       	jmp    c0103eb2 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103deb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103df1:	c1 e8 0c             	shr    $0xc,%eax
c0103df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103df7:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103dfc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103dff:	72 23                	jb     c0103e24 <check_boot_pgdir+0x4e>
c0103e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e04:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103e08:	c7 44 24 08 40 68 10 	movl   $0xc0106840,0x8(%esp)
c0103e0f:	c0 
c0103e10:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0103e17:	00 
c0103e18:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103e1f:	e8 c5 c5 ff ff       	call   c01003e9 <__panic>
c0103e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e27:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103e2c:	89 c2                	mov    %eax,%edx
c0103e2e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103e33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e3a:	00 
c0103e3b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e3f:	89 04 24             	mov    %eax,(%esp)
c0103e42:	e8 86 f5 ff ff       	call   c01033cd <get_pte>
c0103e47:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103e4a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103e4e:	75 24                	jne    c0103e74 <check_boot_pgdir+0x9e>
c0103e50:	c7 44 24 0c 18 6c 10 	movl   $0xc0106c18,0xc(%esp)
c0103e57:	c0 
c0103e58:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103e5f:	c0 
c0103e60:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0103e67:	00 
c0103e68:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103e6f:	e8 75 c5 ff ff       	call   c01003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103e74:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e77:	8b 00                	mov    (%eax),%eax
c0103e79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103e7e:	89 c2                	mov    %eax,%edx
c0103e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e83:	39 c2                	cmp    %eax,%edx
c0103e85:	74 24                	je     c0103eab <check_boot_pgdir+0xd5>
c0103e87:	c7 44 24 0c 55 6c 10 	movl   $0xc0106c55,0xc(%esp)
c0103e8e:	c0 
c0103e8f:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103e96:	c0 
c0103e97:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0103e9e:	00 
c0103e9f:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103ea6:	e8 3e c5 ff ff       	call   c01003e9 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103eab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103eb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103eb5:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103eba:	39 c2                	cmp    %eax,%edx
c0103ebc:	0f 82 26 ff ff ff    	jb     c0103de8 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103ec2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ec7:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103ecc:	8b 00                	mov    (%eax),%eax
c0103ece:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ed3:	89 c2                	mov    %eax,%edx
c0103ed5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103eda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103edd:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0103ee4:	77 23                	ja     c0103f09 <check_boot_pgdir+0x133>
c0103ee6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ee9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103eed:	c7 44 24 08 e4 68 10 	movl   $0xc01068e4,0x8(%esp)
c0103ef4:	c0 
c0103ef5:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0103efc:	00 
c0103efd:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103f04:	e8 e0 c4 ff ff       	call   c01003e9 <__panic>
c0103f09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f0c:	05 00 00 00 40       	add    $0x40000000,%eax
c0103f11:	39 c2                	cmp    %eax,%edx
c0103f13:	74 24                	je     c0103f39 <check_boot_pgdir+0x163>
c0103f15:	c7 44 24 0c 6c 6c 10 	movl   $0xc0106c6c,0xc(%esp)
c0103f1c:	c0 
c0103f1d:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103f24:	c0 
c0103f25:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0103f2c:	00 
c0103f2d:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103f34:	e8 b0 c4 ff ff       	call   c01003e9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103f39:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103f3e:	8b 00                	mov    (%eax),%eax
c0103f40:	85 c0                	test   %eax,%eax
c0103f42:	74 24                	je     c0103f68 <check_boot_pgdir+0x192>
c0103f44:	c7 44 24 0c a0 6c 10 	movl   $0xc0106ca0,0xc(%esp)
c0103f4b:	c0 
c0103f4c:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103f53:	c0 
c0103f54:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0103f5b:	00 
c0103f5c:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103f63:	e8 81 c4 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103f68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f6f:	e8 af ed ff ff       	call   c0102d23 <alloc_pages>
c0103f74:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103f77:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103f7c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103f83:	00 
c0103f84:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103f8b:	00 
c0103f8c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f8f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f93:	89 04 24             	mov    %eax,(%esp)
c0103f96:	e8 6b f6 ff ff       	call   c0103606 <page_insert>
c0103f9b:	85 c0                	test   %eax,%eax
c0103f9d:	74 24                	je     c0103fc3 <check_boot_pgdir+0x1ed>
c0103f9f:	c7 44 24 0c b4 6c 10 	movl   $0xc0106cb4,0xc(%esp)
c0103fa6:	c0 
c0103fa7:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103fae:	c0 
c0103faf:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0103fb6:	00 
c0103fb7:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103fbe:	e8 26 c4 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 1);
c0103fc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fc6:	89 04 24             	mov    %eax,(%esp)
c0103fc9:	e8 50 eb ff ff       	call   c0102b1e <page_ref>
c0103fce:	83 f8 01             	cmp    $0x1,%eax
c0103fd1:	74 24                	je     c0103ff7 <check_boot_pgdir+0x221>
c0103fd3:	c7 44 24 0c e2 6c 10 	movl   $0xc0106ce2,0xc(%esp)
c0103fda:	c0 
c0103fdb:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0103fe2:	c0 
c0103fe3:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0103fea:	00 
c0103feb:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0103ff2:	e8 f2 c3 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103ff7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ffc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104003:	00 
c0104004:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010400b:	00 
c010400c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010400f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104013:	89 04 24             	mov    %eax,(%esp)
c0104016:	e8 eb f5 ff ff       	call   c0103606 <page_insert>
c010401b:	85 c0                	test   %eax,%eax
c010401d:	74 24                	je     c0104043 <check_boot_pgdir+0x26d>
c010401f:	c7 44 24 0c f4 6c 10 	movl   $0xc0106cf4,0xc(%esp)
c0104026:	c0 
c0104027:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c010402e:	c0 
c010402f:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0104036:	00 
c0104037:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c010403e:	e8 a6 c3 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 2);
c0104043:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104046:	89 04 24             	mov    %eax,(%esp)
c0104049:	e8 d0 ea ff ff       	call   c0102b1e <page_ref>
c010404e:	83 f8 02             	cmp    $0x2,%eax
c0104051:	74 24                	je     c0104077 <check_boot_pgdir+0x2a1>
c0104053:	c7 44 24 0c 2b 6d 10 	movl   $0xc0106d2b,0xc(%esp)
c010405a:	c0 
c010405b:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c0104062:	c0 
c0104063:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c010406a:	00 
c010406b:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c0104072:	e8 72 c3 ff ff       	call   c01003e9 <__panic>

    const char *str = "ucore: Hello world!!";
c0104077:	c7 45 dc 3c 6d 10 c0 	movl   $0xc0106d3c,-0x24(%ebp)
    strcpy((void *)0x100, str);
c010407e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104081:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104085:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010408c:	e8 97 15 00 00       	call   c0105628 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0104091:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0104098:	00 
c0104099:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01040a0:	e8 fa 15 00 00       	call   c010569f <strcmp>
c01040a5:	85 c0                	test   %eax,%eax
c01040a7:	74 24                	je     c01040cd <check_boot_pgdir+0x2f7>
c01040a9:	c7 44 24 0c 54 6d 10 	movl   $0xc0106d54,0xc(%esp)
c01040b0:	c0 
c01040b1:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c01040b8:	c0 
c01040b9:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c01040c0:	00 
c01040c1:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c01040c8:	e8 1c c3 ff ff       	call   c01003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01040cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01040d0:	89 04 24             	mov    %eax,(%esp)
c01040d3:	e8 9c e9 ff ff       	call   c0102a74 <page2kva>
c01040d8:	05 00 01 00 00       	add    $0x100,%eax
c01040dd:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01040e0:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01040e7:	e8 e6 14 00 00       	call   c01055d2 <strlen>
c01040ec:	85 c0                	test   %eax,%eax
c01040ee:	74 24                	je     c0104114 <check_boot_pgdir+0x33e>
c01040f0:	c7 44 24 0c 8c 6d 10 	movl   $0xc0106d8c,0xc(%esp)
c01040f7:	c0 
c01040f8:	c7 44 24 08 2d 69 10 	movl   $0xc010692d,0x8(%esp)
c01040ff:	c0 
c0104100:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c0104107:	00 
c0104108:	c7 04 24 08 69 10 c0 	movl   $0xc0106908,(%esp)
c010410f:	e8 d5 c2 ff ff       	call   c01003e9 <__panic>

    free_page(p);
c0104114:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010411b:	00 
c010411c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010411f:	89 04 24             	mov    %eax,(%esp)
c0104122:	e8 34 ec ff ff       	call   c0102d5b <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0104127:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010412c:	8b 00                	mov    (%eax),%eax
c010412e:	89 04 24             	mov    %eax,(%esp)
c0104131:	e8 d0 e9 ff ff       	call   c0102b06 <pde2page>
c0104136:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010413d:	00 
c010413e:	89 04 24             	mov    %eax,(%esp)
c0104141:	e8 15 ec ff ff       	call   c0102d5b <free_pages>
    boot_pgdir[0] = 0;
c0104146:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010414b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104151:	c7 04 24 b0 6d 10 c0 	movl   $0xc0106db0,(%esp)
c0104158:	e8 35 c1 ff ff       	call   c0100292 <cprintf>
}
c010415d:	90                   	nop
c010415e:	c9                   	leave  
c010415f:	c3                   	ret    

c0104160 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104160:	55                   	push   %ebp
c0104161:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0104163:	8b 45 08             	mov    0x8(%ebp),%eax
c0104166:	83 e0 04             	and    $0x4,%eax
c0104169:	85 c0                	test   %eax,%eax
c010416b:	74 04                	je     c0104171 <perm2str+0x11>
c010416d:	b0 75                	mov    $0x75,%al
c010416f:	eb 02                	jmp    c0104173 <perm2str+0x13>
c0104171:	b0 2d                	mov    $0x2d,%al
c0104173:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0104178:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010417f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104182:	83 e0 02             	and    $0x2,%eax
c0104185:	85 c0                	test   %eax,%eax
c0104187:	74 04                	je     c010418d <perm2str+0x2d>
c0104189:	b0 77                	mov    $0x77,%al
c010418b:	eb 02                	jmp    c010418f <perm2str+0x2f>
c010418d:	b0 2d                	mov    $0x2d,%al
c010418f:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0104194:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c010419b:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c01041a0:	5d                   	pop    %ebp
c01041a1:	c3                   	ret    

c01041a2 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01041a2:	55                   	push   %ebp
c01041a3:	89 e5                	mov    %esp,%ebp
c01041a5:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01041a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01041ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01041ae:	72 0d                	jb     c01041bd <get_pgtable_items+0x1b>
        return 0;
c01041b0:	b8 00 00 00 00       	mov    $0x0,%eax
c01041b5:	e9 98 00 00 00       	jmp    c0104252 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01041ba:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c01041bd:	8b 45 10             	mov    0x10(%ebp),%eax
c01041c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01041c3:	73 18                	jae    c01041dd <get_pgtable_items+0x3b>
c01041c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01041c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01041cf:	8b 45 14             	mov    0x14(%ebp),%eax
c01041d2:	01 d0                	add    %edx,%eax
c01041d4:	8b 00                	mov    (%eax),%eax
c01041d6:	83 e0 01             	and    $0x1,%eax
c01041d9:	85 c0                	test   %eax,%eax
c01041db:	74 dd                	je     c01041ba <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c01041dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01041e0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01041e3:	73 68                	jae    c010424d <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01041e5:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01041e9:	74 08                	je     c01041f3 <get_pgtable_items+0x51>
            *left_store = start;
c01041eb:	8b 45 18             	mov    0x18(%ebp),%eax
c01041ee:	8b 55 10             	mov    0x10(%ebp),%edx
c01041f1:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01041f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01041f6:	8d 50 01             	lea    0x1(%eax),%edx
c01041f9:	89 55 10             	mov    %edx,0x10(%ebp)
c01041fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104203:	8b 45 14             	mov    0x14(%ebp),%eax
c0104206:	01 d0                	add    %edx,%eax
c0104208:	8b 00                	mov    (%eax),%eax
c010420a:	83 e0 07             	and    $0x7,%eax
c010420d:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104210:	eb 03                	jmp    c0104215 <get_pgtable_items+0x73>
            start ++;
c0104212:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104215:	8b 45 10             	mov    0x10(%ebp),%eax
c0104218:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010421b:	73 1d                	jae    c010423a <get_pgtable_items+0x98>
c010421d:	8b 45 10             	mov    0x10(%ebp),%eax
c0104220:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104227:	8b 45 14             	mov    0x14(%ebp),%eax
c010422a:	01 d0                	add    %edx,%eax
c010422c:	8b 00                	mov    (%eax),%eax
c010422e:	83 e0 07             	and    $0x7,%eax
c0104231:	89 c2                	mov    %eax,%edx
c0104233:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104236:	39 c2                	cmp    %eax,%edx
c0104238:	74 d8                	je     c0104212 <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
c010423a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010423e:	74 08                	je     c0104248 <get_pgtable_items+0xa6>
            *right_store = start;
c0104240:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104243:	8b 55 10             	mov    0x10(%ebp),%edx
c0104246:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104248:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010424b:	eb 05                	jmp    c0104252 <get_pgtable_items+0xb0>
    }
    return 0;
c010424d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104252:	c9                   	leave  
c0104253:	c3                   	ret    

c0104254 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0104254:	55                   	push   %ebp
c0104255:	89 e5                	mov    %esp,%ebp
c0104257:	57                   	push   %edi
c0104258:	56                   	push   %esi
c0104259:	53                   	push   %ebx
c010425a:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010425d:	c7 04 24 d0 6d 10 c0 	movl   $0xc0106dd0,(%esp)
c0104264:	e8 29 c0 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
c0104269:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104270:	e9 fa 00 00 00       	jmp    c010436f <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104278:	89 04 24             	mov    %eax,(%esp)
c010427b:	e8 e0 fe ff ff       	call   c0104160 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104280:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104283:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104286:	29 d1                	sub    %edx,%ecx
c0104288:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010428a:	89 d6                	mov    %edx,%esi
c010428c:	c1 e6 16             	shl    $0x16,%esi
c010428f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104292:	89 d3                	mov    %edx,%ebx
c0104294:	c1 e3 16             	shl    $0x16,%ebx
c0104297:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010429a:	89 d1                	mov    %edx,%ecx
c010429c:	c1 e1 16             	shl    $0x16,%ecx
c010429f:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01042a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042a5:	29 d7                	sub    %edx,%edi
c01042a7:	89 fa                	mov    %edi,%edx
c01042a9:	89 44 24 14          	mov    %eax,0x14(%esp)
c01042ad:	89 74 24 10          	mov    %esi,0x10(%esp)
c01042b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01042b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01042b9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042bd:	c7 04 24 01 6e 10 c0 	movl   $0xc0106e01,(%esp)
c01042c4:	e8 c9 bf ff ff       	call   c0100292 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c01042c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042cc:	c1 e0 0a             	shl    $0xa,%eax
c01042cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01042d2:	eb 54                	jmp    c0104328 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01042d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042d7:	89 04 24             	mov    %eax,(%esp)
c01042da:	e8 81 fe ff ff       	call   c0104160 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01042df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01042e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01042e5:	29 d1                	sub    %edx,%ecx
c01042e7:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01042e9:	89 d6                	mov    %edx,%esi
c01042eb:	c1 e6 0c             	shl    $0xc,%esi
c01042ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01042f1:	89 d3                	mov    %edx,%ebx
c01042f3:	c1 e3 0c             	shl    $0xc,%ebx
c01042f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01042f9:	89 d1                	mov    %edx,%ecx
c01042fb:	c1 e1 0c             	shl    $0xc,%ecx
c01042fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104301:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104304:	29 d7                	sub    %edx,%edi
c0104306:	89 fa                	mov    %edi,%edx
c0104308:	89 44 24 14          	mov    %eax,0x14(%esp)
c010430c:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104310:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104314:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104318:	89 54 24 04          	mov    %edx,0x4(%esp)
c010431c:	c7 04 24 20 6e 10 c0 	movl   $0xc0106e20,(%esp)
c0104323:	e8 6a bf ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104328:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010432d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104330:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104333:	89 d3                	mov    %edx,%ebx
c0104335:	c1 e3 0a             	shl    $0xa,%ebx
c0104338:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010433b:	89 d1                	mov    %edx,%ecx
c010433d:	c1 e1 0a             	shl    $0xa,%ecx
c0104340:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104343:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104347:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010434a:	89 54 24 10          	mov    %edx,0x10(%esp)
c010434e:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104352:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104356:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010435a:	89 0c 24             	mov    %ecx,(%esp)
c010435d:	e8 40 fe ff ff       	call   c01041a2 <get_pgtable_items>
c0104362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104365:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104369:	0f 85 65 ff ff ff    	jne    c01042d4 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010436f:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104374:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104377:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010437a:	89 54 24 14          	mov    %edx,0x14(%esp)
c010437e:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104381:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104385:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104389:	89 44 24 08          	mov    %eax,0x8(%esp)
c010438d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104394:	00 
c0104395:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010439c:	e8 01 fe ff ff       	call   c01041a2 <get_pgtable_items>
c01043a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01043a8:	0f 85 c7 fe ff ff    	jne    c0104275 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01043ae:	c7 04 24 44 6e 10 c0 	movl   $0xc0106e44,(%esp)
c01043b5:	e8 d8 be ff ff       	call   c0100292 <cprintf>
}
c01043ba:	90                   	nop
c01043bb:	83 c4 4c             	add    $0x4c,%esp
c01043be:	5b                   	pop    %ebx
c01043bf:	5e                   	pop    %esi
c01043c0:	5f                   	pop    %edi
c01043c1:	5d                   	pop    %ebp
c01043c2:	c3                   	ret    

c01043c3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01043c3:	55                   	push   %ebp
c01043c4:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01043c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01043c9:	8b 15 78 af 11 c0    	mov    0xc011af78,%edx
c01043cf:	29 d0                	sub    %edx,%eax
c01043d1:	c1 f8 02             	sar    $0x2,%eax
c01043d4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01043da:	5d                   	pop    %ebp
c01043db:	c3                   	ret    

c01043dc <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01043dc:	55                   	push   %ebp
c01043dd:	89 e5                	mov    %esp,%ebp
c01043df:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01043e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01043e5:	89 04 24             	mov    %eax,(%esp)
c01043e8:	e8 d6 ff ff ff       	call   c01043c3 <page2ppn>
c01043ed:	c1 e0 0c             	shl    $0xc,%eax
}
c01043f0:	c9                   	leave  
c01043f1:	c3                   	ret    

c01043f2 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01043f2:	55                   	push   %ebp
c01043f3:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01043f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01043f8:	8b 00                	mov    (%eax),%eax
}
c01043fa:	5d                   	pop    %ebp
c01043fb:	c3                   	ret    

c01043fc <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01043fc:	55                   	push   %ebp
c01043fd:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01043ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0104402:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104405:	89 10                	mov    %edx,(%eax)
}
c0104407:	90                   	nop
c0104408:	5d                   	pop    %ebp
c0104409:	c3                   	ret    

c010440a <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010440a:	55                   	push   %ebp
c010440b:	89 e5                	mov    %esp,%ebp
c010440d:	83 ec 10             	sub    $0x10,%esp
c0104410:	c7 45 fc 7c af 11 c0 	movl   $0xc011af7c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104417:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010441a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010441d:	89 50 04             	mov    %edx,0x4(%eax)
c0104420:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104423:	8b 50 04             	mov    0x4(%eax),%edx
c0104426:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104429:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010442b:	c7 05 84 af 11 c0 00 	movl   $0x0,0xc011af84
c0104432:	00 00 00 
}
c0104435:	90                   	nop
c0104436:	c9                   	leave  
c0104437:	c3                   	ret    

c0104438 <default_init_memmap>:

//初始化维护页（虚拟地址）
static void
default_init_memmap(struct Page *base, size_t n) {
c0104438:	55                   	push   %ebp
c0104439:	89 e5                	mov    %esp,%ebp
c010443b:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010443e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104442:	75 24                	jne    c0104468 <default_init_memmap+0x30>
c0104444:	c7 44 24 0c 78 6e 10 	movl   $0xc0106e78,0xc(%esp)
c010444b:	c0 
c010444c:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104453:	c0 
c0104454:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c010445b:	00 
c010445c:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104463:	e8 81 bf ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c0104468:	8b 45 08             	mov    0x8(%ebp),%eax
c010446b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010446e:	eb 7d                	jmp    c01044ed <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0104470:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104473:	83 c0 04             	add    $0x4,%eax
c0104476:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010447d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104480:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104483:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104486:	0f a3 10             	bt     %edx,(%eax)
c0104489:	19 c0                	sbb    %eax,%eax
c010448b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c010448e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104492:	0f 95 c0             	setne  %al
c0104495:	0f b6 c0             	movzbl %al,%eax
c0104498:	85 c0                	test   %eax,%eax
c010449a:	75 24                	jne    c01044c0 <default_init_memmap+0x88>
c010449c:	c7 44 24 0c a9 6e 10 	movl   $0xc0106ea9,0xc(%esp)
c01044a3:	c0 
c01044a4:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01044ab:	c0 
c01044ac:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01044b3:	00 
c01044b4:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01044bb:	e8 29 bf ff ff       	call   c01003e9 <__panic>
        p->flags = p->property = 0;
c01044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01044ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044cd:	8b 50 08             	mov    0x8(%eax),%edx
c01044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044d3:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01044d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01044dd:	00 
c01044de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044e1:	89 04 24             	mov    %eax,(%esp)
c01044e4:	e8 13 ff ff ff       	call   c01043fc <set_page_ref>
//初始化维护页（虚拟地址）
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01044e9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01044ed:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044f0:	89 d0                	mov    %edx,%eax
c01044f2:	c1 e0 02             	shl    $0x2,%eax
c01044f5:	01 d0                	add    %edx,%eax
c01044f7:	c1 e0 02             	shl    $0x2,%eax
c01044fa:	89 c2                	mov    %eax,%edx
c01044fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01044ff:	01 d0                	add    %edx,%eax
c0104501:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104504:	0f 85 66 ff ff ff    	jne    c0104470 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c010450a:	8b 45 08             	mov    0x8(%ebp),%eax
c010450d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104510:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104513:	8b 45 08             	mov    0x8(%ebp),%eax
c0104516:	83 c0 04             	add    $0x4,%eax
c0104519:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0104520:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104523:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104526:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104529:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c010452c:	8b 15 84 af 11 c0    	mov    0xc011af84,%edx
c0104532:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104535:	01 d0                	add    %edx,%eax
c0104537:	a3 84 af 11 c0       	mov    %eax,0xc011af84
    list_add_before(&free_list, &(base->page_link));
c010453c:	8b 45 08             	mov    0x8(%ebp),%eax
c010453f:	83 c0 0c             	add    $0xc,%eax
c0104542:	c7 45 f0 7c af 11 c0 	movl   $0xc011af7c,-0x10(%ebp)
c0104549:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010454c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010454f:	8b 00                	mov    (%eax),%eax
c0104551:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104554:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0104557:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010455a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010455d:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104560:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104563:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104566:	89 10                	mov    %edx,(%eax)
c0104568:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010456b:	8b 10                	mov    (%eax),%edx
c010456d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104570:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104573:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104576:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104579:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010457c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010457f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104582:	89 10                	mov    %edx,(%eax)
}
c0104584:	90                   	nop
c0104585:	c9                   	leave  
c0104586:	c3                   	ret    

c0104587 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0104587:	55                   	push   %ebp
c0104588:	89 e5                	mov    %esp,%ebp
c010458a:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010458d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104591:	75 24                	jne    c01045b7 <default_alloc_pages+0x30>
c0104593:	c7 44 24 0c 78 6e 10 	movl   $0xc0106e78,0xc(%esp)
c010459a:	c0 
c010459b:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01045a2:	c0 
c01045a3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01045aa:	00 
c01045ab:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01045b2:	e8 32 be ff ff       	call   c01003e9 <__panic>
    if (n > nr_free) {
c01045b7:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c01045bc:	3b 45 08             	cmp    0x8(%ebp),%eax
c01045bf:	73 0a                	jae    c01045cb <default_alloc_pages+0x44>
        return NULL;
c01045c1:	b8 00 00 00 00       	mov    $0x0,%eax
c01045c6:	e9 3d 01 00 00       	jmp    c0104708 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c01045cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01045d2:	c7 45 f0 7c af 11 c0 	movl   $0xc011af7c,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c01045d9:	eb 1c                	jmp    c01045f7 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c01045db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045de:	83 e8 0c             	sub    $0xc,%eax
c01045e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c01045e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045e7:	8b 40 08             	mov    0x8(%eax),%eax
c01045ea:	3b 45 08             	cmp    0x8(%ebp),%eax
c01045ed:	72 08                	jb     c01045f7 <default_alloc_pages+0x70>
            page = p;
c01045ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01045f5:	eb 18                	jmp    c010460f <default_alloc_pages+0x88>
c01045f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01045fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104600:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0104603:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104606:	81 7d f0 7c af 11 c0 	cmpl   $0xc011af7c,-0x10(%ebp)
c010460d:	75 cc                	jne    c01045db <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c010460f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104613:	0f 84 ec 00 00 00    	je     c0104705 <default_alloc_pages+0x17e>
        if (page->property > n) {
c0104619:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010461c:	8b 40 08             	mov    0x8(%eax),%eax
c010461f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104622:	0f 86 8c 00 00 00    	jbe    c01046b4 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
c0104628:	8b 55 08             	mov    0x8(%ebp),%edx
c010462b:	89 d0                	mov    %edx,%eax
c010462d:	c1 e0 02             	shl    $0x2,%eax
c0104630:	01 d0                	add    %edx,%eax
c0104632:	c1 e0 02             	shl    $0x2,%eax
c0104635:	89 c2                	mov    %eax,%edx
c0104637:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010463a:	01 d0                	add    %edx,%eax
c010463c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c010463f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104642:	8b 40 08             	mov    0x8(%eax),%eax
c0104645:	2b 45 08             	sub    0x8(%ebp),%eax
c0104648:	89 c2                	mov    %eax,%edx
c010464a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010464d:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0104650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104653:	83 c0 04             	add    $0x4,%eax
c0104656:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c010465d:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0104660:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104663:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104666:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0104669:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010466c:	83 c0 0c             	add    $0xc,%eax
c010466f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104672:	83 c2 0c             	add    $0xc,%edx
c0104675:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0104678:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010467b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010467e:	8b 40 04             	mov    0x4(%eax),%eax
c0104681:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104684:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104687:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010468a:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010468d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104690:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104693:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104696:	89 10                	mov    %edx,(%eax)
c0104698:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010469b:	8b 10                	mov    (%eax),%edx
c010469d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01046a0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01046a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01046a6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01046a9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01046ac:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01046af:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01046b2:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c01046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046b7:	83 c0 0c             	add    $0xc,%eax
c01046ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01046bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046c0:	8b 40 04             	mov    0x4(%eax),%eax
c01046c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01046c6:	8b 12                	mov    (%edx),%edx
c01046c8:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01046cb:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01046ce:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01046d1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01046d4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01046d7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01046da:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01046dd:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c01046df:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c01046e4:	2b 45 08             	sub    0x8(%ebp),%eax
c01046e7:	a3 84 af 11 c0       	mov    %eax,0xc011af84
        ClearPageProperty(page);
c01046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ef:	83 c0 04             	add    $0x4,%eax
c01046f2:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01046f9:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01046fc:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01046ff:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104702:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0104705:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104708:	c9                   	leave  
c0104709:	c3                   	ret    

c010470a <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010470a:	55                   	push   %ebp
c010470b:	89 e5                	mov    %esp,%ebp
c010470d:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0104713:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104717:	75 24                	jne    c010473d <default_free_pages+0x33>
c0104719:	c7 44 24 0c 78 6e 10 	movl   $0xc0106e78,0xc(%esp)
c0104720:	c0 
c0104721:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104728:	c0 
c0104729:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
c0104730:	00 
c0104731:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104738:	e8 ac bc ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c010473d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104740:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104743:	e9 9d 00 00 00       	jmp    c01047e5 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0104748:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010474b:	83 c0 04             	add    $0x4,%eax
c010474e:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c0104755:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104758:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010475b:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010475e:	0f a3 10             	bt     %edx,(%eax)
c0104761:	19 c0                	sbb    %eax,%eax
c0104763:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104766:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010476a:	0f 95 c0             	setne  %al
c010476d:	0f b6 c0             	movzbl %al,%eax
c0104770:	85 c0                	test   %eax,%eax
c0104772:	75 2c                	jne    c01047a0 <default_free_pages+0x96>
c0104774:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104777:	83 c0 04             	add    $0x4,%eax
c010477a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0104781:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104784:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104787:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010478a:	0f a3 10             	bt     %edx,(%eax)
c010478d:	19 c0                	sbb    %eax,%eax
c010478f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c0104792:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c0104796:	0f 95 c0             	setne  %al
c0104799:	0f b6 c0             	movzbl %al,%eax
c010479c:	85 c0                	test   %eax,%eax
c010479e:	74 24                	je     c01047c4 <default_free_pages+0xba>
c01047a0:	c7 44 24 0c bc 6e 10 	movl   $0xc0106ebc,0xc(%esp)
c01047a7:	c0 
c01047a8:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01047af:	c0 
c01047b0:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01047b7:	00 
c01047b8:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01047bf:	e8 25 bc ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c01047c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047c7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01047ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01047d5:	00 
c01047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047d9:	89 04 24             	mov    %eax,(%esp)
c01047dc:	e8 1b fc ff ff       	call   c01043fc <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01047e1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01047e5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047e8:	89 d0                	mov    %edx,%eax
c01047ea:	c1 e0 02             	shl    $0x2,%eax
c01047ed:	01 d0                	add    %edx,%eax
c01047ef:	c1 e0 02             	shl    $0x2,%eax
c01047f2:	89 c2                	mov    %eax,%edx
c01047f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01047f7:	01 d0                	add    %edx,%eax
c01047f9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01047fc:	0f 85 46 ff ff ff    	jne    c0104748 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0104802:	8b 45 08             	mov    0x8(%ebp),%eax
c0104805:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104808:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010480b:	8b 45 08             	mov    0x8(%ebp),%eax
c010480e:	83 c0 04             	add    $0x4,%eax
c0104811:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104818:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010481b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010481e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104821:	0f ab 10             	bts    %edx,(%eax)
c0104824:	c7 45 e8 7c af 11 c0 	movl   $0xc011af7c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010482b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010482e:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0104831:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104834:	e9 08 01 00 00       	jmp    c0104941 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0104839:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010483c:	83 e8 0c             	sub    $0xc,%eax
c010483f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104842:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104845:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104848:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010484b:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010484e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0104851:	8b 45 08             	mov    0x8(%ebp),%eax
c0104854:	8b 50 08             	mov    0x8(%eax),%edx
c0104857:	89 d0                	mov    %edx,%eax
c0104859:	c1 e0 02             	shl    $0x2,%eax
c010485c:	01 d0                	add    %edx,%eax
c010485e:	c1 e0 02             	shl    $0x2,%eax
c0104861:	89 c2                	mov    %eax,%edx
c0104863:	8b 45 08             	mov    0x8(%ebp),%eax
c0104866:	01 d0                	add    %edx,%eax
c0104868:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010486b:	75 5a                	jne    c01048c7 <default_free_pages+0x1bd>
            base->property += p->property;
c010486d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104870:	8b 50 08             	mov    0x8(%eax),%edx
c0104873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104876:	8b 40 08             	mov    0x8(%eax),%eax
c0104879:	01 c2                	add    %eax,%edx
c010487b:	8b 45 08             	mov    0x8(%ebp),%eax
c010487e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0104881:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104884:	83 c0 04             	add    $0x4,%eax
c0104887:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c010488e:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104891:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104894:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104897:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c010489a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010489d:	83 c0 0c             	add    $0xc,%eax
c01048a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01048a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01048a6:	8b 40 04             	mov    0x4(%eax),%eax
c01048a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01048ac:	8b 12                	mov    (%edx),%edx
c01048ae:	89 55 a8             	mov    %edx,-0x58(%ebp)
c01048b1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01048b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01048b7:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01048ba:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01048bd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01048c0:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01048c3:	89 10                	mov    %edx,(%eax)
c01048c5:	eb 7a                	jmp    c0104941 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c01048c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ca:	8b 50 08             	mov    0x8(%eax),%edx
c01048cd:	89 d0                	mov    %edx,%eax
c01048cf:	c1 e0 02             	shl    $0x2,%eax
c01048d2:	01 d0                	add    %edx,%eax
c01048d4:	c1 e0 02             	shl    $0x2,%eax
c01048d7:	89 c2                	mov    %eax,%edx
c01048d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048dc:	01 d0                	add    %edx,%eax
c01048de:	3b 45 08             	cmp    0x8(%ebp),%eax
c01048e1:	75 5e                	jne    c0104941 <default_free_pages+0x237>
            p->property += base->property;
c01048e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048e6:	8b 50 08             	mov    0x8(%eax),%edx
c01048e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01048ec:	8b 40 08             	mov    0x8(%eax),%eax
c01048ef:	01 c2                	add    %eax,%edx
c01048f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f4:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01048f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01048fa:	83 c0 04             	add    $0x4,%eax
c01048fd:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0104904:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104907:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010490a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010490d:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0104910:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104913:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104916:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104919:	83 c0 0c             	add    $0xc,%eax
c010491c:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010491f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104922:	8b 40 04             	mov    0x4(%eax),%eax
c0104925:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104928:	8b 12                	mov    (%edx),%edx
c010492a:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010492d:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104930:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104933:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104936:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104939:	8b 45 98             	mov    -0x68(%ebp),%eax
c010493c:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010493f:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0104941:	81 7d f0 7c af 11 c0 	cmpl   $0xc011af7c,-0x10(%ebp)
c0104948:	0f 85 eb fe ff ff    	jne    c0104839 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c010494e:	8b 15 84 af 11 c0    	mov    0xc011af84,%edx
c0104954:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104957:	01 d0                	add    %edx,%eax
c0104959:	a3 84 af 11 c0       	mov    %eax,0xc011af84
c010495e:	c7 45 d0 7c af 11 c0 	movl   $0xc011af7c,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104965:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104968:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c010496b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010496e:	eb 74                	jmp    c01049e4 <default_free_pages+0x2da>
        p = le2page(le, page_link);
c0104970:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104973:	83 e8 0c             	sub    $0xc,%eax
c0104976:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0104979:	8b 45 08             	mov    0x8(%ebp),%eax
c010497c:	8b 50 08             	mov    0x8(%eax),%edx
c010497f:	89 d0                	mov    %edx,%eax
c0104981:	c1 e0 02             	shl    $0x2,%eax
c0104984:	01 d0                	add    %edx,%eax
c0104986:	c1 e0 02             	shl    $0x2,%eax
c0104989:	89 c2                	mov    %eax,%edx
c010498b:	8b 45 08             	mov    0x8(%ebp),%eax
c010498e:	01 d0                	add    %edx,%eax
c0104990:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104993:	77 40                	ja     c01049d5 <default_free_pages+0x2cb>
            assert(base + base->property != p);
c0104995:	8b 45 08             	mov    0x8(%ebp),%eax
c0104998:	8b 50 08             	mov    0x8(%eax),%edx
c010499b:	89 d0                	mov    %edx,%eax
c010499d:	c1 e0 02             	shl    $0x2,%eax
c01049a0:	01 d0                	add    %edx,%eax
c01049a2:	c1 e0 02             	shl    $0x2,%eax
c01049a5:	89 c2                	mov    %eax,%edx
c01049a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01049aa:	01 d0                	add    %edx,%eax
c01049ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049af:	75 3e                	jne    c01049ef <default_free_pages+0x2e5>
c01049b1:	c7 44 24 0c e1 6e 10 	movl   $0xc0106ee1,0xc(%esp)
c01049b8:	c0 
c01049b9:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01049c0:	c0 
c01049c1:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c01049c8:	00 
c01049c9:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01049d0:	e8 14 ba ff ff       	call   c01003e9 <__panic>
c01049d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01049db:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01049de:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01049e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c01049e4:	81 7d f0 7c af 11 c0 	cmpl   $0xc011af7c,-0x10(%ebp)
c01049eb:	75 83                	jne    c0104970 <default_free_pages+0x266>
c01049ed:	eb 01                	jmp    c01049f0 <default_free_pages+0x2e6>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
c01049ef:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c01049f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01049f3:	8d 50 0c             	lea    0xc(%eax),%edx
c01049f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049f9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01049fc:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01049ff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104a02:	8b 00                	mov    (%eax),%eax
c0104a04:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104a07:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104a0a:	89 45 88             	mov    %eax,-0x78(%ebp)
c0104a0d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104a10:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104a13:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104a16:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104a19:	89 10                	mov    %edx,(%eax)
c0104a1b:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104a1e:	8b 10                	mov    (%eax),%edx
c0104a20:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104a23:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104a26:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104a29:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104a2c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104a2f:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104a32:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104a35:	89 10                	mov    %edx,(%eax)
}
c0104a37:	90                   	nop
c0104a38:	c9                   	leave  
c0104a39:	c3                   	ret    

c0104a3a <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104a3a:	55                   	push   %ebp
c0104a3b:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104a3d:	a1 84 af 11 c0       	mov    0xc011af84,%eax
}
c0104a42:	5d                   	pop    %ebp
c0104a43:	c3                   	ret    

c0104a44 <basic_check>:

static void
basic_check(void) {
c0104a44:	55                   	push   %ebp
c0104a45:	89 e5                	mov    %esp,%ebp
c0104a47:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104a4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104a5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a64:	e8 ba e2 ff ff       	call   c0102d23 <alloc_pages>
c0104a69:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104a6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104a70:	75 24                	jne    c0104a96 <basic_check+0x52>
c0104a72:	c7 44 24 0c fc 6e 10 	movl   $0xc0106efc,0xc(%esp)
c0104a79:	c0 
c0104a7a:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104a81:	c0 
c0104a82:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0104a89:	00 
c0104a8a:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104a91:	e8 53 b9 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104a96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a9d:	e8 81 e2 ff ff       	call   c0102d23 <alloc_pages>
c0104aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104aa5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104aa9:	75 24                	jne    c0104acf <basic_check+0x8b>
c0104aab:	c7 44 24 0c 18 6f 10 	movl   $0xc0106f18,0xc(%esp)
c0104ab2:	c0 
c0104ab3:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104aba:	c0 
c0104abb:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0104ac2:	00 
c0104ac3:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104aca:	e8 1a b9 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104acf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ad6:	e8 48 e2 ff ff       	call   c0102d23 <alloc_pages>
c0104adb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ade:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ae2:	75 24                	jne    c0104b08 <basic_check+0xc4>
c0104ae4:	c7 44 24 0c 34 6f 10 	movl   $0xc0106f34,0xc(%esp)
c0104aeb:	c0 
c0104aec:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104af3:	c0 
c0104af4:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0104afb:	00 
c0104afc:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104b03:	e8 e1 b8 ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b0b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104b0e:	74 10                	je     c0104b20 <basic_check+0xdc>
c0104b10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b13:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b16:	74 08                	je     c0104b20 <basic_check+0xdc>
c0104b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b1b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b1e:	75 24                	jne    c0104b44 <basic_check+0x100>
c0104b20:	c7 44 24 0c 50 6f 10 	movl   $0xc0106f50,0xc(%esp)
c0104b27:	c0 
c0104b28:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104b2f:	c0 
c0104b30:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0104b37:	00 
c0104b38:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104b3f:	e8 a5 b8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b47:	89 04 24             	mov    %eax,(%esp)
c0104b4a:	e8 a3 f8 ff ff       	call   c01043f2 <page_ref>
c0104b4f:	85 c0                	test   %eax,%eax
c0104b51:	75 1e                	jne    c0104b71 <basic_check+0x12d>
c0104b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b56:	89 04 24             	mov    %eax,(%esp)
c0104b59:	e8 94 f8 ff ff       	call   c01043f2 <page_ref>
c0104b5e:	85 c0                	test   %eax,%eax
c0104b60:	75 0f                	jne    c0104b71 <basic_check+0x12d>
c0104b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b65:	89 04 24             	mov    %eax,(%esp)
c0104b68:	e8 85 f8 ff ff       	call   c01043f2 <page_ref>
c0104b6d:	85 c0                	test   %eax,%eax
c0104b6f:	74 24                	je     c0104b95 <basic_check+0x151>
c0104b71:	c7 44 24 0c 74 6f 10 	movl   $0xc0106f74,0xc(%esp)
c0104b78:	c0 
c0104b79:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104b80:	c0 
c0104b81:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0104b88:	00 
c0104b89:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104b90:	e8 54 b8 ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b98:	89 04 24             	mov    %eax,(%esp)
c0104b9b:	e8 3c f8 ff ff       	call   c01043dc <page2pa>
c0104ba0:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104ba6:	c1 e2 0c             	shl    $0xc,%edx
c0104ba9:	39 d0                	cmp    %edx,%eax
c0104bab:	72 24                	jb     c0104bd1 <basic_check+0x18d>
c0104bad:	c7 44 24 0c b0 6f 10 	movl   $0xc0106fb0,0xc(%esp)
c0104bb4:	c0 
c0104bb5:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104bbc:	c0 
c0104bbd:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0104bc4:	00 
c0104bc5:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104bcc:	e8 18 b8 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bd4:	89 04 24             	mov    %eax,(%esp)
c0104bd7:	e8 00 f8 ff ff       	call   c01043dc <page2pa>
c0104bdc:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104be2:	c1 e2 0c             	shl    $0xc,%edx
c0104be5:	39 d0                	cmp    %edx,%eax
c0104be7:	72 24                	jb     c0104c0d <basic_check+0x1c9>
c0104be9:	c7 44 24 0c cd 6f 10 	movl   $0xc0106fcd,0xc(%esp)
c0104bf0:	c0 
c0104bf1:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104bf8:	c0 
c0104bf9:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0104c00:	00 
c0104c01:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104c08:	e8 dc b7 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c10:	89 04 24             	mov    %eax,(%esp)
c0104c13:	e8 c4 f7 ff ff       	call   c01043dc <page2pa>
c0104c18:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104c1e:	c1 e2 0c             	shl    $0xc,%edx
c0104c21:	39 d0                	cmp    %edx,%eax
c0104c23:	72 24                	jb     c0104c49 <basic_check+0x205>
c0104c25:	c7 44 24 0c ea 6f 10 	movl   $0xc0106fea,0xc(%esp)
c0104c2c:	c0 
c0104c2d:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104c34:	c0 
c0104c35:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0104c3c:	00 
c0104c3d:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104c44:	e8 a0 b7 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104c49:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0104c4e:	8b 15 80 af 11 c0    	mov    0xc011af80,%edx
c0104c54:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c57:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104c5a:	c7 45 e4 7c af 11 c0 	movl   $0xc011af7c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104c61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104c67:	89 50 04             	mov    %edx,0x4(%eax)
c0104c6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c6d:	8b 50 04             	mov    0x4(%eax),%edx
c0104c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c73:	89 10                	mov    %edx,(%eax)
c0104c75:	c7 45 d8 7c af 11 c0 	movl   $0xc011af7c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104c7c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104c7f:	8b 40 04             	mov    0x4(%eax),%eax
c0104c82:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104c85:	0f 94 c0             	sete   %al
c0104c88:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104c8b:	85 c0                	test   %eax,%eax
c0104c8d:	75 24                	jne    c0104cb3 <basic_check+0x26f>
c0104c8f:	c7 44 24 0c 07 70 10 	movl   $0xc0107007,0xc(%esp)
c0104c96:	c0 
c0104c97:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104c9e:	c0 
c0104c9f:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0104ca6:	00 
c0104ca7:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104cae:	e8 36 b7 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104cb3:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c0104cb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0104cbb:	c7 05 84 af 11 c0 00 	movl   $0x0,0xc011af84
c0104cc2:	00 00 00 

    assert(alloc_page() == NULL);
c0104cc5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ccc:	e8 52 e0 ff ff       	call   c0102d23 <alloc_pages>
c0104cd1:	85 c0                	test   %eax,%eax
c0104cd3:	74 24                	je     c0104cf9 <basic_check+0x2b5>
c0104cd5:	c7 44 24 0c 1e 70 10 	movl   $0xc010701e,0xc(%esp)
c0104cdc:	c0 
c0104cdd:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104ce4:	c0 
c0104ce5:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0104cec:	00 
c0104ced:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104cf4:	e8 f0 b6 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104cf9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d00:	00 
c0104d01:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d04:	89 04 24             	mov    %eax,(%esp)
c0104d07:	e8 4f e0 ff ff       	call   c0102d5b <free_pages>
    free_page(p1);
c0104d0c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d13:	00 
c0104d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d17:	89 04 24             	mov    %eax,(%esp)
c0104d1a:	e8 3c e0 ff ff       	call   c0102d5b <free_pages>
    free_page(p2);
c0104d1f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d26:	00 
c0104d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d2a:	89 04 24             	mov    %eax,(%esp)
c0104d2d:	e8 29 e0 ff ff       	call   c0102d5b <free_pages>
    assert(nr_free == 3);
c0104d32:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c0104d37:	83 f8 03             	cmp    $0x3,%eax
c0104d3a:	74 24                	je     c0104d60 <basic_check+0x31c>
c0104d3c:	c7 44 24 0c 33 70 10 	movl   $0xc0107033,0xc(%esp)
c0104d43:	c0 
c0104d44:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104d4b:	c0 
c0104d4c:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0104d53:	00 
c0104d54:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104d5b:	e8 89 b6 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104d60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d67:	e8 b7 df ff ff       	call   c0102d23 <alloc_pages>
c0104d6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104d73:	75 24                	jne    c0104d99 <basic_check+0x355>
c0104d75:	c7 44 24 0c fc 6e 10 	movl   $0xc0106efc,0xc(%esp)
c0104d7c:	c0 
c0104d7d:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104d84:	c0 
c0104d85:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0104d8c:	00 
c0104d8d:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104d94:	e8 50 b6 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104d99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104da0:	e8 7e df ff ff       	call   c0102d23 <alloc_pages>
c0104da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104da8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104dac:	75 24                	jne    c0104dd2 <basic_check+0x38e>
c0104dae:	c7 44 24 0c 18 6f 10 	movl   $0xc0106f18,0xc(%esp)
c0104db5:	c0 
c0104db6:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104dbd:	c0 
c0104dbe:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0104dc5:	00 
c0104dc6:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104dcd:	e8 17 b6 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104dd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104dd9:	e8 45 df ff ff       	call   c0102d23 <alloc_pages>
c0104dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104de1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104de5:	75 24                	jne    c0104e0b <basic_check+0x3c7>
c0104de7:	c7 44 24 0c 34 6f 10 	movl   $0xc0106f34,0xc(%esp)
c0104dee:	c0 
c0104def:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104df6:	c0 
c0104df7:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0104dfe:	00 
c0104dff:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104e06:	e8 de b5 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104e0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e12:	e8 0c df ff ff       	call   c0102d23 <alloc_pages>
c0104e17:	85 c0                	test   %eax,%eax
c0104e19:	74 24                	je     c0104e3f <basic_check+0x3fb>
c0104e1b:	c7 44 24 0c 1e 70 10 	movl   $0xc010701e,0xc(%esp)
c0104e22:	c0 
c0104e23:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104e2a:	c0 
c0104e2b:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0104e32:	00 
c0104e33:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104e3a:	e8 aa b5 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104e3f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e46:	00 
c0104e47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e4a:	89 04 24             	mov    %eax,(%esp)
c0104e4d:	e8 09 df ff ff       	call   c0102d5b <free_pages>
c0104e52:	c7 45 e8 7c af 11 c0 	movl   $0xc011af7c,-0x18(%ebp)
c0104e59:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e5c:	8b 40 04             	mov    0x4(%eax),%eax
c0104e5f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104e62:	0f 94 c0             	sete   %al
c0104e65:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104e68:	85 c0                	test   %eax,%eax
c0104e6a:	74 24                	je     c0104e90 <basic_check+0x44c>
c0104e6c:	c7 44 24 0c 40 70 10 	movl   $0xc0107040,0xc(%esp)
c0104e73:	c0 
c0104e74:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104e7b:	c0 
c0104e7c:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0104e83:	00 
c0104e84:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104e8b:	e8 59 b5 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104e90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e97:	e8 87 de ff ff       	call   c0102d23 <alloc_pages>
c0104e9c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104e9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104ea2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104ea5:	74 24                	je     c0104ecb <basic_check+0x487>
c0104ea7:	c7 44 24 0c 58 70 10 	movl   $0xc0107058,0xc(%esp)
c0104eae:	c0 
c0104eaf:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104eb6:	c0 
c0104eb7:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0104ebe:	00 
c0104ebf:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104ec6:	e8 1e b5 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104ecb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ed2:	e8 4c de ff ff       	call   c0102d23 <alloc_pages>
c0104ed7:	85 c0                	test   %eax,%eax
c0104ed9:	74 24                	je     c0104eff <basic_check+0x4bb>
c0104edb:	c7 44 24 0c 1e 70 10 	movl   $0xc010701e,0xc(%esp)
c0104ee2:	c0 
c0104ee3:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104eea:	c0 
c0104eeb:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0104ef2:	00 
c0104ef3:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104efa:	e8 ea b4 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104eff:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c0104f04:	85 c0                	test   %eax,%eax
c0104f06:	74 24                	je     c0104f2c <basic_check+0x4e8>
c0104f08:	c7 44 24 0c 71 70 10 	movl   $0xc0107071,0xc(%esp)
c0104f0f:	c0 
c0104f10:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104f17:	c0 
c0104f18:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104f1f:	00 
c0104f20:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104f27:	e8 bd b4 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104f2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104f2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104f32:	a3 7c af 11 c0       	mov    %eax,0xc011af7c
c0104f37:	89 15 80 af 11 c0    	mov    %edx,0xc011af80
    nr_free = nr_free_store;
c0104f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f40:	a3 84 af 11 c0       	mov    %eax,0xc011af84

    free_page(p);
c0104f45:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f4c:	00 
c0104f4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f50:	89 04 24             	mov    %eax,(%esp)
c0104f53:	e8 03 de ff ff       	call   c0102d5b <free_pages>
    free_page(p1);
c0104f58:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f5f:	00 
c0104f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f63:	89 04 24             	mov    %eax,(%esp)
c0104f66:	e8 f0 dd ff ff       	call   c0102d5b <free_pages>
    free_page(p2);
c0104f6b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f72:	00 
c0104f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f76:	89 04 24             	mov    %eax,(%esp)
c0104f79:	e8 dd dd ff ff       	call   c0102d5b <free_pages>
}
c0104f7e:	90                   	nop
c0104f7f:	c9                   	leave  
c0104f80:	c3                   	ret    

c0104f81 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104f81:	55                   	push   %ebp
c0104f82:	89 e5                	mov    %esp,%ebp
c0104f84:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104f8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104f91:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104f98:	c7 45 ec 7c af 11 c0 	movl   $0xc011af7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104f9f:	eb 6a                	jmp    c010500b <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104fa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fa4:	83 e8 0c             	sub    $0xc,%eax
c0104fa7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0104faa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fad:	83 c0 04             	add    $0x4,%eax
c0104fb0:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0104fb7:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104fba:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104fbd:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104fc0:	0f a3 10             	bt     %edx,(%eax)
c0104fc3:	19 c0                	sbb    %eax,%eax
c0104fc5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0104fc8:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0104fcc:	0f 95 c0             	setne  %al
c0104fcf:	0f b6 c0             	movzbl %al,%eax
c0104fd2:	85 c0                	test   %eax,%eax
c0104fd4:	75 24                	jne    c0104ffa <default_check+0x79>
c0104fd6:	c7 44 24 0c 7e 70 10 	movl   $0xc010707e,0xc(%esp)
c0104fdd:	c0 
c0104fde:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0104fe5:	c0 
c0104fe6:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0104fed:	00 
c0104fee:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0104ff5:	e8 ef b3 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104ffa:	ff 45 f4             	incl   -0xc(%ebp)
c0104ffd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105000:	8b 50 08             	mov    0x8(%eax),%edx
c0105003:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105006:	01 d0                	add    %edx,%eax
c0105008:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010500b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010500e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105011:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105014:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105017:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010501a:	81 7d ec 7c af 11 c0 	cmpl   $0xc011af7c,-0x14(%ebp)
c0105021:	0f 85 7a ff ff ff    	jne    c0104fa1 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0105027:	e8 62 dd ff ff       	call   c0102d8e <nr_free_pages>
c010502c:	89 c2                	mov    %eax,%edx
c010502e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105031:	39 c2                	cmp    %eax,%edx
c0105033:	74 24                	je     c0105059 <default_check+0xd8>
c0105035:	c7 44 24 0c 8e 70 10 	movl   $0xc010708e,0xc(%esp)
c010503c:	c0 
c010503d:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0105044:	c0 
c0105045:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c010504c:	00 
c010504d:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0105054:	e8 90 b3 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0105059:	e8 e6 f9 ff ff       	call   c0104a44 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010505e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105065:	e8 b9 dc ff ff       	call   c0102d23 <alloc_pages>
c010506a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c010506d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105071:	75 24                	jne    c0105097 <default_check+0x116>
c0105073:	c7 44 24 0c a7 70 10 	movl   $0xc01070a7,0xc(%esp)
c010507a:	c0 
c010507b:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0105082:	c0 
c0105083:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c010508a:	00 
c010508b:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0105092:	e8 52 b3 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0105097:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010509a:	83 c0 04             	add    $0x4,%eax
c010509d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c01050a4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01050a7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01050aa:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01050ad:	0f a3 10             	bt     %edx,(%eax)
c01050b0:	19 c0                	sbb    %eax,%eax
c01050b2:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c01050b5:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c01050b9:	0f 95 c0             	setne  %al
c01050bc:	0f b6 c0             	movzbl %al,%eax
c01050bf:	85 c0                	test   %eax,%eax
c01050c1:	74 24                	je     c01050e7 <default_check+0x166>
c01050c3:	c7 44 24 0c b2 70 10 	movl   $0xc01070b2,0xc(%esp)
c01050ca:	c0 
c01050cb:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01050d2:	c0 
c01050d3:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01050da:	00 
c01050db:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01050e2:	e8 02 b3 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c01050e7:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c01050ec:	8b 15 80 af 11 c0    	mov    0xc011af80,%edx
c01050f2:	89 45 80             	mov    %eax,-0x80(%ebp)
c01050f5:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01050f8:	c7 45 d0 7c af 11 c0 	movl   $0xc011af7c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01050ff:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105102:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105105:	89 50 04             	mov    %edx,0x4(%eax)
c0105108:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010510b:	8b 50 04             	mov    0x4(%eax),%edx
c010510e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105111:	89 10                	mov    %edx,(%eax)
c0105113:	c7 45 d8 7c af 11 c0 	movl   $0xc011af7c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010511a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010511d:	8b 40 04             	mov    0x4(%eax),%eax
c0105120:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105123:	0f 94 c0             	sete   %al
c0105126:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105129:	85 c0                	test   %eax,%eax
c010512b:	75 24                	jne    c0105151 <default_check+0x1d0>
c010512d:	c7 44 24 0c 07 70 10 	movl   $0xc0107007,0xc(%esp)
c0105134:	c0 
c0105135:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c010513c:	c0 
c010513d:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0105144:	00 
c0105145:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c010514c:	e8 98 b2 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0105151:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105158:	e8 c6 db ff ff       	call   c0102d23 <alloc_pages>
c010515d:	85 c0                	test   %eax,%eax
c010515f:	74 24                	je     c0105185 <default_check+0x204>
c0105161:	c7 44 24 0c 1e 70 10 	movl   $0xc010701e,0xc(%esp)
c0105168:	c0 
c0105169:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0105170:	c0 
c0105171:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c0105178:	00 
c0105179:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0105180:	e8 64 b2 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0105185:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c010518a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c010518d:	c7 05 84 af 11 c0 00 	movl   $0x0,0xc011af84
c0105194:	00 00 00 

    free_pages(p0 + 2, 3);
c0105197:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010519a:	83 c0 28             	add    $0x28,%eax
c010519d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01051a4:	00 
c01051a5:	89 04 24             	mov    %eax,(%esp)
c01051a8:	e8 ae db ff ff       	call   c0102d5b <free_pages>
    assert(alloc_pages(4) == NULL);
c01051ad:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01051b4:	e8 6a db ff ff       	call   c0102d23 <alloc_pages>
c01051b9:	85 c0                	test   %eax,%eax
c01051bb:	74 24                	je     c01051e1 <default_check+0x260>
c01051bd:	c7 44 24 0c c4 70 10 	movl   $0xc01070c4,0xc(%esp)
c01051c4:	c0 
c01051c5:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01051cc:	c0 
c01051cd:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01051d4:	00 
c01051d5:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01051dc:	e8 08 b2 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01051e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01051e4:	83 c0 28             	add    $0x28,%eax
c01051e7:	83 c0 04             	add    $0x4,%eax
c01051ea:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01051f1:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01051f4:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01051f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01051fa:	0f a3 10             	bt     %edx,(%eax)
c01051fd:	19 c0                	sbb    %eax,%eax
c01051ff:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105202:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105206:	0f 95 c0             	setne  %al
c0105209:	0f b6 c0             	movzbl %al,%eax
c010520c:	85 c0                	test   %eax,%eax
c010520e:	74 0e                	je     c010521e <default_check+0x29d>
c0105210:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105213:	83 c0 28             	add    $0x28,%eax
c0105216:	8b 40 08             	mov    0x8(%eax),%eax
c0105219:	83 f8 03             	cmp    $0x3,%eax
c010521c:	74 24                	je     c0105242 <default_check+0x2c1>
c010521e:	c7 44 24 0c dc 70 10 	movl   $0xc01070dc,0xc(%esp)
c0105225:	c0 
c0105226:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c010522d:	c0 
c010522e:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0105235:	00 
c0105236:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c010523d:	e8 a7 b1 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105242:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105249:	e8 d5 da ff ff       	call   c0102d23 <alloc_pages>
c010524e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0105251:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0105255:	75 24                	jne    c010527b <default_check+0x2fa>
c0105257:	c7 44 24 0c 08 71 10 	movl   $0xc0107108,0xc(%esp)
c010525e:	c0 
c010525f:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0105266:	c0 
c0105267:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c010526e:	00 
c010526f:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0105276:	e8 6e b1 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c010527b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105282:	e8 9c da ff ff       	call   c0102d23 <alloc_pages>
c0105287:	85 c0                	test   %eax,%eax
c0105289:	74 24                	je     c01052af <default_check+0x32e>
c010528b:	c7 44 24 0c 1e 70 10 	movl   $0xc010701e,0xc(%esp)
c0105292:	c0 
c0105293:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c010529a:	c0 
c010529b:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01052a2:	00 
c01052a3:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01052aa:	e8 3a b1 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c01052af:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052b2:	83 c0 28             	add    $0x28,%eax
c01052b5:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c01052b8:	74 24                	je     c01052de <default_check+0x35d>
c01052ba:	c7 44 24 0c 26 71 10 	movl   $0xc0107126,0xc(%esp)
c01052c1:	c0 
c01052c2:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01052c9:	c0 
c01052ca:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01052d1:	00 
c01052d2:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01052d9:	e8 0b b1 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c01052de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052e1:	83 c0 14             	add    $0x14,%eax
c01052e4:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c01052e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052ee:	00 
c01052ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052f2:	89 04 24             	mov    %eax,(%esp)
c01052f5:	e8 61 da ff ff       	call   c0102d5b <free_pages>
    free_pages(p1, 3);
c01052fa:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105301:	00 
c0105302:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105305:	89 04 24             	mov    %eax,(%esp)
c0105308:	e8 4e da ff ff       	call   c0102d5b <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010530d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105310:	83 c0 04             	add    $0x4,%eax
c0105313:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c010531a:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010531d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105320:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105323:	0f a3 10             	bt     %edx,(%eax)
c0105326:	19 c0                	sbb    %eax,%eax
c0105328:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c010532b:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c010532f:	0f 95 c0             	setne  %al
c0105332:	0f b6 c0             	movzbl %al,%eax
c0105335:	85 c0                	test   %eax,%eax
c0105337:	74 0b                	je     c0105344 <default_check+0x3c3>
c0105339:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010533c:	8b 40 08             	mov    0x8(%eax),%eax
c010533f:	83 f8 01             	cmp    $0x1,%eax
c0105342:	74 24                	je     c0105368 <default_check+0x3e7>
c0105344:	c7 44 24 0c 34 71 10 	movl   $0xc0107134,0xc(%esp)
c010534b:	c0 
c010534c:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0105353:	c0 
c0105354:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c010535b:	00 
c010535c:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0105363:	e8 81 b0 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105368:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010536b:	83 c0 04             	add    $0x4,%eax
c010536e:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105375:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105378:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010537b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010537e:	0f a3 10             	bt     %edx,(%eax)
c0105381:	19 c0                	sbb    %eax,%eax
c0105383:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0105386:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c010538a:	0f 95 c0             	setne  %al
c010538d:	0f b6 c0             	movzbl %al,%eax
c0105390:	85 c0                	test   %eax,%eax
c0105392:	74 0b                	je     c010539f <default_check+0x41e>
c0105394:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105397:	8b 40 08             	mov    0x8(%eax),%eax
c010539a:	83 f8 03             	cmp    $0x3,%eax
c010539d:	74 24                	je     c01053c3 <default_check+0x442>
c010539f:	c7 44 24 0c 5c 71 10 	movl   $0xc010715c,0xc(%esp)
c01053a6:	c0 
c01053a7:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01053ae:	c0 
c01053af:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c01053b6:	00 
c01053b7:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01053be:	e8 26 b0 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01053c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01053ca:	e8 54 d9 ff ff       	call   c0102d23 <alloc_pages>
c01053cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01053d2:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01053d5:	83 e8 14             	sub    $0x14,%eax
c01053d8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01053db:	74 24                	je     c0105401 <default_check+0x480>
c01053dd:	c7 44 24 0c 82 71 10 	movl   $0xc0107182,0xc(%esp)
c01053e4:	c0 
c01053e5:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01053ec:	c0 
c01053ed:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01053f4:	00 
c01053f5:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01053fc:	e8 e8 af ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c0105401:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105408:	00 
c0105409:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010540c:	89 04 24             	mov    %eax,(%esp)
c010540f:	e8 47 d9 ff ff       	call   c0102d5b <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0105414:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010541b:	e8 03 d9 ff ff       	call   c0102d23 <alloc_pages>
c0105420:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105423:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105426:	83 c0 14             	add    $0x14,%eax
c0105429:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010542c:	74 24                	je     c0105452 <default_check+0x4d1>
c010542e:	c7 44 24 0c a0 71 10 	movl   $0xc01071a0,0xc(%esp)
c0105435:	c0 
c0105436:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c010543d:	c0 
c010543e:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0105445:	00 
c0105446:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c010544d:	e8 97 af ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c0105452:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105459:	00 
c010545a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010545d:	89 04 24             	mov    %eax,(%esp)
c0105460:	e8 f6 d8 ff ff       	call   c0102d5b <free_pages>
    free_page(p2);
c0105465:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010546c:	00 
c010546d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105470:	89 04 24             	mov    %eax,(%esp)
c0105473:	e8 e3 d8 ff ff       	call   c0102d5b <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105478:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010547f:	e8 9f d8 ff ff       	call   c0102d23 <alloc_pages>
c0105484:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105487:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010548b:	75 24                	jne    c01054b1 <default_check+0x530>
c010548d:	c7 44 24 0c c0 71 10 	movl   $0xc01071c0,0xc(%esp)
c0105494:	c0 
c0105495:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c010549c:	c0 
c010549d:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c01054a4:	00 
c01054a5:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01054ac:	e8 38 af ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c01054b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01054b8:	e8 66 d8 ff ff       	call   c0102d23 <alloc_pages>
c01054bd:	85 c0                	test   %eax,%eax
c01054bf:	74 24                	je     c01054e5 <default_check+0x564>
c01054c1:	c7 44 24 0c 1e 70 10 	movl   $0xc010701e,0xc(%esp)
c01054c8:	c0 
c01054c9:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01054d0:	c0 
c01054d1:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01054d8:	00 
c01054d9:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01054e0:	e8 04 af ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c01054e5:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c01054ea:	85 c0                	test   %eax,%eax
c01054ec:	74 24                	je     c0105512 <default_check+0x591>
c01054ee:	c7 44 24 0c 71 70 10 	movl   $0xc0107071,0xc(%esp)
c01054f5:	c0 
c01054f6:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01054fd:	c0 
c01054fe:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0105505:	00 
c0105506:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c010550d:	e8 d7 ae ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c0105512:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105515:	a3 84 af 11 c0       	mov    %eax,0xc011af84

    free_list = free_list_store;
c010551a:	8b 45 80             	mov    -0x80(%ebp),%eax
c010551d:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105520:	a3 7c af 11 c0       	mov    %eax,0xc011af7c
c0105525:	89 15 80 af 11 c0    	mov    %edx,0xc011af80
    free_pages(p0, 5);
c010552b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0105532:	00 
c0105533:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105536:	89 04 24             	mov    %eax,(%esp)
c0105539:	e8 1d d8 ff ff       	call   c0102d5b <free_pages>

    le = &free_list;
c010553e:	c7 45 ec 7c af 11 c0 	movl   $0xc011af7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105545:	eb 1c                	jmp    c0105563 <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c0105547:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010554a:	83 e8 0c             	sub    $0xc,%eax
c010554d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c0105550:	ff 4d f4             	decl   -0xc(%ebp)
c0105553:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105556:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105559:	8b 40 08             	mov    0x8(%eax),%eax
c010555c:	29 c2                	sub    %eax,%edx
c010555e:	89 d0                	mov    %edx,%eax
c0105560:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105563:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105566:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105569:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010556c:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010556f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105572:	81 7d ec 7c af 11 c0 	cmpl   $0xc011af7c,-0x14(%ebp)
c0105579:	75 cc                	jne    c0105547 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c010557b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010557f:	74 24                	je     c01055a5 <default_check+0x624>
c0105581:	c7 44 24 0c de 71 10 	movl   $0xc01071de,0xc(%esp)
c0105588:	c0 
c0105589:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c0105590:	c0 
c0105591:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0105598:	00 
c0105599:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01055a0:	e8 44 ae ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c01055a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01055a9:	74 24                	je     c01055cf <default_check+0x64e>
c01055ab:	c7 44 24 0c e9 71 10 	movl   $0xc01071e9,0xc(%esp)
c01055b2:	c0 
c01055b3:	c7 44 24 08 7e 6e 10 	movl   $0xc0106e7e,0x8(%esp)
c01055ba:	c0 
c01055bb:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c01055c2:	00 
c01055c3:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c01055ca:	e8 1a ae ff ff       	call   c01003e9 <__panic>
}
c01055cf:	90                   	nop
c01055d0:	c9                   	leave  
c01055d1:	c3                   	ret    

c01055d2 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01055d2:	55                   	push   %ebp
c01055d3:	89 e5                	mov    %esp,%ebp
c01055d5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01055d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01055df:	eb 03                	jmp    c01055e4 <strlen+0x12>
        cnt ++;
c01055e1:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c01055e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055e7:	8d 50 01             	lea    0x1(%eax),%edx
c01055ea:	89 55 08             	mov    %edx,0x8(%ebp)
c01055ed:	0f b6 00             	movzbl (%eax),%eax
c01055f0:	84 c0                	test   %al,%al
c01055f2:	75 ed                	jne    c01055e1 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c01055f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01055f7:	c9                   	leave  
c01055f8:	c3                   	ret    

c01055f9 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01055f9:	55                   	push   %ebp
c01055fa:	89 e5                	mov    %esp,%ebp
c01055fc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01055ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105606:	eb 03                	jmp    c010560b <strnlen+0x12>
        cnt ++;
c0105608:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010560b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010560e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105611:	73 10                	jae    c0105623 <strnlen+0x2a>
c0105613:	8b 45 08             	mov    0x8(%ebp),%eax
c0105616:	8d 50 01             	lea    0x1(%eax),%edx
c0105619:	89 55 08             	mov    %edx,0x8(%ebp)
c010561c:	0f b6 00             	movzbl (%eax),%eax
c010561f:	84 c0                	test   %al,%al
c0105621:	75 e5                	jne    c0105608 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105623:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105626:	c9                   	leave  
c0105627:	c3                   	ret    

c0105628 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105628:	55                   	push   %ebp
c0105629:	89 e5                	mov    %esp,%ebp
c010562b:	57                   	push   %edi
c010562c:	56                   	push   %esi
c010562d:	83 ec 20             	sub    $0x20,%esp
c0105630:	8b 45 08             	mov    0x8(%ebp),%eax
c0105633:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105636:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105639:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010563c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105642:	89 d1                	mov    %edx,%ecx
c0105644:	89 c2                	mov    %eax,%edx
c0105646:	89 ce                	mov    %ecx,%esi
c0105648:	89 d7                	mov    %edx,%edi
c010564a:	ac                   	lods   %ds:(%esi),%al
c010564b:	aa                   	stos   %al,%es:(%edi)
c010564c:	84 c0                	test   %al,%al
c010564e:	75 fa                	jne    c010564a <strcpy+0x22>
c0105650:	89 fa                	mov    %edi,%edx
c0105652:	89 f1                	mov    %esi,%ecx
c0105654:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105657:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010565a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010565d:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0105660:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105661:	83 c4 20             	add    $0x20,%esp
c0105664:	5e                   	pop    %esi
c0105665:	5f                   	pop    %edi
c0105666:	5d                   	pop    %ebp
c0105667:	c3                   	ret    

c0105668 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105668:	55                   	push   %ebp
c0105669:	89 e5                	mov    %esp,%ebp
c010566b:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010566e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105671:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105674:	eb 1e                	jmp    c0105694 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0105676:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105679:	0f b6 10             	movzbl (%eax),%edx
c010567c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010567f:	88 10                	mov    %dl,(%eax)
c0105681:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105684:	0f b6 00             	movzbl (%eax),%eax
c0105687:	84 c0                	test   %al,%al
c0105689:	74 03                	je     c010568e <strncpy+0x26>
            src ++;
c010568b:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010568e:	ff 45 fc             	incl   -0x4(%ebp)
c0105691:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105694:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105698:	75 dc                	jne    c0105676 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010569a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010569d:	c9                   	leave  
c010569e:	c3                   	ret    

c010569f <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010569f:	55                   	push   %ebp
c01056a0:	89 e5                	mov    %esp,%ebp
c01056a2:	57                   	push   %edi
c01056a3:	56                   	push   %esi
c01056a4:	83 ec 20             	sub    $0x20,%esp
c01056a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01056aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01056ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c01056b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01056b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056b9:	89 d1                	mov    %edx,%ecx
c01056bb:	89 c2                	mov    %eax,%edx
c01056bd:	89 ce                	mov    %ecx,%esi
c01056bf:	89 d7                	mov    %edx,%edi
c01056c1:	ac                   	lods   %ds:(%esi),%al
c01056c2:	ae                   	scas   %es:(%edi),%al
c01056c3:	75 08                	jne    c01056cd <strcmp+0x2e>
c01056c5:	84 c0                	test   %al,%al
c01056c7:	75 f8                	jne    c01056c1 <strcmp+0x22>
c01056c9:	31 c0                	xor    %eax,%eax
c01056cb:	eb 04                	jmp    c01056d1 <strcmp+0x32>
c01056cd:	19 c0                	sbb    %eax,%eax
c01056cf:	0c 01                	or     $0x1,%al
c01056d1:	89 fa                	mov    %edi,%edx
c01056d3:	89 f1                	mov    %esi,%ecx
c01056d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01056d8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01056db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c01056de:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01056e1:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01056e2:	83 c4 20             	add    $0x20,%esp
c01056e5:	5e                   	pop    %esi
c01056e6:	5f                   	pop    %edi
c01056e7:	5d                   	pop    %ebp
c01056e8:	c3                   	ret    

c01056e9 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01056e9:	55                   	push   %ebp
c01056ea:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01056ec:	eb 09                	jmp    c01056f7 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c01056ee:	ff 4d 10             	decl   0x10(%ebp)
c01056f1:	ff 45 08             	incl   0x8(%ebp)
c01056f4:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01056f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01056fb:	74 1a                	je     c0105717 <strncmp+0x2e>
c01056fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105700:	0f b6 00             	movzbl (%eax),%eax
c0105703:	84 c0                	test   %al,%al
c0105705:	74 10                	je     c0105717 <strncmp+0x2e>
c0105707:	8b 45 08             	mov    0x8(%ebp),%eax
c010570a:	0f b6 10             	movzbl (%eax),%edx
c010570d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105710:	0f b6 00             	movzbl (%eax),%eax
c0105713:	38 c2                	cmp    %al,%dl
c0105715:	74 d7                	je     c01056ee <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105717:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010571b:	74 18                	je     c0105735 <strncmp+0x4c>
c010571d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105720:	0f b6 00             	movzbl (%eax),%eax
c0105723:	0f b6 d0             	movzbl %al,%edx
c0105726:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105729:	0f b6 00             	movzbl (%eax),%eax
c010572c:	0f b6 c0             	movzbl %al,%eax
c010572f:	29 c2                	sub    %eax,%edx
c0105731:	89 d0                	mov    %edx,%eax
c0105733:	eb 05                	jmp    c010573a <strncmp+0x51>
c0105735:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010573a:	5d                   	pop    %ebp
c010573b:	c3                   	ret    

c010573c <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010573c:	55                   	push   %ebp
c010573d:	89 e5                	mov    %esp,%ebp
c010573f:	83 ec 04             	sub    $0x4,%esp
c0105742:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105745:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105748:	eb 13                	jmp    c010575d <strchr+0x21>
        if (*s == c) {
c010574a:	8b 45 08             	mov    0x8(%ebp),%eax
c010574d:	0f b6 00             	movzbl (%eax),%eax
c0105750:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105753:	75 05                	jne    c010575a <strchr+0x1e>
            return (char *)s;
c0105755:	8b 45 08             	mov    0x8(%ebp),%eax
c0105758:	eb 12                	jmp    c010576c <strchr+0x30>
        }
        s ++;
c010575a:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010575d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105760:	0f b6 00             	movzbl (%eax),%eax
c0105763:	84 c0                	test   %al,%al
c0105765:	75 e3                	jne    c010574a <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105767:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010576c:	c9                   	leave  
c010576d:	c3                   	ret    

c010576e <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010576e:	55                   	push   %ebp
c010576f:	89 e5                	mov    %esp,%ebp
c0105771:	83 ec 04             	sub    $0x4,%esp
c0105774:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105777:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010577a:	eb 0e                	jmp    c010578a <strfind+0x1c>
        if (*s == c) {
c010577c:	8b 45 08             	mov    0x8(%ebp),%eax
c010577f:	0f b6 00             	movzbl (%eax),%eax
c0105782:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105785:	74 0f                	je     c0105796 <strfind+0x28>
            break;
        }
        s ++;
c0105787:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010578a:	8b 45 08             	mov    0x8(%ebp),%eax
c010578d:	0f b6 00             	movzbl (%eax),%eax
c0105790:	84 c0                	test   %al,%al
c0105792:	75 e8                	jne    c010577c <strfind+0xe>
c0105794:	eb 01                	jmp    c0105797 <strfind+0x29>
        if (*s == c) {
            break;
c0105796:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0105797:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010579a:	c9                   	leave  
c010579b:	c3                   	ret    

c010579c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010579c:	55                   	push   %ebp
c010579d:	89 e5                	mov    %esp,%ebp
c010579f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01057a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01057a9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01057b0:	eb 03                	jmp    c01057b5 <strtol+0x19>
        s ++;
c01057b2:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01057b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01057b8:	0f b6 00             	movzbl (%eax),%eax
c01057bb:	3c 20                	cmp    $0x20,%al
c01057bd:	74 f3                	je     c01057b2 <strtol+0x16>
c01057bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01057c2:	0f b6 00             	movzbl (%eax),%eax
c01057c5:	3c 09                	cmp    $0x9,%al
c01057c7:	74 e9                	je     c01057b2 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c01057c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01057cc:	0f b6 00             	movzbl (%eax),%eax
c01057cf:	3c 2b                	cmp    $0x2b,%al
c01057d1:	75 05                	jne    c01057d8 <strtol+0x3c>
        s ++;
c01057d3:	ff 45 08             	incl   0x8(%ebp)
c01057d6:	eb 14                	jmp    c01057ec <strtol+0x50>
    }
    else if (*s == '-') {
c01057d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01057db:	0f b6 00             	movzbl (%eax),%eax
c01057de:	3c 2d                	cmp    $0x2d,%al
c01057e0:	75 0a                	jne    c01057ec <strtol+0x50>
        s ++, neg = 1;
c01057e2:	ff 45 08             	incl   0x8(%ebp)
c01057e5:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01057ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01057f0:	74 06                	je     c01057f8 <strtol+0x5c>
c01057f2:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01057f6:	75 22                	jne    c010581a <strtol+0x7e>
c01057f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01057fb:	0f b6 00             	movzbl (%eax),%eax
c01057fe:	3c 30                	cmp    $0x30,%al
c0105800:	75 18                	jne    c010581a <strtol+0x7e>
c0105802:	8b 45 08             	mov    0x8(%ebp),%eax
c0105805:	40                   	inc    %eax
c0105806:	0f b6 00             	movzbl (%eax),%eax
c0105809:	3c 78                	cmp    $0x78,%al
c010580b:	75 0d                	jne    c010581a <strtol+0x7e>
        s += 2, base = 16;
c010580d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105811:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105818:	eb 29                	jmp    c0105843 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c010581a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010581e:	75 16                	jne    c0105836 <strtol+0x9a>
c0105820:	8b 45 08             	mov    0x8(%ebp),%eax
c0105823:	0f b6 00             	movzbl (%eax),%eax
c0105826:	3c 30                	cmp    $0x30,%al
c0105828:	75 0c                	jne    c0105836 <strtol+0x9a>
        s ++, base = 8;
c010582a:	ff 45 08             	incl   0x8(%ebp)
c010582d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105834:	eb 0d                	jmp    c0105843 <strtol+0xa7>
    }
    else if (base == 0) {
c0105836:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010583a:	75 07                	jne    c0105843 <strtol+0xa7>
        base = 10;
c010583c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105843:	8b 45 08             	mov    0x8(%ebp),%eax
c0105846:	0f b6 00             	movzbl (%eax),%eax
c0105849:	3c 2f                	cmp    $0x2f,%al
c010584b:	7e 1b                	jle    c0105868 <strtol+0xcc>
c010584d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105850:	0f b6 00             	movzbl (%eax),%eax
c0105853:	3c 39                	cmp    $0x39,%al
c0105855:	7f 11                	jg     c0105868 <strtol+0xcc>
            dig = *s - '0';
c0105857:	8b 45 08             	mov    0x8(%ebp),%eax
c010585a:	0f b6 00             	movzbl (%eax),%eax
c010585d:	0f be c0             	movsbl %al,%eax
c0105860:	83 e8 30             	sub    $0x30,%eax
c0105863:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105866:	eb 48                	jmp    c01058b0 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105868:	8b 45 08             	mov    0x8(%ebp),%eax
c010586b:	0f b6 00             	movzbl (%eax),%eax
c010586e:	3c 60                	cmp    $0x60,%al
c0105870:	7e 1b                	jle    c010588d <strtol+0xf1>
c0105872:	8b 45 08             	mov    0x8(%ebp),%eax
c0105875:	0f b6 00             	movzbl (%eax),%eax
c0105878:	3c 7a                	cmp    $0x7a,%al
c010587a:	7f 11                	jg     c010588d <strtol+0xf1>
            dig = *s - 'a' + 10;
c010587c:	8b 45 08             	mov    0x8(%ebp),%eax
c010587f:	0f b6 00             	movzbl (%eax),%eax
c0105882:	0f be c0             	movsbl %al,%eax
c0105885:	83 e8 57             	sub    $0x57,%eax
c0105888:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010588b:	eb 23                	jmp    c01058b0 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010588d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105890:	0f b6 00             	movzbl (%eax),%eax
c0105893:	3c 40                	cmp    $0x40,%al
c0105895:	7e 3b                	jle    c01058d2 <strtol+0x136>
c0105897:	8b 45 08             	mov    0x8(%ebp),%eax
c010589a:	0f b6 00             	movzbl (%eax),%eax
c010589d:	3c 5a                	cmp    $0x5a,%al
c010589f:	7f 31                	jg     c01058d2 <strtol+0x136>
            dig = *s - 'A' + 10;
c01058a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01058a4:	0f b6 00             	movzbl (%eax),%eax
c01058a7:	0f be c0             	movsbl %al,%eax
c01058aa:	83 e8 37             	sub    $0x37,%eax
c01058ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01058b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058b3:	3b 45 10             	cmp    0x10(%ebp),%eax
c01058b6:	7d 19                	jge    c01058d1 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01058b8:	ff 45 08             	incl   0x8(%ebp)
c01058bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01058be:	0f af 45 10          	imul   0x10(%ebp),%eax
c01058c2:	89 c2                	mov    %eax,%edx
c01058c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058c7:	01 d0                	add    %edx,%eax
c01058c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c01058cc:	e9 72 ff ff ff       	jmp    c0105843 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c01058d1:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c01058d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01058d6:	74 08                	je     c01058e0 <strtol+0x144>
        *endptr = (char *) s;
c01058d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058db:	8b 55 08             	mov    0x8(%ebp),%edx
c01058de:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01058e0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01058e4:	74 07                	je     c01058ed <strtol+0x151>
c01058e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01058e9:	f7 d8                	neg    %eax
c01058eb:	eb 03                	jmp    c01058f0 <strtol+0x154>
c01058ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01058f0:	c9                   	leave  
c01058f1:	c3                   	ret    

c01058f2 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01058f2:	55                   	push   %ebp
c01058f3:	89 e5                	mov    %esp,%ebp
c01058f5:	57                   	push   %edi
c01058f6:	83 ec 24             	sub    $0x24,%esp
c01058f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058fc:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01058ff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105903:	8b 55 08             	mov    0x8(%ebp),%edx
c0105906:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105909:	88 45 f7             	mov    %al,-0x9(%ebp)
c010590c:	8b 45 10             	mov    0x10(%ebp),%eax
c010590f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105912:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105915:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105919:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010591c:	89 d7                	mov    %edx,%edi
c010591e:	f3 aa                	rep stos %al,%es:(%edi)
c0105920:	89 fa                	mov    %edi,%edx
c0105922:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105925:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105928:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010592b:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010592c:	83 c4 24             	add    $0x24,%esp
c010592f:	5f                   	pop    %edi
c0105930:	5d                   	pop    %ebp
c0105931:	c3                   	ret    

c0105932 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105932:	55                   	push   %ebp
c0105933:	89 e5                	mov    %esp,%ebp
c0105935:	57                   	push   %edi
c0105936:	56                   	push   %esi
c0105937:	53                   	push   %ebx
c0105938:	83 ec 30             	sub    $0x30,%esp
c010593b:	8b 45 08             	mov    0x8(%ebp),%eax
c010593e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105941:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105944:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105947:	8b 45 10             	mov    0x10(%ebp),%eax
c010594a:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010594d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105950:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105953:	73 42                	jae    c0105997 <memmove+0x65>
c0105955:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105958:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010595b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010595e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105961:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105964:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105967:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010596a:	c1 e8 02             	shr    $0x2,%eax
c010596d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010596f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105972:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105975:	89 d7                	mov    %edx,%edi
c0105977:	89 c6                	mov    %eax,%esi
c0105979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010597b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010597e:	83 e1 03             	and    $0x3,%ecx
c0105981:	74 02                	je     c0105985 <memmove+0x53>
c0105983:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105985:	89 f0                	mov    %esi,%eax
c0105987:	89 fa                	mov    %edi,%edx
c0105989:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010598c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010598f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0105995:	eb 36                	jmp    c01059cd <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105997:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010599a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010599d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059a0:	01 c2                	add    %eax,%edx
c01059a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059a5:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01059a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059ab:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c01059ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059b1:	89 c1                	mov    %eax,%ecx
c01059b3:	89 d8                	mov    %ebx,%eax
c01059b5:	89 d6                	mov    %edx,%esi
c01059b7:	89 c7                	mov    %eax,%edi
c01059b9:	fd                   	std    
c01059ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01059bc:	fc                   	cld    
c01059bd:	89 f8                	mov    %edi,%eax
c01059bf:	89 f2                	mov    %esi,%edx
c01059c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01059c4:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01059c7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c01059ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01059cd:	83 c4 30             	add    $0x30,%esp
c01059d0:	5b                   	pop    %ebx
c01059d1:	5e                   	pop    %esi
c01059d2:	5f                   	pop    %edi
c01059d3:	5d                   	pop    %ebp
c01059d4:	c3                   	ret    

c01059d5 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01059d5:	55                   	push   %ebp
c01059d6:	89 e5                	mov    %esp,%ebp
c01059d8:	57                   	push   %edi
c01059d9:	56                   	push   %esi
c01059da:	83 ec 20             	sub    $0x20,%esp
c01059dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01059e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01059ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01059ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059f2:	c1 e8 02             	shr    $0x2,%eax
c01059f5:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01059f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059fd:	89 d7                	mov    %edx,%edi
c01059ff:	89 c6                	mov    %eax,%esi
c0105a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105a03:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105a06:	83 e1 03             	and    $0x3,%ecx
c0105a09:	74 02                	je     c0105a0d <memcpy+0x38>
c0105a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105a0d:	89 f0                	mov    %esi,%eax
c0105a0f:	89 fa                	mov    %edi,%edx
c0105a11:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105a14:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105a17:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0105a1d:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105a1e:	83 c4 20             	add    $0x20,%esp
c0105a21:	5e                   	pop    %esi
c0105a22:	5f                   	pop    %edi
c0105a23:	5d                   	pop    %ebp
c0105a24:	c3                   	ret    

c0105a25 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105a25:	55                   	push   %ebp
c0105a26:	89 e5                	mov    %esp,%ebp
c0105a28:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105a2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105a31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a34:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105a37:	eb 2e                	jmp    c0105a67 <memcmp+0x42>
        if (*s1 != *s2) {
c0105a39:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a3c:	0f b6 10             	movzbl (%eax),%edx
c0105a3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105a42:	0f b6 00             	movzbl (%eax),%eax
c0105a45:	38 c2                	cmp    %al,%dl
c0105a47:	74 18                	je     c0105a61 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a4c:	0f b6 00             	movzbl (%eax),%eax
c0105a4f:	0f b6 d0             	movzbl %al,%edx
c0105a52:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105a55:	0f b6 00             	movzbl (%eax),%eax
c0105a58:	0f b6 c0             	movzbl %al,%eax
c0105a5b:	29 c2                	sub    %eax,%edx
c0105a5d:	89 d0                	mov    %edx,%eax
c0105a5f:	eb 18                	jmp    c0105a79 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0105a61:	ff 45 fc             	incl   -0x4(%ebp)
c0105a64:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105a67:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a6a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a6d:	89 55 10             	mov    %edx,0x10(%ebp)
c0105a70:	85 c0                	test   %eax,%eax
c0105a72:	75 c5                	jne    c0105a39 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105a79:	c9                   	leave  
c0105a7a:	c3                   	ret    

c0105a7b <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105a7b:	55                   	push   %ebp
c0105a7c:	89 e5                	mov    %esp,%ebp
c0105a7e:	83 ec 58             	sub    $0x58,%esp
c0105a81:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a84:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105a87:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105a8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105a90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105a93:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a96:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105a99:	8b 45 18             	mov    0x18(%ebp),%eax
c0105a9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105a9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105aa2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105aa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105aa8:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ab1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105ab5:	74 1c                	je     c0105ad3 <printnum+0x58>
c0105ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aba:	ba 00 00 00 00       	mov    $0x0,%edx
c0105abf:	f7 75 e4             	divl   -0x1c(%ebp)
c0105ac2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ac8:	ba 00 00 00 00       	mov    $0x0,%edx
c0105acd:	f7 75 e4             	divl   -0x1c(%ebp)
c0105ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ad3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ad6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ad9:	f7 75 e4             	divl   -0x1c(%ebp)
c0105adc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105adf:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105ae2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ae5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ae8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105aeb:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105aee:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105af1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105af4:	8b 45 18             	mov    0x18(%ebp),%eax
c0105af7:	ba 00 00 00 00       	mov    $0x0,%edx
c0105afc:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105aff:	77 56                	ja     c0105b57 <printnum+0xdc>
c0105b01:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105b04:	72 05                	jb     c0105b0b <printnum+0x90>
c0105b06:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105b09:	77 4c                	ja     c0105b57 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105b0b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105b0e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105b11:	8b 45 20             	mov    0x20(%ebp),%eax
c0105b14:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105b18:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105b1c:	8b 45 18             	mov    0x18(%ebp),%eax
c0105b1f:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105b23:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b26:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b29:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b2d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105b31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b38:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b3b:	89 04 24             	mov    %eax,(%esp)
c0105b3e:	e8 38 ff ff ff       	call   c0105a7b <printnum>
c0105b43:	eb 1b                	jmp    c0105b60 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105b45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b4c:	8b 45 20             	mov    0x20(%ebp),%eax
c0105b4f:	89 04 24             	mov    %eax,(%esp)
c0105b52:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b55:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105b57:	ff 4d 1c             	decl   0x1c(%ebp)
c0105b5a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105b5e:	7f e5                	jg     c0105b45 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105b60:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105b63:	05 a4 72 10 c0       	add    $0xc01072a4,%eax
c0105b68:	0f b6 00             	movzbl (%eax),%eax
c0105b6b:	0f be c0             	movsbl %al,%eax
c0105b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b71:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b75:	89 04 24             	mov    %eax,(%esp)
c0105b78:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b7b:	ff d0                	call   *%eax
}
c0105b7d:	90                   	nop
c0105b7e:	c9                   	leave  
c0105b7f:	c3                   	ret    

c0105b80 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105b80:	55                   	push   %ebp
c0105b81:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105b83:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105b87:	7e 14                	jle    c0105b9d <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105b89:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b8c:	8b 00                	mov    (%eax),%eax
c0105b8e:	8d 48 08             	lea    0x8(%eax),%ecx
c0105b91:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b94:	89 0a                	mov    %ecx,(%edx)
c0105b96:	8b 50 04             	mov    0x4(%eax),%edx
c0105b99:	8b 00                	mov    (%eax),%eax
c0105b9b:	eb 30                	jmp    c0105bcd <getuint+0x4d>
    }
    else if (lflag) {
c0105b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ba1:	74 16                	je     c0105bb9 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ba6:	8b 00                	mov    (%eax),%eax
c0105ba8:	8d 48 04             	lea    0x4(%eax),%ecx
c0105bab:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bae:	89 0a                	mov    %ecx,(%edx)
c0105bb0:	8b 00                	mov    (%eax),%eax
c0105bb2:	ba 00 00 00 00       	mov    $0x0,%edx
c0105bb7:	eb 14                	jmp    c0105bcd <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bbc:	8b 00                	mov    (%eax),%eax
c0105bbe:	8d 48 04             	lea    0x4(%eax),%ecx
c0105bc1:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bc4:	89 0a                	mov    %ecx,(%edx)
c0105bc6:	8b 00                	mov    (%eax),%eax
c0105bc8:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105bcd:	5d                   	pop    %ebp
c0105bce:	c3                   	ret    

c0105bcf <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105bcf:	55                   	push   %ebp
c0105bd0:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105bd2:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105bd6:	7e 14                	jle    c0105bec <getint+0x1d>
        return va_arg(*ap, long long);
c0105bd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bdb:	8b 00                	mov    (%eax),%eax
c0105bdd:	8d 48 08             	lea    0x8(%eax),%ecx
c0105be0:	8b 55 08             	mov    0x8(%ebp),%edx
c0105be3:	89 0a                	mov    %ecx,(%edx)
c0105be5:	8b 50 04             	mov    0x4(%eax),%edx
c0105be8:	8b 00                	mov    (%eax),%eax
c0105bea:	eb 28                	jmp    c0105c14 <getint+0x45>
    }
    else if (lflag) {
c0105bec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105bf0:	74 12                	je     c0105c04 <getint+0x35>
        return va_arg(*ap, long);
c0105bf2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf5:	8b 00                	mov    (%eax),%eax
c0105bf7:	8d 48 04             	lea    0x4(%eax),%ecx
c0105bfa:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bfd:	89 0a                	mov    %ecx,(%edx)
c0105bff:	8b 00                	mov    (%eax),%eax
c0105c01:	99                   	cltd   
c0105c02:	eb 10                	jmp    c0105c14 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c07:	8b 00                	mov    (%eax),%eax
c0105c09:	8d 48 04             	lea    0x4(%eax),%ecx
c0105c0c:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c0f:	89 0a                	mov    %ecx,(%edx)
c0105c11:	8b 00                	mov    (%eax),%eax
c0105c13:	99                   	cltd   
    }
}
c0105c14:	5d                   	pop    %ebp
c0105c15:	c3                   	ret    

c0105c16 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105c16:	55                   	push   %ebp
c0105c17:	89 e5                	mov    %esp,%ebp
c0105c19:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105c1c:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c25:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105c29:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c2c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c30:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c37:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c3a:	89 04 24             	mov    %eax,(%esp)
c0105c3d:	e8 03 00 00 00       	call   c0105c45 <vprintfmt>
    va_end(ap);
}
c0105c42:	90                   	nop
c0105c43:	c9                   	leave  
c0105c44:	c3                   	ret    

c0105c45 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105c45:	55                   	push   %ebp
c0105c46:	89 e5                	mov    %esp,%ebp
c0105c48:	56                   	push   %esi
c0105c49:	53                   	push   %ebx
c0105c4a:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105c4d:	eb 17                	jmp    c0105c66 <vprintfmt+0x21>
            if (ch == '\0') {
c0105c4f:	85 db                	test   %ebx,%ebx
c0105c51:	0f 84 bf 03 00 00    	je     c0106016 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0105c57:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c5e:	89 1c 24             	mov    %ebx,(%esp)
c0105c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c64:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105c66:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c69:	8d 50 01             	lea    0x1(%eax),%edx
c0105c6c:	89 55 10             	mov    %edx,0x10(%ebp)
c0105c6f:	0f b6 00             	movzbl (%eax),%eax
c0105c72:	0f b6 d8             	movzbl %al,%ebx
c0105c75:	83 fb 25             	cmp    $0x25,%ebx
c0105c78:	75 d5                	jne    c0105c4f <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105c7a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105c7e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c88:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105c8b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105c92:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c95:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105c98:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c9b:	8d 50 01             	lea    0x1(%eax),%edx
c0105c9e:	89 55 10             	mov    %edx,0x10(%ebp)
c0105ca1:	0f b6 00             	movzbl (%eax),%eax
c0105ca4:	0f b6 d8             	movzbl %al,%ebx
c0105ca7:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105caa:	83 f8 55             	cmp    $0x55,%eax
c0105cad:	0f 87 37 03 00 00    	ja     c0105fea <vprintfmt+0x3a5>
c0105cb3:	8b 04 85 c8 72 10 c0 	mov    -0x3fef8d38(,%eax,4),%eax
c0105cba:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105cbc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105cc0:	eb d6                	jmp    c0105c98 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105cc2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105cc6:	eb d0                	jmp    c0105c98 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105cc8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105ccf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105cd2:	89 d0                	mov    %edx,%eax
c0105cd4:	c1 e0 02             	shl    $0x2,%eax
c0105cd7:	01 d0                	add    %edx,%eax
c0105cd9:	01 c0                	add    %eax,%eax
c0105cdb:	01 d8                	add    %ebx,%eax
c0105cdd:	83 e8 30             	sub    $0x30,%eax
c0105ce0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105ce3:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ce6:	0f b6 00             	movzbl (%eax),%eax
c0105ce9:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105cec:	83 fb 2f             	cmp    $0x2f,%ebx
c0105cef:	7e 38                	jle    c0105d29 <vprintfmt+0xe4>
c0105cf1:	83 fb 39             	cmp    $0x39,%ebx
c0105cf4:	7f 33                	jg     c0105d29 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105cf6:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0105cf9:	eb d4                	jmp    c0105ccf <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105cfb:	8b 45 14             	mov    0x14(%ebp),%eax
c0105cfe:	8d 50 04             	lea    0x4(%eax),%edx
c0105d01:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d04:	8b 00                	mov    (%eax),%eax
c0105d06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105d09:	eb 1f                	jmp    c0105d2a <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105d0b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105d0f:	79 87                	jns    c0105c98 <vprintfmt+0x53>
                width = 0;
c0105d11:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105d18:	e9 7b ff ff ff       	jmp    c0105c98 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105d1d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105d24:	e9 6f ff ff ff       	jmp    c0105c98 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c0105d29:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c0105d2a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105d2e:	0f 89 64 ff ff ff    	jns    c0105c98 <vprintfmt+0x53>
                width = precision, precision = -1;
c0105d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d37:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105d3a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105d41:	e9 52 ff ff ff       	jmp    c0105c98 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105d46:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105d49:	e9 4a ff ff ff       	jmp    c0105c98 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105d4e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d51:	8d 50 04             	lea    0x4(%eax),%edx
c0105d54:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d57:	8b 00                	mov    (%eax),%eax
c0105d59:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105d5c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d60:	89 04 24             	mov    %eax,(%esp)
c0105d63:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d66:	ff d0                	call   *%eax
            break;
c0105d68:	e9 a4 02 00 00       	jmp    c0106011 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105d6d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d70:	8d 50 04             	lea    0x4(%eax),%edx
c0105d73:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d76:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105d78:	85 db                	test   %ebx,%ebx
c0105d7a:	79 02                	jns    c0105d7e <vprintfmt+0x139>
                err = -err;
c0105d7c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105d7e:	83 fb 06             	cmp    $0x6,%ebx
c0105d81:	7f 0b                	jg     c0105d8e <vprintfmt+0x149>
c0105d83:	8b 34 9d 88 72 10 c0 	mov    -0x3fef8d78(,%ebx,4),%esi
c0105d8a:	85 f6                	test   %esi,%esi
c0105d8c:	75 23                	jne    c0105db1 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105d8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105d92:	c7 44 24 08 b5 72 10 	movl   $0xc01072b5,0x8(%esp)
c0105d99:	c0 
c0105d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105da1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da4:	89 04 24             	mov    %eax,(%esp)
c0105da7:	e8 6a fe ff ff       	call   c0105c16 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105dac:	e9 60 02 00 00       	jmp    c0106011 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0105db1:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105db5:	c7 44 24 08 be 72 10 	movl   $0xc01072be,0x8(%esp)
c0105dbc:	c0 
c0105dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dc7:	89 04 24             	mov    %eax,(%esp)
c0105dca:	e8 47 fe ff ff       	call   c0105c16 <printfmt>
            }
            break;
c0105dcf:	e9 3d 02 00 00       	jmp    c0106011 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105dd4:	8b 45 14             	mov    0x14(%ebp),%eax
c0105dd7:	8d 50 04             	lea    0x4(%eax),%edx
c0105dda:	89 55 14             	mov    %edx,0x14(%ebp)
c0105ddd:	8b 30                	mov    (%eax),%esi
c0105ddf:	85 f6                	test   %esi,%esi
c0105de1:	75 05                	jne    c0105de8 <vprintfmt+0x1a3>
                p = "(null)";
c0105de3:	be c1 72 10 c0       	mov    $0xc01072c1,%esi
            }
            if (width > 0 && padc != '-') {
c0105de8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105dec:	7e 76                	jle    c0105e64 <vprintfmt+0x21f>
c0105dee:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105df2:	74 70                	je     c0105e64 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105df7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dfb:	89 34 24             	mov    %esi,(%esp)
c0105dfe:	e8 f6 f7 ff ff       	call   c01055f9 <strnlen>
c0105e03:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105e06:	29 c2                	sub    %eax,%edx
c0105e08:	89 d0                	mov    %edx,%eax
c0105e0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105e0d:	eb 16                	jmp    c0105e25 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105e0f:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105e13:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105e16:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e1a:	89 04 24             	mov    %eax,(%esp)
c0105e1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e20:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105e22:	ff 4d e8             	decl   -0x18(%ebp)
c0105e25:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e29:	7f e4                	jg     c0105e0f <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105e2b:	eb 37                	jmp    c0105e64 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105e2d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105e31:	74 1f                	je     c0105e52 <vprintfmt+0x20d>
c0105e33:	83 fb 1f             	cmp    $0x1f,%ebx
c0105e36:	7e 05                	jle    c0105e3d <vprintfmt+0x1f8>
c0105e38:	83 fb 7e             	cmp    $0x7e,%ebx
c0105e3b:	7e 15                	jle    c0105e52 <vprintfmt+0x20d>
                    putch('?', putdat);
c0105e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e44:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105e4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e4e:	ff d0                	call   *%eax
c0105e50:	eb 0f                	jmp    c0105e61 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105e52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e55:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e59:	89 1c 24             	mov    %ebx,(%esp)
c0105e5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e5f:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105e61:	ff 4d e8             	decl   -0x18(%ebp)
c0105e64:	89 f0                	mov    %esi,%eax
c0105e66:	8d 70 01             	lea    0x1(%eax),%esi
c0105e69:	0f b6 00             	movzbl (%eax),%eax
c0105e6c:	0f be d8             	movsbl %al,%ebx
c0105e6f:	85 db                	test   %ebx,%ebx
c0105e71:	74 27                	je     c0105e9a <vprintfmt+0x255>
c0105e73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e77:	78 b4                	js     c0105e2d <vprintfmt+0x1e8>
c0105e79:	ff 4d e4             	decl   -0x1c(%ebp)
c0105e7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e80:	79 ab                	jns    c0105e2d <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105e82:	eb 16                	jmp    c0105e9a <vprintfmt+0x255>
                putch(' ', putdat);
c0105e84:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e8b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105e92:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e95:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105e97:	ff 4d e8             	decl   -0x18(%ebp)
c0105e9a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e9e:	7f e4                	jg     c0105e84 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
c0105ea0:	e9 6c 01 00 00       	jmp    c0106011 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105ea5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eac:	8d 45 14             	lea    0x14(%ebp),%eax
c0105eaf:	89 04 24             	mov    %eax,(%esp)
c0105eb2:	e8 18 fd ff ff       	call   c0105bcf <getint>
c0105eb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105eba:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ec0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ec3:	85 d2                	test   %edx,%edx
c0105ec5:	79 26                	jns    c0105eed <vprintfmt+0x2a8>
                putch('-', putdat);
c0105ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eca:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ece:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105ed5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed8:	ff d0                	call   *%eax
                num = -(long long)num;
c0105eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105edd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ee0:	f7 d8                	neg    %eax
c0105ee2:	83 d2 00             	adc    $0x0,%edx
c0105ee5:	f7 da                	neg    %edx
c0105ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105eea:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105eed:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105ef4:	e9 a8 00 00 00       	jmp    c0105fa1 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105efc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f00:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f03:	89 04 24             	mov    %eax,(%esp)
c0105f06:	e8 75 fc ff ff       	call   c0105b80 <getuint>
c0105f0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f0e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105f11:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105f18:	e9 84 00 00 00       	jmp    c0105fa1 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105f1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f24:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f27:	89 04 24             	mov    %eax,(%esp)
c0105f2a:	e8 51 fc ff ff       	call   c0105b80 <getuint>
c0105f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f32:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105f35:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105f3c:	eb 63                	jmp    c0105fa1 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f45:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105f4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f4f:	ff d0                	call   *%eax
            putch('x', putdat);
c0105f51:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f54:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f58:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105f5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f62:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105f64:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f67:	8d 50 04             	lea    0x4(%eax),%edx
c0105f6a:	89 55 14             	mov    %edx,0x14(%ebp)
c0105f6d:	8b 00                	mov    (%eax),%eax
c0105f6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105f79:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105f80:	eb 1f                	jmp    c0105fa1 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105f82:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f89:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f8c:	89 04 24             	mov    %eax,(%esp)
c0105f8f:	e8 ec fb ff ff       	call   c0105b80 <getuint>
c0105f94:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f97:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105f9a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105fa1:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105fa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105fa8:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105fac:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105faf:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105fb3:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fbd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105fc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fcf:	89 04 24             	mov    %eax,(%esp)
c0105fd2:	e8 a4 fa ff ff       	call   c0105a7b <printnum>
            break;
c0105fd7:	eb 38                	jmp    c0106011 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fe0:	89 1c 24             	mov    %ebx,(%esp)
c0105fe3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fe6:	ff d0                	call   *%eax
            break;
c0105fe8:	eb 27                	jmp    c0106011 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105fea:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fed:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ff1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105ff8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ffb:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105ffd:	ff 4d 10             	decl   0x10(%ebp)
c0106000:	eb 03                	jmp    c0106005 <vprintfmt+0x3c0>
c0106002:	ff 4d 10             	decl   0x10(%ebp)
c0106005:	8b 45 10             	mov    0x10(%ebp),%eax
c0106008:	48                   	dec    %eax
c0106009:	0f b6 00             	movzbl (%eax),%eax
c010600c:	3c 25                	cmp    $0x25,%al
c010600e:	75 f2                	jne    c0106002 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106010:	90                   	nop
        }
    }
c0106011:	e9 37 fc ff ff       	jmp    c0105c4d <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c0106016:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0106017:	83 c4 40             	add    $0x40,%esp
c010601a:	5b                   	pop    %ebx
c010601b:	5e                   	pop    %esi
c010601c:	5d                   	pop    %ebp
c010601d:	c3                   	ret    

c010601e <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010601e:	55                   	push   %ebp
c010601f:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106021:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106024:	8b 40 08             	mov    0x8(%eax),%eax
c0106027:	8d 50 01             	lea    0x1(%eax),%edx
c010602a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010602d:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106030:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106033:	8b 10                	mov    (%eax),%edx
c0106035:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106038:	8b 40 04             	mov    0x4(%eax),%eax
c010603b:	39 c2                	cmp    %eax,%edx
c010603d:	73 12                	jae    c0106051 <sprintputch+0x33>
        *b->buf ++ = ch;
c010603f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106042:	8b 00                	mov    (%eax),%eax
c0106044:	8d 48 01             	lea    0x1(%eax),%ecx
c0106047:	8b 55 0c             	mov    0xc(%ebp),%edx
c010604a:	89 0a                	mov    %ecx,(%edx)
c010604c:	8b 55 08             	mov    0x8(%ebp),%edx
c010604f:	88 10                	mov    %dl,(%eax)
    }
}
c0106051:	90                   	nop
c0106052:	5d                   	pop    %ebp
c0106053:	c3                   	ret    

c0106054 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106054:	55                   	push   %ebp
c0106055:	89 e5                	mov    %esp,%ebp
c0106057:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010605a:	8d 45 14             	lea    0x14(%ebp),%eax
c010605d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106060:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106063:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106067:	8b 45 10             	mov    0x10(%ebp),%eax
c010606a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010606e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106075:	8b 45 08             	mov    0x8(%ebp),%eax
c0106078:	89 04 24             	mov    %eax,(%esp)
c010607b:	e8 08 00 00 00       	call   c0106088 <vsnprintf>
c0106080:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106083:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106086:	c9                   	leave  
c0106087:	c3                   	ret    

c0106088 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106088:	55                   	push   %ebp
c0106089:	89 e5                	mov    %esp,%ebp
c010608b:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010608e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106091:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106094:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106097:	8d 50 ff             	lea    -0x1(%eax),%edx
c010609a:	8b 45 08             	mov    0x8(%ebp),%eax
c010609d:	01 d0                	add    %edx,%eax
c010609f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01060a9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01060ad:	74 0a                	je     c01060b9 <vsnprintf+0x31>
c01060af:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01060b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060b5:	39 c2                	cmp    %eax,%edx
c01060b7:	76 07                	jbe    c01060c0 <vsnprintf+0x38>
        return -E_INVAL;
c01060b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01060be:	eb 2a                	jmp    c01060ea <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01060c0:	8b 45 14             	mov    0x14(%ebp),%eax
c01060c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01060c7:	8b 45 10             	mov    0x10(%ebp),%eax
c01060ca:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01060d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060d5:	c7 04 24 1e 60 10 c0 	movl   $0xc010601e,(%esp)
c01060dc:	e8 64 fb ff ff       	call   c0105c45 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01060e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060e4:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01060e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01060ea:	c9                   	leave  
c01060eb:	c3                   	ret    
