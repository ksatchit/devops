/*	$FreeBSD: releng/9.2/sys/netipsec/ah_var.h 252693 2013-07-04 08:59:34Z ae $	*/
/*	$OpenBSD: ip_ah.h,v 1.29 2002/06/09 16:26:10 itojun Exp $	*/
/*-
 * The authors of this code are John Ioannidis (ji@tla.org),
 * Angelos D. Keromytis (kermit@csd.uch.gr) and
 * Niels Provos (provos@physnet.uni-hamburg.de).
 *
 * The original version of this code was written by John Ioannidis
 * for BSD/OS in Athens, Greece, in November 1995.
 *
 * Ported to OpenBSD and NetBSD, with additional transforms, in December 1996,
 * by Angelos D. Keromytis.
 *
 * Additional transforms and features in 1997 and 1998 by Angelos D. Keromytis
 * and Niels Provos.
 *
 * Additional features in 1999 by Angelos D. Keromytis.
 *
 * Copyright (C) 1995, 1996, 1997, 1998, 1999 John Ioannidis,
 * Angelos D. Keromytis and Niels Provos.
 * Copyright (c) 2001 Angelos D. Keromytis.
 *
 * Permission to use, copy, and modify this software with or without fee
 * is hereby granted, provided that this entire notice is included in
 * all copies of any software which is or includes a copy or
 * modification of this software.
 * You may use this code under the GNU public license if you so wish. Please
 * contribute changes back to the authors under this freer than GPL license
 * so that we may further the use of strong encryption without limitations to
 * all.
 *
 * THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTY. IN PARTICULAR, NONE OF THE AUTHORS MAKES ANY
 * REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE
 * MERCHANTABILITY OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR
 * PURPOSE.
 */

#ifndef _NETIPSEC_AH_VAR_H_
#define _NETIPSEC_AH_VAR_H_

/*
 * These define the algorithm indices into the histogram.  They're
 * presently based on the PF_KEY v2 protocol values which is bogus;
 * they should be decoupled from the protocol at which time we can
 * pack them and reduce the size of the array to a minimum.
 */
#define	AH_ALG_MAX	16

struct ahstat {
	u_int32_t	ahs_hdrops;	/* Packet shorter than header shows */
	u_int32_t	ahs_nopf;	/* Protocol family not supported */
	u_int32_t	ahs_notdb;
	u_int32_t	ahs_badkcr;
	u_int32_t	ahs_badauth;
	u_int32_t	ahs_noxform;
	u_int32_t	ahs_qfull;
	u_int32_t	ahs_wrap;
	u_int32_t	ahs_replay;
	u_int32_t	ahs_badauthl;	/* Bad authenticator length */
	u_int32_t	ahs_input;	/* Input AH packets */
	u_int32_t	ahs_output;	/* Output AH packets */
	u_int32_t	ahs_invalid;	/* Trying to use an invalid TDB */
	u_int64_t	ahs_ibytes;	/* Input bytes */
	u_int64_t	ahs_obytes;	/* Output bytes */
	u_int32_t	ahs_toobig;	/* Packet got larger than IP_MAXPACKET */
	u_int32_t	ahs_pdrops;	/* Packet blocked due to policy */
	u_int32_t	ahs_crypto;	/* Crypto processing failure */
	u_int32_t	ahs_tunnel;	/* Tunnel sanity check failure */
	u_int32_t	ahs_hist[AH_ALG_MAX];	/* Per-algorithm op count */
};

#ifdef _KERNEL
VNET_DECLARE(int, ah_enable);
VNET_DECLARE(int, ah_cleartos);
VNET_DECLARE(struct ahstat, ahstat);

#define	AHSTAT_ADD(name, val)	V_ahstat.name += (val)
#define	AHSTAT_INC(name)	AHSTAT_ADD(name, 1)
#define	V_ah_enable		VNET(ah_enable)
#define	V_ah_cleartos		VNET(ah_cleartos)
#define	V_ahstat		VNET(ahstat)
#endif /* _KERNEL */
#endif /*_NETIPSEC_AH_VAR_H_*/
