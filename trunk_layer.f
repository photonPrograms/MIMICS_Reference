C***********************************************************************
C23456789012345678901234567890123456789012345678901234567890123456789012
C***********************************************************************
C*** This subroutine computes the phase matrices of the TRUNK layer. ***
C***    Calling routine:      main MIMICS program                    ***
C***    Called subroutines:   TRUNK_PHASE_SUB                        ***
C*********************************************************************** 
C
        SUBROUTINE TRUNK_LAYER(LOG_LAYER)
        save
C
C***********************************************************************
C------------------  variable definitions   ----------------------------
C***********************************************************************
C
C   kappa_t_p() =  Extinction matrix  -- upward propagating
C   kappa_t_m() =  Extinction matrix  -- downward propagating
C
C***********************************************************************
C------------------  variable declations    ----------------------------
C***********************************************************************
C----------------------------
c%include 'parameters.include'
        include 'parameters.include'
C----------------------------
C
        INTEGER I,J,K
C
        REAL Z, dum(4,4)
        REAL DENSITY, CROWN_HGHT, TRUNK_HGHT
        REAL P_TRUNK(4,4,2), P_TRUNK_LAYER(4,4,2)
        REAL EXP_KAPPA_T_p(4,4), EXP_KAPPA_T_m(4,4)
        real kappa_t_p(4,4), kappa_t_m(4,4)
        real trunk_prop_diff_p(3), trunk_prop_diff_m(3)
        real trunk_spec_p_diff(3,2)
        real phi_hv_vv,phi_vh_vv,phi_hh_vv
C
        COMPLEX M_trunk_p(2,2), M_trunk_m(2,2)
        COMPLEX M_TRUNK_LAYER_p(2,2), M_TRUNK_LAYER_m(2,2)
        COMPLEX LAMBDA_T_p(4),Q_T_p(4,4),Q_T_p_INV(4,4)
        COMPLEX LAMBDA_T_m(4),Q_T_m(4,4),Q_T_m_INV(4,4)
C
        COMMON /R_CANOPY/ DENSITY, CROWN_HGHT, TRUNK_HGHT

        COMMON /TRUNK_PHASE/ P_TRUNK, P_TRUNK_LAYER
        COMMON /TRUNK_M_MAT/ M_trunk_p, M_trunk_m
        COMMON /TRUNK_EXT/ EXP_KAPPA_T_p, EXP_KAPPA_T_m
        COMMON /TRUNK_KAPPA/ kappa_t_p, kappa_t_m
        COMMON /TRUNK_QS/ Q_T_p, Q_T_p_INV, Q_T_m, Q_T_m_INV
        COMMON /TRUNK_EIGEN/ LAMBDA_T_p, LAMBDA_T_m
c
        common /trunk_prop_p/ trunk_prop_diff_p, trunk_prop_diff_m
        common /trunk_spec_p/ trunk_spec_p_diff
C
        REAL THETA, CTHETA, STHETA
        COMMON /RADAR_ANGLE/ THETA, CTHETA, STHETA
C
        LOGICAL OPEN, STEP_VARIABLE(N_VARIABLES)
        LOGICAL STEP_THIS_TIME(N_VARIABLES)
        LOGICAL  CALL_SUB(N_CALLS,N_SUB_CALLS)
        COMMON /L_FLAGS/ STEP_VARIABLE, STEP_THIS_TIME, CALL_SUB, OPEN
C
        LOGICAL LOG_LAYER

        common /mmats_tr/ M_TRUNK_LAYER_p,M_TRUNK_LAYER_m
C
C***********************************************************************
C   COMPUTE PHASE AND EXTINCTION  MATRICES FOR THE TRUNKS
C***********************************************************************
C
        IF(CALL_SUB(3,2)) THEN
            CALL TRUNK_PHASE_SUB(P_TRUNK)
C
        DO 100 J=1,2
         DO 99 I=1,4
          DO 98 K=1,4
            P_TRUNK_LAYER(K,I,J) = DENSITY*P_TRUNK(K,I,J)
98        CONTINUE
99       CONTINUE
100     CONTINUE

c
        do i=1,4
          do j=1,4
            dum(j,i) = P_TRUNK_LAYER(j,i,1)
          enddo
        enddo
        call phase_diff(dum,phi_hv_vv,phi_vh_vv,phi_hh_vv)
        trunk_spec_p_diff(1,1) = phi_hh_vv
        trunk_spec_p_diff(2,1) = phi_vh_vv
        trunk_spec_p_diff(3,1) = phi_hv_vv
c
        do i=1,4
          do j=1,4
            dum(j,i) = P_TRUNK_LAYER(j,i,2)
          enddo
        enddo
        call phase_diff(dum,phi_hv_vv,phi_vh_vv,phi_hh_vv)
        trunk_spec_p_diff(1,2) = phi_hh_vv
        trunk_spec_p_diff(2,2) = phi_vh_vv
        trunk_spec_p_diff(3,2) = phi_hv_vv
C
        DO 150 J=1,2
         DO 149 I=1,2
            M_TRUNK_LAYER_p(i,j) = DENSITY*M_trunk_p(i,j)
            M_TRUNK_LAYER_m(i,j) = DENSITY*M_trunk_m(i,j)
149      CONTINUE
150     CONTINUE
C
        ELSE IF(.NOT.LOG_LAYER)THEN
         do j=1,2
          do i=1,4
           do k=1,4
            P_TRUNK_LAYER(K,I,J) = 0.0
            P_TRUNK(K,I,J) = 0.0
           enddo
          enddo
         enddo
         do j=1,2
          do i=1,2
            M_TRUNK_LAYER_p(i,j) = CMPLX(0.0,0.0)
            M_TRUNK_LAYER_m(i,j) = CMPLX(0.0,0.0)
          enddo
         enddo
         do j=1,2
          do i=1,3
            trunk_spec_p_diff(i,j) = 0.0
          enddo
         enddo
        ENDIF
