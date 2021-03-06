m4_include(`commons.m4')

_HEADER_HL1(`13-May-2017: Cyclomatic complexity')

<p>The term is used to measure complexity of a function.
Complex functions are usually evil, because they are hard to maintain, hard to test, etc.</p>

<p>There are several heuristics to measure it.</p>

<p>For example, we can find in _HTML_LINK(`https://www.kernel.org/doc/html/v4.10/process/coding-style.html',`Linux kernel coding style'):</p>

<blockquote>
<p>Now, some people will claim that having 8-character indentations makes the code move too far to the right, and makes it hard to read on a 80-character terminal screen. The answer to that is that if you need more than 3 levels of indentation, you’re screwed anyway, and should fix your program.</p>

<p>...</p>

<p>Functions should be short and sweet, and do just one thing. They should fit on one or two screenfuls of text (the ISO/ANSI screen size is 80x24, as we all know), and do one thing and do that well.</p>

<p>The maximum length of a function is inversely proportional to the complexity and indentation level of that function. So, if you have a conceptually simple function that is just one long (but simple) case-statement, where you have to do lots of small things for a lot of different cases, it’s OK to have a longer function.</p>

<p>However, if you have a complex function, and you suspect that a less-than-gifted first-year high-school student might not even understand what the function is all about, you should adhere to the maximum limits all the more closely. Use helper functions with descriptive names (you can ask the compiler to in-line them if you think it’s performance-critical, and it will probably do a better job of it than you would have done).</p>

<p>Another measure of the function is the number of local variables. They shouldn’t exceed 5-10, or you’re doing something wrong. Re-think the function, and split it into smaller pieces. A human brain can generally easily keep track of about 7 different things, anything more and it gets confused. You know you’re brilliant, but maybe you’d like to understand what you did 2 weeks from now.</p>
</blockquote>

<p>In _HTML_LINK(`https://yurichev.com/mirrors/C/JPL_Coding_Standard_C.pdf',`JPL Institutional Coding Standard for the C Programming Language'):</p>

<blockquote>
<p>Functions should be no longer than 60 lines of text and define no more than 6 parameters.</p>

<p>A function should not be longer than what can be printed on a single sheet of paper in a standard reference format with one line per statement and one line per declaration. Typically, this means no more than about 60 lines of code per function. Long lists of function parameters similarly compromise code clarity and should be avoided.</p>

<p>Each function should be a logical unit in the code that is understandable and verifiable as a unit. It is much harder to understand a logical unit that spans multiple screens on a computer display or multiple pages when printed. Excessively long functions are often a sign of poorly structured code.</p>
</blockquote>

<p>Now let's back to cyclomatic complexity.</p>

<p>Without diving deep into graph theory: there are basic blocks and links between them.
For example, this is how IDA shows BBs and links (as arrows). Just click space: _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/RE-for-beginners/blob/1058f52612973030e6d7384e7498c91141731a38/patterns/04_scanf/3_checking_retval/IDA.png').
Each BB is also called vertex or node in graph theory. Each link - edge.</p>

<p>There are at least two popular ways to calculate cyclomatic complexity:
1) edges - nodes + 2
2) edges - nodes + number of exits (RET instructions)</p>

<p>As of IDA example below, there are 4 BBs, so that is 4 nodes. But there are also 4 links and 1 return instruction.
By 1st rule, this is 2, by the second: 1.</p>

<p>The bigger the number, the more complex your function and things go from bad to worse.
As you can see, additional exit (return instructions) make things even worse,
as well as additional links between nodes (including additional goto's).</p>

<p>I wrote the simple IDAPython script (_HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/cyclomatic/cyclomatic.py')) to measure it.
Here is result for Linux kernel 4.11 (most complex functions in it):</p>

_PRE_BEGIN
1829c0 do_check edges=937 nodes=574 rets=1 E-N+2=365 E-N+rets=364
2effe0 ext4_fill_super edges=862 nodes=568 rets=1 E-N+2=296 E-N+rets=295
5d92e0 wm5110_readable_register edges=661 nodes=369 rets=2 E-N+2=294 E-N+rets=294
277650 do_blockdev_direct_IO edges=771 nodes=507 rets=1 E-N+2=266 E-N+rets=265
10f7c0 load_module edges=711 nodes=465 rets=1 E-N+2=248 E-N+rets=247
787730 dev_ethtool edges=559 nodes=315 rets=1 E-N+2=246 E-N+rets=245
84e440 do_ipv6_setsockopt edges=468 nodes=237 rets=1 E-N+2=233 E-N+rets=232
72c3c0 mmc_init_card edges=593 nodes=365 rets=1 E-N+2=230 E-N+rets=229
...
_PRE_END
<p>( Full list: _HTML_LINK_AS_IS(`https://raw.githubusercontent.com/DennisYurichev/yurichev.com/master/blog/cyclomatic/linux_4.11_sorted.txt') )</p>

<p>This is source code of some of them:
_HTML_LINK(`https://github.com/torvalds/linux/blob/56868a460b83c0f93d339256a81064d89aadae8e/kernel/bpf/verifier.c#L2811',`do_check()'),
_HTML_LINK(`https://github.com/torvalds/linux/blob/0fcc3ab23d7395f58e8ab0834e7913e2e4314a83/fs/ext4/super.c#L3358',`ext4_fill_super()'),
_HTML_LINK(`https://github.com/torvalds/linux/blob/86292b33d4b79ee03e2f43ea0381ef85f077c760/fs/direct-io.c#L1107',`do_blockdev_direct_IO()'),
_HTML_LINK(`https://github.com/torvalds/linux/blob/bf5f89463f5b3109a72ed13ca62b57e90213387d/arch/x86/net/bpf_jit_comp.c#L351',`do_jit()').</p>

<p>Most complex functions in Windows 7 ntoskrnl.exe file:</p>

_PRE_BEGIN
140569400 sub_140569400 edges=3070 nodes=1889 rets=1 E-N+2=1183 E-N+rets=1182
14007c640 MmAccessFault edges=2256 nodes=1424 rets=1 E-N+2=834 E-N+rets=833
1401a0410 FsRtlMdlReadCompleteDevEx edges=1241 nodes=752 rets=1 E-N+2=491 E-N+rets=490
14008c190 MmProbeAndLockPages edges=983 nodes=623 rets=1 E-N+2=362 E-N+rets=361
14037fd10 ExpQuerySystemInformation edges=995 nodes=671 rets=1 E-N+2=326 E-N+rets=325
140197260 MmProbeAndLockSelectedPages edges=875 nodes=551 rets=1 E-N+2=326 E-N+rets=325
140362a50 NtSetInformationProcess edges=880 nodes=586 rets=1 E-N+2=296 E-N+rets=295
....
_PRE_END

<p>( Full list: _HTML_LINK_AS_IS(`https://raw.githubusercontent.com/DennisYurichev/yurichev.com/master/blog/cyclomatic/win7_ntoskrnl_sorted.txt') )</p>

<p>From a bug hunter's standpoint, complex functions are prone to have bugs, so an attention should be paid to them.</p>

<p>Read more about it:
_HTML_LINK_AS_IS(`https://en.wikipedia.org/wiki/Cyclomatic_complexity'),
_HTML_LINK_AS_IS(`http://wiki.c2.com/?CyclomaticComplexityMetric').</p>

<p>Measuring cyclomatic complexity in MSVS (C#):
_HTML_LINK_AS_IS(`https://blogs.msdn.microsoft.com/zainnab/2011/05/17/code-metrics-cyclomatic-complexity/').</p>

<p>Couple of other Python scripts for measuring cyclomatic complexity in IDA:
_HTML_LINK_AS_IS(`http://www.openrce.org/articles/full_view/11'),
_HTML_LINK_AS_IS(`https://github.com/mxmssh/IDAmetrics') (incl. other metrics).</p>

<p>GCC plugin:
_HTML_LINK_AS_IS(`https://github.com/ephox-gcc-plugins/cyclomatic_complexity').</p>

_BLOG_FOOTER()


