# This is ksb's infamous sed calculator.		(ksb@sa.fedex.com)
#
# $FreeBSD: releng/9.2/tools/regression/usr.bin/sed/math.sed 167533 2007-03-14 07:40:44Z dds $
#
# $Id: math.sed,v 2.5 1998/08/02 13:23:34 ksb Exp ksb $
# expr ::= (expr) | expr! |
#	expr ^ expr |
#	-expr | expr * expr | expr / expr | expr % expr |
#	expr + expr | expr - expr |
#	[0-9][0-9]* ;
# Bugs: some sign combinations don't work, and I got sick of added cases
# for unary +.  Don't depend on signed math working all the time. -- ksb
#
# $Compile: echo "4+7*3+2^7/3" | sed -f %f

# make sure the expression is well formed
s/[ 	]//g
/[*\/^%+-]$/{
	a\
	poorly formed expression, dyadic operator on the end
	q
}
/^[*\/^%]/{
	a\
	poorly formed expression, leading dyadic operator
	q
}

# fill hold space with done token
x
s/^.*/done/
x

# main loop, process operators ((), !, *, /, %, +, and -)
: loop
# uncomment the print below to follow the "logic" -- ksb
#p
/^[+]/{
	s///
	b loop
}
/^--/{
	s///
	b loop
}
# eval parenthesised sub expressions first
/^\(.*\)(\([^)]*\))\(.*\)$/{
	H
	s//\2/
	x
	s/^\(.*\)\n\(.*\)(\([^()]*\))\(.*\)$/()\2@\4@\1/
	x
	b loop
}
# reduce a^b^c -> a^(b^c)
/\([0-9][0-9]*^\)\([0-9][0-9]*^[0-9][0-9^]*\)/{
	s//\1(\2)/
	b loop
}
# pull any burried exponents
/^\(.*[^0-9]\)\([0-9][0-9]*^[0-9][0-9]*\)$/{
	s//\1(\2)/
	b loop
}
/^\(.*[^0-9]\)\([0-9][0-9]*^[0-9][0-9]*\)\([^0-9].*\)$/{
	s//\1(\2)\3/
	b loop
}
/^\([0-9][0-9]*^[0-9][0-9]*\)\([^0-9].*\)$/{
	s//(\1)\2/
	b loop
}
/^\([-]*[0-9]*\)^0*$/{
	s//1/
	b loop
}
/^\([-]*[0-9]*\)^0*1$/{
	s//\1/
	b loop
}
/^\([-]*[0-9]*\)^-[0-9]*$/{
	s//0/
	b loop
}
/^\([-]*\)\([0-9]*\)^\([0-9][0-9]*[13579]\)$/{
	s//\1\2*((\2*\2)^(\3\/2))/
	b loop
}
/^[-]*\([0-9]*\)^\([0-9][0-9]*[02468]\)$/{
	s//(\1*\1)^(\2\/2)/
	b loop
}
# single digit powers (2  3,9  4,6,8   5,7
/^[-]*\([0-9]*\)^0*2$/{
	s//(\1*\1)/
	b loop
}
/^\([-]*\)\([0-9]*\)^0*\([39]\)$/{
	s//\1(\2*(\2*\2))^(\3\/3)/
	b loop
}
/^[-]*\([0-9]*\)^0*\([468]\)$/{
	s//(\1*\1)^(\2\/2)/
	b loop
}
# 5 7 
/^\([-]*[0-9]*\)^\([0-9]*\)$/{
	s//\1*(\1^(\2-1))/
	b loop
}
# reduce all number factorials
/^0*[01]!/{
	s//1/
	b loop
}
/\([*+-/%^]\)0*[01]!/{
	s//\11/
	b loop
}
/\([0-9]*\)!/{
	s//(\1-1)!*\1/
	b loop
}
# sign simplifications
/^-\([0-9]*\)\([*/%]\)-\([0-9]*\)$/{
	s//\1\2\3/
	b loop
}
/^\([0-9]*\)\([*/%]\)-\([0-9]*\)$/{
	s//-\1\2\3/
	b loop
}
/^-\([0-9][0-9]*\)[+]*-\([0-9][0-9]*\)$/{
	s//\1+\2/
	x
	s/\(.*\)/()-@@\1/
	x
	b loop
}
/^-\([0-9]*\)[+]\([0-9]\)*$/{
	s//\2-\1/
	b loop
}
/^-.*[-+*/%].*/{
	H
	s/^-//
	x
	s/^\(.*\)\n-.*$/()-@@\1/
	x
	b loop
}
# can we simplify multiplications
/^\([0-9]*\)\([*][0-9]*[1-9]\)00*$/{
	H
	s//\1\2/
	x
	s/^\(.*\)\n[0-9]*[*][0-9]*[1-9]\(00*\)$/()@\2@\1/
	x
	b loop
}
/^\([0-9][1-9]*\)00*\([*][0-9]*\)$/{
	H
	s//\1\2/
	x
	s/^\(.*\)\n[0-9][1-9]*\(00*\)[*][0-9]*$/()@\2@\1/
	x
	b loop
}
# can we simplify division (20/30 -> 2/3)
/^\([0-9][0-9]*\)0\([/%]\)\([0-9][0-9]*\)0$/{
	s//\1\2\3/
	b loop
}
# n/1 -> n
/^0*\([0-9][0-9]*\)0[/]0*1$/{
	s//\1/
	b loop
}
# n%2 -> last_digit(n)%2 (same for 1, BTW) N.B. NO LOOP
/^[0-9]*\([0-9]\)%0*\([12]\)$/{
	s//\1%\2/
}
# move any mul/divs to the front via parans
/^\([0-9+]*\)\([-+]\)\([0-9]*[*/][0-9*/]*\)/{
	s//\1\2(\3)/
	b loop
}
# can we div or mul
/^[0-9]*[*][0-9]*$/{
	b mul
}
/^[0-9]*[/%]0*$/{
	i\
divide by zero
	d
}
/^[0-9]*[/%][0-9]*$/{
	H
	s/\([0-9]\).*[/%]/\1-/
	x
	s/^\(.*\)\n\([0-9]\)\([0-9]*\)\([/%]\)\([0-9]*\).*$/.\4\3q0r\2-\5@\1/
	x
	b loop
}
/^\([0-9]*[*/%][0-9]*\)\(.*\)/{
	H
	s//\1/
	x
	s/^\(.*\)\n\([0-9]*[*/][0-9]*\)\(.*\)$/()@\3@\1/
	x
	b loop
}
# can we add or subtract -- note subtract hold expression for underflow
/^[0-9]*[+][0-9]*$/{
	s/$/=/
	b add
}
/^[0-9][0-9]*-[0-9]*$/{
	H
	s/$/=/
	b sub
}
/^\([0-9][0-9]*[-+][0-9]*\)\(.*\)/{
	H
	s//\1/
	x
	s/^\(.*\)\n\([0-9]*[-+][0-9]*\)\(.*\)$/()@\3@\1/
	x
	b loop
}
# look in hold space for stack to reduce
x
/^done$/{
	x
	s/^0*\([0-9][0-9]*\)/\1/
	p
	d
}
# .[/%] numerator q quotient r remainder-divisor @stack
/^\./{
	x
	/^[^-]/{
		H
		x
		s/.\(.\)\([0-9]*\)q\([^r]*\)r\([0-9]*\)-\([0-9]*\)@\(.*\)\n\(.*\)/.\1\2q\3+1r\7-\5@\6/
		h
		s/..[0-9]*q[^r]*r\([0-9]*-[0-9]*\)@.*/\1/
		b loop
	}
	/^-/{
		g
		/.\(.\)\([0-9]\)\([0-9]*\)q\([^r]*\)r0*\([0-9]*\)-\([^@]*\)@.*/{
			s//\5\2-\6/
			x
			s/.\(.\)\([0-9]\)\([0-9]*\)q\([^r]*\)r0*\([0-9]*\)-\([0-9]*\)@\(.*\)/.\1\3q(\4)*10r\5\2-\6@\7/
			x
			b loop
		}
# no digits to shift on
		s/^\.[/]q\([^r]*\)r[^@]*@.*/\1/
		s/^\.[%]q[^r]*r0*\([0-9][0-9]*\)-[^@]*@.*/\1/
		/^\./{
			i\
divide error
			q
		}
		x
		s/^\.[/%]q[^r]*r[^@]*@\(.*\)/\1/
		x
		b loop
	}
}
/^()/{
	s///
	x
	G
	s/\(.*\)\n\([^@]*\)@\([^@]*\)@\(.*\)/\2\1\3/
	x
	s/[^@]*@[^@]*@\(.*\)/\1/
	x
	b loop
}
i\
help, stack problem - the hold space
p
x
i\
and the pat space
p
i\
quit
q

