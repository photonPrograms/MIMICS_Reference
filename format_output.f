C***********************************************************************
C23456789012345678901234567890123456789012345678901234567890123456789012
C***********************************************************************
C********** Subroutine to write data to output files *******************
C***********************************************************************
C
        SUBROUTINE FORMAT_OUTPUT
        save
C
C***********************************************************************
C-------------------Variable declarations-------------------------------
C***********************************************************************
C----------------------------
c%include 'parameters.include'
        INCLUDE 'parameters.include'
C----------------------------
C
        INTEGER I, J, K
        REAL WORK
C
C----------- FUNCTIONAL VARIABLES (INPUTS) -----------------------------
C
        REAL THETA, CTHETA, STHETA
C
C----------- OUTPUTS ---------------------------------------------------
C
        REAL EXP_KAPPA_T_p(4,4), EXP_KAPPA_T_m(4,4)
        REAL EXP_KAPPA_C_p(4,4), EXP_KAPPA_C_m(4,4)
        REAL EXP_CANOPY_p(4,4), EXP_CANOPY_m(4,4)
        REAL T(4,4), BACKTERMS(4,4,N_SCAT_TERMS)
        REAL T_SIG0(4,4), SIG0(4,4,N_SCAT_TERMS)
        REAL T_SIG0_dB(4,4), SIG0_dB(4,4,N_SCAT_TERMS)
C
C***********************************************************************
C
        COMMON /RADAR_ANGLE/ THETA, CTHETA, STHETA
        COMMON /TRUNK_EXT/ EXP_KAPPA_T_p, EXP_KAPPA_T_m
        COMMON /CROWN_EXT/ EXP_KAPPA_C_p, EXP_KAPPA_C_m
        COMMON /CANOPY_EXT/ EXP_CANOPY_p, EXP_CANOPY_m
        COMMON /STOKES_MATS/ T, BACKTERMS
        COMMON /SIGMA_0/ T_SIG0,T_SIG0_dB, SIG0, SIG0_dB
C
C----------------------------
c%include 'constants.include'
        INCLUDE 'constants.include'
C----------------------------
C***********************************************************************
C------ Compute Sigma 0's ----------------------------------------------
C***********************************************************************
C
        WORK = 4.0*PI*CTHETA
C
        DO 120 K=1, N_SCAT_TERMS
          DO 110 I=1,2
            DO 100 J=1,2
                SIG0(J,I,K) = WORK*BACKTERMS(J,I,K)
                IF(SIG0(J,I,K) .GT. 0.0)THEN
                    SIG0_dB(J,I,K) = 10.0*ALOG10(SIG0(J,I,K))
                ELSE
                    SIG0_dB(J,I,K) = -999.99
                ENDIF
100         CONTINUE
110       CONTINUE
120     CONTINUE
C
        DO 140 I=1,2
            DO 130 J=1,2
                T_SIG0(J,I) = WORK*T(J,I)
                IF(T_SIG0(J,I) .GT. 0.0)THEN
                    T_SIG0_dB(J,I) = 10.0*ALOG10(T_SIG0(J,I))
                ELSE
                    T_SIG0_dB(J,I) = -999.99
                ENDIF
130         CONTINUE
140     CONTINUE
C
        RETURN
        END
C
C***********************************************************************
