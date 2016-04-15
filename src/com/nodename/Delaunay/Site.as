package com.nodename.Delaunay
{
	import com.luketramps.vorox.data.PointVX;
	import com.luketramps.vorox.data.PointVXPool;
	import com.luketramps.vorox.data.VectorEdgePool;
	import com.luketramps.vorox.data.VectorPointVXPool;
	import com.nodename.geom.Polygon;
	import com.nodename.geom.Polygon2;
	import com.nodename.geom.Winding;
	import flash.geom.Rectangle;
	
	
	public final class Site implements ICoord
	{
		private static var _pool:Vector.<Site> = new Vector.<Site>();
		public static function create(p:PointVX, index:int, weight:Number, color:uint):Site
		{
			if (_pool.length > 0)
			{
				return _pool.pop().init(p, index, weight, color);
			}
			else
			{
				return new Site(p, index, weight, color);
			}
		}
		
		internal static function sortSites(sites:Vector.<Site>):void
		{
			sites.sort(Site.compare);
		}

		/**
		 * sort sites on y, then x, coord
		 * also change each site's _siteIndex to match its new position in the list
		 * so the _siteIndex can be used to identify the site for nearest-neighbor queries
		 * 
		 * haha "also" - means more than one responsibility...
		 * 
		 */
		private static function compare(s1:Site, s2:Site):Number
		{
			// Inline Voronoi.compareByXThenY function.
			var returnValue:int;
			if (s1.y < s2.y) returnValue = -1;
			else if (s1.y > s2.y) returnValue = 1;
			else if (s1.x < s2.x) returnValue = -1;
			else if (s1.x > s2.x) returnValue = 1;
			else returnValue = 0;
			
			//var returnValue:int = Voronoi.compareByYThenX(s1, s2);
			
			// swap _siteIndex values if necessary to match new ordering:
			var tempIndex:int;
			if (returnValue == -1)
			{
				if (s1._siteIndex > s2._siteIndex)
				{
					tempIndex = s1._siteIndex;
					s1._siteIndex = s2._siteIndex;
					s2._siteIndex = tempIndex;
				}
			}
			else if (returnValue == 1)
			{
				if (s2._siteIndex > s1._siteIndex)
				{
					tempIndex = s2._siteIndex;
					s2._siteIndex = s1._siteIndex;
					s1._siteIndex = tempIndex;
				}
				
			}
			
			return returnValue;
		}


		private static const EPSILON:Number = .005;
		private static function closeEnough(p0:PointVX, p1:PointVX):Boolean
		{
			return PointVX.distance(p0, p1) < EPSILON;
		}
				
		private var _coord:PointVX;
		public final function get coord():PointVX
		{
			return _coord;
		}
		
		internal var color:uint;
		internal var weight:Number;
		
		// LUKE
		public var lukesIndex:uint;
		
		private var _siteIndex:uint;
		
		// the edges that define this Site's Voronoi region:
		private var _edges:Vector.<Edge>;
		internal function get edges():Vector.<Edge>
		{
			return _edges;
		}
		// which end of each edge hooks up with the previous edge in _edges:
		private var _edgeOrientations:Vector.<LR>;
		// ordered list of sitePoints that define the region clipped to bounds:
		private var _region:Vector.<PointVX>;

		public function Site(p:PointVX, index:int, weight:Number, color:uint) // Lukes mod. Removed private constructor enforcer lock.
		{
			init (p, index, weight, color);
		}
		
		private function init(p:PointVX, index:int, weight:Number, color:uint):Site
		{
			_coord = p;
			_siteIndex = index;
			lukesIndex = index;
			this.weight = weight;
			this.color = color;
			_edges = VectorEdgePool.getObjFromSubpool ();
			_region = null;
			return this;
		}
		
		private function move(p:PointVX):void
		{
			clear();
			_coord = p;
		}
		
		public function dispose():void
		{
			_coord = null;
			clear();
			_pool.push(this);
		}
		
		
		private final function clear():void
		{
			if (_edges)
			{
				_edges.length = 0;
				_edges = null;
			}
			if (_edgeOrientations)
			{
				_edgeOrientations.length = 0;
				_edgeOrientations = null;
			}
			if (_region)
			{
				_region.length = 0;
				_region = null;
			}
		}
		
		internal function addEdge(edge:Edge):void
		{
			_edges.push(edge);
		}
		
		internal function nearestEdge():Edge
		{
			_edges.sort(Edge.compareSitesDistances);
			return _edges[0];
		}
		
		internal function neighborSites():Vector.<Site>
		{
			if (_edges == null || _edges.length == 0)
			{
				return new Vector.<Site>();
			}
			if (_edgeOrientations == null)
			{ 
				reorderEdges();
			}
			var list:Vector.<Site> = new Vector.<Site>();
			var edge:Edge;
			var edgeCount:uint = _edges.length;
			//for (var i:int = 0; i < edgeCount; i++) 
			//{
				//list.push (neighborSite(_edges[i]));
			//}
			for each (edge in _edges)
			{
				list.push(neighborSite(edge));
			}
			return list;
		}
		
		
		private final function neighborSite(edge:Edge):Site
		{
			if (this == edge.leftSite)
			{
				return edge.rightSite;
			}
			if (this == edge.rightSite)
			{
				return edge.leftSite;
			}
			return null;
		}
		
		internal static var countFoo:uint = 0;
		internal function region(clippingBounds:Rectangle):Vector.<PointVX>
		{
			countFoo++;
			if (countFoo == 61)
				trace ("braek");
			if (_edges == null || _edges.length == 0)
			{
				return VectorPointVXPool.getObjFromSubpool (); //VectorPointVXPool.getObjFromSubpool ();
			}
			if (_edgeOrientations == null)
			{ 
				reorderEdges();
				_region = clipToBounds(clippingBounds);
				if ((Polygon2.winding(_region)) == Winding.CLOCKWISE)
				{
					_region = _region.reverse();
				}
			}
			return _region;
		}
		
		
		private final function reorderEdges():void
		{
			EdgeReorderer2.reorder (_edges, Vertex); //var reorderer:EdgeReorderer = new EdgeReorderer(_edges, Vertex);
			_edges = EdgeReorderer2.edges;
			_edgeOrientations = EdgeReorderer2.edgeOrientations;
		}
		
		
		private final function clipToBounds(bounds:Rectangle):Vector.<PointVX>
		{
			var sitePoints:Vector.<PointVX> = VectorPointVXPool.getObjFromSubpool ();
			var n:int = _edges.length;
			var i:int = 0;
			var edge:Edge;
			
			for (i = 0; i < n && ((_edges[i] as Edge).visible == false); i++) 
			{
			}
			
			/*while (i < n && ((_edges[i] as Edge).visible == false))
			{
				++i;
			}*/
			
			if (i == n)
			{
				// no edges visible
				return VectorPointVXPool.getObjFromSubpool ();
			}
			edge = _edges[i];
			
			if (!edge.clippedEnds[orientation] is PointVX)
				trace ("break");
			
			var orientation:LR = _edgeOrientations[i];
			sitePoints.push(edge.clippedEnds[orientation]);
			sitePoints.push(edge.clippedEnds[LR.other(orientation)]);
			
			for (var j:int = i + 1; j < n; ++j)
			{
				edge = _edges[j];
				if (edge.visible == false)
				{
					continue;
				}
				connect(sitePoints, j, bounds);
			}
			// close up the polygon by adding another corner SiteVX of the bounds if needed:
			connect(sitePoints, i, bounds, true);
			
			return sitePoints;
		}
		
		//
		private final function connect(sitePoints:Vector.<PointVX>, j:int, bounds:Rectangle, closingUp:Boolean = false):void
		{
			var rightSiteVX:PointVX = sitePoints[sitePoints.length - 1];
			var newEdge:Edge = _edges[j] as Edge;
			var newOrientation:LR = _edgeOrientations[j];
			// the SiteVX that  must be connected to rightSiteVX:
			var newSiteVX:PointVX = newEdge.clippedEnds[newOrientation];
			if (!closeEnough(rightSiteVX, newSiteVX))
			{
				// The sitePoints do not coincide, so they must have been clipped at the bounds;
				// see if they are on the same border of the bounds:
				if (rightSiteVX.x != newSiteVX.x
				&&  rightSiteVX.y != newSiteVX.y)
				{
					// They are on different borders of the bounds;
					// insert one or two corners of bounds as needed to hook them up:
					// (NOTE this will not be correct if the region should take up more than
					// half of the bounds rect, for then we will have gone the wrong way
					// around the bounds and included the smaller part rather than the larger)
					var rightCheck:int = BoundsCheck.check(rightSiteVX, bounds);
					var newCheck:int = BoundsCheck.check(newSiteVX, bounds);
					var px:Number, py:Number;
					if (rightCheck & BoundsCheck.RIGHT)
					{
						px = bounds.right;
						if (newCheck & BoundsCheck.BOTTOM)
						{
							py = bounds.bottom;
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
						}
						else if (newCheck & BoundsCheck.TOP)
						{
							py = bounds.top;
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
						}
						else if (newCheck & BoundsCheck.LEFT)
						{
							if (rightSiteVX.y - bounds.y + newSiteVX.y - bounds.y < bounds.height)
							{
								py = bounds.top;
							}
							else
							{
								py = bounds.bottom;
							}
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
							sitePoints.push(PointVXPool.getPointFromSubpool(bounds.left, py));
						}
					}
					else if (rightCheck & BoundsCheck.LEFT)
					{
						px = bounds.left;
						if (newCheck & BoundsCheck.BOTTOM)
						{
							py = bounds.bottom;
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
						}
						else if (newCheck & BoundsCheck.TOP)
						{
							py = bounds.top;
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
						}
						else if (newCheck & BoundsCheck.RIGHT)
						{
							if (rightSiteVX.y - bounds.y + newSiteVX.y - bounds.y < bounds.height)
							{
								py = bounds.top;
							}
							else
							{
								py = bounds.bottom;
							}
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
							sitePoints.push(PointVXPool.getPointFromSubpool(bounds.right, py));
						}
					}
					else if (rightCheck & BoundsCheck.TOP)
					{
						py = bounds.top;
						if (newCheck & BoundsCheck.RIGHT)
						{
							px = bounds.right;
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
						}
						else if (newCheck & BoundsCheck.LEFT)
						{
							px = bounds.left;
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
						}
						else if (newCheck & BoundsCheck.BOTTOM)
						{
							if (rightSiteVX.x - bounds.x + newSiteVX.x - bounds.x < bounds.width)
							{
								px = bounds.left;
							}
							else
							{
								px = bounds.right;
							}
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
							sitePoints.push(PointVXPool.getPointFromSubpool(px, bounds.bottom));
						}
					}
					else if (rightCheck & BoundsCheck.BOTTOM)
					{
						py = bounds.bottom;
						if (newCheck & BoundsCheck.RIGHT)
						{
							px = bounds.right;
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
						}
						else if (newCheck & BoundsCheck.LEFT)
						{
							px = bounds.left;
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
						}
						else if (newCheck & BoundsCheck.TOP)
						{
							if (rightSiteVX.x - bounds.x + newSiteVX.x - bounds.x < bounds.width)
							{
								px = bounds.left;
							}
							else
							{
								px = bounds.right;
							}
							sitePoints.push(PointVXPool.getPointFromSubpool(px, py));
							sitePoints.push(PointVXPool.getPointFromSubpool(px, bounds.top));
						}
					}
				}
				if (closingUp)
				{
					// newEdge's ends have already been added
					return;
				}
				sitePoints.push(newSiteVX);
			}
			var newRightSiteVX:PointVX = newEdge.clippedEnds[LR.other(newOrientation)];
			if (!closeEnough(sitePoints[0], newRightSiteVX))
			{
				sitePoints.push(newRightSiteVX);
			}
		}
		
		internal function get x():Number
		{
			return _coord.x;
		}
		internal function get y():Number
		{
			return _coord.y;
		}
		
		internal function dist(p:ICoord):Number
		{
			return PointVX.distance(p.coord, this._coord);
		}

	}
}

	class PrivateConstructorEnforcer {}

	import com.luketramps.vorox.data.PointVX;
	import flash.geom.Rectangle;
	
	final class BoundsCheck
	{
		public static const TOP:int = 1;
		public static const BOTTOM:int = 2;
		public static const LEFT:int = 4;
		public static const RIGHT:int = 8;
		
		/**
		 * 
		 * @param SiteVX
		 * @param bounds
		 * @return an int with the appropriate bits set if the SiteVX lies on the corresponding bounds lines
		 * 
		 */
		public static function check(p:PointVX, bounds:Rectangle):int
		{
			var value:int = 0;
			if (p.x == bounds.left)
			{
				value |= LEFT;
			}
			if (p.x == bounds.right)
			{
				value |= RIGHT;
			}
			if (p.y == bounds.top)
			{
				value |= TOP;
			}
			if (p.y == bounds.bottom)
			{
				value |= BOTTOM;
			}
			return value;
		}
		
		public function BoundsCheck()
		{
			throw new Error("BoundsCheck constructor unused");
		}

	}