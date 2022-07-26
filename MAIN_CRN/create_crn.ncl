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

begin

; --- Read Data ----------------------------------------;
 ;diri = "/fs/scd/home1/shea/ncldata_input/"
  ncol = 28
  nstat = 154
  nstat6 = 160
  yearcrn = getenv("YEAR_CRN")
  sdate  = stringtointeger(getenv("SDATE_CRN"))
  edate  = stringtointeger(getenv("EDATE_CRN"))
  totday = edate-sdate+2

  names = new(nstat,string)
  ids = new(nstat,integer)
  nrow = new(nstat,integer)

  TestDatan = asciiread ("crn_namelist_"+yearcrn+".txt" , nstat, "string")
  names(:)=TestDatan(:)


  TestDatai = asciiread("stationID_lat_lon_"+yearcrn+".txt",(/nstat,3/),"integer")

  ids(:)=TestDatai(:,0)

  print(names)

  do i=0,nstat-1
  nrow(i)=numAsciiRow(names(i))
  end do


;  data = new((/totday,nstat,ncol/),float)

;--- Creating 2D (#days, #stations) arrays --------------------------;

  statid = new((/totday,nstat6/),integer)
  tmax = new((/totday,nstat6/),float)
  tmin = new((/totday,nstat6/),float)
  atemp = new((/totday,nstat6/),float)
  precip = new((/totday,nstat6/),float)
  solar = new((/totday,nstat6/),float)
  sur_temp_max = new((/totday,nstat6/),float)
  sur_temp_min = new((/totday,nstat6/),float)
  surface_temp = new((/totday,nstat6/),float)
  rh = new((/totday,nstat6/),float)
  Smois_05cm = new((/totday,nstat6/),float)
  Smois_10cm = new((/totday,nstat6/),float)
  Smois_20cm = new((/totday,nstat6/),float)
  Smois_50cm = new((/totday,nstat6/),float)
  Smois_100cm = new((/totday,nstat6/),float)
  Soiltemp_05cm = new((/totday,nstat6/),float)
  Soiltemp_10cm = new((/totday,nstat6/),float)
  Soiltemp_20cm = new((/totday,nstat6/),float)
  Soiltemp_50cm = new((/totday,nstat6/),float)
  Soiltemp_100cm = new((/totday,nstat6/),float)

  length=new(nstat6,integer)

  delim = " "

  nbs = new(nstat6,integer)

  do j=0,5
  do i=0,totday-1
  tmax(i,j)=i+1
  tmin(i,j)=i+1
  atemp(i,j)=i+1
  precip(i,j)=i+1
  solar(i,j)=i+1
  sur_temp_max(i,j)=i+1
  sur_temp_min(i,j)=i+1
  surface_temp(i,j)=i+1
  rh(i,j)=i+1
  Smois_05cm(i,j)=i+1
  Smois_10cm(i,j)=i+1
  Smois_20cm(i,j)=i+1
  Smois_50cm(i,j)=i+1
  Smois_100cm(i,j)=i+1
  Soiltemp_05cm(i,j)=i+1
  Soiltemp_10cm(i,j)=i+1
  Soiltemp_20cm(i,j)=i+1
  Soiltemp_50cm(i,j)=i+1
  Soiltemp_100cm(i,j)=i+1
  end do
  end do

  TestData=new(totday,string)

;---Looping through to convert string CRN data to float values in new arrays-------;
  do j=6,nstat6-1
  do i=0,nstat-1
  TestData(0:nrow(i)-1) = asciiread (names(i) , -1, "string")
  statid(:,i) = tointeger(str_get_field(TestData,1,delim))

  if(statid(1,i).eq.ids(j-6)) then
  length(j)=nrow(i)
  tmax(:,j) = tofloat(str_get_field(TestData,6,delim))
  tmin(:,j) = tofloat(str_get_field(TestData,7,delim))
  atemp(:,j) = tofloat(str_get_field(TestData,8,delim))
  precip(:,j) = tofloat(str_get_field(TestData,10,delim))
  solar(:,j) = tofloat(str_get_field(TestData,11,delim))
  sur_temp_max(:,j) = tofloat(str_get_field(TestData,13,delim))
  sur_temp_min(:,j) = tofloat(str_get_field(TestData,14,delim))
  surface_temp(:,j) = tofloat(str_get_field(TestData,15,delim))
  rh(:,j) = tofloat(str_get_field(TestData,18,delim))
  Smois_05cm(:,j) = tofloat(str_get_field(TestData,19,delim))
  Smois_10cm(:,j) = tofloat(str_get_field(TestData,20,delim))
  Smois_20cm(:,j) = tofloat(str_get_field(TestData,21,delim))
  Smois_50cm(:,j) = tofloat(str_get_field(TestData,22,delim))
  Smois_100cm(:,j) = tofloat(str_get_field(TestData,23,delim))
  Soiltemp_05cm(:,j) = tofloat(str_get_field(TestData,24,delim))
  Soiltemp_10cm(:,j) = tofloat(str_get_field(TestData,25,delim))
  Soiltemp_20cm(:,j) = tofloat(str_get_field(TestData,26,delim))
  Soiltemp_50cm(:,j) = tofloat(str_get_field(TestData,27,delim))
  Soiltemp_100cm(:,j) = tofloat(str_get_field(TestData,28,delim))
;  print(ids(j))
  nbs(j)=ids(j-6)
;  print(j)
  end if

;  end if

  end do
  end do

;  print(nbs)


;---Setting variable fill values -------------------------------;
  statid@_FillValue=-99
  tmax@_FillValue=-99
  tmin@_FillValue=-99
  atemp@_FillValue=-99
  precip@_FillValue=-99
  solar@_FillValue=-99
  sur_temp_max@_FillValue=-99
  sur_temp_min@_FillValue=-99
  surface_temp@_FillValue=-99
  rh@_FillValue=-99
  Smois_05cm@_FillValue=-99
  Smois_10cm@_FillValue=-99
  Smois_20cm@_FillValue=-99
  Smois_50cm@_FillValue=-99
  Smois_100cm@_FillValue=-99
  Soiltemp_05cm@_FillValue=-99
  Soiltemp_10cm@_FillValue=-99
  Soiltemp_20cm@_FillValue=-99
  Soiltemp_50cm@_FillValue=-99
  Soiltemp_100cm@_FillValue=-99

  do j=6,nstat6-1
  if (.not.ismissing(length(j))) then
  if(length(j).ne.totday) then
  tmax(length(j):totday-1,j)=tmax@_FillValue
  tmin(length(j):totday-1,j)=tmin@_FillValue
  atemp(length(j):totday-1,j)=atemp@_FillValue
  precip(length(j):totday-1,j)=precip@_FillValue
  solar(length(j):totday-1,j)=solar@_FillValue
  sur_temp_max(length(j):totday-1,j)=sur_temp_max@_FillValue
  sur_temp_min(length(j):totday-1,j)=sur_temp_min@_FillValue
  surface_temp(length(j):totday-1,j)=surface_temp@_FillValue
  rh(length(j):totday-1,j)=rh@_FillValue
  Smois_05cm(length(j):totday-1,j)=Smois_05cm@_FillValue
  Smois_10cm(length(j):totday-1,j)=Smois_10cm@_FillValue
  Smois_20cm(length(j):totday-1,j)=Smois_20cm@_FillValue
  Smois_50cm(length(j):totday-1,j)=Smois_50cm@_FillValue
  Smois_100cm(length(j):totday-1,j)=Smois_100cm@_FillValue
  Soiltemp_05cm(length(j):totday-1,j)=Soiltemp_05cm@_FillValue
  Soiltemp_10cm(length(j):totday-1,j)=Soiltemp_10cm@_FillValue
  Soiltemp_20cm(length(j):totday-1,j)=Soiltemp_20cm@_FillValue
  Soiltemp_50cm(length(j):totday-1,j)=Soiltemp_50cm@_FillValue
  Soiltemp_100cm(length(j):totday-1,j)=Soiltemp_100cm@_FillValue
  end if
  end if
  end do

;  ciday=totday+"i6,1x"
;  cday=totday+"f11.2,1x"


;---Writing out new text files with extracted CRN float variables for SWAMP--------------;
  ciday=nstat6+"i6,1x"
  cday=nstat6+"f12.3,1x"

  optn = True
  optn@row = False

  optn@fout="stationID_"+yearcrn+".txt"
  write_matrix(statid(:,:), ciday, optn)

  optn@fout="Temp_max_"+yearcrn+".txt"
  write_matrix(tmax(:,:), cday, optn)

  optn@fout="Temp_min_"+yearcrn+".txt"
  write_matrix(tmin(:,:), cday, optn)

  optn@fout="Air_temp_"+yearcrn+".txt"
  write_matrix(atemp(:,:), cday, optn)

  optn@fout="Precip_"+yearcrn+".txt"
  write_matrix(precip(:,:), cday, optn)

  optn@fout="Solar_"+yearcrn+".txt"
  write_matrix(solar(:,:), cday, optn)

  optn@fout="Sur_temp_max_"+yearcrn+".txt"
  write_matrix(sur_temp_max(:,:), cday, optn)

  optn@fout="Sur_temp_min_"+yearcrn+".txt"
  write_matrix(sur_temp_min(:,:), cday, optn)

  optn@fout="Surface_temp_"+yearcrn+".txt"
  write_matrix(surface_temp(:,:), cday, optn)

  optn@fout="RH_"+yearcrn+".txt"
  write_matrix(rh(:,:), cday, optn)

  optn@fout="Smois_05cm_"+yearcrn+".txt"
  write_matrix(Smois_05cm(:,:), cday, optn)

  optn@fout="Smois_10cm_"+yearcrn+".txt"
  write_matrix(Smois_10cm(:,:), cday, optn)

  optn@fout="Smois_20cm_"+yearcrn+".txt"
  write_matrix(Smois_20cm(:,:), cday, optn)

  optn@fout="Smois_50cm_"+yearcrn+".txt"
  write_matrix(Smois_50cm(:,:), cday, optn)

  optn@fout="Smois_100cm_"+yearcrn+".txt"
  write_matrix(Smois_100cm(:,:), cday, optn)

  optn@fout="Soiltemp_05cm_"+yearcrn+".txt"
  write_matrix(Soiltemp_05cm(:,:), cday, optn)

  optn@fout="Soiltemp_10cm_"+yearcrn+".txt"
  write_matrix(Soiltemp_10cm(:,:), cday, optn)

  optn@fout="Soiltemp_20cm_"+yearcrn+".txt"
  write_matrix(Soiltemp_20cm(:,:), cday, optn)

  optn@fout="Soiltemp_50cm_"+yearcrn+".txt"
  write_matrix(Soiltemp_50cm(:,:), cday, optn)

  optn@fout="Soiltemp_100cm_"+yearcrn+".txt"
  write_matrix(Soiltemp_100cm(:,:), cday, optn)


end
