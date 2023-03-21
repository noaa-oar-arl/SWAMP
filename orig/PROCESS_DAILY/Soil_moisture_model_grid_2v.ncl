;SWAMP2022_1342.png*************************************************
; conOncon_3.ncl
;
; Concepts illustrated:
;   - Overlaying two sets of contours on a polar stereographic map
;   - Overlaying line contours on filled contours
;   - Turning off map tickmarks
;   - Increasing the thickness of contour lines
;   - Using a blue-white-red color map
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

external WEIGHT "./weight.so"
;external WEIGHT2 "./weight2.so"
external SWAMP "./swamp.so"

begin
print("Processing Soil_moisture_model_grid_2v...")
; --- Read Data ----------------------------------------;
 ;diri = "/fs/scd/home1/shea/ncldata_input/"
  yearcrn = getenv("YEAR_CRN")
  sdate  = stringtointeger(getenv("SDATE_CRN"))
  edate  = stringtointeger(getenv("EDATE_CRN"))
  totday = edate-sdate+1
  diri = "./variables_"+yearcrn+"/"
  diri2 = "../"+yearcrn+"_c/"   ;processed PRISM directory
  diri3 = "../ALEXI/"           ;processed ALEXI directory

  preis = "stationID_lat_lon_"
  preiscrn = "USCRN_stations_id_lat_lon"
  presw = "soil_water"
  presp = "soil_properties"
  fili = ".txt"
  lili = ".nc"
  ncol = 228
  nlvls = 107
  ncols = 5
  nz = 121
  nx = 720
  ny = 1150


    ;these are filled based on the total run days
   nlvl = totday
   ntime = totday



  runnbr = new(6,string)

  runnbr(1) = yearcrn

  nxf=1150
  nyf=720

  nlat=621
  nlon=1405

  nlata=625
  nlona=1456


   filenames =  asciiread (diri2+"prism_list_"+yearcrn,nlvl,"string")
  filenamesa = asciiread (diri3+"alexi_list_"+yearcrn,nlvl,"string")


  TestDatapresm = asciiread ("presm_fits.txt", (/nlvls,3/), "float")

  data  = new((/ncol,nlvl/),float)
  pltdata = new((/2,nlvls,nlvl/),float)
  pltdatarun = new((/2,nlvls,nlvl/),float)
  waterd = new((/nlvls,nlvl/),float)
  waterdrun = new((/2,nlvls,nlvl/),float)
  waterdrunm = new((/2,nlvls,nlvl/),float)
  alexi =  new((/nlvls,nlvl/),float)


  a = addfile("AWC_WTA_0to10cm_composite.nc","r")
  d = addfile("veg_2011_30m.nc","r")
  g = addfile("vegsoil_dist_4km.nc","r")
  f = addfile("SWAMP_rel_"+yearcrn+".nc","r")

  veg = d->Band1(:,:)
  awcss = a->Band1(:,:)
  x = a->x(:)
  y = a->y(:)
  xv = d->x(:)
  yv = d->y(:)
  dist = g->VGSLD(:,:,:)

  lat2dg =g->LAT2D(:,:)
  lon2dg =g->LON2D(:,:)

  smr = f->SM

;  print(dist(:,500:510,500:510))

  wgtss = new((/nx,ny/),float)
  wgtsi = new((/nx,ny/), float)

  prismpre =  new((/nlvl,nlat,nlon/),float)
  alexi_et =  new((/nlvl,nlata,nlona/),float)

  latpa = new(nlata,float)
  lonpa = new(nlona,float)

  do i=0,nlata-1
  latpa(i)=24.80+(0.04*i)
  end do
  do j=0,nlona-1
  lonpa(j)=-125.0+(0.04*j)
  end do


  do i=0,nlvl-1

  b = addfile(diri2+filenames(i),"r")
  alexir = fbindirread (diri3+filenamesa(i),0,(/nlata,nlona/), "float")

  latp = b->lat(:)
  lonp = b->lon(:)
  prism = b->Band1(:,:)

  prismpre(i,:,:)=prism(:,:)
  alexi_et(i,:,:)=alexir(:,:)

  end do

;  print(prismpre@_FillValue)
;  print(alexi_et@_FillValue)

;  print(prismpre(4,:,5))

  names = new(120,string)

;  TestDatan = asciiread (diri+"station_names"+fili , 120, "string")

;  names(:)=TestDatan(:)

