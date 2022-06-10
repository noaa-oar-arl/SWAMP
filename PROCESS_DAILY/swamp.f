C NCLFORTSTART
      subroutine wswamp(sm,smn,wgtss,wgtsi,prismpre,alexi_et,
     &plat,plon,latp,lonp,latpa,lonpa,nlat,nlon,nlata,
     &nlona,nlvls,nx,ny,ntime,maxmoist,minmoist)
      integer nlvs,nx,ny,ntime
      integer nlat,nlon,nlata,nlona
      integer idsx(nx),idsy(ny),idsax(nx),idsay(ny)
      real plat(nx),plon(ny)
      double precision latp(nlat),lonp(nlon)
      real latpa(nlata),lonpa(nlona)
      integer cnt(1150,720)
      real wgtss(ny,nx),wgtsi(ny,nx)
      real prismpre(nlon,nlat,ntime),alexi_et(nlona,nlata,ntime)
      real sm(ny,nx,ntime),smn(ny,nx,ntime)
      real maxmoist(ny,nx,ntime),minmoist(ny,nx,ntime)

C NCLEND


      do i=1,nx
      idsx(i)=0	
      do k=1,nlat
      if((abs(plat(i)-latp(k)).lt.0.04)) then
      idsx(i)=k
      end if
      end do
      end do

      do j=1,ny
      idsy(j)=0
      do m=1,nlon
      if((abs(plon(j)-lonp(m)).lt.0.05)) then
      idsy(j)=m
      end if
      end do
      end do

      do i=1,nx
      idsax(i)=0
      do k=1,nlata
      if((abs(plat(i)-latpa(k)).lt.0.04)) then
      idsax(i)=k
      end if
      end do
      end do

      do j=1,ny
      idsay(j)=0
      do m=1,nlona
      if((abs(plon(j)-lonpa(m)).lt.0.05)) then
      idsay(j)=m
      end if
      end do
      end do

!      do j=1,ny
!      print*,idsy(j),j
!      end do

!      do i=1,nx
!      print*,idsx(i),i
!      end do

      do n=2,ntime
      do i=1,ny
      do j=1,nx

      if(idsy(i).ne.0) then
      if(idsx(j).ne.0) then
      if(idsay(i).ne.0) then
      if(idsax(j).ne.0) then
      if(prismpre(idsy(i),idsx(j),n).ne.-9999) then
!      if(alexi_et(idsay(i),idsax(j),n).ne.9.96921e+36) then
      if(alexi_et(idsay(i),idsax(j),n).ge.0.0) then
!      if(wgtss(i,j).ne.0) then

      sm(i,j,n)=sm(i,j,n-1) +(prismpre(idsy(i),idsx(j),n) -
     &alexi_et(idsay(i),idsax(j),n)*0.408)*wgtss(i,j) ! +wgtsi(i,j)

      if(sm(i,j,n).lt.minmoist(i,j,1)) then
      sm(i,j,n)=minmoist(i,j,1)
      end if

      if(sm(i,j,n).gt.maxmoist(i,j,1)) then
      sm(i,j,n)=maxmoist(i,j,1)
      end if

!       sm(i,j,n)=wgtss(i,j)


!      if(n.eq.55) then
!      print*,sm(i,j,n),wgtss(i,j),i,j ! good here 
!      end if

!      if(wgtss(i,j).ne.0) then
!      print*,sm(i,j,n)
!      sm(i,j,n)=sm(i,j,n)*wgtss(i,j) + wgtsi(i,j)
!      print*,sm(i,j,n),wgtss(i,j)
!      end if

!      if(n.eq.55) then
!      print*,sm(i,j,n),wgtss(i,j),i,j
!      end if

 !     if(sm(i,j,n).lt.0) then
 !     sm(i,j,n)=-99
 !     end if
!      sm(i,j,2)=wgtss(i,j)
!      sm(i,j,3)=wgtsi(i,j)

!      sm(i,j,n)=sm(i,j,n-1)-alexi_et(idsay(i),idsax(j),n)*0.408

      smn(i,j,n)=smn(i,j,n-1)+(prismpre(idsy(i),idsx(j),n)-
     &alexi_et(idsay(i),idsax(j),n)*0.408)

      if(smn(i,j,n).lt.minmoist(i,j,1)) then
      smn(i,j,n)=minmoist(i,j,1)
      end if
     
      if(smn(i,j,n).gt.maxmoist(i,j,1)) then
      smn(i,j,n)=maxmoist(i,j,1)
      end if

!      smn(i,j,n)=minmoist(i,j,1)

      else
      sm(i,j,n)=sm(i,j,n-1)
      smn(i,j,n)=smn(i,j,n-1)

!      end if
      end if
      end if
      end if
      end if
      end if
      end if

!      if(n.eq.55)  then
!      if(minmoist(i,j,1).ne.-99) then
!      if(j.eq.500) then
!      print*,"a",minmoist(i,j,1),maxmoist(i,j,1),sm(i,j,n),smn(i,j,n),i
!      end if 
!      end if
!      end if


      end do
      end do

!      print*,n
      end do

      RETURN

      END

