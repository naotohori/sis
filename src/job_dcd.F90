subroutine job_dcd()

   use, intrinsic :: iso_fortran_env, Only : iostat_end
   use const
   use const_idx, only : ENE
   use pbc, only : flg_pbc, pbc_box, pbc_box_half
   use var_top, only : nmp
   use var_state, only : xyz, energies, flg_bp_energy
   use var_io, only : hdl_dcd, hdl_out, cfile_dcd_in, cfile_out
   use dcd, only : file_dcd, DCD_OPEN_MODE

   implicit none

   integer :: i, nframe, istat, nmp_dcd
   type(file_dcd) :: fdcd

   flg_bp_energy = .False.

   fdcd = file_dcd(hdl_dcd, cfile_dcd_in, DCD_OPEN_MODE%READ)

   call fdcd%read_header()

   call fdcd%read_nmp(nmp_dcd, istat)

   if (fdcd%box(1) > 0.0) then
      flg_pbc = .True.
      pbc_box(:) = fdcd%box(:)
      pbc_box_half = 0.5 * pbc_box(:)
      write(*,*) '#Box: ', pbc_box
   else
      flg_pbc = .False.
      write(*,*) '#No PBC'
   endif

   if (nmp_dcd /= nmp) then
      write(*,*) "Error: nmp_dcd /= nmp. nmp = ", nmp, ", nmp_dcd = ", nmp_dcd
      stop (2) 
   endif

   allocate(xyz(3, nmp))

   open(hdl_out, file = cfile_out, status = 'replace', action = 'write', form='formatted')
   write(hdl_out, '(a)') '#(1)nframe (2)T   (3)Ekin       (4)Epot       (5)Ebond      (6)Eangl      (7)Ebp        (8)Eexv       (9)Eele'

   nframe = 0
   do
      call fdcd%read_onestep(nmp, xyz, istat)
      if (istat == iostat_end) exit
      nframe = nframe + 1

      call energy()
      
      write(hdl_out, '(i10, 1x, f6.2, 7(1x,g13.6))') nframe, 0.0, 0.0, (energies(i), i=0,ENE%MAX)

   enddo

   write(*,*) '#nframe:', nframe

   call fdcd%close()

   close(hdl_out)

endsubroutine job_dcd
