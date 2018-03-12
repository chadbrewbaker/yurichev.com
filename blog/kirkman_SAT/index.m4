m4_include(`commons.m4')

_HEADER_HL1(`School teams scheduling, Kirkman’s Schoolgirl Problem, etc')

<p>Previously: _HTML_LINK_AS_IS(`https://yurichev.com/blog/kirkman/').</p>

<p>I've found this in the Dennis E. Shasha -- "Puzzles for Programmers and Pros" book:</p>

_PRE_BEGIN
Scheduling Tradition

There are 12 school teams, unimaginatively named A, B, C, D, E, F, G, H, I, J, K, and L. They must play one another on 11 consecutive days on six fields. 
Every team must play every other team exactly once. Each team plays one game per day.

        Warm-Up
                Suppose there were four teams A, B, C, D and each team has to play every other in three days on two fields. How can you do it?

        Solution to Warm-Up

                We’ll represent the solution in two columns corresponding to the two playing fields. Thus, in the first day, A plays B on field 1 and C plays D on field 2.
                AB CD
                AC DB
                AD BC

Not only does the real problem involve 12 teams instead of merely four, but there are certain constraints due to traditional team rivalries: 
A must play B on day 1, G on day 3, and H on day 6. F must play I on day 2 and J on day 5.  K must play H on day 9 and E on day 11. 
L must play E on day 8 and B on day 9. H must play I on day 10 and L on day 11. There are no constraints on C or D because these are new teams.

        1. Can you form an 11-day schedule for these teams that satisfies the constraints?

It may seem difficult, but look again at the warm-up. Look in particular at the non-A columns. They are related to one another.
If you understand how, you can solve the harder problem.
_PRE_END

<p>This is like Kirkman's Schoolgirl Problem _HTML_LINK(`https://yurichev.com/blog/kirkman/',`I have solved using Z3 before'), but this time I've rewritten it as a SAT problem.
Also, I added additional constraints relating to "team rivalries".
This code also uses my SAT-related _HTML_LINK(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/kirkman_SAT/Xu.py',`Xu Python library').</p>

_PRE_BEGIN
m4_include(`blog/kirkman_SAT/kirkman_SAT.py')
_PRE_END

<p>The solution:</p>

_PRE_BEGIN
group for each person:
person: A B C D E F G H I J K L
day= 0: 4 4 1 3 5 0 2 0 5 3 2 1
day= 1: 5 0 3 3 2 4 1 2 4 1 0 5
day= 2: 4 5 1 0 1 2 4 5 3 3 2 0
day= 3: 3 5 4 1 1 4 2 2 0 5 3 0
day= 4: 3 0 4 5 0 2 5 3 4 2 1 1
day= 5: 3 5 4 5 3 0 0 4 1 2 1 2
day= 6: 5 3 5 4 1 0 1 4 3 2 2 0
day= 7: 5 2 0 1 3 1 2 4 5 4 0 3
day= 8: 4 2 5 4 1 1 3 0 3 5 0 2
day= 9: 4 2 2 1 5 4 0 3 3 5 1 0
day=10: 2 5 0 4 3 5 0 1 4 2 3 1

persons grouped:
day= 0: FH  CL  GK  DJ  AB  EI
day= 1: BK  GJ  EH  CD  FI  AL
day= 2: DL  CE  FK  IJ  AG  BH
day= 3: IL  DE  GH  AK  CF  BJ
day= 4: BE  KL  FJ  AH  CI  DG
day= 5: FG  IK  JL  AE  CH  BD
day= 6: FL  EG  JK  BI  DH  AC
day= 7: CK  DF  BG  EL  HJ  AI
day= 8: HK  EF  BL  GI  AD  CJ
day= 9: GL  DK  BC  HI  AF  EJ
day=10: CG  HL  AJ  EK  DI  BF
_PRE_END

<p>("Person" and "team" terms are interchangeable in my code.)</p>

<p>Thanks to _HTML_LINK(`http://fmv.jku.at/lingeling/',`parallel lingeling SAT solver') I've used this time, it takes couple of minutes on a decent 4-core CPU.</p>

<p>The source code: _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/tree/master/blog/kirkman_SAT').</p>

_BLOG_FOOTER()

