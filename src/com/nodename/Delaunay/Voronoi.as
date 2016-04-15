/*
 * The author of this software is Steven Fortune.  Copyright (c) 1994 by AT&T
 * Bell Laboratories.
 * Permission to use, copy, modify, and distribute this software for any
 * purpose without fee is hereby granted, provided that this entire notice
 * is included in all copies of any software which is or includes a copy
 * or modification of this software and in all copies of the supporting
 * documentation for such software.
 * THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTY.  IN PARTICULAR, NEITHER THE AUTHORS NOR AT&T MAKE ANY
 * REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY
 * OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
 */


package com.nodename.Delaunay
{
	import com.luketramps.vorox.data.DictionaryPool;
	import com.luketramps.vorox.data.HalfEdgePool;
	import com.luketramps.vorox.data.PointVX;
	import com.luketramps.vorox.data.PointVXPool;
	import com.luketramps.vorox.data.VectorEdgePool;
	import com.luketramps.vorox.data.VectorHalfEdgePool;
	import com.luketramps.vorox.data.VectorPointVXPool;
	import com.luketramps.vorox.data.VectorVertexPool;
	import com.nodename.geom.Circle;
	import com.nodename.geom.LineSegment;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	public final class Voronoi
	{
		private var _sites:SiteList;
		private var _sitesIndexedByLocation:Dictionary;
		private var _triangles:Vector.<Triangle>;
		private var _edges:Vector.<Edge>;
		
		// TODO generalize this so it doesn't have to be a rectangle;
		// then we can make the fractal voronois-within-voronois
		private var _plotBounds:Rectangle;
		public function get plotBounds():Rectangle
		{
			return _plotBounds;
		}
		
		public function dispose():void
		{
			var i:int, n:int;
			if (_sites)
			{
				_sites.dispose();
				_sites = null;
			}
			if (_triangles)
			{
				n = _triangles.length;
				for (i = 0; i < n; ++i)
				{
					_triangles[i].dispose();
				}
				_triangles.length = 0;
				_triangles = null;
			}
			if (_edges)
			{
				n = _edges.length;
				// Lukes mod. Done by EdgePool.
				//for (i = 0; i < n; ++i)
				//{
					//_edges[i].dispose();
				//}
				_edges.length = 0;
				_edges = null;
			}
			_plotBounds = null;
			_sitesIndexedByLocation = null;
		}
		
		public function Voronoi(sitePoints:Vector.<PointVX>, colors:Vector.<uint>, plotBounds:Rectangle)
		{
			_sites = new SiteList();
			_sitesIndexedByLocation = DictionaryPool.getDictFromSubpool();
			addSites(sitePoints, colors);
			_plotBounds = plotBounds;
			_triangles = new Vector.<Triangle>();
			_edges = VectorEdgePool.getObjFromSubpool ();
			fortunesAlgorithm();
		}
		
		
		private final function addSites(sitePoints:Vector.<PointVX>, colors:Vector.<uint>):void
		{
			var length:uint = sitePoints.length;
			for (var i:uint = 0; i < length; ++i)
			{
				addSite(sitePoints[i], colors ? colors[0] : 0, i);
			}
		}
		
		
		private final function addSite(p:PointVX, color:uint, index:int):void
		{
			var weight:Number = Math.random() * 100;
			var site:Site = Site.create(p, index, weight, color);
			_sites.push(site);
			_sitesIndexedByLocation[p] = site;
		}

                public function edges():Vector.<Edge>
                {
                	return _edges;
                }
          
		public function region(p:PointVX):Vector.<PointVX>
		{
			var site:Site = _sitesIndexedByLocation[p];
			if (!site)
			{
				return VectorPointVXPool..getObjFromSubpool ();
			}
			return site.region(_plotBounds);
		}

          // TODO: bug: if you call this before you call region(), something goes wrong :(
		public function neighborSitesForSite(coord:PointVX):Vector.<PointVX>
		{
			var sitePoints:Vector.<PointVX> = VectorPointVXPool.getObjFromSubpool ();
			var site:Site = _sitesIndexedByLocation[coord];
			if (!site)
			{
				return sitePoints;
			}
			var sites:Vector.<Site> = site.neighborSites();
			var neighbor:Site;
			for each (neighbor in sites)
			{
				sitePoints.push(neighbor.coord);
			}
			return sitePoints;
		}

		public function circles():Vector.<Circle>
		{
			return _sites.circles();
		}
		
		public function voronoiBoundaryForSite(coord:PointVX):Vector.<LineSegment>
		{
			return visibleLineSegments(selectEdgesForSitePoint(coord, _edges));
		}

		public function delaunayLinesForSite(coord:PointVX):Vector.<LineSegment>
		{
			return delaunayLinesForEdges(selectEdgesForSitePoint(coord, _edges));
		}
		
		public function voronoiDiagram():Vector.<LineSegment>
		{
			return visibleLineSegments(_edges);
		}
		
		public function delaunayTriangulation(keepOutMask:BitmapData = null):Vector.<LineSegment>
		{
			return delaunayLinesForEdges(selectNonIntersectingEdges(keepOutMask, _edges));
		}
		
		public function hull():Vector.<LineSegment>
		{
			return delaunayLinesForEdges(hullEdges());
		}
		
		
		private final function hullEdges():Vector.<Edge>
		{
			return _edges.filter(myTest);
		
			function myTest(edge:Edge, index:int, vector:Vector.<Edge>):Boolean
			{
				return (edge.isPartOfConvexHull());
			}
		}

		public function hullsitePointsInOrder():Vector.<PointVX>
		{
			var hullEdges:Vector.<Edge> = hullEdges();
			
			var sitePoints:Vector.<PointVX> = VectorPointVXPool.getObjFromSubpool ();
			if (hullEdges.length == 0)
			{
				return sitePoints;
			}
			
			EdgeReorderer2.reorder (hullEdges, Site); //var reorderer:EdgeReorderer = new EdgeReorderer(hullEdges, Site);
			hullEdges = EdgeReorderer2.edges;
			var orientations:Vector.<LR> = EdgeReorderer2.edgeOrientations;
			//reorderer.dispose();
			
			var orientation:LR;

			var n:int = hullEdges.length;
			for (var i:int = 0; i < n; ++i)
			{
				var edge:Edge = hullEdges[i];
				orientation = orientations[i];
				sitePoints.push(edge.site(orientation).coord);
			}
			return sitePoints;
		}
		
		public function spanningTree(type:String = "minimum", keepOutMask:BitmapData = null):Vector.<LineSegment>
		{
			var edges:Vector.<Edge> = selectNonIntersectingEdges(keepOutMask, _edges);
			var segments:Vector.<LineSegment> = delaunayLinesForEdges(edges);
			return kruskal(segments, type);
		}
		
		public function regions():Vector.<Vector.<PointVX>>
		{
			return _sites.regions(_plotBounds);
		}
		
		public function siteColors(referenceImage:BitmapData = null):Vector.<uint>
		{
			return _sites.siteColors(referenceImage);
		}
		
		/**
		 * 
		 * @param proximityMap a BitmapData whose regions are filled with the site index values; see PlanesitePointsCanvas::fillRegions()
		 * @param x
		 * @param y
		 * @return coordinates of nearest Site to (x, y)
		 * 
		 */
		public function nearestSiteSiteVX(proximityMap:BitmapData, x:Number, y:Number):PointVX
		{
			return _sites.nearestSiteSiteVX(proximityMap, x, y);
		}
		
		public function siteCoords():Vector.<PointVX>
		{
			return _sites.siteCoords();
		}
		
		private function fortunesAlgorithm():void
		{
			var newSite:Site, bottomSite:Site, topSite:Site, tempSite:Site;
			var v:Vertex, vertex:Vertex;
			var newintstar:PointVX;
			var leftRight:LR;
			var lbnd:Halfedge, rbnd:Halfedge, llbnd:Halfedge, rrbnd:Halfedge, bisector:Halfedge;
			var edge:Edge;
			
			var dataBounds:Rectangle = _sites.getSitesBounds();
			
			var sqrt_nsites:int = int(Math.sqrt(_sites.length + 4));
			var heap:HalfedgePriorityQueue = new HalfedgePriorityQueue(dataBounds.y, dataBounds.height, sqrt_nsites);
			var edgeList:EdgeList = new EdgeList(dataBounds.x, dataBounds.width, sqrt_nsites);
			var halfEdges:Vector.<Halfedge> = VectorHalfEdgePool.getVectorFromSubpool (); // new Vector.<Halfedge>();
			var vertices:Vector.<Vertex> = VectorVertexPool.getVectorFromSubpool (); //new Vector.<Vertex>();
			
			var bottomMostSite:Site = _sites.next();
			newSite = _sites.next();
			
			for (;;)
			{
				if (heap.empty() == false)
				{
					newintstar = heap.min();
					
					if (newSite) // Lukes mod. Inlined compareByXThenY function.
					{
						var comparedXThenY:int;
						if (newSite.y < newintstar.y) comparedXThenY = -1;
						else if (newSite.y > newintstar.y) comparedXThenY = 1;
						else if (newSite.x < newintstar.x) comparedXThenY = -1;
						else if (newSite.x > newintstar.x) comparedXThenY = 1;
						else comparedXThenY = 0;
					}
				}
				
				if (newSite != null 
				&&  (heap.empty() || comparedXThenY < 0))
				{
					/* new site is smallest */
					//trace("smallest: new site " + newSite);
					
					// Step 8:
					lbnd = edgeList.edgeListLeftNeighbor(newSite.coord);	// the Halfedge just to the left of newSite
					//trace("lbnd: " + lbnd);
					rbnd = lbnd.edgeListRightNeighbor;		// the Halfedge just to the right
					//trace("rbnd: " + rbnd);
					bottomSite = (lbnd.edge) ? lbnd.edge.site (LR.other(lbnd.leftRight)) : bottomMostSite // rightRegion(lbnd);		// this is the same as leftRegion(rbnd)
					// this Site determines the region containing the new site
					//trace("new Site is in region of existing site: " + bottomSite);
					
					// Step 9:
					edge = Edge.createBisectingEdge(bottomSite, newSite);
					//trace("new edge: " + edge);
					_edges.push(edge);
					
					bisector = HalfEdgePool.getHalfedgeFromSubpool (edge, LR.LEFT);
					halfEdges.push(bisector);
					// inserting two Halfedges into edgeList constitutes Step 10:
					// insert bisector to the right of lbnd:
					edgeList.insert(lbnd, bisector);
					
					// first half of Step 11:
					if ((vertex = Vertex.intersect(lbnd, bisector)) != null) 
					{
						vertices.push(vertex);
						heap.remove(lbnd);
						lbnd.vertex = vertex;
						lbnd.ystar = vertex.y + newSite.dist(vertex);
						heap.insert(lbnd);
					}
					
					lbnd = bisector;
					bisector = HalfEdgePool.getHalfedgeFromSubpool (edge, LR.RIGHT);
					halfEdges.push(bisector);
					// second Halfedge for Step 10:
					// insert bisector to the right of lbnd:
					edgeList.insert(lbnd, bisector);
					
					// second half of Step 11:
					if ((vertex = Vertex.intersect(bisector, rbnd)) != null)
					{
						vertices.push(vertex);
						bisector.vertex = vertex;
						bisector.ystar = vertex.y + newSite.dist(vertex);
						heap.insert(bisector);	
					}
					
					newSite = _sites.next();	
				}
				else if (heap.empty() == false) 
				{
					/* intersection is smallest */
					lbnd = heap.extractMin();
					llbnd = lbnd.edgeListLeftNeighbor;
					rbnd = lbnd.edgeListRightNeighbor;
					rrbnd = rbnd.edgeListRightNeighbor;
					bottomSite = (lbnd.edge) ? lbnd.edge.site (lbnd.leftRight) : bottomMostSite; // leftRegion(lbnd); // 
					topSite = (rbnd.edge) ? rbnd.edge.site (LR.other (rbnd.leftRight)) : bottomMostSite; //rightRegion(rbnd);
					// these three sites define a Delaunay triangle
					// (not actually using these for anything...)
					//_triangles.push(new Triangle(bottomSite, topSite, rightRegion(lbnd)));
					
					v = lbnd.vertex;
					v.setIndex();
					lbnd.edge.setVertex(lbnd.leftRight, v);
					rbnd.edge.setVertex(rbnd.leftRight, v);
					edgeList.remove(lbnd); 
					heap.remove(rbnd);
					edgeList.remove(rbnd); 
					leftRight = LR.LEFT;
					if (bottomSite.y > topSite.y)
					{
						tempSite = bottomSite; bottomSite = topSite; topSite = tempSite; leftRight = LR.RIGHT;
					}
					edge = Edge.createBisectingEdge(bottomSite, topSite);
					_edges.push(edge);
					bisector = HalfEdgePool.getHalfedgeFromSubpool (edge, leftRight);
					halfEdges.push(bisector);
					edgeList.insert(llbnd, bisector);
					edge.setVertex(LR.other(leftRight), v);
					if ((vertex = Vertex.intersect(llbnd, bisector)) != null)
					{
						vertices.push(vertex);
						heap.remove(llbnd);
						llbnd.vertex = vertex;
						llbnd.ystar = vertex.y + bottomSite.dist(vertex);
						heap.insert(llbnd);
					}
					if ((vertex = Vertex.intersect(bisector, rrbnd)) != null)
					{
						vertices.push(vertex);
						bisector.vertex = vertex;
						bisector.ystar = vertex.y + bottomSite.dist(vertex);
						heap.insert(bisector);
					}
				}
				else
				{
					break;
				}
			}
			
			// heap should be empty now
			heap.dispose();
			edgeList.dispose();
			
			for each (var halfEdge:Halfedge in halfEdges)
			{
				halfEdge.reallyDispose();
			}
			halfEdges.length = 0;
			
			// we need the vertices to clip the edges
			for each (edge in _edges)
			{
				edge.clipVertices(_plotBounds);
			}
			// but we don't actually ever use them again!
			for each (vertex in vertices)
			{
				vertex.dispose();
			}
			vertices.length = 0;
		}
		
		// Lukes mod. This function was inlined by hand.
		internal static function compareByYThenX(s1:Site, s2:*):Number
		{
			if (s1.y < s2.y) return -1;
			if (s1.y > s2.y) return 1;
			if (s1.x < s2.x) return -1;
			if (s1.x > s2.x) return 1;
			return 0;
		}

	}
}