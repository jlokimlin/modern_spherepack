!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 1998 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                      SPHEREPACK version 3.2                   *
!     *                                                               *
!     *       A Package of Fortran77 Subroutines and Programs         *
!     *                                                               *
!     *              for Modeling Geophysical Processes               *
!     *                                                               *
!     *                             by                                *
!     *                                                               *
!     *                  John Adams and Paul Swarztrauber             *
!     *                                                               *
!     *                             of                                *
!     *                                                               *
!     *         the National Center for Atmospheric Research          *
!     *                                                               *
!     *                Boulder, Colorado  (80307)  U.S.A.             *
!     *                                                               *
!     *                   which is sponsored by                       *
!     *                                                               *
!     *              the National Science Foundation                  *
!     *                                                               *
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
!
!
! ... file idvtgc.f
!
!     this file includes documentation and code for
!     subroutine idvtgc         i
!
! ... files which must be loaded with idvtgc.f
!
!     sphcom.f, hrfft.f, vhsgc.f, shagc.f, gaqd.f
!
!
!     subroutine idvtgc(nlat, nlon, isym, nt, v, w, idvw, jdvw, ad, bd, av, bv, 
!    +mdab, ndab, wvhsgc, lvhsgc, work, lwork, pertbd, pertbv, ierror)
!
!     given the scalar spherical harmonic coefficients ad, bd precomputed
!     by subroutine shagc for the scalar field divg and coefficients av, bv
!     precomputed by subroutine shagc for the scalar field vort, subroutine
!     idvtgc computes a vector field (v, w) whose divergence is divg - pertbd
!     and whose vorticity is vort - pertbv.  w the is east longitude component
!     and v is the colatitudinal component of the velocity.  if nt=1 (see nt
!     below) pertrbd and pertbv are constants which must be subtracted from
!     divg and vort for (v, w) to exist (see the description of pertbd and
!     pertrbv below).  usually pertbd and pertbv are zero or small relative
!     to divg and vort.  w(i, j) and v(i, j) are the velocity components at
!     gaussian colatitude theta(i) (see nlat as input argument) and longitude
!     lambda(j) = (j-1)*2*pi/nlon
!
!     the
!
!            divergence(v(i, j), w(i, j))
!
!         =  [d(sint*v)/dtheta + dw/dlambda]/sint
!
!         =  divg(i, j) - pertbd
!
!     and
!
!            vorticity(v(i, j), w(i, j))
!
!         =  [-dv/dlambda + d(sint*w)/dtheta]/sint
!
!         =  vort(i, j) - pertbv
!
!     where
!
!            sint = cos(theta(i)).
!
!
!     input parameters
!
!     nlat   the number of points in the gaussian colatitude grid on the
!            full sphere. these lie in the interval (0, pi) and are computed
!            in radians in theta(1) <...< theta(nlat) by subroutine gaqd.
!            if nlat is odd the equator will be included as the grid point
!            theta((nlat+1)/2).  if nlat is even the equator will be
!            excluded as a grid point and will lie half way between
!            theta(nlat/2) and theta(nlat/2+1). nlat must be at least 3.
!            note: on the half sphere, the number of grid points in the
!            colatitudinal direction is nlat/2 if nlat is even or
!            (nlat+1)/2 if nlat is odd.
!
!     nlon   the number of distinct londitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater
!            than 3. the axisymmetric case corresponds to nlon=1.
!            the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!
!     isym   isym determines whether (v, w) are computed on the full or half
!            sphere as follows:
!
!      = 0
!            divg, vort are neither pairwise symmetric/antisymmetric nor
!            antisymmetric/symmetric about the equator as described for
!            isym = 1 or isym = 2  below.  in this case, the vector field
!            (v, w) is computed on the entire sphere.  i.e., in the arrays
!            w(i, j) and v(i, j) i=1, ..., nlat and j=1, ..., nlon.
!
!      = 1
!
!            divg is antisymmetric and vort is symmetric about the equator.
!            in this case w is antisymmetric and v is symmetric about the
!            equator.  w and v are computed on the northern hemisphere only.
!            if nlat is odd they are computed for i=1, ..., (nlat+1)/2
!            and j=1, ..., nlon.  if nlat is even they are computed for
!            i=1, ..., nlat/2 and j=1, ..., nlon.
!
!      = 2
!
!            divg is symmetric and vort is antisymmetric about the equator.
!            in this case w is symmetric and v is antisymmetric about the
!            equator.  w and v are computed on the northern hemisphere only.
!            if nlat is odd they are computed for i=1, ..., (nlat+1)/2
!            and j=1, ..., nlon.  if nlat is even they are computed for
!            i=1, ..., nlat/2 and j=1, ..., nlon.
!
!
!     nt     in the program that calls idvtgc, nt is the number of scalar
!            and vector fields.  some computational efficiency is obtained
!            for multiple fields.  the arrays ad, bd, av, bv, u, and v can be
!            three dimensional and pertbd, pertbv can be one dimensional
!            corresponding to indexed multiple arrays divg, vort.  in this
!            case, multiple synthesis will be performed to compute each
!            vector field.  the third index for ad, bd, av, bv, v, w and first
!            pertrbd, pertbv is the synthesis index which assumes the values
!            k=1, ..., nt.  for a single synthesis set nt=1. the description of
!            remaining parameters is simplified by assuming that nt=1 or that
!            ad, bd, av, bv, v, w are two dimensional and pertbd, pertbv are
!            constants.
!
!     idvw   the first dimension of the arrays v, w as it appears in
!            the program that calls idvtgc. if isym = 0 then idvw
!            must be at least nlat.  if isym = 1 or 2 and nlat is
!            even then idvw must be at least nlat/2. if isym = 1 or 2
!            and nlat is odd then idvw must be at least (nlat+1)/2.
!
!     jdvw   the second dimension of the arrays v, w as it appears in
!            the program that calls idvtgc. jdvw must be at least nlon.
!
!     ad, bd  two or three dimensional arrays (see input parameter nt)
!            that contain scalar spherical harmonic coefficients
!            of the divergence array divg as computed by subroutine shagc.
!
!     av, bv  two or three dimensional arrays (see input parameter nt)
!            that contain scalar spherical harmonic coefficients
!            of the vorticity array vort as computed by subroutine shagc.
!     ***    ad, bd, av, bv must be computed by shagc prior to calling idvtgc.
!
!     mdab   the first dimension of the arrays ad, bd, av, bv as it appears
!            in the program that calls idvtgc (and shagc). mdab must be at
!            least min(nlat, (nlon+2)/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!     ndab   the second dimension of the arrays ad, bd, av, bv as it appears in
!            the program that calls idvtgc (and shagc). ndab must be at
!            least nlat.
!
!  wvhsgc    an array which must be initialized by subroutine vhsgci.
!            wvhsgc can be used repeatedly by idvtgc as long as nlon
!            and nlat remain unchanged.  wvhsgc must not be altered
!            between calls of idvtgc.
!
!
!  lvhsgc    the dimension of the array wvhsgc as it appears in the
!            program that calls idvtgc. define
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd
!
!            then lvhsgc must be at least
!
!               4*nlat*l2+3*max(l1-2, 0)*(2*nlat-l1-1)+nlon+15
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls idvtgc. define
!
!               l2 = nlat/2                    if nlat is even or
!               l2 = (nlat+1)/2                if nlat is odd
!               l1 = min(nlat, nlon/2)       if nlon is even or
!               l1 = min(nlat, (nlon+1)/2)   if nlon is odd
!
!
!            if isym = 0 then lwork must be at least
!
!              l2*(2*nt*nlon+max(6*nlat, nlon))+nlat*(4*nt*l1+1)
!
!            if isym = 1 or 2 then lwork must be at least
!
!              nlat*(2*nt*nlon+max(6*l2, nlon)+4*nt*l1+1)
!
!
!     **************************************************************
!
!     output parameters
!
!
!     v, w   two or three dimensional arrays (see input parameter nt) that
!           contain a vector field whose divergence is divg - pertbd and
!           whose vorticity is vort - pertbv.  w(i, j) is the east longitude
!           component and v(i, j) is the colatitudinal component of velocity
!           at the colatitude theta(i) = (i-1)*pi/(nlat-1) and longitude
!           lambda(j) = (j-1)*2*pi/nlon for i=1, ..., nlat and j=1, ..., nlon.
!
!   pertbd  a nt dimensional array (see input parameter nt and assume nt=1
!           for the description that follows).  divg - pertbd is a scalar
!           field which can be the divergence of a vector field (v, w).
!           pertbd is related to the scalar harmonic coefficients ad, bd
!           of divg (computed by shagc) by the formula
!
!                pertbd = ad(1, 1)/(2.*sqrt(2.))
!
!           an unperturbed divg can be the divergence of a vector field
!           only if ad(1, 1) is zero.  if ad(1, 1) is nonzero (flagged by
!           pertbd nonzero) then subtracting pertbd from divg yields a
!           scalar field for which ad(1, 1) is zero.  usually pertbd is
!           zero or small relative to divg.
!
!   pertbv a nt dimensional array (see input parameter nt and assume nt=1
!           for the description that follows).  vort - pertbv is a scalar
!           field which can be the vorticity of a vector field (v, w).
!           pertbv is related to the scalar harmonic coefficients av, bv
!           of vort (computed by shagc) by the formula
!
!                pertbv = av(1, 1)/(2.*sqrt(2.))
!
!           an unperturbed vort can be the vorticity of a vector field
!           only if av(1, 1) is zero.  if av(1, 1) is nonzero (flagged by
!           pertbv nonzero) then subtracting pertbv from vort yields a
!           scalar field for which av(1, 1) is zero.  usually pertbv is
!           zero or small relative to vort.
!
!    ierror = 0  no errors
!           = 1  error in the specification of nlat
!           = 2  error in the specification of nlon
!           = 3  error in the specification of isym
!           = 4  error in the specification of nt
!           = 5  error in the specification of idvw
!           = 6  error in the specification of jdvw
!           = 7  error in the specification of mdab
!           = 8  error in the specification of ndab
!           = 9  error in the specification of lvhsgc
!           = 10 error in the specification of lwork
! **********************************************************************
!                                                                              
!   
subroutine idvtgc(nlat, nlon, isym, nt, v, w, idvw, jdvw, ad, bd, av, bv, &
mdab, ndab, wvhsgc, lvhsgc, work, lwork, pertbd, pertbv, ierror)
dimension w(idvw, jdvw, nt), v(idvw, jdvw, nt), pertbd(nt), pertbv(nt)
dimension ad(mdab, ndab, nt), bd(mdab, ndab, nt)
dimension av(mdab, ndab, nt), bv(mdab, ndab, nt)
dimension wvhsgc(lvhsgc), work(lwork)
!
!     check input parameters
!
ierror = 1
if(nlat < 3) return
ierror = 2
if(nlon < 4) return
ierror = 3
if(isym<0 .or. isym>2) return
ierror = 4
if(nt < 0) return
ierror = 5
imid = (nlat+1)/2
if((isym==0 .and. idvw<nlat) .or. &
   (isym/=0 .and. idvw<imid)) return
ierror = 6
if(jdvw < nlon) return
ierror = 7
mmax = min(nlat, (nlon+1)/2)
if(mdab < min(nlat, (nlon+2)/2)) return
ierror = 8
if(ndab < nlat) return
ierror = 9
lzz1 = 2*nlat*imid
labc = 3*(max(mmax-2, 0)*(nlat+nlat-mmax-1))/2
if(lvhsgc < 2*(lzz1+labc)+nlon+15) return
ierror = 10
!
!     verify unsaved work space length
!
mn = mmax*nlat*nt
if(isym/=0  .and. lwork < &
nlat*(2*nt*nlon+max(6*imid, nlon))+4*mn+nlat) return
if(isym==0  .and. lwork < &
imid*(2*nt*nlon+max(6*nlat, nlon))+4*mn+nlat) return
ierror = 0
!
!     set work space pointers
!
ibr = 1
ibi = ibr+mn
icr = ibi+mn
ici = icr + mn
is = ici + mn
iwk = is + nlat
liwk = lwork-4*mn-nlat
call idvtgc1(nlat, nlon, isym, nt, v, w, idvw, jdvw, work(ibr), &
work(ibi), work(icr), work(ici), mmax, work(is), mdab, ndab, ad, bd, &
av, bv, wvhsgc, lvhsgc, work(iwk), liwk, pertbd, pertbv, ierror)
return
end subroutine idvtgc

subroutine idvtgc1(nlat, nlon, isym, nt, v, w, idvw, jdvw, br, bi, &
cr, ci, mmax, sqnn, mdab, ndab, ad, bd, av, bv, wvhsgc, lvhsgc, wk, lwk, &
pertbd, pertbv, ierror)
dimension w(idvw, jdvw, nt), v(idvw, jdvw, nt)
dimension br(mmax, nlat, nt), bi(mmax, nlat, nt), sqnn(nlat)
dimension cr(mmax, nlat, nt), ci(mmax, nlat, nt)
dimension ad(mdab, ndab, nt), bd(mdab, ndab, nt)
dimension av(mdab, ndab, nt), bv(mdab, ndab, nt)
dimension wvhsgc(lvhsgc), wk(lwk)
dimension pertbd(nt), pertbv(nt)
!
!     preset coefficient multiplyers in vector
!
do 1 n=2, nlat
fn = real(n-1)
sqnn(n) = sqrt(fn*(fn+1.))
1 continue
!
!     compute multiple vector fields coefficients
!
do 2 k=1, nt
!
!     set divergence, vorticity perturbation constants
!
pertbd(k) = ad(1, 1, k)/(2.*sqrt(2.))
pertbv(k) = av(1, 1, k)/(2.*sqrt(2.))
!
!     preset br, bi, cr, ci to 0.0
!
do 3 n=1, nlat
do 4 m=1, mmax
br(m, n, k) = 0.0
bi(m, n, k) = 0.0
cr(m, n, k) = 0.0
ci(m, n, k) = 0.0
4 continue
3 continue
!
!     compute m=0 coefficients
!
do 5 n=2, nlat
br(1, n, k) = -ad(1, n, k)/sqnn(n)
bi(1, n, k) = -bd(1, n, k)/sqnn(n)
cr(1, n, k) = av(1, n, k)/sqnn(n)
ci(1, n, k) = bv(1, n, k)/sqnn(n)
5 continue
!
!     compute m>0 coefficients
!
do 6 m=2, mmax
do 7 n=m, nlat
br(m, n, k) = -ad(m, n, k)/sqnn(n)
bi(m, n, k) = -bd(m, n, k)/sqnn(n)
cr(m, n, k) = av(m, n, k)/sqnn(n)
ci(m, n, k) = bv(m, n, k)/sqnn(n)
7 continue
6 continue
2 continue
!
!     set ityp for vector synthesis without assuming div=0 or curl=0
!
if (isym==0) then
ityp = 0
else if (isym==1) then
ityp = 3
else if (isym==2) then
ityp = 6
end if
!
!     sythesize br, bi, cr, ci into the vector field (v, w)
!
call vhsgc(nlat, nlon, ityp, nt, v, w, idvw, jdvw, br, bi, cr, ci, &
           mmax, nlat, wvhsgc, lvhsgc, wk, lwk, ierror)
return
end subroutine idvtgc1