C
C--- COMPUTE EIGENVALUE SOLUTION FOR AVERAGE M-MATRX -------------------
C
        CALL MAT_EIGEN_SUB(M_TRUNK_LAYER_p,LAMBDA_T_p,Q_T_p,Q_T_p_INV)
        CALL MAT_EIGEN_SUB(M_TRUNK_LAYER_m,LAMBDA_T_m,Q_T_m,Q_T_m_INV)
C
C--- COMPUTE EXTINCTION MATRICES FOR THE TRUNK LAYER -------------------
C
        CALL KAPPA_MAT_SUB(M_trunk_layer_p, kappa_t_p)
        CALL KAPPA_MAT_SUB(M_trunk_layer_m, kappa_t_m)
C
C***********************************************************************
C   COMPUTE EXPONENTIALS OF EXTINCTION MATRICES
C***********************************************************************
C
C--- TRUNK LAYER ----
C
        z = -TRUNK_HGHT/CTHETA
       CALL EXP_MAT(LAMBDA_T_p,Q_T_p,Q_T_p_INV,z,EXP_KAPPA_T_p)
       CALL EXP_MAT(LAMBDA_T_m,Q_T_m,Q_T_m_INV,z,EXP_KAPPA_T_m)
c
        call phase_diff(EXP_KAPPA_T_p,phi_hv_vv,phi_vh_vv,phi_hh_vv)
        trunk_prop_diff_p(1) = phi_hh_vv
        trunk_prop_diff_p(2) = phi_vh_vv
        trunk_prop_diff_p(3) = phi_hv_vv
c
        call phase_diff(EXP_KAPPA_T_m,phi_hv_vv,phi_vh_vv,phi_hh_vv)
        trunk_prop_diff_m(1) = phi_hh_vv
        trunk_prop_diff_m(2) = phi_vh_vv
        trunk_prop_diff_m(3) = phi_hv_vv
C
        RETURN
        END
C
C***********************************************************************
c***********************************************************************
C23456789012345678901234567890123456789012345678901234567890123456789012
c***********************************************************************
C*** This subroutine computes the phase matrices of the trunk layer  ***
c***********************************************************************
c** updated 3-7-91 to force reciprocity to hold for resonant trunks  ***
C*********************************************************************** 
c***    Calling routine:      TRUNK_LAYER                            ***
c***    Called subroutines:   RESONANT_CYL_SCAT_MAT                  ***
c***                          EXP_KAPPA                              ***
C***                          MAT_EIGEN_SUB                          ***
c***                          STOKES_SUB                             ***
c***                          PDF_TR_SETUP                           ***
c***    Called functions:     PDF_TR                                 ***
c*********************************************************************** 
C
        SUBROUTINE TRUNK_PHASE_SUB(P_TRUNK)
        save
