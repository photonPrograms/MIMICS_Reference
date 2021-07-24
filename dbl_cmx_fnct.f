c***********************************************************************
c-- subroutine to compute sine of a complex argument -------------------
c***********************************************************************
c
        subroutine csina(a,b,rsz,isz)
        save
c
        real*8 a,b,rsz,isz    
c        
        rsz = (dsin(a))*((dexp(-b)+dexp(b))/2.d0)
        isz = -(dcos(a))*((dexp(-b)-dexp(b))/2.d0)
c  
        return
        end
c
c***********************************************************************
c-- subroutine to compute cosine of a complex argument -----------------
c***********************************************************************
c
        subroutine ccosa(a,b,rcz,icz)
        save
c
        real*8 a,b,rcz,icz 
c                           
        rcz = (dcos(a))*((dexp(-b)+dexp(b))/2.d0)
        icz = (dsin(a))*((dexp(-b)-dexp(b))/2.d0)
c
        return
        end
c
c******************************************************************
c  double precision subroutine to compute complex exponential
c******************************************************************
c
        subroutine cexpa(a,b,er,ei)
        save
c
        real*8 a,b,er,ei
        real*8 fact
c
        fact = dexp(a)
c
        er = fact*dcos(b)
        ei = fact*dsin(b)
c
        return
        end
c
c******************************************************************
c  double precision subroutine to compute complex natural logarithm
c******************************************************************
c
        subroutine clna(a,b,lnr,lni)
        save
c
        real*8 a,b,lnr,lni
        real*8 theta,r,pi
c
        pi = 3.141592653589793238462643383279d0
c
        r = dsqrt(a*a + b*b)
        theta = datan2(b,a)
c
        lnr = dlog(r)
        lni = theta
c
        if((theta.le.-pi).or.(theta.gt.pi))then
            print*,'** Error in clna routine ** theta = ',theta
            stop
        endif
c
        return
        end
c
c******************************************************************
c This double precision routine computes the product of two
c complex numbers which each are supplied as two real*8
c numbers.
c******************************************************************
c
        subroutine cmult(ar,ai,br,bi,cr,ci)
        save
c
        real*8 ar,ai,br,bi,cr,ci
c
        cr = ar*br - ai*bi
        ci = ar*bi + ai*br
c
        return
        end
c
c*****************************************************************
c This double precision routine divides twocomplex numbers 
c which each are supplied as two real*8 numbers.
c*****************************************************************
c
        subroutine cdiv(ar,ai,br,bi,cr,ci)
        save
c
        real*8 ar,ai,br,bi,cr,ci
c
        cr = (ar*br + ai*bi)/(br*br + bi*bi)
        ci = (ai*br - ar*bi)/(br*br + bi*bi)
c
        return
        end
c
c**********************************************************************
c  double precision subroutine to compute absolute magnitude of
c   a complex number
c**********************************************************************
c
        subroutine cabsa(a,b,mag)
        save
c
        real*8 a,b,mag
c
        mag = dsqrt(a*a + b*b)
c
        return
        end
c
C                                                                      C
C**********************************************************************C
C                                                                      C
      SUBROUTINE CSQRTA(Xreal,Ximag,Yreal,Yimag)
        save
C                                                                      C
C**********************************************************************C
C                                                                      C
C     Written for modification of software to Apollo computer.
C     Finds the complex square root of X and returns it in Y.
C     Returns the root in quadrant I or IV of the complex plane so
C     that Yreal is always positive or zero.
C
C     Software by Tom Willis  -  written May 1985
C
      REAL*8 DENOM, XIMAG, YIMAG, XREAL, YREAL, XI2, XR2
      REAL*8 RROOT, RXR, R, COSPHI, SINPHI
C
      If (Ximag.eq.0.D0) goto 100
      If (Xreal/DABS(Ximag).lt.-1.D4) goto 300
C
c      R=DSQRT(Xreal*Xreal+Ximag*Ximag)
c      Rroot=DSQRT(R)
c      RXr=R+Xreal
c      Denom=DSQRT(RXr*RXr+Ximag*Ximag)
c      Yimag=Rroot*Ximag/Denom
c      Yreal=Rroot*RXr/Denom
c
        R=DSQRT(Xreal*Xreal+Ximag*Ximag)
        Yreal = dsqrt(0.5d0*(R+Xreal))
        Yimag = dsqrt(0.5d0*(R-Xreal))
        if(Ximag.lt.0.d0) Yimag = -Yimag
c
      RETURN
C
  100 If (Xreal.lt.0.D0) goto 200
C
CCC   Pure real root
C
      Yreal=DSQRT(Xreal)
      Yimag=0.D0
      RETURN
C
CCC   Pure imaginary root
C
  200 Yimag=DSQRT(-Xreal)
      Yreal=0.D0
      RETURN
C
CCC   Illconditioned case where almost pure imaginary root
C
  300 Xr2=Xreal*Xreal
      Xi2=Ximag*Ximag
      R=-Xreal*(1.D0+Xi2/(2.D0*Xr2))
      Rroot=DSQRT(R)
      Denom=8.D0*Xr2+Xi2
      Sinphi=8.D0*Xr2/Denom
      If (Ximag.lt.0.D0) Sinphi=-Sinphi
      Cosphi=DABS(Ximag*(Xi2-4.D0*Xr2)/(Xreal*Denom))
      Yreal=Rroot*Cosphi
      Yimag=Rroot*Sinphi
      RETURN
C
      END
c*****************************************************************
