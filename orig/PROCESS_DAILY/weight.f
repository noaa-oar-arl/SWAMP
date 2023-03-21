C NCLFORTSTART

      subroutine wdist(wgtss,wgtsi,dist,presm_slp,presm_int,
     &nlvls,nx,ny,plat,plon,lat2dg,lon2dg)
      integer nlvs,nx,ny
      integer cnt(1150,720),dist(1150,720,nlvls)
      real wgtss(ny,nx),wgtsi(ny,nx)
      real presm_slp(nlvls),presm_int(nlvls)
      real plat(nx),plon(ny)
      real lat2dg(ny,nx),lon2dg(ny,nx)
      integer idsx(ny,nx),idsy(ny,nx)

C NCLEND


      do i=1,ny
!      print*,'weight yx', i
      do j=1,nx
      idsy(i,j)=0
      idsx(i,j)=0
      do k=1,ny
      do m=1,nx
      if(abs(plon(i)-lon2dg(k,m)).lt.0.06) then
      if(abs(plat(j)-lat2dg(k,m)).lt.0.05) then
      idsy(i,j)=k
      idsx(i,j)=m
      end if
      end if
      end do
      end do
      end do
      end do

!      do i=1,ny
!      print*,'weight x', i
!      do j=1,nx
!      idsx(i,j)=0
!      do k=1,ny
!      do m=1,nx
!      if(abs(plon(i)-lon2dg(k,m)).lt.0.05) then
!      if(abs(plat(j)-lat2dg(k,m)).lt.0.045) then
!      idsx(i,j)=m
!      end if
!      end if
!      end do
!      end do
!      end do
!      end do

!      do i=1,nx
!      idsx(i)=0
!      stp=0
!      if(stp.eq.0) then
!      do k=1,ny
!      do j=1,nx
!      if(abs(plat(i)-lat2dg(k,j)).lt.0.04) then
!      idsx(i)=j !j
!      stp=1
!      end if
!      end do
!      end do
!      end if
!      end do

!     do i=1,ny
!     idsy(i)=0
!     stp=0
!     if(stp.eq.0) then
!     do k=1,ny
!     do j=1,nx
!     if(abs(plon(i)-lon2dg(k,j)).lt.0.05) then
!     idsy(i)=k !k
!     stp=1
!     end if
!     end do!
!     end do
!     end if
!     end do

!     do i=1,ny
!     print*,"idsy=",idsy(i),i
!     end do
!     do j=1,nx
!     print*,"idsx=",idsx(j),j
!     end do


      do i=1,ny
!     print*,i
      do j=1,nx
      wgtss(i,j)=0
      wgtsi(i,j)=0
      cnt(i,j)=0
      do k=1,nlvls
      if(presm_slp(k).ne.-99) then
      if(presm_int(k).ne.-99) then
!      if(dist(idsy(i),idsx(j),k).ne.-99) then
      wgtss(i,j)=wgtss(i,j) + dist(idsy(i,j),idsx(i,j),k)*presm_slp(k)
      wgtsi(i,j)=wgtsi(i,j) + dist(idsy(i,j),idsx(i,j),k)*presm_int(k)
      cnt(i,j)=cnt(i,j)+dist(idsy(i,j),idsx(i,j),k)
!      end if
      end if
      end if
      end do

      if(cnt(i,j).ne.0) then
      wgtss(i,j)=wgtss(i,j)/cnt(i,j)
      wgtsi(i,j)=wgtsi(i,j)/cnt(i,j)
      end if
      end do
      end do

      do i=1,ny
      do j=1,nx
!     print*,wgtss(i,j),cnt(i,j),i,j
      end do
      end do

      do k=1,nlvls
      do i=1,ny
      do j=1,nx
      if((dist(i,j,k).gt.0).and.(dist(i,j,k).lt.1000.0)) then
!      print*,"dist= ", dist(i,j,k),i,j,k
      end if
      end do
      end do
      end do


      RETURN

      END