C
c***********************************************************************
c------------------  variable definitions   ----------------------------
c***********************************************************************
C
C   J               = SQRT(-1)
C   diamcm,DIAMCM   = DIAMETER OF TRUNKS (CM)
C   lengthm,LENGTHM = HEIGHT OF TRUNKS (METERS)
C   esilonrc()      = VECTOR (COMPLEX) CONTAINING RELATIVE DIELECTRIC
C                     CONSTANTS OF THE CANOPY CONSTITUENTS
C                       (e' + j*e'')
C
C   epsr            = RELATIVE DIELECTRIC CONSTANT OF THE TRUNKS
C                       (e' + j*e'')
C   theta           = RADAR LOOK ANGLE (RADIANS)
C   thetai, phii    = ANGLES OF INCIDENCE ON THE TRUNKS (RADIANS)
C   thetas, phis    = ANGLES OF SCATTERING FROM THE TRUNKS (RADIANS)
C   thetac, phic    = ANGLES OF ORIENTATION OF THE TRUNKS (RADIANS)
C   LFLAG           = LOGICAL VARIABLE RETURNED FROM THE SUBROUTINE
C                     RESONANT_CYL_SCAT_MAT
C                   = .TRUE. - SCATTERING MARTIX COMPUTED NORMALLY
C                   = .FALSE.- SCATTERING MARTIX NOT COMPUTED.
C                       -- elements set to zero for end-on incidence
C                          or for values of sin(x)/(x) < thresh
C
C   Smat(2,2)       = SCATTERING MATRIX OF TRUNK (COMPLEX)
C   M_trunk_p(2,2)  = + GOING M MATRIX (COMPLEX) OF TRUNK -- IS THE AVERAGE
C                       Smat TIMES THE FACTOR (J*2*pi)*(1.0/Ht)/k0
C   M_trunk_m(2,2)  = - GOING M MATRIX (COMPLEX) OF TRUNK
C   LAMBDA_T_p(4)   = COMPLEX VECTOR CONTAING THE FOUR EIGENVALUES OF
C                       THE + GOING EXTINCTION MATRIX
C   LAMBDA_T_m(4)   = COMPLEX VECTOR CONTAING THE FOUR EIGENVALUES OF
C                       THE - GOING EXTINCTION MATRIX
C   Q_T_p(4,4)      = COMPLEX MATRIX CONTAINING THE EIGENVECTORS OF THE
C                       + GOING EXTINCTION MATRIX
C   Q_T_m(4,4)      = COMPLEX MATRIX CONTAINING THE EIGENVECTORS OF THE
C                       - GOING EXTINCTION MATRIX
C   Q_T_p_INV(4,4)  = INVERSE OF Q_T_p(4,4)  (COMPLEX)
C   Q_T_m_INV(4,4)  = INVERSE OF Q_T_p(4,4)  (COMPLEX)
C
C   TRUNK_STOKES_p(4,4) = STOKES MATRIX OF THE TRUNK LAYER FOR
C                               + GOING WAVE
C   TRUNK_STOKES_m(4,4) = STOKES MATRIX OF THE TRUNK LAYER FOR
C                               - GOING WAVE
C   P_TRUNK(4,4,1)  = PHASE MATRIX OF A SINGLE TRUNK FOR
C                               + GOING WAVE (ground-trunk)                       
C   P_TRUNK(4,4,2)  = PHASE MATRIX OF A SINGLE TRUNK FOR
C                               - GOING WAVE (trunk-ground)                      
C
C   z/ctheta       = VERTICAL EXTENT VARIABLE OVER WHICH TO EVALUATE
C                     THE EXPONENTAL OF THE EXTINCTION MATRIX
C   
C   EXP_KAPPA_T_p  = EXPONENTIAL OF THE + GOING EXTINCTION MATRIX
C   EXP_KAPPA_T_m  = EXPONENTIAL OF THE + GOING EXTINCTION MATRIX
C                    EXP_MAT = EXP(KAPPA*TRUNK_HGHT/COS(THETA))
C
C***********************************************************************
C------------------  variable declations    ----------------------------
C***********************************************************************
C----------------------------
c%include 'parameters.include'
        include 'parameters.include'
C----------------------------
        INTEGER I, K, L, II, JJ
C
        REAL WORK, PDF, PDF_TR, NORM
        REAL DIAMCM,LENGTHM, K0A
        real thetai,phii,thetas,phis,thetac,phic

        REAL FREQ_HERTZ, WAVELENGTH, k0
        REAL THETA, CTHETA, STHETA
        REAL MG_TRUNK, RHO_TRUNK, TRUNK_DIAM
        REAL DENSITY, CROWN_HGHT, TRUNK_HGHT

c
        COMPLEX EPSILONR(N_EPS),EPSILONRC(N_EPS),EPSR
        COMPLEX J,CWORK
        COMPLEX SMAT(2,2),Smat_avg(2,2,2)
        COMPLEX Smat_avg_tmp_1(2,2,2), Smat_avg_tmp_2(2,2,2)
        COMPLEX Smat_avg_tmp_3(2,2,2), smat_tmp1(2,2), smat_tmp2(2,2)
        COMPLEX M_trunk_p(2,2), M_trunk_m(2,2)
        REAL P_TRUNK(4,4,2), STOKES_MAT(4,4), STOKES_MAT2(4,4)
        REAL P_TRUNK_tmp_1(4,4,2), P_TRUNK_tmp_2(4,4,2)
        REAL P_TRUNK_tmp_3(4,4,2)
c
        integer n_theta_1, n_theta_2, n_theta_3
        integer n_phi_1, n_phi_2, n_phi_3
        real t_rad_start_1, t_rad_stop_1, t_rad_start_2, t_rad_stop_2
        real t_rad_start_3, t_rad_stop_3
        real p_rad_start_1, p_rad_stop_1, p_rad_start_2, p_rad_stop_2
        real p_rad_start_3, p_rad_stop_3
        real delta_p_rad_1, delta_p_rad_2, delta_p_rad_3
        real delta_t_rad_1, delta_t_rad_2, delta_t_rad_3
        real delta_p1_t1, delta_p2_t2, delta_p3_t3
c
        LOGICAL LFLAG
c
        COMMON /RADAR_FREQ/ FREQ_HERTZ, WAVELENGTH, k0
        COMMON /RADAR_ANGLE/ THETA, CTHETA, STHETA
        COMMON /C_DIELECTRIC/ EPSILONR,EPSILONRC
        COMMON /R_TRUNK/ MG_TRUNK, RHO_TRUNK, TRUNK_DIAM
        COMMON /R_CANOPY/ DENSITY, CROWN_HGHT, TRUNK_HGHT
C
C--- COMMON BLOCKS FOR EXTINCTION AND PHASE MATRICES ----
C
        COMMON /TRUNK_M_MAT/ M_trunk_p, M_trunk_m
C
C--- COMMON BLOCKS FOR SUBROUTINE RESONANT_CYL_SCAT_MAT ----
C
        common /rcyldata/ diamcm,lengthm,k0a
        common /ccyldata/ epsr
        common /cylscatmat/ Smat
C
C--- VARIABLES FOR SIZE PARAMETER INTEGRATION ----
C
        LOGICAL LOG_CONSTITUENT(N_CONSTITUENTS)
        LOGICAL LOG_EPS_TABLE(N_CONSTITUENTS)
        LOGICAL LOG_DRY_DENSITY(N_CONSTITUENTS) 
        LOGICAL LOG_PDF_TYPE(N_CONSTITUENTS,N_CONST_VARY)
        LOGICAL LOG_HIST(N_CONSTITUENTS)
C
        COMMON /L_CONFIGURE/ LOG_CONSTITUENT, LOG_EPS_TABLE,
     &                       LOG_DRY_DENSITY, LOG_PDF_TYPE, LOG_HIST
C
        REAL STOKES_MAT_INT(4,4)
        COMPLEX SMAT_INT(2,2)
C
C----------------------------
c%include 'constants.include'
        include 'constants.include'
C----------------------------
C***********************************************************************
C   COMPUTE PHASE AND EXTINCTION  MATRICES FOR THE TRUNKS
C***********************************************************************
C--- INITIALIZE TO ZERO ---
C
        DO 50 i=1,2
         DO 50 k=1,4
          DO 50 l=1,4
             P_TRUNK(l,k,i) = 0.0
             P_TRUNK_tmp_1(l,k,i) = 0.0
             P_TRUNK_tmp_2(l,k,i) = 0.0
             P_TRUNK_tmp_3(l,k,i) = 0.0
50      CONTINUE
C
        DO 60 i=1,2
         DO 60 k=1,2
          DO 60 l=1,2
             Smat_avg(l,k,i) = CMPLX(0.0,0.0)
             Smat_avg_tmp_1(l,k,i) = CMPLX(0.0,0.0)
             Smat_avg_tmp_2(l,k,i) = CMPLX(0.0,0.0)
             Smat_avg_tmp_3(l,k,i) = CMPLX(0.0,0.0)
60      CONTINUE
C
C***********************************************************************
C--- INITIALIZATION OF WORKING VARIABLES ---
C***********************************************************************
C
        k0a = k0
C
        NORM = 2.0*PI
c
        diamcm = TRUNK_DIAM
        lengthm = TRUNK_HGHT
        epsr = EPSILONRC(5)
c
        phii = 0.0
c
C***********************************************************************
C--- INTEGRATE OVER ORIENTATIONS --- ASSUME AZIMUTHAL SYMMETRY ---------
C***********************************************************************
C
        call pdf_tr_setup(n_theta_1,t_rad_start_1,t_rad_stop_1,
     &       delta_t_rad_1,n_theta_2,t_rad_start_2,t_rad_stop_2,
     &       delta_t_rad_2,n_theta_3,t_rad_start_3,t_rad_stop_3,
     &       delta_t_rad_3,n_phi_1,p_rad_start_1,p_rad_stop_1,
     &  delta_p_rad_1,n_phi_2,p_rad_start_2,p_rad_stop_2,delta_p_rad_2,
     &       n_phi_3,p_rad_start_3,p_rad_stop_3,delta_p_rad_3)
c
        delta_p1_t1 = delta_p_rad_1*delta_t_rad_1
        delta_p2_t2 = delta_p_rad_2*delta_t_rad_2
        delta_p3_t3 = delta_p_rad_3*delta_t_rad_3
c
c-----------------------------------------------------------------------
c------------ integrate over first interval of THETAc ------------------
c-----------------------------------------------------------------------
c
      IF((n_theta_1.ne.0).and.(n_phi_1.ne.0))THEN
c
      do 150 jj=1,n_theta_1
        thetac = t_rad_start_1 + delta_t_rad_1*float(jj-1)
        pdf = pdf_tr(thetac)
        IF(PDF.GT.0.0)THEN
          print*,' thetac, pdf = ',thetac,pdf
c
c-----------------------------------------------------------------------
c------------ integrate over first interval of PHIc --------------------
c-----------------------------------------------------------------------
c
          do 140 ii=1,n_phi_1
            PHIc = p_rad_start_1 + delta_p_rad_1*float(ii-1)
C
C--- COMPUTE TRUNK PHASE MATRIX FOR SPECULAR SCATTER -------------------
C--- PHASE MATRIX CASE I ----  CANOPY SPECULAR UPWARD FROM GROUND
C                               (GROUND-TRUNK)
C
            THETAI = THETA
            THETAS = THETA
            PHIS = PI + PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO
            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)
                CALL STOKES_SUB(SMAT,STOKES_MAT)

                smat_tmp1(1,1) =  smat(1,1)
                smat_tmp1(1,2) = -smat(2,1)
                smat_tmp1(2,1) = -smat(1,2)
                smat_tmp1(2,2) =  smat(2,2)

                if(n_phi_1.gt.1)then
                 smat(1,2) = -smat(1,2)
                 smat(2,1) = -smat(2,1)

                 CALL STOKES_SUB(SMAT,STOKES_MAT2)

                 DO K=1,4
                  DO L=1,4
                   STOKES_MAT(L,K)=(STOKES_MAT(L,K)+STOKES_MAT2(L,K))
                  ENDDO
                 ENDDO
                endif

            ENDIF
C
            DO K=1,4
             DO L=1,4
              P_TRUNK_tmp_1(L,K,1) =
     &             P_TRUNK_tmp_1(L,K,1) + PDF*STOKES_MAT(L,K)
             ENDDO
            ENDDO

C
C--- PHASE MATRIX CASE II ----  CANOPY SPECULAR DOWNWARD TOWARD GROUND
C                               (TRUNK-GROUND)
C
            THETAI = PI - THETA
            THETAS = PI - THETA
            PHIS   = PI + PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO
            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)
                CALL STOKES_SUB(SMAT,STOKES_MAT)

                smat_tmp2(1,1) =  smat(1,1)
                smat_tmp2(1,2) = -smat(2,1)
                smat_tmp2(2,1) = -smat(1,2)
                smat_tmp2(2,2) =  smat(2,2)

                if(n_phi_1.gt.1)then
                 smat(1,2) = -smat(1,2)
                 smat(2,1) = -smat(2,1)

                 CALL STOKES_SUB(SMAT,STOKES_MAT2)

                 DO K=1,4
                  DO L=1,4
                  STOKES_MAT(L,K)=(STOKES_MAT(L,K)+STOKES_MAT2(L,K))
                  ENDDO
                 ENDDO
                endif

            ENDIF
