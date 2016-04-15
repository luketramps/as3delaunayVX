package com.nodename.Delaunay
{
	import com.luketramps.vorox.data.VectorBoolPool;
	import com.luketramps.vorox.data.VectorEdgePool;
	import com.luketramps.vorox.data.VectorLrPool;
	
	
	internal final class EdgeReorderer2
	{
		private static var _edges:Vector.<Edge>;
		private static var _edgeOrientations:Vector.<LR>;
		
		
		public static function get edges():Vector.<Edge>
		{
			return _edges;
		}
		
		public static function get edgeOrientations():Vector.<LR>
		{
			return _edgeOrientations;
		}
		
		public static function reorder(origEdges:Vector.<Edge>, criterion:Class):void
		{
			if (criterion != Vertex && criterion != Site)
			{
				throw new ArgumentError("Edges: criterion must be Vertex or Site");
			}
			_edges = VectorEdgePool.getObjFromSubpool ();
			_edgeOrientations = VectorLrPool.getObjFromSubpool ()//new Vector.<LR>();
			if (origEdges.length > 0)
			{
				_edges = reorderEdges(origEdges, criterion);
			}
		}
		
		
		private static function reorderEdges(origEdges:Vector.<Edge>, criterion:Class):Vector.<Edge>
		{
			var i:int;
			var j:int;
			var n:int = origEdges.length;
			var edge:Edge;
			// we're going to reorder the edges in order of traversal
			var done:Vector.<Boolean> = VectorBoolPool.getObjFromSubpool (n); //new Vector.<Boolean>//(n, true);
			var nDone:int = 0;
			var newEdges:Vector.<Edge> = VectorEdgePool.getObjFromSubpool ();
			
			i = 0;
			edge = origEdges[i];
			newEdges.push(edge);
			_edgeOrientations.push(LR.LEFT);
			var firstSiteVX:ICoord = (criterion == Vertex) ? edge.leftVertex : edge.leftSite;
			var lastSiteVX:ICoord = (criterion == Vertex) ? edge.rightVertex : edge.rightSite;
			
			if (firstSiteVX == Vertex.VERTEX_AT_INFINITY || lastSiteVX == Vertex.VERTEX_AT_INFINITY)
			{
				return VectorEdgePool.getObjFromSubpool ();
			}
			
			done[i] = true;
			++nDone;
			
			//while (nDone < n)
			for (var k:int = 0; k < n; k++)
			{
				for (i = 1; i < n; ++i)
				{
					if (done[i])
					{
						continue;
					}
					edge = origEdges[i];
					var leftSiteVX:ICoord = (criterion == Vertex) ? edge.leftVertex : edge.leftSite;
					var rightSiteVX:ICoord = (criterion == Vertex) ? edge.rightVertex : edge.rightSite;
					if (leftSiteVX == Vertex.VERTEX_AT_INFINITY || rightSiteVX == Vertex.VERTEX_AT_INFINITY)
					{
						return VectorEdgePool.getObjFromSubpool ();
					}
					if (leftSiteVX == lastSiteVX)
					{
						lastSiteVX = rightSiteVX;
						_edgeOrientations.push(LR.LEFT);
						newEdges.push(edge);
						done[i] = true;
					}
					else if (rightSiteVX == firstSiteVX)
					{
						firstSiteVX = leftSiteVX;
						_edgeOrientations.unshift(LR.LEFT);
						newEdges.unshift(edge);
						done[i] = true;
					}
					else if (leftSiteVX == firstSiteVX)
					{
						firstSiteVX = rightSiteVX;
						_edgeOrientations.unshift(LR.RIGHT);
						newEdges.unshift(edge);
						done[i] = true;
					}
					else if (rightSiteVX == lastSiteVX)
					{
						lastSiteVX = leftSiteVX;
						_edgeOrientations.push(LR.RIGHT);
						newEdges.push(edge);
						done[i] = true;
					}
					if (done[i])
					{
						++nDone;
					}
				}
			}
			
			return newEdges;
		}

	}
}