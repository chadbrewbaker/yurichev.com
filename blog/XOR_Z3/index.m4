m4_include(`commons.m4')

_HEADER_HL1(`19-Jun-2017: Cracking simple XOR cipher with Z3')

_COPYPASTED2()

<p>What if we've got a text encrypted with simple XOR cipher, where just XOR mask has been applied?
It may be long, so brute-force is not an option.</p>

<p>Relationships between plain text, cipher text and key can be described using simple system of equations.
But we can do more: we can ask Z3 to find such a key (array of bytes), so the plain text will have as many lowercase
letters (a...z) as possible, but a solution will still satisfy all conditions.</p>

_PRE_BEGIN
m4_include(`blog/XOR_Z3/1.py')
_PRE_END

<p>( _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/XOR_Z3/1.py') )</p>

<p>Let's try it on a _HTML_LINK(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/XOR_Z3/cipher1.txt',`small 350-bytes file'):</p>

_PRE_BEGIN
% python 1.py cipher1.txt
len= 1
len= 2
len= 3
len= 4
len= 5

...

len= 16
len= 17
key=
00000000: 90 A0 21 52 48 84 FB FF  86 83 CF 50 46 12 7A F9  ..!RH......PF.z.
00000010: 36                                                6
plain=
00000000: 4D 72 2E 22 54 63 65 72  6F 6F 63 6D 27 48 6F 6C  Mr."Tceroocm'Hol
00000010: 6A 65 73 2C 22 70 63 6F  20 74 61 73 26 72 73 75  jes,"pco tas&rsu
00000020: 61 6B 6C 79 20 74 62 79  79 20 6F 61 74 63 27 69  akly tbyy oatc'i
00000030: 6E 20 73 68 65 20 6F 68  79 6E 69 6D 67 73 2A 27  n she ohynimgs*'
00000040: 73 61 76 62 0D 0A 75 72  68 65 20 74 6B 6F 73 63  savb..urhe tkosc
00000050: 27 6E 6F 74 27 69 6E 66  70 62 7A 75 65 6D 74 20  'not'infpbzuemt
00000060: 69 64 63 61 73 6E 6F 6E  73 22 70 63 65 6E 23 68  idcasnons"pcen#h
00000070: 65 26 70 61 73 20 72 70  20 61 6E 6B 2B 6E 69 64  e&pas rp ank+nid
00000080: 68 74 2A 27 77 61 73 27  73 65 61 76 62 6F 0D 0A  ht*'was'seavbo..
00000090: 62 74 20 72 6F 65 20 62  75 65 61 6B 64 66 78 74  bt roe bueakdfxt
000000A0: 20 77 61 62 6A 62 2E 20  49 27 73 74 6F 6D 63 2B   wabjb. I'stomc+
000000B0: 75 70 6C 6E 20 72 6F 65  20 68 62 61 72 74 6A 2A  upln roe hbartj*
000000C0: 79 75 67 23 61 6E 62 27  70 69 63 6C 65 64 20 77  yug#anb'picled w
000000D0: 77 2B 74 68 66 0D 0A 75  73 69 63 6B 27 77 68 69  w+thf..usick'whi
000000E0: 61 6F 2B 6F 75 71 20 76  6F 74 69 74 6F 75 20 68  ao+ouq votitou h
000000F0: 61 66 27 67 65 66 77 20  62 63 6F 69 6E 64 27 68  af'gefw bcoind'h
00000100: 69 6D 22 73 63 65 20 6D  69 67 6E 73 20 62 65 61  im"sce migns bea
00000110: 6F 72 65 2C 27 42 74 20  74 61 73 26 66 0D 0A 66  ore,'Bt tas&f..f
00000120: 6E 6E 65 2C 22 73 63 69  63 68 20 70 6F 62 63 65  nne,"scich pobce
00000130: 20 68 66 20 77 6D 68 6F  2C 20 61 75 6C 64 68 75   hf wmho, auldhu
00000140: 73 2D 6F 65 61 64 67 63  27 20 6F 65 20 74 6E 62  s-oeadgc' oe tnb
00000150: 20 73 6F 75 74 20 77 6A  6E 68 68 20 6A 73         sout wjnhh js
len= 18
len= 19
_PRE_END

<p>This is not readable. But what is interesting, the solution exist only for 17-byte key.</p>

<p>What do we know about English language texts?
Digits are rare there, so we can "minimize" them in plain text.
There are so called "digraphs" - a very popular combinations of two letters.
The most popular in English are: "th", "he", "in" and "er".
We can count them in plain text and "maximize" them:</p>

_PRE_BEGIN
...

    # ... for each byte of plain text: 1 if the byte is digit:
    digits_in_plain=[Int('digits_in_plain_%d' % i) for i in range (cipher_len)]
    # ... for each byte of plain text: 1 if the byte + next byte is "th" characters:
    th_in_plain=[Int('th_in_plain_%d' % i) for i in range (cipher_len-1)]
    # ... etc:
    he_in_plain=[Int('he_in_plain_%d' % i) for i in range (cipher_len-1)]
    in_in_plain=[Int('in_in_plain_%d' % i) for i in range (cipher_len-1)]
    er_in_plain=[Int('er_in_plain_%d' % i) for i in range (cipher_len-1)]

...

    for i in range(cipher_len-1):
        # ... for each byte of plain text: 1 if the byte + next byte is "th" characters:
        s.add(th_in_plain[i]==(If(And(plain[i]==ord('t'),plain[i+1]==ord('h')), 1, 0)))
        # ... etc:
        s.add(he_in_plain[i]==(If(And(plain[i]==ord('h'),plain[i+1]==ord('e')), 1, 0)))
        s.add(in_in_plain[i]==(If(And(plain[i]==ord('i'),plain[i+1]==ord('n')), 1, 0)))
        s.add(er_in_plain[i]==(If(And(plain[i]==ord('e'),plain[i+1]==ord('r')), 1, 0)))

    # find solution, where the sum of all az_in_plain variables is maximum:
    s.maximize(Sum(*az_in_plain))
    # ... and sum of digits_in_plain is minimum:
    s.minimize(Sum(*digits_in_plain))

    # "maximize" presence of "th", "he", "in" and "er" digraphs:
    s.maximize(Sum(*th_in_plain))
    s.maximize(Sum(*he_in_plain))
    s.maximize(Sum(*in_in_plain))
    s.maximize(Sum(*er_in_plain))

...
_PRE_END

<p>( _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/XOR_Z3/2.py') )</p>

<p>Now this is something familiar:</p>

_PRE_BEGIN
len= 17
key=
00000000: 90 A0 22 50 4F 8F FB FF  85 83 CF 56 41 12 7A FE  .."PO......VA.z.
00000010: 31                                                1
plain=
00000000: 4D 72 2D 20 53 68 65 72  6C 6F 63 6B 20 48 6F 6B  Mr- Sherlock Hok
00000010: 6D 65 73 2F 20 77 68 6F  20 77 61 73 20 75 73 75  mes/ who was usu
00000020: 66 6C 6C 79 23 76 65 72  79 20 6C 61 74 65 20 69  flly#very late i
00000030: 6E 27 74 68 65 23 6D 6F  72 6E 69 6E 67 73 2C 20  n'the#mornings,
00000040: 73 61 71 65 0D 0A 76 70  6F 6E 20 74 68 6F 73 65  saqe..vpon those
00000050: 20 6E 6F 73 20 69 6E 65  72 65 71 75 65 6E 74 20   nos inerequent
00000060: 6F 63 63 61 74 69 6F 6E  70 20 77 68 65 6E 20 68  occationp when h
00000070: 65 20 77 61 73 27 75 70  20 62 6C 6C 20 6E 69 67  e was'up bll nig
00000080: 68 74 2C 20 77 61 74 20  73 65 62 74 65 64 0D 0A  ht, wat sebted..
00000090: 61 74 20 74 68 65 20 65  72 65 61 68 66 61 73 74  at the ereahfast
000000A0: 20 74 61 62 6C 65 2E 20  4E 20 73 74 6C 6F 64 20   table. N stlod
000000B0: 75 70 6F 6E 20 74 68 65  20 6F 65 61 72 77 68 2D  upon the oearwh-
000000C0: 72 75 67 20 61 6E 64 20  70 69 64 6B 65 64 23 75  rug and pidked#u
000000D0: 70 20 74 68 65 0D 0A 73  74 69 63 6C 20 77 68 6A  p the..sticl whj
000000E0: 63 68 20 6F 75 72 20 76  69 73 69 74 68 72 20 68  ch our visithr h
000000F0: 62 64 20 6C 65 66 74 20  62 65 68 69 6E 63 20 68  bd left behinc h
00000100: 69 6E 20 74 68 65 20 6E  69 67 68 74 20 62 62 66  in the night bbf
00000110: 6F 72 66 2E 20 49 74 20  77 61 73 20 61 0D 0A 61  orf. It was a..a
00000120: 69 6E 65 2F 20 74 68 69  63 6B 20 70 69 65 63 65  ine/ thick piece
00000130: 27 6F 66 20 74 6F 6F 64  2C 20 62 75 6C 62 6F 75  'of tood, bulbou
00000140: 73 2A 68 65 61 67 65 64  2C 20 6F 66 20 74 68 65  s*heaged, of the
00000150: 20 73 68 72 74 20 74 68  69 63 68 20 69 73         shrt thich is
_PRE_END

<p>Several characters are wrong.
But we can fix them, adding these conditions:</p>

_PRE_BEGIN
...
    # 3 known characters of plain text:
    s.add(plain[0xf]==ord('l'))
    s.add(plain[0x20]==ord('a'))
    s.add(plain[0x57]==ord('f'))
...
_PRE_END

<p>( _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/XOR_Z3/3.py') )</p>

<p>This key is seems correct:</p>

_PRE_BEGIN
len= 17
key=
00000000: 90 A0 21 50 4F 8F FB FF  85 83 CF 56 41 12 7A F9  ..!PO......VA.z.
00000010: 31                                                1
plain=
00000000: 4D 72 2E 20 53 68 65 72  6C 6F 63 6B 20 48 6F 6C  Mr. Sherlock Hol
00000010: 6D 65 73 2C 20 77 68 6F  20 77 61 73 20 75 73 75  mes, who was usu
00000020: 61 6C 6C 79 20 76 65 72  79 20 6C 61 74 65 20 69  ally very late i
00000030: 6E 20 74 68 65 20 6D 6F  72 6E 69 6E 67 73 2C 20  n the mornings,
00000040: 73 61 76 65 0D 0A 75 70  6F 6E 20 74 68 6F 73 65  save..upon those
00000050: 20 6E 6F 74 20 69 6E 66  72 65 71 75 65 6E 74 20   not infrequent
00000060: 6F 63 63 61 73 69 6F 6E  73 20 77 68 65 6E 20 68  occasions when h
00000070: 65 20 77 61 73 20 75 70  20 61 6C 6C 20 6E 69 67  e was up all nig
00000080: 68 74 2C 20 77 61 73 20  73 65 61 74 65 64 0D 0A  ht, was seated..
00000090: 61 74 20 74 68 65 20 62  72 65 61 6B 66 61 73 74  at the breakfast
000000A0: 20 74 61 62 6C 65 2E 20  49 20 73 74 6F 6F 64 20   table. I stood
000000B0: 75 70 6F 6E 20 74 68 65  20 68 65 61 72 74 68 2D  upon the hearth-
000000C0: 72 75 67 20 61 6E 64 20  70 69 63 6B 65 64 20 75  rug and picked u
000000D0: 70 20 74 68 65 0D 0A 73  74 69 63 6B 20 77 68 69  p the..stick whi
000000E0: 63 68 20 6F 75 72 20 76  69 73 69 74 6F 72 20 68  ch our visitor h
000000F0: 61 64 20 6C 65 66 74 20  62 65 68 69 6E 64 20 68  ad left behind h
00000100: 69 6D 20 74 68 65 20 6E  69 67 68 74 20 62 65 66  im the night bef
00000110: 6F 72 65 2E 20 49 74 20  77 61 73 20 61 0D 0A 66  ore. It was a..f
00000120: 69 6E 65 2C 20 74 68 69  63 6B 20 70 69 65 63 65  ine, thick piece
00000130: 20 6F 66 20 77 6F 6F 64  2C 20 62 75 6C 62 6F 75   of wood, bulbou
00000140: 73 2D 68 65 61 64 65 64  2C 20 6F 66 20 74 68 65  s-headed, of the
00000150: 20 73 6F 72 74 20 77 68  69 63 68 20 69 73         sort which is
_PRE_END

<p>So this is correct 17-byte XOR-key.</p>

<p>Needless to say, that the bigger input, the better.
That 350-byte file is in fact the beginning of bigger file I prepared (_HTML_LINK(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/XOR_Z3/cipher2.txt',`cipher2.txt'), 12903 bytes).
And a correct key for it can be found for it without additional "heuristics" we added.</p>

<p>SMT solver is overkill for this. I once solved this problem naively, and it was much faster: _HTML_LINK_AS_IS(`https://yurichev.com/blog/XOR_mask_2/').
Nevertheless, this is yet another demonstration of yet another optimization problem.</p>

<p>The files: _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/tree/master/blog/XOR_Z3').</p>

<p>Previously: _HTML_LINK(`https://yurichev.com/blog/set_cover/',`Making smallest possible test suite using Z3'),
_HTML_LINK(`https://yurichev.com/writings/SAT_SMT_draft-EN.pdf',`Quick introduction into SAT/SMT solvers and symbolic execution').</p>

_BLOG_FOOTER()