C
            DO K=1,4
             DO L=1,4
              P_TRUNK_tmp_1(L,K,2) =
     &             P_TRUNK_tmp_1(L,K,2) + PDF*STOKES_MAT(L,K)
             ENDDO
            ENDDO

c-----------------------------------------------------------------------
c--- process specular crown scatter for resonant cylinder solution ---
c        forcing reciprocity to hold

            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1)) then
             continue
            else 
             CALL STOKES_SUB(smat_tmp1,STOKES_MAT)
             if(n_phi_1.gt.1)then
              smat_tmp1(1,2) = -smat_tmp1(1,2)
              smat_tmp1(2,1) = -smat_tmp1(2,1)
              CALL STOKES_SUB(smat_tmp1,STOKES_MAT2)
              DO K=1,4
               DO L=1,4
                STOKES_MAT(L,K) = STOKES_MAT(L,K) + STOKES_MAT2(L,K) 
               ENDDO
              ENDDO
             endif

             DO K=1,4
              DO L=1,4
               P_TRUNK_tmp_1(L,K,2) =
     &             P_TRUNK_tmp_1(L,K,2) + PDF*STOKES_MAT(L,K)
              ENDDO
             ENDDO

             CALL STOKES_SUB(smat_tmp2,STOKES_MAT)
              if(n_phi_1.gt.1)then
               smat_tmp2(1,2) = -smat_tmp2(1,2)
               smat_tmp2(2,1) = -smat_tmp2(2,1)
               CALL STOKES_SUB(smat_tmp2,STOKES_MAT2)
               DO K=1,4
                DO L=1,4
                 STOKES_MAT(L,K) = STOKES_MAT(L,K) + STOKES_MAT2(L,K) 
                ENDDO
               ENDDO
              endif

              DO K=1,4
               DO L=1,4
                P_TRUNK_tmp_1(L,K,1) =
     &             P_TRUNK_tmp_1(L,K,1) + PDF*STOKES_MAT(L,K)
               ENDDO
              ENDDO
            endif