;  TestDatascrn = asciiread (diri+preiscrn+fili , (/120,3/), "float")
  TestDatascrn = asciiread (diri+preis+runnbr(1)+fili , (/120,3/), "float")
  TestDatasw = asciiread (diri+presw+fili , (/107,4/), "float")
  TestDatasp = asciiread (diri+presp+fili , (/107,4/), "float")
  TestDatast = asciiread (diri+preis+yearcrn+fili , (/ncol-6,3/), "integer")

   presm_int = new(107,float)
   presm_rsq = new(107,float)
   presm_slp = new(107,float)

   cpid = new(107,float)

   sidsw = new(107,float)
   wiltpt = new(107,float)
   fieldc = new(107,float)
   availw = new(107,float)

   presm_int(:)=TestDatapresm(:,0)
   presm_rsq(:)=TestDatapresm(:,1)
   presm_slp(:)=TestDatapresm(:,2)

;   distcnt = new((/nx,ny/), integer)

;   do i=0,nx-1
;   do j=0,ny-1
;   wgtss(i,j)=0
;   wgtsi(i,j)=0
;   distcnt(i,j)=0
;   do k=0,40
;   if(.not.ismissing(presm_slp(k))) then
;   if(.not.ismissing(presm_int(k))) then
;   if(.not.ismissing(dist(k,i,j))) then
;   wgtss(i,j)=wgtss(i,j) + dist(k,i,j)*presm_slp(k)
;   wgtsi(i,j)=wgtsi(i,j) + dist(k,i,j)*presm_int(k)
;   distcnt(i,j)=distcnt(i,j)+dist(k,i,j) 
;   end if
;   end if
;   end if
;   end do

;   if(.not.ismissing(distcnt(i,j))) then
;   if(distcnt(i,j).ne.0) then
;   wgtss(i,j)=wgtss(i,j)/distcnt(i,j)
;   wgtsi(i,j)=wgtsi(i,j)/distcnt(i,j)
;   end if
;   end if
;   end do
;   end do

;   WEIGHT::wdist(wgtss,wgtsi,dist,presm_slp,presm_int,nlvls,nx,ny,lon2dg)

;   print(wgtss(500:520,500:520))
;   print(wgtsi(500:520,500:520))


;   print(presm_int)
;   print(presm_rsq)
;   print(presm_slp)

   cpid(:)=TestDatasp(:,0)

   sidsw(:)=TestDatasw(:,0)
   wiltpt(:)=TestDatasw(:,1)
   fieldc(:)=TestDatasw(:,2)
   availw(:)=TestDatasw(:,3)

   sidsw@_FillValue=9999
   wiltpt@_FillValue=9999
   fieldc@_FillValue=9999
   availw@_FillValue=9999

   sid = new(107,float)
   lat = new(107,float)
   lon = new(107,float)
   otm = new(107,float)

   crnidall = new(ncol-6,integer)

   crnidall(:)=TestDatast(:,0)

   crnid = new(120,float)
   crnlat = new(120,float)
   crnlon = new(120,float)

   crnid(:) =TestDatascrn(:,0)
   crnlat(:)=TestDatascrn(:,1)
   crnlon(:)=TestDatascrn(:,2)

   clat = new(107,float)
   clon = new(107,float)

   cpid = new(107,float)
   cpid(:)=TestDatasp(:,0)

   do i=0,106
   if(crnid(i).eq.cpid(i)) then
   clat(i)=crnlat(i)
   clon(i)=crnlon(i)
   end if
   end do

   idx = new(nlvls,integer)
   idy = new(nlvls,integer)
  
   idxa = new(nlvls,integer)
   idya = new(nlvls,integer)

   do k=0,nlvls-1

   idx(k)=-999
   idy(k)=-999

   idxa(k)=-999
   idya(k)=-999

   do i=0,nlat-1
   do j=0,nlon-1
   if(.not.ismissing(clat(k))) then
   if((abs(clat(k)-latp(i)).lt.0.04).and.(abs(clon(k)-lonp(j)).lt.0.05)) then
   idx(k)=i
   idy(k)=j
   end if
   end if
   end do                               
   end do

   do i=0,nlata-1
   do j=0,nlona-1
   if(.not.ismissing(clat(k))) then
   if((abs(clat(k)-latpa(i)).lt.0.04).and.(abs(clon(k)-lonpa(j)).lt.0.04)) then
   idxa(k)=i
   idya(k)=j
   end if
   end if
   end do
   end do

   end do

   stidx = new(nlvls,integer)

   do k=0,nlvls-1
   do i=0,ncol-7
   if(.not.ismissing(crnidall(i))) then
   if(crnidall(i).eq.crnid(k)) then
   stidx(k)=i+6
   end if
   end if
   end do
   end do

  pltdata@_FillValue=-99
  data@_FillValue=-99
  idx@_FillValue=-999
  idy@_FillValue=-999
  idxa@_FillValue=-999
  idya@_FillValue=-999
  alexi_et@_FillValue=-9999

  do i=0,nlvls-1
  if(.not.ismissing(stidx(i))) then
  if(.not.ismissing(idx(i))) then
  if(.not.ismissing(idy(i))) then
  pltdata(1,i,:)=prismpre(:,idx(i),idy(i))
  end if
  end if
  end if


  if(.not.ismissing(idxa(i))) then
  if(.not.ismissing(idya(i))) then
  do k=0,nlvl-1
  if(.not.ismissing(alexi_et(k,idxa(i),idya(i)))) then
  alexi(i,k)=alexi_et(k,idxa(i),idya(i))*0.408
  end if
  end do
  end if
  end if

  end do

  alexi@_FillValue=-9999

  waterd@_FillValue=-99

  waterdmin = new(nlvls,float)
  waterdmax = new(nlvls,float)


  do j=0,nlvls-1
  do i=0,nlvl-1
  if(ismissing(pltdata(1,j,i))) then
  pltdata(1,j,i)=0.0
  end if
  end do
  end do


