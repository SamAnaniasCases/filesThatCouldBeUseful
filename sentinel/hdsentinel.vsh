<html>
<head>
<title>Hard Disk Sentinel</title>

<style>
   body { 
//      width:430px;
//      height:20px;
      margin: 0, 0;
      padding: 0, 0, 0, 0;
      font-size: 1px;
      font-family: arial;
      }

    li, ul {
	padding: 0, 0, 0, 0;
	margin: 0, 0, 0, 0;
	list-style-image: none;
	list-style-type: none;  
	}

    p	{
	padding: 0;
	margin: 0;
	}

    ul {
	padding: 0, 0, 0, 0;
	margin: 0 0px 1px 4px;
	}

	.xboxcontent { display: block; background:#fff; border:0 solid black; border-width:1px 1px 1px 1px; }
	.xboxcont2 { display: block; background:#fff; border-style: outset; border-color: #e0e0e0; border-width:1px 1px 1px 1px; }
	.xboxcont3 { border-style: outset; border-color: #e0e0e0; border-width:1px 1px 1px 1px; width:10; }
	
</style>

<script language="javascript" type="text/javascript">

var intHandle = 0;
var bodyHeight = 10;
var updateInterval = 1;
var updatecount = 0;
var sRegkey = 'HKLM\\Software\\HD Sentinel\\Gadget\\';
var sRegkey64Sentinel = 'HKLM\\Software\\Wow6432Node\\HD Sentinel\\';
var sRegkey64 = sRegkey64Sentinel + 'Gadget\\';
var WshShell = new ActiveXObject("WScript.Shell");
var showHeader = '1';
var partdisp = 'none';

function togglelogical()
{

	if (partdisp=="") { partdisp = "none"; }
	else { partdisp = ""; }
	updateGadget();
}

function loadData()
{
	try
	{
		var is64bitOs=WshShell.RegRead(sRegkey64Sentinel+'InstallDate');
	}
	catch(err)
	{
		is64bitOs = '';
	}

	if (is64bitOs.length > 0)
	{
		sRegkey = sRegkey64;
	}

	updateGadget();
	intHandle=setInterval("updateGadget()",updateInterval*1000);
}

function updateGadget()
{

	var s = '';
	var items =''; 
	var bgcolor =''; 

	try
	{
		document.body.style.width=WshShell.RegRead(sRegkey+'GadgetWidth');
	}
	catch(err)
	{
		document.body.style.width= 130;
	}

	try
	{
		bgcolor=WshShell.RegRead(sRegkey+'BGColor');
		if (bgcolor.length > 0) 
		{
			document.getElementById('contents').style.background = bgcolor;
		}
	}
	catch(err)
  		{
			document.getElementById('contents').style.background = '#ffffff';
		}

	var fnt = '';
	try
	{
		var f1=WshShell.RegRead(sRegkey+'FontColor');
		var f2=WshShell.RegRead(sRegkey+'FontName');
		var f3=WshShell.RegRead(sRegkey+'FontStyle');
		var f4=WshShell.RegRead(sRegkey+'FontSize');
	}
	catch(err)
	{
		f1='#000000';
		f2='Segoe UI';
		f3='<b>';
		f4='8';
	}
	
	fnt='<p style="font-size: '+f4+'pt;"><font face="'+f2+'" color="'+f1+'">'+f3;

	try
	{
		var items=WshShell.RegRead(sRegkey+'Disks');
	}
	catch(err)
	{
		items = '';
	}

	try
	{
		var logitems=WshShell.RegRead(sRegkey+'LogicalDrives');
	}
	catch(err)
	{
		logitems = '';
	}

	var header='';
	try
	{
		header=WshShell.RegRead(sRegkey+'Header');
	}
	catch(err)
	{
	}

	if (header=='') 
	{
		s='';
	}
	else 
	{
		s='<p style="font-size: '+f4+'pt; background: '+f1+'"><font face="'+f2+'" color="'+bgcolor+'">'+f3+'&nbsp;'+header+'&nbsp;</p>';
	}

	if (items.length > 0)
	{

		var iarray = items.split(',');

		var s1 = '';
		var s2 = '';
		var s3 = '';
		var s5 = '';

		if (iarray.length==1) 
		{
			s=s+'<table width=10% height=2px border=0 cellspacing=0 cellpadding=0><tr><td></table>';
		}

		for (var i=0; i<iarray.length; i++)
	    	{
			s1=sRegkey+'Disk.'+iarray[i]+'.ID';
			s2=sRegkey+'Disk.'+iarray[i]+'.Health';
			s3=sRegkey+'Disk.'+iarray[i]+'.Temp';
			s5=sRegkey+'Disk.'+iarray[i]+'.Perf';

			try
			{

				var tempunit = WshShell.RegRead(s3);
				var tu=tempunit.indexOf(' ');
				if (tu>0) { tempunit = tempunit.substr(tu+1); } else { tempunit = ""; }
				var statline = WshShell.RegRead(s1);

				var imgwidth=16;
				var fsiz=parseInt(f4)+2;
				if (fsiz<11) { fneg=18; }
				else if (fsiz<13) { imgwidth=19; }
				else if (fsiz<15) { imgwidth=20; }
				else if (fsiz<17) { imgwidth=22; }
				else if (fsiz<19) { imgwidth=23; }
				else if (fsiz<21) { imgwidth=24; }
				else if (fsiz<23) { imgwidth=27; }
				else { imgwidth=30; }

				s=s+'<table width=10% height=2px border=0 cellspacing=0 cellpadding=0><tr><td></table>';
				s=s+'<table width=97% border=0 cellspacing=0 cellpadding=0><tr><td width=5px;><td width='+(imgwidth+5)+'px><img src=disk'+iarray[i]+'temp.bmp width='+imgwidth+'px><td valign=center>'+fnt+'<a onclick="togglelogical();">';
				var curtemp=WshShell.RegRead(s3);
				if ((curtemp.charAt(0)!='?') && (tempunit.length>0)) { tempunit=tempunit+': '; } else { tempunit=''; }
				s=s+tempunit+statline+'</a></p></table>';
				var s6 = WshShell.RegRead(s5);
				var parray = s6.split(',');
				if (parray.length > 1)
				{
					s=s+'<center><div class="xboxcont3"> <table border=0 width=120 height=33 cellspacing=0 cellpadding=0><tr bgcolor=#000080>';
					for (var j=0; j<parray.length; j++) 
					{
						if (j<39) continue;
						var cu=parray[j];
						cu=Math.ceil(cu/3);
						if (cu>33) { cu=33; }
						var b=33-cu;
						s=s+'<td width=2><table border=0 width=100% cellspacing=0 cellpadding=0>';
						if (b>0) { s=s+'<tr height='+(b)+'><td>'; }
						if (cu>0) { s=s+'<tr height='+(cu)+' bgcolor=white><td>'; }
						s=s+'</table>';
					}
					s=s+'</table></div></center><p style="font-size: 2pt; font-family: arial"></p>';
				}

			}
			catch(err)
			{
			}
		}

		if (iarray.length==1) 
		{
			s=s+'<table width=10% height=2px border=0 cellspacing=0 cellpadding=0><tr><td></table>';
		}

		s=s+'<center><div id="partinfo" style="display:'+partdisp+'">';
		s=s+'<table width=10% height=2px border=0 cellspacing=0 cellpadding=0><tr><td></table>';

		var ls1 = '';
		var ls2 = '';
		var ls3 = '';
		var ls5 = '';

		for (var i=0; i<logitems; i++)
	    	{

			lid=sRegkey+'LogicalDrive.'+i+'.ID';
			llabel=sRegkey+'LogicalDrive.'+i+'.Label';
			lcap=sRegkey+'LogicalDrive.'+i+'.Capacity';
			lfree=sRegkey+'LogicalDrive.'+i+'.Free';

			s=s+'<table border=0 width=95% cellspacing=0 cellpadding=0 onclick="System.Shell.execute(\''+WshShell.RegRead(lid)+'\');"><tr><td width=20px>'+fnt+'<b>'+WshShell.RegRead(lid);
			s=s+'</b></p>';
			s=s+'<td>'+fnt+WshShell.RegRead(llabel)+'&nbsp;</p>';
			var lf=WshShell.RegRead(lfree);
			var lc=WshShell.RegRead(lcap);
			s=s+'<td width=160px>';

			if (lc>0) 
			{
				var fsiz=parseInt(f4)+2;
				var fneg=0;
				if (fsiz<9) { }
				else if (fsiz<10) { fneg=1; }
				else if (fsiz<12) { fneg=2; }
				else if (fsiz<13) { fneg=3; }
				else if (fsiz<15) { fneg=4; }
				else if (fsiz<17) { fneg=5; }
				else if (fsiz<19) { fneg=6; }
				else if (fsiz<21) { fneg=8; }
				else if (fsiz<23) { fneg=9; }
				else { fneg=10; }

				s=s+'<span style="position: relative; width=97%; height='+fsiz+'px;">';
				s=s+'<span style="z-order: 0; position: absolute; top: 0px; left: 0px;"><table height='+parseInt(fsiz+2)+'px width=100% border=0 cellspacing=0 cellpadding=0 style="border: 1px solid #303030;">';
				s=s+'<tr>';
				s=s+'<td width='+(100-(lf*100/lc))+'% bgcolor=#0000FF>';
				s=s+'<td width='+(lf*100/lc)+'% bgcolor=#F800F8>';
				s=s+'</table></span>';
				s=s+'<span style="z-order: 1; position: absolute; top: -'+fneg+'px; text-align: center; width=100%">'+fnt+'<font color=white>'+Math.round(lf/1048576)+' MB</font></p></span>';
				s=s+'</span><br><span style="position: relative; width=97%; height=1px;"><span style="z-order: 0; position: absolute; top: 0px; left: 0px;"><table height=1 width=10% border=0 cellspacing=0 cellpadding=0></table></span></span><br>';
			}

			s=s+'</table><table width=10% height=1px border=0 cellspacing=0 cellpadding=0><tr><td></table>';

		}	
		s=s+'</div>';
	}
	else
	{
		s='<table border=0 cellspacing=0 cellpadding=0><tr><td><p style="font-size: 9pt; text-align: center; margin-top: 4px; margin-bottom: 4px;"><font face="Segoe UI">Hard Disk Sentinel is not running or sidebar support is disabled.</font></p>';
		s=s+'</table>';
	}


  	contents.innerHTML=s;

	updatecount++;

	if (updatecount>1) 
	{
		bodyHeight=contents.offsetHeight+4;
		document.body.style.height=bodyHeight;
	}
	else 
	{
		document.body.style.height=57;
	}

}

</script>

</head>

<body unselectable="on" scroll="no" onload="loadData()">

<div class="xboxcont2">
<div class="xboxcont2">

<div id="contents"></div>

</div>
</div></body></html>
