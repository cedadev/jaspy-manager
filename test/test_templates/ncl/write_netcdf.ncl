;Based on code for JIRA-1603.
;This script also serves the purpose of test its correctness.
;load "$NCARGTEST/nclscripts/functions.ncl"
;------------------------------------------------------------
;Make sure we set the file output as NetCDF4.
 setfileoption("nc", "Format",  "NetCDF4")
 fn = "__OUTPUT_PATH__"
 system("/bin/rm -f " + fn) ; remove if exists
 f = addfile(fn, "c")

;===================================================================
; explicitly declare file definition mode. Improve efficiency.
 setfileoption(f,"DefineMode",True)

;Create some file attributes
 fAtt               = True            ; assign file attributes
 fAtt@title         = "NCL generated netCDF file with multiple unlimited dimensions"
 fAtt@source_file   = fn
 fAtt@creation_date = systemfunc ("date")
 fileattdef(f, fAtt)

;We want to create a variable of two dimensions:
; 0: use time as dimension
; 1: use space as dimension
;Define some parameters for dimension.
 nd = 2
 nt = 5
 ns = 5
 nt2 = 2 * nt
 ns2 = 2 * ns
;===================================================================
;Define the file dimensions, NOTE that both dimensions are unlimited.
 dimNames = (/"time", "space"/)
 dimSizes = (/    -1,     -1/)
 dimUnlim = (/  True,   True/)
 filedimdef(f, dimNames, dimSizes, dimUnlim)

;===================================================================
;Generate time and space coordinate variable.
 time = ispan(1, nt, 1)
 time@name = "time"
 time!0 = "time"
 filevardef(f, "time", typeof(time), getvardims(time))
 filevarattdef(f,"time", time)

 space = ispan(1, ns, 1)
 space@name = "space"
 space!0 = "space"
 filevardef(f, "space", typeof(space), getvardims(space))
 filevarattdef(f,"space", space)

;===================================================================
;Make a Fibonacci series (somehow in 2d)
;Where: value(0, 0) = 1
;       value(1, 0) = 1
;       value(0, 1) = 1
;       value(0, i) = value(0, i-1) + value(0, i-2) (i > 1)
;       value(j, 0) = value(j-1, 0) + value(j-2, 0) (j > 1)
;       value(j, i) = value(i-1, j) + value(i, j-1) (i > 0, j > 0)

 value = new((/nt, ns/), integer)
 value@name = "value"
 value!0 = "time"
 value!1 = "space"
 filevardef(f, "value", typeof(value), getvardims(value))
 filevarattdef(f,"value", value)

 value(0, 0) = 1
 value(1, 0) = 1
 value(0, 1) = 1

 do i = 2, ns - 1
    value(0, i) = value(0, i-1) + value(0, i-2)
 end do

 do j = 2, nt - 1
    value(j, 0) = value(j-1, 0) + value(j-2, 0)
 end do

 do j = 1, nt - 1
 do i = 1, ns - 1
    value(j, i) = value(j-1, i) + value(j, i-1)
 end do
 end do

;Write the data out.
 f->time  = (/time/)
 f->space = (/space/)
 f->value = (/value/)
;====================================================================

