C**********************************************************************C
C                                                                      C
        COMPLEX FUNCTION MYCSQRT(X)
        save
C                                                                      C
C**********************************************************************C
C                                                                      C
C     Written for modification of software to Apollo computer.
C     Finds the complex square root of X and returns it in Y.
C     Returns the root in quadrant I or IV of the complex plane so
C     that RE(Y) is always positive or zero.
C
C     Software by Tom Willis  -  written May 1985
C
        REAL DENOM, XI2, XR2
        REAL RROOT, RXR, R, COSPHI, SINPHI
        REAL Xreal, Ximag, Yreal, Yimag
        COMPLEX X , Y
C
        Xreal = real(x)
        Ximag = aimag(x)

      If (Ximag.eq.0.0) goto 100
      If (Xreal/ABS(Ximag).lt.-1.E4) goto 300
C
c      R = SQRT(Xreal*Xreal + Ximag*Ximag)
c      Rroot = SQRT(R)
c      RXr = R+Xreal
c      Denom = SQRT(RXr*RXr+Ximag*Ximag)
c      Yimag = Rroot*Ximag/Denom
c      Yreal = Rroot*RXr/Denom
c
        R = SQRT(Xreal*Xreal + Ximag*Ximag)
        Yreal = sqrt(0.5*(R+Xreal))
        Yimag = sqrt(0.5*(R-Xreal))
        if(Ximag.lt.0.0) Yimag = -Yimag
c
        Y = CMPLX(Yreal,Yimag)
        mycsqrt = y
      RETURN
C
  100 If (Xreal.lt.0.0) goto 200
C
CCC   Pure real root
C
      Yreal = SQRT(Xreal)
      Yimag = 0.0
        Y = CMPLX(Yreal,Yimag)
        mycsqrt = y
      RETURN
C
CCC   Pure imaginary root
C
  200 Yimag = SQRT(-Xreal)
      Yreal = 0.0
        Y = CMPLX(Yreal,Yimag)
        mycsqrt = y
      RETURN
C
CCC   Illconditioned case where almost pure imaginary root
C
  300 Xr2 = Xreal*Xreal
      Xi2 = Ximag*Ximag
      R = -Xreal*(1.0 + Xi2/(2.0*Xr2))
      Rroot = SQRT(R)
      Denom = 8.0*Xr2 + Xi2
      Sinphi = 8.0*Xr2/Denom
      If (Ximag.lt.0.0) Sinphi=-Sinphi
      Cosphi = ABS(Ximag*(Xi2-4.0*Xr2)/(Xreal*Denom))
      Yreal = Rroot*Cosphi
      Yimag = Rroot*Sinphi
        Y = CMPLX(Yreal,Yimag)
        mycsqrt = y
      RETURN
C
      END
c*****************************************************************