c
c-----------------------------------------------------------------------
C
C--- EXTINCTION MATRIX CASE I --- POSITIVE (UPWARD) PROPAGATING CASE ---
C
            THETAI = THETA
            THETAS = THETA
            PHIS   = PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_1(L,K,1) =
     &            Smat_avg_tmp_1(L,K,1) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_1(L,K,1) =
     &            Smat_avg_tmp_1(L,K,1) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

                if(n_phi_1.gt.1)then
                  smat(1,2) = -smat(1,2)
                  smat(2,1) = -smat(2,1)

                  DO K=1,2
                   DO L=1,2
                    Smat_avg_tmp_1(L,K,1) =
     &                Smat_avg_tmp_1(L,K,1) + PDF*Smat(L,K)
                   ENDDO
                  ENDDO
                endif

            ENDIF
C
C
C--- EXTINCTION MATRIX CASE II --- NEGATIVE (DOWNWARD) PROPAGATING CASE-
C
            THETAI = PI - THETA
            THETAS = PI - THETA
            PHIS   = PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_1(L,K,2) =
     &             Smat_avg_tmp_1(L,K,2) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_1(L,K,2) =
     &             Smat_avg_tmp_1(L,K,2) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

                if(n_phi_1.gt.1)then
                  smat(1,2) = -smat(1,2)
                  smat(2,1) = -smat(2,1)

                  DO K=1,2
                   DO L=1,2
                    Smat_avg_tmp_1(L,K,2) =
     &             Smat_avg_tmp_1(L,K,2) + PDF*Smat(L,K)
                   ENDDO
                  ENDDO
                endif

            ENDIF
C
C
140        CONTINUE
c
        endif
150    continue
c
c---- commented out 3-7-91 ------
c        if(n_phi_1.gt.1)then
c
c            do k=1,2
c              P_TRUNK_tmp_1(1,3,k) = 0.0
c              P_TRUNK_tmp_1(2,3,k) = 0.0
c              P_TRUNK_tmp_1(1,4,k) = 0.0
c              P_TRUNK_tmp_1(2,4,k) = 0.0
c              P_TRUNK_tmp_1(3,1,k) = 0.0
c              P_TRUNK_tmp_1(4,1,k) = 0.0
c              P_TRUNK_tmp_1(3,2,k) = 0.0
c              P_TRUNK_tmp_1(4,2,k) = 0.0
c
c              P_TRUNK_tmp_1(1,1,k) = 2.*P_TRUNK_tmp_1(1,1,k)
c              P_TRUNK_tmp_1(2,1,k) = 2.*P_TRUNK_tmp_1(2,1,k)
c              P_TRUNK_tmp_1(1,2,k) = 2.*P_TRUNK_tmp_1(1,2,k)
c              P_TRUNK_tmp_1(2,2,k) = 2.*P_TRUNK_tmp_1(2,2,k)
c              P_TRUNK_tmp_1(3,3,k) = 2.*P_TRUNK_tmp_1(3,3,k)
c              P_TRUNK_tmp_1(4,3,k) = 2.*P_TRUNK_tmp_1(4,3,k)
c              P_TRUNK_tmp_1(3,4,k) = 2.*P_TRUNK_tmp_1(3,4,k)
c              P_TRUNK_tmp_1(4,4,k) = 2.*P_TRUNK_tmp_1(4,4,k)
c
c              Smat_avg_tmp_1(1,1,k) = 2.*Smat_avg_tmp_1(1,1,k)
c              Smat_avg_tmp_1(2,2,k) = 2.*Smat_avg_tmp_1(2,2,k)
c              Smat_avg_tmp_1(1,2,k) = cmplx(0.0,0.0)
c              Smat_avg_tmp_1(2,1,k) = cmplx(0.0,0.0)
c            enddo
c        endif
c
       ENDIF
c
c
c-----------------------------------------------------------------------
c------------ integrate over second interval of THETAc -----------------
c-----------------------------------------------------------------------
c
c
      IF((n_theta_2.ne.0).and.(n_phi_2.ne.0))THEN
c
      do 170 jj=1,n_theta_2
        thetac = t_rad_start_2 + delta_t_rad_2*float(jj-1)
        pdf = pdf_tr(thetac)
        IF(PDF.GT.0.0)THEN
          print*,' thetac, pdf = ',thetac,pdf
c
c-----------------------------------------------------------------------
c------------ integrate over second interval of PHIc -------------------
c-----------------------------------------------------------------------
c
          do 165 ii=1,n_phi_2
            PHIc = p_rad_start_2 + delta_p_rad_2*float(ii-1)
C
C--- COMPUTE TRUNK PHASE MATRIX FOR SPECULAR SCATTER -------------------
C--- PHASE MATRIX CASE I ----  CANOPY SPECULAR UPWARD FROM GROUND
C                               (GROUND-TRUNK)
C
            THETAI = THETA
            THETAS = THETA
            PHIS = PI + PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO
            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)
                CALL STOKES_SUB(SMAT,STOKES_MAT)

                smat_tmp1(1,1) =  smat(1,1)
                smat_tmp1(1,2) = -smat(2,1)
                smat_tmp1(2,1) = -smat(1,2)
                smat_tmp1(2,2) =  smat(2,2)

                if(n_phi_2.gt.1)then
                 smat(1,2) = -smat(1,2)
                 smat(2,1) = -smat(2,1)

                 CALL STOKES_SUB(SMAT,STOKES_MAT2)

                 DO K=1,4
                  DO L=1,4
                   STOKES_MAT(L,K)=(STOKES_MAT(L,K)+STOKES_MAT2(L,K))
                  ENDDO
                 ENDDO
                endif

            ENDIF
C
            DO K=1,4
             DO L=1,4
              P_TRUNK_tmp_2(L,K,1) =
     &             P_TRUNK_tmp_2(L,K,1) + PDF*STOKES_MAT(L,K)
             ENDDO
            ENDDO
