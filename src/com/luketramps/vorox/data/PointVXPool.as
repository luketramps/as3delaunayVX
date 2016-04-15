/*
 *  	VoroX - Voronoi Animation Framework
 *  	http://www.luketramps.com/vorox
 *  	Copyright 2016 Lukas Damian Opacki. All rights reserved.
 *  	MIT License https://github.com/luketramps/VoroX/blob/master/LICENSE
 */
package com.luketramps.vorox.data 
{
	/**
	 * Internal pool.
	 * @author Lukas Damian Opacki
	 */
	final public class PointVXPool 
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
		
		// Actual pool for PointVX objects.
		private static var GROW_SIZE:uint;
		private static var MAX_SIZE:uint;
		private static var objPool:Vector.<PointVX>;
		private static var objCounter:uint;
		private static var currentPoint:PointVX;
		
		// Reference storages for collective disposal.
		private static var allSubpools:Array;
		private static var availableSubpools:Vector.<ReferenceStorage>;
		private static var poolCounter:uint;
		private static var currentPool:ReferenceStorage;
		
		// POINT POOL
		public static function init(maxPoolSize:uint, growthSize:uint):void
		{
			MAX_SIZE = maxPoolSize;
			GROW_SIZE = growthSize;
			objCounter = maxPoolSize;
			
			var i:uint = maxPoolSize
			objPool = new Vector.<PointVX> (MAX_SIZE, (GROW_SIZE == 0) ? true : false);
			
			while (--i > -1)
				objPool[i] = new PointVX ();
				
				
			initSubpools();
		}
		
		public static function getPoint(x:Number = 0, y:Number = 0, index:uint = 0):PointVX
		{
			if (objCounter > 0)
			{
				currentPoint = objPool[--objCounter];
				
				currentPoint.x = x;
				currentPoint.y = y;
				currentPoint.index = index;
				
				return currentPoint;
			}
			
			if (GROW_SIZE == 0)
				throw new Error ("Fixed Pools require additional objects. Please check vorox pooling configuration.");
			
			numGrowth++;
			
			var i:uint = GROW_SIZE;
			while (--i > -1)
				objPool.unshift (new PointVX ())
				
			objCounter = GROW_SIZE;
			return getPoint (x, y, index);
		}
		
		[Inline]
		public static function disposePoint(p:PointVX):void
		{
			objPool[objCounter++] = p;
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
				currentPool = availableSubpools[--poolCounter]; 		//if (!currentPool.isClear ()) throw new Error ("something went wrong!");
				return currentPool.id;
			}
			
			var newPool:ReferenceStorage = new ReferenceStorage(MAX_SIZE, allSubpools.length);
			
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
		
		// Stores a PointVX ref in the current subpool and returns it.
		public static function getPointFromSubpool(x:Number, y:Number, index:uint = 0):PointVX
		{
			return currentPool.store (getPoint (x, y, index));
		}
		
	}

}
import com.luketramps.vorox.data.PointVXPool;
import com.luketramps.vorox.data.PointVX;
/*
 * Utility class that stores references for disposal.
 */
class ReferenceStorage
{
	public var references:Vector.<PointVX>;
	public var numRefs:uint;
	public var id:uint;
	
	public function ReferenceStorage(size:uint, index:uint):void
	{
		references = new Vector.<PointVX> (size);
		numRefs = 0;
		id = index;
	}
	
	public final function store (p:PointVX):PointVX
	{
		return references[numRefs++] = p;
	}
	
	public final function dispose():ReferenceStorage
	{
		for (var i:int = 0; i < numRefs; i++) 
			PointVXPool.disposePoint (references[i]);
		
		numRefs = 0;
		
		return this;
	}
	
	public function isClear():Boolean
	{
		return numRefs == 0;
	}
}