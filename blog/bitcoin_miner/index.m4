m4_include(`commons.m4')

_HEADER_HL1(`27-Jun-2016: Overclocking Cointerra Bitcoin miner')

<p>There was Cointerra Bitcoin miner, looking like _HTML_LINK(`http://yurichev.com/blog/bitcoin_miner/files/board.jpg',`that').</p>

<p>And there was also (possibly leaked) _HTML_LINK(`http://yurichev.com/blog/bitcoin_miner/files/cointool-overclock',`utility') which can set clock rate for the board.
It runs on additional BeagleBone Linux ARM board (small board at bottom of the picture).</p>

<p>And I was asked, is it possible to hack this utility to see, which frequency can be set and which are not. And it is possible to tweak it?</p>

<p>The utility should be run like that: <b>./cointool-overclock 0 0 900</b>, where 900 is frequency in MHz.
If the frequency is too high, utility will print "Error with arguments" and exit.</p>

<p>This is a fragment of code around reference to "Error with arguments" text string:</p>

_PRE_BEGIN

...

.text:0000ABC4                 STR             R3, [R11,#var_28]
.text:0000ABC8                 MOV             R3, #optind
.text:0000ABD0                 LDR             R3, [R3]
.text:0000ABD4                 ADD             R3, R3, #1
.text:0000ABD8                 MOV             R3, R3,LSL#2
.text:0000ABDC                 LDR             R2, [R11,#argv]
.text:0000ABE0                 ADD             R3, R2, R3
.text:0000ABE4                 LDR             R3, [R3]
.text:0000ABE8                 MOV             R0, R3  ; nptr
.text:0000ABEC                 MOV             R1, #0  ; endptr
.text:0000ABF0                 MOV             R2, #0  ; base
.text:0000ABF4                 BL              strtoll
.text:0000ABF8                 MOV             R2, R0
.text:0000ABFC                 MOV             R3, R1
.text:0000AC00                 MOV             R3, R2
.text:0000AC04                 STR             R3, [R11,#var_2C]
.text:0000AC08                 MOV             R3, #optind
.text:0000AC10                 LDR             R3, [R3]
.text:0000AC14                 ADD             R3, R3, #2
.text:0000AC18                 MOV             R3, R3,LSL#2
.text:0000AC1C                 LDR             R2, [R11,#argv]
.text:0000AC20                 ADD             R3, R2, R3
.text:0000AC24                 LDR             R3, [R3]
.text:0000AC28                 MOV             R0, R3  ; nptr
.text:0000AC2C                 MOV             R1, #0  ; endptr
.text:0000AC30                 MOV             R2, #0  ; base
.text:0000AC34                 BL              strtoll
.text:0000AC38                 MOV             R2, R0
.text:0000AC3C                 MOV             R3, R1
.text:0000AC40                 MOV             R3, R2
.text:0000AC44                 STR             R3, [R11,#third_argument]
.text:0000AC48                 LDR             R3, [R11,#var_28]
.text:0000AC4C                 CMP             R3, #0
.text:0000AC50                 BLT             errors_with_arguments
.text:0000AC54                 LDR             R3, [R11,#var_28]
.text:0000AC58                 CMP             R3, #1
.text:0000AC5C                 BGT             errors_with_arguments
.text:0000AC60                 LDR             R3, [R11,#var_2C]
.text:0000AC64                 CMP             R3, #0
.text:0000AC68                 BLT             errors_with_arguments
.text:0000AC6C                 LDR             R3, [R11,#var_2C]
.text:0000AC70                 CMP             R3, #3
.text:0000AC74                 BGT             errors_with_arguments
.text:0000AC78                 LDR             R3, [R11,#third_argument]
.text:0000AC7C                 CMP             R3, #0x31
.text:0000AC80                 BLE             errors_with_arguments
.text:0000AC84                 LDR             R2, [R11,#third_argument]
.text:0000AC88                 MOV             R3, #950
.text:0000AC8C                 CMP             R2, R3
.text:0000AC90                 BGT             errors_with_arguments
.text:0000AC94                 LDR             R2, [R11,#third_argument]
.text:0000AC98                 MOV             R3, #0x51EB851F
.text:0000ACA0                 SMULL           R1, R3, R3, R2
.text:0000ACA4                 MOV             R1, R3,ASR#4
.text:0000ACA8                 MOV             R3, R2,ASR#31
.text:0000ACAC                 RSB             R3, R3, R1
.text:0000ACB0                 MOV             R1, #50
.text:0000ACB4                 MUL             R3, R1, R3
.text:0000ACB8                 RSB             R3, R3, R2
.text:0000ACBC                 CMP             R3, #0
.text:0000ACC0                 BEQ             loc_ACEC
.text:0000ACC4
.text:0000ACC4 errors_with_arguments
.text:0000ACC4                                         
.text:0000ACC4                 LDR             R3, [R11,#argv]
.text:0000ACC8                 LDR             R3, [R3]
.text:0000ACCC                 MOV             R0, R3  ; path
.text:0000ACD0                 BL              __xpg_basename
.text:0000ACD4                 MOV             R3, R0
.text:0000ACD8                 MOV             R0, #aSErrorWithArgu ; format
.text:0000ACE0                 MOV             R1, R3
.text:0000ACE4                 BL              printf
.text:0000ACE8                 B               loc_ADD4
.text:0000ACEC ; ---------------------------------------------------------------------------
.text:0000ACEC
.text:0000ACEC loc_ACEC                                ; CODE XREF: main+66C
.text:0000ACEC                 LDR             R2, [R11,#third_argument]
.text:0000ACF0                 MOV             R3, #499
.text:0000ACF4                 CMP             R2, R3
.text:0000ACF8                 BGT             loc_AD08
.text:0000ACFC                 MOV             R3, #0x64
.text:0000AD00                 STR             R3, [R11,#unk_constant]
.text:0000AD04                 B               jump_to_write_power
.text:0000AD08 ; ---------------------------------------------------------------------------
.text:0000AD08
.text:0000AD08 loc_AD08                                ; CODE XREF: main+6A4
.text:0000AD08                 LDR             R2, [R11,#third_argument]
.text:0000AD0C                 MOV             R3, #799
.text:0000AD10                 CMP             R2, R3
.text:0000AD14                 BGT             loc_AD24
.text:0000AD18                 MOV             R3, #0x5F
.text:0000AD1C                 STR             R3, [R11,#unk_constant]
.text:0000AD20                 B               jump_to_write_power
.text:0000AD24 ; ---------------------------------------------------------------------------
.text:0000AD24
.text:0000AD24 loc_AD24                                ; CODE XREF: main+6C0
.text:0000AD24                 LDR             R2, [R11,#third_argument]
.text:0000AD28                 MOV             R3, #899
.text:0000AD2C                 CMP             R2, R3
.text:0000AD30                 BGT             loc_AD40
.text:0000AD34                 MOV             R3, #0x5A
.text:0000AD38                 STR             R3, [R11,#unk_constant]
.text:0000AD3C                 B               jump_to_write_power
.text:0000AD40 ; ---------------------------------------------------------------------------
.text:0000AD40
.text:0000AD40 loc_AD40                                ; CODE XREF: main+6DC
.text:0000AD40                 LDR             R2, [R11,#third_argument]
.text:0000AD44                 MOV             R3, #999
.text:0000AD48                 CMP             R2, R3
.text:0000AD4C                 BGT             loc_AD5C
.text:0000AD50                 MOV             R3, #0x55
.text:0000AD54                 STR             R3, [R11,#unk_constant]
.text:0000AD58                 B               jump_to_write_power
.text:0000AD5C ; ---------------------------------------------------------------------------
.text:0000AD5C
.text:0000AD5C loc_AD5C                                ; CODE XREF: main+6F8
.text:0000AD5C                 LDR             R2, [R11,#third_argument]
.text:0000AD60                 MOV             R3, #1099
.text:0000AD64                 CMP             R2, R3
.text:0000AD68                 BGT             jump_to_write_power
.text:0000AD6C                 MOV             R3, #0x50
.text:0000AD70                 STR             R3, [R11,#unk_constant]
.text:0000AD74
.text:0000AD74 jump_to_write_power                     ; CODE XREF: main+6B0
.text:0000AD74                                         ; main+6CC ...
.text:0000AD74                 LDR             R3, [R11,#var_28]
.text:0000AD78                 UXTB            R1, R3
.text:0000AD7C                 LDR             R3, [R11,#var_2C]
.text:0000AD80                 UXTB            R2, R3
.text:0000AD84                 LDR             R3, [R11,#unk_constant]
.text:0000AD88                 UXTB            R3, R3
.text:0000AD8C                 LDR             R0, [R11,#third_argument]
.text:0000AD90                 UXTH            R0, R0
.text:0000AD94                 STR             R0, [SP,#0x44+var_44]
.text:0000AD98                 LDR             R0, [R11,#var_24]
.text:0000AD9C                 BL              write_power
.text:0000ADA0                 LDR             R0, [R11,#var_24]
.text:0000ADA4                 MOV             R1, #0x5A
.text:0000ADA8                 BL              read_loop
.text:0000ADAC                 B               loc_ADD4

...

.rodata:0000B378 aSErrorWithArgu DCB "%s: Error with arguments",0xA,0 ; DATA XREF: main+684

...

_PRE_END

<p>Function names were present in debugging information of the original binary, like "write_power", "read_loop".
But labels inside functions were named by me.</p>

<p>"optind" name looks familiar. It is from _HTML_LINK(`https://en.wikipedia.org/wiki/Getopt',`getopt') *NIX library intended for command-line parsing - well, this is exaclty what happens in this utility.
Then, the 3rd argument (where frequency value is to be passed) is converted from string to number using call to strtoll() function.</p>

<p>The value is then checked against various constants.
At 0xACEC, it's checked, if it is lesser or equal to 499, 0x64 is to be passed finally to write_power() function (which sends a command through USB using send_msg()).
If it is greater than 499, jump to 0xAD08 is occurred.</p>

<p>At 0xAD08 it's checked, if it's lesser or equal to 799. 0x5F is then passed to write_power() function in case of success.</p>

<p>There are more checks: for 899 at 0xAD24, for 0x999 at 0xAD40 and finally, for 1099 at 0xAD5C.
If the input frequency is lesser or equal to 1099, 0x50 will be passed (at 0xAD6C) to write_power() function.
And there is some kind of bug.
If the value is still greater than 1099, the value itself is passed into write_power() function.
Oh, it's not a bug, because we can't get here: value is checked first against 950 at 0xAC88, and if it is greater, error message will be displayed and the utility will finish.</p>

<p>Now the table between frequency in MHz and value passed to write_power() function (MHz, value in hexadecimal form, value in decimal form):</p>

_PRE_BEGIN
499MHz 0x64 100d
799MHz 0x5f 95d
899MHz 0x5a 90d
999MHz 0x55 85d
1099MHz 0x50 80d
_PRE_END

<p>As it seems, value passed to the board is gradually decreasing during frequency increasing.</p>

<p>Now we see that value of 950MHz is a hardcoded limit, at least in this utility. Can we trick it?</p>

<p>Let's back to this piece of code:</p>

_PRE_BEGIN
.text:0000AC84                 LDR             R2, [R11,#third_argument]
.text:0000AC88                 MOV             R3, #950
.text:0000AC8C                 CMP             R2, R3
.text:0000AC90                 BGT             errors_with_arguments ; I've patched here to 00 00 00 00
_PRE_END

<p>We need to disable BGT branch instruction at 0xAC90 somehow. And this is ARM in ARM mode, because, as we see, all addresses are increasing by 4, i.e., each instruction has size of 4 bytes.
NOP (no operation) instruction in ARM mode is just four zero bytes: 00 00 00 00.
So by writing four zeroes at 0xAC90 address (or physical offset in file 0x2C90) will disable this check.</p>

<p>Not it's possible to set frequencies up to 1050MHz. Even more is possible, but due to the bug, if input value is greater than 1099, raw value in MHz will be passed to the board, which is incorrect.</p>

<p>I didn't go further, but if I need to, I would try to decrease a value which is passed to write_power() function.</p>

<p>Now the scary piece of code which I skipped at first:</p>

_PRE_BEGIN
.text:0000AC94                 LDR             R2, [R11,#third_argument]
.text:0000AC98                 MOV             R3, #0x51EB851F
.text:0000ACA0                 SMULL           R1, R3, R3, R2 ; R3=3rg_arg/3.125
.text:0000ACA4                 MOV             R1, R3,ASR#4 ; R1=R3/16=3rg_arg/50
.text:0000ACA8                 MOV             R3, R2,ASR#31 ; R3=MSB(3rg_arg)
.text:0000ACAC                 RSB             R3, R3, R1 ; R3=3rd_arg/50
.text:0000ACB0                 MOV             R1, #50
.text:0000ACB4                 MUL             R3, R1, R3 ; R3=50*(3rd_arg/50)
.text:0000ACB8                 RSB             R3, R3, R2
.text:0000ACBC                 CMP             R3, #0
.text:0000ACC0                 BEQ             loc_ACEC
.text:0000ACC4
.text:0000ACC4 errors_with_arguments
_PRE_END

<p>Multiplication via division is used here, and constant is 0x51EB851F.
I wrote a simple _HTML_LINK(`https://github.com/dennis714/progcalc',`programmer&rsquo;s calculator') for myself.
And I have there a feature to calculate modulo inverse.</p>

_PRE_BEGIN
modinv32(0x51EB851F)
Warning, result is not integer: 3.125000
(unsigned) dec: 3 hex: 0x3 bin: 11 log2=1
_PRE_END

<p>That means that SMULL instruction at 0xACA0 is basically divides 3rd argument by 3.125.
In fact, all modinv32() function in my calculator does, is this: $\frac{1}{\frac{input}{2^{32}}}$ (or this: $\frac{2^{32}}{input}$).</p>

<p>Then there are additional shifts and now we see than 3rg argument is just divided by 50. And then it's multiplied by 50 again.
Why?
This is simplest check, if the input value is can be divided by 50 evenly.
If the value of this expression is non-zero, $x$ can't be divided by 50 evenly: $x-((\frac{x}{50}) \cdot 50)$.
This is in fact simple way to calculate remainder of division.
</p>

<p>And then, if the remainder is non-zero, error message is displayed. So this utility takes frequency values in form like 850, 900, 950, 1000, etc, but not 855 or 911.</p>

<p>That's it! If you do something like that, please be warned that you may damage your board, just as in case of overclocking other devices like CPUs, GPUs, etc.
If you have a Cointerra board, do this on your own risk!</p>

_BLOG_FOOTER_GITHUB(`bitcoin_miner')

_BLOG_FOOTER()

