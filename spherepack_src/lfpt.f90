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
! subroutine lfpt (n, m, theta, cp, pb)
!
! dimension of
! arguments
!                        cp((n/2)+1)
!
! purpose                routine lfpt uses coefficients computed by
!                        routine alfk to compute the single precision
!                        normalized associated legendre function pbar(n, 
!                        m, theta) at colatitude theta.
!
! usage                  call lfpt(n, m, theta, cp, pb)
!
! arguments
!
! on input               n
!                          nonnegative integer specifying the degree of
!                          pbar(n, m, theta)
!                        m
!                          is the order of pbar(n, m, theta). m can be
!                          any integer however pbar(n, m, theta) = 0
!                          if abs(m) is greater than n and
!                          pbar(n, m, theta) = (-1)**m*pbar(n, -m, theta)
!                          for negative m.
!
!                        theta
!                          single precision colatitude in radians
!
!                        cp
!                          single precision array of length (n/2)+1
!                          containing coefficients computed by routine
!                          alfk
!
! on output              pb
!                          single precision variable containing
!                          pbar(n, m, theta)
!
! special conditions     calls to routine lfpt must be preceded by an
!                        appropriate call to routine alfk.
!
! precision              single
!
! algorithm              the trigonometric series formula used by
!                        routine lfpt to calculate pbar(n, m, th) at
!                        colatitude th depends on m and n as follows:
!
!                           1) for n even and m even, the formula is
!                              .5*cp(1) plus the sum from k=1 to k=n/2
!                              of cp(k)*cos(2*k*th)
!                           2) for n even and m odd. the formula is
!                              the sum from k=1 to k=n/2 of
!                              cp(k)*sin(2*k*th)
!                           3) for n odd and m even, the formula is
!                              the sum from k=1 to k=(n+1)/2 of
!                              cp(k)*cos((2*k-1)*th)
!                           4) for n odd and m odd, the formula is
!                              the sum from k=1 to k=(n+1)/2 of
!                              cp(k)*sin((2*k-1)*th)
!
! accuracy               comparison between routines lfpt and double
!                        precision dlfpt on the cray1 indicates greater
!                        accuracy for greater values on input parameter
!                        n.  agreement to 13 places was obtained for
!                        n=10 and to 12 places for n=100.
!
! timing                 time per call to routine lfpt is dependent on
!                        the input parameter n.
!
pure subroutine lfpt(n, m, theta, cp, pb)

    use, intrinsic :: iso_fortran_env, only: &
        wp => REAL64, &
        ip => INT32

    implicit none
    !----------------------------------------------------------------------
    ! Dictionary: calling arguments
    !----------------------------------------------------------------------
    integer (ip), intent (in)  :: n
    integer (ip), intent (in)  :: m
    real (wp),    intent (in)  :: theta
    real (wp),    intent (in)  :: cp(1)
    real (wp),    intent (out) :: pb
    !----------------------------------------------------------------------
    ! Dictionary: local variables
    !----------------------------------------------------------------------
    integer (ip) :: ma, np1, k, kdo, kp1
    real (ip)    :: cos2t, sin2t, cost, sint, temp, summation
    !----------------------------------------------------------------------

    pb = 0.0_wp
    ma = abs(m)

    if (ma <= n) then
        if (n <= 0) then
            if (ma <= 0) pb= sqrt(0.5_wp)
        else
            np1 = n+1
            if (mod(n, 2) <= 0) then
                if (mod(ma, 2) <= 0) then
                    kdo = n/2+1
                    cos2t = cos(2.0_wp*theta)
                    sin2t = sin(2.0_wp*theta)
                    cost = 1.0_wp
                    sint = 0.0_wp
                    summation = 0.5_wp * cp(1)

                    do kp1=2, kdo
                        temp = cos2t*cost-sin2t*sint
                        sint = sin2t*cost+cos2t*sint
                        cost = temp
                        summation = summation+cp(kp1)*cost
                    end do

                    pb = summation
                else
                    kdo = n/2
                    cos2t = cos(2.0_wp*theta)
                    sin2t = sin(2.0_wp*theta)
                    cost = 1.0_wp
                    sint = 0.0_wp
                    summation = 0.0_wp

                    do k=1, kdo
                        temp = cos2t*cost-sin2t*sint
                        sint = sin2t*cost+cos2t*sint
                        cost = temp
                        summation = summation+cp(k)*sint
                    end do

                    pb = summation
                end if
            else
                kdo = (n+1)/2
                if (mod(ma, 2) <= 0) then
                    cos2t = cos(2.0*theta)
                    sin2t = sin(2.0*theta)
                    cost = cos(theta)
                    sint = -sin(theta)
                    summation = 0.0_wp

                    do k=1, kdo
                        temp = cos2t*cost-sin2t*sint
                        sint = sin2t*cost+cos2t*sint
                        cost = temp
                        summation = summation+cp(k)*cost
                    end do

                    pb= summation
                else
                    cos2t = cos(2.0*theta)
                    sin2t = sin(2.0*theta)
                    cost = cos(theta)
                    sint = -sin(theta)
                    summation = 0.0_wp

                    do k=1, kdo
                        temp = cos2t*cost-sin2t*sint
                        sint = sin2t*cost+cos2t*sint
                        cost = temp
                        summation = summation+cp(k)*sint
                    end do

                    pb = summation
                end if
            end if
        end if
    end if

end subroutine lfpt

