#! /bin/tcsh -f
#modified 4/24/2001 to wake YMB in case of goes violation.
#modified 4/26/2001 to  let others know of a violation,
#
#modified 4/04/2001 to write to pool1 instead of $HOME
#this rearms the system 24 at the midnight following the last violation

    set text = " A Radiation violation of GOES 10 P2 (P>10 - P>5) been observed (limit = 50 particles/cm2-s-ster averaged over 2 hours )  see: http://asc.harvard.edu/mta/G10.html"

    if( -f /pool1/prot_violate_goes) then
	set num_violate = `cat /pool1/prot_violate_goes | wc -l`
	echo "1" >> /pool1/prot_violate_goes
	if($num_violate < 4 ) then
	    
	    if($num_violate_goes % 5 == 0) then
		echo $text |mail ymb,5283122@archwireless.net,6724485@mobilecomm.net,emartin@ipa.harvard.edu,martin-e@mediaone.net,6937506@archwireless.net,3278862@archwireless.net,plucinsk,svirani,juda,rac,swolk,das,wap

	    endif
	
	endif
	else
	echo "1" >! /pool1/prot_violate_goes
	  echo $text |mail ymb,5283122@archwireless.net,6724485@mobilecomm.net,emartin@ipa.harvard.edu,martin-e@mediaone.net,6937506@archwireless.net,3278862@archwireless.net,plucinsk,svirani,juda,rac,swolk,das,wap

    endif