;!!!!!!! fill min/max values

   minmax_in = new(11, string)
   minmax = new((/11,107,2/), float)

   do i=0,nlvls-1
   waterdmin(i)=1000.00
   waterdmax(i)=0.0
   end do

   do n=0,10
   nmbyr=2010+n
   minmax_in(n) = "minmax_"+nmbyr+".txt"

 ;  print(minmax_in(n))

   MinmaxData = asciiread(minmax_in(n), (/107,2/), "float")

   minmax(n,:,:)=MinmaxData(:,:)

   end do

    do n=0,10
    do i=0,nlvls-1
   if(minmax(n,i,0).lt.waterdmin(i)) then
   waterdmin(i)=minmax(n,i,0)
   end if
   if(minmax(n,i,1).gt.waterdmax(i)) then
   waterdmax(i)=minmax(n,i,1)
   end if
   end do
   end do

;   print(waterdmin)
;   print(waterdmax)


  do i=0,nlvls-1
  pltdatarun(1,i,0)=pltdata(1,i,0)
  waterdrun(1,i,0)=waterd(i,0)

  if(ismissing(waterd(i,0)))then
  waterdrun(1,i,0)=((wiltpt(i)+fieldc(i))/2.0)*2.5
  end if



  do j=1,nlvl-1
  pltdatarun(1,i,j)=pltdatarun(1,i,j-1)+pltdata(1,i,j)


  if(.not.ismissing(alexi(i,j))) then
;  waterdrun(1,i,j)=waterdrun(1,i,j-1)+(pltdata(1,i,j)-alexi(i,j))
  waterdrun(1,i,j)=waterdrun(1,i,j-1)+(pltdata(1,i,j)-alexi(i,j))*presm_slp(i)+presm_int(i)
  else
  waterdrun(1,i,j)=waterdrun(1,i,j-1)+(pltdata(1,i,j)-alexi(i,j-1))*presm_slp(i)+presm_int(i)
  end if


  if(.not.ismissing(waterdrun(1,i,j)))

  if(waterdmin(i).ne.1000) then
  if(waterdrun(1,i,j).lt.waterdmin(i)) then
  waterdrun(1,i,j)=waterdmin(i)    ; multiply by 1 to get units in mm of water in column
  end if
  end if
  if(waterdmax(i).ne.0) then
  if(waterdrun(1,i,j).gt.waterdmax(i)) then
  waterdrun(1,i,j)=waterdmax(i)
  end if
  end if

  if(waterdmin(i).eq.1000) then
  waterdrun(1,i,j)=waterd@_FillValue
  end if

  if(waterdmax(i).eq.0) then
  waterdrun(1,i,j)=waterd@_FillValue
  end if



  end if

  end do

  end do


  do i=0,nlvls-1
  do j=0,nlvl-1
  if(ismissing(waterdrun(1,i,j))) then
  waterdrun(1,i,j)=-99
  end if
  end do
  end do


   day = new(nlvl,integer)

   do i=0,nlvl-1
   day(i)=i
   end do

  imnbr = new(ntime, string)
  idnbr = new(nlvls, string)

  timnbr = new(ntime, string)

  do i=0,ntime-1
  imnbr(i)=i+1
  timnbr(i)=1000+i
  end do

