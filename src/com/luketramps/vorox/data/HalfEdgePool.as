package com.luketramps.vorox.data 
{
	import com.nodename.Delaunay.Edge;
	import com.nodename.Delaunay.Halfedge;
	import com.nodename.Delaunay.LR;
	/**
	 * ...
	 * @author Lukas Damian Opacki
	 */
	final public class HalfEdgePool 
	{
		// DEBUG
		
		private static var numGrowth:uint = 0;
		
		public static function get inUse():uint
		{
			return MAX_SIZE + (numGrowth * GROW_SIZE) - objCounter;
		}
		
		public static function get max():uint
		{
			return objPool.length;
		}
		
		public static function get subpools():Array
		{
			var arr:Object = [];
			for (var i:int = 0; i < allSubpools.length; i++) 
			{
				arr[i] = String (allSubpools[i].numRefs)
			}
			return arr;
		}
		
		// POOL
		
		// Actual pool for dictonary objects.
		private static var GROW_SIZE:uint;
		private static var MAX_SIZE:uint;
		private static var objPool:Vector.<Halfedge>;
		private static var objCounter:uint;
		
		// Reference storages for collective disposal.
		private static var allSubpools:Array;
		private static var availableSubpools:Vector.<ReferenceStorage>;
		private static var poolCounter:uint;
		private static var currentPool:ReferenceStorage;
		
		public static function init(maxPoolSize:uint, growthSize:uint):void
		{
			MAX_SIZE = maxPoolSize;
			GROW_SIZE = growthSize;
			objCounter = maxPoolSize;
			
			var i:uint = maxPoolSize
			objPool = new Vector.<Halfedge> (MAX_SIZE, (GROW_SIZE == 0) ? true : false);
			
			while (--i > -1)
				objPool[i] = new Halfedge ();
				
				
			initSubpools();
		}
		
		public static function getHalfedge(edge:Edge, lr:LR):Halfedge
		{
			if (objCounter > 0)
			{
				return objPool[--objCounter].init (edge, lr);
			}
			
			if (GROW_SIZE == 0)
				throw new Error ("Fixed Pools require additional objects. Please check vorox pooling configuration.");
			
			numGrowth++;
			
			var i:uint = GROW_SIZE;
			while (--i > -1)
				objPool.unshift (new Halfedge ())
				
			objCounter = GROW_SIZE;
			return getHalfedge (edge, lr);
		}
		
		[Inline]
		public static function disposeHalfedge(halfeedge:Halfedge):void
		{
			objPool[objCounter++] = halfeedge;
		}
		
		// REFERENCE COLLECTIONS
		
		// Create the first subpool. 
		public static function initSubpools():void
		{
			var pool:ReferenceStorage = new ReferenceStorage (MAX_SIZE, 0);
			
			allSubpools = [];
			availableSubpools = new Vector.<ReferenceStorage> ();
			availableSubpools.push (pool);
			allSubpools.push (pool);
			poolCounter = 1;
		}
		
		// Sets the next subpool as current and returns its id.
		public static function enterNextSubPool():uint
		{
			if (poolCounter > 0)
			{
				currentPool = availableSubpools[--poolCounter]; 
				return currentPool.id;
			}
			
			var newPool:ReferenceStorage = new ReferenceStorage (MAX_SIZE, allSubpools.length);
			
			availableSubpools.unshift (newPool);
			allSubpools.push (newPool);
			poolCounter++;
			
			return enterNextSubPool ();
		}
		
		// Disposes the subpool accociated with the given id.
		public static function disposeSubpool(id:uint):void
		{
			availableSubpools[poolCounter++] = allSubpools[id].dispose ();
		}
		
		// Disposes all subpools
		public static function disposeAllSubpools():void
		{
			for (var i:int = 0; i < poolCounter-1; i++) 
			{
				disposeSubpool (poolCounter);
			}
		}
		
		// Stores a Dictionary ref in the current subpool and returns it.
		public static function getHalfedgeFromSubpool(edge:Edge, lr:LR):Halfedge
		{
			return currentPool.store (getHalfedge (edge, lr));
		}
		
	}

}

import com.nodename.Delaunay.Halfedge;
import com.luketramps.vorox.data.HalfEdgePool;
/*
 * Utility class that stores references for disposal.
 */
class ReferenceStorage
{
	public var references:Vector.<Halfedge>;
	public var numRefs:uint;
	public var id:uint;
	
	public function ReferenceStorage(size:uint, index:uint):void
	{
		references = new Vector.<Halfedge> (size);
		numRefs = 0;
		id = index;
	}
	
	public final function store (p:Halfedge):Halfedge
	{
		return references[numRefs++] = p;
	}
	
	public final function dispose():ReferenceStorage
	{
		for (var i:int = 0; i < numRefs; i++) 
			HalfEdgePool.disposeHalfedge (references[i]);
		
		numRefs = 0;
		
		return this;
	}
	
	public function isClear():Boolean
	{
		return numRefs == 0;
	}
}