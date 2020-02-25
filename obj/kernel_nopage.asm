
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 88 af 11 00       	mov    $0x11af88,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 90 58 00 00       	call   1058f2 <memset>

    cons_init();                // init the console
  100062:	e8 74 15 00 00       	call   1015db <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 00 61 10 00 	movl   $0x106100,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 1c 61 10 00 	movl   $0x10611c,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 b2 08 00 00       	call   100938 <print_kerninfo>

    grade_backtrace();
  100086:	e8 89 00 00 00       	call   100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 57 32 00 00       	call   1032e7 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 aa 16 00 00       	call   10173f <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 03 18 00 00       	call   10189d <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 ef 0c 00 00       	call   100d8e <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 ce 17 00 00       	call   101872 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 b4 0c 00 00       	call   100d7c <mon_backtrace>
}
  1000c8:	90                   	nop
  1000c9:	c9                   	leave  
  1000ca:	c3                   	ret    

001000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000cb:	55                   	push   %ebp
  1000cc:	89 e5                	mov    %esp,%ebp
  1000ce:	53                   	push   %ebx
  1000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b4 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	83 c4 14             	add    $0x14,%esp
  1000f6:	5b                   	pop    %ebx
  1000f7:	5d                   	pop    %ebp
  1000f8:	c3                   	ret    

001000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f9:	55                   	push   %ebp
  1000fa:	89 e5                	mov    %esp,%ebp
  1000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ff:	8b 45 10             	mov    0x10(%ebp),%eax
  100102:	89 44 24 04          	mov    %eax,0x4(%esp)
  100106:	8b 45 08             	mov    0x8(%ebp),%eax
  100109:	89 04 24             	mov    %eax,(%esp)
  10010c:	e8 ba ff ff ff       	call   1000cb <grade_backtrace1>
}
  100111:	90                   	nop
  100112:	c9                   	leave  
  100113:	c3                   	ret    

00100114 <grade_backtrace>:

void
grade_backtrace(void) {
  100114:	55                   	push   %ebp
  100115:	89 e5                	mov    %esp,%ebp
  100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011a:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100126:	ff 
  100127:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100132:	e8 c2 ff ff ff       	call   1000f9 <grade_backtrace0>
}
  100137:	90                   	nop
  100138:	c9                   	leave  
  100139:	c3                   	ret    

0010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013a:	55                   	push   %ebp
  10013b:	89 e5                	mov    %esp,%ebp
  10013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100150:	83 e0 03             	and    $0x3,%eax
  100153:	89 c2                	mov    %eax,%edx
  100155:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10015a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100162:	c7 04 24 21 61 10 00 	movl   $0x106121,(%esp)
  100169:	e8 24 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 2f 61 10 00 	movl   $0x10612f,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 3d 61 10 00 	movl   $0x10613d,(%esp)
  1001a7:	e8 e6 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 4b 61 10 00 	movl   $0x10614b,(%esp)
  1001c6:	e8 c7 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 59 61 10 00 	movl   $0x106159,(%esp)
  1001e5:	e8 a8 00 00 00       	call   100292 <cprintf>
    round ++;
  1001ea:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001ef:	40                   	inc    %eax
  1001f0:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001f5:	90                   	nop
  1001f6:	c9                   	leave  
  1001f7:	c3                   	ret    

001001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001f8:	55                   	push   %ebp
  1001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001fb:	90                   	nop
  1001fc:	5d                   	pop    %ebp
  1001fd:	c3                   	ret    

001001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001fe:	55                   	push   %ebp
  1001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100201:	90                   	nop
  100202:	5d                   	pop    %ebp
  100203:	c3                   	ret    

00100204 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100204:	55                   	push   %ebp
  100205:	89 e5                	mov    %esp,%ebp
  100207:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020a:	e8 2b ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10020f:	c7 04 24 68 61 10 00 	movl   $0x106168,(%esp)
  100216:	e8 77 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021b:	e8 d8 ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100220:	e8 15 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100225:	c7 04 24 88 61 10 00 	movl   $0x106188,(%esp)
  10022c:	e8 61 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_kernel();
  100231:	e8 c8 ff ff ff       	call   1001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100236:	e8 ff fe ff ff       	call   10013a <lab1_print_cur_status>
}
  10023b:	90                   	nop
  10023c:	c9                   	leave  
  10023d:	c3                   	ret    

0010023e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10023e:	55                   	push   %ebp
  10023f:	89 e5                	mov    %esp,%ebp
  100241:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100244:	8b 45 08             	mov    0x8(%ebp),%eax
  100247:	89 04 24             	mov    %eax,(%esp)
  10024a:	e8 b9 13 00 00       	call   101608 <cons_putc>
    (*cnt) ++;
  10024f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100252:	8b 00                	mov    (%eax),%eax
  100254:	8d 50 01             	lea    0x1(%eax),%edx
  100257:	8b 45 0c             	mov    0xc(%ebp),%eax
  10025a:	89 10                	mov    %edx,(%eax)
}
  10025c:	90                   	nop
  10025d:	c9                   	leave  
  10025e:	c3                   	ret    

0010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10025f:	55                   	push   %ebp
  100260:	89 e5                	mov    %esp,%ebp
  100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100273:	8b 45 08             	mov    0x8(%ebp),%eax
  100276:	89 44 24 08          	mov    %eax,0x8(%esp)
  10027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100281:	c7 04 24 3e 02 10 00 	movl   $0x10023e,(%esp)
  100288:	e8 b8 59 00 00       	call   105c45 <vprintfmt>
    return cnt;
  10028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100292:	55                   	push   %ebp
  100293:	89 e5                	mov    %esp,%ebp
  100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100298:	8d 45 0c             	lea    0xc(%ebp),%eax
  10029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002a8:	89 04 24             	mov    %eax,(%esp)
  1002ab:	e8 af ff ff ff       	call   10025f <vcprintf>
  1002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002b6:	c9                   	leave  
  1002b7:	c3                   	ret    

001002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002b8:	55                   	push   %ebp
  1002b9:	89 e5                	mov    %esp,%ebp
  1002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002be:	8b 45 08             	mov    0x8(%ebp),%eax
  1002c1:	89 04 24             	mov    %eax,(%esp)
  1002c4:	e8 3f 13 00 00       	call   101608 <cons_putc>
}
  1002c9:	90                   	nop
  1002ca:	c9                   	leave  
  1002cb:	c3                   	ret    

001002cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002cc:	55                   	push   %ebp
  1002cd:	89 e5                	mov    %esp,%ebp
  1002cf:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002d9:	eb 13                	jmp    1002ee <cputs+0x22>
        cputch(c, &cnt);
  1002db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002df:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002e6:	89 04 24             	mov    %eax,(%esp)
  1002e9:	e8 50 ff ff ff       	call   10023e <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1002f1:	8d 50 01             	lea    0x1(%eax),%edx
  1002f4:	89 55 08             	mov    %edx,0x8(%ebp)
  1002f7:	0f b6 00             	movzbl (%eax),%eax
  1002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002fd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100301:	75 d8                	jne    1002db <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  100303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100306:	89 44 24 04          	mov    %eax,0x4(%esp)
  10030a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100311:	e8 28 ff ff ff       	call   10023e <cputch>
    return cnt;
  100316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100319:	c9                   	leave  
  10031a:	c3                   	ret    

0010031b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10031b:	55                   	push   %ebp
  10031c:	89 e5                	mov    %esp,%ebp
  10031e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100321:	e8 1f 13 00 00       	call   101645 <cons_getc>
  100326:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10032d:	74 f2                	je     100321 <getchar+0x6>
        /* do nothing */;
    return c;
  10032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100332:	c9                   	leave  
  100333:	c3                   	ret    

00100334 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100334:	55                   	push   %ebp
  100335:	89 e5                	mov    %esp,%ebp
  100337:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10033a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10033e:	74 13                	je     100353 <readline+0x1f>
        cprintf("%s", prompt);
  100340:	8b 45 08             	mov    0x8(%ebp),%eax
  100343:	89 44 24 04          	mov    %eax,0x4(%esp)
  100347:	c7 04 24 a7 61 10 00 	movl   $0x1061a7,(%esp)
  10034e:	e8 3f ff ff ff       	call   100292 <cprintf>
    }
    int i = 0, c;
  100353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10035a:	e8 bc ff ff ff       	call   10031b <getchar>
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100366:	79 07                	jns    10036f <readline+0x3b>
            return NULL;
  100368:	b8 00 00 00 00       	mov    $0x0,%eax
  10036d:	eb 78                	jmp    1003e7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10036f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100373:	7e 28                	jle    10039d <readline+0x69>
  100375:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10037c:	7f 1f                	jg     10039d <readline+0x69>
            cputchar(c);
  10037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100381:	89 04 24             	mov    %eax,(%esp)
  100384:	e8 2f ff ff ff       	call   1002b8 <cputchar>
            buf[i ++] = c;
  100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10038c:	8d 50 01             	lea    0x1(%eax),%edx
  10038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100395:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  10039b:	eb 45                	jmp    1003e2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  10039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003a1:	75 16                	jne    1003b9 <readline+0x85>
  1003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003a7:	7e 10                	jle    1003b9 <readline+0x85>
            cputchar(c);
  1003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003ac:	89 04 24             	mov    %eax,(%esp)
  1003af:	e8 04 ff ff ff       	call   1002b8 <cputchar>
            i --;
  1003b4:	ff 4d f4             	decl   -0xc(%ebp)
  1003b7:	eb 29                	jmp    1003e2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003bd:	74 06                	je     1003c5 <readline+0x91>
  1003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003c3:	75 95                	jne    10035a <readline+0x26>
            cputchar(c);
  1003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003c8:	89 04 24             	mov    %eax,(%esp)
  1003cb:	e8 e8 fe ff ff       	call   1002b8 <cputchar>
            buf[i] = '\0';
  1003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003d3:	05 20 a0 11 00       	add    $0x11a020,%eax
  1003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003db:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1003e0:	eb 05                	jmp    1003e7 <readline+0xb3>
        }
    }
  1003e2:	e9 73 ff ff ff       	jmp    10035a <readline+0x26>
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003ef:	a1 20 a4 11 00       	mov    0x11a420,%eax
  1003f4:	85 c0                	test   %eax,%eax
  1003f6:	75 5b                	jne    100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003f8:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  1003ff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100402:	8d 45 14             	lea    0x14(%ebp),%eax
  100405:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100408:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10040f:	8b 45 08             	mov    0x8(%ebp),%eax
  100412:	89 44 24 04          	mov    %eax,0x4(%esp)
  100416:	c7 04 24 aa 61 10 00 	movl   $0x1061aa,(%esp)
  10041d:	e8 70 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100425:	89 44 24 04          	mov    %eax,0x4(%esp)
  100429:	8b 45 10             	mov    0x10(%ebp),%eax
  10042c:	89 04 24             	mov    %eax,(%esp)
  10042f:	e8 2b fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100434:	c7 04 24 c6 61 10 00 	movl   $0x1061c6,(%esp)
  10043b:	e8 52 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100440:	c7 04 24 c8 61 10 00 	movl   $0x1061c8,(%esp)
  100447:	e8 46 fe ff ff       	call   100292 <cprintf>
    print_stackframe();
  10044c:	e8 32 06 00 00       	call   100a83 <print_stackframe>
  100451:	eb 01                	jmp    100454 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  100453:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  100454:	e8 20 14 00 00       	call   101879 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100460:	e8 4a 08 00 00       	call   100caf <kmonitor>
    }
  100465:	eb f2                	jmp    100459 <__panic+0x70>

00100467 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100467:	55                   	push   %ebp
  100468:	89 e5                	mov    %esp,%ebp
  10046a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10046d:	8d 45 14             	lea    0x14(%ebp),%eax
  100470:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100473:	8b 45 0c             	mov    0xc(%ebp),%eax
  100476:	89 44 24 08          	mov    %eax,0x8(%esp)
  10047a:	8b 45 08             	mov    0x8(%ebp),%eax
  10047d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100481:	c7 04 24 da 61 10 00 	movl   $0x1061da,(%esp)
  100488:	e8 05 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100490:	89 44 24 04          	mov    %eax,0x4(%esp)
  100494:	8b 45 10             	mov    0x10(%ebp),%eax
  100497:	89 04 24             	mov    %eax,(%esp)
  10049a:	e8 c0 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049f:	c7 04 24 c6 61 10 00 	movl   $0x1061c6,(%esp)
  1004a6:	e8 e7 fd ff ff       	call   100292 <cprintf>
    va_end(ap);
}
  1004ab:	90                   	nop
  1004ac:	c9                   	leave  
  1004ad:	c3                   	ret    

001004ae <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004ae:	55                   	push   %ebp
  1004af:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004b1:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  1004b6:	5d                   	pop    %ebp
  1004b7:	c3                   	ret    

001004b8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004b8:	55                   	push   %ebp
  1004b9:	89 e5                	mov    %esp,%ebp
  1004bb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004c1:	8b 00                	mov    (%eax),%eax
  1004c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004c9:	8b 00                	mov    (%eax),%eax
  1004cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004d5:	e9 ca 00 00 00       	jmp    1005a4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004da:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004e0:	01 d0                	add    %edx,%eax
  1004e2:	89 c2                	mov    %eax,%edx
  1004e4:	c1 ea 1f             	shr    $0x1f,%edx
  1004e7:	01 d0                	add    %edx,%eax
  1004e9:	d1 f8                	sar    %eax
  1004eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004f4:	eb 03                	jmp    1004f9 <stab_binsearch+0x41>
            m --;
  1004f6:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004ff:	7c 1f                	jl     100520 <stab_binsearch+0x68>
  100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100504:	89 d0                	mov    %edx,%eax
  100506:	01 c0                	add    %eax,%eax
  100508:	01 d0                	add    %edx,%eax
  10050a:	c1 e0 02             	shl    $0x2,%eax
  10050d:	89 c2                	mov    %eax,%edx
  10050f:	8b 45 08             	mov    0x8(%ebp),%eax
  100512:	01 d0                	add    %edx,%eax
  100514:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100518:	0f b6 c0             	movzbl %al,%eax
  10051b:	3b 45 14             	cmp    0x14(%ebp),%eax
  10051e:	75 d6                	jne    1004f6 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100523:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100526:	7d 09                	jge    100531 <stab_binsearch+0x79>
            l = true_m + 1;
  100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10052b:	40                   	inc    %eax
  10052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10052f:	eb 73                	jmp    1005a4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10053b:	89 d0                	mov    %edx,%eax
  10053d:	01 c0                	add    %eax,%eax
  10053f:	01 d0                	add    %edx,%eax
  100541:	c1 e0 02             	shl    $0x2,%eax
  100544:	89 c2                	mov    %eax,%edx
  100546:	8b 45 08             	mov    0x8(%ebp),%eax
  100549:	01 d0                	add    %edx,%eax
  10054b:	8b 40 08             	mov    0x8(%eax),%eax
  10054e:	3b 45 18             	cmp    0x18(%ebp),%eax
  100551:	73 11                	jae    100564 <stab_binsearch+0xac>
            *region_left = m;
  100553:	8b 45 0c             	mov    0xc(%ebp),%eax
  100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100559:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10055b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10055e:	40                   	inc    %eax
  10055f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100562:	eb 40                	jmp    1005a4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100564:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100567:	89 d0                	mov    %edx,%eax
  100569:	01 c0                	add    %eax,%eax
  10056b:	01 d0                	add    %edx,%eax
  10056d:	c1 e0 02             	shl    $0x2,%eax
  100570:	89 c2                	mov    %eax,%edx
  100572:	8b 45 08             	mov    0x8(%ebp),%eax
  100575:	01 d0                	add    %edx,%eax
  100577:	8b 40 08             	mov    0x8(%eax),%eax
  10057a:	3b 45 18             	cmp    0x18(%ebp),%eax
  10057d:	76 14                	jbe    100593 <stab_binsearch+0xdb>
            *region_right = m - 1;
  10057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100582:	8d 50 ff             	lea    -0x1(%eax),%edx
  100585:	8b 45 10             	mov    0x10(%ebp),%eax
  100588:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10058d:	48                   	dec    %eax
  10058e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100591:	eb 11                	jmp    1005a4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100593:	8b 45 0c             	mov    0xc(%ebp),%eax
  100596:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100599:	89 10                	mov    %edx,(%eax)
            l = m;
  10059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10059e:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005a1:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005aa:	0f 8e 2a ff ff ff    	jle    1004da <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1005b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005b4:	75 0f                	jne    1005c5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b9:	8b 00                	mov    (%eax),%eax
  1005bb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005be:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005c3:	eb 3e                	jmp    100603 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1005c5:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c8:	8b 00                	mov    (%eax),%eax
  1005ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005cd:	eb 03                	jmp    1005d2 <stab_binsearch+0x11a>
  1005cf:	ff 4d fc             	decl   -0x4(%ebp)
  1005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d5:	8b 00                	mov    (%eax),%eax
  1005d7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005da:	7d 1f                	jge    1005fb <stab_binsearch+0x143>
  1005dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005df:	89 d0                	mov    %edx,%eax
  1005e1:	01 c0                	add    %eax,%eax
  1005e3:	01 d0                	add    %edx,%eax
  1005e5:	c1 e0 02             	shl    $0x2,%eax
  1005e8:	89 c2                	mov    %eax,%edx
  1005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1005ed:	01 d0                	add    %edx,%eax
  1005ef:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005f3:	0f b6 c0             	movzbl %al,%eax
  1005f6:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005f9:	75 d4                	jne    1005cf <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
  1005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100601:	89 10                	mov    %edx,(%eax)
    }
}
  100603:	90                   	nop
  100604:	c9                   	leave  
  100605:	c3                   	ret    

00100606 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100606:	55                   	push   %ebp
  100607:	89 e5                	mov    %esp,%ebp
  100609:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060f:	c7 00 f8 61 10 00    	movl   $0x1061f8,(%eax)
    info->eip_line = 0;
  100615:	8b 45 0c             	mov    0xc(%ebp),%eax
  100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100622:	c7 40 08 f8 61 10 00 	movl   $0x1061f8,0x8(%eax)
    info->eip_fn_namelen = 9;
  100629:	8b 45 0c             	mov    0xc(%ebp),%eax
  10062c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100633:	8b 45 0c             	mov    0xc(%ebp),%eax
  100636:	8b 55 08             	mov    0x8(%ebp),%edx
  100639:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10063c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100646:	c7 45 f4 20 74 10 00 	movl   $0x107420,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064d:	c7 45 f0 34 23 11 00 	movl   $0x112334,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100654:	c7 45 ec 35 23 11 00 	movl   $0x112335,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10065b:	c7 45 e8 c9 4d 11 00 	movl   $0x114dc9,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100662:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100665:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100668:	76 0b                	jbe    100675 <debuginfo_eip+0x6f>
  10066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10066d:	48                   	dec    %eax
  10066e:	0f b6 00             	movzbl (%eax),%eax
  100671:	84 c0                	test   %al,%al
  100673:	74 0a                	je     10067f <debuginfo_eip+0x79>
        return -1;
  100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10067a:	e9 b7 02 00 00       	jmp    100936 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068c:	29 c2                	sub    %eax,%edx
  10068e:	89 d0                	mov    %edx,%eax
  100690:	c1 f8 02             	sar    $0x2,%eax
  100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100699:	48                   	dec    %eax
  10069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  10069d:	8b 45 08             	mov    0x8(%ebp),%eax
  1006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006a4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006ab:	00 
  1006ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006af:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006bd:	89 04 24             	mov    %eax,(%esp)
  1006c0:	e8 f3 fd ff ff       	call   1004b8 <stab_binsearch>
    if (lfile == 0)
  1006c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006c8:	85 c0                	test   %eax,%eax
  1006ca:	75 0a                	jne    1006d6 <debuginfo_eip+0xd0>
        return -1;
  1006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006d1:	e9 60 02 00 00       	jmp    100936 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006e9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006f0:	00 
  1006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100702:	89 04 24             	mov    %eax,(%esp)
  100705:	e8 ae fd ff ff       	call   1004b8 <stab_binsearch>

    if (lfun <= rfun) {
  10070a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100710:	39 c2                	cmp    %eax,%edx
  100712:	7f 7c                	jg     100790 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100717:	89 c2                	mov    %eax,%edx
  100719:	89 d0                	mov    %edx,%eax
  10071b:	01 c0                	add    %eax,%eax
  10071d:	01 d0                	add    %edx,%eax
  10071f:	c1 e0 02             	shl    $0x2,%eax
  100722:	89 c2                	mov    %eax,%edx
  100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100727:	01 d0                	add    %edx,%eax
  100729:	8b 00                	mov    (%eax),%eax
  10072b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10072e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100731:	29 d1                	sub    %edx,%ecx
  100733:	89 ca                	mov    %ecx,%edx
  100735:	39 d0                	cmp    %edx,%eax
  100737:	73 22                	jae    10075b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100739:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10073c:	89 c2                	mov    %eax,%edx
  10073e:	89 d0                	mov    %edx,%eax
  100740:	01 c0                	add    %eax,%eax
  100742:	01 d0                	add    %edx,%eax
  100744:	c1 e0 02             	shl    $0x2,%eax
  100747:	89 c2                	mov    %eax,%edx
  100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074c:	01 d0                	add    %edx,%eax
  10074e:	8b 10                	mov    (%eax),%edx
  100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100753:	01 c2                	add    %eax,%edx
  100755:	8b 45 0c             	mov    0xc(%ebp),%eax
  100758:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075e:	89 c2                	mov    %eax,%edx
  100760:	89 d0                	mov    %edx,%eax
  100762:	01 c0                	add    %eax,%eax
  100764:	01 d0                	add    %edx,%eax
  100766:	c1 e0 02             	shl    $0x2,%eax
  100769:	89 c2                	mov    %eax,%edx
  10076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10076e:	01 d0                	add    %edx,%eax
  100770:	8b 50 08             	mov    0x8(%eax),%edx
  100773:	8b 45 0c             	mov    0xc(%ebp),%eax
  100776:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100779:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077c:	8b 40 10             	mov    0x10(%eax),%eax
  10077f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100782:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100788:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10078e:	eb 15                	jmp    1007a5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100790:	8b 45 0c             	mov    0xc(%ebp),%eax
  100793:	8b 55 08             	mov    0x8(%ebp),%edx
  100796:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  10079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a8:	8b 40 08             	mov    0x8(%eax),%eax
  1007ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007b2:	00 
  1007b3:	89 04 24             	mov    %eax,(%esp)
  1007b6:	e8 b3 4f 00 00       	call   10576e <strfind>
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c0:	8b 40 08             	mov    0x8(%eax),%eax
  1007c3:	29 c2                	sub    %eax,%edx
  1007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007d2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007d9:	00 
  1007da:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007eb:	89 04 24             	mov    %eax,(%esp)
  1007ee:	e8 c5 fc ff ff       	call   1004b8 <stab_binsearch>
    if (lline <= rline) {
  1007f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007f9:	39 c2                	cmp    %eax,%edx
  1007fb:	7f 23                	jg     100820 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  1007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100800:	89 c2                	mov    %eax,%edx
  100802:	89 d0                	mov    %edx,%eax
  100804:	01 c0                	add    %eax,%eax
  100806:	01 d0                	add    %edx,%eax
  100808:	c1 e0 02             	shl    $0x2,%eax
  10080b:	89 c2                	mov    %eax,%edx
  10080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100810:	01 d0                	add    %edx,%eax
  100812:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100816:	89 c2                	mov    %eax,%edx
  100818:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10081e:	eb 11                	jmp    100831 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100825:	e9 0c 01 00 00       	jmp    100936 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10082a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10082d:	48                   	dec    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100837:	39 c2                	cmp    %eax,%edx
  100839:	7c 56                	jl     100891 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  10083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10083e:	89 c2                	mov    %eax,%edx
  100840:	89 d0                	mov    %edx,%eax
  100842:	01 c0                	add    %eax,%eax
  100844:	01 d0                	add    %edx,%eax
  100846:	c1 e0 02             	shl    $0x2,%eax
  100849:	89 c2                	mov    %eax,%edx
  10084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10084e:	01 d0                	add    %edx,%eax
  100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100854:	3c 84                	cmp    $0x84,%al
  100856:	74 39                	je     100891 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085b:	89 c2                	mov    %eax,%edx
  10085d:	89 d0                	mov    %edx,%eax
  10085f:	01 c0                	add    %eax,%eax
  100861:	01 d0                	add    %edx,%eax
  100863:	c1 e0 02             	shl    $0x2,%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100871:	3c 64                	cmp    $0x64,%al
  100873:	75 b5                	jne    10082a <debuginfo_eip+0x224>
  100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100878:	89 c2                	mov    %eax,%edx
  10087a:	89 d0                	mov    %edx,%eax
  10087c:	01 c0                	add    %eax,%eax
  10087e:	01 d0                	add    %edx,%eax
  100880:	c1 e0 02             	shl    $0x2,%eax
  100883:	89 c2                	mov    %eax,%edx
  100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100888:	01 d0                	add    %edx,%eax
  10088a:	8b 40 08             	mov    0x8(%eax),%eax
  10088d:	85 c0                	test   %eax,%eax
  10088f:	74 99                	je     10082a <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100897:	39 c2                	cmp    %eax,%edx
  100899:	7c 46                	jl     1008e1 <debuginfo_eip+0x2db>
  10089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089e:	89 c2                	mov    %eax,%edx
  1008a0:	89 d0                	mov    %edx,%eax
  1008a2:	01 c0                	add    %eax,%eax
  1008a4:	01 d0                	add    %edx,%eax
  1008a6:	c1 e0 02             	shl    $0x2,%eax
  1008a9:	89 c2                	mov    %eax,%edx
  1008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008ae:	01 d0                	add    %edx,%eax
  1008b0:	8b 00                	mov    (%eax),%eax
  1008b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008b8:	29 d1                	sub    %edx,%ecx
  1008ba:	89 ca                	mov    %ecx,%edx
  1008bc:	39 d0                	cmp    %edx,%eax
  1008be:	73 21                	jae    1008e1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008c3:	89 c2                	mov    %eax,%edx
  1008c5:	89 d0                	mov    %edx,%eax
  1008c7:	01 c0                	add    %eax,%eax
  1008c9:	01 d0                	add    %edx,%eax
  1008cb:	c1 e0 02             	shl    $0x2,%eax
  1008ce:	89 c2                	mov    %eax,%edx
  1008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008d3:	01 d0                	add    %edx,%eax
  1008d5:	8b 10                	mov    (%eax),%edx
  1008d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008da:	01 c2                	add    %eax,%edx
  1008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008df:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008e7:	39 c2                	cmp    %eax,%edx
  1008e9:	7d 46                	jge    100931 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008ee:	40                   	inc    %eax
  1008ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008f2:	eb 16                	jmp    10090a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008f7:	8b 40 14             	mov    0x14(%eax),%eax
  1008fa:	8d 50 01             	lea    0x1(%eax),%edx
  1008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100900:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100906:	40                   	inc    %eax
  100907:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10090a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10090d:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100910:	39 c2                	cmp    %eax,%edx
  100912:	7d 1d                	jge    100931 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100917:	89 c2                	mov    %eax,%edx
  100919:	89 d0                	mov    %edx,%eax
  10091b:	01 c0                	add    %eax,%eax
  10091d:	01 d0                	add    %edx,%eax
  10091f:	c1 e0 02             	shl    $0x2,%eax
  100922:	89 c2                	mov    %eax,%edx
  100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100927:	01 d0                	add    %edx,%eax
  100929:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10092d:	3c a0                	cmp    $0xa0,%al
  10092f:	74 c3                	je     1008f4 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100936:	c9                   	leave  
  100937:	c3                   	ret    

00100938 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100938:	55                   	push   %ebp
  100939:	89 e5                	mov    %esp,%ebp
  10093b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10093e:	c7 04 24 02 62 10 00 	movl   $0x106202,(%esp)
  100945:	e8 48 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100951:	00 
  100952:	c7 04 24 1b 62 10 00 	movl   $0x10621b,(%esp)
  100959:	e8 34 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10095e:	c7 44 24 04 ec 60 10 	movl   $0x1060ec,0x4(%esp)
  100965:	00 
  100966:	c7 04 24 33 62 10 00 	movl   $0x106233,(%esp)
  10096d:	e8 20 f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100972:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  100979:	00 
  10097a:	c7 04 24 4b 62 10 00 	movl   $0x10624b,(%esp)
  100981:	e8 0c f9 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100986:	c7 44 24 04 88 af 11 	movl   $0x11af88,0x4(%esp)
  10098d:	00 
  10098e:	c7 04 24 63 62 10 00 	movl   $0x106263,(%esp)
  100995:	e8 f8 f8 ff ff       	call   100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10099a:	b8 88 af 11 00       	mov    $0x11af88,%eax
  10099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009a5:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009aa:	29 c2                	sub    %eax,%edx
  1009ac:	89 d0                	mov    %edx,%eax
  1009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b4:	85 c0                	test   %eax,%eax
  1009b6:	0f 48 c2             	cmovs  %edx,%eax
  1009b9:	c1 f8 0a             	sar    $0xa,%eax
  1009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009c0:	c7 04 24 7c 62 10 00 	movl   $0x10627c,(%esp)
  1009c7:	e8 c6 f8 ff ff       	call   100292 <cprintf>
}
  1009cc:	90                   	nop
  1009cd:	c9                   	leave  
  1009ce:	c3                   	ret    

001009cf <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009cf:	55                   	push   %ebp
  1009d0:	89 e5                	mov    %esp,%ebp
  1009d2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009df:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e2:	89 04 24             	mov    %eax,(%esp)
  1009e5:	e8 1c fc ff ff       	call   100606 <debuginfo_eip>
  1009ea:	85 c0                	test   %eax,%eax
  1009ec:	74 15                	je     100a03 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f5:	c7 04 24 a6 62 10 00 	movl   $0x1062a6,(%esp)
  1009fc:	e8 91 f8 ff ff       	call   100292 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a01:	eb 6c                	jmp    100a6f <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a0a:	eb 1b                	jmp    100a27 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a12:	01 d0                	add    %edx,%eax
  100a14:	0f b6 00             	movzbl (%eax),%eax
  100a17:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a20:	01 ca                	add    %ecx,%edx
  100a22:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a24:	ff 45 f4             	incl   -0xc(%ebp)
  100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a2d:	7f dd                	jg     100a0c <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100a2f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a38:	01 d0                	add    %edx,%eax
  100a3a:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a40:	8b 55 08             	mov    0x8(%ebp),%edx
  100a43:	89 d1                	mov    %edx,%ecx
  100a45:	29 c1                	sub    %eax,%ecx
  100a47:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a51:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a63:	c7 04 24 c2 62 10 00 	movl   $0x1062c2,(%esp)
  100a6a:	e8 23 f8 ff ff       	call   100292 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  100a6f:	90                   	nop
  100a70:	c9                   	leave  
  100a71:	c3                   	ret    

00100a72 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a72:	55                   	push   %ebp
  100a73:	89 e5                	mov    %esp,%ebp
  100a75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a78:	8b 45 04             	mov    0x4(%ebp),%eax
  100a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a81:	c9                   	leave  
  100a82:	c3                   	ret    

00100a83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a83:	55                   	push   %ebp
  100a84:	89 e5                	mov    %esp,%ebp
  100a86:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a89:	89 e8                	mov    %ebp,%eax
  100a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
  100a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100a94:	e8 d9 ff ff ff       	call   100a72 <read_eip>
  100a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100aa3:	e9 84 00 00 00       	jmp    100b2c <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  100aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab6:	c7 04 24 d4 62 10 00 	movl   $0x1062d4,(%esp)
  100abd:	e8 d0 f7 ff ff       	call   100292 <cprintf>

        //C语言的函数调用约定为参数从右到左压栈，所以EBP高8字节保存的是第一个参数
        uint32_t *args = (uint32_t *)ebp + 2;
  100ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ac5:	83 c0 08             	add    $0x8,%eax
  100ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100acb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100ad2:	eb 24                	jmp    100af8 <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
  100ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ad7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ae1:	01 d0                	add    %edx,%eax
  100ae3:	8b 00                	mov    (%eax),%eax
  100ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ae9:	c7 04 24 f0 62 10 00 	movl   $0x1062f0,(%esp)
  100af0:	e8 9d f7 ff ff       	call   100292 <cprintf>
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);

        //C语言的函数调用约定为参数从右到左压栈，所以EBP高8字节保存的是第一个参数
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
  100af5:	ff 45 e8             	incl   -0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	7e d6                	jle    100ad4 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
  100afe:	c7 04 24 f8 62 10 00 	movl   $0x1062f8,(%esp)
  100b05:	e8 88 f7 ff ff       	call   100292 <cprintf>
        print_debuginfo(eip - 1);
  100b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b0d:	48                   	dec    %eax
  100b0e:	89 04 24             	mov    %eax,(%esp)
  100b11:	e8 b9 fe ff ff       	call   1009cf <print_debuginfo>
        //当前帧指针EBP指向的栈地址保存的是上一个函数栈的我帧指针
        //当前帧指针EBP指向的栈地址的高4字节，保存的返回地址
        eip = ((uint32_t *)ebp)[1];
  100b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b19:	83 c0 04             	add    $0x4,%eax
  100b1c:	8b 00                	mov    (%eax),%eax
  100b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b24:	8b 00                	mov    (%eax),%eax
  100b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100b29:	ff 45 ec             	incl   -0x14(%ebp)
  100b2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b30:	74 0a                	je     100b3c <print_stackframe+0xb9>
  100b32:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b36:	0f 8e 6c ff ff ff    	jle    100aa8 <print_stackframe+0x25>
        //当前帧指针EBP指向的栈地址保存的是上一个函数栈的我帧指针
        //当前帧指针EBP指向的栈地址的高4字节，保存的返回地址
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
  100b3c:	90                   	nop
  100b3d:	c9                   	leave  
  100b3e:	c3                   	ret    

00100b3f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b3f:	55                   	push   %ebp
  100b40:	89 e5                	mov    %esp,%ebp
  100b42:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b4c:	eb 0c                	jmp    100b5a <parse+0x1b>
            *buf ++ = '\0';
  100b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b51:	8d 50 01             	lea    0x1(%eax),%edx
  100b54:	89 55 08             	mov    %edx,0x8(%ebp)
  100b57:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5d:	0f b6 00             	movzbl (%eax),%eax
  100b60:	84 c0                	test   %al,%al
  100b62:	74 1d                	je     100b81 <parse+0x42>
  100b64:	8b 45 08             	mov    0x8(%ebp),%eax
  100b67:	0f b6 00             	movzbl (%eax),%eax
  100b6a:	0f be c0             	movsbl %al,%eax
  100b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b71:	c7 04 24 7c 63 10 00 	movl   $0x10637c,(%esp)
  100b78:	e8 bf 4b 00 00       	call   10573c <strchr>
  100b7d:	85 c0                	test   %eax,%eax
  100b7f:	75 cd                	jne    100b4e <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100b81:	8b 45 08             	mov    0x8(%ebp),%eax
  100b84:	0f b6 00             	movzbl (%eax),%eax
  100b87:	84 c0                	test   %al,%al
  100b89:	74 69                	je     100bf4 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b8b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b8f:	75 14                	jne    100ba5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b91:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b98:	00 
  100b99:	c7 04 24 81 63 10 00 	movl   $0x106381,(%esp)
  100ba0:	e8 ed f6 ff ff       	call   100292 <cprintf>
        }
        argv[argc ++] = buf;
  100ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ba8:	8d 50 01             	lea    0x1(%eax),%edx
  100bab:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bb8:	01 c2                	add    %eax,%edx
  100bba:	8b 45 08             	mov    0x8(%ebp),%eax
  100bbd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bbf:	eb 03                	jmp    100bc4 <parse+0x85>
            buf ++;
  100bc1:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  100bc7:	0f b6 00             	movzbl (%eax),%eax
  100bca:	84 c0                	test   %al,%al
  100bcc:	0f 84 7a ff ff ff    	je     100b4c <parse+0xd>
  100bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  100bd5:	0f b6 00             	movzbl (%eax),%eax
  100bd8:	0f be c0             	movsbl %al,%eax
  100bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdf:	c7 04 24 7c 63 10 00 	movl   $0x10637c,(%esp)
  100be6:	e8 51 4b 00 00       	call   10573c <strchr>
  100beb:	85 c0                	test   %eax,%eax
  100bed:	74 d2                	je     100bc1 <parse+0x82>
            buf ++;
        }
    }
  100bef:	e9 58 ff ff ff       	jmp    100b4c <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100bf4:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bf8:	c9                   	leave  
  100bf9:	c3                   	ret    

00100bfa <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bfa:	55                   	push   %ebp
  100bfb:	89 e5                	mov    %esp,%ebp
  100bfd:	53                   	push   %ebx
  100bfe:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c01:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c04:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c08:	8b 45 08             	mov    0x8(%ebp),%eax
  100c0b:	89 04 24             	mov    %eax,(%esp)
  100c0e:	e8 2c ff ff ff       	call   100b3f <parse>
  100c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c1a:	75 0a                	jne    100c26 <runcmd+0x2c>
        return 0;
  100c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  100c21:	e9 83 00 00 00       	jmp    100ca9 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c2d:	eb 5a                	jmp    100c89 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c2f:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c35:	89 d0                	mov    %edx,%eax
  100c37:	01 c0                	add    %eax,%eax
  100c39:	01 d0                	add    %edx,%eax
  100c3b:	c1 e0 02             	shl    $0x2,%eax
  100c3e:	05 00 70 11 00       	add    $0x117000,%eax
  100c43:	8b 00                	mov    (%eax),%eax
  100c45:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c49:	89 04 24             	mov    %eax,(%esp)
  100c4c:	e8 4e 4a 00 00       	call   10569f <strcmp>
  100c51:	85 c0                	test   %eax,%eax
  100c53:	75 31                	jne    100c86 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c58:	89 d0                	mov    %edx,%eax
  100c5a:	01 c0                	add    %eax,%eax
  100c5c:	01 d0                	add    %edx,%eax
  100c5e:	c1 e0 02             	shl    $0x2,%eax
  100c61:	05 08 70 11 00       	add    $0x117008,%eax
  100c66:	8b 10                	mov    (%eax),%edx
  100c68:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c6b:	83 c0 04             	add    $0x4,%eax
  100c6e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c71:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c7f:	89 1c 24             	mov    %ebx,(%esp)
  100c82:	ff d2                	call   *%edx
  100c84:	eb 23                	jmp    100ca9 <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c86:	ff 45 f4             	incl   -0xc(%ebp)
  100c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c8c:	83 f8 02             	cmp    $0x2,%eax
  100c8f:	76 9e                	jbe    100c2f <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c91:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c94:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c98:	c7 04 24 9f 63 10 00 	movl   $0x10639f,(%esp)
  100c9f:	e8 ee f5 ff ff       	call   100292 <cprintf>
    return 0;
  100ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ca9:	83 c4 64             	add    $0x64,%esp
  100cac:	5b                   	pop    %ebx
  100cad:	5d                   	pop    %ebp
  100cae:	c3                   	ret    

00100caf <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100caf:	55                   	push   %ebp
  100cb0:	89 e5                	mov    %esp,%ebp
  100cb2:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cb5:	c7 04 24 b8 63 10 00 	movl   $0x1063b8,(%esp)
  100cbc:	e8 d1 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cc1:	c7 04 24 e0 63 10 00 	movl   $0x1063e0,(%esp)
  100cc8:	e8 c5 f5 ff ff       	call   100292 <cprintf>

    if (tf != NULL) {
  100ccd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cd1:	74 0b                	je     100cde <kmonitor+0x2f>
        print_trapframe(tf);
  100cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd6:	89 04 24             	mov    %eax,(%esp)
  100cd9:	e8 76 0d 00 00       	call   101a54 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cde:	c7 04 24 05 64 10 00 	movl   $0x106405,(%esp)
  100ce5:	e8 4a f6 ff ff       	call   100334 <readline>
  100cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100ced:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cf1:	74 eb                	je     100cde <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cfd:	89 04 24             	mov    %eax,(%esp)
  100d00:	e8 f5 fe ff ff       	call   100bfa <runcmd>
  100d05:	85 c0                	test   %eax,%eax
  100d07:	78 02                	js     100d0b <kmonitor+0x5c>
                break;
            }
        }
    }
  100d09:	eb d3                	jmp    100cde <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100d0b:	90                   	nop
            }
        }
    }
}
  100d0c:	90                   	nop
  100d0d:	c9                   	leave  
  100d0e:	c3                   	ret    

00100d0f <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d0f:	55                   	push   %ebp
  100d10:	89 e5                	mov    %esp,%ebp
  100d12:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d1c:	eb 3d                	jmp    100d5b <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d21:	89 d0                	mov    %edx,%eax
  100d23:	01 c0                	add    %eax,%eax
  100d25:	01 d0                	add    %edx,%eax
  100d27:	c1 e0 02             	shl    $0x2,%eax
  100d2a:	05 04 70 11 00       	add    $0x117004,%eax
  100d2f:	8b 08                	mov    (%eax),%ecx
  100d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d34:	89 d0                	mov    %edx,%eax
  100d36:	01 c0                	add    %eax,%eax
  100d38:	01 d0                	add    %edx,%eax
  100d3a:	c1 e0 02             	shl    $0x2,%eax
  100d3d:	05 00 70 11 00       	add    $0x117000,%eax
  100d42:	8b 00                	mov    (%eax),%eax
  100d44:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d4c:	c7 04 24 09 64 10 00 	movl   $0x106409,(%esp)
  100d53:	e8 3a f5 ff ff       	call   100292 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d58:	ff 45 f4             	incl   -0xc(%ebp)
  100d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d5e:	83 f8 02             	cmp    $0x2,%eax
  100d61:	76 bb                	jbe    100d1e <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d68:	c9                   	leave  
  100d69:	c3                   	ret    

00100d6a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d6a:	55                   	push   %ebp
  100d6b:	89 e5                	mov    %esp,%ebp
  100d6d:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d70:	e8 c3 fb ff ff       	call   100938 <print_kerninfo>
    return 0;
  100d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d7a:	c9                   	leave  
  100d7b:	c3                   	ret    

00100d7c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d7c:	55                   	push   %ebp
  100d7d:	89 e5                	mov    %esp,%ebp
  100d7f:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d82:	e8 fc fc ff ff       	call   100a83 <print_stackframe>
    return 0;
  100d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d8c:	c9                   	leave  
  100d8d:	c3                   	ret    

00100d8e <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d8e:	55                   	push   %ebp
  100d8f:	89 e5                	mov    %esp,%ebp
  100d91:	83 ec 28             	sub    $0x28,%esp
  100d94:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d9a:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100d9e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100da2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100da6:	ee                   	out    %al,(%dx)
  100da7:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100dad:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100db1:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100db5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100db8:	ee                   	out    %al,(%dx)
  100db9:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dbf:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100dc3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dcb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dcc:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100dd3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dd6:	c7 04 24 12 64 10 00 	movl   $0x106412,(%esp)
  100ddd:	e8 b0 f4 ff ff       	call   100292 <cprintf>
    pic_enable(IRQ_TIMER);
  100de2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100de9:	e8 1e 09 00 00       	call   10170c <pic_enable>
}
  100dee:	90                   	nop
  100def:	c9                   	leave  
  100df0:	c3                   	ret    

00100df1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100df1:	55                   	push   %ebp
  100df2:	89 e5                	mov    %esp,%ebp
  100df4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100df7:	9c                   	pushf  
  100df8:	58                   	pop    %eax
  100df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100dff:	25 00 02 00 00       	and    $0x200,%eax
  100e04:	85 c0                	test   %eax,%eax
  100e06:	74 0c                	je     100e14 <__intr_save+0x23>
        intr_disable();
  100e08:	e8 6c 0a 00 00       	call   101879 <intr_disable>
        return 1;
  100e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  100e12:	eb 05                	jmp    100e19 <__intr_save+0x28>
    }
    return 0;
  100e14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e19:	c9                   	leave  
  100e1a:	c3                   	ret    

00100e1b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e1b:	55                   	push   %ebp
  100e1c:	89 e5                	mov    %esp,%ebp
  100e1e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e21:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e25:	74 05                	je     100e2c <__intr_restore+0x11>
        intr_enable();
  100e27:	e8 46 0a 00 00       	call   101872 <intr_enable>
    }
}
  100e2c:	90                   	nop
  100e2d:	c9                   	leave  
  100e2e:	c3                   	ret    

00100e2f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e2f:	55                   	push   %ebp
  100e30:	89 e5                	mov    %esp,%ebp
  100e32:	83 ec 10             	sub    $0x10,%esp
  100e35:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e3b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e3f:	89 c2                	mov    %eax,%edx
  100e41:	ec                   	in     (%dx),%al
  100e42:	88 45 f4             	mov    %al,-0xc(%ebp)
  100e45:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100e4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e4e:	89 c2                	mov    %eax,%edx
  100e50:	ec                   	in     (%dx),%al
  100e51:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e54:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e5a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e5e:	89 c2                	mov    %eax,%edx
  100e60:	ec                   	in     (%dx),%al
  100e61:	88 45 f6             	mov    %al,-0xa(%ebp)
  100e64:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100e6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100e6d:	89 c2                	mov    %eax,%edx
  100e6f:	ec                   	in     (%dx),%al
  100e70:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e73:	90                   	nop
  100e74:	c9                   	leave  
  100e75:	c3                   	ret    

00100e76 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e76:	55                   	push   %ebp
  100e77:	89 e5                	mov    %esp,%ebp
  100e79:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e7c:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e86:	0f b7 00             	movzwl (%eax),%eax
  100e89:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e90:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e98:	0f b7 00             	movzwl (%eax),%eax
  100e9b:	0f b7 c0             	movzwl %ax,%eax
  100e9e:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ea3:	74 12                	je     100eb7 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ea5:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100eac:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100eb3:	b4 03 
  100eb5:	eb 13                	jmp    100eca <cga_init+0x54>
    } else {
        *cp = was;
  100eb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eba:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ebe:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ec1:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100ec8:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100eca:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ed1:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100ed5:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ed9:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100edd:	8b 55 f8             	mov    -0x8(%ebp),%edx
  100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ee1:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ee8:	40                   	inc    %eax
  100ee9:	0f b7 c0             	movzwl %ax,%eax
  100eec:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ef0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ef4:	89 c2                	mov    %eax,%edx
  100ef6:	ec                   	in     (%dx),%al
  100ef7:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100efa:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100efe:	0f b6 c0             	movzbl %al,%eax
  100f01:	c1 e0 08             	shl    $0x8,%eax
  100f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f07:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f0e:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100f12:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f16:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100f1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100f1d:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f1e:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f25:	40                   	inc    %eax
  100f26:	0f b7 c0             	movzwl %ax,%eax
  100f29:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f2d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f31:	89 c2                	mov    %eax,%edx
  100f33:	ec                   	in     (%dx),%al
  100f34:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f37:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f3b:	0f b6 c0             	movzbl %al,%eax
  100f3e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f41:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f44:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f4c:	0f b7 c0             	movzwl %ax,%eax
  100f4f:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f55:	90                   	nop
  100f56:	c9                   	leave  
  100f57:	c3                   	ret    

00100f58 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f58:	55                   	push   %ebp
  100f59:	89 e5                	mov    %esp,%ebp
  100f5b:	83 ec 38             	sub    $0x38,%esp
  100f5e:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f64:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f68:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100f6c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f70:	ee                   	out    %al,(%dx)
  100f71:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100f77:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100f7b:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100f7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100f82:	ee                   	out    %al,(%dx)
  100f83:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100f89:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100f8d:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100f91:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f95:	ee                   	out    %al,(%dx)
  100f96:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100f9c:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100fa0:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fa4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100fa7:	ee                   	out    %al,(%dx)
  100fa8:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100fae:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100fb2:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100fb6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fba:	ee                   	out    %al,(%dx)
  100fbb:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100fc1:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100fc5:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100fc9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100fcc:	ee                   	out    %al,(%dx)
  100fcd:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fd3:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100fd7:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100fdb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fdf:	ee                   	out    %al,(%dx)
  100fe0:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fe6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100fe9:	89 c2                	mov    %eax,%edx
  100feb:	ec                   	in     (%dx),%al
  100fec:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
  100fef:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100ff3:	3c ff                	cmp    $0xff,%al
  100ff5:	0f 95 c0             	setne  %al
  100ff8:	0f b6 c0             	movzbl %al,%eax
  100ffb:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101000:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101006:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  10100a:	89 c2                	mov    %eax,%edx
  10100c:	ec                   	in     (%dx),%al
  10100d:	88 45 e2             	mov    %al,-0x1e(%ebp)
  101010:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
  101016:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101019:	89 c2                	mov    %eax,%edx
  10101b:	ec                   	in     (%dx),%al
  10101c:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10101f:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101024:	85 c0                	test   %eax,%eax
  101026:	74 0c                	je     101034 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
  101028:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10102f:	e8 d8 06 00 00       	call   10170c <pic_enable>
    }
}
  101034:	90                   	nop
  101035:	c9                   	leave  
  101036:	c3                   	ret    

00101037 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101037:	55                   	push   %ebp
  101038:	89 e5                	mov    %esp,%ebp
  10103a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10103d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101044:	eb 08                	jmp    10104e <lpt_putc_sub+0x17>
        delay();
  101046:	e8 e4 fd ff ff       	call   100e2f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10104b:	ff 45 fc             	incl   -0x4(%ebp)
  10104e:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  101054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101057:	89 c2                	mov    %eax,%edx
  101059:	ec                   	in     (%dx),%al
  10105a:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  10105d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101061:	84 c0                	test   %al,%al
  101063:	78 09                	js     10106e <lpt_putc_sub+0x37>
  101065:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10106c:	7e d8                	jle    101046 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  10106e:	8b 45 08             	mov    0x8(%ebp),%eax
  101071:	0f b6 c0             	movzbl %al,%eax
  101074:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  10107a:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10107d:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  101081:	8b 55 f8             	mov    -0x8(%ebp),%edx
  101084:	ee                   	out    %al,(%dx)
  101085:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  10108b:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  10108f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101093:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101097:	ee                   	out    %al,(%dx)
  101098:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  10109e:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  1010a2:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  1010a6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1010aa:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010ab:	90                   	nop
  1010ac:	c9                   	leave  
  1010ad:	c3                   	ret    

001010ae <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010ae:	55                   	push   %ebp
  1010af:	89 e5                	mov    %esp,%ebp
  1010b1:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010b4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010b8:	74 0d                	je     1010c7 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1010bd:	89 04 24             	mov    %eax,(%esp)
  1010c0:	e8 72 ff ff ff       	call   101037 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010c5:	eb 24                	jmp    1010eb <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  1010c7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010ce:	e8 64 ff ff ff       	call   101037 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010d3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010da:	e8 58 ff ff ff       	call   101037 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010df:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010e6:	e8 4c ff ff ff       	call   101037 <lpt_putc_sub>
    }
}
  1010eb:	90                   	nop
  1010ec:	c9                   	leave  
  1010ed:	c3                   	ret    

001010ee <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010ee:	55                   	push   %ebp
  1010ef:	89 e5                	mov    %esp,%ebp
  1010f1:	53                   	push   %ebx
  1010f2:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f8:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010fd:	85 c0                	test   %eax,%eax
  1010ff:	75 07                	jne    101108 <cga_putc+0x1a>
        c |= 0x0700;
  101101:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101108:	8b 45 08             	mov    0x8(%ebp),%eax
  10110b:	0f b6 c0             	movzbl %al,%eax
  10110e:	83 f8 0a             	cmp    $0xa,%eax
  101111:	74 54                	je     101167 <cga_putc+0x79>
  101113:	83 f8 0d             	cmp    $0xd,%eax
  101116:	74 62                	je     10117a <cga_putc+0x8c>
  101118:	83 f8 08             	cmp    $0x8,%eax
  10111b:	0f 85 93 00 00 00    	jne    1011b4 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
  101121:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101128:	85 c0                	test   %eax,%eax
  10112a:	0f 84 ae 00 00 00    	je     1011de <cga_putc+0xf0>
            crt_pos --;
  101130:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101137:	48                   	dec    %eax
  101138:	0f b7 c0             	movzwl %ax,%eax
  10113b:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101141:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101146:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  10114d:	01 d2                	add    %edx,%edx
  10114f:	01 c2                	add    %eax,%edx
  101151:	8b 45 08             	mov    0x8(%ebp),%eax
  101154:	98                   	cwtl   
  101155:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10115a:	98                   	cwtl   
  10115b:	83 c8 20             	or     $0x20,%eax
  10115e:	98                   	cwtl   
  10115f:	0f b7 c0             	movzwl %ax,%eax
  101162:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101165:	eb 77                	jmp    1011de <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
  101167:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10116e:	83 c0 50             	add    $0x50,%eax
  101171:	0f b7 c0             	movzwl %ax,%eax
  101174:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10117a:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  101181:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101188:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  10118d:	89 c8                	mov    %ecx,%eax
  10118f:	f7 e2                	mul    %edx
  101191:	c1 ea 06             	shr    $0x6,%edx
  101194:	89 d0                	mov    %edx,%eax
  101196:	c1 e0 02             	shl    $0x2,%eax
  101199:	01 d0                	add    %edx,%eax
  10119b:	c1 e0 04             	shl    $0x4,%eax
  10119e:	29 c1                	sub    %eax,%ecx
  1011a0:	89 c8                	mov    %ecx,%eax
  1011a2:	0f b7 c0             	movzwl %ax,%eax
  1011a5:	29 c3                	sub    %eax,%ebx
  1011a7:	89 d8                	mov    %ebx,%eax
  1011a9:	0f b7 c0             	movzwl %ax,%eax
  1011ac:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011b2:	eb 2b                	jmp    1011df <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011b4:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011ba:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011c1:	8d 50 01             	lea    0x1(%eax),%edx
  1011c4:	0f b7 d2             	movzwl %dx,%edx
  1011c7:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011ce:	01 c0                	add    %eax,%eax
  1011d0:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1011d6:	0f b7 c0             	movzwl %ax,%eax
  1011d9:	66 89 02             	mov    %ax,(%edx)
        break;
  1011dc:	eb 01                	jmp    1011df <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  1011de:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011df:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011e6:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011eb:	76 5d                	jbe    10124a <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011ed:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011f2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011f8:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011fd:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101204:	00 
  101205:	89 54 24 04          	mov    %edx,0x4(%esp)
  101209:	89 04 24             	mov    %eax,(%esp)
  10120c:	e8 21 47 00 00       	call   105932 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101211:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101218:	eb 14                	jmp    10122e <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
  10121a:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10121f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101222:	01 d2                	add    %edx,%edx
  101224:	01 d0                	add    %edx,%eax
  101226:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10122b:	ff 45 f4             	incl   -0xc(%ebp)
  10122e:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101235:	7e e3                	jle    10121a <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  101237:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10123e:	83 e8 50             	sub    $0x50,%eax
  101241:	0f b7 c0             	movzwl %ax,%eax
  101244:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10124a:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101251:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101255:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  101259:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  10125d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101261:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101262:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101269:	c1 e8 08             	shr    $0x8,%eax
  10126c:	0f b7 c0             	movzwl %ax,%eax
  10126f:	0f b6 c0             	movzbl %al,%eax
  101272:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  101279:	42                   	inc    %edx
  10127a:	0f b7 d2             	movzwl %dx,%edx
  10127d:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  101281:	88 45 e9             	mov    %al,-0x17(%ebp)
  101284:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101288:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10128b:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10128c:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101293:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  101297:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  10129b:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  10129f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012a3:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012a4:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012ab:	0f b6 c0             	movzbl %al,%eax
  1012ae:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012b5:	42                   	inc    %edx
  1012b6:	0f b7 d2             	movzwl %dx,%edx
  1012b9:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  1012bd:	88 45 eb             	mov    %al,-0x15(%ebp)
  1012c0:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  1012c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1012c7:	ee                   	out    %al,(%dx)
}
  1012c8:	90                   	nop
  1012c9:	83 c4 24             	add    $0x24,%esp
  1012cc:	5b                   	pop    %ebx
  1012cd:	5d                   	pop    %ebp
  1012ce:	c3                   	ret    

001012cf <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012cf:	55                   	push   %ebp
  1012d0:	89 e5                	mov    %esp,%ebp
  1012d2:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012dc:	eb 08                	jmp    1012e6 <serial_putc_sub+0x17>
        delay();
  1012de:	e8 4c fb ff ff       	call   100e2f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e3:	ff 45 fc             	incl   -0x4(%ebp)
  1012e6:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1012ef:	89 c2                	mov    %eax,%edx
  1012f1:	ec                   	in     (%dx),%al
  1012f2:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1012f5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1012f9:	0f b6 c0             	movzbl %al,%eax
  1012fc:	83 e0 20             	and    $0x20,%eax
  1012ff:	85 c0                	test   %eax,%eax
  101301:	75 09                	jne    10130c <serial_putc_sub+0x3d>
  101303:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10130a:	7e d2                	jle    1012de <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  10130c:	8b 45 08             	mov    0x8(%ebp),%eax
  10130f:	0f b6 c0             	movzbl %al,%eax
  101312:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  101318:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10131b:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  10131f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101323:	ee                   	out    %al,(%dx)
}
  101324:	90                   	nop
  101325:	c9                   	leave  
  101326:	c3                   	ret    

00101327 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101327:	55                   	push   %ebp
  101328:	89 e5                	mov    %esp,%ebp
  10132a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10132d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101331:	74 0d                	je     101340 <serial_putc+0x19>
        serial_putc_sub(c);
  101333:	8b 45 08             	mov    0x8(%ebp),%eax
  101336:	89 04 24             	mov    %eax,(%esp)
  101339:	e8 91 ff ff ff       	call   1012cf <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10133e:	eb 24                	jmp    101364 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  101340:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101347:	e8 83 ff ff ff       	call   1012cf <serial_putc_sub>
        serial_putc_sub(' ');
  10134c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101353:	e8 77 ff ff ff       	call   1012cf <serial_putc_sub>
        serial_putc_sub('\b');
  101358:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10135f:	e8 6b ff ff ff       	call   1012cf <serial_putc_sub>
    }
}
  101364:	90                   	nop
  101365:	c9                   	leave  
  101366:	c3                   	ret    

00101367 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101367:	55                   	push   %ebp
  101368:	89 e5                	mov    %esp,%ebp
  10136a:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10136d:	eb 33                	jmp    1013a2 <cons_intr+0x3b>
        if (c != 0) {
  10136f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101373:	74 2d                	je     1013a2 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101375:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10137a:	8d 50 01             	lea    0x1(%eax),%edx
  10137d:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  101383:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101386:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  10138c:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101391:	3d 00 02 00 00       	cmp    $0x200,%eax
  101396:	75 0a                	jne    1013a2 <cons_intr+0x3b>
                cons.wpos = 0;
  101398:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  10139f:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1013a5:	ff d0                	call   *%eax
  1013a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013aa:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013ae:	75 bf                	jne    10136f <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013b0:	90                   	nop
  1013b1:	c9                   	leave  
  1013b2:	c3                   	ret    

001013b3 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013b3:	55                   	push   %ebp
  1013b4:	89 e5                	mov    %esp,%ebp
  1013b6:	83 ec 10             	sub    $0x10,%esp
  1013b9:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1013c2:	89 c2                	mov    %eax,%edx
  1013c4:	ec                   	in     (%dx),%al
  1013c5:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1013c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013cc:	0f b6 c0             	movzbl %al,%eax
  1013cf:	83 e0 01             	and    $0x1,%eax
  1013d2:	85 c0                	test   %eax,%eax
  1013d4:	75 07                	jne    1013dd <serial_proc_data+0x2a>
        return -1;
  1013d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013db:	eb 2a                	jmp    101407 <serial_proc_data+0x54>
  1013dd:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013e3:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013e7:	89 c2                	mov    %eax,%edx
  1013e9:	ec                   	in     (%dx),%al
  1013ea:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  1013ed:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013f1:	0f b6 c0             	movzbl %al,%eax
  1013f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013f7:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013fb:	75 07                	jne    101404 <serial_proc_data+0x51>
        c = '\b';
  1013fd:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101404:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101407:	c9                   	leave  
  101408:	c3                   	ret    

00101409 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101409:	55                   	push   %ebp
  10140a:	89 e5                	mov    %esp,%ebp
  10140c:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10140f:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101414:	85 c0                	test   %eax,%eax
  101416:	74 0c                	je     101424 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101418:	c7 04 24 b3 13 10 00 	movl   $0x1013b3,(%esp)
  10141f:	e8 43 ff ff ff       	call   101367 <cons_intr>
    }
}
  101424:	90                   	nop
  101425:	c9                   	leave  
  101426:	c3                   	ret    

00101427 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101427:	55                   	push   %ebp
  101428:	89 e5                	mov    %esp,%ebp
  10142a:	83 ec 28             	sub    $0x28,%esp
  10142d:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101433:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101436:	89 c2                	mov    %eax,%edx
  101438:	ec                   	in     (%dx),%al
  101439:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10143c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101440:	0f b6 c0             	movzbl %al,%eax
  101443:	83 e0 01             	and    $0x1,%eax
  101446:	85 c0                	test   %eax,%eax
  101448:	75 0a                	jne    101454 <kbd_proc_data+0x2d>
        return -1;
  10144a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10144f:	e9 56 01 00 00       	jmp    1015aa <kbd_proc_data+0x183>
  101454:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10145a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10145d:	89 c2                	mov    %eax,%edx
  10145f:	ec                   	in     (%dx),%al
  101460:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  101463:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  101467:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10146a:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10146e:	75 17                	jne    101487 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101470:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101475:	83 c8 40             	or     $0x40,%eax
  101478:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  10147d:	b8 00 00 00 00       	mov    $0x0,%eax
  101482:	e9 23 01 00 00       	jmp    1015aa <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  101487:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10148b:	84 c0                	test   %al,%al
  10148d:	79 45                	jns    1014d4 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10148f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101494:	83 e0 40             	and    $0x40,%eax
  101497:	85 c0                	test   %eax,%eax
  101499:	75 08                	jne    1014a3 <kbd_proc_data+0x7c>
  10149b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10149f:	24 7f                	and    $0x7f,%al
  1014a1:	eb 04                	jmp    1014a7 <kbd_proc_data+0x80>
  1014a3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a7:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014aa:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ae:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014b5:	0c 40                	or     $0x40,%al
  1014b7:	0f b6 c0             	movzbl %al,%eax
  1014ba:	f7 d0                	not    %eax
  1014bc:	89 c2                	mov    %eax,%edx
  1014be:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014c3:	21 d0                	and    %edx,%eax
  1014c5:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014ca:	b8 00 00 00 00       	mov    $0x0,%eax
  1014cf:	e9 d6 00 00 00       	jmp    1015aa <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  1014d4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014d9:	83 e0 40             	and    $0x40,%eax
  1014dc:	85 c0                	test   %eax,%eax
  1014de:	74 11                	je     1014f1 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014e0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014e4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014e9:	83 e0 bf             	and    $0xffffffbf,%eax
  1014ec:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  1014f1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f5:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014fc:	0f b6 d0             	movzbl %al,%edx
  1014ff:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101504:	09 d0                	or     %edx,%eax
  101506:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  10150b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150f:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101516:	0f b6 d0             	movzbl %al,%edx
  101519:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10151e:	31 d0                	xor    %edx,%eax
  101520:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101525:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10152a:	83 e0 03             	and    $0x3,%eax
  10152d:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101534:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101538:	01 d0                	add    %edx,%eax
  10153a:	0f b6 00             	movzbl (%eax),%eax
  10153d:	0f b6 c0             	movzbl %al,%eax
  101540:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101543:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101548:	83 e0 08             	and    $0x8,%eax
  10154b:	85 c0                	test   %eax,%eax
  10154d:	74 22                	je     101571 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  10154f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101553:	7e 0c                	jle    101561 <kbd_proc_data+0x13a>
  101555:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101559:	7f 06                	jg     101561 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  10155b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10155f:	eb 10                	jmp    101571 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  101561:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101565:	7e 0a                	jle    101571 <kbd_proc_data+0x14a>
  101567:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10156b:	7f 04                	jg     101571 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10156d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101571:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101576:	f7 d0                	not    %eax
  101578:	83 e0 06             	and    $0x6,%eax
  10157b:	85 c0                	test   %eax,%eax
  10157d:	75 28                	jne    1015a7 <kbd_proc_data+0x180>
  10157f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101586:	75 1f                	jne    1015a7 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  101588:	c7 04 24 2d 64 10 00 	movl   $0x10642d,(%esp)
  10158f:	e8 fe ec ff ff       	call   100292 <cprintf>
  101594:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  10159a:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10159e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1015a2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1015a6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015aa:	c9                   	leave  
  1015ab:	c3                   	ret    

001015ac <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015ac:	55                   	push   %ebp
  1015ad:	89 e5                	mov    %esp,%ebp
  1015af:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015b2:	c7 04 24 27 14 10 00 	movl   $0x101427,(%esp)
  1015b9:	e8 a9 fd ff ff       	call   101367 <cons_intr>
}
  1015be:	90                   	nop
  1015bf:	c9                   	leave  
  1015c0:	c3                   	ret    

001015c1 <kbd_init>:

static void
kbd_init(void) {
  1015c1:	55                   	push   %ebp
  1015c2:	89 e5                	mov    %esp,%ebp
  1015c4:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015c7:	e8 e0 ff ff ff       	call   1015ac <kbd_intr>
    pic_enable(IRQ_KBD);
  1015cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015d3:	e8 34 01 00 00       	call   10170c <pic_enable>
}
  1015d8:	90                   	nop
  1015d9:	c9                   	leave  
  1015da:	c3                   	ret    

001015db <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015db:	55                   	push   %ebp
  1015dc:	89 e5                	mov    %esp,%ebp
  1015de:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015e1:	e8 90 f8 ff ff       	call   100e76 <cga_init>
    serial_init();
  1015e6:	e8 6d f9 ff ff       	call   100f58 <serial_init>
    kbd_init();
  1015eb:	e8 d1 ff ff ff       	call   1015c1 <kbd_init>
    if (!serial_exists) {
  1015f0:	a1 48 a4 11 00       	mov    0x11a448,%eax
  1015f5:	85 c0                	test   %eax,%eax
  1015f7:	75 0c                	jne    101605 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015f9:	c7 04 24 39 64 10 00 	movl   $0x106439,(%esp)
  101600:	e8 8d ec ff ff       	call   100292 <cprintf>
    }
}
  101605:	90                   	nop
  101606:	c9                   	leave  
  101607:	c3                   	ret    

00101608 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101608:	55                   	push   %ebp
  101609:	89 e5                	mov    %esp,%ebp
  10160b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10160e:	e8 de f7 ff ff       	call   100df1 <__intr_save>
  101613:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101616:	8b 45 08             	mov    0x8(%ebp),%eax
  101619:	89 04 24             	mov    %eax,(%esp)
  10161c:	e8 8d fa ff ff       	call   1010ae <lpt_putc>
        cga_putc(c);
  101621:	8b 45 08             	mov    0x8(%ebp),%eax
  101624:	89 04 24             	mov    %eax,(%esp)
  101627:	e8 c2 fa ff ff       	call   1010ee <cga_putc>
        serial_putc(c);
  10162c:	8b 45 08             	mov    0x8(%ebp),%eax
  10162f:	89 04 24             	mov    %eax,(%esp)
  101632:	e8 f0 fc ff ff       	call   101327 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101637:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10163a:	89 04 24             	mov    %eax,(%esp)
  10163d:	e8 d9 f7 ff ff       	call   100e1b <__intr_restore>
}
  101642:	90                   	nop
  101643:	c9                   	leave  
  101644:	c3                   	ret    

00101645 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101645:	55                   	push   %ebp
  101646:	89 e5                	mov    %esp,%ebp
  101648:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  10164b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101652:	e8 9a f7 ff ff       	call   100df1 <__intr_save>
  101657:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  10165a:	e8 aa fd ff ff       	call   101409 <serial_intr>
        kbd_intr();
  10165f:	e8 48 ff ff ff       	call   1015ac <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101664:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  10166a:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10166f:	39 c2                	cmp    %eax,%edx
  101671:	74 31                	je     1016a4 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  101673:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101678:	8d 50 01             	lea    0x1(%eax),%edx
  10167b:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  101681:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  101688:	0f b6 c0             	movzbl %al,%eax
  10168b:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10168e:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101693:	3d 00 02 00 00       	cmp    $0x200,%eax
  101698:	75 0a                	jne    1016a4 <cons_getc+0x5f>
                cons.rpos = 0;
  10169a:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016a1:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016a7:	89 04 24             	mov    %eax,(%esp)
  1016aa:	e8 6c f7 ff ff       	call   100e1b <__intr_restore>
    return c;
  1016af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016b2:	c9                   	leave  
  1016b3:	c3                   	ret    

001016b4 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016b4:	55                   	push   %ebp
  1016b5:	89 e5                	mov    %esp,%ebp
  1016b7:	83 ec 14             	sub    $0x14,%esp
  1016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1016bd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016c4:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016ca:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016cf:	85 c0                	test   %eax,%eax
  1016d1:	74 36                	je     101709 <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
  1016d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016d6:	0f b6 c0             	movzbl %al,%eax
  1016d9:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016df:	88 45 fa             	mov    %al,-0x6(%ebp)
  1016e2:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  1016e6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016ea:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1016eb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016ef:	c1 e8 08             	shr    $0x8,%eax
  1016f2:	0f b7 c0             	movzwl %ax,%eax
  1016f5:	0f b6 c0             	movzbl %al,%eax
  1016f8:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  1016fe:	88 45 fb             	mov    %al,-0x5(%ebp)
  101701:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101705:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101708:	ee                   	out    %al,(%dx)
    }
}
  101709:	90                   	nop
  10170a:	c9                   	leave  
  10170b:	c3                   	ret    

0010170c <pic_enable>:

void
pic_enable(unsigned int irq) {
  10170c:	55                   	push   %ebp
  10170d:	89 e5                	mov    %esp,%ebp
  10170f:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101712:	8b 45 08             	mov    0x8(%ebp),%eax
  101715:	ba 01 00 00 00       	mov    $0x1,%edx
  10171a:	88 c1                	mov    %al,%cl
  10171c:	d3 e2                	shl    %cl,%edx
  10171e:	89 d0                	mov    %edx,%eax
  101720:	98                   	cwtl   
  101721:	f7 d0                	not    %eax
  101723:	0f bf d0             	movswl %ax,%edx
  101726:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10172d:	98                   	cwtl   
  10172e:	21 d0                	and    %edx,%eax
  101730:	98                   	cwtl   
  101731:	0f b7 c0             	movzwl %ax,%eax
  101734:	89 04 24             	mov    %eax,(%esp)
  101737:	e8 78 ff ff ff       	call   1016b4 <pic_setmask>
}
  10173c:	90                   	nop
  10173d:	c9                   	leave  
  10173e:	c3                   	ret    

0010173f <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  10173f:	55                   	push   %ebp
  101740:	89 e5                	mov    %esp,%ebp
  101742:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
  101745:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  10174c:	00 00 00 
  10174f:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101755:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
  101759:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
  10175d:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101761:	ee                   	out    %al,(%dx)
  101762:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  101768:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
  10176c:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
  101770:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101773:	ee                   	out    %al,(%dx)
  101774:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  10177a:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  10177e:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  101782:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101786:	ee                   	out    %al,(%dx)
  101787:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  10178d:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  101791:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101795:	8b 55 f8             	mov    -0x8(%ebp),%edx
  101798:	ee                   	out    %al,(%dx)
  101799:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  10179f:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  1017a3:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  1017a7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017ab:	ee                   	out    %al,(%dx)
  1017ac:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  1017b2:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  1017b6:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  1017ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1017bd:	ee                   	out    %al,(%dx)
  1017be:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  1017c4:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  1017c8:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  1017cc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017d0:	ee                   	out    %al,(%dx)
  1017d1:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  1017d7:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  1017db:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1017e2:	ee                   	out    %al,(%dx)
  1017e3:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  1017e9:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  1017ed:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  1017f1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017f5:	ee                   	out    %al,(%dx)
  1017f6:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  1017fc:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  101800:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  101804:	8b 55 ec             	mov    -0x14(%ebp),%edx
  101807:	ee                   	out    %al,(%dx)
  101808:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  10180e:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  101812:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  101816:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10181a:	ee                   	out    %al,(%dx)
  10181b:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  101821:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  101825:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101829:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10182c:	ee                   	out    %al,(%dx)
  10182d:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  101833:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  101837:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  10183b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10183f:	ee                   	out    %al,(%dx)
  101840:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  101846:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  10184a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10184e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  101851:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101852:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101859:	3d ff ff 00 00       	cmp    $0xffff,%eax
  10185e:	74 0f                	je     10186f <pic_init+0x130>
        pic_setmask(irq_mask);
  101860:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101867:	89 04 24             	mov    %eax,(%esp)
  10186a:	e8 45 fe ff ff       	call   1016b4 <pic_setmask>
    }
}
  10186f:	90                   	nop
  101870:	c9                   	leave  
  101871:	c3                   	ret    

00101872 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101872:	55                   	push   %ebp
  101873:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  101875:	fb                   	sti    
    sti();
}
  101876:	90                   	nop
  101877:	5d                   	pop    %ebp
  101878:	c3                   	ret    

00101879 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101879:	55                   	push   %ebp
  10187a:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  10187c:	fa                   	cli    
    cli();
}
  10187d:	90                   	nop
  10187e:	5d                   	pop    %ebp
  10187f:	c3                   	ret    

00101880 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101880:	55                   	push   %ebp
  101881:	89 e5                	mov    %esp,%ebp
  101883:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101886:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10188d:	00 
  10188e:	c7 04 24 60 64 10 00 	movl   $0x106460,(%esp)
  101895:	e8 f8 e9 ff ff       	call   100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  10189a:	90                   	nop
  10189b:	c9                   	leave  
  10189c:	c3                   	ret    

0010189d <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10189d:	55                   	push   %ebp
  10189e:	89 e5                	mov    %esp,%ebp
  1018a0:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
	//初始化IDT
    for (i = 0; i < 256; i ++) {
  1018a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018aa:	e9 c4 00 00 00       	jmp    101973 <idt_init+0xd6>
        //0为中断门，GD_KTEXT为系统段选择子，DPL_KERNEL=0
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b2:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018b9:	0f b7 d0             	movzwl %ax,%edx
  1018bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018bf:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018c6:	00 
  1018c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ca:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  1018d1:	00 08 00 
  1018d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d7:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018de:	00 
  1018df:	80 e2 e0             	and    $0xe0,%dl
  1018e2:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ec:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018f3:	00 
  1018f4:	80 e2 1f             	and    $0x1f,%dl
  1018f7:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101901:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101908:	00 
  101909:	80 e2 f0             	and    $0xf0,%dl
  10190c:	80 ca 0e             	or     $0xe,%dl
  10190f:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101916:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101919:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101920:	00 
  101921:	80 e2 ef             	and    $0xef,%dl
  101924:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10192b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192e:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101935:	00 
  101936:	80 e2 9f             	and    $0x9f,%dl
  101939:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101940:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101943:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10194a:	00 
  10194b:	80 ca 80             	or     $0x80,%dl
  10194e:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101955:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101958:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  10195f:	c1 e8 10             	shr    $0x10,%eax
  101962:	0f b7 d0             	movzwl %ax,%edx
  101965:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101968:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  10196f:	00 
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
	//初始化IDT
    for (i = 0; i < 256; i ++) {
  101970:	ff 45 fc             	incl   -0x4(%ebp)
  101973:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  10197a:	0f 8e 2f ff ff ff    	jle    1018af <idt_init+0x12>
        //0为中断门，GD_KTEXT为系统段选择子，DPL_KERNEL=0
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101980:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101985:	0f b7 c0             	movzwl %ax,%eax
  101988:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  10198e:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  101995:	08 00 
  101997:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  10199e:	24 e0                	and    $0xe0,%al
  1019a0:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019a5:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019ac:	24 1f                	and    $0x1f,%al
  1019ae:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019b3:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019ba:	24 f0                	and    $0xf0,%al
  1019bc:	0c 0e                	or     $0xe,%al
  1019be:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019c3:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019ca:	24 ef                	and    $0xef,%al
  1019cc:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019d1:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019d8:	0c 60                	or     $0x60,%al
  1019da:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019df:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019e6:	0c 80                	or     $0x80,%al
  1019e8:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019ed:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  1019f2:	c1 e8 10             	shr    $0x10,%eax
  1019f5:	0f b7 c0             	movzwl %ax,%eax
  1019f8:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  1019fe:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a05:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a08:	0f 01 18             	lidtl  (%eax)
	// 加载IDT
    lidt(&idt_pd);
}
  101a0b:	90                   	nop
  101a0c:	c9                   	leave  
  101a0d:	c3                   	ret    

00101a0e <trapname>:

static const char *
trapname(int trapno) {
  101a0e:	55                   	push   %ebp
  101a0f:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a11:	8b 45 08             	mov    0x8(%ebp),%eax
  101a14:	83 f8 13             	cmp    $0x13,%eax
  101a17:	77 0c                	ja     101a25 <trapname+0x17>
        return excnames[trapno];
  101a19:	8b 45 08             	mov    0x8(%ebp),%eax
  101a1c:	8b 04 85 c0 67 10 00 	mov    0x1067c0(,%eax,4),%eax
  101a23:	eb 18                	jmp    101a3d <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a25:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a29:	7e 0d                	jle    101a38 <trapname+0x2a>
  101a2b:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a2f:	7f 07                	jg     101a38 <trapname+0x2a>
        return "Hardware Interrupt";
  101a31:	b8 6a 64 10 00       	mov    $0x10646a,%eax
  101a36:	eb 05                	jmp    101a3d <trapname+0x2f>
    }
    return "(unknown trap)";
  101a38:	b8 7d 64 10 00       	mov    $0x10647d,%eax
}
  101a3d:	5d                   	pop    %ebp
  101a3e:	c3                   	ret    

00101a3f <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a3f:	55                   	push   %ebp
  101a40:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a42:	8b 45 08             	mov    0x8(%ebp),%eax
  101a45:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a49:	83 f8 08             	cmp    $0x8,%eax
  101a4c:	0f 94 c0             	sete   %al
  101a4f:	0f b6 c0             	movzbl %al,%eax
}
  101a52:	5d                   	pop    %ebp
  101a53:	c3                   	ret    

00101a54 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a54:	55                   	push   %ebp
  101a55:	89 e5                	mov    %esp,%ebp
  101a57:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a61:	c7 04 24 be 64 10 00 	movl   $0x1064be,(%esp)
  101a68:	e8 25 e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a70:	89 04 24             	mov    %eax,(%esp)
  101a73:	e8 91 01 00 00       	call   101c09 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a78:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7b:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a83:	c7 04 24 cf 64 10 00 	movl   $0x1064cf,(%esp)
  101a8a:	e8 03 e8 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a92:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a96:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9a:	c7 04 24 e2 64 10 00 	movl   $0x1064e2,(%esp)
  101aa1:	e8 ec e7 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa9:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101aad:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab1:	c7 04 24 f5 64 10 00 	movl   $0x1064f5,(%esp)
  101ab8:	e8 d5 e7 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101abd:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac8:	c7 04 24 08 65 10 00 	movl   $0x106508,(%esp)
  101acf:	e8 be e7 ff ff       	call   100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad7:	8b 40 30             	mov    0x30(%eax),%eax
  101ada:	89 04 24             	mov    %eax,(%esp)
  101add:	e8 2c ff ff ff       	call   101a0e <trapname>
  101ae2:	89 c2                	mov    %eax,%edx
  101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae7:	8b 40 30             	mov    0x30(%eax),%eax
  101aea:	89 54 24 08          	mov    %edx,0x8(%esp)
  101aee:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af2:	c7 04 24 1b 65 10 00 	movl   $0x10651b,(%esp)
  101af9:	e8 94 e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101afe:	8b 45 08             	mov    0x8(%ebp),%eax
  101b01:	8b 40 34             	mov    0x34(%eax),%eax
  101b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b08:	c7 04 24 2d 65 10 00 	movl   $0x10652d,(%esp)
  101b0f:	e8 7e e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b14:	8b 45 08             	mov    0x8(%ebp),%eax
  101b17:	8b 40 38             	mov    0x38(%eax),%eax
  101b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b1e:	c7 04 24 3c 65 10 00 	movl   $0x10653c,(%esp)
  101b25:	e8 68 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b35:	c7 04 24 4b 65 10 00 	movl   $0x10654b,(%esp)
  101b3c:	e8 51 e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b41:	8b 45 08             	mov    0x8(%ebp),%eax
  101b44:	8b 40 40             	mov    0x40(%eax),%eax
  101b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4b:	c7 04 24 5e 65 10 00 	movl   $0x10655e,(%esp)
  101b52:	e8 3b e7 ff ff       	call   100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b5e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b65:	eb 3d                	jmp    101ba4 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b67:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6a:	8b 50 40             	mov    0x40(%eax),%edx
  101b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b70:	21 d0                	and    %edx,%eax
  101b72:	85 c0                	test   %eax,%eax
  101b74:	74 28                	je     101b9e <print_trapframe+0x14a>
  101b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b79:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b80:	85 c0                	test   %eax,%eax
  101b82:	74 1a                	je     101b9e <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b87:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b92:	c7 04 24 6d 65 10 00 	movl   $0x10656d,(%esp)
  101b99:	e8 f4 e6 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b9e:	ff 45 f4             	incl   -0xc(%ebp)
  101ba1:	d1 65 f0             	shll   -0x10(%ebp)
  101ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101ba7:	83 f8 17             	cmp    $0x17,%eax
  101baa:	76 bb                	jbe    101b67 <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bac:	8b 45 08             	mov    0x8(%ebp),%eax
  101baf:	8b 40 40             	mov    0x40(%eax),%eax
  101bb2:	25 00 30 00 00       	and    $0x3000,%eax
  101bb7:	c1 e8 0c             	shr    $0xc,%eax
  101bba:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bbe:	c7 04 24 71 65 10 00 	movl   $0x106571,(%esp)
  101bc5:	e8 c8 e6 ff ff       	call   100292 <cprintf>

    if (!trap_in_kernel(tf)) {
  101bca:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcd:	89 04 24             	mov    %eax,(%esp)
  101bd0:	e8 6a fe ff ff       	call   101a3f <trap_in_kernel>
  101bd5:	85 c0                	test   %eax,%eax
  101bd7:	75 2d                	jne    101c06 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bdc:	8b 40 44             	mov    0x44(%eax),%eax
  101bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be3:	c7 04 24 7a 65 10 00 	movl   $0x10657a,(%esp)
  101bea:	e8 a3 e6 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bef:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf2:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfa:	c7 04 24 89 65 10 00 	movl   $0x106589,(%esp)
  101c01:	e8 8c e6 ff ff       	call   100292 <cprintf>
    }
}
  101c06:	90                   	nop
  101c07:	c9                   	leave  
  101c08:	c3                   	ret    

00101c09 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c09:	55                   	push   %ebp
  101c0a:	89 e5                	mov    %esp,%ebp
  101c0c:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c12:	8b 00                	mov    (%eax),%eax
  101c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c18:	c7 04 24 9c 65 10 00 	movl   $0x10659c,(%esp)
  101c1f:	e8 6e e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c24:	8b 45 08             	mov    0x8(%ebp),%eax
  101c27:	8b 40 04             	mov    0x4(%eax),%eax
  101c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c2e:	c7 04 24 ab 65 10 00 	movl   $0x1065ab,(%esp)
  101c35:	e8 58 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3d:	8b 40 08             	mov    0x8(%eax),%eax
  101c40:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c44:	c7 04 24 ba 65 10 00 	movl   $0x1065ba,(%esp)
  101c4b:	e8 42 e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c50:	8b 45 08             	mov    0x8(%ebp),%eax
  101c53:	8b 40 0c             	mov    0xc(%eax),%eax
  101c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5a:	c7 04 24 c9 65 10 00 	movl   $0x1065c9,(%esp)
  101c61:	e8 2c e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c66:	8b 45 08             	mov    0x8(%ebp),%eax
  101c69:	8b 40 10             	mov    0x10(%eax),%eax
  101c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c70:	c7 04 24 d8 65 10 00 	movl   $0x1065d8,(%esp)
  101c77:	e8 16 e6 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7f:	8b 40 14             	mov    0x14(%eax),%eax
  101c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c86:	c7 04 24 e7 65 10 00 	movl   $0x1065e7,(%esp)
  101c8d:	e8 00 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c92:	8b 45 08             	mov    0x8(%ebp),%eax
  101c95:	8b 40 18             	mov    0x18(%eax),%eax
  101c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9c:	c7 04 24 f6 65 10 00 	movl   $0x1065f6,(%esp)
  101ca3:	e8 ea e5 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  101cab:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cae:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb2:	c7 04 24 05 66 10 00 	movl   $0x106605,(%esp)
  101cb9:	e8 d4 e5 ff ff       	call   100292 <cprintf>
}
  101cbe:	90                   	nop
  101cbf:	c9                   	leave  
  101cc0:	c3                   	ret    

00101cc1 <trap_dispatch>:

struct trapframe switchk2u, *switchu2k;
/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101cc1:	55                   	push   %ebp
  101cc2:	89 e5                	mov    %esp,%ebp
  101cc4:	57                   	push   %edi
  101cc5:	56                   	push   %esi
  101cc6:	53                   	push   %ebx
  101cc7:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
  101cca:	8b 45 08             	mov    0x8(%ebp),%eax
  101ccd:	8b 40 30             	mov    0x30(%eax),%eax
  101cd0:	83 f8 2f             	cmp    $0x2f,%eax
  101cd3:	77 21                	ja     101cf6 <trap_dispatch+0x35>
  101cd5:	83 f8 2e             	cmp    $0x2e,%eax
  101cd8:	0f 83 5d 02 00 00    	jae    101f3b <trap_dispatch+0x27a>
  101cde:	83 f8 21             	cmp    $0x21,%eax
  101ce1:	0f 84 95 00 00 00    	je     101d7c <trap_dispatch+0xbb>
  101ce7:	83 f8 24             	cmp    $0x24,%eax
  101cea:	74 67                	je     101d53 <trap_dispatch+0x92>
  101cec:	83 f8 20             	cmp    $0x20,%eax
  101cef:	74 1c                	je     101d0d <trap_dispatch+0x4c>
  101cf1:	e9 10 02 00 00       	jmp    101f06 <trap_dispatch+0x245>
  101cf6:	83 f8 78             	cmp    $0x78,%eax
  101cf9:	0f 84 a6 00 00 00    	je     101da5 <trap_dispatch+0xe4>
  101cff:	83 f8 79             	cmp    $0x79,%eax
  101d02:	0f 84 81 01 00 00    	je     101e89 <trap_dispatch+0x1c8>
  101d08:	e9 f9 01 00 00       	jmp    101f06 <trap_dispatch+0x245>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101d0d:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d12:	40                   	inc    %eax
  101d13:	a3 0c af 11 00       	mov    %eax,0x11af0c
        if (ticks % TICK_NUM == 0) {
  101d18:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
  101d1e:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d23:	89 c8                	mov    %ecx,%eax
  101d25:	f7 e2                	mul    %edx
  101d27:	c1 ea 05             	shr    $0x5,%edx
  101d2a:	89 d0                	mov    %edx,%eax
  101d2c:	c1 e0 02             	shl    $0x2,%eax
  101d2f:	01 d0                	add    %edx,%eax
  101d31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d38:	01 d0                	add    %edx,%eax
  101d3a:	c1 e0 02             	shl    $0x2,%eax
  101d3d:	29 c1                	sub    %eax,%ecx
  101d3f:	89 ca                	mov    %ecx,%edx
  101d41:	85 d2                	test   %edx,%edx
  101d43:	0f 85 f5 01 00 00    	jne    101f3e <trap_dispatch+0x27d>
            print_ticks();
  101d49:	e8 32 fb ff ff       	call   101880 <print_ticks>
        }
        break;
  101d4e:	e9 eb 01 00 00       	jmp    101f3e <trap_dispatch+0x27d>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d53:	e8 ed f8 ff ff       	call   101645 <cons_getc>
  101d58:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d5b:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d5f:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d63:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d6b:	c7 04 24 14 66 10 00 	movl   $0x106614,(%esp)
  101d72:	e8 1b e5 ff ff       	call   100292 <cprintf>
        break;
  101d77:	e9 c9 01 00 00       	jmp    101f45 <trap_dispatch+0x284>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d7c:	e8 c4 f8 ff ff       	call   101645 <cons_getc>
  101d81:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d84:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d88:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d8c:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d90:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d94:	c7 04 24 26 66 10 00 	movl   $0x106626,(%esp)
  101d9b:	e8 f2 e4 ff ff       	call   100292 <cprintf>
        break;
  101da0:	e9 a0 01 00 00       	jmp    101f45 <trap_dispatch+0x284>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
  101da5:	8b 45 08             	mov    0x8(%ebp),%eax
  101da8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dac:	83 f8 1b             	cmp    $0x1b,%eax
  101daf:	0f 84 8c 01 00 00    	je     101f41 <trap_dispatch+0x280>
        //当前在内核态，需要建立切换到用户态所需的trapframe结构的数据switchk2u，即修改栈上的段寄存器为用户态段寄存器
            switchk2u = *tf;
  101db5:	8b 55 08             	mov    0x8(%ebp),%edx
  101db8:	b8 20 af 11 00       	mov    $0x11af20,%eax
  101dbd:	bb 4c 00 00 00       	mov    $0x4c,%ebx
  101dc2:	89 c1                	mov    %eax,%ecx
  101dc4:	83 e1 01             	and    $0x1,%ecx
  101dc7:	85 c9                	test   %ecx,%ecx
  101dc9:	74 0c                	je     101dd7 <trap_dispatch+0x116>
  101dcb:	0f b6 0a             	movzbl (%edx),%ecx
  101dce:	88 08                	mov    %cl,(%eax)
  101dd0:	8d 40 01             	lea    0x1(%eax),%eax
  101dd3:	8d 52 01             	lea    0x1(%edx),%edx
  101dd6:	4b                   	dec    %ebx
  101dd7:	89 c1                	mov    %eax,%ecx
  101dd9:	83 e1 02             	and    $0x2,%ecx
  101ddc:	85 c9                	test   %ecx,%ecx
  101dde:	74 0f                	je     101def <trap_dispatch+0x12e>
  101de0:	0f b7 0a             	movzwl (%edx),%ecx
  101de3:	66 89 08             	mov    %cx,(%eax)
  101de6:	8d 40 02             	lea    0x2(%eax),%eax
  101de9:	8d 52 02             	lea    0x2(%edx),%edx
  101dec:	83 eb 02             	sub    $0x2,%ebx
  101def:	89 df                	mov    %ebx,%edi
  101df1:	83 e7 fc             	and    $0xfffffffc,%edi
  101df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  101df9:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
  101dfc:	89 34 08             	mov    %esi,(%eax,%ecx,1)
  101dff:	83 c1 04             	add    $0x4,%ecx
  101e02:	39 f9                	cmp    %edi,%ecx
  101e04:	72 f3                	jb     101df9 <trap_dispatch+0x138>
  101e06:	01 c8                	add    %ecx,%eax
  101e08:	01 ca                	add    %ecx,%edx
  101e0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  101e0f:	89 de                	mov    %ebx,%esi
  101e11:	83 e6 02             	and    $0x2,%esi
  101e14:	85 f6                	test   %esi,%esi
  101e16:	74 0b                	je     101e23 <trap_dispatch+0x162>
  101e18:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
  101e1c:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
  101e20:	83 c1 02             	add    $0x2,%ecx
  101e23:	83 e3 01             	and    $0x1,%ebx
  101e26:	85 db                	test   %ebx,%ebx
  101e28:	74 07                	je     101e31 <trap_dispatch+0x170>
  101e2a:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
  101e2e:	88 14 08             	mov    %dl,(%eax,%ecx,1)
            switchk2u.tf_cs = USER_CS;
  101e31:	66 c7 05 5c af 11 00 	movw   $0x1b,0x11af5c
  101e38:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101e3a:	66 c7 05 68 af 11 00 	movw   $0x23,0x11af68
  101e41:	23 00 
  101e43:	0f b7 05 68 af 11 00 	movzwl 0x11af68,%eax
  101e4a:	66 a3 48 af 11 00    	mov    %ax,0x11af48
  101e50:	0f b7 05 48 af 11 00 	movzwl 0x11af48,%eax
  101e57:	66 a3 4c af 11 00    	mov    %ax,0x11af4c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e60:	83 c0 44             	add    $0x44,%eax
  101e63:	a3 64 af 11 00       	mov    %eax,0x11af64
            //设置EFLAG的I/O特权位，使得在用户态可使用in/out指令
            switchk2u.tf_eflags |= (3 << 12);
  101e68:	a1 60 af 11 00       	mov    0x11af60,%eax
  101e6d:	0d 00 30 00 00       	or     $0x3000,%eax
  101e72:	a3 60 af 11 00       	mov    %eax,0x11af60
            //设置临时栈，指向switchk2u，这样iret返回时，CPU会从switchk2u恢复数据，
            //而不是从现有栈恢复数据。
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101e77:	8b 45 08             	mov    0x8(%ebp),%eax
  101e7a:	83 e8 04             	sub    $0x4,%eax
  101e7d:	ba 20 af 11 00       	mov    $0x11af20,%edx
  101e82:	89 10                	mov    %edx,(%eax)
        }
        break;
  101e84:	e9 b8 00 00 00       	jmp    101f41 <trap_dispatch+0x280>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
  101e89:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e90:	83 f8 08             	cmp    $0x8,%eax
  101e93:	0f 84 ab 00 00 00    	je     101f44 <trap_dispatch+0x283>
            //发出中断时，CPU处于用户态，我们希望处理完此中断后，CPU继续在内核态运行，
            //修改栈上的段寄存器值为内核代码段和内核数据段
            tf->tf_cs = KERNEL_CS;
  101e99:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9c:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea5:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101eab:	8b 45 08             	mov    0x8(%ebp),%eax
  101eae:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb5:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            //设置EFLAGS，让用户态不能执行in/out指令
            tf->tf_eflags &= ~(3 << 12);
  101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  101ebc:	8b 40 40             	mov    0x40(%eax),%eax
  101ebf:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101ec4:	89 c2                	mov    %eax,%edx
  101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec9:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  101ecf:	8b 40 44             	mov    0x44(%eax),%eax
  101ed2:	83 e8 44             	sub    $0x44,%eax
  101ed5:	a3 6c af 11 00       	mov    %eax,0x11af6c
            //设置临时栈，指向switchu2k，这样iret返回时，CPU会从switchu2k恢复数据，
            //而不是从现有栈恢复数据。
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101eda:	a1 6c af 11 00       	mov    0x11af6c,%eax
  101edf:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101ee6:	00 
  101ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  101eea:	89 54 24 04          	mov    %edx,0x4(%esp)
  101eee:	89 04 24             	mov    %eax,(%esp)
  101ef1:	e8 3c 3a 00 00       	call   105932 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef9:	83 e8 04             	sub    $0x4,%eax
  101efc:	8b 15 6c af 11 00    	mov    0x11af6c,%edx
  101f02:	89 10                	mov    %edx,(%eax)
        }
        break;
  101f04:	eb 3e                	jmp    101f44 <trap_dispatch+0x283>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101f06:	8b 45 08             	mov    0x8(%ebp),%eax
  101f09:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f0d:	83 e0 03             	and    $0x3,%eax
  101f10:	85 c0                	test   %eax,%eax
  101f12:	75 31                	jne    101f45 <trap_dispatch+0x284>
            print_trapframe(tf);
  101f14:	8b 45 08             	mov    0x8(%ebp),%eax
  101f17:	89 04 24             	mov    %eax,(%esp)
  101f1a:	e8 35 fb ff ff       	call   101a54 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101f1f:	c7 44 24 08 35 66 10 	movl   $0x106635,0x8(%esp)
  101f26:	00 
  101f27:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  101f2e:	00 
  101f2f:	c7 04 24 51 66 10 00 	movl   $0x106651,(%esp)
  101f36:	e8 ae e4 ff ff       	call   1003e9 <__panic>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101f3b:	90                   	nop
  101f3c:	eb 07                	jmp    101f45 <trap_dispatch+0x284>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
  101f3e:	90                   	nop
  101f3f:	eb 04                	jmp    101f45 <trap_dispatch+0x284>
            switchk2u.tf_eflags |= (3 << 12);
            //设置临时栈，指向switchk2u，这样iret返回时，CPU会从switchk2u恢复数据，
            //而不是从现有栈恢复数据。
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
        }
        break;
  101f41:	90                   	nop
  101f42:	eb 01                	jmp    101f45 <trap_dispatch+0x284>
            //设置临时栈，指向switchu2k，这样iret返回时，CPU会从switchu2k恢复数据，
            //而不是从现有栈恢复数据。
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
        }
        break;
  101f44:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101f45:	90                   	nop
  101f46:	83 c4 2c             	add    $0x2c,%esp
  101f49:	5b                   	pop    %ebx
  101f4a:	5e                   	pop    %esi
  101f4b:	5f                   	pop    %edi
  101f4c:	5d                   	pop    %ebp
  101f4d:	c3                   	ret    

00101f4e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101f4e:	55                   	push   %ebp
  101f4f:	89 e5                	mov    %esp,%ebp
  101f51:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101f54:	8b 45 08             	mov    0x8(%ebp),%eax
  101f57:	89 04 24             	mov    %eax,(%esp)
  101f5a:	e8 62 fd ff ff       	call   101cc1 <trap_dispatch>
}
  101f5f:	90                   	nop
  101f60:	c9                   	leave  
  101f61:	c3                   	ret    

00101f62 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f62:	6a 00                	push   $0x0
  pushl $0
  101f64:	6a 00                	push   $0x0
  jmp __alltraps
  101f66:	e9 69 0a 00 00       	jmp    1029d4 <__alltraps>

00101f6b <vector1>:
.globl vector1
vector1:
  pushl $0
  101f6b:	6a 00                	push   $0x0
  pushl $1
  101f6d:	6a 01                	push   $0x1
  jmp __alltraps
  101f6f:	e9 60 0a 00 00       	jmp    1029d4 <__alltraps>

00101f74 <vector2>:
.globl vector2
vector2:
  pushl $0
  101f74:	6a 00                	push   $0x0
  pushl $2
  101f76:	6a 02                	push   $0x2
  jmp __alltraps
  101f78:	e9 57 0a 00 00       	jmp    1029d4 <__alltraps>

00101f7d <vector3>:
.globl vector3
vector3:
  pushl $0
  101f7d:	6a 00                	push   $0x0
  pushl $3
  101f7f:	6a 03                	push   $0x3
  jmp __alltraps
  101f81:	e9 4e 0a 00 00       	jmp    1029d4 <__alltraps>

00101f86 <vector4>:
.globl vector4
vector4:
  pushl $0
  101f86:	6a 00                	push   $0x0
  pushl $4
  101f88:	6a 04                	push   $0x4
  jmp __alltraps
  101f8a:	e9 45 0a 00 00       	jmp    1029d4 <__alltraps>

00101f8f <vector5>:
.globl vector5
vector5:
  pushl $0
  101f8f:	6a 00                	push   $0x0
  pushl $5
  101f91:	6a 05                	push   $0x5
  jmp __alltraps
  101f93:	e9 3c 0a 00 00       	jmp    1029d4 <__alltraps>

00101f98 <vector6>:
.globl vector6
vector6:
  pushl $0
  101f98:	6a 00                	push   $0x0
  pushl $6
  101f9a:	6a 06                	push   $0x6
  jmp __alltraps
  101f9c:	e9 33 0a 00 00       	jmp    1029d4 <__alltraps>

00101fa1 <vector7>:
.globl vector7
vector7:
  pushl $0
  101fa1:	6a 00                	push   $0x0
  pushl $7
  101fa3:	6a 07                	push   $0x7
  jmp __alltraps
  101fa5:	e9 2a 0a 00 00       	jmp    1029d4 <__alltraps>

00101faa <vector8>:
.globl vector8
vector8:
  pushl $8
  101faa:	6a 08                	push   $0x8
  jmp __alltraps
  101fac:	e9 23 0a 00 00       	jmp    1029d4 <__alltraps>

00101fb1 <vector9>:
.globl vector9
vector9:
  pushl $0
  101fb1:	6a 00                	push   $0x0
  pushl $9
  101fb3:	6a 09                	push   $0x9
  jmp __alltraps
  101fb5:	e9 1a 0a 00 00       	jmp    1029d4 <__alltraps>

00101fba <vector10>:
.globl vector10
vector10:
  pushl $10
  101fba:	6a 0a                	push   $0xa
  jmp __alltraps
  101fbc:	e9 13 0a 00 00       	jmp    1029d4 <__alltraps>

00101fc1 <vector11>:
.globl vector11
vector11:
  pushl $11
  101fc1:	6a 0b                	push   $0xb
  jmp __alltraps
  101fc3:	e9 0c 0a 00 00       	jmp    1029d4 <__alltraps>

00101fc8 <vector12>:
.globl vector12
vector12:
  pushl $12
  101fc8:	6a 0c                	push   $0xc
  jmp __alltraps
  101fca:	e9 05 0a 00 00       	jmp    1029d4 <__alltraps>

00101fcf <vector13>:
.globl vector13
vector13:
  pushl $13
  101fcf:	6a 0d                	push   $0xd
  jmp __alltraps
  101fd1:	e9 fe 09 00 00       	jmp    1029d4 <__alltraps>

00101fd6 <vector14>:
.globl vector14
vector14:
  pushl $14
  101fd6:	6a 0e                	push   $0xe
  jmp __alltraps
  101fd8:	e9 f7 09 00 00       	jmp    1029d4 <__alltraps>

00101fdd <vector15>:
.globl vector15
vector15:
  pushl $0
  101fdd:	6a 00                	push   $0x0
  pushl $15
  101fdf:	6a 0f                	push   $0xf
  jmp __alltraps
  101fe1:	e9 ee 09 00 00       	jmp    1029d4 <__alltraps>

00101fe6 <vector16>:
.globl vector16
vector16:
  pushl $0
  101fe6:	6a 00                	push   $0x0
  pushl $16
  101fe8:	6a 10                	push   $0x10
  jmp __alltraps
  101fea:	e9 e5 09 00 00       	jmp    1029d4 <__alltraps>

00101fef <vector17>:
.globl vector17
vector17:
  pushl $17
  101fef:	6a 11                	push   $0x11
  jmp __alltraps
  101ff1:	e9 de 09 00 00       	jmp    1029d4 <__alltraps>

00101ff6 <vector18>:
.globl vector18
vector18:
  pushl $0
  101ff6:	6a 00                	push   $0x0
  pushl $18
  101ff8:	6a 12                	push   $0x12
  jmp __alltraps
  101ffa:	e9 d5 09 00 00       	jmp    1029d4 <__alltraps>

00101fff <vector19>:
.globl vector19
vector19:
  pushl $0
  101fff:	6a 00                	push   $0x0
  pushl $19
  102001:	6a 13                	push   $0x13
  jmp __alltraps
  102003:	e9 cc 09 00 00       	jmp    1029d4 <__alltraps>

00102008 <vector20>:
.globl vector20
vector20:
  pushl $0
  102008:	6a 00                	push   $0x0
  pushl $20
  10200a:	6a 14                	push   $0x14
  jmp __alltraps
  10200c:	e9 c3 09 00 00       	jmp    1029d4 <__alltraps>

00102011 <vector21>:
.globl vector21
vector21:
  pushl $0
  102011:	6a 00                	push   $0x0
  pushl $21
  102013:	6a 15                	push   $0x15
  jmp __alltraps
  102015:	e9 ba 09 00 00       	jmp    1029d4 <__alltraps>

0010201a <vector22>:
.globl vector22
vector22:
  pushl $0
  10201a:	6a 00                	push   $0x0
  pushl $22
  10201c:	6a 16                	push   $0x16
  jmp __alltraps
  10201e:	e9 b1 09 00 00       	jmp    1029d4 <__alltraps>

00102023 <vector23>:
.globl vector23
vector23:
  pushl $0
  102023:	6a 00                	push   $0x0
  pushl $23
  102025:	6a 17                	push   $0x17
  jmp __alltraps
  102027:	e9 a8 09 00 00       	jmp    1029d4 <__alltraps>

0010202c <vector24>:
.globl vector24
vector24:
  pushl $0
  10202c:	6a 00                	push   $0x0
  pushl $24
  10202e:	6a 18                	push   $0x18
  jmp __alltraps
  102030:	e9 9f 09 00 00       	jmp    1029d4 <__alltraps>

00102035 <vector25>:
.globl vector25
vector25:
  pushl $0
  102035:	6a 00                	push   $0x0
  pushl $25
  102037:	6a 19                	push   $0x19
  jmp __alltraps
  102039:	e9 96 09 00 00       	jmp    1029d4 <__alltraps>

0010203e <vector26>:
.globl vector26
vector26:
  pushl $0
  10203e:	6a 00                	push   $0x0
  pushl $26
  102040:	6a 1a                	push   $0x1a
  jmp __alltraps
  102042:	e9 8d 09 00 00       	jmp    1029d4 <__alltraps>

00102047 <vector27>:
.globl vector27
vector27:
  pushl $0
  102047:	6a 00                	push   $0x0
  pushl $27
  102049:	6a 1b                	push   $0x1b
  jmp __alltraps
  10204b:	e9 84 09 00 00       	jmp    1029d4 <__alltraps>

00102050 <vector28>:
.globl vector28
vector28:
  pushl $0
  102050:	6a 00                	push   $0x0
  pushl $28
  102052:	6a 1c                	push   $0x1c
  jmp __alltraps
  102054:	e9 7b 09 00 00       	jmp    1029d4 <__alltraps>

00102059 <vector29>:
.globl vector29
vector29:
  pushl $0
  102059:	6a 00                	push   $0x0
  pushl $29
  10205b:	6a 1d                	push   $0x1d
  jmp __alltraps
  10205d:	e9 72 09 00 00       	jmp    1029d4 <__alltraps>

00102062 <vector30>:
.globl vector30
vector30:
  pushl $0
  102062:	6a 00                	push   $0x0
  pushl $30
  102064:	6a 1e                	push   $0x1e
  jmp __alltraps
  102066:	e9 69 09 00 00       	jmp    1029d4 <__alltraps>

0010206b <vector31>:
.globl vector31
vector31:
  pushl $0
  10206b:	6a 00                	push   $0x0
  pushl $31
  10206d:	6a 1f                	push   $0x1f
  jmp __alltraps
  10206f:	e9 60 09 00 00       	jmp    1029d4 <__alltraps>

00102074 <vector32>:
.globl vector32
vector32:
  pushl $0
  102074:	6a 00                	push   $0x0
  pushl $32
  102076:	6a 20                	push   $0x20
  jmp __alltraps
  102078:	e9 57 09 00 00       	jmp    1029d4 <__alltraps>

0010207d <vector33>:
.globl vector33
vector33:
  pushl $0
  10207d:	6a 00                	push   $0x0
  pushl $33
  10207f:	6a 21                	push   $0x21
  jmp __alltraps
  102081:	e9 4e 09 00 00       	jmp    1029d4 <__alltraps>

00102086 <vector34>:
.globl vector34
vector34:
  pushl $0
  102086:	6a 00                	push   $0x0
  pushl $34
  102088:	6a 22                	push   $0x22
  jmp __alltraps
  10208a:	e9 45 09 00 00       	jmp    1029d4 <__alltraps>

0010208f <vector35>:
.globl vector35
vector35:
  pushl $0
  10208f:	6a 00                	push   $0x0
  pushl $35
  102091:	6a 23                	push   $0x23
  jmp __alltraps
  102093:	e9 3c 09 00 00       	jmp    1029d4 <__alltraps>

00102098 <vector36>:
.globl vector36
vector36:
  pushl $0
  102098:	6a 00                	push   $0x0
  pushl $36
  10209a:	6a 24                	push   $0x24
  jmp __alltraps
  10209c:	e9 33 09 00 00       	jmp    1029d4 <__alltraps>

001020a1 <vector37>:
.globl vector37
vector37:
  pushl $0
  1020a1:	6a 00                	push   $0x0
  pushl $37
  1020a3:	6a 25                	push   $0x25
  jmp __alltraps
  1020a5:	e9 2a 09 00 00       	jmp    1029d4 <__alltraps>

001020aa <vector38>:
.globl vector38
vector38:
  pushl $0
  1020aa:	6a 00                	push   $0x0
  pushl $38
  1020ac:	6a 26                	push   $0x26
  jmp __alltraps
  1020ae:	e9 21 09 00 00       	jmp    1029d4 <__alltraps>

001020b3 <vector39>:
.globl vector39
vector39:
  pushl $0
  1020b3:	6a 00                	push   $0x0
  pushl $39
  1020b5:	6a 27                	push   $0x27
  jmp __alltraps
  1020b7:	e9 18 09 00 00       	jmp    1029d4 <__alltraps>

001020bc <vector40>:
.globl vector40
vector40:
  pushl $0
  1020bc:	6a 00                	push   $0x0
  pushl $40
  1020be:	6a 28                	push   $0x28
  jmp __alltraps
  1020c0:	e9 0f 09 00 00       	jmp    1029d4 <__alltraps>

001020c5 <vector41>:
.globl vector41
vector41:
  pushl $0
  1020c5:	6a 00                	push   $0x0
  pushl $41
  1020c7:	6a 29                	push   $0x29
  jmp __alltraps
  1020c9:	e9 06 09 00 00       	jmp    1029d4 <__alltraps>

001020ce <vector42>:
.globl vector42
vector42:
  pushl $0
  1020ce:	6a 00                	push   $0x0
  pushl $42
  1020d0:	6a 2a                	push   $0x2a
  jmp __alltraps
  1020d2:	e9 fd 08 00 00       	jmp    1029d4 <__alltraps>

001020d7 <vector43>:
.globl vector43
vector43:
  pushl $0
  1020d7:	6a 00                	push   $0x0
  pushl $43
  1020d9:	6a 2b                	push   $0x2b
  jmp __alltraps
  1020db:	e9 f4 08 00 00       	jmp    1029d4 <__alltraps>

001020e0 <vector44>:
.globl vector44
vector44:
  pushl $0
  1020e0:	6a 00                	push   $0x0
  pushl $44
  1020e2:	6a 2c                	push   $0x2c
  jmp __alltraps
  1020e4:	e9 eb 08 00 00       	jmp    1029d4 <__alltraps>

001020e9 <vector45>:
.globl vector45
vector45:
  pushl $0
  1020e9:	6a 00                	push   $0x0
  pushl $45
  1020eb:	6a 2d                	push   $0x2d
  jmp __alltraps
  1020ed:	e9 e2 08 00 00       	jmp    1029d4 <__alltraps>

001020f2 <vector46>:
.globl vector46
vector46:
  pushl $0
  1020f2:	6a 00                	push   $0x0
  pushl $46
  1020f4:	6a 2e                	push   $0x2e
  jmp __alltraps
  1020f6:	e9 d9 08 00 00       	jmp    1029d4 <__alltraps>

001020fb <vector47>:
.globl vector47
vector47:
  pushl $0
  1020fb:	6a 00                	push   $0x0
  pushl $47
  1020fd:	6a 2f                	push   $0x2f
  jmp __alltraps
  1020ff:	e9 d0 08 00 00       	jmp    1029d4 <__alltraps>

00102104 <vector48>:
.globl vector48
vector48:
  pushl $0
  102104:	6a 00                	push   $0x0
  pushl $48
  102106:	6a 30                	push   $0x30
  jmp __alltraps
  102108:	e9 c7 08 00 00       	jmp    1029d4 <__alltraps>

0010210d <vector49>:
.globl vector49
vector49:
  pushl $0
  10210d:	6a 00                	push   $0x0
  pushl $49
  10210f:	6a 31                	push   $0x31
  jmp __alltraps
  102111:	e9 be 08 00 00       	jmp    1029d4 <__alltraps>

00102116 <vector50>:
.globl vector50
vector50:
  pushl $0
  102116:	6a 00                	push   $0x0
  pushl $50
  102118:	6a 32                	push   $0x32
  jmp __alltraps
  10211a:	e9 b5 08 00 00       	jmp    1029d4 <__alltraps>

0010211f <vector51>:
.globl vector51
vector51:
  pushl $0
  10211f:	6a 00                	push   $0x0
  pushl $51
  102121:	6a 33                	push   $0x33
  jmp __alltraps
  102123:	e9 ac 08 00 00       	jmp    1029d4 <__alltraps>

00102128 <vector52>:
.globl vector52
vector52:
  pushl $0
  102128:	6a 00                	push   $0x0
  pushl $52
  10212a:	6a 34                	push   $0x34
  jmp __alltraps
  10212c:	e9 a3 08 00 00       	jmp    1029d4 <__alltraps>

00102131 <vector53>:
.globl vector53
vector53:
  pushl $0
  102131:	6a 00                	push   $0x0
  pushl $53
  102133:	6a 35                	push   $0x35
  jmp __alltraps
  102135:	e9 9a 08 00 00       	jmp    1029d4 <__alltraps>

0010213a <vector54>:
.globl vector54
vector54:
  pushl $0
  10213a:	6a 00                	push   $0x0
  pushl $54
  10213c:	6a 36                	push   $0x36
  jmp __alltraps
  10213e:	e9 91 08 00 00       	jmp    1029d4 <__alltraps>

00102143 <vector55>:
.globl vector55
vector55:
  pushl $0
  102143:	6a 00                	push   $0x0
  pushl $55
  102145:	6a 37                	push   $0x37
  jmp __alltraps
  102147:	e9 88 08 00 00       	jmp    1029d4 <__alltraps>

0010214c <vector56>:
.globl vector56
vector56:
  pushl $0
  10214c:	6a 00                	push   $0x0
  pushl $56
  10214e:	6a 38                	push   $0x38
  jmp __alltraps
  102150:	e9 7f 08 00 00       	jmp    1029d4 <__alltraps>

00102155 <vector57>:
.globl vector57
vector57:
  pushl $0
  102155:	6a 00                	push   $0x0
  pushl $57
  102157:	6a 39                	push   $0x39
  jmp __alltraps
  102159:	e9 76 08 00 00       	jmp    1029d4 <__alltraps>

0010215e <vector58>:
.globl vector58
vector58:
  pushl $0
  10215e:	6a 00                	push   $0x0
  pushl $58
  102160:	6a 3a                	push   $0x3a
  jmp __alltraps
  102162:	e9 6d 08 00 00       	jmp    1029d4 <__alltraps>

00102167 <vector59>:
.globl vector59
vector59:
  pushl $0
  102167:	6a 00                	push   $0x0
  pushl $59
  102169:	6a 3b                	push   $0x3b
  jmp __alltraps
  10216b:	e9 64 08 00 00       	jmp    1029d4 <__alltraps>

00102170 <vector60>:
.globl vector60
vector60:
  pushl $0
  102170:	6a 00                	push   $0x0
  pushl $60
  102172:	6a 3c                	push   $0x3c
  jmp __alltraps
  102174:	e9 5b 08 00 00       	jmp    1029d4 <__alltraps>

00102179 <vector61>:
.globl vector61
vector61:
  pushl $0
  102179:	6a 00                	push   $0x0
  pushl $61
  10217b:	6a 3d                	push   $0x3d
  jmp __alltraps
  10217d:	e9 52 08 00 00       	jmp    1029d4 <__alltraps>

00102182 <vector62>:
.globl vector62
vector62:
  pushl $0
  102182:	6a 00                	push   $0x0
  pushl $62
  102184:	6a 3e                	push   $0x3e
  jmp __alltraps
  102186:	e9 49 08 00 00       	jmp    1029d4 <__alltraps>

0010218b <vector63>:
.globl vector63
vector63:
  pushl $0
  10218b:	6a 00                	push   $0x0
  pushl $63
  10218d:	6a 3f                	push   $0x3f
  jmp __alltraps
  10218f:	e9 40 08 00 00       	jmp    1029d4 <__alltraps>

00102194 <vector64>:
.globl vector64
vector64:
  pushl $0
  102194:	6a 00                	push   $0x0
  pushl $64
  102196:	6a 40                	push   $0x40
  jmp __alltraps
  102198:	e9 37 08 00 00       	jmp    1029d4 <__alltraps>

0010219d <vector65>:
.globl vector65
vector65:
  pushl $0
  10219d:	6a 00                	push   $0x0
  pushl $65
  10219f:	6a 41                	push   $0x41
  jmp __alltraps
  1021a1:	e9 2e 08 00 00       	jmp    1029d4 <__alltraps>

001021a6 <vector66>:
.globl vector66
vector66:
  pushl $0
  1021a6:	6a 00                	push   $0x0
  pushl $66
  1021a8:	6a 42                	push   $0x42
  jmp __alltraps
  1021aa:	e9 25 08 00 00       	jmp    1029d4 <__alltraps>

001021af <vector67>:
.globl vector67
vector67:
  pushl $0
  1021af:	6a 00                	push   $0x0
  pushl $67
  1021b1:	6a 43                	push   $0x43
  jmp __alltraps
  1021b3:	e9 1c 08 00 00       	jmp    1029d4 <__alltraps>

001021b8 <vector68>:
.globl vector68
vector68:
  pushl $0
  1021b8:	6a 00                	push   $0x0
  pushl $68
  1021ba:	6a 44                	push   $0x44
  jmp __alltraps
  1021bc:	e9 13 08 00 00       	jmp    1029d4 <__alltraps>

001021c1 <vector69>:
.globl vector69
vector69:
  pushl $0
  1021c1:	6a 00                	push   $0x0
  pushl $69
  1021c3:	6a 45                	push   $0x45
  jmp __alltraps
  1021c5:	e9 0a 08 00 00       	jmp    1029d4 <__alltraps>

001021ca <vector70>:
.globl vector70
vector70:
  pushl $0
  1021ca:	6a 00                	push   $0x0
  pushl $70
  1021cc:	6a 46                	push   $0x46
  jmp __alltraps
  1021ce:	e9 01 08 00 00       	jmp    1029d4 <__alltraps>

001021d3 <vector71>:
.globl vector71
vector71:
  pushl $0
  1021d3:	6a 00                	push   $0x0
  pushl $71
  1021d5:	6a 47                	push   $0x47
  jmp __alltraps
  1021d7:	e9 f8 07 00 00       	jmp    1029d4 <__alltraps>

001021dc <vector72>:
.globl vector72
vector72:
  pushl $0
  1021dc:	6a 00                	push   $0x0
  pushl $72
  1021de:	6a 48                	push   $0x48
  jmp __alltraps
  1021e0:	e9 ef 07 00 00       	jmp    1029d4 <__alltraps>

001021e5 <vector73>:
.globl vector73
vector73:
  pushl $0
  1021e5:	6a 00                	push   $0x0
  pushl $73
  1021e7:	6a 49                	push   $0x49
  jmp __alltraps
  1021e9:	e9 e6 07 00 00       	jmp    1029d4 <__alltraps>

001021ee <vector74>:
.globl vector74
vector74:
  pushl $0
  1021ee:	6a 00                	push   $0x0
  pushl $74
  1021f0:	6a 4a                	push   $0x4a
  jmp __alltraps
  1021f2:	e9 dd 07 00 00       	jmp    1029d4 <__alltraps>

001021f7 <vector75>:
.globl vector75
vector75:
  pushl $0
  1021f7:	6a 00                	push   $0x0
  pushl $75
  1021f9:	6a 4b                	push   $0x4b
  jmp __alltraps
  1021fb:	e9 d4 07 00 00       	jmp    1029d4 <__alltraps>

00102200 <vector76>:
.globl vector76
vector76:
  pushl $0
  102200:	6a 00                	push   $0x0
  pushl $76
  102202:	6a 4c                	push   $0x4c
  jmp __alltraps
  102204:	e9 cb 07 00 00       	jmp    1029d4 <__alltraps>

00102209 <vector77>:
.globl vector77
vector77:
  pushl $0
  102209:	6a 00                	push   $0x0
  pushl $77
  10220b:	6a 4d                	push   $0x4d
  jmp __alltraps
  10220d:	e9 c2 07 00 00       	jmp    1029d4 <__alltraps>

00102212 <vector78>:
.globl vector78
vector78:
  pushl $0
  102212:	6a 00                	push   $0x0
  pushl $78
  102214:	6a 4e                	push   $0x4e
  jmp __alltraps
  102216:	e9 b9 07 00 00       	jmp    1029d4 <__alltraps>

0010221b <vector79>:
.globl vector79
vector79:
  pushl $0
  10221b:	6a 00                	push   $0x0
  pushl $79
  10221d:	6a 4f                	push   $0x4f
  jmp __alltraps
  10221f:	e9 b0 07 00 00       	jmp    1029d4 <__alltraps>

00102224 <vector80>:
.globl vector80
vector80:
  pushl $0
  102224:	6a 00                	push   $0x0
  pushl $80
  102226:	6a 50                	push   $0x50
  jmp __alltraps
  102228:	e9 a7 07 00 00       	jmp    1029d4 <__alltraps>

0010222d <vector81>:
.globl vector81
vector81:
  pushl $0
  10222d:	6a 00                	push   $0x0
  pushl $81
  10222f:	6a 51                	push   $0x51
  jmp __alltraps
  102231:	e9 9e 07 00 00       	jmp    1029d4 <__alltraps>

00102236 <vector82>:
.globl vector82
vector82:
  pushl $0
  102236:	6a 00                	push   $0x0
  pushl $82
  102238:	6a 52                	push   $0x52
  jmp __alltraps
  10223a:	e9 95 07 00 00       	jmp    1029d4 <__alltraps>

0010223f <vector83>:
.globl vector83
vector83:
  pushl $0
  10223f:	6a 00                	push   $0x0
  pushl $83
  102241:	6a 53                	push   $0x53
  jmp __alltraps
  102243:	e9 8c 07 00 00       	jmp    1029d4 <__alltraps>

00102248 <vector84>:
.globl vector84
vector84:
  pushl $0
  102248:	6a 00                	push   $0x0
  pushl $84
  10224a:	6a 54                	push   $0x54
  jmp __alltraps
  10224c:	e9 83 07 00 00       	jmp    1029d4 <__alltraps>

00102251 <vector85>:
.globl vector85
vector85:
  pushl $0
  102251:	6a 00                	push   $0x0
  pushl $85
  102253:	6a 55                	push   $0x55
  jmp __alltraps
  102255:	e9 7a 07 00 00       	jmp    1029d4 <__alltraps>

0010225a <vector86>:
.globl vector86
vector86:
  pushl $0
  10225a:	6a 00                	push   $0x0
  pushl $86
  10225c:	6a 56                	push   $0x56
  jmp __alltraps
  10225e:	e9 71 07 00 00       	jmp    1029d4 <__alltraps>

00102263 <vector87>:
.globl vector87
vector87:
  pushl $0
  102263:	6a 00                	push   $0x0
  pushl $87
  102265:	6a 57                	push   $0x57
  jmp __alltraps
  102267:	e9 68 07 00 00       	jmp    1029d4 <__alltraps>

0010226c <vector88>:
.globl vector88
vector88:
  pushl $0
  10226c:	6a 00                	push   $0x0
  pushl $88
  10226e:	6a 58                	push   $0x58
  jmp __alltraps
  102270:	e9 5f 07 00 00       	jmp    1029d4 <__alltraps>

00102275 <vector89>:
.globl vector89
vector89:
  pushl $0
  102275:	6a 00                	push   $0x0
  pushl $89
  102277:	6a 59                	push   $0x59
  jmp __alltraps
  102279:	e9 56 07 00 00       	jmp    1029d4 <__alltraps>

0010227e <vector90>:
.globl vector90
vector90:
  pushl $0
  10227e:	6a 00                	push   $0x0
  pushl $90
  102280:	6a 5a                	push   $0x5a
  jmp __alltraps
  102282:	e9 4d 07 00 00       	jmp    1029d4 <__alltraps>

00102287 <vector91>:
.globl vector91
vector91:
  pushl $0
  102287:	6a 00                	push   $0x0
  pushl $91
  102289:	6a 5b                	push   $0x5b
  jmp __alltraps
  10228b:	e9 44 07 00 00       	jmp    1029d4 <__alltraps>

00102290 <vector92>:
.globl vector92
vector92:
  pushl $0
  102290:	6a 00                	push   $0x0
  pushl $92
  102292:	6a 5c                	push   $0x5c
  jmp __alltraps
  102294:	e9 3b 07 00 00       	jmp    1029d4 <__alltraps>

00102299 <vector93>:
.globl vector93
vector93:
  pushl $0
  102299:	6a 00                	push   $0x0
  pushl $93
  10229b:	6a 5d                	push   $0x5d
  jmp __alltraps
  10229d:	e9 32 07 00 00       	jmp    1029d4 <__alltraps>

001022a2 <vector94>:
.globl vector94
vector94:
  pushl $0
  1022a2:	6a 00                	push   $0x0
  pushl $94
  1022a4:	6a 5e                	push   $0x5e
  jmp __alltraps
  1022a6:	e9 29 07 00 00       	jmp    1029d4 <__alltraps>

001022ab <vector95>:
.globl vector95
vector95:
  pushl $0
  1022ab:	6a 00                	push   $0x0
  pushl $95
  1022ad:	6a 5f                	push   $0x5f
  jmp __alltraps
  1022af:	e9 20 07 00 00       	jmp    1029d4 <__alltraps>

001022b4 <vector96>:
.globl vector96
vector96:
  pushl $0
  1022b4:	6a 00                	push   $0x0
  pushl $96
  1022b6:	6a 60                	push   $0x60
  jmp __alltraps
  1022b8:	e9 17 07 00 00       	jmp    1029d4 <__alltraps>

001022bd <vector97>:
.globl vector97
vector97:
  pushl $0
  1022bd:	6a 00                	push   $0x0
  pushl $97
  1022bf:	6a 61                	push   $0x61
  jmp __alltraps
  1022c1:	e9 0e 07 00 00       	jmp    1029d4 <__alltraps>

001022c6 <vector98>:
.globl vector98
vector98:
  pushl $0
  1022c6:	6a 00                	push   $0x0
  pushl $98
  1022c8:	6a 62                	push   $0x62
  jmp __alltraps
  1022ca:	e9 05 07 00 00       	jmp    1029d4 <__alltraps>

001022cf <vector99>:
.globl vector99
vector99:
  pushl $0
  1022cf:	6a 00                	push   $0x0
  pushl $99
  1022d1:	6a 63                	push   $0x63
  jmp __alltraps
  1022d3:	e9 fc 06 00 00       	jmp    1029d4 <__alltraps>

001022d8 <vector100>:
.globl vector100
vector100:
  pushl $0
  1022d8:	6a 00                	push   $0x0
  pushl $100
  1022da:	6a 64                	push   $0x64
  jmp __alltraps
  1022dc:	e9 f3 06 00 00       	jmp    1029d4 <__alltraps>

001022e1 <vector101>:
.globl vector101
vector101:
  pushl $0
  1022e1:	6a 00                	push   $0x0
  pushl $101
  1022e3:	6a 65                	push   $0x65
  jmp __alltraps
  1022e5:	e9 ea 06 00 00       	jmp    1029d4 <__alltraps>

001022ea <vector102>:
.globl vector102
vector102:
  pushl $0
  1022ea:	6a 00                	push   $0x0
  pushl $102
  1022ec:	6a 66                	push   $0x66
  jmp __alltraps
  1022ee:	e9 e1 06 00 00       	jmp    1029d4 <__alltraps>

001022f3 <vector103>:
.globl vector103
vector103:
  pushl $0
  1022f3:	6a 00                	push   $0x0
  pushl $103
  1022f5:	6a 67                	push   $0x67
  jmp __alltraps
  1022f7:	e9 d8 06 00 00       	jmp    1029d4 <__alltraps>

001022fc <vector104>:
.globl vector104
vector104:
  pushl $0
  1022fc:	6a 00                	push   $0x0
  pushl $104
  1022fe:	6a 68                	push   $0x68
  jmp __alltraps
  102300:	e9 cf 06 00 00       	jmp    1029d4 <__alltraps>

00102305 <vector105>:
.globl vector105
vector105:
  pushl $0
  102305:	6a 00                	push   $0x0
  pushl $105
  102307:	6a 69                	push   $0x69
  jmp __alltraps
  102309:	e9 c6 06 00 00       	jmp    1029d4 <__alltraps>

0010230e <vector106>:
.globl vector106
vector106:
  pushl $0
  10230e:	6a 00                	push   $0x0
  pushl $106
  102310:	6a 6a                	push   $0x6a
  jmp __alltraps
  102312:	e9 bd 06 00 00       	jmp    1029d4 <__alltraps>

00102317 <vector107>:
.globl vector107
vector107:
  pushl $0
  102317:	6a 00                	push   $0x0
  pushl $107
  102319:	6a 6b                	push   $0x6b
  jmp __alltraps
  10231b:	e9 b4 06 00 00       	jmp    1029d4 <__alltraps>

00102320 <vector108>:
.globl vector108
vector108:
  pushl $0
  102320:	6a 00                	push   $0x0
  pushl $108
  102322:	6a 6c                	push   $0x6c
  jmp __alltraps
  102324:	e9 ab 06 00 00       	jmp    1029d4 <__alltraps>

00102329 <vector109>:
.globl vector109
vector109:
  pushl $0
  102329:	6a 00                	push   $0x0
  pushl $109
  10232b:	6a 6d                	push   $0x6d
  jmp __alltraps
  10232d:	e9 a2 06 00 00       	jmp    1029d4 <__alltraps>

00102332 <vector110>:
.globl vector110
vector110:
  pushl $0
  102332:	6a 00                	push   $0x0
  pushl $110
  102334:	6a 6e                	push   $0x6e
  jmp __alltraps
  102336:	e9 99 06 00 00       	jmp    1029d4 <__alltraps>

0010233b <vector111>:
.globl vector111
vector111:
  pushl $0
  10233b:	6a 00                	push   $0x0
  pushl $111
  10233d:	6a 6f                	push   $0x6f
  jmp __alltraps
  10233f:	e9 90 06 00 00       	jmp    1029d4 <__alltraps>

00102344 <vector112>:
.globl vector112
vector112:
  pushl $0
  102344:	6a 00                	push   $0x0
  pushl $112
  102346:	6a 70                	push   $0x70
  jmp __alltraps
  102348:	e9 87 06 00 00       	jmp    1029d4 <__alltraps>

0010234d <vector113>:
.globl vector113
vector113:
  pushl $0
  10234d:	6a 00                	push   $0x0
  pushl $113
  10234f:	6a 71                	push   $0x71
  jmp __alltraps
  102351:	e9 7e 06 00 00       	jmp    1029d4 <__alltraps>

00102356 <vector114>:
.globl vector114
vector114:
  pushl $0
  102356:	6a 00                	push   $0x0
  pushl $114
  102358:	6a 72                	push   $0x72
  jmp __alltraps
  10235a:	e9 75 06 00 00       	jmp    1029d4 <__alltraps>

0010235f <vector115>:
.globl vector115
vector115:
  pushl $0
  10235f:	6a 00                	push   $0x0
  pushl $115
  102361:	6a 73                	push   $0x73
  jmp __alltraps
  102363:	e9 6c 06 00 00       	jmp    1029d4 <__alltraps>

00102368 <vector116>:
.globl vector116
vector116:
  pushl $0
  102368:	6a 00                	push   $0x0
  pushl $116
  10236a:	6a 74                	push   $0x74
  jmp __alltraps
  10236c:	e9 63 06 00 00       	jmp    1029d4 <__alltraps>

00102371 <vector117>:
.globl vector117
vector117:
  pushl $0
  102371:	6a 00                	push   $0x0
  pushl $117
  102373:	6a 75                	push   $0x75
  jmp __alltraps
  102375:	e9 5a 06 00 00       	jmp    1029d4 <__alltraps>

0010237a <vector118>:
.globl vector118
vector118:
  pushl $0
  10237a:	6a 00                	push   $0x0
  pushl $118
  10237c:	6a 76                	push   $0x76
  jmp __alltraps
  10237e:	e9 51 06 00 00       	jmp    1029d4 <__alltraps>

00102383 <vector119>:
.globl vector119
vector119:
  pushl $0
  102383:	6a 00                	push   $0x0
  pushl $119
  102385:	6a 77                	push   $0x77
  jmp __alltraps
  102387:	e9 48 06 00 00       	jmp    1029d4 <__alltraps>

0010238c <vector120>:
.globl vector120
vector120:
  pushl $0
  10238c:	6a 00                	push   $0x0
  pushl $120
  10238e:	6a 78                	push   $0x78
  jmp __alltraps
  102390:	e9 3f 06 00 00       	jmp    1029d4 <__alltraps>

00102395 <vector121>:
.globl vector121
vector121:
  pushl $0
  102395:	6a 00                	push   $0x0
  pushl $121
  102397:	6a 79                	push   $0x79
  jmp __alltraps
  102399:	e9 36 06 00 00       	jmp    1029d4 <__alltraps>

0010239e <vector122>:
.globl vector122
vector122:
  pushl $0
  10239e:	6a 00                	push   $0x0
  pushl $122
  1023a0:	6a 7a                	push   $0x7a
  jmp __alltraps
  1023a2:	e9 2d 06 00 00       	jmp    1029d4 <__alltraps>

001023a7 <vector123>:
.globl vector123
vector123:
  pushl $0
  1023a7:	6a 00                	push   $0x0
  pushl $123
  1023a9:	6a 7b                	push   $0x7b
  jmp __alltraps
  1023ab:	e9 24 06 00 00       	jmp    1029d4 <__alltraps>

001023b0 <vector124>:
.globl vector124
vector124:
  pushl $0
  1023b0:	6a 00                	push   $0x0
  pushl $124
  1023b2:	6a 7c                	push   $0x7c
  jmp __alltraps
  1023b4:	e9 1b 06 00 00       	jmp    1029d4 <__alltraps>

001023b9 <vector125>:
.globl vector125
vector125:
  pushl $0
  1023b9:	6a 00                	push   $0x0
  pushl $125
  1023bb:	6a 7d                	push   $0x7d
  jmp __alltraps
  1023bd:	e9 12 06 00 00       	jmp    1029d4 <__alltraps>

001023c2 <vector126>:
.globl vector126
vector126:
  pushl $0
  1023c2:	6a 00                	push   $0x0
  pushl $126
  1023c4:	6a 7e                	push   $0x7e
  jmp __alltraps
  1023c6:	e9 09 06 00 00       	jmp    1029d4 <__alltraps>

001023cb <vector127>:
.globl vector127
vector127:
  pushl $0
  1023cb:	6a 00                	push   $0x0
  pushl $127
  1023cd:	6a 7f                	push   $0x7f
  jmp __alltraps
  1023cf:	e9 00 06 00 00       	jmp    1029d4 <__alltraps>

001023d4 <vector128>:
.globl vector128
vector128:
  pushl $0
  1023d4:	6a 00                	push   $0x0
  pushl $128
  1023d6:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1023db:	e9 f4 05 00 00       	jmp    1029d4 <__alltraps>

001023e0 <vector129>:
.globl vector129
vector129:
  pushl $0
  1023e0:	6a 00                	push   $0x0
  pushl $129
  1023e2:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1023e7:	e9 e8 05 00 00       	jmp    1029d4 <__alltraps>

001023ec <vector130>:
.globl vector130
vector130:
  pushl $0
  1023ec:	6a 00                	push   $0x0
  pushl $130
  1023ee:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1023f3:	e9 dc 05 00 00       	jmp    1029d4 <__alltraps>

001023f8 <vector131>:
.globl vector131
vector131:
  pushl $0
  1023f8:	6a 00                	push   $0x0
  pushl $131
  1023fa:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1023ff:	e9 d0 05 00 00       	jmp    1029d4 <__alltraps>

00102404 <vector132>:
.globl vector132
vector132:
  pushl $0
  102404:	6a 00                	push   $0x0
  pushl $132
  102406:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10240b:	e9 c4 05 00 00       	jmp    1029d4 <__alltraps>

00102410 <vector133>:
.globl vector133
vector133:
  pushl $0
  102410:	6a 00                	push   $0x0
  pushl $133
  102412:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102417:	e9 b8 05 00 00       	jmp    1029d4 <__alltraps>

0010241c <vector134>:
.globl vector134
vector134:
  pushl $0
  10241c:	6a 00                	push   $0x0
  pushl $134
  10241e:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102423:	e9 ac 05 00 00       	jmp    1029d4 <__alltraps>

00102428 <vector135>:
.globl vector135
vector135:
  pushl $0
  102428:	6a 00                	push   $0x0
  pushl $135
  10242a:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10242f:	e9 a0 05 00 00       	jmp    1029d4 <__alltraps>

00102434 <vector136>:
.globl vector136
vector136:
  pushl $0
  102434:	6a 00                	push   $0x0
  pushl $136
  102436:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10243b:	e9 94 05 00 00       	jmp    1029d4 <__alltraps>

00102440 <vector137>:
.globl vector137
vector137:
  pushl $0
  102440:	6a 00                	push   $0x0
  pushl $137
  102442:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102447:	e9 88 05 00 00       	jmp    1029d4 <__alltraps>

0010244c <vector138>:
.globl vector138
vector138:
  pushl $0
  10244c:	6a 00                	push   $0x0
  pushl $138
  10244e:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102453:	e9 7c 05 00 00       	jmp    1029d4 <__alltraps>

00102458 <vector139>:
.globl vector139
vector139:
  pushl $0
  102458:	6a 00                	push   $0x0
  pushl $139
  10245a:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10245f:	e9 70 05 00 00       	jmp    1029d4 <__alltraps>

00102464 <vector140>:
.globl vector140
vector140:
  pushl $0
  102464:	6a 00                	push   $0x0
  pushl $140
  102466:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10246b:	e9 64 05 00 00       	jmp    1029d4 <__alltraps>

00102470 <vector141>:
.globl vector141
vector141:
  pushl $0
  102470:	6a 00                	push   $0x0
  pushl $141
  102472:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102477:	e9 58 05 00 00       	jmp    1029d4 <__alltraps>

0010247c <vector142>:
.globl vector142
vector142:
  pushl $0
  10247c:	6a 00                	push   $0x0
  pushl $142
  10247e:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102483:	e9 4c 05 00 00       	jmp    1029d4 <__alltraps>

00102488 <vector143>:
.globl vector143
vector143:
  pushl $0
  102488:	6a 00                	push   $0x0
  pushl $143
  10248a:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10248f:	e9 40 05 00 00       	jmp    1029d4 <__alltraps>

00102494 <vector144>:
.globl vector144
vector144:
  pushl $0
  102494:	6a 00                	push   $0x0
  pushl $144
  102496:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10249b:	e9 34 05 00 00       	jmp    1029d4 <__alltraps>

001024a0 <vector145>:
.globl vector145
vector145:
  pushl $0
  1024a0:	6a 00                	push   $0x0
  pushl $145
  1024a2:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1024a7:	e9 28 05 00 00       	jmp    1029d4 <__alltraps>

001024ac <vector146>:
.globl vector146
vector146:
  pushl $0
  1024ac:	6a 00                	push   $0x0
  pushl $146
  1024ae:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1024b3:	e9 1c 05 00 00       	jmp    1029d4 <__alltraps>

001024b8 <vector147>:
.globl vector147
vector147:
  pushl $0
  1024b8:	6a 00                	push   $0x0
  pushl $147
  1024ba:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1024bf:	e9 10 05 00 00       	jmp    1029d4 <__alltraps>

001024c4 <vector148>:
.globl vector148
vector148:
  pushl $0
  1024c4:	6a 00                	push   $0x0
  pushl $148
  1024c6:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1024cb:	e9 04 05 00 00       	jmp    1029d4 <__alltraps>

001024d0 <vector149>:
.globl vector149
vector149:
  pushl $0
  1024d0:	6a 00                	push   $0x0
  pushl $149
  1024d2:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1024d7:	e9 f8 04 00 00       	jmp    1029d4 <__alltraps>

001024dc <vector150>:
.globl vector150
vector150:
  pushl $0
  1024dc:	6a 00                	push   $0x0
  pushl $150
  1024de:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1024e3:	e9 ec 04 00 00       	jmp    1029d4 <__alltraps>

001024e8 <vector151>:
.globl vector151
vector151:
  pushl $0
  1024e8:	6a 00                	push   $0x0
  pushl $151
  1024ea:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1024ef:	e9 e0 04 00 00       	jmp    1029d4 <__alltraps>

001024f4 <vector152>:
.globl vector152
vector152:
  pushl $0
  1024f4:	6a 00                	push   $0x0
  pushl $152
  1024f6:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1024fb:	e9 d4 04 00 00       	jmp    1029d4 <__alltraps>

00102500 <vector153>:
.globl vector153
vector153:
  pushl $0
  102500:	6a 00                	push   $0x0
  pushl $153
  102502:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102507:	e9 c8 04 00 00       	jmp    1029d4 <__alltraps>

0010250c <vector154>:
.globl vector154
vector154:
  pushl $0
  10250c:	6a 00                	push   $0x0
  pushl $154
  10250e:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102513:	e9 bc 04 00 00       	jmp    1029d4 <__alltraps>

00102518 <vector155>:
.globl vector155
vector155:
  pushl $0
  102518:	6a 00                	push   $0x0
  pushl $155
  10251a:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10251f:	e9 b0 04 00 00       	jmp    1029d4 <__alltraps>

00102524 <vector156>:
.globl vector156
vector156:
  pushl $0
  102524:	6a 00                	push   $0x0
  pushl $156
  102526:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10252b:	e9 a4 04 00 00       	jmp    1029d4 <__alltraps>

00102530 <vector157>:
.globl vector157
vector157:
  pushl $0
  102530:	6a 00                	push   $0x0
  pushl $157
  102532:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102537:	e9 98 04 00 00       	jmp    1029d4 <__alltraps>

0010253c <vector158>:
.globl vector158
vector158:
  pushl $0
  10253c:	6a 00                	push   $0x0
  pushl $158
  10253e:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102543:	e9 8c 04 00 00       	jmp    1029d4 <__alltraps>

00102548 <vector159>:
.globl vector159
vector159:
  pushl $0
  102548:	6a 00                	push   $0x0
  pushl $159
  10254a:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10254f:	e9 80 04 00 00       	jmp    1029d4 <__alltraps>

00102554 <vector160>:
.globl vector160
vector160:
  pushl $0
  102554:	6a 00                	push   $0x0
  pushl $160
  102556:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10255b:	e9 74 04 00 00       	jmp    1029d4 <__alltraps>

00102560 <vector161>:
.globl vector161
vector161:
  pushl $0
  102560:	6a 00                	push   $0x0
  pushl $161
  102562:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102567:	e9 68 04 00 00       	jmp    1029d4 <__alltraps>

0010256c <vector162>:
.globl vector162
vector162:
  pushl $0
  10256c:	6a 00                	push   $0x0
  pushl $162
  10256e:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102573:	e9 5c 04 00 00       	jmp    1029d4 <__alltraps>

00102578 <vector163>:
.globl vector163
vector163:
  pushl $0
  102578:	6a 00                	push   $0x0
  pushl $163
  10257a:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10257f:	e9 50 04 00 00       	jmp    1029d4 <__alltraps>

00102584 <vector164>:
.globl vector164
vector164:
  pushl $0
  102584:	6a 00                	push   $0x0
  pushl $164
  102586:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10258b:	e9 44 04 00 00       	jmp    1029d4 <__alltraps>

00102590 <vector165>:
.globl vector165
vector165:
  pushl $0
  102590:	6a 00                	push   $0x0
  pushl $165
  102592:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102597:	e9 38 04 00 00       	jmp    1029d4 <__alltraps>

0010259c <vector166>:
.globl vector166
vector166:
  pushl $0
  10259c:	6a 00                	push   $0x0
  pushl $166
  10259e:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1025a3:	e9 2c 04 00 00       	jmp    1029d4 <__alltraps>

001025a8 <vector167>:
.globl vector167
vector167:
  pushl $0
  1025a8:	6a 00                	push   $0x0
  pushl $167
  1025aa:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1025af:	e9 20 04 00 00       	jmp    1029d4 <__alltraps>

001025b4 <vector168>:
.globl vector168
vector168:
  pushl $0
  1025b4:	6a 00                	push   $0x0
  pushl $168
  1025b6:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1025bb:	e9 14 04 00 00       	jmp    1029d4 <__alltraps>

001025c0 <vector169>:
.globl vector169
vector169:
  pushl $0
  1025c0:	6a 00                	push   $0x0
  pushl $169
  1025c2:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1025c7:	e9 08 04 00 00       	jmp    1029d4 <__alltraps>

001025cc <vector170>:
.globl vector170
vector170:
  pushl $0
  1025cc:	6a 00                	push   $0x0
  pushl $170
  1025ce:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1025d3:	e9 fc 03 00 00       	jmp    1029d4 <__alltraps>

001025d8 <vector171>:
.globl vector171
vector171:
  pushl $0
  1025d8:	6a 00                	push   $0x0
  pushl $171
  1025da:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1025df:	e9 f0 03 00 00       	jmp    1029d4 <__alltraps>

001025e4 <vector172>:
.globl vector172
vector172:
  pushl $0
  1025e4:	6a 00                	push   $0x0
  pushl $172
  1025e6:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1025eb:	e9 e4 03 00 00       	jmp    1029d4 <__alltraps>

001025f0 <vector173>:
.globl vector173
vector173:
  pushl $0
  1025f0:	6a 00                	push   $0x0
  pushl $173
  1025f2:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1025f7:	e9 d8 03 00 00       	jmp    1029d4 <__alltraps>

001025fc <vector174>:
.globl vector174
vector174:
  pushl $0
  1025fc:	6a 00                	push   $0x0
  pushl $174
  1025fe:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102603:	e9 cc 03 00 00       	jmp    1029d4 <__alltraps>

00102608 <vector175>:
.globl vector175
vector175:
  pushl $0
  102608:	6a 00                	push   $0x0
  pushl $175
  10260a:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10260f:	e9 c0 03 00 00       	jmp    1029d4 <__alltraps>

00102614 <vector176>:
.globl vector176
vector176:
  pushl $0
  102614:	6a 00                	push   $0x0
  pushl $176
  102616:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10261b:	e9 b4 03 00 00       	jmp    1029d4 <__alltraps>

00102620 <vector177>:
.globl vector177
vector177:
  pushl $0
  102620:	6a 00                	push   $0x0
  pushl $177
  102622:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102627:	e9 a8 03 00 00       	jmp    1029d4 <__alltraps>

0010262c <vector178>:
.globl vector178
vector178:
  pushl $0
  10262c:	6a 00                	push   $0x0
  pushl $178
  10262e:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102633:	e9 9c 03 00 00       	jmp    1029d4 <__alltraps>

00102638 <vector179>:
.globl vector179
vector179:
  pushl $0
  102638:	6a 00                	push   $0x0
  pushl $179
  10263a:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10263f:	e9 90 03 00 00       	jmp    1029d4 <__alltraps>

00102644 <vector180>:
.globl vector180
vector180:
  pushl $0
  102644:	6a 00                	push   $0x0
  pushl $180
  102646:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10264b:	e9 84 03 00 00       	jmp    1029d4 <__alltraps>

00102650 <vector181>:
.globl vector181
vector181:
  pushl $0
  102650:	6a 00                	push   $0x0
  pushl $181
  102652:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102657:	e9 78 03 00 00       	jmp    1029d4 <__alltraps>

0010265c <vector182>:
.globl vector182
vector182:
  pushl $0
  10265c:	6a 00                	push   $0x0
  pushl $182
  10265e:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102663:	e9 6c 03 00 00       	jmp    1029d4 <__alltraps>

00102668 <vector183>:
.globl vector183
vector183:
  pushl $0
  102668:	6a 00                	push   $0x0
  pushl $183
  10266a:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10266f:	e9 60 03 00 00       	jmp    1029d4 <__alltraps>

00102674 <vector184>:
.globl vector184
vector184:
  pushl $0
  102674:	6a 00                	push   $0x0
  pushl $184
  102676:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10267b:	e9 54 03 00 00       	jmp    1029d4 <__alltraps>

00102680 <vector185>:
.globl vector185
vector185:
  pushl $0
  102680:	6a 00                	push   $0x0
  pushl $185
  102682:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102687:	e9 48 03 00 00       	jmp    1029d4 <__alltraps>

0010268c <vector186>:
.globl vector186
vector186:
  pushl $0
  10268c:	6a 00                	push   $0x0
  pushl $186
  10268e:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102693:	e9 3c 03 00 00       	jmp    1029d4 <__alltraps>

00102698 <vector187>:
.globl vector187
vector187:
  pushl $0
  102698:	6a 00                	push   $0x0
  pushl $187
  10269a:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10269f:	e9 30 03 00 00       	jmp    1029d4 <__alltraps>

001026a4 <vector188>:
.globl vector188
vector188:
  pushl $0
  1026a4:	6a 00                	push   $0x0
  pushl $188
  1026a6:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1026ab:	e9 24 03 00 00       	jmp    1029d4 <__alltraps>

001026b0 <vector189>:
.globl vector189
vector189:
  pushl $0
  1026b0:	6a 00                	push   $0x0
  pushl $189
  1026b2:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1026b7:	e9 18 03 00 00       	jmp    1029d4 <__alltraps>

001026bc <vector190>:
.globl vector190
vector190:
  pushl $0
  1026bc:	6a 00                	push   $0x0
  pushl $190
  1026be:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1026c3:	e9 0c 03 00 00       	jmp    1029d4 <__alltraps>

001026c8 <vector191>:
.globl vector191
vector191:
  pushl $0
  1026c8:	6a 00                	push   $0x0
  pushl $191
  1026ca:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1026cf:	e9 00 03 00 00       	jmp    1029d4 <__alltraps>

001026d4 <vector192>:
.globl vector192
vector192:
  pushl $0
  1026d4:	6a 00                	push   $0x0
  pushl $192
  1026d6:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1026db:	e9 f4 02 00 00       	jmp    1029d4 <__alltraps>

001026e0 <vector193>:
.globl vector193
vector193:
  pushl $0
  1026e0:	6a 00                	push   $0x0
  pushl $193
  1026e2:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1026e7:	e9 e8 02 00 00       	jmp    1029d4 <__alltraps>

001026ec <vector194>:
.globl vector194
vector194:
  pushl $0
  1026ec:	6a 00                	push   $0x0
  pushl $194
  1026ee:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1026f3:	e9 dc 02 00 00       	jmp    1029d4 <__alltraps>

001026f8 <vector195>:
.globl vector195
vector195:
  pushl $0
  1026f8:	6a 00                	push   $0x0
  pushl $195
  1026fa:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1026ff:	e9 d0 02 00 00       	jmp    1029d4 <__alltraps>

00102704 <vector196>:
.globl vector196
vector196:
  pushl $0
  102704:	6a 00                	push   $0x0
  pushl $196
  102706:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10270b:	e9 c4 02 00 00       	jmp    1029d4 <__alltraps>

00102710 <vector197>:
.globl vector197
vector197:
  pushl $0
  102710:	6a 00                	push   $0x0
  pushl $197
  102712:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102717:	e9 b8 02 00 00       	jmp    1029d4 <__alltraps>

0010271c <vector198>:
.globl vector198
vector198:
  pushl $0
  10271c:	6a 00                	push   $0x0
  pushl $198
  10271e:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102723:	e9 ac 02 00 00       	jmp    1029d4 <__alltraps>

00102728 <vector199>:
.globl vector199
vector199:
  pushl $0
  102728:	6a 00                	push   $0x0
  pushl $199
  10272a:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10272f:	e9 a0 02 00 00       	jmp    1029d4 <__alltraps>

00102734 <vector200>:
.globl vector200
vector200:
  pushl $0
  102734:	6a 00                	push   $0x0
  pushl $200
  102736:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10273b:	e9 94 02 00 00       	jmp    1029d4 <__alltraps>

00102740 <vector201>:
.globl vector201
vector201:
  pushl $0
  102740:	6a 00                	push   $0x0
  pushl $201
  102742:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102747:	e9 88 02 00 00       	jmp    1029d4 <__alltraps>

0010274c <vector202>:
.globl vector202
vector202:
  pushl $0
  10274c:	6a 00                	push   $0x0
  pushl $202
  10274e:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102753:	e9 7c 02 00 00       	jmp    1029d4 <__alltraps>

00102758 <vector203>:
.globl vector203
vector203:
  pushl $0
  102758:	6a 00                	push   $0x0
  pushl $203
  10275a:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10275f:	e9 70 02 00 00       	jmp    1029d4 <__alltraps>

00102764 <vector204>:
.globl vector204
vector204:
  pushl $0
  102764:	6a 00                	push   $0x0
  pushl $204
  102766:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10276b:	e9 64 02 00 00       	jmp    1029d4 <__alltraps>

00102770 <vector205>:
.globl vector205
vector205:
  pushl $0
  102770:	6a 00                	push   $0x0
  pushl $205
  102772:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102777:	e9 58 02 00 00       	jmp    1029d4 <__alltraps>

0010277c <vector206>:
.globl vector206
vector206:
  pushl $0
  10277c:	6a 00                	push   $0x0
  pushl $206
  10277e:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102783:	e9 4c 02 00 00       	jmp    1029d4 <__alltraps>

00102788 <vector207>:
.globl vector207
vector207:
  pushl $0
  102788:	6a 00                	push   $0x0
  pushl $207
  10278a:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10278f:	e9 40 02 00 00       	jmp    1029d4 <__alltraps>

00102794 <vector208>:
.globl vector208
vector208:
  pushl $0
  102794:	6a 00                	push   $0x0
  pushl $208
  102796:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10279b:	e9 34 02 00 00       	jmp    1029d4 <__alltraps>

001027a0 <vector209>:
.globl vector209
vector209:
  pushl $0
  1027a0:	6a 00                	push   $0x0
  pushl $209
  1027a2:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1027a7:	e9 28 02 00 00       	jmp    1029d4 <__alltraps>

001027ac <vector210>:
.globl vector210
vector210:
  pushl $0
  1027ac:	6a 00                	push   $0x0
  pushl $210
  1027ae:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1027b3:	e9 1c 02 00 00       	jmp    1029d4 <__alltraps>

001027b8 <vector211>:
.globl vector211
vector211:
  pushl $0
  1027b8:	6a 00                	push   $0x0
  pushl $211
  1027ba:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1027bf:	e9 10 02 00 00       	jmp    1029d4 <__alltraps>

001027c4 <vector212>:
.globl vector212
vector212:
  pushl $0
  1027c4:	6a 00                	push   $0x0
  pushl $212
  1027c6:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1027cb:	e9 04 02 00 00       	jmp    1029d4 <__alltraps>

001027d0 <vector213>:
.globl vector213
vector213:
  pushl $0
  1027d0:	6a 00                	push   $0x0
  pushl $213
  1027d2:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1027d7:	e9 f8 01 00 00       	jmp    1029d4 <__alltraps>

001027dc <vector214>:
.globl vector214
vector214:
  pushl $0
  1027dc:	6a 00                	push   $0x0
  pushl $214
  1027de:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1027e3:	e9 ec 01 00 00       	jmp    1029d4 <__alltraps>

001027e8 <vector215>:
.globl vector215
vector215:
  pushl $0
  1027e8:	6a 00                	push   $0x0
  pushl $215
  1027ea:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1027ef:	e9 e0 01 00 00       	jmp    1029d4 <__alltraps>

001027f4 <vector216>:
.globl vector216
vector216:
  pushl $0
  1027f4:	6a 00                	push   $0x0
  pushl $216
  1027f6:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1027fb:	e9 d4 01 00 00       	jmp    1029d4 <__alltraps>

00102800 <vector217>:
.globl vector217
vector217:
  pushl $0
  102800:	6a 00                	push   $0x0
  pushl $217
  102802:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102807:	e9 c8 01 00 00       	jmp    1029d4 <__alltraps>

0010280c <vector218>:
.globl vector218
vector218:
  pushl $0
  10280c:	6a 00                	push   $0x0
  pushl $218
  10280e:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102813:	e9 bc 01 00 00       	jmp    1029d4 <__alltraps>

00102818 <vector219>:
.globl vector219
vector219:
  pushl $0
  102818:	6a 00                	push   $0x0
  pushl $219
  10281a:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10281f:	e9 b0 01 00 00       	jmp    1029d4 <__alltraps>

00102824 <vector220>:
.globl vector220
vector220:
  pushl $0
  102824:	6a 00                	push   $0x0
  pushl $220
  102826:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10282b:	e9 a4 01 00 00       	jmp    1029d4 <__alltraps>

00102830 <vector221>:
.globl vector221
vector221:
  pushl $0
  102830:	6a 00                	push   $0x0
  pushl $221
  102832:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102837:	e9 98 01 00 00       	jmp    1029d4 <__alltraps>

0010283c <vector222>:
.globl vector222
vector222:
  pushl $0
  10283c:	6a 00                	push   $0x0
  pushl $222
  10283e:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102843:	e9 8c 01 00 00       	jmp    1029d4 <__alltraps>

00102848 <vector223>:
.globl vector223
vector223:
  pushl $0
  102848:	6a 00                	push   $0x0
  pushl $223
  10284a:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10284f:	e9 80 01 00 00       	jmp    1029d4 <__alltraps>

00102854 <vector224>:
.globl vector224
vector224:
  pushl $0
  102854:	6a 00                	push   $0x0
  pushl $224
  102856:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10285b:	e9 74 01 00 00       	jmp    1029d4 <__alltraps>

00102860 <vector225>:
.globl vector225
vector225:
  pushl $0
  102860:	6a 00                	push   $0x0
  pushl $225
  102862:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102867:	e9 68 01 00 00       	jmp    1029d4 <__alltraps>

0010286c <vector226>:
.globl vector226
vector226:
  pushl $0
  10286c:	6a 00                	push   $0x0
  pushl $226
  10286e:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102873:	e9 5c 01 00 00       	jmp    1029d4 <__alltraps>

00102878 <vector227>:
.globl vector227
vector227:
  pushl $0
  102878:	6a 00                	push   $0x0
  pushl $227
  10287a:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10287f:	e9 50 01 00 00       	jmp    1029d4 <__alltraps>

00102884 <vector228>:
.globl vector228
vector228:
  pushl $0
  102884:	6a 00                	push   $0x0
  pushl $228
  102886:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10288b:	e9 44 01 00 00       	jmp    1029d4 <__alltraps>

00102890 <vector229>:
.globl vector229
vector229:
  pushl $0
  102890:	6a 00                	push   $0x0
  pushl $229
  102892:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102897:	e9 38 01 00 00       	jmp    1029d4 <__alltraps>

0010289c <vector230>:
.globl vector230
vector230:
  pushl $0
  10289c:	6a 00                	push   $0x0
  pushl $230
  10289e:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1028a3:	e9 2c 01 00 00       	jmp    1029d4 <__alltraps>

001028a8 <vector231>:
.globl vector231
vector231:
  pushl $0
  1028a8:	6a 00                	push   $0x0
  pushl $231
  1028aa:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1028af:	e9 20 01 00 00       	jmp    1029d4 <__alltraps>

001028b4 <vector232>:
.globl vector232
vector232:
  pushl $0
  1028b4:	6a 00                	push   $0x0
  pushl $232
  1028b6:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1028bb:	e9 14 01 00 00       	jmp    1029d4 <__alltraps>

001028c0 <vector233>:
.globl vector233
vector233:
  pushl $0
  1028c0:	6a 00                	push   $0x0
  pushl $233
  1028c2:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1028c7:	e9 08 01 00 00       	jmp    1029d4 <__alltraps>

001028cc <vector234>:
.globl vector234
vector234:
  pushl $0
  1028cc:	6a 00                	push   $0x0
  pushl $234
  1028ce:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1028d3:	e9 fc 00 00 00       	jmp    1029d4 <__alltraps>

001028d8 <vector235>:
.globl vector235
vector235:
  pushl $0
  1028d8:	6a 00                	push   $0x0
  pushl $235
  1028da:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1028df:	e9 f0 00 00 00       	jmp    1029d4 <__alltraps>

001028e4 <vector236>:
.globl vector236
vector236:
  pushl $0
  1028e4:	6a 00                	push   $0x0
  pushl $236
  1028e6:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1028eb:	e9 e4 00 00 00       	jmp    1029d4 <__alltraps>

001028f0 <vector237>:
.globl vector237
vector237:
  pushl $0
  1028f0:	6a 00                	push   $0x0
  pushl $237
  1028f2:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1028f7:	e9 d8 00 00 00       	jmp    1029d4 <__alltraps>

001028fc <vector238>:
.globl vector238
vector238:
  pushl $0
  1028fc:	6a 00                	push   $0x0
  pushl $238
  1028fe:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102903:	e9 cc 00 00 00       	jmp    1029d4 <__alltraps>

00102908 <vector239>:
.globl vector239
vector239:
  pushl $0
  102908:	6a 00                	push   $0x0
  pushl $239
  10290a:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10290f:	e9 c0 00 00 00       	jmp    1029d4 <__alltraps>

00102914 <vector240>:
.globl vector240
vector240:
  pushl $0
  102914:	6a 00                	push   $0x0
  pushl $240
  102916:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10291b:	e9 b4 00 00 00       	jmp    1029d4 <__alltraps>

00102920 <vector241>:
.globl vector241
vector241:
  pushl $0
  102920:	6a 00                	push   $0x0
  pushl $241
  102922:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102927:	e9 a8 00 00 00       	jmp    1029d4 <__alltraps>

0010292c <vector242>:
.globl vector242
vector242:
  pushl $0
  10292c:	6a 00                	push   $0x0
  pushl $242
  10292e:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102933:	e9 9c 00 00 00       	jmp    1029d4 <__alltraps>

00102938 <vector243>:
.globl vector243
vector243:
  pushl $0
  102938:	6a 00                	push   $0x0
  pushl $243
  10293a:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10293f:	e9 90 00 00 00       	jmp    1029d4 <__alltraps>

00102944 <vector244>:
.globl vector244
vector244:
  pushl $0
  102944:	6a 00                	push   $0x0
  pushl $244
  102946:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10294b:	e9 84 00 00 00       	jmp    1029d4 <__alltraps>

00102950 <vector245>:
.globl vector245
vector245:
  pushl $0
  102950:	6a 00                	push   $0x0
  pushl $245
  102952:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102957:	e9 78 00 00 00       	jmp    1029d4 <__alltraps>

0010295c <vector246>:
.globl vector246
vector246:
  pushl $0
  10295c:	6a 00                	push   $0x0
  pushl $246
  10295e:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102963:	e9 6c 00 00 00       	jmp    1029d4 <__alltraps>

00102968 <vector247>:
.globl vector247
vector247:
  pushl $0
  102968:	6a 00                	push   $0x0
  pushl $247
  10296a:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10296f:	e9 60 00 00 00       	jmp    1029d4 <__alltraps>

00102974 <vector248>:
.globl vector248
vector248:
  pushl $0
  102974:	6a 00                	push   $0x0
  pushl $248
  102976:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10297b:	e9 54 00 00 00       	jmp    1029d4 <__alltraps>

00102980 <vector249>:
.globl vector249
vector249:
  pushl $0
  102980:	6a 00                	push   $0x0
  pushl $249
  102982:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102987:	e9 48 00 00 00       	jmp    1029d4 <__alltraps>

0010298c <vector250>:
.globl vector250
vector250:
  pushl $0
  10298c:	6a 00                	push   $0x0
  pushl $250
  10298e:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102993:	e9 3c 00 00 00       	jmp    1029d4 <__alltraps>

00102998 <vector251>:
.globl vector251
vector251:
  pushl $0
  102998:	6a 00                	push   $0x0
  pushl $251
  10299a:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  10299f:	e9 30 00 00 00       	jmp    1029d4 <__alltraps>

001029a4 <vector252>:
.globl vector252
vector252:
  pushl $0
  1029a4:	6a 00                	push   $0x0
  pushl $252
  1029a6:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1029ab:	e9 24 00 00 00       	jmp    1029d4 <__alltraps>

001029b0 <vector253>:
.globl vector253
vector253:
  pushl $0
  1029b0:	6a 00                	push   $0x0
  pushl $253
  1029b2:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1029b7:	e9 18 00 00 00       	jmp    1029d4 <__alltraps>

001029bc <vector254>:
.globl vector254
vector254:
  pushl $0
  1029bc:	6a 00                	push   $0x0
  pushl $254
  1029be:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1029c3:	e9 0c 00 00 00       	jmp    1029d4 <__alltraps>

001029c8 <vector255>:
.globl vector255
vector255:
  pushl $0
  1029c8:	6a 00                	push   $0x0
  pushl $255
  1029ca:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1029cf:	e9 00 00 00 00       	jmp    1029d4 <__alltraps>

001029d4 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1029d4:	1e                   	push   %ds
    pushl %es
  1029d5:	06                   	push   %es
    pushl %fs
  1029d6:	0f a0                	push   %fs
    pushl %gs
  1029d8:	0f a8                	push   %gs
    pushal
  1029da:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  1029db:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  1029e0:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1029e2:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1029e4:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1029e5:	e8 64 f5 ff ff       	call   101f4e <trap>

    # pop the pushed stack pointer
    popl %esp
  1029ea:	5c                   	pop    %esp

001029eb <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  1029eb:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  1029ec:	0f a9                	pop    %gs
    popl %fs
  1029ee:	0f a1                	pop    %fs
    popl %es
  1029f0:	07                   	pop    %es
    popl %ds
  1029f1:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  1029f2:	83 c4 08             	add    $0x8,%esp
    iret
  1029f5:	cf                   	iret   

001029f6 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1029f6:	55                   	push   %ebp
  1029f7:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1029f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1029fc:	8b 15 78 af 11 00    	mov    0x11af78,%edx
  102a02:	29 d0                	sub    %edx,%eax
  102a04:	c1 f8 02             	sar    $0x2,%eax
  102a07:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102a0d:	5d                   	pop    %ebp
  102a0e:	c3                   	ret    

00102a0f <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102a0f:	55                   	push   %ebp
  102a10:	89 e5                	mov    %esp,%ebp
  102a12:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102a15:	8b 45 08             	mov    0x8(%ebp),%eax
  102a18:	89 04 24             	mov    %eax,(%esp)
  102a1b:	e8 d6 ff ff ff       	call   1029f6 <page2ppn>
  102a20:	c1 e0 0c             	shl    $0xc,%eax
}
  102a23:	c9                   	leave  
  102a24:	c3                   	ret    

00102a25 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102a25:	55                   	push   %ebp
  102a26:	89 e5                	mov    %esp,%ebp
  102a28:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  102a2e:	c1 e8 0c             	shr    $0xc,%eax
  102a31:	89 c2                	mov    %eax,%edx
  102a33:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102a38:	39 c2                	cmp    %eax,%edx
  102a3a:	72 1c                	jb     102a58 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102a3c:	c7 44 24 08 10 68 10 	movl   $0x106810,0x8(%esp)
  102a43:	00 
  102a44:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102a4b:	00 
  102a4c:	c7 04 24 2f 68 10 00 	movl   $0x10682f,(%esp)
  102a53:	e8 91 d9 ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  102a58:	8b 0d 78 af 11 00    	mov    0x11af78,%ecx
  102a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  102a61:	c1 e8 0c             	shr    $0xc,%eax
  102a64:	89 c2                	mov    %eax,%edx
  102a66:	89 d0                	mov    %edx,%eax
  102a68:	c1 e0 02             	shl    $0x2,%eax
  102a6b:	01 d0                	add    %edx,%eax
  102a6d:	c1 e0 02             	shl    $0x2,%eax
  102a70:	01 c8                	add    %ecx,%eax
}
  102a72:	c9                   	leave  
  102a73:	c3                   	ret    

00102a74 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102a74:	55                   	push   %ebp
  102a75:	89 e5                	mov    %esp,%ebp
  102a77:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  102a7d:	89 04 24             	mov    %eax,(%esp)
  102a80:	e8 8a ff ff ff       	call   102a0f <page2pa>
  102a85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a8b:	c1 e8 0c             	shr    $0xc,%eax
  102a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102a91:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102a96:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102a99:	72 23                	jb     102abe <page2kva+0x4a>
  102a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102aa2:	c7 44 24 08 40 68 10 	movl   $0x106840,0x8(%esp)
  102aa9:	00 
  102aaa:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  102ab1:	00 
  102ab2:	c7 04 24 2f 68 10 00 	movl   $0x10682f,(%esp)
  102ab9:	e8 2b d9 ff ff       	call   1003e9 <__panic>
  102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ac1:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102ac6:	c9                   	leave  
  102ac7:	c3                   	ret    

00102ac8 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102ac8:	55                   	push   %ebp
  102ac9:	89 e5                	mov    %esp,%ebp
  102acb:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102ace:	8b 45 08             	mov    0x8(%ebp),%eax
  102ad1:	83 e0 01             	and    $0x1,%eax
  102ad4:	85 c0                	test   %eax,%eax
  102ad6:	75 1c                	jne    102af4 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102ad8:	c7 44 24 08 64 68 10 	movl   $0x106864,0x8(%esp)
  102adf:	00 
  102ae0:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  102ae7:	00 
  102ae8:	c7 04 24 2f 68 10 00 	movl   $0x10682f,(%esp)
  102aef:	e8 f5 d8 ff ff       	call   1003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102af4:	8b 45 08             	mov    0x8(%ebp),%eax
  102af7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102afc:	89 04 24             	mov    %eax,(%esp)
  102aff:	e8 21 ff ff ff       	call   102a25 <pa2page>
}
  102b04:	c9                   	leave  
  102b05:	c3                   	ret    

00102b06 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  102b06:	55                   	push   %ebp
  102b07:	89 e5                	mov    %esp,%ebp
  102b09:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102b14:	89 04 24             	mov    %eax,(%esp)
  102b17:	e8 09 ff ff ff       	call   102a25 <pa2page>
}
  102b1c:	c9                   	leave  
  102b1d:	c3                   	ret    

00102b1e <page_ref>:

static inline int
page_ref(struct Page *page) {
  102b1e:	55                   	push   %ebp
  102b1f:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102b21:	8b 45 08             	mov    0x8(%ebp),%eax
  102b24:	8b 00                	mov    (%eax),%eax
}
  102b26:	5d                   	pop    %ebp
  102b27:	c3                   	ret    

00102b28 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102b28:	55                   	push   %ebp
  102b29:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b31:	89 10                	mov    %edx,(%eax)
}
  102b33:	90                   	nop
  102b34:	5d                   	pop    %ebp
  102b35:	c3                   	ret    

00102b36 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102b36:	55                   	push   %ebp
  102b37:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102b39:	8b 45 08             	mov    0x8(%ebp),%eax
  102b3c:	8b 00                	mov    (%eax),%eax
  102b3e:	8d 50 01             	lea    0x1(%eax),%edx
  102b41:	8b 45 08             	mov    0x8(%ebp),%eax
  102b44:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102b46:	8b 45 08             	mov    0x8(%ebp),%eax
  102b49:	8b 00                	mov    (%eax),%eax
}
  102b4b:	5d                   	pop    %ebp
  102b4c:	c3                   	ret    

00102b4d <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102b4d:	55                   	push   %ebp
  102b4e:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102b50:	8b 45 08             	mov    0x8(%ebp),%eax
  102b53:	8b 00                	mov    (%eax),%eax
  102b55:	8d 50 ff             	lea    -0x1(%eax),%edx
  102b58:	8b 45 08             	mov    0x8(%ebp),%eax
  102b5b:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  102b60:	8b 00                	mov    (%eax),%eax
}
  102b62:	5d                   	pop    %ebp
  102b63:	c3                   	ret    

00102b64 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  102b64:	55                   	push   %ebp
  102b65:	89 e5                	mov    %esp,%ebp
  102b67:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102b6a:	9c                   	pushf  
  102b6b:	58                   	pop    %eax
  102b6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102b72:	25 00 02 00 00       	and    $0x200,%eax
  102b77:	85 c0                	test   %eax,%eax
  102b79:	74 0c                	je     102b87 <__intr_save+0x23>
        intr_disable();
  102b7b:	e8 f9 ec ff ff       	call   101879 <intr_disable>
        return 1;
  102b80:	b8 01 00 00 00       	mov    $0x1,%eax
  102b85:	eb 05                	jmp    102b8c <__intr_save+0x28>
    }
    return 0;
  102b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102b8c:	c9                   	leave  
  102b8d:	c3                   	ret    

00102b8e <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  102b8e:	55                   	push   %ebp
  102b8f:	89 e5                	mov    %esp,%ebp
  102b91:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102b94:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102b98:	74 05                	je     102b9f <__intr_restore+0x11>
        intr_enable();
  102b9a:	e8 d3 ec ff ff       	call   101872 <intr_enable>
    }
}
  102b9f:	90                   	nop
  102ba0:	c9                   	leave  
  102ba1:	c3                   	ret    

00102ba2 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102ba2:	55                   	push   %ebp
  102ba3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  102ba8:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102bab:	b8 23 00 00 00       	mov    $0x23,%eax
  102bb0:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102bb2:	b8 23 00 00 00       	mov    $0x23,%eax
  102bb7:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102bb9:	b8 10 00 00 00       	mov    $0x10,%eax
  102bbe:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102bc0:	b8 10 00 00 00       	mov    $0x10,%eax
  102bc5:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102bc7:	b8 10 00 00 00       	mov    $0x10,%eax
  102bcc:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102bce:	ea d5 2b 10 00 08 00 	ljmp   $0x8,$0x102bd5
}
  102bd5:	90                   	nop
  102bd6:	5d                   	pop    %ebp
  102bd7:	c3                   	ret    

00102bd8 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102bd8:	55                   	push   %ebp
  102bd9:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  102bde:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  102be3:	90                   	nop
  102be4:	5d                   	pop    %ebp
  102be5:	c3                   	ret    

00102be6 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102be6:	55                   	push   %ebp
  102be7:	89 e5                	mov    %esp,%ebp
  102be9:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102bec:	b8 00 70 11 00       	mov    $0x117000,%eax
  102bf1:	89 04 24             	mov    %eax,(%esp)
  102bf4:	e8 df ff ff ff       	call   102bd8 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102bf9:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  102c00:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102c02:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102c09:	68 00 
  102c0b:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102c10:	0f b7 c0             	movzwl %ax,%eax
  102c13:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102c19:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102c1e:	c1 e8 10             	shr    $0x10,%eax
  102c21:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102c26:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102c2d:	24 f0                	and    $0xf0,%al
  102c2f:	0c 09                	or     $0x9,%al
  102c31:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102c36:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102c3d:	24 ef                	and    $0xef,%al
  102c3f:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102c44:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102c4b:	24 9f                	and    $0x9f,%al
  102c4d:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102c52:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102c59:	0c 80                	or     $0x80,%al
  102c5b:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102c60:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c67:	24 f0                	and    $0xf0,%al
  102c69:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102c6e:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c75:	24 ef                	and    $0xef,%al
  102c77:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102c7c:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c83:	24 df                	and    $0xdf,%al
  102c85:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102c8a:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c91:	0c 40                	or     $0x40,%al
  102c93:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102c98:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c9f:	24 7f                	and    $0x7f,%al
  102ca1:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102ca6:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102cab:	c1 e8 18             	shr    $0x18,%eax
  102cae:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102cb3:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102cba:	e8 e3 fe ff ff       	call   102ba2 <lgdt>
  102cbf:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102cc5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102cc9:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102ccc:	90                   	nop
  102ccd:	c9                   	leave  
  102cce:	c3                   	ret    

00102ccf <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102ccf:	55                   	push   %ebp
  102cd0:	89 e5                	mov    %esp,%ebp
  102cd2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102cd5:	c7 05 70 af 11 00 08 	movl   $0x107208,0x11af70
  102cdc:	72 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102cdf:	a1 70 af 11 00       	mov    0x11af70,%eax
  102ce4:	8b 00                	mov    (%eax),%eax
  102ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  102cea:	c7 04 24 90 68 10 00 	movl   $0x106890,(%esp)
  102cf1:	e8 9c d5 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102cf6:	a1 70 af 11 00       	mov    0x11af70,%eax
  102cfb:	8b 40 04             	mov    0x4(%eax),%eax
  102cfe:	ff d0                	call   *%eax
}
  102d00:	90                   	nop
  102d01:	c9                   	leave  
  102d02:	c3                   	ret    

00102d03 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102d03:	55                   	push   %ebp
  102d04:	89 e5                	mov    %esp,%ebp
  102d06:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102d09:	a1 70 af 11 00       	mov    0x11af70,%eax
  102d0e:	8b 40 08             	mov    0x8(%eax),%eax
  102d11:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d14:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d18:	8b 55 08             	mov    0x8(%ebp),%edx
  102d1b:	89 14 24             	mov    %edx,(%esp)
  102d1e:	ff d0                	call   *%eax
}
  102d20:	90                   	nop
  102d21:	c9                   	leave  
  102d22:	c3                   	ret    

00102d23 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102d23:	55                   	push   %ebp
  102d24:	89 e5                	mov    %esp,%ebp
  102d26:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102d29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102d30:	e8 2f fe ff ff       	call   102b64 <__intr_save>
  102d35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102d38:	a1 70 af 11 00       	mov    0x11af70,%eax
  102d3d:	8b 40 0c             	mov    0xc(%eax),%eax
  102d40:	8b 55 08             	mov    0x8(%ebp),%edx
  102d43:	89 14 24             	mov    %edx,(%esp)
  102d46:	ff d0                	call   *%eax
  102d48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d4e:	89 04 24             	mov    %eax,(%esp)
  102d51:	e8 38 fe ff ff       	call   102b8e <__intr_restore>
    return page;
  102d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102d59:	c9                   	leave  
  102d5a:	c3                   	ret    

00102d5b <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102d5b:	55                   	push   %ebp
  102d5c:	89 e5                	mov    %esp,%ebp
  102d5e:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102d61:	e8 fe fd ff ff       	call   102b64 <__intr_save>
  102d66:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102d69:	a1 70 af 11 00       	mov    0x11af70,%eax
  102d6e:	8b 40 10             	mov    0x10(%eax),%eax
  102d71:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d74:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d78:	8b 55 08             	mov    0x8(%ebp),%edx
  102d7b:	89 14 24             	mov    %edx,(%esp)
  102d7e:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d83:	89 04 24             	mov    %eax,(%esp)
  102d86:	e8 03 fe ff ff       	call   102b8e <__intr_restore>
}
  102d8b:	90                   	nop
  102d8c:	c9                   	leave  
  102d8d:	c3                   	ret    

00102d8e <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102d8e:	55                   	push   %ebp
  102d8f:	89 e5                	mov    %esp,%ebp
  102d91:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102d94:	e8 cb fd ff ff       	call   102b64 <__intr_save>
  102d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102d9c:	a1 70 af 11 00       	mov    0x11af70,%eax
  102da1:	8b 40 14             	mov    0x14(%eax),%eax
  102da4:	ff d0                	call   *%eax
  102da6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dac:	89 04 24             	mov    %eax,(%esp)
  102daf:	e8 da fd ff ff       	call   102b8e <__intr_restore>
    return ret;
  102db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102db7:	c9                   	leave  
  102db8:	c3                   	ret    

00102db9 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102db9:	55                   	push   %ebp
  102dba:	89 e5                	mov    %esp,%ebp
  102dbc:	57                   	push   %edi
  102dbd:	56                   	push   %esi
  102dbe:	53                   	push   %ebx
  102dbf:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102dc5:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102dcc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102dd3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102dda:	c7 04 24 a7 68 10 00 	movl   $0x1068a7,(%esp)
  102de1:	e8 ac d4 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102de6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ded:	e9 22 01 00 00       	jmp    102f14 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102df2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102df5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102df8:	89 d0                	mov    %edx,%eax
  102dfa:	c1 e0 02             	shl    $0x2,%eax
  102dfd:	01 d0                	add    %edx,%eax
  102dff:	c1 e0 02             	shl    $0x2,%eax
  102e02:	01 c8                	add    %ecx,%eax
  102e04:	8b 50 08             	mov    0x8(%eax),%edx
  102e07:	8b 40 04             	mov    0x4(%eax),%eax
  102e0a:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102e0d:	89 55 bc             	mov    %edx,-0x44(%ebp)
  102e10:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e13:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e16:	89 d0                	mov    %edx,%eax
  102e18:	c1 e0 02             	shl    $0x2,%eax
  102e1b:	01 d0                	add    %edx,%eax
  102e1d:	c1 e0 02             	shl    $0x2,%eax
  102e20:	01 c8                	add    %ecx,%eax
  102e22:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e25:	8b 58 10             	mov    0x10(%eax),%ebx
  102e28:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102e2b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102e2e:	01 c8                	add    %ecx,%eax
  102e30:	11 da                	adc    %ebx,%edx
  102e32:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102e35:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102e38:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e3e:	89 d0                	mov    %edx,%eax
  102e40:	c1 e0 02             	shl    $0x2,%eax
  102e43:	01 d0                	add    %edx,%eax
  102e45:	c1 e0 02             	shl    $0x2,%eax
  102e48:	01 c8                	add    %ecx,%eax
  102e4a:	83 c0 14             	add    $0x14,%eax
  102e4d:	8b 00                	mov    (%eax),%eax
  102e4f:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102e52:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102e55:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102e58:	83 c0 ff             	add    $0xffffffff,%eax
  102e5b:	83 d2 ff             	adc    $0xffffffff,%edx
  102e5e:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102e64:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102e6a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e6d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e70:	89 d0                	mov    %edx,%eax
  102e72:	c1 e0 02             	shl    $0x2,%eax
  102e75:	01 d0                	add    %edx,%eax
  102e77:	c1 e0 02             	shl    $0x2,%eax
  102e7a:	01 c8                	add    %ecx,%eax
  102e7c:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e7f:	8b 58 10             	mov    0x10(%eax),%ebx
  102e82:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102e85:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102e89:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102e8f:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102e95:	89 44 24 14          	mov    %eax,0x14(%esp)
  102e99:	89 54 24 18          	mov    %edx,0x18(%esp)
  102e9d:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ea0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ea7:	89 54 24 10          	mov    %edx,0x10(%esp)
  102eab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102eaf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102eb3:	c7 04 24 b4 68 10 00 	movl   $0x1068b4,(%esp)
  102eba:	e8 d3 d3 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102ebf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ec2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ec5:	89 d0                	mov    %edx,%eax
  102ec7:	c1 e0 02             	shl    $0x2,%eax
  102eca:	01 d0                	add    %edx,%eax
  102ecc:	c1 e0 02             	shl    $0x2,%eax
  102ecf:	01 c8                	add    %ecx,%eax
  102ed1:	83 c0 14             	add    $0x14,%eax
  102ed4:	8b 00                	mov    (%eax),%eax
  102ed6:	83 f8 01             	cmp    $0x1,%eax
  102ed9:	75 36                	jne    102f11 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ede:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102ee1:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102ee4:	77 2b                	ja     102f11 <page_init+0x158>
  102ee6:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102ee9:	72 05                	jb     102ef0 <page_init+0x137>
  102eeb:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  102eee:	73 21                	jae    102f11 <page_init+0x158>
  102ef0:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102ef4:	77 1b                	ja     102f11 <page_init+0x158>
  102ef6:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102efa:	72 09                	jb     102f05 <page_init+0x14c>
  102efc:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  102f03:	77 0c                	ja     102f11 <page_init+0x158>
                maxpa = end;
  102f05:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102f08:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102f0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102f0e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102f11:	ff 45 dc             	incl   -0x24(%ebp)
  102f14:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102f17:	8b 00                	mov    (%eax),%eax
  102f19:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102f1c:	0f 8f d0 fe ff ff    	jg     102df2 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102f22:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f26:	72 1d                	jb     102f45 <page_init+0x18c>
  102f28:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f2c:	77 09                	ja     102f37 <page_init+0x17e>
  102f2e:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102f35:	76 0e                	jbe    102f45 <page_init+0x18c>
        maxpa = KMEMSIZE;
  102f37:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102f3e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE; //物理页个数0x7fe0
  102f45:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f48:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f4b:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102f4f:	c1 ea 0c             	shr    $0xc,%edx
  102f52:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);    //空闲内存开始的虚拟地址0xc011b000
  102f57:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  102f5e:	b8 88 af 11 00       	mov    $0x11af88,%eax
  102f63:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f66:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f69:	01 d0                	add    %edx,%eax
  102f6b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102f6e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102f71:	ba 00 00 00 00       	mov    $0x0,%edx
  102f76:	f7 75 ac             	divl   -0x54(%ebp)
  102f79:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102f7c:	29 d0                	sub    %edx,%eax
  102f7e:	a3 78 af 11 00       	mov    %eax,0x11af78

    for (i = 0; i < npage; i ++) {
  102f83:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102f8a:	eb 2e                	jmp    102fba <page_init+0x201>
        SetPageReserved(pages + i);     //讲全部物理页设为保留页，之后再初始化空闲页标记
  102f8c:	8b 0d 78 af 11 00    	mov    0x11af78,%ecx
  102f92:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f95:	89 d0                	mov    %edx,%eax
  102f97:	c1 e0 02             	shl    $0x2,%eax
  102f9a:	01 d0                	add    %edx,%eax
  102f9c:	c1 e0 02             	shl    $0x2,%eax
  102f9f:	01 c8                	add    %ecx,%eax
  102fa1:	83 c0 04             	add    $0x4,%eax
  102fa4:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  102fab:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102fae:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102fb1:	8b 55 90             	mov    -0x70(%ebp),%edx
  102fb4:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE; //物理页个数0x7fe0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);    //空闲内存开始的虚拟地址0xc011b000

    for (i = 0; i < npage; i ++) {
  102fb7:	ff 45 dc             	incl   -0x24(%ebp)
  102fba:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102fbd:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102fc2:	39 c2                	cmp    %eax,%edx
  102fc4:	72 c6                	jb     102f8c <page_init+0x1d3>
    }

    //hex(0xc011b000+0x7fe0*20-0xC0000000) = 0x1bad80
    //sizeof(struct Page) = 20
    //PADDR将虚拟地址根据映射机制，转换为物理地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102fc6:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102fcc:	89 d0                	mov    %edx,%eax
  102fce:	c1 e0 02             	shl    $0x2,%eax
  102fd1:	01 d0                	add    %edx,%eax
  102fd3:	c1 e0 02             	shl    $0x2,%eax
  102fd6:	89 c2                	mov    %eax,%edx
  102fd8:	a1 78 af 11 00       	mov    0x11af78,%eax
  102fdd:	01 d0                	add    %edx,%eax
  102fdf:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102fe2:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  102fe9:	77 23                	ja     10300e <page_init+0x255>
  102feb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102fee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ff2:	c7 44 24 08 e4 68 10 	movl   $0x1068e4,0x8(%esp)
  102ff9:	00 
  102ffa:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  103001:	00 
  103002:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103009:	e8 db d3 ff ff       	call   1003e9 <__panic>
  10300e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  103011:	05 00 00 00 40       	add    $0x40000000,%eax
  103016:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  103019:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103020:	e9 61 01 00 00       	jmp    103186 <page_init+0x3cd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103025:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103028:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10302b:	89 d0                	mov    %edx,%eax
  10302d:	c1 e0 02             	shl    $0x2,%eax
  103030:	01 d0                	add    %edx,%eax
  103032:	c1 e0 02             	shl    $0x2,%eax
  103035:	01 c8                	add    %ecx,%eax
  103037:	8b 50 08             	mov    0x8(%eax),%edx
  10303a:	8b 40 04             	mov    0x4(%eax),%eax
  10303d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103040:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103043:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103046:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103049:	89 d0                	mov    %edx,%eax
  10304b:	c1 e0 02             	shl    $0x2,%eax
  10304e:	01 d0                	add    %edx,%eax
  103050:	c1 e0 02             	shl    $0x2,%eax
  103053:	01 c8                	add    %ecx,%eax
  103055:	8b 48 0c             	mov    0xc(%eax),%ecx
  103058:	8b 58 10             	mov    0x10(%eax),%ebx
  10305b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10305e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103061:	01 c8                	add    %ecx,%eax
  103063:	11 da                	adc    %ebx,%edx
  103065:	89 45 c8             	mov    %eax,-0x38(%ebp)
  103068:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  10306b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10306e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103071:	89 d0                	mov    %edx,%eax
  103073:	c1 e0 02             	shl    $0x2,%eax
  103076:	01 d0                	add    %edx,%eax
  103078:	c1 e0 02             	shl    $0x2,%eax
  10307b:	01 c8                	add    %ecx,%eax
  10307d:	83 c0 14             	add    $0x14,%eax
  103080:	8b 00                	mov    (%eax),%eax
  103082:	83 f8 01             	cmp    $0x1,%eax
  103085:	0f 85 f8 00 00 00    	jne    103183 <page_init+0x3ca>
            if (begin < freemem) {
  10308b:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10308e:	ba 00 00 00 00       	mov    $0x0,%edx
  103093:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  103096:	72 17                	jb     1030af <page_init+0x2f6>
  103098:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10309b:	77 05                	ja     1030a2 <page_init+0x2e9>
  10309d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1030a0:	76 0d                	jbe    1030af <page_init+0x2f6>
                begin = freemem;
  1030a2:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1030a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1030a8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1030af:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030b3:	72 1d                	jb     1030d2 <page_init+0x319>
  1030b5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030b9:	77 09                	ja     1030c4 <page_init+0x30b>
  1030bb:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1030c2:	76 0e                	jbe    1030d2 <page_init+0x319>
                end = KMEMSIZE;
  1030c4:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1030cb:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1030d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1030d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1030d8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1030db:	0f 87 a2 00 00 00    	ja     103183 <page_init+0x3ca>
  1030e1:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1030e4:	72 09                	jb     1030ef <page_init+0x336>
  1030e6:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1030e9:	0f 83 94 00 00 00    	jae    103183 <page_init+0x3ca>
                begin = ROUNDUP(begin, PGSIZE);
  1030ef:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  1030f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1030f9:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1030fc:	01 d0                	add    %edx,%eax
  1030fe:	48                   	dec    %eax
  1030ff:	89 45 98             	mov    %eax,-0x68(%ebp)
  103102:	8b 45 98             	mov    -0x68(%ebp),%eax
  103105:	ba 00 00 00 00       	mov    $0x0,%edx
  10310a:	f7 75 9c             	divl   -0x64(%ebp)
  10310d:	8b 45 98             	mov    -0x68(%ebp),%eax
  103110:	29 d0                	sub    %edx,%eax
  103112:	ba 00 00 00 00       	mov    $0x0,%edx
  103117:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10311a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  10311d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103120:	89 45 94             	mov    %eax,-0x6c(%ebp)
  103123:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103126:	ba 00 00 00 00       	mov    $0x0,%edx
  10312b:	89 c3                	mov    %eax,%ebx
  10312d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  103133:	89 de                	mov    %ebx,%esi
  103135:	89 d0                	mov    %edx,%eax
  103137:	83 e0 00             	and    $0x0,%eax
  10313a:	89 c7                	mov    %eax,%edi
  10313c:	89 75 c8             	mov    %esi,-0x38(%ebp)
  10313f:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  103142:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103145:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103148:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10314b:	77 36                	ja     103183 <page_init+0x3ca>
  10314d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103150:	72 05                	jb     103157 <page_init+0x39e>
  103152:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103155:	73 2c                	jae    103183 <page_init+0x3ca>
                    //pa2page，根据当前物理地址，得到对应维护页的虚拟地址，即page结构体的虚拟地址
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  103157:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10315a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10315d:	2b 45 d0             	sub    -0x30(%ebp),%eax
  103160:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  103163:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103167:	c1 ea 0c             	shr    $0xc,%edx
  10316a:	89 c3                	mov    %eax,%ebx
  10316c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10316f:	89 04 24             	mov    %eax,(%esp)
  103172:	e8 ae f8 ff ff       	call   102a25 <pa2page>
  103177:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10317b:	89 04 24             	mov    %eax,(%esp)
  10317e:	e8 80 fb ff ff       	call   102d03 <init_memmap>
    //hex(0xc011b000+0x7fe0*20-0xC0000000) = 0x1bad80
    //sizeof(struct Page) = 20
    //PADDR将虚拟地址根据映射机制，转换为物理地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  103183:	ff 45 dc             	incl   -0x24(%ebp)
  103186:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103189:	8b 00                	mov    (%eax),%eax
  10318b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10318e:	0f 8f 91 fe ff ff    	jg     103025 <page_init+0x26c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  103194:	90                   	nop
  103195:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  10319b:	5b                   	pop    %ebx
  10319c:	5e                   	pop    %esi
  10319d:	5f                   	pop    %edi
  10319e:	5d                   	pop    %ebp
  10319f:	c3                   	ret    

001031a0 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1031a0:	55                   	push   %ebp
  1031a1:	89 e5                	mov    %esp,%ebp
  1031a3:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1031a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031a9:	33 45 14             	xor    0x14(%ebp),%eax
  1031ac:	25 ff 0f 00 00       	and    $0xfff,%eax
  1031b1:	85 c0                	test   %eax,%eax
  1031b3:	74 24                	je     1031d9 <boot_map_segment+0x39>
  1031b5:	c7 44 24 0c 16 69 10 	movl   $0x106916,0xc(%esp)
  1031bc:	00 
  1031bd:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  1031c4:	00 
  1031c5:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  1031cc:	00 
  1031cd:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1031d4:	e8 10 d2 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1031d9:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1031e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031e3:	25 ff 0f 00 00       	and    $0xfff,%eax
  1031e8:	89 c2                	mov    %eax,%edx
  1031ea:	8b 45 10             	mov    0x10(%ebp),%eax
  1031ed:	01 c2                	add    %eax,%edx
  1031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031f2:	01 d0                	add    %edx,%eax
  1031f4:	48                   	dec    %eax
  1031f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1031f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031fb:	ba 00 00 00 00       	mov    $0x0,%edx
  103200:	f7 75 f0             	divl   -0x10(%ebp)
  103203:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103206:	29 d0                	sub    %edx,%eax
  103208:	c1 e8 0c             	shr    $0xc,%eax
  10320b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10320e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103211:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103214:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103217:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10321c:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  10321f:	8b 45 14             	mov    0x14(%ebp),%eax
  103222:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103225:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103228:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10322d:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103230:	eb 68                	jmp    10329a <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103232:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103239:	00 
  10323a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10323d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103241:	8b 45 08             	mov    0x8(%ebp),%eax
  103244:	89 04 24             	mov    %eax,(%esp)
  103247:	e8 81 01 00 00       	call   1033cd <get_pte>
  10324c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  10324f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103253:	75 24                	jne    103279 <boot_map_segment+0xd9>
  103255:	c7 44 24 0c 42 69 10 	movl   $0x106942,0xc(%esp)
  10325c:	00 
  10325d:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103264:	00 
  103265:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  10326c:	00 
  10326d:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103274:	e8 70 d1 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  103279:	8b 45 14             	mov    0x14(%ebp),%eax
  10327c:	0b 45 18             	or     0x18(%ebp),%eax
  10327f:	83 c8 01             	or     $0x1,%eax
  103282:	89 c2                	mov    %eax,%edx
  103284:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103287:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103289:	ff 4d f4             	decl   -0xc(%ebp)
  10328c:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  103293:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  10329a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10329e:	75 92                	jne    103232 <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  1032a0:	90                   	nop
  1032a1:	c9                   	leave  
  1032a2:	c3                   	ret    

001032a3 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1032a3:	55                   	push   %ebp
  1032a4:	89 e5                	mov    %esp,%ebp
  1032a6:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1032a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032b0:	e8 6e fa ff ff       	call   102d23 <alloc_pages>
  1032b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1032b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032bc:	75 1c                	jne    1032da <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1032be:	c7 44 24 08 4f 69 10 	movl   $0x10694f,0x8(%esp)
  1032c5:	00 
  1032c6:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  1032cd:	00 
  1032ce:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1032d5:	e8 0f d1 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  1032da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032dd:	89 04 24             	mov    %eax,(%esp)
  1032e0:	e8 8f f7 ff ff       	call   102a74 <page2kva>
}
  1032e5:	c9                   	leave  
  1032e6:	c3                   	ret    

001032e7 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1032e7:	55                   	push   %ebp
  1032e8:	89 e5                	mov    %esp,%ebp
  1032ea:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1032ed:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1032f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1032f5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1032fc:	77 23                	ja     103321 <pmm_init+0x3a>
  1032fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103305:	c7 44 24 08 e4 68 10 	movl   $0x1068e4,0x8(%esp)
  10330c:	00 
  10330d:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  103314:	00 
  103315:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  10331c:	e8 c8 d0 ff ff       	call   1003e9 <__panic>
  103321:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103324:	05 00 00 00 40       	add    $0x40000000,%eax
  103329:	a3 74 af 11 00       	mov    %eax,0x11af74
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager(); //初始化物理内存管理器
  10332e:	e8 9c f9 ff ff       	call   102ccf <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();    //根据空间内存初始化每个空闲物理页对应的page结构体
  103333:	e8 81 fa ff ff       	call   102db9 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  103338:	e8 de 03 00 00       	call   10371b <check_alloc_page>

    check_pgdir();
  10333d:	e8 f8 03 00 00       	call   10373a <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  103342:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103347:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  10334d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103352:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103355:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10335c:	77 23                	ja     103381 <pmm_init+0x9a>
  10335e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103361:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103365:	c7 44 24 08 e4 68 10 	movl   $0x1068e4,0x8(%esp)
  10336c:	00 
  10336d:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  103374:	00 
  103375:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  10337c:	e8 68 d0 ff ff       	call   1003e9 <__panic>
  103381:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103384:	05 00 00 00 40       	add    $0x40000000,%eax
  103389:	83 c8 03             	or     $0x3,%eax
  10338c:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10338e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103393:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  10339a:	00 
  10339b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1033a2:	00 
  1033a3:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1033aa:	38 
  1033ab:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1033b2:	c0 
  1033b3:	89 04 24             	mov    %eax,(%esp)
  1033b6:	e8 e5 fd ff ff       	call   1031a0 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1033bb:	e8 26 f8 ff ff       	call   102be6 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1033c0:	e8 11 0a 00 00       	call   103dd6 <check_boot_pgdir>

    print_pgdir();
  1033c5:	e8 8a 0e 00 00       	call   104254 <print_pgdir>

}
  1033ca:	90                   	nop
  1033cb:	c9                   	leave  
  1033cc:	c3                   	ret    

001033cd <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1033cd:	55                   	push   %ebp
  1033ce:	89 e5                	mov    %esp,%ebp
  1033d0:	83 ec 38             	sub    $0x38,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
//----------------------------------------------------
    pde_t *pdep = &pgdir[PDX(la)];
  1033d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033d6:	c1 e8 16             	shr    $0x16,%eax
  1033d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1033e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1033e3:	01 d0                	add    %edx,%eax
  1033e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) { //页表项不存在
  1033e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033eb:	8b 00                	mov    (%eax),%eax
  1033ed:	83 e0 01             	and    $0x1,%eax
  1033f0:	85 c0                	test   %eax,%eax
  1033f2:	0f 85 af 00 00 00    	jne    1034a7 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  1033f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1033fc:	74 15                	je     103413 <get_pte+0x46>
  1033fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103405:	e8 19 f9 ff ff       	call   102d23 <alloc_pages>
  10340a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10340d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103411:	75 0a                	jne    10341d <get_pte+0x50>
            return NULL;
  103413:	b8 00 00 00 00       	mov    $0x0,%eax
  103418:	e9 e7 00 00 00       	jmp    103504 <get_pte+0x137>
        }
        set_page_ref(page, 1);
  10341d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103424:	00 
  103425:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103428:	89 04 24             	mov    %eax,(%esp)
  10342b:	e8 f8 f6 ff ff       	call   102b28 <set_page_ref>
        uintptr_t pa = page2pa(page);
  103430:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103433:	89 04 24             	mov    %eax,(%esp)
  103436:	e8 d4 f5 ff ff       	call   102a0f <page2pa>
  10343b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  10343e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103441:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103444:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103447:	c1 e8 0c             	shr    $0xc,%eax
  10344a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10344d:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103452:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103455:	72 23                	jb     10347a <get_pte+0xad>
  103457:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10345a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10345e:	c7 44 24 08 40 68 10 	movl   $0x106840,0x8(%esp)
  103465:	00 
  103466:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
  10346d:	00 
  10346e:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103475:	e8 6f cf ff ff       	call   1003e9 <__panic>
  10347a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10347d:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103482:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103489:	00 
  10348a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103491:	00 
  103492:	89 04 24             	mov    %eax,(%esp)
  103495:	e8 58 24 00 00       	call   1058f2 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;     //更新页表内容
  10349a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10349d:	83 c8 07             	or     $0x7,%eax
  1034a0:	89 c2                	mov    %eax,%edx
  1034a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034a5:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  1034a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034aa:	8b 00                	mov    (%eax),%eax
  1034ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1034b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1034b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034b7:	c1 e8 0c             	shr    $0xc,%eax
  1034ba:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1034bd:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1034c2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1034c5:	72 23                	jb     1034ea <get_pte+0x11d>
  1034c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1034ce:	c7 44 24 08 40 68 10 	movl   $0x106840,0x8(%esp)
  1034d5:	00 
  1034d6:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
  1034dd:	00 
  1034de:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1034e5:	e8 ff ce ff ff       	call   1003e9 <__panic>
  1034ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034ed:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1034f2:	89 c2                	mov    %eax,%edx
  1034f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034f7:	c1 e8 0c             	shr    $0xc,%eax
  1034fa:	25 ff 03 00 00       	and    $0x3ff,%eax
  1034ff:	c1 e0 02             	shl    $0x2,%eax
  103502:	01 d0                	add    %edx,%eax
//----------------------------------------------------
}
  103504:	c9                   	leave  
  103505:	c3                   	ret    

00103506 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103506:	55                   	push   %ebp
  103507:	89 e5                	mov    %esp,%ebp
  103509:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);    //返回页表项
  10350c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103513:	00 
  103514:	8b 45 0c             	mov    0xc(%ebp),%eax
  103517:	89 44 24 04          	mov    %eax,0x4(%esp)
  10351b:	8b 45 08             	mov    0x8(%ebp),%eax
  10351e:	89 04 24             	mov    %eax,(%esp)
  103521:	e8 a7 fe ff ff       	call   1033cd <get_pte>
  103526:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103529:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10352d:	74 08                	je     103537 <get_page+0x31>
        *ptep_store = ptep;
  10352f:	8b 45 10             	mov    0x10(%ebp),%eax
  103532:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103535:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103537:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10353b:	74 1b                	je     103558 <get_page+0x52>
  10353d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103540:	8b 00                	mov    (%eax),%eax
  103542:	83 e0 01             	and    $0x1,%eax
  103545:	85 c0                	test   %eax,%eax
  103547:	74 0f                	je     103558 <get_page+0x52>
        return pte2page(*ptep);
  103549:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10354c:	8b 00                	mov    (%eax),%eax
  10354e:	89 04 24             	mov    %eax,(%esp)
  103551:	e8 72 f5 ff ff       	call   102ac8 <pte2page>
  103556:	eb 05                	jmp    10355d <get_page+0x57>
    }
    return NULL;
  103558:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10355d:	c9                   	leave  
  10355e:	c3                   	ret    

0010355f <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10355f:	55                   	push   %ebp
  103560:	89 e5                	mov    %esp,%ebp
  103562:	83 ec 28             	sub    $0x28,%esp
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
//-------------------------------------
    if (*ptep & PTE_P) {
  103565:	8b 45 10             	mov    0x10(%ebp),%eax
  103568:	8b 00                	mov    (%eax),%eax
  10356a:	83 e0 01             	and    $0x1,%eax
  10356d:	85 c0                	test   %eax,%eax
  10356f:	74 4d                	je     1035be <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  103571:	8b 45 10             	mov    0x10(%ebp),%eax
  103574:	8b 00                	mov    (%eax),%eax
  103576:	89 04 24             	mov    %eax,(%esp)
  103579:	e8 4a f5 ff ff       	call   102ac8 <pte2page>
  10357e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  103581:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103584:	89 04 24             	mov    %eax,(%esp)
  103587:	e8 c1 f5 ff ff       	call   102b4d <page_ref_dec>
  10358c:	85 c0                	test   %eax,%eax
  10358e:	75 13                	jne    1035a3 <page_remove_pte+0x44>
            free_page(page);
  103590:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103597:	00 
  103598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10359b:	89 04 24             	mov    %eax,(%esp)
  10359e:	e8 b8 f7 ff ff       	call   102d5b <free_pages>
        }
        *ptep = 0;  //清空页表项
  1035a3:	8b 45 10             	mov    0x10(%ebp),%eax
  1035a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  1035ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035af:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1035b6:	89 04 24             	mov    %eax,(%esp)
  1035b9:	e8 01 01 00 00       	call   1036bf <tlb_invalidate>
    }
//-------------------------------------
}
  1035be:	90                   	nop
  1035bf:	c9                   	leave  
  1035c0:	c3                   	ret    

001035c1 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1035c1:	55                   	push   %ebp
  1035c2:	89 e5                	mov    %esp,%ebp
  1035c4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1035c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1035ce:	00 
  1035cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1035d9:	89 04 24             	mov    %eax,(%esp)
  1035dc:	e8 ec fd ff ff       	call   1033cd <get_pte>
  1035e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1035e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1035e8:	74 19                	je     103603 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1035ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  1035f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1035fb:	89 04 24             	mov    %eax,(%esp)
  1035fe:	e8 5c ff ff ff       	call   10355f <page_remove_pte>
    }
}
  103603:	90                   	nop
  103604:	c9                   	leave  
  103605:	c3                   	ret    

00103606 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103606:	55                   	push   %ebp
  103607:	89 e5                	mov    %esp,%ebp
  103609:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10360c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103613:	00 
  103614:	8b 45 10             	mov    0x10(%ebp),%eax
  103617:	89 44 24 04          	mov    %eax,0x4(%esp)
  10361b:	8b 45 08             	mov    0x8(%ebp),%eax
  10361e:	89 04 24             	mov    %eax,(%esp)
  103621:	e8 a7 fd ff ff       	call   1033cd <get_pte>
  103626:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  103629:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10362d:	75 0a                	jne    103639 <page_insert+0x33>
        return -E_NO_MEM;
  10362f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103634:	e9 84 00 00 00       	jmp    1036bd <page_insert+0xb7>
    }
    page_ref_inc(page);
  103639:	8b 45 0c             	mov    0xc(%ebp),%eax
  10363c:	89 04 24             	mov    %eax,(%esp)
  10363f:	e8 f2 f4 ff ff       	call   102b36 <page_ref_inc>
    if (*ptep & PTE_P) {
  103644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103647:	8b 00                	mov    (%eax),%eax
  103649:	83 e0 01             	and    $0x1,%eax
  10364c:	85 c0                	test   %eax,%eax
  10364e:	74 3e                	je     10368e <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  103650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103653:	8b 00                	mov    (%eax),%eax
  103655:	89 04 24             	mov    %eax,(%esp)
  103658:	e8 6b f4 ff ff       	call   102ac8 <pte2page>
  10365d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  103660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103663:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103666:	75 0d                	jne    103675 <page_insert+0x6f>
            page_ref_dec(page);
  103668:	8b 45 0c             	mov    0xc(%ebp),%eax
  10366b:	89 04 24             	mov    %eax,(%esp)
  10366e:	e8 da f4 ff ff       	call   102b4d <page_ref_dec>
  103673:	eb 19                	jmp    10368e <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  103675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103678:	89 44 24 08          	mov    %eax,0x8(%esp)
  10367c:	8b 45 10             	mov    0x10(%ebp),%eax
  10367f:	89 44 24 04          	mov    %eax,0x4(%esp)
  103683:	8b 45 08             	mov    0x8(%ebp),%eax
  103686:	89 04 24             	mov    %eax,(%esp)
  103689:	e8 d1 fe ff ff       	call   10355f <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  10368e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103691:	89 04 24             	mov    %eax,(%esp)
  103694:	e8 76 f3 ff ff       	call   102a0f <page2pa>
  103699:	0b 45 14             	or     0x14(%ebp),%eax
  10369c:	83 c8 01             	or     $0x1,%eax
  10369f:	89 c2                	mov    %eax,%edx
  1036a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036a4:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1036a6:	8b 45 10             	mov    0x10(%ebp),%eax
  1036a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1036b0:	89 04 24             	mov    %eax,(%esp)
  1036b3:	e8 07 00 00 00       	call   1036bf <tlb_invalidate>
    return 0;
  1036b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1036bd:	c9                   	leave  
  1036be:	c3                   	ret    

001036bf <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1036bf:	55                   	push   %ebp
  1036c0:	89 e5                	mov    %esp,%ebp
  1036c2:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1036c5:	0f 20 d8             	mov    %cr3,%eax
  1036c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
  1036cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  1036ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1036d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036d4:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1036db:	77 23                	ja     103700 <tlb_invalidate+0x41>
  1036dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1036e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1036e4:	c7 44 24 08 e4 68 10 	movl   $0x1068e4,0x8(%esp)
  1036eb:	00 
  1036ec:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
  1036f3:	00 
  1036f4:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1036fb:	e8 e9 cc ff ff       	call   1003e9 <__panic>
  103700:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103703:	05 00 00 00 40       	add    $0x40000000,%eax
  103708:	39 c2                	cmp    %eax,%edx
  10370a:	75 0c                	jne    103718 <tlb_invalidate+0x59>
        invlpg((void *)la);
  10370c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10370f:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103715:	0f 01 38             	invlpg (%eax)
    }
}
  103718:	90                   	nop
  103719:	c9                   	leave  
  10371a:	c3                   	ret    

0010371b <check_alloc_page>:

static void
check_alloc_page(void) {
  10371b:	55                   	push   %ebp
  10371c:	89 e5                	mov    %esp,%ebp
  10371e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  103721:	a1 70 af 11 00       	mov    0x11af70,%eax
  103726:	8b 40 18             	mov    0x18(%eax),%eax
  103729:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  10372b:	c7 04 24 68 69 10 00 	movl   $0x106968,(%esp)
  103732:	e8 5b cb ff ff       	call   100292 <cprintf>
}
  103737:	90                   	nop
  103738:	c9                   	leave  
  103739:	c3                   	ret    

0010373a <check_pgdir>:

static void
check_pgdir(void) {
  10373a:	55                   	push   %ebp
  10373b:	89 e5                	mov    %esp,%ebp
  10373d:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  103740:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103745:	3d 00 80 03 00       	cmp    $0x38000,%eax
  10374a:	76 24                	jbe    103770 <check_pgdir+0x36>
  10374c:	c7 44 24 0c 87 69 10 	movl   $0x106987,0xc(%esp)
  103753:	00 
  103754:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  10375b:	00 
  10375c:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  103763:	00 
  103764:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  10376b:	e8 79 cc ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  103770:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103775:	85 c0                	test   %eax,%eax
  103777:	74 0e                	je     103787 <check_pgdir+0x4d>
  103779:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10377e:	25 ff 0f 00 00       	and    $0xfff,%eax
  103783:	85 c0                	test   %eax,%eax
  103785:	74 24                	je     1037ab <check_pgdir+0x71>
  103787:	c7 44 24 0c a4 69 10 	movl   $0x1069a4,0xc(%esp)
  10378e:	00 
  10378f:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103796:	00 
  103797:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  10379e:	00 
  10379f:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1037a6:	e8 3e cc ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1037ab:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037b7:	00 
  1037b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1037bf:	00 
  1037c0:	89 04 24             	mov    %eax,(%esp)
  1037c3:	e8 3e fd ff ff       	call   103506 <get_page>
  1037c8:	85 c0                	test   %eax,%eax
  1037ca:	74 24                	je     1037f0 <check_pgdir+0xb6>
  1037cc:	c7 44 24 0c dc 69 10 	movl   $0x1069dc,0xc(%esp)
  1037d3:	00 
  1037d4:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  1037db:	00 
  1037dc:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  1037e3:	00 
  1037e4:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1037eb:	e8 f9 cb ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1037f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037f7:	e8 27 f5 ff ff       	call   102d23 <alloc_pages>
  1037fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1037ff:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103804:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10380b:	00 
  10380c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103813:	00 
  103814:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103817:	89 54 24 04          	mov    %edx,0x4(%esp)
  10381b:	89 04 24             	mov    %eax,(%esp)
  10381e:	e8 e3 fd ff ff       	call   103606 <page_insert>
  103823:	85 c0                	test   %eax,%eax
  103825:	74 24                	je     10384b <check_pgdir+0x111>
  103827:	c7 44 24 0c 04 6a 10 	movl   $0x106a04,0xc(%esp)
  10382e:	00 
  10382f:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103836:	00 
  103837:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  10383e:	00 
  10383f:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103846:	e8 9e cb ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  10384b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103850:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103857:	00 
  103858:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10385f:	00 
  103860:	89 04 24             	mov    %eax,(%esp)
  103863:	e8 65 fb ff ff       	call   1033cd <get_pte>
  103868:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10386b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10386f:	75 24                	jne    103895 <check_pgdir+0x15b>
  103871:	c7 44 24 0c 30 6a 10 	movl   $0x106a30,0xc(%esp)
  103878:	00 
  103879:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103880:	00 
  103881:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103888:	00 
  103889:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103890:	e8 54 cb ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103898:	8b 00                	mov    (%eax),%eax
  10389a:	89 04 24             	mov    %eax,(%esp)
  10389d:	e8 26 f2 ff ff       	call   102ac8 <pte2page>
  1038a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1038a5:	74 24                	je     1038cb <check_pgdir+0x191>
  1038a7:	c7 44 24 0c 5d 6a 10 	movl   $0x106a5d,0xc(%esp)
  1038ae:	00 
  1038af:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  1038b6:	00 
  1038b7:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  1038be:	00 
  1038bf:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1038c6:	e8 1e cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  1038cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038ce:	89 04 24             	mov    %eax,(%esp)
  1038d1:	e8 48 f2 ff ff       	call   102b1e <page_ref>
  1038d6:	83 f8 01             	cmp    $0x1,%eax
  1038d9:	74 24                	je     1038ff <check_pgdir+0x1c5>
  1038db:	c7 44 24 0c 73 6a 10 	movl   $0x106a73,0xc(%esp)
  1038e2:	00 
  1038e3:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  1038ea:	00 
  1038eb:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  1038f2:	00 
  1038f3:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1038fa:	e8 ea ca ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1038ff:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103904:	8b 00                	mov    (%eax),%eax
  103906:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10390b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10390e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103911:	c1 e8 0c             	shr    $0xc,%eax
  103914:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103917:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10391c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10391f:	72 23                	jb     103944 <check_pgdir+0x20a>
  103921:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103924:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103928:	c7 44 24 08 40 68 10 	movl   $0x106840,0x8(%esp)
  10392f:	00 
  103930:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103937:	00 
  103938:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  10393f:	e8 a5 ca ff ff       	call   1003e9 <__panic>
  103944:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103947:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10394c:	83 c0 04             	add    $0x4,%eax
  10394f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  103952:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103957:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10395e:	00 
  10395f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103966:	00 
  103967:	89 04 24             	mov    %eax,(%esp)
  10396a:	e8 5e fa ff ff       	call   1033cd <get_pte>
  10396f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103972:	74 24                	je     103998 <check_pgdir+0x25e>
  103974:	c7 44 24 0c 88 6a 10 	movl   $0x106a88,0xc(%esp)
  10397b:	00 
  10397c:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103983:	00 
  103984:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  10398b:	00 
  10398c:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103993:	e8 51 ca ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  103998:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10399f:	e8 7f f3 ff ff       	call   102d23 <alloc_pages>
  1039a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  1039a7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1039ac:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  1039b3:	00 
  1039b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1039bb:	00 
  1039bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1039bf:	89 54 24 04          	mov    %edx,0x4(%esp)
  1039c3:	89 04 24             	mov    %eax,(%esp)
  1039c6:	e8 3b fc ff ff       	call   103606 <page_insert>
  1039cb:	85 c0                	test   %eax,%eax
  1039cd:	74 24                	je     1039f3 <check_pgdir+0x2b9>
  1039cf:	c7 44 24 0c b0 6a 10 	movl   $0x106ab0,0xc(%esp)
  1039d6:	00 
  1039d7:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  1039de:	00 
  1039df:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  1039e6:	00 
  1039e7:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1039ee:	e8 f6 c9 ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1039f3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1039f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1039ff:	00 
  103a00:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a07:	00 
  103a08:	89 04 24             	mov    %eax,(%esp)
  103a0b:	e8 bd f9 ff ff       	call   1033cd <get_pte>
  103a10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a17:	75 24                	jne    103a3d <check_pgdir+0x303>
  103a19:	c7 44 24 0c e8 6a 10 	movl   $0x106ae8,0xc(%esp)
  103a20:	00 
  103a21:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103a28:	00 
  103a29:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  103a30:	00 
  103a31:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103a38:	e8 ac c9 ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  103a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a40:	8b 00                	mov    (%eax),%eax
  103a42:	83 e0 04             	and    $0x4,%eax
  103a45:	85 c0                	test   %eax,%eax
  103a47:	75 24                	jne    103a6d <check_pgdir+0x333>
  103a49:	c7 44 24 0c 18 6b 10 	movl   $0x106b18,0xc(%esp)
  103a50:	00 
  103a51:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103a58:	00 
  103a59:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  103a60:	00 
  103a61:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103a68:	e8 7c c9 ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  103a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a70:	8b 00                	mov    (%eax),%eax
  103a72:	83 e0 02             	and    $0x2,%eax
  103a75:	85 c0                	test   %eax,%eax
  103a77:	75 24                	jne    103a9d <check_pgdir+0x363>
  103a79:	c7 44 24 0c 26 6b 10 	movl   $0x106b26,0xc(%esp)
  103a80:	00 
  103a81:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103a88:	00 
  103a89:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  103a90:	00 
  103a91:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103a98:	e8 4c c9 ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103a9d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103aa2:	8b 00                	mov    (%eax),%eax
  103aa4:	83 e0 04             	and    $0x4,%eax
  103aa7:	85 c0                	test   %eax,%eax
  103aa9:	75 24                	jne    103acf <check_pgdir+0x395>
  103aab:	c7 44 24 0c 34 6b 10 	movl   $0x106b34,0xc(%esp)
  103ab2:	00 
  103ab3:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103aba:	00 
  103abb:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  103ac2:	00 
  103ac3:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103aca:	e8 1a c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  103acf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ad2:	89 04 24             	mov    %eax,(%esp)
  103ad5:	e8 44 f0 ff ff       	call   102b1e <page_ref>
  103ada:	83 f8 01             	cmp    $0x1,%eax
  103add:	74 24                	je     103b03 <check_pgdir+0x3c9>
  103adf:	c7 44 24 0c 4a 6b 10 	movl   $0x106b4a,0xc(%esp)
  103ae6:	00 
  103ae7:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103aee:	00 
  103aef:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  103af6:	00 
  103af7:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103afe:	e8 e6 c8 ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103b03:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103b0f:	00 
  103b10:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103b17:	00 
  103b18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103b1b:	89 54 24 04          	mov    %edx,0x4(%esp)
  103b1f:	89 04 24             	mov    %eax,(%esp)
  103b22:	e8 df fa ff ff       	call   103606 <page_insert>
  103b27:	85 c0                	test   %eax,%eax
  103b29:	74 24                	je     103b4f <check_pgdir+0x415>
  103b2b:	c7 44 24 0c 5c 6b 10 	movl   $0x106b5c,0xc(%esp)
  103b32:	00 
  103b33:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103b3a:	00 
  103b3b:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103b42:	00 
  103b43:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103b4a:	e8 9a c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  103b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b52:	89 04 24             	mov    %eax,(%esp)
  103b55:	e8 c4 ef ff ff       	call   102b1e <page_ref>
  103b5a:	83 f8 02             	cmp    $0x2,%eax
  103b5d:	74 24                	je     103b83 <check_pgdir+0x449>
  103b5f:	c7 44 24 0c 88 6b 10 	movl   $0x106b88,0xc(%esp)
  103b66:	00 
  103b67:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103b6e:	00 
  103b6f:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  103b76:	00 
  103b77:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103b7e:	e8 66 c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b86:	89 04 24             	mov    %eax,(%esp)
  103b89:	e8 90 ef ff ff       	call   102b1e <page_ref>
  103b8e:	85 c0                	test   %eax,%eax
  103b90:	74 24                	je     103bb6 <check_pgdir+0x47c>
  103b92:	c7 44 24 0c 9a 6b 10 	movl   $0x106b9a,0xc(%esp)
  103b99:	00 
  103b9a:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103ba1:	00 
  103ba2:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  103ba9:	00 
  103baa:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103bb1:	e8 33 c8 ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103bb6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103bbb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103bc2:	00 
  103bc3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103bca:	00 
  103bcb:	89 04 24             	mov    %eax,(%esp)
  103bce:	e8 fa f7 ff ff       	call   1033cd <get_pte>
  103bd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103bd6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103bda:	75 24                	jne    103c00 <check_pgdir+0x4c6>
  103bdc:	c7 44 24 0c e8 6a 10 	movl   $0x106ae8,0xc(%esp)
  103be3:	00 
  103be4:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103beb:	00 
  103bec:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103bf3:	00 
  103bf4:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103bfb:	e8 e9 c7 ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c03:	8b 00                	mov    (%eax),%eax
  103c05:	89 04 24             	mov    %eax,(%esp)
  103c08:	e8 bb ee ff ff       	call   102ac8 <pte2page>
  103c0d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103c10:	74 24                	je     103c36 <check_pgdir+0x4fc>
  103c12:	c7 44 24 0c 5d 6a 10 	movl   $0x106a5d,0xc(%esp)
  103c19:	00 
  103c1a:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103c21:	00 
  103c22:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  103c29:	00 
  103c2a:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103c31:	e8 b3 c7 ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c39:	8b 00                	mov    (%eax),%eax
  103c3b:	83 e0 04             	and    $0x4,%eax
  103c3e:	85 c0                	test   %eax,%eax
  103c40:	74 24                	je     103c66 <check_pgdir+0x52c>
  103c42:	c7 44 24 0c ac 6b 10 	movl   $0x106bac,0xc(%esp)
  103c49:	00 
  103c4a:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103c51:	00 
  103c52:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103c59:	00 
  103c5a:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103c61:	e8 83 c7 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103c66:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103c72:	00 
  103c73:	89 04 24             	mov    %eax,(%esp)
  103c76:	e8 46 f9 ff ff       	call   1035c1 <page_remove>
    assert(page_ref(p1) == 1);
  103c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c7e:	89 04 24             	mov    %eax,(%esp)
  103c81:	e8 98 ee ff ff       	call   102b1e <page_ref>
  103c86:	83 f8 01             	cmp    $0x1,%eax
  103c89:	74 24                	je     103caf <check_pgdir+0x575>
  103c8b:	c7 44 24 0c 73 6a 10 	movl   $0x106a73,0xc(%esp)
  103c92:	00 
  103c93:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103c9a:	00 
  103c9b:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103ca2:	00 
  103ca3:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103caa:	e8 3a c7 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103caf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103cb2:	89 04 24             	mov    %eax,(%esp)
  103cb5:	e8 64 ee ff ff       	call   102b1e <page_ref>
  103cba:	85 c0                	test   %eax,%eax
  103cbc:	74 24                	je     103ce2 <check_pgdir+0x5a8>
  103cbe:	c7 44 24 0c 9a 6b 10 	movl   $0x106b9a,0xc(%esp)
  103cc5:	00 
  103cc6:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103ccd:	00 
  103cce:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  103cd5:	00 
  103cd6:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103cdd:	e8 07 c7 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103ce2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ce7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103cee:	00 
  103cef:	89 04 24             	mov    %eax,(%esp)
  103cf2:	e8 ca f8 ff ff       	call   1035c1 <page_remove>
    assert(page_ref(p1) == 0);
  103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cfa:	89 04 24             	mov    %eax,(%esp)
  103cfd:	e8 1c ee ff ff       	call   102b1e <page_ref>
  103d02:	85 c0                	test   %eax,%eax
  103d04:	74 24                	je     103d2a <check_pgdir+0x5f0>
  103d06:	c7 44 24 0c c1 6b 10 	movl   $0x106bc1,0xc(%esp)
  103d0d:	00 
  103d0e:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103d15:	00 
  103d16:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103d1d:	00 
  103d1e:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103d25:	e8 bf c6 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103d2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d2d:	89 04 24             	mov    %eax,(%esp)
  103d30:	e8 e9 ed ff ff       	call   102b1e <page_ref>
  103d35:	85 c0                	test   %eax,%eax
  103d37:	74 24                	je     103d5d <check_pgdir+0x623>
  103d39:	c7 44 24 0c 9a 6b 10 	movl   $0x106b9a,0xc(%esp)
  103d40:	00 
  103d41:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103d48:	00 
  103d49:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  103d50:	00 
  103d51:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103d58:	e8 8c c6 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103d5d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d62:	8b 00                	mov    (%eax),%eax
  103d64:	89 04 24             	mov    %eax,(%esp)
  103d67:	e8 9a ed ff ff       	call   102b06 <pde2page>
  103d6c:	89 04 24             	mov    %eax,(%esp)
  103d6f:	e8 aa ed ff ff       	call   102b1e <page_ref>
  103d74:	83 f8 01             	cmp    $0x1,%eax
  103d77:	74 24                	je     103d9d <check_pgdir+0x663>
  103d79:	c7 44 24 0c d4 6b 10 	movl   $0x106bd4,0xc(%esp)
  103d80:	00 
  103d81:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103d88:	00 
  103d89:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  103d90:	00 
  103d91:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103d98:	e8 4c c6 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103d9d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103da2:	8b 00                	mov    (%eax),%eax
  103da4:	89 04 24             	mov    %eax,(%esp)
  103da7:	e8 5a ed ff ff       	call   102b06 <pde2page>
  103dac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103db3:	00 
  103db4:	89 04 24             	mov    %eax,(%esp)
  103db7:	e8 9f ef ff ff       	call   102d5b <free_pages>
    boot_pgdir[0] = 0;
  103dbc:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103dc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103dc7:	c7 04 24 fb 6b 10 00 	movl   $0x106bfb,(%esp)
  103dce:	e8 bf c4 ff ff       	call   100292 <cprintf>
}
  103dd3:	90                   	nop
  103dd4:	c9                   	leave  
  103dd5:	c3                   	ret    

00103dd6 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103dd6:	55                   	push   %ebp
  103dd7:	89 e5                	mov    %esp,%ebp
  103dd9:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103ddc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103de3:	e9 ca 00 00 00       	jmp    103eb2 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103deb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103df1:	c1 e8 0c             	shr    $0xc,%eax
  103df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103df7:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103dfc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103dff:	72 23                	jb     103e24 <check_boot_pgdir+0x4e>
  103e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103e08:	c7 44 24 08 40 68 10 	movl   $0x106840,0x8(%esp)
  103e0f:	00 
  103e10:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  103e17:	00 
  103e18:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103e1f:	e8 c5 c5 ff ff       	call   1003e9 <__panic>
  103e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e27:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103e2c:	89 c2                	mov    %eax,%edx
  103e2e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103e33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103e3a:	00 
  103e3b:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e3f:	89 04 24             	mov    %eax,(%esp)
  103e42:	e8 86 f5 ff ff       	call   1033cd <get_pte>
  103e47:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103e4a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103e4e:	75 24                	jne    103e74 <check_boot_pgdir+0x9e>
  103e50:	c7 44 24 0c 18 6c 10 	movl   $0x106c18,0xc(%esp)
  103e57:	00 
  103e58:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103e5f:	00 
  103e60:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  103e67:	00 
  103e68:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103e6f:	e8 75 c5 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103e74:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103e77:	8b 00                	mov    (%eax),%eax
  103e79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103e7e:	89 c2                	mov    %eax,%edx
  103e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e83:	39 c2                	cmp    %eax,%edx
  103e85:	74 24                	je     103eab <check_boot_pgdir+0xd5>
  103e87:	c7 44 24 0c 55 6c 10 	movl   $0x106c55,0xc(%esp)
  103e8e:	00 
  103e8f:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103e96:	00 
  103e97:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  103e9e:	00 
  103e9f:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103ea6:	e8 3e c5 ff ff       	call   1003e9 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103eab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103eb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103eb5:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103eba:	39 c2                	cmp    %eax,%edx
  103ebc:	0f 82 26 ff ff ff    	jb     103de8 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103ec2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ec7:	05 ac 0f 00 00       	add    $0xfac,%eax
  103ecc:	8b 00                	mov    (%eax),%eax
  103ece:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103ed3:	89 c2                	mov    %eax,%edx
  103ed5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103eda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103edd:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  103ee4:	77 23                	ja     103f09 <check_boot_pgdir+0x133>
  103ee6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ee9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103eed:	c7 44 24 08 e4 68 10 	movl   $0x1068e4,0x8(%esp)
  103ef4:	00 
  103ef5:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  103efc:	00 
  103efd:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103f04:	e8 e0 c4 ff ff       	call   1003e9 <__panic>
  103f09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103f0c:	05 00 00 00 40       	add    $0x40000000,%eax
  103f11:	39 c2                	cmp    %eax,%edx
  103f13:	74 24                	je     103f39 <check_boot_pgdir+0x163>
  103f15:	c7 44 24 0c 6c 6c 10 	movl   $0x106c6c,0xc(%esp)
  103f1c:	00 
  103f1d:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103f24:	00 
  103f25:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  103f2c:	00 
  103f2d:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103f34:	e8 b0 c4 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103f39:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103f3e:	8b 00                	mov    (%eax),%eax
  103f40:	85 c0                	test   %eax,%eax
  103f42:	74 24                	je     103f68 <check_boot_pgdir+0x192>
  103f44:	c7 44 24 0c a0 6c 10 	movl   $0x106ca0,0xc(%esp)
  103f4b:	00 
  103f4c:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103f53:	00 
  103f54:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  103f5b:	00 
  103f5c:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103f63:	e8 81 c4 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103f68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103f6f:	e8 af ed ff ff       	call   102d23 <alloc_pages>
  103f74:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103f77:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103f7c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103f83:	00 
  103f84:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103f8b:	00 
  103f8c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103f8f:	89 54 24 04          	mov    %edx,0x4(%esp)
  103f93:	89 04 24             	mov    %eax,(%esp)
  103f96:	e8 6b f6 ff ff       	call   103606 <page_insert>
  103f9b:	85 c0                	test   %eax,%eax
  103f9d:	74 24                	je     103fc3 <check_boot_pgdir+0x1ed>
  103f9f:	c7 44 24 0c b4 6c 10 	movl   $0x106cb4,0xc(%esp)
  103fa6:	00 
  103fa7:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103fae:	00 
  103faf:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  103fb6:	00 
  103fb7:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103fbe:	e8 26 c4 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103fc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103fc6:	89 04 24             	mov    %eax,(%esp)
  103fc9:	e8 50 eb ff ff       	call   102b1e <page_ref>
  103fce:	83 f8 01             	cmp    $0x1,%eax
  103fd1:	74 24                	je     103ff7 <check_boot_pgdir+0x221>
  103fd3:	c7 44 24 0c e2 6c 10 	movl   $0x106ce2,0xc(%esp)
  103fda:	00 
  103fdb:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  103fe2:	00 
  103fe3:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  103fea:	00 
  103feb:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  103ff2:	e8 f2 c3 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103ff7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ffc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104003:	00 
  104004:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  10400b:	00 
  10400c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10400f:	89 54 24 04          	mov    %edx,0x4(%esp)
  104013:	89 04 24             	mov    %eax,(%esp)
  104016:	e8 eb f5 ff ff       	call   103606 <page_insert>
  10401b:	85 c0                	test   %eax,%eax
  10401d:	74 24                	je     104043 <check_boot_pgdir+0x26d>
  10401f:	c7 44 24 0c f4 6c 10 	movl   $0x106cf4,0xc(%esp)
  104026:	00 
  104027:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  10402e:	00 
  10402f:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  104036:	00 
  104037:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  10403e:	e8 a6 c3 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  104043:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104046:	89 04 24             	mov    %eax,(%esp)
  104049:	e8 d0 ea ff ff       	call   102b1e <page_ref>
  10404e:	83 f8 02             	cmp    $0x2,%eax
  104051:	74 24                	je     104077 <check_boot_pgdir+0x2a1>
  104053:	c7 44 24 0c 2b 6d 10 	movl   $0x106d2b,0xc(%esp)
  10405a:	00 
  10405b:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  104062:	00 
  104063:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  10406a:	00 
  10406b:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  104072:	e8 72 c3 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  104077:	c7 45 dc 3c 6d 10 00 	movl   $0x106d3c,-0x24(%ebp)
    strcpy((void *)0x100, str);
  10407e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104081:	89 44 24 04          	mov    %eax,0x4(%esp)
  104085:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10408c:	e8 97 15 00 00       	call   105628 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  104091:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  104098:	00 
  104099:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1040a0:	e8 fa 15 00 00       	call   10569f <strcmp>
  1040a5:	85 c0                	test   %eax,%eax
  1040a7:	74 24                	je     1040cd <check_boot_pgdir+0x2f7>
  1040a9:	c7 44 24 0c 54 6d 10 	movl   $0x106d54,0xc(%esp)
  1040b0:	00 
  1040b1:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  1040b8:	00 
  1040b9:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  1040c0:	00 
  1040c1:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  1040c8:	e8 1c c3 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1040cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1040d0:	89 04 24             	mov    %eax,(%esp)
  1040d3:	e8 9c e9 ff ff       	call   102a74 <page2kva>
  1040d8:	05 00 01 00 00       	add    $0x100,%eax
  1040dd:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1040e0:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1040e7:	e8 e6 14 00 00       	call   1055d2 <strlen>
  1040ec:	85 c0                	test   %eax,%eax
  1040ee:	74 24                	je     104114 <check_boot_pgdir+0x33e>
  1040f0:	c7 44 24 0c 8c 6d 10 	movl   $0x106d8c,0xc(%esp)
  1040f7:	00 
  1040f8:	c7 44 24 08 2d 69 10 	movl   $0x10692d,0x8(%esp)
  1040ff:	00 
  104100:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
  104107:	00 
  104108:	c7 04 24 08 69 10 00 	movl   $0x106908,(%esp)
  10410f:	e8 d5 c2 ff ff       	call   1003e9 <__panic>

    free_page(p);
  104114:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10411b:	00 
  10411c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10411f:	89 04 24             	mov    %eax,(%esp)
  104122:	e8 34 ec ff ff       	call   102d5b <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  104127:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10412c:	8b 00                	mov    (%eax),%eax
  10412e:	89 04 24             	mov    %eax,(%esp)
  104131:	e8 d0 e9 ff ff       	call   102b06 <pde2page>
  104136:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10413d:	00 
  10413e:	89 04 24             	mov    %eax,(%esp)
  104141:	e8 15 ec ff ff       	call   102d5b <free_pages>
    boot_pgdir[0] = 0;
  104146:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10414b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  104151:	c7 04 24 b0 6d 10 00 	movl   $0x106db0,(%esp)
  104158:	e8 35 c1 ff ff       	call   100292 <cprintf>
}
  10415d:	90                   	nop
  10415e:	c9                   	leave  
  10415f:	c3                   	ret    

00104160 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  104160:	55                   	push   %ebp
  104161:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  104163:	8b 45 08             	mov    0x8(%ebp),%eax
  104166:	83 e0 04             	and    $0x4,%eax
  104169:	85 c0                	test   %eax,%eax
  10416b:	74 04                	je     104171 <perm2str+0x11>
  10416d:	b0 75                	mov    $0x75,%al
  10416f:	eb 02                	jmp    104173 <perm2str+0x13>
  104171:	b0 2d                	mov    $0x2d,%al
  104173:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  104178:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  10417f:	8b 45 08             	mov    0x8(%ebp),%eax
  104182:	83 e0 02             	and    $0x2,%eax
  104185:	85 c0                	test   %eax,%eax
  104187:	74 04                	je     10418d <perm2str+0x2d>
  104189:	b0 77                	mov    $0x77,%al
  10418b:	eb 02                	jmp    10418f <perm2str+0x2f>
  10418d:	b0 2d                	mov    $0x2d,%al
  10418f:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  104194:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  10419b:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  1041a0:	5d                   	pop    %ebp
  1041a1:	c3                   	ret    

001041a2 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1041a2:	55                   	push   %ebp
  1041a3:	89 e5                	mov    %esp,%ebp
  1041a5:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1041a8:	8b 45 10             	mov    0x10(%ebp),%eax
  1041ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1041ae:	72 0d                	jb     1041bd <get_pgtable_items+0x1b>
        return 0;
  1041b0:	b8 00 00 00 00       	mov    $0x0,%eax
  1041b5:	e9 98 00 00 00       	jmp    104252 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  1041ba:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  1041bd:	8b 45 10             	mov    0x10(%ebp),%eax
  1041c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1041c3:	73 18                	jae    1041dd <get_pgtable_items+0x3b>
  1041c5:	8b 45 10             	mov    0x10(%ebp),%eax
  1041c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1041cf:	8b 45 14             	mov    0x14(%ebp),%eax
  1041d2:	01 d0                	add    %edx,%eax
  1041d4:	8b 00                	mov    (%eax),%eax
  1041d6:	83 e0 01             	and    $0x1,%eax
  1041d9:	85 c0                	test   %eax,%eax
  1041db:	74 dd                	je     1041ba <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
  1041dd:	8b 45 10             	mov    0x10(%ebp),%eax
  1041e0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1041e3:	73 68                	jae    10424d <get_pgtable_items+0xab>
        if (left_store != NULL) {
  1041e5:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1041e9:	74 08                	je     1041f3 <get_pgtable_items+0x51>
            *left_store = start;
  1041eb:	8b 45 18             	mov    0x18(%ebp),%eax
  1041ee:	8b 55 10             	mov    0x10(%ebp),%edx
  1041f1:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1041f3:	8b 45 10             	mov    0x10(%ebp),%eax
  1041f6:	8d 50 01             	lea    0x1(%eax),%edx
  1041f9:	89 55 10             	mov    %edx,0x10(%ebp)
  1041fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104203:	8b 45 14             	mov    0x14(%ebp),%eax
  104206:	01 d0                	add    %edx,%eax
  104208:	8b 00                	mov    (%eax),%eax
  10420a:	83 e0 07             	and    $0x7,%eax
  10420d:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104210:	eb 03                	jmp    104215 <get_pgtable_items+0x73>
            start ++;
  104212:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  104215:	8b 45 10             	mov    0x10(%ebp),%eax
  104218:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10421b:	73 1d                	jae    10423a <get_pgtable_items+0x98>
  10421d:	8b 45 10             	mov    0x10(%ebp),%eax
  104220:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104227:	8b 45 14             	mov    0x14(%ebp),%eax
  10422a:	01 d0                	add    %edx,%eax
  10422c:	8b 00                	mov    (%eax),%eax
  10422e:	83 e0 07             	and    $0x7,%eax
  104231:	89 c2                	mov    %eax,%edx
  104233:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104236:	39 c2                	cmp    %eax,%edx
  104238:	74 d8                	je     104212 <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
  10423a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10423e:	74 08                	je     104248 <get_pgtable_items+0xa6>
            *right_store = start;
  104240:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104243:	8b 55 10             	mov    0x10(%ebp),%edx
  104246:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  104248:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10424b:	eb 05                	jmp    104252 <get_pgtable_items+0xb0>
    }
    return 0;
  10424d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104252:	c9                   	leave  
  104253:	c3                   	ret    

00104254 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  104254:	55                   	push   %ebp
  104255:	89 e5                	mov    %esp,%ebp
  104257:	57                   	push   %edi
  104258:	56                   	push   %esi
  104259:	53                   	push   %ebx
  10425a:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  10425d:	c7 04 24 d0 6d 10 00 	movl   $0x106dd0,(%esp)
  104264:	e8 29 c0 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  104269:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104270:	e9 fa 00 00 00       	jmp    10436f <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104278:	89 04 24             	mov    %eax,(%esp)
  10427b:	e8 e0 fe ff ff       	call   104160 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104280:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  104283:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104286:	29 d1                	sub    %edx,%ecx
  104288:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10428a:	89 d6                	mov    %edx,%esi
  10428c:	c1 e6 16             	shl    $0x16,%esi
  10428f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104292:	89 d3                	mov    %edx,%ebx
  104294:	c1 e3 16             	shl    $0x16,%ebx
  104297:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10429a:	89 d1                	mov    %edx,%ecx
  10429c:	c1 e1 16             	shl    $0x16,%ecx
  10429f:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1042a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1042a5:	29 d7                	sub    %edx,%edi
  1042a7:	89 fa                	mov    %edi,%edx
  1042a9:	89 44 24 14          	mov    %eax,0x14(%esp)
  1042ad:	89 74 24 10          	mov    %esi,0x10(%esp)
  1042b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1042b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1042b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1042bd:	c7 04 24 01 6e 10 00 	movl   $0x106e01,(%esp)
  1042c4:	e8 c9 bf ff ff       	call   100292 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  1042c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1042cc:	c1 e0 0a             	shl    $0xa,%eax
  1042cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1042d2:	eb 54                	jmp    104328 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1042d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042d7:	89 04 24             	mov    %eax,(%esp)
  1042da:	e8 81 fe ff ff       	call   104160 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1042df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1042e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1042e5:	29 d1                	sub    %edx,%ecx
  1042e7:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1042e9:	89 d6                	mov    %edx,%esi
  1042eb:	c1 e6 0c             	shl    $0xc,%esi
  1042ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1042f1:	89 d3                	mov    %edx,%ebx
  1042f3:	c1 e3 0c             	shl    $0xc,%ebx
  1042f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1042f9:	89 d1                	mov    %edx,%ecx
  1042fb:	c1 e1 0c             	shl    $0xc,%ecx
  1042fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  104301:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104304:	29 d7                	sub    %edx,%edi
  104306:	89 fa                	mov    %edi,%edx
  104308:	89 44 24 14          	mov    %eax,0x14(%esp)
  10430c:	89 74 24 10          	mov    %esi,0x10(%esp)
  104310:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104314:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104318:	89 54 24 04          	mov    %edx,0x4(%esp)
  10431c:	c7 04 24 20 6e 10 00 	movl   $0x106e20,(%esp)
  104323:	e8 6a bf ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104328:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  10432d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104330:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104333:	89 d3                	mov    %edx,%ebx
  104335:	c1 e3 0a             	shl    $0xa,%ebx
  104338:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10433b:	89 d1                	mov    %edx,%ecx
  10433d:	c1 e1 0a             	shl    $0xa,%ecx
  104340:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  104343:	89 54 24 14          	mov    %edx,0x14(%esp)
  104347:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10434a:	89 54 24 10          	mov    %edx,0x10(%esp)
  10434e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  104352:	89 44 24 08          	mov    %eax,0x8(%esp)
  104356:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10435a:	89 0c 24             	mov    %ecx,(%esp)
  10435d:	e8 40 fe ff ff       	call   1041a2 <get_pgtable_items>
  104362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104365:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104369:	0f 85 65 ff ff ff    	jne    1042d4 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10436f:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  104374:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104377:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10437a:	89 54 24 14          	mov    %edx,0x14(%esp)
  10437e:	8d 55 e0             	lea    -0x20(%ebp),%edx
  104381:	89 54 24 10          	mov    %edx,0x10(%esp)
  104385:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  104389:	89 44 24 08          	mov    %eax,0x8(%esp)
  10438d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  104394:	00 
  104395:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10439c:	e8 01 fe ff ff       	call   1041a2 <get_pgtable_items>
  1043a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1043a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1043a8:	0f 85 c7 fe ff ff    	jne    104275 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1043ae:	c7 04 24 44 6e 10 00 	movl   $0x106e44,(%esp)
  1043b5:	e8 d8 be ff ff       	call   100292 <cprintf>
}
  1043ba:	90                   	nop
  1043bb:	83 c4 4c             	add    $0x4c,%esp
  1043be:	5b                   	pop    %ebx
  1043bf:	5e                   	pop    %esi
  1043c0:	5f                   	pop    %edi
  1043c1:	5d                   	pop    %ebp
  1043c2:	c3                   	ret    

001043c3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1043c3:	55                   	push   %ebp
  1043c4:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1043c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1043c9:	8b 15 78 af 11 00    	mov    0x11af78,%edx
  1043cf:	29 d0                	sub    %edx,%eax
  1043d1:	c1 f8 02             	sar    $0x2,%eax
  1043d4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1043da:	5d                   	pop    %ebp
  1043db:	c3                   	ret    

001043dc <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1043dc:	55                   	push   %ebp
  1043dd:	89 e5                	mov    %esp,%ebp
  1043df:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1043e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1043e5:	89 04 24             	mov    %eax,(%esp)
  1043e8:	e8 d6 ff ff ff       	call   1043c3 <page2ppn>
  1043ed:	c1 e0 0c             	shl    $0xc,%eax
}
  1043f0:	c9                   	leave  
  1043f1:	c3                   	ret    

001043f2 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  1043f2:	55                   	push   %ebp
  1043f3:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1043f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1043f8:	8b 00                	mov    (%eax),%eax
}
  1043fa:	5d                   	pop    %ebp
  1043fb:	c3                   	ret    

001043fc <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1043fc:	55                   	push   %ebp
  1043fd:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1043ff:	8b 45 08             	mov    0x8(%ebp),%eax
  104402:	8b 55 0c             	mov    0xc(%ebp),%edx
  104405:	89 10                	mov    %edx,(%eax)
}
  104407:	90                   	nop
  104408:	5d                   	pop    %ebp
  104409:	c3                   	ret    

0010440a <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  10440a:	55                   	push   %ebp
  10440b:	89 e5                	mov    %esp,%ebp
  10440d:	83 ec 10             	sub    $0x10,%esp
  104410:	c7 45 fc 7c af 11 00 	movl   $0x11af7c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104417:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10441a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10441d:	89 50 04             	mov    %edx,0x4(%eax)
  104420:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104423:	8b 50 04             	mov    0x4(%eax),%edx
  104426:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104429:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  10442b:	c7 05 84 af 11 00 00 	movl   $0x0,0x11af84
  104432:	00 00 00 
}
  104435:	90                   	nop
  104436:	c9                   	leave  
  104437:	c3                   	ret    

00104438 <default_init_memmap>:

//初始化维护页（虚拟地址）
static void
default_init_memmap(struct Page *base, size_t n) {
  104438:	55                   	push   %ebp
  104439:	89 e5                	mov    %esp,%ebp
  10443b:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  10443e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104442:	75 24                	jne    104468 <default_init_memmap+0x30>
  104444:	c7 44 24 0c 78 6e 10 	movl   $0x106e78,0xc(%esp)
  10444b:	00 
  10444c:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104453:	00 
  104454:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  10445b:	00 
  10445c:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104463:	e8 81 bf ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  104468:	8b 45 08             	mov    0x8(%ebp),%eax
  10446b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10446e:	eb 7d                	jmp    1044ed <default_init_memmap+0xb5>
        assert(PageReserved(p));
  104470:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104473:	83 c0 04             	add    $0x4,%eax
  104476:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  10447d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104480:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104483:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104486:	0f a3 10             	bt     %edx,(%eax)
  104489:	19 c0                	sbb    %eax,%eax
  10448b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
  10448e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104492:	0f 95 c0             	setne  %al
  104495:	0f b6 c0             	movzbl %al,%eax
  104498:	85 c0                	test   %eax,%eax
  10449a:	75 24                	jne    1044c0 <default_init_memmap+0x88>
  10449c:	c7 44 24 0c a9 6e 10 	movl   $0x106ea9,0xc(%esp)
  1044a3:	00 
  1044a4:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1044ab:	00 
  1044ac:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  1044b3:	00 
  1044b4:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1044bb:	e8 29 bf ff ff       	call   1003e9 <__panic>
        p->flags = p->property = 0;
  1044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1044ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044cd:	8b 50 08             	mov    0x8(%eax),%edx
  1044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044d3:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  1044d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1044dd:	00 
  1044de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044e1:	89 04 24             	mov    %eax,(%esp)
  1044e4:	e8 13 ff ff ff       	call   1043fc <set_page_ref>
//初始化维护页（虚拟地址）
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  1044e9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1044ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044f0:	89 d0                	mov    %edx,%eax
  1044f2:	c1 e0 02             	shl    $0x2,%eax
  1044f5:	01 d0                	add    %edx,%eax
  1044f7:	c1 e0 02             	shl    $0x2,%eax
  1044fa:	89 c2                	mov    %eax,%edx
  1044fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1044ff:	01 d0                	add    %edx,%eax
  104501:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104504:	0f 85 66 ff ff ff    	jne    104470 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  10450a:	8b 45 08             	mov    0x8(%ebp),%eax
  10450d:	8b 55 0c             	mov    0xc(%ebp),%edx
  104510:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104513:	8b 45 08             	mov    0x8(%ebp),%eax
  104516:	83 c0 04             	add    $0x4,%eax
  104519:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  104520:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104523:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104526:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104529:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  10452c:	8b 15 84 af 11 00    	mov    0x11af84,%edx
  104532:	8b 45 0c             	mov    0xc(%ebp),%eax
  104535:	01 d0                	add    %edx,%eax
  104537:	a3 84 af 11 00       	mov    %eax,0x11af84
    list_add_before(&free_list, &(base->page_link));
  10453c:	8b 45 08             	mov    0x8(%ebp),%eax
  10453f:	83 c0 0c             	add    $0xc,%eax
  104542:	c7 45 f0 7c af 11 00 	movl   $0x11af7c,-0x10(%ebp)
  104549:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10454c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10454f:	8b 00                	mov    (%eax),%eax
  104551:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104554:	89 55 d8             	mov    %edx,-0x28(%ebp)
  104557:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10455a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10455d:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  104560:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104563:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104566:	89 10                	mov    %edx,(%eax)
  104568:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10456b:	8b 10                	mov    (%eax),%edx
  10456d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104570:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104573:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104576:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104579:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10457c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10457f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104582:	89 10                	mov    %edx,(%eax)
}
  104584:	90                   	nop
  104585:	c9                   	leave  
  104586:	c3                   	ret    

00104587 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  104587:	55                   	push   %ebp
  104588:	89 e5                	mov    %esp,%ebp
  10458a:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  10458d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104591:	75 24                	jne    1045b7 <default_alloc_pages+0x30>
  104593:	c7 44 24 0c 78 6e 10 	movl   $0x106e78,0xc(%esp)
  10459a:	00 
  10459b:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1045a2:	00 
  1045a3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  1045aa:	00 
  1045ab:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1045b2:	e8 32 be ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  1045b7:	a1 84 af 11 00       	mov    0x11af84,%eax
  1045bc:	3b 45 08             	cmp    0x8(%ebp),%eax
  1045bf:	73 0a                	jae    1045cb <default_alloc_pages+0x44>
        return NULL;
  1045c1:	b8 00 00 00 00       	mov    $0x0,%eax
  1045c6:	e9 3d 01 00 00       	jmp    104708 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
  1045cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  1045d2:	c7 45 f0 7c af 11 00 	movl   $0x11af7c,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
  1045d9:	eb 1c                	jmp    1045f7 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  1045db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045de:	83 e8 0c             	sub    $0xc,%eax
  1045e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
  1045e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045e7:	8b 40 08             	mov    0x8(%eax),%eax
  1045ea:	3b 45 08             	cmp    0x8(%ebp),%eax
  1045ed:	72 08                	jb     1045f7 <default_alloc_pages+0x70>
            page = p;
  1045ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  1045f5:	eb 18                	jmp    10460f <default_alloc_pages+0x88>
  1045f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1045fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104600:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
  104603:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104606:	81 7d f0 7c af 11 00 	cmpl   $0x11af7c,-0x10(%ebp)
  10460d:	75 cc                	jne    1045db <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  10460f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104613:	0f 84 ec 00 00 00    	je     104705 <default_alloc_pages+0x17e>
        if (page->property > n) {
  104619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10461c:	8b 40 08             	mov    0x8(%eax),%eax
  10461f:	3b 45 08             	cmp    0x8(%ebp),%eax
  104622:	0f 86 8c 00 00 00    	jbe    1046b4 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
  104628:	8b 55 08             	mov    0x8(%ebp),%edx
  10462b:	89 d0                	mov    %edx,%eax
  10462d:	c1 e0 02             	shl    $0x2,%eax
  104630:	01 d0                	add    %edx,%eax
  104632:	c1 e0 02             	shl    $0x2,%eax
  104635:	89 c2                	mov    %eax,%edx
  104637:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10463a:	01 d0                	add    %edx,%eax
  10463c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
  10463f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104642:	8b 40 08             	mov    0x8(%eax),%eax
  104645:	2b 45 08             	sub    0x8(%ebp),%eax
  104648:	89 c2                	mov    %eax,%edx
  10464a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10464d:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  104650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104653:	83 c0 04             	add    $0x4,%eax
  104656:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
  10465d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  104660:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104663:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104666:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
  104669:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10466c:	83 c0 0c             	add    $0xc,%eax
  10466f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104672:	83 c2 0c             	add    $0xc,%edx
  104675:	89 55 ec             	mov    %edx,-0x14(%ebp)
  104678:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  10467b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10467e:	8b 40 04             	mov    0x4(%eax),%eax
  104681:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104684:	89 55 cc             	mov    %edx,-0x34(%ebp)
  104687:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10468a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  10468d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  104690:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104693:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104696:	89 10                	mov    %edx,(%eax)
  104698:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10469b:	8b 10                	mov    (%eax),%edx
  10469d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1046a0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1046a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1046a6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1046a9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1046ac:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1046af:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1046b2:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
  1046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046b7:	83 c0 0c             	add    $0xc,%eax
  1046ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1046bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1046c0:	8b 40 04             	mov    0x4(%eax),%eax
  1046c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1046c6:	8b 12                	mov    (%edx),%edx
  1046c8:	89 55 b8             	mov    %edx,-0x48(%ebp)
  1046cb:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1046ce:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1046d1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1046d4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1046d7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1046da:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1046dd:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  1046df:	a1 84 af 11 00       	mov    0x11af84,%eax
  1046e4:	2b 45 08             	sub    0x8(%ebp),%eax
  1046e7:	a3 84 af 11 00       	mov    %eax,0x11af84
        ClearPageProperty(page);
  1046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ef:	83 c0 04             	add    $0x4,%eax
  1046f2:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1046f9:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1046fc:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1046ff:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104702:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  104705:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104708:	c9                   	leave  
  104709:	c3                   	ret    

0010470a <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  10470a:	55                   	push   %ebp
  10470b:	89 e5                	mov    %esp,%ebp
  10470d:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  104713:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104717:	75 24                	jne    10473d <default_free_pages+0x33>
  104719:	c7 44 24 0c 78 6e 10 	movl   $0x106e78,0xc(%esp)
  104720:	00 
  104721:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104728:	00 
  104729:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  104730:	00 
  104731:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104738:	e8 ac bc ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  10473d:	8b 45 08             	mov    0x8(%ebp),%eax
  104740:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104743:	e9 9d 00 00 00       	jmp    1047e5 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  104748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10474b:	83 c0 04             	add    $0x4,%eax
  10474e:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  104755:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104758:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10475b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10475e:	0f a3 10             	bt     %edx,(%eax)
  104761:	19 c0                	sbb    %eax,%eax
  104763:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104766:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  10476a:	0f 95 c0             	setne  %al
  10476d:	0f b6 c0             	movzbl %al,%eax
  104770:	85 c0                	test   %eax,%eax
  104772:	75 2c                	jne    1047a0 <default_free_pages+0x96>
  104774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104777:	83 c0 04             	add    $0x4,%eax
  10477a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  104781:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104784:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104787:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10478a:	0f a3 10             	bt     %edx,(%eax)
  10478d:	19 c0                	sbb    %eax,%eax
  10478f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
  104792:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  104796:	0f 95 c0             	setne  %al
  104799:	0f b6 c0             	movzbl %al,%eax
  10479c:	85 c0                	test   %eax,%eax
  10479e:	74 24                	je     1047c4 <default_free_pages+0xba>
  1047a0:	c7 44 24 0c bc 6e 10 	movl   $0x106ebc,0xc(%esp)
  1047a7:	00 
  1047a8:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1047af:	00 
  1047b0:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  1047b7:	00 
  1047b8:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1047bf:	e8 25 bc ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  1047c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047c7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  1047ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1047d5:	00 
  1047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047d9:	89 04 24             	mov    %eax,(%esp)
  1047dc:	e8 1b fc ff ff       	call   1043fc <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  1047e1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1047e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1047e8:	89 d0                	mov    %edx,%eax
  1047ea:	c1 e0 02             	shl    $0x2,%eax
  1047ed:	01 d0                	add    %edx,%eax
  1047ef:	c1 e0 02             	shl    $0x2,%eax
  1047f2:	89 c2                	mov    %eax,%edx
  1047f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1047f7:	01 d0                	add    %edx,%eax
  1047f9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1047fc:	0f 85 46 ff ff ff    	jne    104748 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  104802:	8b 45 08             	mov    0x8(%ebp),%eax
  104805:	8b 55 0c             	mov    0xc(%ebp),%edx
  104808:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  10480b:	8b 45 08             	mov    0x8(%ebp),%eax
  10480e:	83 c0 04             	add    $0x4,%eax
  104811:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  104818:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10481b:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10481e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104821:	0f ab 10             	bts    %edx,(%eax)
  104824:	c7 45 e8 7c af 11 00 	movl   $0x11af7c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10482b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10482e:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  104831:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  104834:	e9 08 01 00 00       	jmp    104941 <default_free_pages+0x237>
        p = le2page(le, page_link);
  104839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10483c:	83 e8 0c             	sub    $0xc,%eax
  10483f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104842:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104845:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104848:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10484b:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  10484e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
  104851:	8b 45 08             	mov    0x8(%ebp),%eax
  104854:	8b 50 08             	mov    0x8(%eax),%edx
  104857:	89 d0                	mov    %edx,%eax
  104859:	c1 e0 02             	shl    $0x2,%eax
  10485c:	01 d0                	add    %edx,%eax
  10485e:	c1 e0 02             	shl    $0x2,%eax
  104861:	89 c2                	mov    %eax,%edx
  104863:	8b 45 08             	mov    0x8(%ebp),%eax
  104866:	01 d0                	add    %edx,%eax
  104868:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10486b:	75 5a                	jne    1048c7 <default_free_pages+0x1bd>
            base->property += p->property;
  10486d:	8b 45 08             	mov    0x8(%ebp),%eax
  104870:	8b 50 08             	mov    0x8(%eax),%edx
  104873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104876:	8b 40 08             	mov    0x8(%eax),%eax
  104879:	01 c2                	add    %eax,%edx
  10487b:	8b 45 08             	mov    0x8(%ebp),%eax
  10487e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  104881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104884:	83 c0 04             	add    $0x4,%eax
  104887:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  10488e:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104891:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104894:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104897:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  10489a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10489d:	83 c0 0c             	add    $0xc,%eax
  1048a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1048a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1048a6:	8b 40 04             	mov    0x4(%eax),%eax
  1048a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1048ac:	8b 12                	mov    (%edx),%edx
  1048ae:	89 55 a8             	mov    %edx,-0x58(%ebp)
  1048b1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1048b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1048b7:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  1048ba:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1048bd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1048c0:	8b 55 a8             	mov    -0x58(%ebp),%edx
  1048c3:	89 10                	mov    %edx,(%eax)
  1048c5:	eb 7a                	jmp    104941 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  1048c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048ca:	8b 50 08             	mov    0x8(%eax),%edx
  1048cd:	89 d0                	mov    %edx,%eax
  1048cf:	c1 e0 02             	shl    $0x2,%eax
  1048d2:	01 d0                	add    %edx,%eax
  1048d4:	c1 e0 02             	shl    $0x2,%eax
  1048d7:	89 c2                	mov    %eax,%edx
  1048d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048dc:	01 d0                	add    %edx,%eax
  1048de:	3b 45 08             	cmp    0x8(%ebp),%eax
  1048e1:	75 5e                	jne    104941 <default_free_pages+0x237>
            p->property += base->property;
  1048e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048e6:	8b 50 08             	mov    0x8(%eax),%edx
  1048e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1048ec:	8b 40 08             	mov    0x8(%eax),%eax
  1048ef:	01 c2                	add    %eax,%edx
  1048f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048f4:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  1048f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1048fa:	83 c0 04             	add    $0x4,%eax
  1048fd:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  104904:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104907:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10490a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10490d:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  104910:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104913:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104919:	83 c0 0c             	add    $0xc,%eax
  10491c:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  10491f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104922:	8b 40 04             	mov    0x4(%eax),%eax
  104925:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104928:	8b 12                	mov    (%edx),%edx
  10492a:	89 55 9c             	mov    %edx,-0x64(%ebp)
  10492d:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104930:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104933:	8b 55 98             	mov    -0x68(%ebp),%edx
  104936:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104939:	8b 45 98             	mov    -0x68(%ebp),%eax
  10493c:	8b 55 9c             	mov    -0x64(%ebp),%edx
  10493f:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  104941:	81 7d f0 7c af 11 00 	cmpl   $0x11af7c,-0x10(%ebp)
  104948:	0f 85 eb fe ff ff    	jne    104839 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  10494e:	8b 15 84 af 11 00    	mov    0x11af84,%edx
  104954:	8b 45 0c             	mov    0xc(%ebp),%eax
  104957:	01 d0                	add    %edx,%eax
  104959:	a3 84 af 11 00       	mov    %eax,0x11af84
  10495e:	c7 45 d0 7c af 11 00 	movl   $0x11af7c,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104965:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104968:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  10496b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  10496e:	eb 74                	jmp    1049e4 <default_free_pages+0x2da>
        p = le2page(le, page_link);
  104970:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104973:	83 e8 0c             	sub    $0xc,%eax
  104976:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  104979:	8b 45 08             	mov    0x8(%ebp),%eax
  10497c:	8b 50 08             	mov    0x8(%eax),%edx
  10497f:	89 d0                	mov    %edx,%eax
  104981:	c1 e0 02             	shl    $0x2,%eax
  104984:	01 d0                	add    %edx,%eax
  104986:	c1 e0 02             	shl    $0x2,%eax
  104989:	89 c2                	mov    %eax,%edx
  10498b:	8b 45 08             	mov    0x8(%ebp),%eax
  10498e:	01 d0                	add    %edx,%eax
  104990:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104993:	77 40                	ja     1049d5 <default_free_pages+0x2cb>
            assert(base + base->property != p);
  104995:	8b 45 08             	mov    0x8(%ebp),%eax
  104998:	8b 50 08             	mov    0x8(%eax),%edx
  10499b:	89 d0                	mov    %edx,%eax
  10499d:	c1 e0 02             	shl    $0x2,%eax
  1049a0:	01 d0                	add    %edx,%eax
  1049a2:	c1 e0 02             	shl    $0x2,%eax
  1049a5:	89 c2                	mov    %eax,%edx
  1049a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1049aa:	01 d0                	add    %edx,%eax
  1049ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1049af:	75 3e                	jne    1049ef <default_free_pages+0x2e5>
  1049b1:	c7 44 24 0c e1 6e 10 	movl   $0x106ee1,0xc(%esp)
  1049b8:	00 
  1049b9:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1049c0:	00 
  1049c1:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  1049c8:	00 
  1049c9:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1049d0:	e8 14 ba ff ff       	call   1003e9 <__panic>
  1049d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1049db:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1049de:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
  1049e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
  1049e4:	81 7d f0 7c af 11 00 	cmpl   $0x11af7c,-0x10(%ebp)
  1049eb:	75 83                	jne    104970 <default_free_pages+0x266>
  1049ed:	eb 01                	jmp    1049f0 <default_free_pages+0x2e6>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
  1049ef:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
  1049f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1049f3:	8d 50 0c             	lea    0xc(%eax),%edx
  1049f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049f9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  1049fc:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1049ff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104a02:	8b 00                	mov    (%eax),%eax
  104a04:	8b 55 90             	mov    -0x70(%ebp),%edx
  104a07:	89 55 8c             	mov    %edx,-0x74(%ebp)
  104a0a:	89 45 88             	mov    %eax,-0x78(%ebp)
  104a0d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104a10:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  104a13:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104a16:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104a19:	89 10                	mov    %edx,(%eax)
  104a1b:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104a1e:	8b 10                	mov    (%eax),%edx
  104a20:	8b 45 88             	mov    -0x78(%ebp),%eax
  104a23:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104a26:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104a29:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104a2c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104a2f:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104a32:	8b 55 88             	mov    -0x78(%ebp),%edx
  104a35:	89 10                	mov    %edx,(%eax)
}
  104a37:	90                   	nop
  104a38:	c9                   	leave  
  104a39:	c3                   	ret    

00104a3a <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104a3a:	55                   	push   %ebp
  104a3b:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104a3d:	a1 84 af 11 00       	mov    0x11af84,%eax
}
  104a42:	5d                   	pop    %ebp
  104a43:	c3                   	ret    

00104a44 <basic_check>:

static void
basic_check(void) {
  104a44:	55                   	push   %ebp
  104a45:	89 e5                	mov    %esp,%ebp
  104a47:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104a4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104a5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a64:	e8 ba e2 ff ff       	call   102d23 <alloc_pages>
  104a69:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104a6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104a70:	75 24                	jne    104a96 <basic_check+0x52>
  104a72:	c7 44 24 0c fc 6e 10 	movl   $0x106efc,0xc(%esp)
  104a79:	00 
  104a7a:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104a81:	00 
  104a82:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  104a89:	00 
  104a8a:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104a91:	e8 53 b9 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104a96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a9d:	e8 81 e2 ff ff       	call   102d23 <alloc_pages>
  104aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104aa5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104aa9:	75 24                	jne    104acf <basic_check+0x8b>
  104aab:	c7 44 24 0c 18 6f 10 	movl   $0x106f18,0xc(%esp)
  104ab2:	00 
  104ab3:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104aba:	00 
  104abb:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  104ac2:	00 
  104ac3:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104aca:	e8 1a b9 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104acf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ad6:	e8 48 e2 ff ff       	call   102d23 <alloc_pages>
  104adb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104ade:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104ae2:	75 24                	jne    104b08 <basic_check+0xc4>
  104ae4:	c7 44 24 0c 34 6f 10 	movl   $0x106f34,0xc(%esp)
  104aeb:	00 
  104aec:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104af3:	00 
  104af4:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  104afb:	00 
  104afc:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104b03:	e8 e1 b8 ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b0b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104b0e:	74 10                	je     104b20 <basic_check+0xdc>
  104b10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b13:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104b16:	74 08                	je     104b20 <basic_check+0xdc>
  104b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b1b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104b1e:	75 24                	jne    104b44 <basic_check+0x100>
  104b20:	c7 44 24 0c 50 6f 10 	movl   $0x106f50,0xc(%esp)
  104b27:	00 
  104b28:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104b2f:	00 
  104b30:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  104b37:	00 
  104b38:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104b3f:	e8 a5 b8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b47:	89 04 24             	mov    %eax,(%esp)
  104b4a:	e8 a3 f8 ff ff       	call   1043f2 <page_ref>
  104b4f:	85 c0                	test   %eax,%eax
  104b51:	75 1e                	jne    104b71 <basic_check+0x12d>
  104b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b56:	89 04 24             	mov    %eax,(%esp)
  104b59:	e8 94 f8 ff ff       	call   1043f2 <page_ref>
  104b5e:	85 c0                	test   %eax,%eax
  104b60:	75 0f                	jne    104b71 <basic_check+0x12d>
  104b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b65:	89 04 24             	mov    %eax,(%esp)
  104b68:	e8 85 f8 ff ff       	call   1043f2 <page_ref>
  104b6d:	85 c0                	test   %eax,%eax
  104b6f:	74 24                	je     104b95 <basic_check+0x151>
  104b71:	c7 44 24 0c 74 6f 10 	movl   $0x106f74,0xc(%esp)
  104b78:	00 
  104b79:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104b80:	00 
  104b81:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  104b88:	00 
  104b89:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104b90:	e8 54 b8 ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b98:	89 04 24             	mov    %eax,(%esp)
  104b9b:	e8 3c f8 ff ff       	call   1043dc <page2pa>
  104ba0:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104ba6:	c1 e2 0c             	shl    $0xc,%edx
  104ba9:	39 d0                	cmp    %edx,%eax
  104bab:	72 24                	jb     104bd1 <basic_check+0x18d>
  104bad:	c7 44 24 0c b0 6f 10 	movl   $0x106fb0,0xc(%esp)
  104bb4:	00 
  104bb5:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104bbc:	00 
  104bbd:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  104bc4:	00 
  104bc5:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104bcc:	e8 18 b8 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bd4:	89 04 24             	mov    %eax,(%esp)
  104bd7:	e8 00 f8 ff ff       	call   1043dc <page2pa>
  104bdc:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104be2:	c1 e2 0c             	shl    $0xc,%edx
  104be5:	39 d0                	cmp    %edx,%eax
  104be7:	72 24                	jb     104c0d <basic_check+0x1c9>
  104be9:	c7 44 24 0c cd 6f 10 	movl   $0x106fcd,0xc(%esp)
  104bf0:	00 
  104bf1:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104bf8:	00 
  104bf9:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  104c00:	00 
  104c01:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104c08:	e8 dc b7 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c10:	89 04 24             	mov    %eax,(%esp)
  104c13:	e8 c4 f7 ff ff       	call   1043dc <page2pa>
  104c18:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104c1e:	c1 e2 0c             	shl    $0xc,%edx
  104c21:	39 d0                	cmp    %edx,%eax
  104c23:	72 24                	jb     104c49 <basic_check+0x205>
  104c25:	c7 44 24 0c ea 6f 10 	movl   $0x106fea,0xc(%esp)
  104c2c:	00 
  104c2d:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104c34:	00 
  104c35:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  104c3c:	00 
  104c3d:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104c44:	e8 a0 b7 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104c49:	a1 7c af 11 00       	mov    0x11af7c,%eax
  104c4e:	8b 15 80 af 11 00    	mov    0x11af80,%edx
  104c54:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104c57:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104c5a:	c7 45 e4 7c af 11 00 	movl   $0x11af7c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104c61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104c67:	89 50 04             	mov    %edx,0x4(%eax)
  104c6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c6d:	8b 50 04             	mov    0x4(%eax),%edx
  104c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c73:	89 10                	mov    %edx,(%eax)
  104c75:	c7 45 d8 7c af 11 00 	movl   $0x11af7c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  104c7c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104c7f:	8b 40 04             	mov    0x4(%eax),%eax
  104c82:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104c85:	0f 94 c0             	sete   %al
  104c88:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104c8b:	85 c0                	test   %eax,%eax
  104c8d:	75 24                	jne    104cb3 <basic_check+0x26f>
  104c8f:	c7 44 24 0c 07 70 10 	movl   $0x107007,0xc(%esp)
  104c96:	00 
  104c97:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104c9e:	00 
  104c9f:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  104ca6:	00 
  104ca7:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104cae:	e8 36 b7 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104cb3:	a1 84 af 11 00       	mov    0x11af84,%eax
  104cb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  104cbb:	c7 05 84 af 11 00 00 	movl   $0x0,0x11af84
  104cc2:	00 00 00 

    assert(alloc_page() == NULL);
  104cc5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ccc:	e8 52 e0 ff ff       	call   102d23 <alloc_pages>
  104cd1:	85 c0                	test   %eax,%eax
  104cd3:	74 24                	je     104cf9 <basic_check+0x2b5>
  104cd5:	c7 44 24 0c 1e 70 10 	movl   $0x10701e,0xc(%esp)
  104cdc:	00 
  104cdd:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104ce4:	00 
  104ce5:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  104cec:	00 
  104ced:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104cf4:	e8 f0 b6 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104cf9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d00:	00 
  104d01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d04:	89 04 24             	mov    %eax,(%esp)
  104d07:	e8 4f e0 ff ff       	call   102d5b <free_pages>
    free_page(p1);
  104d0c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d13:	00 
  104d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d17:	89 04 24             	mov    %eax,(%esp)
  104d1a:	e8 3c e0 ff ff       	call   102d5b <free_pages>
    free_page(p2);
  104d1f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d26:	00 
  104d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d2a:	89 04 24             	mov    %eax,(%esp)
  104d2d:	e8 29 e0 ff ff       	call   102d5b <free_pages>
    assert(nr_free == 3);
  104d32:	a1 84 af 11 00       	mov    0x11af84,%eax
  104d37:	83 f8 03             	cmp    $0x3,%eax
  104d3a:	74 24                	je     104d60 <basic_check+0x31c>
  104d3c:	c7 44 24 0c 33 70 10 	movl   $0x107033,0xc(%esp)
  104d43:	00 
  104d44:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104d4b:	00 
  104d4c:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  104d53:	00 
  104d54:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104d5b:	e8 89 b6 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104d60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d67:	e8 b7 df ff ff       	call   102d23 <alloc_pages>
  104d6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104d6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104d73:	75 24                	jne    104d99 <basic_check+0x355>
  104d75:	c7 44 24 0c fc 6e 10 	movl   $0x106efc,0xc(%esp)
  104d7c:	00 
  104d7d:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104d84:	00 
  104d85:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  104d8c:	00 
  104d8d:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104d94:	e8 50 b6 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104d99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104da0:	e8 7e df ff ff       	call   102d23 <alloc_pages>
  104da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104da8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104dac:	75 24                	jne    104dd2 <basic_check+0x38e>
  104dae:	c7 44 24 0c 18 6f 10 	movl   $0x106f18,0xc(%esp)
  104db5:	00 
  104db6:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104dbd:	00 
  104dbe:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  104dc5:	00 
  104dc6:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104dcd:	e8 17 b6 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104dd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104dd9:	e8 45 df ff ff       	call   102d23 <alloc_pages>
  104dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104de1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104de5:	75 24                	jne    104e0b <basic_check+0x3c7>
  104de7:	c7 44 24 0c 34 6f 10 	movl   $0x106f34,0xc(%esp)
  104dee:	00 
  104def:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104df6:	00 
  104df7:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  104dfe:	00 
  104dff:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104e06:	e8 de b5 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104e0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e12:	e8 0c df ff ff       	call   102d23 <alloc_pages>
  104e17:	85 c0                	test   %eax,%eax
  104e19:	74 24                	je     104e3f <basic_check+0x3fb>
  104e1b:	c7 44 24 0c 1e 70 10 	movl   $0x10701e,0xc(%esp)
  104e22:	00 
  104e23:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104e2a:	00 
  104e2b:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  104e32:	00 
  104e33:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104e3a:	e8 aa b5 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104e3f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e46:	00 
  104e47:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e4a:	89 04 24             	mov    %eax,(%esp)
  104e4d:	e8 09 df ff ff       	call   102d5b <free_pages>
  104e52:	c7 45 e8 7c af 11 00 	movl   $0x11af7c,-0x18(%ebp)
  104e59:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e5c:	8b 40 04             	mov    0x4(%eax),%eax
  104e5f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104e62:	0f 94 c0             	sete   %al
  104e65:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104e68:	85 c0                	test   %eax,%eax
  104e6a:	74 24                	je     104e90 <basic_check+0x44c>
  104e6c:	c7 44 24 0c 40 70 10 	movl   $0x107040,0xc(%esp)
  104e73:	00 
  104e74:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104e7b:	00 
  104e7c:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  104e83:	00 
  104e84:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104e8b:	e8 59 b5 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104e90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e97:	e8 87 de ff ff       	call   102d23 <alloc_pages>
  104e9c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104e9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104ea2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104ea5:	74 24                	je     104ecb <basic_check+0x487>
  104ea7:	c7 44 24 0c 58 70 10 	movl   $0x107058,0xc(%esp)
  104eae:	00 
  104eaf:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104eb6:	00 
  104eb7:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  104ebe:	00 
  104ebf:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104ec6:	e8 1e b5 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104ecb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ed2:	e8 4c de ff ff       	call   102d23 <alloc_pages>
  104ed7:	85 c0                	test   %eax,%eax
  104ed9:	74 24                	je     104eff <basic_check+0x4bb>
  104edb:	c7 44 24 0c 1e 70 10 	movl   $0x10701e,0xc(%esp)
  104ee2:	00 
  104ee3:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104eea:	00 
  104eeb:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  104ef2:	00 
  104ef3:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104efa:	e8 ea b4 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104eff:	a1 84 af 11 00       	mov    0x11af84,%eax
  104f04:	85 c0                	test   %eax,%eax
  104f06:	74 24                	je     104f2c <basic_check+0x4e8>
  104f08:	c7 44 24 0c 71 70 10 	movl   $0x107071,0xc(%esp)
  104f0f:	00 
  104f10:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104f17:	00 
  104f18:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  104f1f:	00 
  104f20:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104f27:	e8 bd b4 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104f2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104f2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104f32:	a3 7c af 11 00       	mov    %eax,0x11af7c
  104f37:	89 15 80 af 11 00    	mov    %edx,0x11af80
    nr_free = nr_free_store;
  104f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f40:	a3 84 af 11 00       	mov    %eax,0x11af84

    free_page(p);
  104f45:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f4c:	00 
  104f4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f50:	89 04 24             	mov    %eax,(%esp)
  104f53:	e8 03 de ff ff       	call   102d5b <free_pages>
    free_page(p1);
  104f58:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f5f:	00 
  104f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f63:	89 04 24             	mov    %eax,(%esp)
  104f66:	e8 f0 dd ff ff       	call   102d5b <free_pages>
    free_page(p2);
  104f6b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f72:	00 
  104f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f76:	89 04 24             	mov    %eax,(%esp)
  104f79:	e8 dd dd ff ff       	call   102d5b <free_pages>
}
  104f7e:	90                   	nop
  104f7f:	c9                   	leave  
  104f80:	c3                   	ret    

00104f81 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104f81:	55                   	push   %ebp
  104f82:	89 e5                	mov    %esp,%ebp
  104f84:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104f8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104f91:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104f98:	c7 45 ec 7c af 11 00 	movl   $0x11af7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104f9f:	eb 6a                	jmp    10500b <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104fa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104fa4:	83 e8 0c             	sub    $0xc,%eax
  104fa7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
  104faa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fad:	83 c0 04             	add    $0x4,%eax
  104fb0:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  104fb7:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104fba:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104fbd:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104fc0:	0f a3 10             	bt     %edx,(%eax)
  104fc3:	19 c0                	sbb    %eax,%eax
  104fc5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
  104fc8:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
  104fcc:	0f 95 c0             	setne  %al
  104fcf:	0f b6 c0             	movzbl %al,%eax
  104fd2:	85 c0                	test   %eax,%eax
  104fd4:	75 24                	jne    104ffa <default_check+0x79>
  104fd6:	c7 44 24 0c 7e 70 10 	movl   $0x10707e,0xc(%esp)
  104fdd:	00 
  104fde:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  104fe5:	00 
  104fe6:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  104fed:	00 
  104fee:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  104ff5:	e8 ef b3 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104ffa:	ff 45 f4             	incl   -0xc(%ebp)
  104ffd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105000:	8b 50 08             	mov    0x8(%eax),%edx
  105003:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105006:	01 d0                	add    %edx,%eax
  105008:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10500b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10500e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  105011:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105014:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  105017:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10501a:	81 7d ec 7c af 11 00 	cmpl   $0x11af7c,-0x14(%ebp)
  105021:	0f 85 7a ff ff ff    	jne    104fa1 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  105027:	e8 62 dd ff ff       	call   102d8e <nr_free_pages>
  10502c:	89 c2                	mov    %eax,%edx
  10502e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105031:	39 c2                	cmp    %eax,%edx
  105033:	74 24                	je     105059 <default_check+0xd8>
  105035:	c7 44 24 0c 8e 70 10 	movl   $0x10708e,0xc(%esp)
  10503c:	00 
  10503d:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  105044:	00 
  105045:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  10504c:	00 
  10504d:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  105054:	e8 90 b3 ff ff       	call   1003e9 <__panic>

    basic_check();
  105059:	e8 e6 f9 ff ff       	call   104a44 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10505e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105065:	e8 b9 dc ff ff       	call   102d23 <alloc_pages>
  10506a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
  10506d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105071:	75 24                	jne    105097 <default_check+0x116>
  105073:	c7 44 24 0c a7 70 10 	movl   $0x1070a7,0xc(%esp)
  10507a:	00 
  10507b:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  105082:	00 
  105083:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  10508a:	00 
  10508b:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  105092:	e8 52 b3 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  105097:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10509a:	83 c0 04             	add    $0x4,%eax
  10509d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  1050a4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1050a7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1050aa:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1050ad:	0f a3 10             	bt     %edx,(%eax)
  1050b0:	19 c0                	sbb    %eax,%eax
  1050b2:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
  1050b5:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
  1050b9:	0f 95 c0             	setne  %al
  1050bc:	0f b6 c0             	movzbl %al,%eax
  1050bf:	85 c0                	test   %eax,%eax
  1050c1:	74 24                	je     1050e7 <default_check+0x166>
  1050c3:	c7 44 24 0c b2 70 10 	movl   $0x1070b2,0xc(%esp)
  1050ca:	00 
  1050cb:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1050d2:	00 
  1050d3:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  1050da:	00 
  1050db:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1050e2:	e8 02 b3 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  1050e7:	a1 7c af 11 00       	mov    0x11af7c,%eax
  1050ec:	8b 15 80 af 11 00    	mov    0x11af80,%edx
  1050f2:	89 45 80             	mov    %eax,-0x80(%ebp)
  1050f5:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1050f8:	c7 45 d0 7c af 11 00 	movl   $0x11af7c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1050ff:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105102:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105105:	89 50 04             	mov    %edx,0x4(%eax)
  105108:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10510b:	8b 50 04             	mov    0x4(%eax),%edx
  10510e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105111:	89 10                	mov    %edx,(%eax)
  105113:	c7 45 d8 7c af 11 00 	movl   $0x11af7c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  10511a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10511d:	8b 40 04             	mov    0x4(%eax),%eax
  105120:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  105123:	0f 94 c0             	sete   %al
  105126:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  105129:	85 c0                	test   %eax,%eax
  10512b:	75 24                	jne    105151 <default_check+0x1d0>
  10512d:	c7 44 24 0c 07 70 10 	movl   $0x107007,0xc(%esp)
  105134:	00 
  105135:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  10513c:	00 
  10513d:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  105144:	00 
  105145:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  10514c:	e8 98 b2 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  105151:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105158:	e8 c6 db ff ff       	call   102d23 <alloc_pages>
  10515d:	85 c0                	test   %eax,%eax
  10515f:	74 24                	je     105185 <default_check+0x204>
  105161:	c7 44 24 0c 1e 70 10 	movl   $0x10701e,0xc(%esp)
  105168:	00 
  105169:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  105170:	00 
  105171:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  105178:	00 
  105179:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  105180:	e8 64 b2 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  105185:	a1 84 af 11 00       	mov    0x11af84,%eax
  10518a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
  10518d:	c7 05 84 af 11 00 00 	movl   $0x0,0x11af84
  105194:	00 00 00 

    free_pages(p0 + 2, 3);
  105197:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10519a:	83 c0 28             	add    $0x28,%eax
  10519d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1051a4:	00 
  1051a5:	89 04 24             	mov    %eax,(%esp)
  1051a8:	e8 ae db ff ff       	call   102d5b <free_pages>
    assert(alloc_pages(4) == NULL);
  1051ad:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1051b4:	e8 6a db ff ff       	call   102d23 <alloc_pages>
  1051b9:	85 c0                	test   %eax,%eax
  1051bb:	74 24                	je     1051e1 <default_check+0x260>
  1051bd:	c7 44 24 0c c4 70 10 	movl   $0x1070c4,0xc(%esp)
  1051c4:	00 
  1051c5:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1051cc:	00 
  1051cd:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1051d4:	00 
  1051d5:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1051dc:	e8 08 b2 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1051e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051e4:	83 c0 28             	add    $0x28,%eax
  1051e7:	83 c0 04             	add    $0x4,%eax
  1051ea:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  1051f1:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1051f4:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1051f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1051fa:	0f a3 10             	bt     %edx,(%eax)
  1051fd:	19 c0                	sbb    %eax,%eax
  1051ff:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105202:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105206:	0f 95 c0             	setne  %al
  105209:	0f b6 c0             	movzbl %al,%eax
  10520c:	85 c0                	test   %eax,%eax
  10520e:	74 0e                	je     10521e <default_check+0x29d>
  105210:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105213:	83 c0 28             	add    $0x28,%eax
  105216:	8b 40 08             	mov    0x8(%eax),%eax
  105219:	83 f8 03             	cmp    $0x3,%eax
  10521c:	74 24                	je     105242 <default_check+0x2c1>
  10521e:	c7 44 24 0c dc 70 10 	movl   $0x1070dc,0xc(%esp)
  105225:	00 
  105226:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  10522d:	00 
  10522e:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  105235:	00 
  105236:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  10523d:	e8 a7 b1 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  105242:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105249:	e8 d5 da ff ff       	call   102d23 <alloc_pages>
  10524e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  105251:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  105255:	75 24                	jne    10527b <default_check+0x2fa>
  105257:	c7 44 24 0c 08 71 10 	movl   $0x107108,0xc(%esp)
  10525e:	00 
  10525f:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  105266:	00 
  105267:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  10526e:	00 
  10526f:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  105276:	e8 6e b1 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  10527b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105282:	e8 9c da ff ff       	call   102d23 <alloc_pages>
  105287:	85 c0                	test   %eax,%eax
  105289:	74 24                	je     1052af <default_check+0x32e>
  10528b:	c7 44 24 0c 1e 70 10 	movl   $0x10701e,0xc(%esp)
  105292:	00 
  105293:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  10529a:	00 
  10529b:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  1052a2:	00 
  1052a3:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1052aa:	e8 3a b1 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  1052af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052b2:	83 c0 28             	add    $0x28,%eax
  1052b5:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
  1052b8:	74 24                	je     1052de <default_check+0x35d>
  1052ba:	c7 44 24 0c 26 71 10 	movl   $0x107126,0xc(%esp)
  1052c1:	00 
  1052c2:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1052c9:	00 
  1052ca:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  1052d1:	00 
  1052d2:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1052d9:	e8 0b b1 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  1052de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052e1:	83 c0 14             	add    $0x14,%eax
  1052e4:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
  1052e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052ee:	00 
  1052ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052f2:	89 04 24             	mov    %eax,(%esp)
  1052f5:	e8 61 da ff ff       	call   102d5b <free_pages>
    free_pages(p1, 3);
  1052fa:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105301:	00 
  105302:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105305:	89 04 24             	mov    %eax,(%esp)
  105308:	e8 4e da ff ff       	call   102d5b <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10530d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105310:	83 c0 04             	add    $0x4,%eax
  105313:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  10531a:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10531d:	8b 45 94             	mov    -0x6c(%ebp),%eax
  105320:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105323:	0f a3 10             	bt     %edx,(%eax)
  105326:	19 c0                	sbb    %eax,%eax
  105328:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
  10532b:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
  10532f:	0f 95 c0             	setne  %al
  105332:	0f b6 c0             	movzbl %al,%eax
  105335:	85 c0                	test   %eax,%eax
  105337:	74 0b                	je     105344 <default_check+0x3c3>
  105339:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10533c:	8b 40 08             	mov    0x8(%eax),%eax
  10533f:	83 f8 01             	cmp    $0x1,%eax
  105342:	74 24                	je     105368 <default_check+0x3e7>
  105344:	c7 44 24 0c 34 71 10 	movl   $0x107134,0xc(%esp)
  10534b:	00 
  10534c:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  105353:	00 
  105354:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  10535b:	00 
  10535c:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  105363:	e8 81 b0 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  105368:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10536b:	83 c0 04             	add    $0x4,%eax
  10536e:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  105375:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105378:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10537b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10537e:	0f a3 10             	bt     %edx,(%eax)
  105381:	19 c0                	sbb    %eax,%eax
  105383:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
  105386:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
  10538a:	0f 95 c0             	setne  %al
  10538d:	0f b6 c0             	movzbl %al,%eax
  105390:	85 c0                	test   %eax,%eax
  105392:	74 0b                	je     10539f <default_check+0x41e>
  105394:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105397:	8b 40 08             	mov    0x8(%eax),%eax
  10539a:	83 f8 03             	cmp    $0x3,%eax
  10539d:	74 24                	je     1053c3 <default_check+0x442>
  10539f:	c7 44 24 0c 5c 71 10 	movl   $0x10715c,0xc(%esp)
  1053a6:	00 
  1053a7:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1053ae:	00 
  1053af:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  1053b6:	00 
  1053b7:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1053be:	e8 26 b0 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1053c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1053ca:	e8 54 d9 ff ff       	call   102d23 <alloc_pages>
  1053cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1053d2:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1053d5:	83 e8 14             	sub    $0x14,%eax
  1053d8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1053db:	74 24                	je     105401 <default_check+0x480>
  1053dd:	c7 44 24 0c 82 71 10 	movl   $0x107182,0xc(%esp)
  1053e4:	00 
  1053e5:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1053ec:	00 
  1053ed:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  1053f4:	00 
  1053f5:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1053fc:	e8 e8 af ff ff       	call   1003e9 <__panic>
    free_page(p0);
  105401:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105408:	00 
  105409:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10540c:	89 04 24             	mov    %eax,(%esp)
  10540f:	e8 47 d9 ff ff       	call   102d5b <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  105414:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10541b:	e8 03 d9 ff ff       	call   102d23 <alloc_pages>
  105420:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105423:	8b 45 c0             	mov    -0x40(%ebp),%eax
  105426:	83 c0 14             	add    $0x14,%eax
  105429:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10542c:	74 24                	je     105452 <default_check+0x4d1>
  10542e:	c7 44 24 0c a0 71 10 	movl   $0x1071a0,0xc(%esp)
  105435:	00 
  105436:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  10543d:	00 
  10543e:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  105445:	00 
  105446:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  10544d:	e8 97 af ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  105452:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105459:	00 
  10545a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10545d:	89 04 24             	mov    %eax,(%esp)
  105460:	e8 f6 d8 ff ff       	call   102d5b <free_pages>
    free_page(p2);
  105465:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10546c:	00 
  10546d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  105470:	89 04 24             	mov    %eax,(%esp)
  105473:	e8 e3 d8 ff ff       	call   102d5b <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105478:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10547f:	e8 9f d8 ff ff       	call   102d23 <alloc_pages>
  105484:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105487:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10548b:	75 24                	jne    1054b1 <default_check+0x530>
  10548d:	c7 44 24 0c c0 71 10 	movl   $0x1071c0,0xc(%esp)
  105494:	00 
  105495:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  10549c:	00 
  10549d:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  1054a4:	00 
  1054a5:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1054ac:	e8 38 af ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  1054b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1054b8:	e8 66 d8 ff ff       	call   102d23 <alloc_pages>
  1054bd:	85 c0                	test   %eax,%eax
  1054bf:	74 24                	je     1054e5 <default_check+0x564>
  1054c1:	c7 44 24 0c 1e 70 10 	movl   $0x10701e,0xc(%esp)
  1054c8:	00 
  1054c9:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1054d0:	00 
  1054d1:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  1054d8:	00 
  1054d9:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1054e0:	e8 04 af ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  1054e5:	a1 84 af 11 00       	mov    0x11af84,%eax
  1054ea:	85 c0                	test   %eax,%eax
  1054ec:	74 24                	je     105512 <default_check+0x591>
  1054ee:	c7 44 24 0c 71 70 10 	movl   $0x107071,0xc(%esp)
  1054f5:	00 
  1054f6:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1054fd:	00 
  1054fe:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  105505:	00 
  105506:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  10550d:	e8 d7 ae ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  105512:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105515:	a3 84 af 11 00       	mov    %eax,0x11af84

    free_list = free_list_store;
  10551a:	8b 45 80             	mov    -0x80(%ebp),%eax
  10551d:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105520:	a3 7c af 11 00       	mov    %eax,0x11af7c
  105525:	89 15 80 af 11 00    	mov    %edx,0x11af80
    free_pages(p0, 5);
  10552b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  105532:	00 
  105533:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105536:	89 04 24             	mov    %eax,(%esp)
  105539:	e8 1d d8 ff ff       	call   102d5b <free_pages>

    le = &free_list;
  10553e:	c7 45 ec 7c af 11 00 	movl   $0x11af7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105545:	eb 1c                	jmp    105563 <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
  105547:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10554a:	83 e8 0c             	sub    $0xc,%eax
  10554d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
  105550:	ff 4d f4             	decl   -0xc(%ebp)
  105553:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105556:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105559:	8b 40 08             	mov    0x8(%eax),%eax
  10555c:	29 c2                	sub    %eax,%edx
  10555e:	89 d0                	mov    %edx,%eax
  105560:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105563:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105566:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  105569:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10556c:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  10556f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105572:	81 7d ec 7c af 11 00 	cmpl   $0x11af7c,-0x14(%ebp)
  105579:	75 cc                	jne    105547 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  10557b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10557f:	74 24                	je     1055a5 <default_check+0x624>
  105581:	c7 44 24 0c de 71 10 	movl   $0x1071de,0xc(%esp)
  105588:	00 
  105589:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  105590:	00 
  105591:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
  105598:	00 
  105599:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1055a0:	e8 44 ae ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  1055a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1055a9:	74 24                	je     1055cf <default_check+0x64e>
  1055ab:	c7 44 24 0c e9 71 10 	movl   $0x1071e9,0xc(%esp)
  1055b2:	00 
  1055b3:	c7 44 24 08 7e 6e 10 	movl   $0x106e7e,0x8(%esp)
  1055ba:	00 
  1055bb:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  1055c2:	00 
  1055c3:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  1055ca:	e8 1a ae ff ff       	call   1003e9 <__panic>
}
  1055cf:	90                   	nop
  1055d0:	c9                   	leave  
  1055d1:	c3                   	ret    

001055d2 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1055d2:	55                   	push   %ebp
  1055d3:	89 e5                	mov    %esp,%ebp
  1055d5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1055d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1055df:	eb 03                	jmp    1055e4 <strlen+0x12>
        cnt ++;
  1055e1:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  1055e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1055e7:	8d 50 01             	lea    0x1(%eax),%edx
  1055ea:	89 55 08             	mov    %edx,0x8(%ebp)
  1055ed:	0f b6 00             	movzbl (%eax),%eax
  1055f0:	84 c0                	test   %al,%al
  1055f2:	75 ed                	jne    1055e1 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  1055f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1055f7:	c9                   	leave  
  1055f8:	c3                   	ret    

001055f9 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1055f9:	55                   	push   %ebp
  1055fa:	89 e5                	mov    %esp,%ebp
  1055fc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1055ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105606:	eb 03                	jmp    10560b <strnlen+0x12>
        cnt ++;
  105608:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  10560b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10560e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105611:	73 10                	jae    105623 <strnlen+0x2a>
  105613:	8b 45 08             	mov    0x8(%ebp),%eax
  105616:	8d 50 01             	lea    0x1(%eax),%edx
  105619:	89 55 08             	mov    %edx,0x8(%ebp)
  10561c:	0f b6 00             	movzbl (%eax),%eax
  10561f:	84 c0                	test   %al,%al
  105621:	75 e5                	jne    105608 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105623:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105626:	c9                   	leave  
  105627:	c3                   	ret    

00105628 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105628:	55                   	push   %ebp
  105629:	89 e5                	mov    %esp,%ebp
  10562b:	57                   	push   %edi
  10562c:	56                   	push   %esi
  10562d:	83 ec 20             	sub    $0x20,%esp
  105630:	8b 45 08             	mov    0x8(%ebp),%eax
  105633:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105636:	8b 45 0c             	mov    0xc(%ebp),%eax
  105639:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  10563c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105642:	89 d1                	mov    %edx,%ecx
  105644:	89 c2                	mov    %eax,%edx
  105646:	89 ce                	mov    %ecx,%esi
  105648:	89 d7                	mov    %edx,%edi
  10564a:	ac                   	lods   %ds:(%esi),%al
  10564b:	aa                   	stos   %al,%es:(%edi)
  10564c:	84 c0                	test   %al,%al
  10564e:	75 fa                	jne    10564a <strcpy+0x22>
  105650:	89 fa                	mov    %edi,%edx
  105652:	89 f1                	mov    %esi,%ecx
  105654:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105657:	89 55 e8             	mov    %edx,-0x18(%ebp)
  10565a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  10565d:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  105660:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105661:	83 c4 20             	add    $0x20,%esp
  105664:	5e                   	pop    %esi
  105665:	5f                   	pop    %edi
  105666:	5d                   	pop    %ebp
  105667:	c3                   	ret    

00105668 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105668:	55                   	push   %ebp
  105669:	89 e5                	mov    %esp,%ebp
  10566b:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  10566e:	8b 45 08             	mov    0x8(%ebp),%eax
  105671:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105674:	eb 1e                	jmp    105694 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  105676:	8b 45 0c             	mov    0xc(%ebp),%eax
  105679:	0f b6 10             	movzbl (%eax),%edx
  10567c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10567f:	88 10                	mov    %dl,(%eax)
  105681:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105684:	0f b6 00             	movzbl (%eax),%eax
  105687:	84 c0                	test   %al,%al
  105689:	74 03                	je     10568e <strncpy+0x26>
            src ++;
  10568b:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  10568e:	ff 45 fc             	incl   -0x4(%ebp)
  105691:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105694:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105698:	75 dc                	jne    105676 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  10569a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10569d:	c9                   	leave  
  10569e:	c3                   	ret    

0010569f <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10569f:	55                   	push   %ebp
  1056a0:	89 e5                	mov    %esp,%ebp
  1056a2:	57                   	push   %edi
  1056a3:	56                   	push   %esi
  1056a4:	83 ec 20             	sub    $0x20,%esp
  1056a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1056aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1056ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  1056b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1056b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056b9:	89 d1                	mov    %edx,%ecx
  1056bb:	89 c2                	mov    %eax,%edx
  1056bd:	89 ce                	mov    %ecx,%esi
  1056bf:	89 d7                	mov    %edx,%edi
  1056c1:	ac                   	lods   %ds:(%esi),%al
  1056c2:	ae                   	scas   %es:(%edi),%al
  1056c3:	75 08                	jne    1056cd <strcmp+0x2e>
  1056c5:	84 c0                	test   %al,%al
  1056c7:	75 f8                	jne    1056c1 <strcmp+0x22>
  1056c9:	31 c0                	xor    %eax,%eax
  1056cb:	eb 04                	jmp    1056d1 <strcmp+0x32>
  1056cd:	19 c0                	sbb    %eax,%eax
  1056cf:	0c 01                	or     $0x1,%al
  1056d1:	89 fa                	mov    %edi,%edx
  1056d3:	89 f1                	mov    %esi,%ecx
  1056d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1056d8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1056db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  1056de:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  1056e1:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1056e2:	83 c4 20             	add    $0x20,%esp
  1056e5:	5e                   	pop    %esi
  1056e6:	5f                   	pop    %edi
  1056e7:	5d                   	pop    %ebp
  1056e8:	c3                   	ret    

001056e9 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1056e9:	55                   	push   %ebp
  1056ea:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1056ec:	eb 09                	jmp    1056f7 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  1056ee:	ff 4d 10             	decl   0x10(%ebp)
  1056f1:	ff 45 08             	incl   0x8(%ebp)
  1056f4:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1056f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1056fb:	74 1a                	je     105717 <strncmp+0x2e>
  1056fd:	8b 45 08             	mov    0x8(%ebp),%eax
  105700:	0f b6 00             	movzbl (%eax),%eax
  105703:	84 c0                	test   %al,%al
  105705:	74 10                	je     105717 <strncmp+0x2e>
  105707:	8b 45 08             	mov    0x8(%ebp),%eax
  10570a:	0f b6 10             	movzbl (%eax),%edx
  10570d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105710:	0f b6 00             	movzbl (%eax),%eax
  105713:	38 c2                	cmp    %al,%dl
  105715:	74 d7                	je     1056ee <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105717:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10571b:	74 18                	je     105735 <strncmp+0x4c>
  10571d:	8b 45 08             	mov    0x8(%ebp),%eax
  105720:	0f b6 00             	movzbl (%eax),%eax
  105723:	0f b6 d0             	movzbl %al,%edx
  105726:	8b 45 0c             	mov    0xc(%ebp),%eax
  105729:	0f b6 00             	movzbl (%eax),%eax
  10572c:	0f b6 c0             	movzbl %al,%eax
  10572f:	29 c2                	sub    %eax,%edx
  105731:	89 d0                	mov    %edx,%eax
  105733:	eb 05                	jmp    10573a <strncmp+0x51>
  105735:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10573a:	5d                   	pop    %ebp
  10573b:	c3                   	ret    

0010573c <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  10573c:	55                   	push   %ebp
  10573d:	89 e5                	mov    %esp,%ebp
  10573f:	83 ec 04             	sub    $0x4,%esp
  105742:	8b 45 0c             	mov    0xc(%ebp),%eax
  105745:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105748:	eb 13                	jmp    10575d <strchr+0x21>
        if (*s == c) {
  10574a:	8b 45 08             	mov    0x8(%ebp),%eax
  10574d:	0f b6 00             	movzbl (%eax),%eax
  105750:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105753:	75 05                	jne    10575a <strchr+0x1e>
            return (char *)s;
  105755:	8b 45 08             	mov    0x8(%ebp),%eax
  105758:	eb 12                	jmp    10576c <strchr+0x30>
        }
        s ++;
  10575a:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  10575d:	8b 45 08             	mov    0x8(%ebp),%eax
  105760:	0f b6 00             	movzbl (%eax),%eax
  105763:	84 c0                	test   %al,%al
  105765:	75 e3                	jne    10574a <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105767:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10576c:	c9                   	leave  
  10576d:	c3                   	ret    

0010576e <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  10576e:	55                   	push   %ebp
  10576f:	89 e5                	mov    %esp,%ebp
  105771:	83 ec 04             	sub    $0x4,%esp
  105774:	8b 45 0c             	mov    0xc(%ebp),%eax
  105777:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10577a:	eb 0e                	jmp    10578a <strfind+0x1c>
        if (*s == c) {
  10577c:	8b 45 08             	mov    0x8(%ebp),%eax
  10577f:	0f b6 00             	movzbl (%eax),%eax
  105782:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105785:	74 0f                	je     105796 <strfind+0x28>
            break;
        }
        s ++;
  105787:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  10578a:	8b 45 08             	mov    0x8(%ebp),%eax
  10578d:	0f b6 00             	movzbl (%eax),%eax
  105790:	84 c0                	test   %al,%al
  105792:	75 e8                	jne    10577c <strfind+0xe>
  105794:	eb 01                	jmp    105797 <strfind+0x29>
        if (*s == c) {
            break;
  105796:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  105797:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10579a:	c9                   	leave  
  10579b:	c3                   	ret    

0010579c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  10579c:	55                   	push   %ebp
  10579d:	89 e5                	mov    %esp,%ebp
  10579f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1057a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1057a9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1057b0:	eb 03                	jmp    1057b5 <strtol+0x19>
        s ++;
  1057b2:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1057b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1057b8:	0f b6 00             	movzbl (%eax),%eax
  1057bb:	3c 20                	cmp    $0x20,%al
  1057bd:	74 f3                	je     1057b2 <strtol+0x16>
  1057bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1057c2:	0f b6 00             	movzbl (%eax),%eax
  1057c5:	3c 09                	cmp    $0x9,%al
  1057c7:	74 e9                	je     1057b2 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  1057c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1057cc:	0f b6 00             	movzbl (%eax),%eax
  1057cf:	3c 2b                	cmp    $0x2b,%al
  1057d1:	75 05                	jne    1057d8 <strtol+0x3c>
        s ++;
  1057d3:	ff 45 08             	incl   0x8(%ebp)
  1057d6:	eb 14                	jmp    1057ec <strtol+0x50>
    }
    else if (*s == '-') {
  1057d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1057db:	0f b6 00             	movzbl (%eax),%eax
  1057de:	3c 2d                	cmp    $0x2d,%al
  1057e0:	75 0a                	jne    1057ec <strtol+0x50>
        s ++, neg = 1;
  1057e2:	ff 45 08             	incl   0x8(%ebp)
  1057e5:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1057ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1057f0:	74 06                	je     1057f8 <strtol+0x5c>
  1057f2:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1057f6:	75 22                	jne    10581a <strtol+0x7e>
  1057f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1057fb:	0f b6 00             	movzbl (%eax),%eax
  1057fe:	3c 30                	cmp    $0x30,%al
  105800:	75 18                	jne    10581a <strtol+0x7e>
  105802:	8b 45 08             	mov    0x8(%ebp),%eax
  105805:	40                   	inc    %eax
  105806:	0f b6 00             	movzbl (%eax),%eax
  105809:	3c 78                	cmp    $0x78,%al
  10580b:	75 0d                	jne    10581a <strtol+0x7e>
        s += 2, base = 16;
  10580d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105811:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105818:	eb 29                	jmp    105843 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  10581a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10581e:	75 16                	jne    105836 <strtol+0x9a>
  105820:	8b 45 08             	mov    0x8(%ebp),%eax
  105823:	0f b6 00             	movzbl (%eax),%eax
  105826:	3c 30                	cmp    $0x30,%al
  105828:	75 0c                	jne    105836 <strtol+0x9a>
        s ++, base = 8;
  10582a:	ff 45 08             	incl   0x8(%ebp)
  10582d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105834:	eb 0d                	jmp    105843 <strtol+0xa7>
    }
    else if (base == 0) {
  105836:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10583a:	75 07                	jne    105843 <strtol+0xa7>
        base = 10;
  10583c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105843:	8b 45 08             	mov    0x8(%ebp),%eax
  105846:	0f b6 00             	movzbl (%eax),%eax
  105849:	3c 2f                	cmp    $0x2f,%al
  10584b:	7e 1b                	jle    105868 <strtol+0xcc>
  10584d:	8b 45 08             	mov    0x8(%ebp),%eax
  105850:	0f b6 00             	movzbl (%eax),%eax
  105853:	3c 39                	cmp    $0x39,%al
  105855:	7f 11                	jg     105868 <strtol+0xcc>
            dig = *s - '0';
  105857:	8b 45 08             	mov    0x8(%ebp),%eax
  10585a:	0f b6 00             	movzbl (%eax),%eax
  10585d:	0f be c0             	movsbl %al,%eax
  105860:	83 e8 30             	sub    $0x30,%eax
  105863:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105866:	eb 48                	jmp    1058b0 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105868:	8b 45 08             	mov    0x8(%ebp),%eax
  10586b:	0f b6 00             	movzbl (%eax),%eax
  10586e:	3c 60                	cmp    $0x60,%al
  105870:	7e 1b                	jle    10588d <strtol+0xf1>
  105872:	8b 45 08             	mov    0x8(%ebp),%eax
  105875:	0f b6 00             	movzbl (%eax),%eax
  105878:	3c 7a                	cmp    $0x7a,%al
  10587a:	7f 11                	jg     10588d <strtol+0xf1>
            dig = *s - 'a' + 10;
  10587c:	8b 45 08             	mov    0x8(%ebp),%eax
  10587f:	0f b6 00             	movzbl (%eax),%eax
  105882:	0f be c0             	movsbl %al,%eax
  105885:	83 e8 57             	sub    $0x57,%eax
  105888:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10588b:	eb 23                	jmp    1058b0 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10588d:	8b 45 08             	mov    0x8(%ebp),%eax
  105890:	0f b6 00             	movzbl (%eax),%eax
  105893:	3c 40                	cmp    $0x40,%al
  105895:	7e 3b                	jle    1058d2 <strtol+0x136>
  105897:	8b 45 08             	mov    0x8(%ebp),%eax
  10589a:	0f b6 00             	movzbl (%eax),%eax
  10589d:	3c 5a                	cmp    $0x5a,%al
  10589f:	7f 31                	jg     1058d2 <strtol+0x136>
            dig = *s - 'A' + 10;
  1058a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1058a4:	0f b6 00             	movzbl (%eax),%eax
  1058a7:	0f be c0             	movsbl %al,%eax
  1058aa:	83 e8 37             	sub    $0x37,%eax
  1058ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1058b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1058b3:	3b 45 10             	cmp    0x10(%ebp),%eax
  1058b6:	7d 19                	jge    1058d1 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  1058b8:	ff 45 08             	incl   0x8(%ebp)
  1058bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1058be:	0f af 45 10          	imul   0x10(%ebp),%eax
  1058c2:	89 c2                	mov    %eax,%edx
  1058c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1058c7:	01 d0                	add    %edx,%eax
  1058c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  1058cc:	e9 72 ff ff ff       	jmp    105843 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  1058d1:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  1058d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1058d6:	74 08                	je     1058e0 <strtol+0x144>
        *endptr = (char *) s;
  1058d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058db:	8b 55 08             	mov    0x8(%ebp),%edx
  1058de:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1058e0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1058e4:	74 07                	je     1058ed <strtol+0x151>
  1058e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1058e9:	f7 d8                	neg    %eax
  1058eb:	eb 03                	jmp    1058f0 <strtol+0x154>
  1058ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1058f0:	c9                   	leave  
  1058f1:	c3                   	ret    

001058f2 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1058f2:	55                   	push   %ebp
  1058f3:	89 e5                	mov    %esp,%ebp
  1058f5:	57                   	push   %edi
  1058f6:	83 ec 24             	sub    $0x24,%esp
  1058f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058fc:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1058ff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105903:	8b 55 08             	mov    0x8(%ebp),%edx
  105906:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105909:	88 45 f7             	mov    %al,-0x9(%ebp)
  10590c:	8b 45 10             	mov    0x10(%ebp),%eax
  10590f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105912:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105915:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105919:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10591c:	89 d7                	mov    %edx,%edi
  10591e:	f3 aa                	rep stos %al,%es:(%edi)
  105920:	89 fa                	mov    %edi,%edx
  105922:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105925:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105928:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10592b:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  10592c:	83 c4 24             	add    $0x24,%esp
  10592f:	5f                   	pop    %edi
  105930:	5d                   	pop    %ebp
  105931:	c3                   	ret    

00105932 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105932:	55                   	push   %ebp
  105933:	89 e5                	mov    %esp,%ebp
  105935:	57                   	push   %edi
  105936:	56                   	push   %esi
  105937:	53                   	push   %ebx
  105938:	83 ec 30             	sub    $0x30,%esp
  10593b:	8b 45 08             	mov    0x8(%ebp),%eax
  10593e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105941:	8b 45 0c             	mov    0xc(%ebp),%eax
  105944:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105947:	8b 45 10             	mov    0x10(%ebp),%eax
  10594a:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  10594d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105950:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105953:	73 42                	jae    105997 <memmove+0x65>
  105955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105958:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10595b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10595e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105961:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105964:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105967:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10596a:	c1 e8 02             	shr    $0x2,%eax
  10596d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  10596f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105972:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105975:	89 d7                	mov    %edx,%edi
  105977:	89 c6                	mov    %eax,%esi
  105979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10597b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10597e:	83 e1 03             	and    $0x3,%ecx
  105981:	74 02                	je     105985 <memmove+0x53>
  105983:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105985:	89 f0                	mov    %esi,%eax
  105987:	89 fa                	mov    %edi,%edx
  105989:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  10598c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10598f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  105995:	eb 36                	jmp    1059cd <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105997:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10599a:	8d 50 ff             	lea    -0x1(%eax),%edx
  10599d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059a0:	01 c2                	add    %eax,%edx
  1059a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059a5:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1059a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059ab:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  1059ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059b1:	89 c1                	mov    %eax,%ecx
  1059b3:	89 d8                	mov    %ebx,%eax
  1059b5:	89 d6                	mov    %edx,%esi
  1059b7:	89 c7                	mov    %eax,%edi
  1059b9:	fd                   	std    
  1059ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1059bc:	fc                   	cld    
  1059bd:	89 f8                	mov    %edi,%eax
  1059bf:	89 f2                	mov    %esi,%edx
  1059c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1059c4:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1059c7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  1059ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1059cd:	83 c4 30             	add    $0x30,%esp
  1059d0:	5b                   	pop    %ebx
  1059d1:	5e                   	pop    %esi
  1059d2:	5f                   	pop    %edi
  1059d3:	5d                   	pop    %ebp
  1059d4:	c3                   	ret    

001059d5 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1059d5:	55                   	push   %ebp
  1059d6:	89 e5                	mov    %esp,%ebp
  1059d8:	57                   	push   %edi
  1059d9:	56                   	push   %esi
  1059da:	83 ec 20             	sub    $0x20,%esp
  1059dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1059e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1059e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059e9:	8b 45 10             	mov    0x10(%ebp),%eax
  1059ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1059ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059f2:	c1 e8 02             	shr    $0x2,%eax
  1059f5:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  1059f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059fd:	89 d7                	mov    %edx,%edi
  1059ff:	89 c6                	mov    %eax,%esi
  105a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105a03:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105a06:	83 e1 03             	and    $0x3,%ecx
  105a09:	74 02                	je     105a0d <memcpy+0x38>
  105a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105a0d:	89 f0                	mov    %esi,%eax
  105a0f:	89 fa                	mov    %edi,%edx
  105a11:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105a14:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105a17:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  105a1d:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105a1e:	83 c4 20             	add    $0x20,%esp
  105a21:	5e                   	pop    %esi
  105a22:	5f                   	pop    %edi
  105a23:	5d                   	pop    %ebp
  105a24:	c3                   	ret    

00105a25 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105a25:	55                   	push   %ebp
  105a26:	89 e5                	mov    %esp,%ebp
  105a28:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a34:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105a37:	eb 2e                	jmp    105a67 <memcmp+0x42>
        if (*s1 != *s2) {
  105a39:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a3c:	0f b6 10             	movzbl (%eax),%edx
  105a3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105a42:	0f b6 00             	movzbl (%eax),%eax
  105a45:	38 c2                	cmp    %al,%dl
  105a47:	74 18                	je     105a61 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a4c:	0f b6 00             	movzbl (%eax),%eax
  105a4f:	0f b6 d0             	movzbl %al,%edx
  105a52:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105a55:	0f b6 00             	movzbl (%eax),%eax
  105a58:	0f b6 c0             	movzbl %al,%eax
  105a5b:	29 c2                	sub    %eax,%edx
  105a5d:	89 d0                	mov    %edx,%eax
  105a5f:	eb 18                	jmp    105a79 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  105a61:	ff 45 fc             	incl   -0x4(%ebp)
  105a64:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105a67:	8b 45 10             	mov    0x10(%ebp),%eax
  105a6a:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a6d:	89 55 10             	mov    %edx,0x10(%ebp)
  105a70:	85 c0                	test   %eax,%eax
  105a72:	75 c5                	jne    105a39 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105a79:	c9                   	leave  
  105a7a:	c3                   	ret    

00105a7b <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105a7b:	55                   	push   %ebp
  105a7c:	89 e5                	mov    %esp,%ebp
  105a7e:	83 ec 58             	sub    $0x58,%esp
  105a81:	8b 45 10             	mov    0x10(%ebp),%eax
  105a84:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105a87:	8b 45 14             	mov    0x14(%ebp),%eax
  105a8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105a8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105a90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105a93:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105a96:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105a99:	8b 45 18             	mov    0x18(%ebp),%eax
  105a9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105a9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105aa2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105aa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105aa8:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ab1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105ab5:	74 1c                	je     105ad3 <printnum+0x58>
  105ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105aba:	ba 00 00 00 00       	mov    $0x0,%edx
  105abf:	f7 75 e4             	divl   -0x1c(%ebp)
  105ac2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  105acd:	f7 75 e4             	divl   -0x1c(%ebp)
  105ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ad3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ad6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ad9:	f7 75 e4             	divl   -0x1c(%ebp)
  105adc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105adf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105ae2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ae5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105ae8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105aeb:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105aee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105af1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105af4:	8b 45 18             	mov    0x18(%ebp),%eax
  105af7:	ba 00 00 00 00       	mov    $0x0,%edx
  105afc:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105aff:	77 56                	ja     105b57 <printnum+0xdc>
  105b01:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105b04:	72 05                	jb     105b0b <printnum+0x90>
  105b06:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105b09:	77 4c                	ja     105b57 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105b0b:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105b0e:	8d 50 ff             	lea    -0x1(%eax),%edx
  105b11:	8b 45 20             	mov    0x20(%ebp),%eax
  105b14:	89 44 24 18          	mov    %eax,0x18(%esp)
  105b18:	89 54 24 14          	mov    %edx,0x14(%esp)
  105b1c:	8b 45 18             	mov    0x18(%ebp),%eax
  105b1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  105b23:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105b26:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105b29:	89 44 24 08          	mov    %eax,0x8(%esp)
  105b2d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b38:	8b 45 08             	mov    0x8(%ebp),%eax
  105b3b:	89 04 24             	mov    %eax,(%esp)
  105b3e:	e8 38 ff ff ff       	call   105a7b <printnum>
  105b43:	eb 1b                	jmp    105b60 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b4c:	8b 45 20             	mov    0x20(%ebp),%eax
  105b4f:	89 04 24             	mov    %eax,(%esp)
  105b52:	8b 45 08             	mov    0x8(%ebp),%eax
  105b55:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  105b57:	ff 4d 1c             	decl   0x1c(%ebp)
  105b5a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105b5e:	7f e5                	jg     105b45 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105b60:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105b63:	05 a4 72 10 00       	add    $0x1072a4,%eax
  105b68:	0f b6 00             	movzbl (%eax),%eax
  105b6b:	0f be c0             	movsbl %al,%eax
  105b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  105b71:	89 54 24 04          	mov    %edx,0x4(%esp)
  105b75:	89 04 24             	mov    %eax,(%esp)
  105b78:	8b 45 08             	mov    0x8(%ebp),%eax
  105b7b:	ff d0                	call   *%eax
}
  105b7d:	90                   	nop
  105b7e:	c9                   	leave  
  105b7f:	c3                   	ret    

00105b80 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105b80:	55                   	push   %ebp
  105b81:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105b83:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105b87:	7e 14                	jle    105b9d <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105b89:	8b 45 08             	mov    0x8(%ebp),%eax
  105b8c:	8b 00                	mov    (%eax),%eax
  105b8e:	8d 48 08             	lea    0x8(%eax),%ecx
  105b91:	8b 55 08             	mov    0x8(%ebp),%edx
  105b94:	89 0a                	mov    %ecx,(%edx)
  105b96:	8b 50 04             	mov    0x4(%eax),%edx
  105b99:	8b 00                	mov    (%eax),%eax
  105b9b:	eb 30                	jmp    105bcd <getuint+0x4d>
    }
    else if (lflag) {
  105b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105ba1:	74 16                	je     105bb9 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ba6:	8b 00                	mov    (%eax),%eax
  105ba8:	8d 48 04             	lea    0x4(%eax),%ecx
  105bab:	8b 55 08             	mov    0x8(%ebp),%edx
  105bae:	89 0a                	mov    %ecx,(%edx)
  105bb0:	8b 00                	mov    (%eax),%eax
  105bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  105bb7:	eb 14                	jmp    105bcd <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  105bbc:	8b 00                	mov    (%eax),%eax
  105bbe:	8d 48 04             	lea    0x4(%eax),%ecx
  105bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  105bc4:	89 0a                	mov    %ecx,(%edx)
  105bc6:	8b 00                	mov    (%eax),%eax
  105bc8:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105bcd:	5d                   	pop    %ebp
  105bce:	c3                   	ret    

00105bcf <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105bcf:	55                   	push   %ebp
  105bd0:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105bd2:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105bd6:	7e 14                	jle    105bec <getint+0x1d>
        return va_arg(*ap, long long);
  105bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  105bdb:	8b 00                	mov    (%eax),%eax
  105bdd:	8d 48 08             	lea    0x8(%eax),%ecx
  105be0:	8b 55 08             	mov    0x8(%ebp),%edx
  105be3:	89 0a                	mov    %ecx,(%edx)
  105be5:	8b 50 04             	mov    0x4(%eax),%edx
  105be8:	8b 00                	mov    (%eax),%eax
  105bea:	eb 28                	jmp    105c14 <getint+0x45>
    }
    else if (lflag) {
  105bec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105bf0:	74 12                	je     105c04 <getint+0x35>
        return va_arg(*ap, long);
  105bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  105bf5:	8b 00                	mov    (%eax),%eax
  105bf7:	8d 48 04             	lea    0x4(%eax),%ecx
  105bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  105bfd:	89 0a                	mov    %ecx,(%edx)
  105bff:	8b 00                	mov    (%eax),%eax
  105c01:	99                   	cltd   
  105c02:	eb 10                	jmp    105c14 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105c04:	8b 45 08             	mov    0x8(%ebp),%eax
  105c07:	8b 00                	mov    (%eax),%eax
  105c09:	8d 48 04             	lea    0x4(%eax),%ecx
  105c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  105c0f:	89 0a                	mov    %ecx,(%edx)
  105c11:	8b 00                	mov    (%eax),%eax
  105c13:	99                   	cltd   
    }
}
  105c14:	5d                   	pop    %ebp
  105c15:	c3                   	ret    

00105c16 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105c16:	55                   	push   %ebp
  105c17:	89 e5                	mov    %esp,%ebp
  105c19:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105c1c:	8d 45 14             	lea    0x14(%ebp),%eax
  105c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105c29:	8b 45 10             	mov    0x10(%ebp),%eax
  105c2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c37:	8b 45 08             	mov    0x8(%ebp),%eax
  105c3a:	89 04 24             	mov    %eax,(%esp)
  105c3d:	e8 03 00 00 00       	call   105c45 <vprintfmt>
    va_end(ap);
}
  105c42:	90                   	nop
  105c43:	c9                   	leave  
  105c44:	c3                   	ret    

00105c45 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105c45:	55                   	push   %ebp
  105c46:	89 e5                	mov    %esp,%ebp
  105c48:	56                   	push   %esi
  105c49:	53                   	push   %ebx
  105c4a:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105c4d:	eb 17                	jmp    105c66 <vprintfmt+0x21>
            if (ch == '\0') {
  105c4f:	85 db                	test   %ebx,%ebx
  105c51:	0f 84 bf 03 00 00    	je     106016 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c5e:	89 1c 24             	mov    %ebx,(%esp)
  105c61:	8b 45 08             	mov    0x8(%ebp),%eax
  105c64:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105c66:	8b 45 10             	mov    0x10(%ebp),%eax
  105c69:	8d 50 01             	lea    0x1(%eax),%edx
  105c6c:	89 55 10             	mov    %edx,0x10(%ebp)
  105c6f:	0f b6 00             	movzbl (%eax),%eax
  105c72:	0f b6 d8             	movzbl %al,%ebx
  105c75:	83 fb 25             	cmp    $0x25,%ebx
  105c78:	75 d5                	jne    105c4f <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  105c7a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105c7e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c88:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105c8b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105c92:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105c95:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105c98:	8b 45 10             	mov    0x10(%ebp),%eax
  105c9b:	8d 50 01             	lea    0x1(%eax),%edx
  105c9e:	89 55 10             	mov    %edx,0x10(%ebp)
  105ca1:	0f b6 00             	movzbl (%eax),%eax
  105ca4:	0f b6 d8             	movzbl %al,%ebx
  105ca7:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105caa:	83 f8 55             	cmp    $0x55,%eax
  105cad:	0f 87 37 03 00 00    	ja     105fea <vprintfmt+0x3a5>
  105cb3:	8b 04 85 c8 72 10 00 	mov    0x1072c8(,%eax,4),%eax
  105cba:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105cbc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105cc0:	eb d6                	jmp    105c98 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105cc2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105cc6:	eb d0                	jmp    105c98 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105cc8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105ccf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105cd2:	89 d0                	mov    %edx,%eax
  105cd4:	c1 e0 02             	shl    $0x2,%eax
  105cd7:	01 d0                	add    %edx,%eax
  105cd9:	01 c0                	add    %eax,%eax
  105cdb:	01 d8                	add    %ebx,%eax
  105cdd:	83 e8 30             	sub    $0x30,%eax
  105ce0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105ce3:	8b 45 10             	mov    0x10(%ebp),%eax
  105ce6:	0f b6 00             	movzbl (%eax),%eax
  105ce9:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105cec:	83 fb 2f             	cmp    $0x2f,%ebx
  105cef:	7e 38                	jle    105d29 <vprintfmt+0xe4>
  105cf1:	83 fb 39             	cmp    $0x39,%ebx
  105cf4:	7f 33                	jg     105d29 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105cf6:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  105cf9:	eb d4                	jmp    105ccf <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105cfb:	8b 45 14             	mov    0x14(%ebp),%eax
  105cfe:	8d 50 04             	lea    0x4(%eax),%edx
  105d01:	89 55 14             	mov    %edx,0x14(%ebp)
  105d04:	8b 00                	mov    (%eax),%eax
  105d06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105d09:	eb 1f                	jmp    105d2a <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105d0b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d0f:	79 87                	jns    105c98 <vprintfmt+0x53>
                width = 0;
  105d11:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105d18:	e9 7b ff ff ff       	jmp    105c98 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105d1d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105d24:	e9 6f ff ff ff       	jmp    105c98 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  105d29:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  105d2a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d2e:	0f 89 64 ff ff ff    	jns    105c98 <vprintfmt+0x53>
                width = precision, precision = -1;
  105d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105d37:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105d3a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105d41:	e9 52 ff ff ff       	jmp    105c98 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105d46:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105d49:	e9 4a ff ff ff       	jmp    105c98 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105d4e:	8b 45 14             	mov    0x14(%ebp),%eax
  105d51:	8d 50 04             	lea    0x4(%eax),%edx
  105d54:	89 55 14             	mov    %edx,0x14(%ebp)
  105d57:	8b 00                	mov    (%eax),%eax
  105d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  105d5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  105d60:	89 04 24             	mov    %eax,(%esp)
  105d63:	8b 45 08             	mov    0x8(%ebp),%eax
  105d66:	ff d0                	call   *%eax
            break;
  105d68:	e9 a4 02 00 00       	jmp    106011 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105d6d:	8b 45 14             	mov    0x14(%ebp),%eax
  105d70:	8d 50 04             	lea    0x4(%eax),%edx
  105d73:	89 55 14             	mov    %edx,0x14(%ebp)
  105d76:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105d78:	85 db                	test   %ebx,%ebx
  105d7a:	79 02                	jns    105d7e <vprintfmt+0x139>
                err = -err;
  105d7c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105d7e:	83 fb 06             	cmp    $0x6,%ebx
  105d81:	7f 0b                	jg     105d8e <vprintfmt+0x149>
  105d83:	8b 34 9d 88 72 10 00 	mov    0x107288(,%ebx,4),%esi
  105d8a:	85 f6                	test   %esi,%esi
  105d8c:	75 23                	jne    105db1 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105d8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105d92:	c7 44 24 08 b5 72 10 	movl   $0x1072b5,0x8(%esp)
  105d99:	00 
  105d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105da1:	8b 45 08             	mov    0x8(%ebp),%eax
  105da4:	89 04 24             	mov    %eax,(%esp)
  105da7:	e8 6a fe ff ff       	call   105c16 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105dac:	e9 60 02 00 00       	jmp    106011 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  105db1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105db5:	c7 44 24 08 be 72 10 	movl   $0x1072be,0x8(%esp)
  105dbc:	00 
  105dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  105dc7:	89 04 24             	mov    %eax,(%esp)
  105dca:	e8 47 fe ff ff       	call   105c16 <printfmt>
            }
            break;
  105dcf:	e9 3d 02 00 00       	jmp    106011 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105dd4:	8b 45 14             	mov    0x14(%ebp),%eax
  105dd7:	8d 50 04             	lea    0x4(%eax),%edx
  105dda:	89 55 14             	mov    %edx,0x14(%ebp)
  105ddd:	8b 30                	mov    (%eax),%esi
  105ddf:	85 f6                	test   %esi,%esi
  105de1:	75 05                	jne    105de8 <vprintfmt+0x1a3>
                p = "(null)";
  105de3:	be c1 72 10 00       	mov    $0x1072c1,%esi
            }
            if (width > 0 && padc != '-') {
  105de8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105dec:	7e 76                	jle    105e64 <vprintfmt+0x21f>
  105dee:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105df2:	74 70                	je     105e64 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dfb:	89 34 24             	mov    %esi,(%esp)
  105dfe:	e8 f6 f7 ff ff       	call   1055f9 <strnlen>
  105e03:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105e06:	29 c2                	sub    %eax,%edx
  105e08:	89 d0                	mov    %edx,%eax
  105e0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105e0d:	eb 16                	jmp    105e25 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105e0f:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105e13:	8b 55 0c             	mov    0xc(%ebp),%edx
  105e16:	89 54 24 04          	mov    %edx,0x4(%esp)
  105e1a:	89 04 24             	mov    %eax,(%esp)
  105e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  105e20:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  105e22:	ff 4d e8             	decl   -0x18(%ebp)
  105e25:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105e29:	7f e4                	jg     105e0f <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105e2b:	eb 37                	jmp    105e64 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105e2d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105e31:	74 1f                	je     105e52 <vprintfmt+0x20d>
  105e33:	83 fb 1f             	cmp    $0x1f,%ebx
  105e36:	7e 05                	jle    105e3d <vprintfmt+0x1f8>
  105e38:	83 fb 7e             	cmp    $0x7e,%ebx
  105e3b:	7e 15                	jle    105e52 <vprintfmt+0x20d>
                    putch('?', putdat);
  105e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e44:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  105e4e:	ff d0                	call   *%eax
  105e50:	eb 0f                	jmp    105e61 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e55:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e59:	89 1c 24             	mov    %ebx,(%esp)
  105e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  105e5f:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105e61:	ff 4d e8             	decl   -0x18(%ebp)
  105e64:	89 f0                	mov    %esi,%eax
  105e66:	8d 70 01             	lea    0x1(%eax),%esi
  105e69:	0f b6 00             	movzbl (%eax),%eax
  105e6c:	0f be d8             	movsbl %al,%ebx
  105e6f:	85 db                	test   %ebx,%ebx
  105e71:	74 27                	je     105e9a <vprintfmt+0x255>
  105e73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105e77:	78 b4                	js     105e2d <vprintfmt+0x1e8>
  105e79:	ff 4d e4             	decl   -0x1c(%ebp)
  105e7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105e80:	79 ab                	jns    105e2d <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105e82:	eb 16                	jmp    105e9a <vprintfmt+0x255>
                putch(' ', putdat);
  105e84:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e87:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e8b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105e92:	8b 45 08             	mov    0x8(%ebp),%eax
  105e95:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105e97:	ff 4d e8             	decl   -0x18(%ebp)
  105e9a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105e9e:	7f e4                	jg     105e84 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
  105ea0:	e9 6c 01 00 00       	jmp    106011 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105ea5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105eac:	8d 45 14             	lea    0x14(%ebp),%eax
  105eaf:	89 04 24             	mov    %eax,(%esp)
  105eb2:	e8 18 fd ff ff       	call   105bcf <getint>
  105eb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105eba:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ec0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ec3:	85 d2                	test   %edx,%edx
  105ec5:	79 26                	jns    105eed <vprintfmt+0x2a8>
                putch('-', putdat);
  105ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eca:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ece:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ed8:	ff d0                	call   *%eax
                num = -(long long)num;
  105eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105edd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ee0:	f7 d8                	neg    %eax
  105ee2:	83 d2 00             	adc    $0x0,%edx
  105ee5:	f7 da                	neg    %edx
  105ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105eea:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105eed:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105ef4:	e9 a8 00 00 00       	jmp    105fa1 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105efc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f00:	8d 45 14             	lea    0x14(%ebp),%eax
  105f03:	89 04 24             	mov    %eax,(%esp)
  105f06:	e8 75 fc ff ff       	call   105b80 <getuint>
  105f0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f0e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105f11:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105f18:	e9 84 00 00 00       	jmp    105fa1 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105f1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f20:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f24:	8d 45 14             	lea    0x14(%ebp),%eax
  105f27:	89 04 24             	mov    %eax,(%esp)
  105f2a:	e8 51 fc ff ff       	call   105b80 <getuint>
  105f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f32:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105f35:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105f3c:	eb 63                	jmp    105fa1 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f41:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f45:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  105f4f:	ff d0                	call   *%eax
            putch('x', putdat);
  105f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f58:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  105f62:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105f64:	8b 45 14             	mov    0x14(%ebp),%eax
  105f67:	8d 50 04             	lea    0x4(%eax),%edx
  105f6a:	89 55 14             	mov    %edx,0x14(%ebp)
  105f6d:	8b 00                	mov    (%eax),%eax
  105f6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105f79:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105f80:	eb 1f                	jmp    105fa1 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105f82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f85:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f89:	8d 45 14             	lea    0x14(%ebp),%eax
  105f8c:	89 04 24             	mov    %eax,(%esp)
  105f8f:	e8 ec fb ff ff       	call   105b80 <getuint>
  105f94:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f97:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105f9a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105fa1:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105fa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105fa8:	89 54 24 18          	mov    %edx,0x18(%esp)
  105fac:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105faf:	89 54 24 14          	mov    %edx,0x14(%esp)
  105fb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  105fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105fba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105fbd:	89 44 24 08          	mov    %eax,0x8(%esp)
  105fc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  105fcf:	89 04 24             	mov    %eax,(%esp)
  105fd2:	e8 a4 fa ff ff       	call   105a7b <printnum>
            break;
  105fd7:	eb 38                	jmp    106011 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fe0:	89 1c 24             	mov    %ebx,(%esp)
  105fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  105fe6:	ff d0                	call   *%eax
            break;
  105fe8:	eb 27                	jmp    106011 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105fea:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fed:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ff1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105ff8:	8b 45 08             	mov    0x8(%ebp),%eax
  105ffb:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105ffd:	ff 4d 10             	decl   0x10(%ebp)
  106000:	eb 03                	jmp    106005 <vprintfmt+0x3c0>
  106002:	ff 4d 10             	decl   0x10(%ebp)
  106005:	8b 45 10             	mov    0x10(%ebp),%eax
  106008:	48                   	dec    %eax
  106009:	0f b6 00             	movzbl (%eax),%eax
  10600c:	3c 25                	cmp    $0x25,%al
  10600e:	75 f2                	jne    106002 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  106010:	90                   	nop
        }
    }
  106011:	e9 37 fc ff ff       	jmp    105c4d <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  106016:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  106017:	83 c4 40             	add    $0x40,%esp
  10601a:	5b                   	pop    %ebx
  10601b:	5e                   	pop    %esi
  10601c:	5d                   	pop    %ebp
  10601d:	c3                   	ret    

0010601e <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  10601e:	55                   	push   %ebp
  10601f:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106021:	8b 45 0c             	mov    0xc(%ebp),%eax
  106024:	8b 40 08             	mov    0x8(%eax),%eax
  106027:	8d 50 01             	lea    0x1(%eax),%edx
  10602a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10602d:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106030:	8b 45 0c             	mov    0xc(%ebp),%eax
  106033:	8b 10                	mov    (%eax),%edx
  106035:	8b 45 0c             	mov    0xc(%ebp),%eax
  106038:	8b 40 04             	mov    0x4(%eax),%eax
  10603b:	39 c2                	cmp    %eax,%edx
  10603d:	73 12                	jae    106051 <sprintputch+0x33>
        *b->buf ++ = ch;
  10603f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106042:	8b 00                	mov    (%eax),%eax
  106044:	8d 48 01             	lea    0x1(%eax),%ecx
  106047:	8b 55 0c             	mov    0xc(%ebp),%edx
  10604a:	89 0a                	mov    %ecx,(%edx)
  10604c:	8b 55 08             	mov    0x8(%ebp),%edx
  10604f:	88 10                	mov    %dl,(%eax)
    }
}
  106051:	90                   	nop
  106052:	5d                   	pop    %ebp
  106053:	c3                   	ret    

00106054 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106054:	55                   	push   %ebp
  106055:	89 e5                	mov    %esp,%ebp
  106057:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10605a:	8d 45 14             	lea    0x14(%ebp),%eax
  10605d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106060:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106067:	8b 45 10             	mov    0x10(%ebp),%eax
  10606a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10606e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106071:	89 44 24 04          	mov    %eax,0x4(%esp)
  106075:	8b 45 08             	mov    0x8(%ebp),%eax
  106078:	89 04 24             	mov    %eax,(%esp)
  10607b:	e8 08 00 00 00       	call   106088 <vsnprintf>
  106080:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106083:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106086:	c9                   	leave  
  106087:	c3                   	ret    

00106088 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106088:	55                   	push   %ebp
  106089:	89 e5                	mov    %esp,%ebp
  10608b:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  10608e:	8b 45 08             	mov    0x8(%ebp),%eax
  106091:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106094:	8b 45 0c             	mov    0xc(%ebp),%eax
  106097:	8d 50 ff             	lea    -0x1(%eax),%edx
  10609a:	8b 45 08             	mov    0x8(%ebp),%eax
  10609d:	01 d0                	add    %edx,%eax
  10609f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1060a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1060a9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1060ad:	74 0a                	je     1060b9 <vsnprintf+0x31>
  1060af:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1060b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060b5:	39 c2                	cmp    %eax,%edx
  1060b7:	76 07                	jbe    1060c0 <vsnprintf+0x38>
        return -E_INVAL;
  1060b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1060be:	eb 2a                	jmp    1060ea <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1060c0:	8b 45 14             	mov    0x14(%ebp),%eax
  1060c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1060c7:	8b 45 10             	mov    0x10(%ebp),%eax
  1060ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  1060ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1060d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1060d5:	c7 04 24 1e 60 10 00 	movl   $0x10601e,(%esp)
  1060dc:	e8 64 fb ff ff       	call   105c45 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1060e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1060e4:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1060e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1060ea:	c9                   	leave  
  1060eb:	c3                   	ret    