;  do n=0,nlvls-1
;  imnbr(n)=crnid(n)
;  idnbr(n)=1000+n
;  end do

   plat = new(720,float)
   plon = new(1150,float)

  plat =  10.*fspan(2.3,5.0,nx)
  plon =  -10.*fspan(12.5,6.5,ny)

  mdat = new(107,float)
  sm = new((/ntime,nx,ny/), float)
  maxmoist = new((/ntime,nx,ny/), float)
  minmoist = new((/ntime,nx,ny/), float)

   slat = new((/107,ntime/),float)
   slon = new((/107,ntime/),float)
  
   dlat = new(107,float)
   dlon = new(107,float)

  mm=new(nlvls,float)
  mm@_FillValue=-99
  waterdmin@_FillValue=-99
  waterdmax@_FillValue=-99
  do i=0,nlvls-1
  if(waterdmin(i).eq.1000) then
  waterdmin(i)=waterdmin@_FillValue
  end if
  if(waterdmax(i).eq.0) then
  waterdmax(i)=waterdmax@_FillValue
  end if
  end do

;!!!!!!!!!! loop over year

;  do n=0,ntime-1
  n=0

  otm(:)=waterdrun(1,:,n)

; print(otm)

  cnt=0


  do i=0,106
;  if((otm(i).ne.-99).and.(otm(i).ne.-9999)) then
;  print(i)
;  print(otm(i))
  if(.not.ismissing(otm(i))) then
  mdat(i)=otm(i)
;  mdat(i)=(otm(i)-waterdmin(i))/(waterdmax(i)-waterdmin(i))
;  mdat(i)=1.0-mdat(i)
;  mdat(i)=(mdat(i)-0.5)*-10.0
  dlat(i)=clat(i)
  dlon(i)=clon(i)
  slat(i,n)=clat(i)
  slon(i,n)=clon(i)

  cnt=cnt +1
  end if
  end do


;  end do ; n = time

;  print(lon)
;  print(dlat)
;  print(mdat)

  lon@units = "degrees_east"
  lat@units = "degrees_north"
  plon@units = "degrees_east"
  plat@units = "degrees_north"

  rscan = (/10, 8, 6/)
  opt = True
  opt@blend_wgt = (/1.0, 0.5, 0.25/)

;    sm  = cssgrid_Wrap(lat,lon,mdat,plat,plon)
    sm(n,:,:)  = obj_anal_ic_Wrap(dlon,dlat,mdat,plon,plat,rscan,False) ; note lat/lon flipped
    maxmoist(n,:,:)=obj_anal_ic_Wrap(dlon,dlat,waterdmax,plon,plat,rscan,False)
    minmoist(n,:,:)=obj_anal_ic_Wrap(dlon,dlat,waterdmin,plon,plat,rscan,False)
;    sm  = obj_anal_ic_Wrap(dlon,dlat,mdat,plon,plat,rscan,False) ; note lat/lon flipped

;   sm@lat2d = plat
;   sm@lon2d = plon

;   print(sm)
   c = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
   lsdata = c->LSMASK
   lsm = landsea_mask(lsdata,plat,plon)

   sm = mask(sm,lsm.eq.0,False)

   smn = new((/ntime,nx,ny/), float)
 ;  end do ; n

;   latlons = new((/nx,ny/), integer)
;   latlons = getind_latlon2d(lat2dg,lon2dg,plat,plon)

;   wlat=new(nx,integer)
;   wlon=new(ny,integer)

;   print(dist)

;   WEIGHT::wdist(wgtss,nlvls,nx,ny)
;   WEIGHT::wdist(wgtss,wgtsi,dist,presm_slp,presm_int,nlvls,nx,ny,plat,plon,lat2dg,lon2dg)
;   WEIGHT2::wdist2(wgtss,wgtsi,dist,presm_slp,presm_int,nlvls,nx,ny,wlat,wlon)
;   TestDataws = asciiread("slp_weights.txt", (/nx,ny/), "float")
;   TestDatawi = asciiread("int_weights.txt", (/nx,ny/), "float")
;   wgtss(:,:)=TestDataws(:,:)
;   wgtsi(:,:)=TestDatawi(:,:)

