C NCLFORTSTART
      subroutine match(mdat,sm1,dlat,dlon,plat,plon,rncol,nx,ny,miss)
      integer rncol,nx,ny,cnt
      real miss
      real dlat(rncol)
      real dlon(rncol)
      real mdat(rncol)
      real plat(nx)
      real plon(ny)
      real sm1(nx,ny)


C NCLEND

      cnt=0
      do i=1,nx
      do j=1,ny
      do k=1,rncol

      if(mdat(k).ne.miss) then
      if((abs(dlat(k)-plat(i)).lt.0.052).and.
     &(abs(dlon(k)-plon(j)).lt.0.052)) then
      sm1(i,j)=mdat(k)
!      print*,dlat(k),plat(i),sm1(i,j),i,j,k


      if(dlat(k).eq.35.97) then
!      print*,i,j
      end if

      cnt=cnt+1
      end if
      end if

      end do
      end do
      end do

!      print*,cnt

      RETURN

      END

