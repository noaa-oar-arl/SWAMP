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

;external SOILM "./soilm.so"

begin
print("Processing Smois_20cm_grid...")
; --- Read Data ----------------------------------------;
 ;diri = "/fs/scd/home1/shea/ncldata_input/"
  yearcrn = getenv("YEAR_CRN")
  sdate  = stringtointeger(getenv("SDATE_CRN"))
  edate  = stringtointeger(getenv("EDATE_CRN"))
  totday = edate-sdate+1
  diri = "./variables_"+yearcrn+"/"

  prei = "Smois_20cm_"
  preis = "stationID_lat_lon_"
  preiscrn = "USCRN_stations_id_lat_lon"
  fili = ".txt"
  lili = ".nc"
  ncol = numAsciiCol(diri+prei+yearcrn+fili)
  nz = 121
  nx = 150
  ny = 325


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

  TestData = asciiread (diri+prei+runnbr(1)+fili , (/nlvl,ncol/), "float")
  TestDatas = asciiread (diri+preis+runnbr(1)+fili , (/ncol-6,3/), "float")
;  TestDatascrn = asciiread (diri+preiscrn+fili , (/120,3/), "float")
  TestDatascrn = asciiread (diri+preis+runnbr(1)+fili , (/120,3/), "float")

   data  = new((/ncol,nlvl/),float)
   smoist = new((/ncol-6,nlvl/), float)

   sid = new(ncol-6,float)
   lat = new(ncol-6,float)
   lon = new(ncol-6,float)
   otm = new(ncol-6,float)

   slat = new((/ncol-6,ntime/),float)
   slon = new((/ncol-6,ntime/),float)

   dlat = new(ncol-6,float)
   dlon = new(ncol-6,float)
 
   crnlat = new(120,float)
   crnlon = new(120,float)
  
   crnlat(:)=TestDatascrn(:,1)
   crnlon(:)=TestDatascrn(:,2)

   data  = new((/ncol,nlvl/),float)
   smoist = new((/ncol-6,nlvl/), float)

   sid = new(ncol-6,float)
   lat = new(ncol-6,float)
   lon = new(ncol-6,float)
   otm = new(ncol-6,float)

   slat = new((/ncol-6,ntime/),float)
   slon = new((/ncol-6,ntime/),float)

   dlat = new(ncol-6,float)
   dlon = new(ncol-6,float)


   sid(:)=TestDatas(:,0)
   lat(:)=TestDatas(:,1)
   lon(:)=TestDatas(:,2)

;   print(sid)
;   print(lat)
;   print(lon)

;   do i=0,ncol-1
;   print(TestData(1918,i))
;   end do


  do i=0,ncol-1
  data(i,:) = TestData (:,i)
  end do

  dday=data(0,:)
  year=data(1,:)
  month=data(2,:)
  day=data(3,:)
  hour=data(4,:)
  minute=data(5,:)
  
  do i=6,ncol-1
  smoist(i-6,:)=data(i,:)
  end do

;; print(smoist(:,1918))


;   dmsg=-99
;   dmsg@_FillValue = -99

;   smoist@_FillValue = -99
;   otm@_FillVallue = -99

; print(smoist(:,18))

;  wks  = gsn_open_wks("X11","gsn_contour")    ; open a ps file
;  wks  = gsn_open_wks("pdf",diri+prei+runnbr(1))    ; open a ps file
;  gsn_define_colormap(wks,"MPL_YlGnBu")     ; define colormap


;   SOILM::soilob(data,vari,nlvl,ncol,nz,ntime)

   plat = new(150,float)
   plon = new(325,float)

  plat =  5.*fspan(4.0,10.0,nx)
  plon =  -10.*fspan(6.0,12.5,ny)

  mdat = new(ncol-6,float)
  sm = new((/ntime,nx,ny/), float)

;!!!!!!!!!! loop over year

  do n=0,ntime-1

;  m=n*24 + 12
;  otm(:)=smoist(:,m)

  otm(:)=smoist(:,n)

  cnt=0


  do i=0,ncol-7
  if((otm(i).ne.-99).and.(otm(i).ne.-9999)) then
  mdat(i)=otm(i)
  dlat(i)=lat(i)
  dlon(i)=lon(i)
  slat(i,n)=lat(i)
  slon(i,n)=lon(i)

;  cnt=cnt +1
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
;    sm  = obj_anal_ic_Wrap(dlon,dlat,mdat,plon,plat,rscan,False) ; note lat/lon flipped

;   sm@lat2d = plat
;   sm@lon2d = plon

;   print(sm)

   c = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
   lsdata = c->LSMASK
   lsm = landsea_mask(lsdata,plat,plon)

   sm = mask(sm,lsm.eq.0,False)

   end do ; n

;   print(sm(80,:,:))

;***************************
; Create netCDF file
;***************************

  filenm = diri+prei+runnbr(1)+lili

;  print(filenm)

;   system("/bin/rm -f $filenm")   ; remove any pre-existing file
;   ncdf = addfile(diri+prei+runnbr(p)+lili ,"c")  ; open output netCDF file

   system("/bin/rm -f Smois_20cm_"+yearcrn+".nc")   ; remove any pre-existing file
   ncdf = addfile("Smois_20cm_"+yearcrn+".nc","c")  ; open output netCDF file

   times = new(ntime,double)
   do i=0,ntime-1
   times(i)=i
   end do

   times@units = "days since "+yearcrn+"-01-01 00:00:00"

   sm!0 = "time"
   sm&time = times
   sm@long_name = "20 cm soil moisture"
   sm@standard_name = "soil moisture"
   sm@units = "fraction"


;===================================================================
; create global attributes of the file (optional)
;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "CRN soil moisture gridded analysis"
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
  wks  = gsn_open_wks("png",diri+prei+runnbr(1)+"_"+timnbr(n))    ; open a ps file
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
  resn@xyExplicitLegendLabels = (/"40","80","120","161","200"/)         ; explicit labels

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
;  resr@tmXBTickEndF = 18000
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
;  resr@mpLeftCornerLonF       = lon(820,1200)
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
  resr@cnMinLevelValF = 0.0
  resr@cnMaxLevelValF = 0.60
  resr@cnLevelSpacingF = 0.01
  


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
;  resr@xyExplicitLegendLabels = (/"40","80","120","161","200"/)         ; explicit labels

;  resr@tiMainOn = False

  resr@tiMainString    = "20 cm Soil Moisture"   ; add titles

  resr@lbTitleOn        = True                  ; turn on title
  resr@lbTitleString    = "Soil moisture (fractional)"
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
