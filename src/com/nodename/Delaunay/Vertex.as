package com.nodename.Delaunay
{
	import com.luketramps.vorox.data.PointVX;
	import com.luketramps.vorox.data.PointVXPool;
	import com.luketramps.vorox.data.VectorVertexPool;
	
	public final class Vertex extends Object implements ICoord
	{
		internal static var VERTEX_AT_INFINITY:Vertex = new Vertex(NaN, NaN);
		
		// Lukes mod. Workaround vorox pooling here.
		public static function createFirstVertex():void 
		{
			try {
				VERTEX_AT_INFINITY = new Vertex(NaN, NaN);
			}
			catch (e:*)
			{
				trace (VERTEX_AT_INFINITY);
			}
		}
		
		private static var _pool:Vector.<Vertex> = new Vector.<Vertex>();
		
		
		private static function create(x:Number, y:Number):Vertex
		{
			if (isNaN(x) || isNaN(y))
			{
				return VERTEX_AT_INFINITY;
			}
			if (_pool.length > 0)
			{
				return _pool.pop().init(x, y);
			}
			else
			{
				return new Vertex(x, y);
			}
		}
		
		
		private static var _nvertices:int = 0;
		
		private var _coord:PointVX;
		public function get coord():PointVX
		{
			return _coord;
		}
		private var _vertexIndex:int;
		public function get vertexIndex():int
		{
			return _vertexIndex;
		}
		
		public function Vertex(x:Number, y:Number) // Lukes mod. Remove private constructor enforcer lock.
		{
			init(x, y);
		}
		
		private function init(x:Number, y:Number):Vertex
		{
			if (_coord)
			{
				_coord.x = x;
				_coord.y = y;
			}
			else _coord = new PointVX (x, y); // Lukes mod. Don't pool points here, they stay in mem.
			
			return this;
		}
		
		public function dispose():void
		{
			//_coord = null; // Lukes mod. Don't garbage collect theese.
			_pool.push(this);
		}
		
		public function setIndex():void
		{
			_vertexIndex = _nvertices++;
		}

		/**
		 * This is the only way to make a Vertex
		 * 
		 * @param halfedge0
		 * @param halfedge1
		 * @return 
		 * 
		 */
		public static function intersect(halfedge0:Halfedge, halfedge1:Halfedge):Vertex
		{
			var edge0:Edge, edge1:Edge, edge:Edge;
			var halfedge:Halfedge;
			var determinant:Number, intersectionX:Number, intersectionY:Number;
			var rightOfSite:Boolean;
		
			edge0 = halfedge0.edge;
			edge1 = halfedge1.edge;
			if (edge0 == null || edge1 == null)
			{
				return null;
			}
			if (edge0.rightSite == edge1.rightSite)
			{
				return null;
			}
		
			determinant = edge0.a * edge1.b - edge0.b * edge1.a;
			if (-1.0e-10 < determinant && determinant < 1.0e-10)
			{
				// the edges are parallel
				return null;
			}
		
			intersectionX = (edge0.c * edge1.b - edge1.c * edge0.b)/determinant;
			intersectionY = (edge1.c * edge0.a - edge0.c * edge1.a)/determinant;
			
			// Inlined compareByXThenY function.
			var comparedXThenY:int;
			if (edge0.rightSite.y < edge1.rightSite.y) comparedXThenY = -1;
			else if (edge0.rightSite.y > edge1.rightSite.y) comparedXThenY = 1;
			else if (edge0.rightSite.x < edge1.rightSite.x) comparedXThenY = -1;
			else if (edge0.rightSite.x > edge1.rightSite.x) comparedXThenY = 1;
			else comparedXThenY = 0;
			
			if (comparedXThenY < 0)
			{
				halfedge = halfedge0; edge = edge0;
			}
			else
			{
				halfedge = halfedge1; edge = edge1;
			}
			rightOfSite = intersectionX >= edge.rightSite.x;
			if ((rightOfSite && halfedge.leftRight == LR.LEFT)
			||  (!rightOfSite && halfedge.leftRight == LR.RIGHT))
			{
				return null;
			}
		
			// Inline create function.
			//return Vertex.create(intersectionX, intersectionY);
			
			if (isNaN(intersectionX) || isNaN(intersectionY))
			{
				return VERTEX_AT_INFINITY;
			}
			if (_pool.length > 0)
			{
				return _pool.pop().init(intersectionX, intersectionY);
			}
			else
			{
				return new Vertex(intersectionX, intersectionY);
			}
		}
		
		public function get x():Number
		{
			return _coord.x;
		}
		public function get y():Number
		{
			return _coord.y;
		}
		
		static public function set AT_INFINITY(value:Vertex):void 
		{
			VERTEX_AT_INFINITY = value;
		}
		
	}
}