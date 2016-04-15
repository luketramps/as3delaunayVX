package 
{
	import com.luketramps.vorox.data.DictionaryPool;
	import com.luketramps.vorox.data.EdgePool;
	import com.luketramps.vorox.data.HalfEdgePool;
	import com.luketramps.vorox.data.PointVX;
	import com.luketramps.vorox.data.PointVXPool;
	import com.luketramps.vorox.data.PoolsConfig;
	import com.luketramps.vorox.data.VectorBoolPool;
	import com.luketramps.vorox.data.VectorEdgePool;
	import com.luketramps.vorox.data.VectorHalfEdgePool;
	import com.luketramps.vorox.data.VectorLrPool;
	import com.luketramps.vorox.data.VectorPointVXPool;
	import com.luketramps.vorox.data.VectorVertexPool;
	import com.nodename.Delaunay.Edge;
	import com.nodename.Delaunay.Voronoi;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Lukas Damian Opacki
	 */
	 [SWF(frameRate="250")]
	public class MainDelauney extends MovieClip
	{
		private var bounds:Rectangle;
		private var sites:Vector.<PointVX>;
		private var voronoi:Voronoi;
		private var polygons:Vector.<Vector.<PointVX>>;
		
		// Pools.
		
		private var pointPoolID:uint;
		private var edgePoolID:uint;
		private var dictPoolID:uint;
		private var vecEdgePoolID:uint;
		private var vecBoolPoolID:uint;
		private var vecPvxPoolID:uint;
		private var vecLrPoolID:uint;
		private var vecHalfEdgePoolID:uint;
		private var halfEdgePoolID:uint;
		private var vecVertexPoolID:uint;
		
		
		public function MainDelauney() 
		{
			createSites ();
			initPools ();
			addEventListener (Event.ENTER_FRAME, onFrame);
		}
		
		private function createSites():void 
		{
			bounds = new Rectangle (0, 0, stage.stageWidth, stage.stageHeight);
			sites = new Vector.<PointVX> ();
			
			for (var i:int = 0; i < 30; i++) 
			{
				sites.push (new PointVX (bounds.width * Math.random (), bounds.height * Math.random ()));
			}
		}
		
		// Create and dispose Voronoi instance.
		private function onFrame(e:Event):void 
		{
			// Dispose an existing Voronoi instance.
			if (voronoi != null)
			{
				clearPools ();
				voronoi.dispose ();
			}
			
			// Create a new Voronoi instance.
			setupPools ();
			voronoi = new Voronoi (sites, null, bounds);
			voronoi.delaunayTriangulation ();
			
			// Render graphics.
			//displayChart ();
		}
		
		// Render voronoi regions to display.
		private function displayChart():void 
		{
			// retrieve a collection of polygons
			polygons = voronoi.regions ();
			
			graphics.lineStyle (2, 0);
			
			for (var i:int = 0; i < polygons.length; i++) 
			{
				var polygon:Vector.<PointVX> = polygons[i];
				
				// move to the first point of the polygon
				graphics.moveTo (polygon[0].x, polygon[0].y);
				
				for (var j:int = 1; j < polygon.length; j++) 
				{
					// line to the next point
					graphics.lineTo (polygon[j].x, polygon[j].y);
				}
				
				// close the polygon
				graphics.lineTo (polygon[0].x, polygon[0].y);
			}
		}
		
		// POOLS
		
		// Every instance of Voronoi requires a set of 'ids' for collecting object references...
		private final function setupPools():void
		{
			pointPoolID = PointVXPool.enterNextSubPool ();
			edgePoolID = EdgePool.enterNextSubPool ();
			dictPoolID = DictionaryPool.enterNextSubPool ();
			vecEdgePoolID = VectorEdgePool.enterNextSubPool ();
			vecBoolPoolID = VectorBoolPool.enterNextSubPool ();
			vecPvxPoolID = VectorPointVXPool.enterNextSubPool ();
			vecLrPoolID = VectorLrPool.enterNextSubPool ();
			halfEdgePoolID = HalfEdgePool.enterNextSubPool ();
			vecHalfEdgePoolID = VectorHalfEdgePool.enterNextSubPool ();
			vecVertexPoolID = VectorVertexPool.enterNextSubPool ();
		}
		
		// ... which represent refence collections, that can be disposed like this (objects return to pool).
		private final function clearPools():void
		{
			PointVXPool.disposeSubpool (pointPoolID);
			EdgePool.disposeSubpool (edgePoolID);
			DictionaryPool.disposeSubpool (dictPoolID);
			VectorEdgePool.disposeSubpool (vecEdgePoolID);
			VectorBoolPool.disposeSubpool (vecBoolPoolID);
			VectorPointVXPool.disposeSubpool (vecPvxPoolID);
			VectorLrPool.disposeSubpool (vecLrPoolID);
			HalfEdgePool.disposeSubpool (halfEdgePoolID);
			VectorHalfEdgePool.disposeSubpool (vecHalfEdgePoolID);
			VectorVertexPool.disposeSubpool (vecVertexPoolID);
		}
		
		// Pools must be initialised before beeing used.
		private function initPools():void 
		{
			// Define pool size.
			var config:PoolsConfig = new PoolsConfig ();
			
			VectorHalfEdgePool.init (config.vecHalfedgePoolSize, uint (config.vecHalfedgePoolSize/5))
			VectorVertexPool.init (config.vecVertexPoolSize, uint (config.vecVertexPoolSize / 5));
			PointVXPool.init (config.pointPoolSize, uint (config.pointPoolSize/5));
			VectorEdgePool.init (config.vecEdgePoolSize, uint (config.vecEdgePoolSize/5));
			VectorBoolPool.init (config.vecBoolPoolSize, uint (config.vecBoolPoolSize/5));
			VectorPointVXPool.init (config.vecPointPoolSize, uint (config.vecPointPoolSize/5));
			DictionaryPool.init (config.dictPoolSize, uint (config.dictPoolSize/5));
			EdgePool.init (config.edgePoolSize, uint (config.edgePoolSize/5));
			VectorLrPool.init (config.vecLrPoolSize, uint (config.vecLrPoolSize / 5));
			HalfEdgePool.init (config.halfeedgePoolSize, uint (config.halfeedgePoolSize / 5));
			
			// Hotfix.
			Edge.createFirstEdge ();
		}
	}

}