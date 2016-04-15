package com.nodename.Delaunay
{
	import __AS3__.vec.Vector;
	import com.luketramps.vorox.data.PointVX
	
	internal function selectEdgesForSitePoint(coord:PointVX, edgesToTest:Vector.<Edge>):Vector.<Edge>
	{
		return edgesToTest.filter(myTest);
		
		function myTest(edge:Edge, index:int, vector:Vector.<Edge>):Boolean
		{
			return ((edge.leftSite && edge.leftSite.coord == coord)
			||  (edge.rightSite && edge.rightSite.coord == coord));
		}
	}
}