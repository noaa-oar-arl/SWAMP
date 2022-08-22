;*************************************************
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

external STATMATCH "./statmatch.so"
print("Processing Fract_avail_water_grid...")
begin

; --- Read Data ----------------------------------------;
 ;diri = "/fs/scd/home1/shea/ncldata_input/"
  yearcrn = getenv("YEAR_CRN")
  sdate  = stringtointeger(getenv("SDATE_CRN"))
  edate  = stringtointeger(getenv("EDATE_CRN"))
  totday = edate-sdate+1
  diri = "./variables_"+yearcrn+"/"

  pre = "FractAWC"
  prei1 = "Smois_05cm_"
  prei2 = "Smois_10cm_"
  prei3 = "Smois_20cm_"
  prei4 = "Smois_50cm_"
  prei5 = "Smois_100cm_"
  preis = "stationID_lat_lon_"
  preiscrn = "USCRN_stations_id_lat_lon"
  presw = "soil_water"
  fili = ".txt"
  lili = ".nc"
;  nlvl = 365
  ncol = numAsciiCol(diri+prei1+yearcrn+fili)
  nlvlsw = 107
  ncolsw = 4
;  ntime = 365
  nz = 121
  nx = 720
  ny = 1150

  nlvl = totday
  ntime = totday


  runnbr = new(6, string)
  imnbr = new(ntime, string)
  timnbr = new(ntime, string)

  do i=0,ntime-1
  imnbr(i)=i
  timnbr(i)=1000+i
  end do


  runnbr(1) = yearcrn
	
;  do p=1,1

  TestData1 = asciiread (diri+prei1+runnbr(1)+fili , (/nlvl,ncol/), "float")
  TestData2 = asciiread (diri+prei2+runnbr(1)+fili , (/nlvl,ncol/), "float")
  TestData3 = asciiread (diri+prei3+runnbr(1)+fili , (/nlvl,ncol/), "float")
  TestData4 = asciiread (diri+prei4+runnbr(1)+fili , (/nlvl,ncol/), "float")
  TestData5 = asciiread (diri+prei5+runnbr(1)+fili , (/nlvl,ncol/), "float")
  TestDatas = asciiread (diri+preis+runnbr(1)+fili , (/ncol-6,3/), "float")
;  TestDatascrn = asciiread (diri+preiscrn+fili , (/120,3/), "float")
  TestDatascrn = asciiread (diri+preis+runnbr(1)+fili , (/120,3/), "float")
  TestDatasw = asciiread (diri+presw+fili , (/107,4/), "float")

   data  = new((/ncol,nlvl/),float)
   smoist1 = new((/ncol-6,nlvl/), float)
   smoist2 = new((/ncol-6,nlvl/), float)
   smoist3 = new((/ncol-6,nlvl/), float)
   smoist4 = new((/ncol-6,nlvl/), float)
   smoist5 = new((/ncol-6,nlvl/), float)


   sid = new(ncol-6,float)
   lat = new(ncol-6,float)
   lon = new(ncol-6,float)
   otm = new(ncol-6,float)
   otmu = new(ncol-6,float)

   otmpct= new(ncol-6,float)

   otmfc = new(ncol-6,float)
   otmwp = new(ncol-6,float)

   sidsw = new(107,float)
   wiltpt = new(107,float)
   fieldc = new(107,float)
   availw = new(107,float)

   wiltptg = new(ncol-6,float)
   fieldcg = new(ncol-6,float)
   availwg = new(ncol-6,float)

   slat = new((/ncol-6,ntime/),float)
   slon = new((/ncol-6,ntime/),float)

   dlat = new(ncol-6,float)
   dlon = new(ncol-6,float)

   crnid = new(120,float)
   crnlat = new(120,float)
   crnlon = new(120,float)

   crnid(:)=TestDatascrn(:,0)
   crnlat(:)=TestDatascrn(:,1)
   crnlon(:)=TestDatascrn(:,2)

   sid(:)=TestDatas(:,0)
   lat(:)=TestDatas(:,1)
   lon(:)=TestDatas(:,2)

   sidsw(:)=TestDatasw(:,0)
   wiltpt(:)=TestDatasw(:,1)
   fieldc(:)=TestDatasw(:,2)
   availw(:)=TestDatasw(:,3)


;   print(sidsw)
;   print(lat)
;   print(lon)

