package com.nodename.Delaunay
{
	import com.luketramps.vorox.data.PointVX;
	import com.luketramps.vorox.data.PointVXPool;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	internal function selectNonIntersectingEdges(keepOutMask:BitmapData, edgesToTest:Vector.<Edge>):Vector.<Edge>
	{
		if (keepOutMask == null)
		{
			return edgesToTest;
		}
		
		var zeroSiteVX:Point = new Point ();
		return edgesToTest.filter(myTest);
		
		function myTest(edge:Edge, index:int, vector:Vector.<Edge>):Boolean
		{
			var delaunayLineBmp:BitmapData = edge.makeDelaunayLineBmp();
			var notIntersecting:Boolean = !(keepOutMask.hitTest (zeroSiteVX, 1, delaunayLineBmp, zeroSiteVX, 1));
			delaunayLineBmp.dispose();
			return notIntersecting;
		}
	}
}
	