;   print(dist(0:20,500,:))
;   print(wgtss(500,:))

   wgtss=asciiread("slp_weights.txt",(/nx,ny/),"float")
   wgtsi=asciiread("int_weights.txt",(/nx,ny/),"float")

   optn=True
   optn@fout = "slp_weights.txt"
   write_matrix(wgtss, "1150f11.2,1x", optn)

   optp=True
   optp@fout = "int_weights.txt"
   write_matrix(wgtsi, "1150f11.2,1x", optp)


   SWAMP::wswamp(sm,smn,wgtss,wgtsi,prismpre,alexi_et,plat,plon,latp,lonp,latpa,lonpa,nlat,nlon,nlata,nlona,nlvls,nx,ny,ntime,maxmoist,minmoist)

   do n=1,ntime-1
   sm(n,:,:)=mask(sm(n,:,:),lsm.eq.0,False)
   smn(n,:,:)=mask(smn(n,:,:),lsm.eq.0,False)
   end do

   do n=1,ntime-1
   sm(n,:,:)=sm(n,:,:)/2.5
   smn(n,:,:)=smn(n,:,:)/2.5
   end do

;  idsx = new(nx, integer)
;  idsy = new(ny, integer)
;  idsax = new(nx, integer)
;  idsay = new(ny, integer)

;  do i=0,nx-1
;  do k=0,nlat-1
;  if((abs(plat(i)-latp(k)).lt.0.05)) then
;  idsx(i)=k
;  print(idsx(i))
;  end if
;  end do
;  end do

;  do j=0,ny-1
;  do m=0,nlon-1
;  if((abs(plon(j)-lonp(m)).lt.0.05)) then
;  idsy(j)=m
;  end if
;  end do
;  end do

;  do i=0,nx-1
;  do k=0,nlata-1
;  if((abs(plat(i)-latpa(k)).lt.0.05)) then
;  idsax(i)=k
;  end if
;  end do
;  end do

;  do j=0,ny-1
;  do m=0,nlona-1
;  if((abs(plon(j)-lonpa(m)).lt.0.05)) then
;  idsay(j)=m
;  end if
;  end do
;  end do


;  do n=1,ntime-1
;  do i=0,nx-1
;  do j=0,ny-1
;  if(.not.ismissing(idsx(i)))
;  if(.not.ismissing(idsy(j)))
;  if(.not.ismissing(idsax(i)))
;  if(.not.ismissing(idsay(j)))
;  sm(n,i,j)=sm(n-1,i,j)+(prismpre(n,idsx(i),idsy(j))-alexi_et(n,idsax(i),idsay(j))*0.408)*wgtss(i,j) + wgtsi(i,j)

;  if(.not.ismissing(maxmoist(0,i,j))) then
;  if(.not.ismissing(sm(n,i,j))) then
;  if(sm(n,i,j).gt.maxmoist(0,i,j)) then
;  sm(n,i,j)=maxmoist(0,i,j)
;  end if
;  end if
;  end if

;  if(.not.ismissing(minmoist(0,i,j))) then
;  if(.not.ismissing(sm(n,i,j))) then
;  if(sm(n,i,j).lt.minmoist(0,i,j)) then
;  sm(n,i,j)=minmoist(0,i,j)
;  end if
;  end if
;  end if


;  end if
;  end if 
;  end if
;  end if
;  end do
;  end do

;  print(n)
;  end do



;***************************
; Create netCDF file
;***************************

   system("/bin/rm -f SWAMP_"+yearcrn+".nc")   ; remove any pre-existing file
   ncdf = addfile("SWAMP_"+yearcrn+".nc","c")  ; open output netCDF file

   times=new(ntime,double)
   do i=0,ntime-1
   times(i)=i
   end do

   times@units = "days since "+yearcrn+"-01-01 00:00:00"

   sm!0 = "time"
   sm&time = times
   sm@long_name = "soil water analysis model product"
   sm@standard_name = "SWAMP "
   sm@units = "percent"

   sm!1 = "lat"	
   sm!2 = "lon"
   plat@units="degrees_north" 
   plon@units="degrees_east"
   sm@lat = plat
   sm@lon = plon

   smr!0 = "time"
   smr&time = times
   smr@long_name = "relative soil water analysis model product"
   smr@standard_name = " RSWAMP"
   smr@units = "percent"

   smr!1 = "lat"
   smr!2 = "lon"
   smr@lat = plat
   smr@lon = plon