;   do i=0,ncol-1
;   print(TestData(1932,i))
;   end do

    do i=0,ncol-7
    do j=0,106
    if(.not.ismissing(sid(i)))
    if(sidsw(j).eq.sid(i)) then
    wiltptg(i)=wiltpt(j)
    fieldcg(i)=fieldc(j)
    availwg(i)=availw(j)
    end if
    end if
    end do
    end do

   wiltptg@_FillValue = -99
   fieldcg@_FillValue = -99
   availwg@_FillValue = -99

    do i=0,ncol-7

    if(.not.ismissing(wiltptg(i)))
    if(wiltptg(i).eq.9999) then
    wiltptg(i)=-99
    end if
    end if

    if(.not.ismissing(fieldcg(i)))
    if(fieldcg(i).eq.9999) then
    fieldcg(i)=-99               
    end if 
    end if

    if(.not.ismissing(availwg(i)))
    if(availwg(i).eq.9999) then
    availwg(i)=-99               
    end if 
    end if

    otmfc(i)=0.0
    otmwp(i)=1000.0

    end do


;   print(wiltptg)

  do i=0,ncol-1
  data(i,:) = TestData1(:,i)
  end do

  dday=data(0,:)
  year=data(1,:)
  month=data(2,:)
  day=data(3,:)
  hour=data(4,:)
  minute=data(5,:)
  
  do i=6,ncol-1
  smoist1(i-6,:)=data(i,:)
  smoist2(i-6,:)=TestData2(:,i)
  smoist3(i-6,:)=TestData3(:,i)
  smoist4(i-6,:)=TestData4(:,i)
  smoist5(i-6,:)=TestData5(:,i)
  end do

;  print(smoist(:,1932))


;   dmsg=-99
;   dmsg@_FillValue = -99

;   smoist@_FillValue = -99
;   otm@_FillVallue = -99

;;  print(smoist(:,32))

;  wks  = gsn_open_wks("X11","gsn_contour")    ; open a ps file
;  wks  = gsn_open_wks("pdf",diri+prei+runnbr(1))    ; open a ps file
;  gsn_define_colormap(wks,"MPL_YlGnBu")     ; define colormap


;   SOILM::soilob(data,vari,nlvl,ncol,nz,ntime)

   plat = new(720,float)
   plon = new(1150,float)

  plat =  10.*fspan(2.3,5.0,nx)
  plon =  -10.*fspan(12.5,6.5,ny)

  mdat = new(ncol-6,float)
  mdat2 = new(ncol-6,float)
  mdatdiff = new(ncol-6,float)
  sm = new((/ntime,nx,ny/), float)
  sm2 = new((/ntime,ny,nx/), float)

  mdatprt = new((/153,ntime/), float)

;!!!!!!!!!! loop over year

  do n=0,ntime-1

;  m=n*24 + 12
;  otm(:)=smoist(:,m)


   smoist1@_FillValue = -99
   smoist2@_FillValue = -99
   smoist3@_FillValue = -99
   smoist4@_FillValue = -99
   smoist5@_FillValue = -99

  do i=0,ncol-7
  if(.not.ismissing(smoist1(i,n)))
  if(.not.ismissing(smoist2(i,n)))
  if(.not.ismissing(smoist3(i,n)))
;  if(.not.ismissing(smoist4(i,n)))
;  if(.not.ismissing(smoist5(i,n)))

;  otm(i)=smoist1(i,n)*7.5+smoist2(i,n)*7.5+smoist3(i,n)*20+smoist4(i,n)*40+smoist5(i,n)*25
  otm(i)=smoist1(i,n)*7.5+smoist2(i,n)*7.5+smoist3(i,n)*20

  if(otm(i).gt.otmfc(i)) then
  otmfc(i)=otm(i)
  end if

  if(otm(i).lt.otmwp(i)) then
  otmwp(i)=otm(i)
  end if

;  end if
;  end if
  end if
  end if
  end if
  end do

  end do ; n

;  print(otmfc)
;  print(otmwp)

  do n=0,ntime-1

   smoist1@_FillValue = -99
   smoist2@_FillValue = -99
   smoist3@_FillValue = -99
   smoist4@_FillValue = -99
   smoist5@_FillValue = -99

  do i=0,ncol-7
  if(.not.ismissing(smoist1(i,n)))
  if(.not.ismissing(smoist2(i,n)))
  if(.not.ismissing(smoist3(i,n)))
;  if(.not.ismissing(smoist4(i,n)))
;  if(.not.ismissing(smoist5(i,n)))