C
C--- PHASE MATRIX CASE II ----  CANOPY SPECULAR DOWNWARD TOWARD GROUND
C                               (TRUNK-GROUND)
C
            THETAI = PI - THETA
            THETAS = PI - THETA
            PHIS   = PI + PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO
            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)
                CALL STOKES_SUB(SMAT,STOKES_MAT)

                smat_tmp2(1,1) =  smat(1,1)
                smat_tmp2(1,2) = -smat(2,1)
                smat_tmp2(2,1) = -smat(1,2)
                smat_tmp2(2,2) =  smat(2,2)

                if(n_phi_2.gt.1)then
                 smat(1,2) = -smat(1,2)
                 smat(2,1) = -smat(2,1)

                 CALL STOKES_SUB(SMAT,STOKES_MAT2)

                 DO K=1,4
                  DO L=1,4
                   STOKES_MAT(L,K)=(STOKES_MAT(L,K)+STOKES_MAT2(L,K))
                  ENDDO
                 ENDDO
                endif

            ENDIF
C
            DO K=1,4
             DO L=1,4
              P_TRUNK_tmp_2(L,K,2) =
     &             P_TRUNK_tmp_2(L,K,2) + PDF*STOKES_MAT(L,K)
             ENDDO
            ENDDO

c-----------------------------------------------------------------------
c--- process specular crown scatter for resonant cylinder solution ---
c        forcing reciprocity to hold

            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1)) then
             continue
            else 
             CALL STOKES_SUB(smat_tmp1,STOKES_MAT)
             if(n_phi_2.gt.1)then
              smat_tmp1(1,2) = -smat_tmp1(1,2)
              smat_tmp1(2,1) = -smat_tmp1(2,1)
              CALL STOKES_SUB(smat_tmp1,STOKES_MAT2)
              DO K=1,4
               DO L=1,4
                STOKES_MAT(L,K) = STOKES_MAT(L,K) + STOKES_MAT2(L,K) 
               ENDDO
              ENDDO
             endif

             DO K=1,4
              DO L=1,4
               P_TRUNK_tmp_2(L,K,2) =
     &             P_TRUNK_tmp_2(L,K,2) + PDF*STOKES_MAT(L,K)
              ENDDO
             ENDDO

             CALL STOKES_SUB(smat_tmp2,STOKES_MAT)
             if(n_phi_2.gt.1)then
              smat_tmp2(1,2) = -smat_tmp2(1,2)
              smat_tmp2(2,1) = -smat_tmp2(2,1)
              CALL STOKES_SUB(smat_tmp2,STOKES_MAT2)
              DO K=1,4
               DO L=1,4
                STOKES_MAT(L,K) = STOKES_MAT(L,K) + STOKES_MAT2(L,K) 
               ENDDO
              ENDDO
             endif

             DO K=1,4
              DO L=1,4
               P_TRUNK_tmp_2(L,K,1) =
     &             P_TRUNK_tmp_2(L,K,1) + PDF*STOKES_MAT(L,K)
              ENDDO
             ENDDO
            endif

c-----------------------------------------------------------------------
C
C--- EXTINCTION MATRIX CASE I --- POSITIVE (UPWARD) PROPAGATING CASE ---
C
            THETAI = THETA
            THETAS = THETA
            PHIS   = PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_2(L,K,1) =
     &              Smat_avg_tmp_2(L,K,1) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_2(L,K,1) =
     &              Smat_avg_tmp_2(L,K,1) + PDF*Smat(L,K)
                 ENDDO
                ENDDO 

                if(n_phi_2.gt.1)then
                  smat(1,2) = -smat(1,2)
                  smat(2,1) = -smat(2,1)

                  DO K=1,2
                   DO L=1,2
                    Smat_avg_tmp_2(L,K,1) =
     &             Smat_avg_tmp_2(L,K,1) + PDF*Smat(L,K)
                   ENDDO
                  ENDDO
                endif


            ENDIF
C
C--- EXTINCTION MATRIX CASE II --- NEGATIVE (DOWNWARD) PROPAGATING CASE-
C
            THETAI = PI - THETA
            THETAS = PI - THETA
            PHIS   = PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO 

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_2(L,K,2) =
     &             Smat_avg_tmp_2(L,K,2) + PDF*Smat(L,K)
                 ENDDO
                ENDDO
            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_2(L,K,2) =
     &             Smat_avg_tmp_2(L,K,2) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

                if(n_phi_2.gt.1)then
                  smat(1,2) = -smat(1,2)
                  smat(2,1) = -smat(2,1)

                  DO K=1,2
                   DO L=1,2
                    Smat_avg_tmp_2(L,K,2) =
     &             Smat_avg_tmp_2(L,K,2) + PDF*Smat(L,K)
                   ENDDO
                  ENDDO
                endif
            ENDIF
C
165        CONTINUE
c
        endif
170    continue
c---- commented out 3-7-91 ------
c        if(n_phi_2.gt.1)then
c
c            do k=1,2
c              P_TRUNK_tmp_2(1,3,k) = 0.0
c              P_TRUNK_tmp_2(2,3,k) = 0.0
c              P_TRUNK_tmp_2(1,4,k) = 0.0
c              P_TRUNK_tmp_2(2,4,k) = 0.0
c              P_TRUNK_tmp_2(3,1,k) = 0.0
c              P_TRUNK_tmp_2(4,1,k) = 0.0
c              P_TRUNK_tmp_2(3,2,k) = 0.0
c              P_TRUNK_tmp_2(4,2,k) = 0.0
c
c              P_TRUNK_tmp_2(1,1,k) = 2.*P_TRUNK_tmp_2(1,1,k)
c              P_TRUNK_tmp_2(2,1,k) = 2.*P_TRUNK_tmp_2(2,1,k)
c              P_TRUNK_tmp_2(1,2,k) = 2.*P_TRUNK_tmp_2(1,2,k)
c              P_TRUNK_tmp_2(2,2,k) = 2.*P_TRUNK_tmp_2(2,2,k)
c              P_TRUNK_tmp_2(3,3,k) = 2.*P_TRUNK_tmp_2(3,3,k)
c              P_TRUNK_tmp_2(4,3,k) = 2.*P_TRUNK_tmp_2(4,3,k)
c              P_TRUNK_tmp_2(3,4,k) = 2.*P_TRUNK_tmp_2(3,4,k)
c              P_TRUNK_tmp_2(4,4,k) = 2.*P_TRUNK_tmp_2(4,4,k)
c
c              Smat_avg_tmp_2(1,1,k) = 2.*Smat_avg_tmp_2(1,1,k)
c              Smat_avg_tmp_2(2,2,k) = 2.*Smat_avg_tmp_2(2,2,k)
c              Smat_avg_tmp_2(1,2,k) = cmplx(0.0,0.0)
c              Smat_avg_tmp_2(2,1,k) = cmplx(0.0,0.0)
c            enddo
c        endif
c
       ENDIF