;===================================================================
; create global attributes of the file (optional)
;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "CRN gridded analysis"
   fAtt@source_file   =  "original-file.nc"
   fAtt@Conventions   = "None"
   fAtt@creation_date = systemfunc ("date")
   fileattdef( ncdf, fAtt )            ; copy file attributes

;===================================================================
; make time an UNLIMITED dimension; recommended  for most applications
;===================================================================
   filedimdef(ncdf,"time",-1,True)

;===================================================================
; output variables directly; NCL will call appropriate functions
; to write the meta data associated with each variable
;===================================================================
;   ncdf->T  = T                          ; 4D
;   ncdf->PS = PS                         ; 3D
   ncdf->SM = sm                         ; 3D
   ncdf->SMR = smr
                                             ; say ORO(:,:)
;   ORO!0    = "lat"                      ; assign named dimensions
;   ORO!1    = "lon"

;   ORO&lat  = T&lat                      ; copy lat from T to ORO
;   ORO&lon  = T&lon

;   ORO@long_name = "orography"           ; assign attributes
;   ORO@units     = "m"

;   ncdf->TOPOGRAPHY = ORO                ; name on file different from name in code


   n=80
  do n=0,ntime-1
  wks  = gsn_open_wks("png",diri+"SWAMP"+runnbr(1)+"_"+timnbr(n))    ; open a ps file
;  gsn_define_colormap(wks,"cosam")     ; define colormap
;  gsn_define_colormap(wks,"BlAqGrWh2YeOrReVi22")
;  gsn_define_colormap(wks,"smoist_msb")
   daylable="DOY "+imnbr(n)+" "+yearcrn

;*****************************
; create first plot
;*****************************
  resn            = True        ; create vector resource array

  resn@xyLineColors      = (/"black","blue","red","green","orange"/)
  resn@xyDashPattern = 0
  resn@xyLineThicknessF = 4.0

;  resn@xyMarkLineMode = "MarkLines"    ; Markers *and* lines
;  resn@xyMarkers      = (/6,11,16,21/)    ; 3 different markers
;  resn@xyMarkerColors = (/"black","blue","red","green"/)  ; 3 different colors

  resn@tiMainString = " "

  resn@pmLegendDisplayMode    = "Always"            ; turn on legend

  resn@pmLegendSide           = "Top"               ; Change location of
  resn@pmLegendParallelPosF   = .80                 ; move units right
  resn@pmLegendOrthogonalPosF = -0.5                ; move units down

  resn@pmLegendWidthF         = 0.15                ; Change width and
  resn@pmLegendHeightF        = 0.18                ; height of legend.
  resn@lgLabelFontHeightF     = .015                 ; change font height
  resn@lgTitleOn              = True                ; turn on legend title
  resn@lgTitleString          = daylable           ; create legend title
  resn@lgTitleFontHeightF     = .015                ; font of legend title
  resn@xyExplicitLegendLabels = (/"40","80","120","160","200"/)         ; explicit labels

;  resn@trYMinF            = 0.0            ; set axis min/max
;  resn@trYMaxF            = 3000.0

;  resn@trXMinF            = 0.0            ; set axis min/max
;  resn@trXMaxF            = 0.6


  resn@tiYAxisString = "Height"
  resn@tiXAxisString = "Variance"

;  plot1 = gsn_csm_xy(wks,dday,smoist(55,:),resn)

;*****************************
; create second plot
;*****************************
  resr            = True        ; create vector resource array
  resr@cnFillOn   = True        ; color fill
  resr@cnLinesOn  = False       ; no contour lines

  resr@cnFillMode = "RasterFill" ; speed up plotting

  resr@gsnLeftString    = ""     ; no titles
  resr@gsnRightString   = ""
  resr@tiXAxisString    = ""
  resr@tiYAxisString    = ""

  resr@gsnDraw    = False       ; don't draw
  resr@gsnFrame   = False       ; don't advance frame

  resr@vpWidthF  = 0.6                    ; change the aspect ratio
  resr@vpHeightF = 0.4


  resr@mpDataBaseVersion = "MediumRes"
  resr@pmTickMarkDisplayMode = "Always"

  resr@gsnAddCyclic = False    ; regional data

  resr@mpProjection = "LambertConformal"

  resr@mpLimitMode            = "Corners"          ; choose region of map
  resr@mpLeftCornerLatF       = plat(0)
  resr@mpLeftCornerLonF       = plon(0)
  resr@mpRightCornerLatF      = plat(nx-1)
  resr@mpRightCornerLonF      = plon(ny-1)