;  otm(i)=smoist1(i,n)*7.5+smoist2(i,n)*7.5+smoist3(i,n)*20+smoist4(i,n)*40+smoist5(i,n)*25
  otm(i)=smoist1(i,n)*7.5+smoist2(i,n)*7.5+smoist3(i,n)*20

;  otmu(i)=smoist1(i,n)*7.5+smoist2(i,n)*7.5
;  otmu(i)=otmu(i)*(100.0/15.0)

;  end if
;  end if
  end if
  end if
  end if
  end do    

  cnt=0

  do j=0,119
  do i=0,ncol-7
  if(crnid(j).eq.sid(i)) then
;  if((otm(i).ne.-99).and.(otm(i).ne.-9999)) then
  if(.not.ismissing(otm(i)))
  if(.not.ismissing(fieldcg(i)))
  if(.not.ismissing(wiltptg(i)))
  if(.not.ismissing(availwg(i)))
  if(otmfc(i).ne.otmwp(i)) then
;  mdat(i)=(otm(i)-wiltptg(i))/(fieldcg(i)-wiltptg(i))
  mdat(i)=(otm(i)-otmwp(i))/(otmfc(i)-otmwp(i))
;  mdat2(i)=(otmu(i)-otmwp(i))/(otmfc(i)-otmwp(i))
;  mdatdiff(i)=mdat(i)-mdat2(i)
;  mdat(i)=otm(i)
  dlat(i)=lat(i)
  dlon(i)=lon(i)
  slat(i,n)=lat(i)
  slon(i,n)=lon(i)
  else
  mdat(i)=otm@_FillValue
  mdatdiff(i)=otm@_FillValue

;  cnt=cnt +1
  end if
  end if
  end if
  end if
  end if
  end if
  end do
  end do


;  end do ; n = time

;  print(dlon)
;  print(dlat)
;  print(mdatdiff)
;  print(otm)
;  print(smoist3(:,n))
;  print(sid)
;  print(wiltptg)
;  print(fieldcg)


;  lon@units = "degrees_east"
;  lat@units = "degrees_north"
;  plon@units = "degrees_east"
;  plat@units = "degrees_north"


;  rscan = (/0.023/)
;  opt = True           
;  opt@blend_wgt = (/1.0, 0.5, 0.25/)

;    sm  = cssgrid_Wrap(lat,lon,mdat,plat,plon)
;    sm(n,:,:)  = obj_anal_ic_Wrap(dlon,dlat,mdat,plon,plat,rscan,False) ; note lat/lon flipped
;    sm  = obj_anal_ic_Wrap(dlon,dlat,mdat,plon,plat,rscan,False) ; note lat/lon flipped

;   sm@lat2d = plat
;   sm@lon2d = plon

;   print(sm)

   c = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
   lsdata = c->LSMASK
   lsm = landsea_mask(lsdata,plat,plon)

   sm = mask(sm,lsm.eq.0,False)

   sm1 = new((/ny,nx/),float)

;   sm1@_FillValue=-999
;   sm@_FillValue=-999


   mdatprt(14,n)=mdat(14)

   rncol=ncol-6

   STATMATCH::match(mdat,sm1,dlat,dlon,plat,plon,rncol,nx,ny,sm1@_FillValue)

   do i=0,nx-1
   do j=0,ny-1
;   sm(n,i,j)=sm1(j,i)
   sm2(n,j,i)=sm1(j,i)
   end do
   end do

   end do ; n

;  print(mdatprt)

  sm2!0 = "time"
  sm2!1 = "lon"
  sm2!2 = "lat"

  sm = sm2( time|: , lat|:, lon|:)

;***************************
; Create netCDF file
;***************************

  filenm = diri+prei1+runnbr(1)+lili

;  print(filenm)

;   system("/bin/rm -f $filenm")   ; remove any pre-existing file
;   ncdf = addfile(diri+prei+runnbr(p)+lili ,"c")  ; open output netCDF file

   system("/bin/rm -f FractAWC_"+yearcrn+"_station.nc")   ; remove any pre-existing file
   ncdf = addfile("FractAWC_"+yearcrn+"_station.nc","c")  ; open output netCDF file

   times = new(ntime,double)
   do i=0,ntime-1
   times(i)=i
   end do

   times@units = "days since "+yearcrn+"-01-01 00:00:00"

   sm!0 = "time"
   sm&time = times
   sm@long_name = "Fractional available water"
   sm@standard_name = "fractional available water"
   sm@units = "percent"

   sm!1 = "lat"
   sm!2 = "lon"
   plat@units="degrees_north"
   plon@units="degrees_east"
   sm&lat = plat
   sm&lon = plon


