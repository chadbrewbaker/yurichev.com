m4_include(`commons.m4')

_HEADER_HL1(`Integer factorization using SAT solver')

_COPYPASTED2()

<p>Previously: _HTML_LINK(`https://yurichev.com/blog/factor/',`Integer factorization using Z3 SMT solver').</p>

<p>We are going to simulate electronic circuit of binary multiplier in SAT and then ask solver, what multiplier's inputs must be so the output will be a desired number?
If this situation is impossible, the desired number is prime.</p>

<p>First we should build multiplier out of adders.</p>

_HL2(`Binary adder in SAT')

<p>Simple binary adder usually constists of full-adders and one half-adder.
These are basic elements of adders.</p>

<p>Half-adder:</p>

<img src="half_adder.png">

<p>( The image has been taken from _HTML_LINK(`https://en.wikipedia.org/wiki/Adder_(electronics)',`Wikipedia'). )</p>

Full-adder:

<img src="full_adder.png">
<p>( The image has been taken from _HTML_LINK(`https://en.wikipedia.org/wiki/Adder_(electronics)',`Wikipedia'). )</p>

<p>Here is a 4-bit ripple-carry adder:</p>

_PRE_BEGIN
         X3 Y3              X2 Y2              X1 Y1              X0 Y0
         |  |               |  |               |  |               |  |
         v  v               v  v               v  v               v  v
        +----+             +----+             +----+             +----+
Cout <- | FA | <- carry <- | FA | <- carry <- | FA | <- carry <- | HA |
        +----+             +----+             +----+             +----+
          ^                  ^                  ^                  ^
          |                  |                  |                  |
          S3                 S2                 S1                 S0
_PRE_END

<p>It can be used for most tasks.</p>

<p>Here is a 4-bit ripple-carry adder with carry-in:</p>

_PRE_BEGIN
         X3 Y3              X2 Y2              X1 Y1              X0 Y0
         |  |               |  |               |  |               |  |
         v  v               v  v               v  v               v  v
        +----+             +----+             +----+             +----+
Cout <- | FA | <- carry <- | FA | <- carry <- | FA | <- carry <- | FA | <- Cin
        +----+             +----+             +----+             +----+
          ^                  ^                  ^                  ^
          |                  |                  |                  |
          S3                 S2                 S1                 S0
_PRE_END

<p>What carries are?
4-bit adder can sum up two numbers up to 0b1111 (15).
15+15=30 and this is 0b11110, i.e., 5 bits. Lowest 4 bits is a sum.
5th most significant bit is not a part of sum, but is a carry bit.</p>

<p>If you sum two numbers on x86 CPU, CF flag is a carry bit connected to ALU.
It is set if a resulting sum is bigger than it can be fit into result.</p>

<p>Now you can also need carry-in.
Again, x86 CPU has ADC instruction, it takes CF flag state.
It can be said, CF flag is connected to adder's carry-in input.
Hence, combining two ADD and ADC instructions you can sum up 128 bits on 64-bit CPU.</p>

<p>By the way, this is a good explanation of "carry-ripple".
The very first full-adder's result is depending on the carry-out of the previous full-adder.
Hence, adders cannot work in parallel.
This is a problem of simplest possible adder, other adders can solve this.</p>

<p>To represent full-adders in CNF form, we can use Wolfram Mathematica.
I've taken truth table for full-adder from _HTML_LINK(`https://en.wikipedia.org/wiki/Adder_(electronics)',`Wikipedia'):</p>

_PRE_BEGIN
Inputs 	|  Outputs
--------+----------
A B Cin |  Cout Sum
0 0 0   |  0    0
0 0 1   |  0    1
0 1 0   |  0    1
0 1 1   |  1    0
1 0 0   |  0    1
1 0 1   |  1    0
1 1 0   |  1    0
1 1 1   |  1    1
_PRE_END

<p>In Mathematica, I'm setting "->1" if row is correct and "->0" if not correct.</p>

_PRE_BEGIN
In[59]:= FaTbl = {{0, 0, 0, 0, 0} -> 1, {0, 0, 0, 0, 1} -> 
   0, {0, 0, 0, 1, 0} -> 0, {0, 0, 0, 1, 1} -> 0, {0, 0, 1, 0, 0} -> 
   0, {0, 0, 1, 0, 1} -> 1, {0, 0, 1, 1, 0} -> 0, {0, 0, 1, 1, 1} -> 
   0, {0, 1, 0, 0, 0} -> 0, {0, 1, 0, 0, 1} -> 1, {0, 1, 0, 1, 0} -> 
   0, {0, 1, 0, 1, 1} -> 0, {0, 1, 1, 0, 0} -> 0, {0, 1, 1, 0, 1} -> 
   0, {0, 1, 1, 1, 0} -> 1, {0, 1, 1, 1, 1} -> 0, {1, 0, 0, 0, 0} -> 
   0, {1, 0, 0, 0, 1} -> 1, {1, 0, 0, 1, 0} -> 0, {1, 0, 0, 1, 1} -> 
   0, {1, 0, 1, 0, 0} -> 0, {1, 0, 1, 0, 1} -> 0, {1, 0, 1, 1, 0} -> 
   1, {1, 0, 1, 1, 1} -> 0, {1, 1, 0, 0, 0} -> 0, {1, 1, 0, 0, 1} -> 
   0, {1, 1, 0, 1, 0} -> 1, {1, 1, 0, 1, 1} -> 0, {1, 1, 1, 0, 0} -> 
   0, {1, 1, 1, 0, 1} -> 0, {1, 1, 1, 1, 0} -> 0, {1, 1, 1, 1, 1} -> 1}

...

In[60]:= BooleanConvert[
 BooleanFunction[FaTbl, {a, b, cin, cout, s}], "CNF"]

Out[60]= (! a || ! b || ! cin || s) && (! a || ! b || 
   cout) && (! a || ! cin || cout) && (! a || cout || s) && (a || b ||
    cin || ! s) && (a || b || ! cout) && (a || 
   cin || ! cout) && (a || ! cout || ! s) && (! b || ! cin || 
   cout) && (! b || cout || s) && (b || 
   cin || ! cout) && (b || ! cout || ! s) && (! cin || cout || 
   s) && (cin || ! cout || ! s)
_PRE_END

<p>These clauses can be used as full-adder.</p>

<p>Here is it:</p>

_PRE_BEGIN
# full-adder, as found by Mathematica using truth table:
def FA (a,b,cin):
    global clauses
    s=create_var()
    cout=create_var()

    clauses.append([neg(a), neg(b), neg(cin), s])
    clauses.append([neg(a), neg(b), cout])
    clauses.append([neg(a), neg(cin), cout])
    clauses.append([neg(a), cout, s])
    clauses.append([a, b, cin, neg(s)])
    clauses.append([a, b, neg(cout)])
    clauses.append([a, cin, neg(cout)])
    clauses.append([a, neg(cout), neg(s)])
    clauses.append([neg(b), neg(cin), cout])
    clauses.append([neg(b), cout, s])
    clauses.append([b, cin, neg(cout)])
    clauses.append([b, neg(cout), neg(s)])
    clauses.append([neg(cin), cout, s])
    clauses.append([cin, neg(cout), neg(s)])

    return s, cout
_PRE_END

<p>And adder:</p>

_PRE_BEGIN
# reverse list:
def rvr(i):
    return i[::-1]

# n-bit adder:
def adder(X,Y):
    global clauses, const_true, const_false
    assert len(X)==len(Y)
    # first full-adder could be half-adder
    # start with lowest bits:
    inputs=rvr(zip(X,Y))
    carry=const_false
    sums=[]
    for pair in inputs:
        # "carry" variable is replaced at each iteration.
        # so it is used in the each FA() call from the previous FA() call.
        s, carry = FA(pair[0], pair[1], carry)
        sums.append(s)
    return rvr(sums), carry
_PRE_END

_HL2(`Binary multiplier in SAT')

<p>Remember school-level long division?
This multiplier works in a same way, but for binary digits.</p>

<p>Here is example of multiplying 0b1101 (X) by 0b0111 (Y):</p>

_PRE_BEGIN
         LSB
          |
          v
       1101 <- X
       -------
LSB 0|    0000
    1|   1101
    1|  1101
    1| 1101
    ^
    |
    Y
_PRE_END

<p>If bit from Y is zero, a row is zero.
If bit from Y is non-zero, a row is equal to X, but shifted each time.
Then you just sum up all rows (which are called "partial products".)</p>

<p>This is 4-bit binary multiplier. It takes 4-bit inputs and produces 8-bit output:</p>

<img src="bin_mult.png">

<p>( The image has been taken from _HTML_LINK_AS_IS(`http://www.chegg.com/homework-help/binary-multiplier-multiplies-two-unsigned-four-bit-numbers-u-chapter-4-problem-20p-solution-9780132774208-exc'). )</p>

<p>I would build separate block, "multiply by one bit" as a latch for each partial product:</p>

_PRE_BEGIN
def AND_Tseitin(v1, v2, out):
    global clauses
    clauses.append([neg(v1), neg(v2), out])
    clauses.append([v1, neg(out)])
    clauses.append([v2, neg(out)])

def AND(v1, v2):
    global clauses
    out=create_var()
    AND_Tseitin(v1, v2, out)
    return out

...

# bit is 0 or 1.
# i.e., if it's 0, output is 0 (all bits)
# if it's 1, output=input
def mult_by_bit(X, bit):
    return [AND(i, bit) for i in X]

# build multiplier using adders and mult_by_bit blocks:
def multiplier(X, Y):
    global clauses, const_false
    assert len(X)==len(Y)
    out=[]
    #initial:
    prev=[const_false]*len(X)
    # first adder can be skipped, but I left thing "as is" to make it simpler
    for Y_bit in rvr(Y):
        s, carry = adder(mult_by_bit(X, Y_bit), prev)
        out.append(s[-1])
        prev=[carry] + s[:-1]

    return prev + rvr(out)
_PRE_END

<p>AND gate is constructed here using Tseitin transformations.
This is quite popular way of encoding gates in CNF form, by adding additional variable:
_HTML_LINK_AS_IS(`https://en.wikipedia.org/wiki/Tseytin_transformation').
In fact, full-adder can be constructed without Mathematica, using logic gates, and encoded by Tseitin transformation.</p>

_HL2(`Glueling all together')

_PRE_BEGIN
# vals=list
# as in Tseitin transformations.
def OR(vals):
    global clauses
    out=create_var()
    clauses.append(vals+[neg(out)])
    clauses=clauses+[[neg(v), out] for v in vals]
    return out

...

def factor(n):
    global clauses, last_var, const_false

    print "factoring",n

    clauses=[]
    last_var=1

    # allocate a single variable fixed to False:
    const_false=create_var()
    var_always(const_false,False)

    # size of inputs.
    # in other words, how many bits we have to allocate to store 'n'?
    input_bits=int(math.ceil(math.log(n,2)))
    print "input_bits=", input_bits

    factor1,factor2=alloc_BV(input_bits),alloc_BV(input_bits)
    product=multiplier(factor1,factor2)

    # at least one bit in each input must be set, except lowest.
    # hence we restrict inputs to be greater than 1
    var_always(OR(factor1[:-1]), True)
    var_always(OR(factor2[:-1]), True)

    # output has a size twice as bigger as each input:
    BV_always(product, n_to_BV(n,input_bits*2))

    solution=solve(clauses)
    if solution==None:
        print n,"is prime (unsat)"
        return [n]

    # get inputs of multiplier:
    factor1_n=BV_to_number(get_BV_from_solution(factor1, solution))
    factor2_n=BV_to_number(get_BV_from_solution(factor2, solution))

    print "factors of", n, "are", factor1_n, "and", factor2_n
    # factor factors recursively:
    rt=sorted(factor (factor1_n) + factor (factor2_n))
    assert reduce(mul, rt, 1)==n
    return rt

print factor(1234567890) # {{2, 1}, {3, 2}, {5, 1}, {3607, 1}, {3803, 1}}
_PRE_END

<p>I just connect our number to output of multiplier and ask SAT solver to find inputs.
If it's UNSAT, this is prime number.
Then we factor factors recursively.</p>

<p>Also, we want block input factors of 1, because obviously, we do not interesting in the fact that n*1=n.
I'm using wide OR gates for this.</p>

<p>Output:</p>

_PRE_BEGIN
 % python factor_SAT.py
factoring 1234567890
input_bits= 31
len(clauses)= 16464
factors of 1234567890 are 2 and 617283945
factoring 2
input_bits= 1
len(clauses)= 24
2 is prime (unsat)
factoring 617283945
input_bits= 30
len(clauses)= 15423
factors of 617283945 are 3 and 205761315
factoring 3
input_bits= 2
len(clauses)= 79
3 is prime (unsat)
factoring 205761315
input_bits= 28
len(clauses)= 13443
factors of 205761315 are 3 and 68587105
factoring 3
input_bits= 2
len(clauses)= 79
3 is prime (unsat)
factoring 68587105
input_bits= 27
len(clauses)= 12504
factors of 68587105 are 5 and 13717421
factoring 5
input_bits= 3
len(clauses)= 168
5 is prime (unsat)
factoring 13717421
input_bits= 24
len(clauses)= 9891
factors of 13717421 are 3607 and 3803
factoring 3607
input_bits= 12
len(clauses)= 2499
3607 is prime (unsat)
factoring 3803
input_bits= 12
len(clauses)= 2499
3803 is prime (unsat)
[2, 3, 3, 5, 3607, 3803]
_PRE_END

<p>So, 1234567890 = 2*3*3*5*3607*3803.</p>

<p>It works way faster than by Z3 solution, but still slow.
It can factor numbers up to maybe ~2^40, while Wolfram Mathematica can factor ~2^80 easily.</p>

<p>The full source code: _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/factor_SAT/factor_SAT.py').</p>

_HL2(`Division using multiplier')

<p>Hard to believe, but why we couldn't define one of factors and ask SAT solver to find another factor?
Then it will divide numbers!
But, unfortunately, this is somewhat impractical, since it will work only if reaminder is zero:</p>

_PRE_BEGIN
def div(dividend,divisor):
    global clauses, last_var, const_false

    clauses=[]
    last_var=1

    # allocate a single variable fixed to False:
    const_false=create_var()
    var_always(const_false,False)

    # size of inputs.
    # in other words, how many bits we have to allocate to store 'n'?
    input_bits=int(math.ceil(math.log(dividend,2)))
    print "input_bits=", input_bits

    factor1,factor2=alloc_BV(input_bits),alloc_BV(input_bits)
    product=multiplier(factor1,factor2)

    # connect divisor to one of multiplier's input:
    BV_always(factor1, n_to_BV(divisor,input_bits))
    # output has a size twice as bigger as each input.
    # connect dividend to multiplier's output:
    BV_always(product, n_to_BV(dividend,input_bits*2))

    solution=solve(clauses)
    if solution==None:
        print "remainder!=0 (unsat)"
        return None

    # get 2nd input of multiplier, which is quotient:
    return BV_to_number(get_BV_from_solution(factor2, solution))

print div (12345678901234567890123456789*12345, 12345)
_PRE_END

<p>The full source code: _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/factor_SAT/div.py').</p>

<p>It works very fast, but still, slower than conventional ways.</p>

_HL2(`Breaking RSA')

<p>It's not a problem to build multiplier with 4096 bit inputs and 8192 output, but it will not work in practice.
Still, you can break toy-level demonstrational RSA problems with key less than 2^40 or something like that (or larger, using Wolfram Mathematica).<p>

_HL2(`Further reading')

<p>_HTML_LINK_AS_IS(`https://yurichev.com/mirrors/SAT_factor/Encoding%20Basic%20Arithmetic%20Operations%20for%20SAT-Solvers.pdf')</p>
<p>_HTML_LINK_AS_IS(`https://yurichev.com/mirrors/SAT_factor/Factoring%20integers%20with%20parallel%20SAT%20solvers.pdf')</p>
<p>_HTML_LINK_AS_IS(`https://yurichev.com/mirrors/SAT_factor/Hard%20Instance%20Generation%20for%20SAT.pdf')</p>

_BLOG_FOOTER()