# turn mul into add until 1*x -> x, 0*x -> 0
: mul
/^00*\*.*/{
	s//0/
	b loop
}
/^0*1\*/{
	s///
: leading
	s/^0*\([0-9][0-9]*\)/\1/
	b loop
}
s/^\([0-9]*\)0\*\([0-9]*\)/\1*\20/
s/^\([0-9]*\)1\*\([0-9]*\)/\1*\20+\2/
s/^\([0-9]*\)2\*\([0-9]*\)/\1*\20+(\2+\2)/
s/^\([0-9]*\)3\*\([0-9]*\)/\1*\20+(\2+\2+\2)/
s/^\([0-9]*\)4\*\([0-9]*\)/\1*\20+(\2+\2+\2+\2)/
s/^\([0-9]*\)5\*\([0-9]*\)/\1*\20+(\2+\2+\2+\2+\2)/
s/^\([0-9]*\)6\*\([0-9]*\)/\1*\20+(\2+\2+\2+\2+\2+\2)/
s/^\([0-9]*\)7\*\([0-9]*\)/\1*\20+(\2+\2+\2+\2+\2+\2+\2)/
s/^\([0-9]*\)8\*\([0-9]*\)/\1*\20+(\2+\2+\2+\2+\2+\2+\2+\2)/
s/^\([0-9]*\)9\*\([0-9]*\)/\1*\20+(\2+\2+\2+\2+\2+\2+\2+\2+\2)/
/^0*\*[0-9]*[+]*\(.*\)/{
	s//\1/
	b loop
}
b mul