;===================================================================
; create global attributes of the file (optional)
;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "CRN gridded analysis"
   fAtt@source_file   =  "original-file.nc"
   fAtt@Conventions   = "CF-1.0"
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
  wks  = gsn_open_wks("png",diri+pre+runnbr(1)+"_"+timnbr(n))    ; open a ps file

;  gsn_define_colormap(wks,"smoist_msb")     ; define colormap

  daylable="DOY "+imnbr(n)+" "+yearcrn

;*****************************
; create first plot
;*****************************
  resn            = True 	; create vector resource array

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
  resn@xyExplicitLegendLabels = (/"40","80","120","ncol-1","ncol-7"/)         ; explicit labels

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

  resr@gsnLeftString    = ""     ; no titles
  resr@gsnRightString   = ""
  resr@tiXAxisString    = ""
  resr@tiYAxisString    = ""

  resr@gsnDraw    = False       ; don't draw
  resr@gsnFrame   = False       ; don't advance frame

  resr@vpWidthF  = 0.6                    ; change the aspect ratio
  resr@vpHeightF = 0.4

;  resr@tmXBMode = "Manual"
;  resr@trXMinF = 0
;  resr@tmXBTickStartF = resn@trXMinF
;  resr@trYMinF = 0
;  resr@tmYRTickStartF = resn@trYMinF
;  resr@tmXBTickEndF = 3ncol-70
;  resr@tmXBTickSpacingF = 4000

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
;  resr@mpLeftCornerLonF       = lon(820,1ncol-7)
;  resr@mpRightCornerLatF      = lat(475,800)
;  resr@mpRightCornerLonF      = lon(800,1300)

  resr@mpLeftCornerLatF       = 25.0        ;  choose subset
  resr@mpLeftCornerLonF       = -120.0
  resr@mpRightCornerLatF      = 45.0
  resr@mpRightCornerLonF      = -60.0



  resr@mpLambertMeridianF = -97.5
  resr@mpLambertParallel1F = 38.5
  resr@mpLambertParallel2F = 38.5

;  resr@mpDataBaseVersion = "MediumRes"
;  resr@mpDataSetName = "Earth..4"
;  resr@mpOutlineBoundarySets = "AllBoundaries" ; all boundaries
  resr@mpOutlineBoundarySets = "GeophysicalAndUSStates" ;

;  resr@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resourc$
;  resr@cnMinLevelValF = 0.0
;  resr@cnMaxLevelValF = 5.0
;  resr@cnLevelSpacingF = 0.05


  resr@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resourc$
  resr@cnMinLevelValF =  -0.2
  resr@cnMaxLevelValF =  0.2
  resr@cnLevelSpacingF = 0.023
  


;  resr@gsnPaperOrientation = "Portrait"

  resr@pmLegendDisplayMode    = "Always"            ; turn on legend

  resr@pmLegendSide           = "Top"               ; Change location of
  resr@pmLegendParallelPosF   = .80                 ; move units right
  resr@pmLegendOrthogonalPosF = -0.5                ; move units down

  resr@pmLegendWidthF         = 0.15                ; Change width and
  resr@pmLegendHeightF        = 0.18                ; height of legend.
  resr@lgLabelFontHeightF     = .015                 ; change font height
  resr@lgTitleOn              = True                ; turn on legend title
  resr@lgTitleString          = "Time (min)"           ; create legend title
  resr@lgTitleFontHeightF     = .015                ; font of legend title
;  resr@xyExplicitLegendLabels = (/"40","80","120","ncol-1","ncol-7"/)         ; explicit labels

;  resr@tiMainOn = False

  resr@tiMainString    = "Fractional AWC"   ; add titles

  resr@lbTitleOn        = True                  ; turn on title
  resr@lbTitleString    = "Fractional AWC (%)"
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
  pmres@gsMarkerSizeF      = 0.0235

;  ;;;plot3 = gsn_add_polymarker(wks, plot2, slon(:,n), slat(:,n), pmres)
;  ;;;plot3 = gsn_add_polymarker(wks, plot2, lon, lat, pmres)
;  ;;;plot3 = gsn_add_polymarker(wks, plot2, crnlon, crnlat, pmres)

  draw(plot2)
  frame(wks)


  end do ; n

;  end do ; p


end