;  resr@mpLeftCornerLatF       = lat(450,500)         ;  choose subset
;  resr@mpLeftCornerLonF       = lon(820,1200)
;  resr@mpRightCornerLatF      = lat(475,800)
;  resr@mpRightCornerLonF      = lon(800,1300)

  resr@mpLeftCornerLatF       = 23.0        ;  choose subset
  resr@mpLeftCornerLonF       = -120.0
  resr@mpRightCornerLatF      = 46.0
  resr@mpRightCornerLonF      = -60.0



  resr@mpLambertMeridianF = -97.5
  resr@mpLambertParallel1F = 38.5
  resr@mpLambertParallel2F = 38.5

;  resr@mpDataBaseVersion = "MediumRes"
;  resr@mpDataSetName = "Earth..4"
;  resr@mpOutlineBoundarySets = "AllBoundaries" ; all boundaries
  resr@mpOutlineBoundarySets = "GeophysicalAndUSStates" ;


  resr@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resourc$
  resr@cnMinLevelValF =  0.0
  resr@cnMaxLevelValF =  150.0
  resr@cnLevelSpacingF = 5.0

;   resr@cnLevelSelectionMode = "ExplicitLevels"
;   resr@cnLevels = (/.6,.7,.8,.9,.95/)

;   resr@cnExplicitLabelBarLabelsOn=True
;   resr@lbLabelStrings = (/"D0", "D1", "D2", "D3", "D4"/)

;  resr@gsnPaperOrientation = "Portrait"

  resr@pmLegendDisplayMode    = "Always"            ; turn on legend

  resr@pmLegendSide           = "Top"               ; Change location of
  resr@pmLegendParallelPosF   = .80                 ; move units right
  resr@pmLegendOrthogonalPosF = -0.5                ; move units down

  resr@pmLegendWidthF         = 0.15                ; Change width and
  resr@pmLegendHeightF        = 0.18                ; height of legend.
  resr@lgLabelFontHeightF     = .015                 ; change font height
  resr@lgTitleOn              = True                ; turn on legend title
  resr@lgTitleString          = "soil water (mm)"           ; create legend title
  resr@lgTitleFontHeightF     = .015                ; font of legend title
;  resr@xyExplicitLegendLabels = (/"40","80","120","160","200"/)         ; explicit labels

;  resr@tiMainOn = False

  resr@tiMainString    = "SWAMP"   ; add titles

  resr@lbTitleOn        = True                  ; turn on title
  resr@lbTitleString    = "25 cm soil water"
  resr@lbTitlePosition  = "Bottom"              ; title position
  resr@lbTitleFontHeightF= .015                 ; make title smaller


  plot2 = gsn_csm_contour_map(wks,sm(n,:,:),resr)
;  plot2 = gsn_csm_contour_map(wks,sm,resr)

  txresr                       = True
  txresr@txPerimOn             = True
  txresr@txBackgroundFillColor = "white"
  txresr@txFontHeightF         = 0.01

  txresr@txFont                = "helvetica-bold"

  amresr = True

  amresr@amParallelPosF   = 0.38    ; This is the right edge of the plot.
  amresr@amOrthogonalPosF = 0.3    ; This is the bottom edge of the plot.

  txid = gsn_create_text(wks, daylable, txresr)

  annoid = gsn_add_annotation(plot2, txid, amresr)  ; Attach string to plot
                                                  ; using default values.

;*****************************
; create third
;*****************************

  pmres = True
  pmres@gsMarkerIndex      = 17             ; Filled circle
  pmres@gsMarkerSizeF      = 0.025

;  plot3 = gsn_add_polymarker(wks, plot2, slon(:,n), slat(:,n), pmres)
;  plot3 = gsn_add_polymarker(wks, plot2, lon, lat, pmres)
  plot3 = gsn_add_polymarker(wks, plot2, crnlon, crnlat, pmres)

  draw(plot2)
  frame(wks)

  end do ; n

;  end do ; p


end

