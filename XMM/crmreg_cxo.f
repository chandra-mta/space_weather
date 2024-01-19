      program crmreg

c Convert Chandra ECI linear coords to GSE, GSE coords

c Robert Cameron
c April 2001
c BDS Mar 2002
c modified 18 aug 04 bds from cocochan to read cxo and xmm
c  spctrk files and determine 

c compile and link this program as follows:
c f77 cocochan.f ./GEOPACK.f -o cocochan
c f77 cocochan.f ./GEOPACK.f ../crmflx_v1.2_25jan2001/CRMFLX_V12_EXP.f
c         -o cocochan
c
c how to compile crmreg_cxo:
c
c f77 crmreg_cxo.f 
c/data/mta4/proj/rac/ops/CRM3/RUNCRM/geopack/geopack.f
c/data/mta4/proj/rac/ops/CRM3/RUNCRM/geopack/supple.f  -o crmreg_cxo
c
c--- updated by t.isobe (tisobe@cfa.harvard.edu)
c
      integer idct(12),ios,yr,mon,d,h,min,s,doy
c      real x,y,z,vx,vy,vz,pi,re,Xgm,Ygm,Zgm,Xge,Yge,Zge
      real Xgsm,Ygsm,Zgsm,xgse,ygse,zgse,pi,re
      real*8 t,fy

      data pi /3.1415926535/
      data re /6.371/
      data idct /0,31,59,90,120,151,181,212,243,273,304,334/

c cxo.gsme is wrong, use in_Re
c      open(unit=1,name='/proj/rac/ops/ephem/TLE/cxo.gsme_in_Re')
      open(unit=1,name='cxo.gsme_in_Re')
      open(unit=2,name='crmreg_cxo.dat')

      do 100 while (ios.eq.0)
         read(1,*,iostat=ios) t,xgse,ygse,zgse,Xgsm,Ygsm,Zgsm,fy,mon,d,h,min,s

c convert time for unix (secs since 1970)
         t=t-8.83613e8-8.64e4

c convert cartesian coordinates to units of Earth radii
c  done for in_Re, but need km

c         Xgm = Xgsm/re
c         Ygm = Ygsm/re
c         Zgm = Zgsm/re
         Xgm = Xgsm*1000.0
         Ygm = Ygsm*1000.0
         Zgm = Zgsm*1000.0

c just use a dummy kp
         Xkp = 2.0
c      call sphcar(R,Tgsm,Pgsm,Xgm*re,Ygm*re,Zgm*re,-1)
      call locreg(Xkp,Xgm,Ygm,Zgm,Xtail,Ytail,Ztail,idloc)
c      if (ios.eq.0) write(2,3) t,R,Tgsm,Pgsm,Tgse,Pgse,fy,mon,d,h,min,s
      if (ios.eq.0) write(2,3) t,R,Xgm,Ygm,Zgm,idloc
c      if (ios.eq.0) write(3,4)t,Xgm,Ygm,Zgm,Xge,Yge,Zge,fy,mon,d,h,min,s
 100  continue
 3    format(f12.1,4(" ",f10.2)," ",i1)
 4    format(f12.1,6f11.6,f12.6,5i3)

      end
