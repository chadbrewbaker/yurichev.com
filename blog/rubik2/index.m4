m4_include(`commons.m4')

_HEADER_HL1(`Rubik’s cube (3*3*3) and Z3 SMT-solver, part II')

_COPYPASTED2()

<p>Previously: _HTML_LINK_AS_IS(`https://yurichev.com/blog/rubik/').</p>

<p>As I wrote before, I couldn't solve even 2*2*2 pocket cube with Z3, but I wanted to play with it further, and found
that it's still possible to solve one face instead of all 6.</p>

<p>I tried to model color of each facelet using integer sort (type), but now I can use bool: white facelet is True and all other non-white is False.
I can encode state of Rubik's cube like that: "W" for white facelet, "." for other.</p>

<p>Now the process of solving is a matter of minutes on a decent computer, or faster.</p>

_PRE_BEGIN
#!/usr/bin/env python

from z3 import *

FACES=6
FACELETS=9

def rotate_FCW(s):
        return [
                [ s[0][6], s[0][3], s[0][0], s[0][7], s[0][4], s[0][1], s[0][8], s[0][5], s[0][2], ],  # new F
                [ s[1][0], s[1][1], s[1][2], s[1][3], s[1][4], s[1][5], s[4][8], s[4][5], s[4][2], ],  # new U
                [ s[3][6], s[3][3], s[3][0], s[2][3], s[2][4], s[2][5], s[2][6], s[2][7], s[2][8], ],  # new D
                [ s[1][6], s[3][1], s[3][2], s[1][7], s[3][4], s[3][5], s[1][8], s[3][7], s[3][8], ],  # new R
                [ s[4][0], s[4][1], s[2][0], s[4][3], s[4][4], s[2][1], s[4][6], s[4][7], s[2][2], ],  # new L
                [ s[5][0], s[5][1], s[5][2], s[5][3], s[5][4], s[5][5], s[5][6], s[5][7], s[5][8], ] ] # new B

def rotate_FH(s):
        return [
                [ s[0][8], s[0][7], s[0][6], s[0][5], s[0][4], s[0][3], s[0][2], s[0][1], s[0][0], ],
                [ s[1][0], s[1][1], s[1][2], s[1][3], s[1][4], s[1][5], s[2][2], s[2][1], s[2][0], ],
                [ s[1][8], s[1][7], s[1][6], s[2][3], s[2][4], s[2][5], s[2][6], s[2][7], s[2][8], ],
                [ s[4][8], s[3][1], s[3][2], s[4][5], s[3][4], s[3][5], s[4][2], s[3][7], s[3][8], ],
                [ s[4][0], s[4][1], s[3][6], s[4][3], s[4][4], s[3][3], s[4][6], s[4][7], s[3][0], ],
                [ s[5][0], s[5][1], s[5][2], s[5][3], s[5][4], s[5][5], s[5][6], s[5][7], s[5][8], ] ]


...


def rotate(op, st, side, j):
	return If(op==0, rotate_FCW(st)[side][j],
		If(op==1, rotate_FCCW(st)[side][j],
		If(op==2, rotate_UCW(st)[side][j],
		If(op==3, rotate_UCCW(st)[side][j],
		If(op==4, rotate_DCW(st)[side][j],
		If(op==5, rotate_DCCW(st)[side][j],
		If(op==6, rotate_RCW(st)[side][j],
		If(op==7, rotate_RCCW(st)[side][j],
		If(op==8, rotate_LCW(st)[side][j],
		If(op==9, rotate_LCCW(st)[side][j],
		If(op==10, rotate_BCW(st)[side][j],
		If(op==11, rotate_BCCW(st)[side][j],
		If(op==12, rotate_FH(st)[side][j],
		If(op==13, rotate_UH(st)[side][j],
		If(op==14, rotate_DH(st)[side][j],
		If(op==15, rotate_RH(st)[side][j],
		If(op==16, rotate_LH(st)[side][j],
		If(op==17, rotate_BH(st)[side][j],
			rotate_BH(st)[side][j], # default
			))))))))))))))))))

move_names=["FCW", "FCCW", "UCW", "UCCW", "DCW", "DCCW", "RCW", "RCCW", "LCW", "LCCW", "BCW", "BCCW", "FH", "UH", "DH", "RH", "LH", "BH"]

def colors_to_array_of_ints(s):
    rt=[]
    for c in s:
	if c=='W':
            rt.append(True)
        else:
            rt.append(False)
    return rt

def set_current_state (d):
    F=colors_to_array_of_ints(d["F"])
    U=colors_to_array_of_ints(d["U"])
    D=colors_to_array_of_ints(d["D"])
    R=colors_to_array_of_ints(d["R"])
    L=colors_to_array_of_ints(d["L"])
    B=colors_to_array_of_ints(d["B"])
    return F,U,D,R,L,B # return tuple

init_F, init_U, init_D, init_R, init_L, init_B=set_current_state({"F":"....W..W.", "U":"...W...W.", "D":".......W.", "R":"..W...W..", "L":"......W..", "B":"..W......"})

for STEPS in range(1, 20):
	print "trying %d steps" % STEPS

	s=Solver()
	state=[[[Bool('state%d_%d_%d' % (n, side, i)) for i in range(FACELETS)] for side in range(FACES)] for n in range(STEPS+1)]

	op=[Int('op%d' % n) for n in range(STEPS+1)]

	# initial state
	for i in range(FACELETS):
		s.add(state[0][0][i]==init_F[i])
		s.add(state[0][1][i]==init_U[i])
		s.add(state[0][2][i]==init_D[i])
		s.add(state[0][3][i]==init_R[i])
		s.add(state[0][4][i]==init_L[i])
		s.add(state[0][5][i]==init_B[i])

	# "must be" state for one (front/white) face
	for j in range(FACELETS):
		s.add(state[STEPS][0][j]==True)

	for n in range(STEPS):
		for side in range(FACES):
			for j in range(FACELETS):
				s.add(state[n+1][side][j]==rotate(op[n], state[n], side, j))

	if s.check()==sat:
		print "sat"
		m=s.model()
		for n in range(STEPS):
			print move_names[int(str(m[op[n]]))]
		exit(0)
_PRE_END

<p>( The full source code: _HTML_LINK_AS_IS(`https://github.com/DennisYurichev/yurichev.com/blob/master/blog/rubik2/rubik3_z3.py') )</p>

<p>Now the fun statistics.
Using random walk I collected 928 states and then I tried to solve one (white/front) face for each state.</p>

_PRE_BEGIN
      1 turns= 4
      5 turns= 5
     57 turns= 6
    307 turns= 7
    501 turns= 8
     56 turns= 9
      1 turns= 10
_PRE_END

<p>It seems that majority of all states can be solved for 7-8 half turns (half-turn is one of 18 turns we used here).
But there is at least one state which must be solved with 10 half turns.
Maybe 10 is a "_HTML_LINK(`http://www.cube20.org/',`god’s number')" for one face, like 20 for all 6 faces?</p>

<p>My other notes about SAT/SMT: _HTML_LINK_AS_IS(`https://yurichev.com/writings/SAT_SMT_draft-EN.pdf')</p>

_BLOG_FOOTER()

