subroutine energy_ele_DH(Eele)

   use const
   use pbc, only : pbc_vec_d
   use var_state, only : xyz, lambdaD
   use var_potential, only : ele_mp, nele, ele_cutoff, ele_coef

   implicit none

   real(PREC), intent(out) :: Eele

   integer :: imp1, imp2, iele
   real(PREC) :: dist
   real(PREC) :: e_ele, rcdist

   rcdist = 1.0_PREC / lambdaD
   e_ele = 0.0_PREC

   !$omp parallel do private(imp1,imp2,dist) reduction(+:e_ele)
   do iele = 1, nele

      imp1 = ele_mp(1, iele)
      imp2 = ele_mp(2, iele)

      dist = norm2(pbc_vec_d(xyz(:, ele_mp(1, iele)), xyz(:, ele_mp(2, iele))))

      if (dist > ele_cutoff) cycle
        
      e_ele = e_ele + ele_coef /dist*exp(-dist*rcdist)

   end do
   !$omp end parallel do

   Eele = e_ele

end subroutine energy_ele_DH
