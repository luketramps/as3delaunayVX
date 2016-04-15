package com.nodename.Delaunay
{
	import com.luketramps.vorox.data.HalfEdgePool;
	import com.luketramps.vorox.data.PointVX;
	
	public final class Halfedge
	{
		public static function create(edge:Edge, lr:LR):Halfedge
		{
			throw new Error ("Depraced.");
			return null;
		}
		
		public static function createDummy():Halfedge
		{
			throw new Error ("Depraced.");
			return null; //create(null, null);
		}
		
		public var edgeListLeftNeighbor:Halfedge, edgeListRightNeighbor:Halfedge;
		public var nextInPriorityQueue:Halfedge;
		
		public var edge:Edge;
		public var leftRight:LR;
		public var vertex:Vertex;
		
		// the vertex's y-coordinate in the transformed Voronoi space V*
		public var ystar:Number;

		public function init(edge:Edge, lr:LR):Halfedge
		{
			this.edge = edge;
			leftRight = lr;
			nextInPriorityQueue = null;
			vertex = null;
			return this;
		}
		
		public function toString():String
		{
			return "Halfedge (leftRight: " + leftRight + "; vertex: " + vertex + ")";
		}
		
		public function dispose():void
		{
			if (edgeListLeftNeighbor || edgeListRightNeighbor)
			{
				// still in EdgeList
				return;
			}
			if (nextInPriorityQueue)
			{
				// still in PriorityQueue
				return;
			}
			edge = null;
			leftRight = null;
			vertex = null;
		}
		
		public function reallyDispose():void
		{
			edgeListLeftNeighbor = null;
			edgeListRightNeighbor = null;
			nextInPriorityQueue = null;
			edge = null;
			leftRight = null;
			vertex = null;
		}

		internal function isLeftOf(p:PointVX):Boolean
		{
			var topSite:Site;
			var rightOfSite:Boolean, above:Boolean, fast:Boolean;
			var dxp:Number, dyp:Number, dxs:Number, t1:Number, t2:Number, t3:Number, yl:Number;
			
			topSite = edge.rightSite;
			rightOfSite = p.x > topSite.x;
			if (rightOfSite && this.leftRight == LR.LEFT)
			{
				return true;
			}
			if (!rightOfSite && this.leftRight == LR.RIGHT)
			{
				return false;
			}
			
			if (edge.a == 1.0)
			{
				dyp = p.y - topSite.y;
				dxp = p.x - topSite.x;
				fast = false;
				if ((!rightOfSite && edge.b < 0.0) || (rightOfSite && edge.b >= 0.0) )
				{
					above = dyp >= edge.b * dxp;	
					fast = above;
				}
				else 
				{
					above = p.x + p.y * edge.b > edge.c;
					if (edge.b < 0.0)
					{
						above = !above;
					}
					if (!above)
					{
						fast = true;
					}
				}
				if (!fast)
				{
					dxs = topSite.x - edge.leftSite.x;
					above = edge.b * (dxp * dxp - dyp * dyp) <
					        dxs * dyp * (1.0 + 2.0 * dxp/dxs + edge.b * edge.b);
					if (edge.b < 0.0)
					{
						above = !above;
					}
				}
			}
			else  /* edge.b == 1.0 */
			{
				yl = edge.c - edge.a * p.x;
				t1 = p.y - yl;
				t2 = p.x - topSite.x;
				t3 = yl - topSite.y;
				above = t1 * t1 > t2 * t2 + t3 * t3;
			}
			return this.leftRight == LR.LEFT ? above : !above;
		}

	}
}