# get rid of a plus term until 0+x -> x
: add
/^[+]\([0-9+*]*\)=/{
	s//\1/
	b leading
}
/^\([0-9*]*\)[+]=/{
	s//\1/
	b loop
}
/^\([0-9]*\)0[+]\([0-9]*\)\([0-9]\)=/{
	s//\1+\2=\3/
	b add
}
/^\([0-9]*\)\([0-9]\)[+]\([0-9]*\)0=/{
	s//\1+\3=\2/
	b add
}
s/^\([0-9]*\)1[+]/\10+/
s/^\([0-9]*\)2[+]/\11+/
s/^\([0-9]*\)3[+]/\12+/
s/^\([0-9]*\)4[+]/\13+/
s/^\([0-9]*\)5[+]/\14+/
s/^\([0-9]*\)6[+]/\15+/
s/^\([0-9]*\)7[+]/\16+/
s/^\([0-9]*\)8[+]/\17+/
s/^\([0-9]*\)9[+]/\18+/

s/9=\([0-9]*\)$/_=\1/
s/8=\([0-9]*\)$/9=\1/
s/7=\([0-9]*\)$/8=\1/
s/6=\([0-9]*\)$/7=\1/
s/5=\([0-9]*\)$/6=\1/
s/4=\([0-9]*\)$/5=\1/
s/3=\([0-9]*\)$/4=\1/
s/2=\([0-9]*\)$/3=\1/
s/1=\([0-9]*\)$/2=\1/
/_/{
	s//_0/
	: inc
	s/9_/_0/
	s/8_/9/
	s/7_/8/
	s/6_/7/
	s/5_/6/
	s/4_/5/
	s/3_/4/
	s/2_/3/
	s/1_/2/
	s/0_/1/
	s/[+]_/+1/
	/_/b inc
}
b add

# get rid of a sub term until /-0*=/ or underflow
: sub
/^\([0-9]*\)-0*=/{
	s//\1/
	x
	s/\(.*\)\n.*$/\1/
	x
	b leading
}
/^-\([0-9].*\)=/{
: under
	g
	s/.*\n\([0-9]*\)-\([0-9]*\).*/-(\2-\1)/
	x
	s/\(.*\)\n.*/\1/
	x
	b loop
}
/^\([0-9]*\)\([0-9]\)-\([0-9]*\)0=/{
	s//\1-\3=\2/
	b sub
}
s/1=/0=/
s/2=/1=/
s/3=/2=/
s/4=/3=/
s/5=/4=/
s/6=/5=/
s/7=/6=/
s/8=/7=/
s/9=/8=/

s/^\([0-9]*\)1-/\1_-/
s/^\([0-9]*\)2-/\11-/
s/^\([0-9]*\)3-/\12-/
s/^\([0-9]*\)4-/\13-/
s/^\([0-9]*\)5-/\14-/
s/^\([0-9]*\)6-/\15-/
s/^\([0-9]*\)7-/\16-/
s/^\([0-9]*\)8-/\17-/
s/^\([0-9]*\)9-/\18-/
s/^\([0-9]*\)0-/\1'9-/
s/_/0/

: scarry
/0'/{
	s//'9/
	b scarry
}
/^'/{
	b under
}
s/1'/0/
s/2'/1/
s/3'/2/
s/4'/3/
s/5'/4/
s/6'/5/
s/7'/6/
s/8'/7/
s/9'/8/

b sub
