; compare CXC's predicted Chandra ephemeris 
; with ephemeris from 2-line element propagation
 
; Robert Cameron
; May 2004

; read ephemeris data output from "foo.f"  (using SGP4 model)
rac_arread,'fort.16.cxo_test',dt,xs,ys,zs,vxs,vys,vzs,skip=3

; read CXC predicted ephemeris
rac_arread,'PE.EPH.dat',s98,x,y,z,vx,vy,vz,yr,mon,d,h,m,s

; align data according to timestamps
ok = where(d eq 21 and h eq 12 and m eq 0)
ok = ok + 0
x= x(ok[0]:*)
y= y(ok[0]:*)
z= z(ok[0]:*)
vz= vz(ok[0]:*)
vx= vx(ok[0]:*)
vy= vy(ok[0]:*)
n = n_elements(x)-1
dt = dt(0:n)/1440
xs = xs(0:n)
ys = ys(0:n)
zs = zs(0:n)
vzs = vzs(0:n)
vys = vys(0:n)
vxs = vxs(0:n)

; calculate difference vectors in position and velocity
dx = xs - x/1000
dy = ys - y/1000
dz = zs - z/1000
dvx = vxs - vx/1000
dvy = vys - vy/1000
dvz = vzs - vz/1000
dr = sqrt(dx^2 + dy^2 + dz^2)
dv = sqrt(dvx^2 + dvy^2 + dvz^2)
r = sqrt(x^2 + y^2 + z^2)/1000

; make plots

!p.multi = [0,1,3]
!p.charsize = 2
!p.title = 'CXC ephemeris to 2-line element ephemeris comparison'
!x.title = 'Time (days)'
plot, dt,r/1000,ytit='Geocentric Distance (Mm)'
plot, dt,dr,ytit='Position Difference (km)'
plot, dt,dv,ytit='Velocity Difference (km/s)'

end