c
c
c-----------------------------------------------------------------------
c------------ integrate over third interval of THETAc ------------------
c-----------------------------------------------------------------------
c
c
      IF((n_theta_3.ne.0).and.(n_phi_3.ne.0))THEN
c
      do 200 jj=1,n_theta_3
        thetac = t_rad_start_3 + delta_t_rad_3*float(jj-1)
        pdf = pdf_tr(thetac)
        IF(PDF.GT.0.0)THEN
          print*,' thetac, pdf = ',thetac,pdf
c
c-----------------------------------------------------------------------
c------------ integrate over third interval of PHIc --------------------
c-----------------------------------------------------------------------
c
          do 195 ii=1,n_phi_3
            PHIc = p_rad_start_3 + delta_p_rad_3*float(ii-1)
C
C--- COMPUTE TRUNK PHASE MATRIX FOR SPECULAR SCATTER -------------------
C--- PHASE MATRIX CASE I ----  CANOPY SPECULAR UPWARD FROM GROUND
C                               (GROUND-TRUNK)
C
            THETAI = THETA
            THETAS = THETA
            PHIS = PI + PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO
            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)
                CALL STOKES_SUB(SMAT,STOKES_MAT)

                smat_tmp1(1,1) =  smat(1,1)
                smat_tmp1(1,2) = -smat(2,1)
                smat_tmp1(2,1) = -smat(1,2)
                smat_tmp1(2,2) =  smat(2,2)

                if(n_phi_3.gt.1)then
                 smat(1,2) = -smat(1,2)
                 smat(2,1) = -smat(2,1)

                 CALL STOKES_SUB(SMAT,STOKES_MAT2)

                 DO K=1,4
                  DO L=1,4
                   STOKES_MAT(L,K)=(STOKES_MAT(L,K)+STOKES_MAT2(L,K))
                  ENDDO
                 ENDDO
                endif

            ENDIF
C
            DO K=1,4
             DO L=1,4
              P_TRUNK_tmp_2(L,K,1) =
     &             P_TRUNK_tmp_3(L,K,1) + PDF*STOKES_MAT(L,K)
             ENDDO
            ENDDO
C
C--- PHASE MATRIX CASE II ----  CANOPY SPECULAR DOWNWARD TOWARD GROUND
C                               (TRUNK-GROUND)
C
            THETAI = PI - THETA
            THETAS = PI - THETA
            PHIS   = PI + PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO
            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)
                CALL STOKES_SUB(SMAT,STOKES_MAT)

                smat_tmp2(1,1) =  smat(1,1)
                smat_tmp2(1,2) = -smat(2,1)
                smat_tmp2(2,1) = -smat(1,2)
                smat_tmp2(2,2) =  smat(2,2)

                if(n_phi_3.gt.1)then
                 smat(1,2) = -smat(1,2)
                 smat(2,1) = -smat(2,1)

                 CALL STOKES_SUB(SMAT,STOKES_MAT2)

                 DO K=1,4
                  DO L=1,4
                   STOKES_MAT(L,K)=(STOKES_MAT(L,K)+STOKES_MAT2(L,K))
                  ENDDO
                 ENDDO
                endif

            ENDIF
C
            DO K=1,4
             DO L=1,4
              P_TRUNK_tmp_3(L,K,2) =
     &             P_TRUNK_tmp_3(L,K,2) + PDF*STOKES_MAT(L,K)
             ENDDO
            ENDDO
c-----------------------------------------------------------------------
c--- process specular crown scatter for resonant cylinder solution ---
c        forcing reciprocity to hold

            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1)) then
             continue
            else 
             CALL STOKES_SUB(smat_tmp1,STOKES_MAT) 
             if(n_phi_3.gt.1)then
              smat_tmp1(1,2) = -smat_tmp1(1,2)
              smat_tmp1(2,1) = -smat_tmp1(2,1)
              CALL STOKES_SUB(smat_tmp1,STOKES_MAT2)
              DO K=1,4
               DO L=1,4
                STOKES_MAT(L,K) = STOKES_MAT(L,K) + STOKES_MAT2(L,K) 
               ENDDO
              ENDDO
             endif

             DO K=1,4
              DO L=1,4
               P_TRUNK_tmp_3(L,K,2) =
     &             P_TRUNK_tmp_3(L,K,2) + PDF*STOKES_MAT(L,K)
              ENDDO
             ENDDO

             CALL STOKES_SUB(smat_tmp2,STOKES_MAT)
             if(n_phi_3.gt.1)then
              smat_tmp2(1,2) = -smat_tmp2(1,2)
              smat_tmp2(2,1) = -smat_tmp2(2,1)
              CALL STOKES_SUB(smat_tmp2,STOKES_MAT2)
              DO K=1,4
               DO L=1,4
                STOKES_MAT(L,K) = STOKES_MAT(L,K) + STOKES_MAT2(L,K) 
               ENDDO
              ENDDO
             endif

             DO K=1,4
              DO L=1,4
               P_TRUNK_tmp_3(L,K,1) =
     &             P_TRUNK_tmp_3(L,K,1) + PDF*STOKES_MAT(L,K)
              ENDDO
             ENDDO
            endif

c-----------------------------------------------------------------------
C
C--- EXTINCTION MATRIX CASE I --- POSITIVE (UPWARD) PROPAGATING CASE ---
C
            THETAI = THETA
            THETAS = THETA
            PHIS   = PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_3(L,K,1) =
     &              Smat_avg_tmp_3(L,K,1) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_3(L,K,1) =
     &              Smat_avg_tmp_3(L,K,1) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

                if(n_phi_3.gt.1)then
                  smat(1,2) = -smat(1,2)
                  smat(2,1) = -smat(2,1)

                  DO K=1,2
                   DO L=1,2
                    Smat_avg_tmp_3(L,K,2) =
     &             Smat_avg_tmp_3(L,K,2) + PDF*Smat(L,K)
                   ENDDO
                  ENDDO
                endif

            ENDIF
