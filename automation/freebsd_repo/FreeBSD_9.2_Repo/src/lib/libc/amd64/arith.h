/*
 * MD header for contrib/gdtoa
 *
 * $FreeBSD: releng/9.2/lib/libc/amd64/arith.h 114839 2003-05-08 13:50:44Z das $
 */

/*
 * NOTE: The definitions in this file must be correct or strtod(3) and
 * floating point formats in printf(3) will break!  The file can be
 * generated by running contrib/gdtoa/arithchk.c on the target
 * architecture.  See contrib/gdtoa/gdtoaimp.h for details.
 */

#define IEEE_8087
#define Arith_Kind_ASL 1
#define Long int
#define Intcast (int)(long)
#define Double_Align
#define X64_bit_pointers