C
C
C--- EXTINCTION MATRIX CASE II --- NEGATIVE (DOWNWARD) PROPAGATING CASE-
C
            THETAI = PI - THETA
            THETAS = PI - THETA
            PHIS   = PHII
C
            IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1))THEN
                CALL CYL_SCAT_MAT_SIZE_INT(thetai,phii,thetas,phis,
     &             thetac,phic,STOKES_MAT_INT,SMAT_INT)
                DO K=1,4
                 DO L=1,4
                  STOKES_MAT(L,K) = STOKES_MAT_INT(L,K)
                 ENDDO
                ENDDO
                DO K=1,2
                 DO L=1,2
                  SMAT(L,K) = SMAT_INT(L,K)
                 ENDDO
                ENDDO

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_3(L,K,2) =
     &              Smat_avg_tmp_3(L,K,2) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

            ELSE
                CALL RESONANT_CYL_SCAT_MAT(thetai,phii,thetas,phis,
     &             thetac,phic,lflag)

                DO K=1,2
                 DO L=1,2
                  Smat_avg_tmp_3(L,K,2) =
     &              Smat_avg_tmp_3(L,K,2) + PDF*Smat(L,K)
                 ENDDO
                ENDDO

                if(n_phi_3.gt.1)then
                  smat(1,2) = -smat(1,2)
                  smat(2,1) = -smat(2,1)

                  DO K=1,2
                   DO L=1,2
                    Smat_avg_tmp_3(L,K,2) =
     &             Smat_avg_tmp_3(L,K,2) + PDF*Smat(L,K)
                   ENDDO
                  ENDDO
                endif

            ENDIF
C
195        CONTINUE
c
        endif
200    continue
c---- commented out 3-7-91 ------
c        if(n_phi_3.gt.1)then
c
c            do k=1,2
c              P_TRUNK_tmp_3(1,3,k) = 0.0
c              P_TRUNK_tmp_3(2,3,k) = 0.0
c              P_TRUNK_tmp_3(1,4,k) = 0.0
c              P_TRUNK_tmp_3(2,4,k) = 0.0
c              P_TRUNK_tmp_3(3,1,k) = 0.0
c              P_TRUNK_tmp_3(4,1,k) = 0.0
c              P_TRUNK_tmp_3(3,2,k) = 0.0
c              P_TRUNK_tmp_3(4,2,k) = 0.0
c
c              P_TRUNK_tmp_3(1,1,k) = 2.*P_TRUNK_tmp_3(1,1,k)
c              P_TRUNK_tmp_3(2,1,k) = 2.*P_TRUNK_tmp_3(2,1,k)
c              P_TRUNK_tmp_3(1,2,k) = 2.*P_TRUNK_tmp_3(1,2,k)
c              P_TRUNK_tmp_3(2,2,k) = 2.*P_TRUNK_tmp_3(2,2,k)
c              P_TRUNK_tmp_3(3,3,k) = 2.*P_TRUNK_tmp_3(3,3,k)
c              P_TRUNK_tmp_3(4,3,k) = 2.*P_TRUNK_tmp_3(4,3,k)
c              P_TRUNK_tmp_3(3,4,k) = 2.*P_TRUNK_tmp_3(3,4,k)
c              P_TRUNK_tmp_3(4,4,k) = 2.*P_TRUNK_tmp_3(4,4,k)
c
c              Smat_avg_tmp_3(1,1,k) = 2.*Smat_avg_tmp_3(1,1,k)
c              Smat_avg_tmp_3(2,2,k) = 2.*Smat_avg_tmp_3(2,2,k)
c              Smat_avg_tmp_3(1,2,k) = cmplx(0.0,0.0)
c              Smat_avg_tmp_3(2,1,k) = cmplx(0.0,0.0)
c            enddo
c        endif
c
c
       ENDIF
c
C***********************************************************************
C--- CORRECT TO ACTUAL PHASE AND M - MATRICES --------------------------
C***********************************************************************
C
        WORK = 1.0/(NORM*TRUNK_HGHT)
C
        DO 250 i=1,2
         DO 250 k=1,4
          DO 250 l=1,4
           IF(LOG_PDF_TYPE(1,1).OR.LOG_HIST(1)) then
            P_TRUNK(l,k,i) = WORK*(delta_p1_t1*P_TRUNK_tmp_1(l,k,i) +
     &            delta_p2_t2*P_TRUNK_tmp_2(l,k,i) +
     &            delta_p3_t3*P_TRUNK_tmp_3(l,k,i))
           else 
            P_TRUNK(l,k,i) = 0.5*WORK*(delta_p1_t1*P_TRUNK_tmp_1(l,k,i)+
     &            delta_p2_t2*P_TRUNK_tmp_2(l,k,i) +
     &            delta_p3_t3*P_TRUNK_tmp_3(l,k,i))
           endif
250     CONTINUE
C
        J = CMPLX(0.0,1.0)
        CWORK = J*2.0*PI/(NORM*TRUNK_HGHT*k0)
C
        DO 260 k=1,2
         DO 260 l=1,2
           M_TRUNK_P(l,k) = CWORK*(delta_p1_t1*Smat_avg_tmp_1(l,k,1) +
     &            delta_p2_t2*Smat_avg_tmp_2(l,k,1) +
     &            delta_p3_t3*Smat_avg_tmp_3(l,k,1))
260     CONTINUE
C
        DO 270 k=1,2
         DO 270 l=1,2
           M_TRUNK_M(l,k) = CWORK*(delta_p1_t1*Smat_avg_tmp_1(l,k,2) +
     &            delta_p2_t2*Smat_avg_tmp_2(l,k,2) +
     &            delta_p3_t3*Smat_avg_tmp_3(l,k,2))
270     CONTINUE
C
c        print*,'Tvv = ',-2.0*real(M_trunk_p(1,1))*TRUNK_HGHT
c        print*,'Thh = ',-2.0*real(M_trunk_p(2,2))*TRUNK_HGHT
C
        RETURN
        END
C
C***********************************************************************
