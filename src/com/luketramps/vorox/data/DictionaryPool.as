/*
 *  	VoroX - Voronoi Animation Framework
 *  	http://www.luketramps.com/vorox
 *  	Copyright 2016 Lukas Damian Opacki. All rights reserved.
 *  	MIT License https://github.com/luketramps/VoroX/blob/master/LICENSE
 */
package com.luketramps.vorox.data 
{
	import flash.utils.Dictionary;
	/**
	 * Internal pool.
	 * @author Lukas Damian Opacki
	 */
	final public class DictionaryPool 
	{
		// DEBUG
		
		private static var numGrowth:uint = 0;
		
		public static function get inUse():uint
		{
			return MAX_SIZE + (numGrowth * GROW_SIZE) - dictCounter;
		}
		
		public static function get max():uint
		{
			return dictPool.length;
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
		private static var dictPool:Vector.<Dictionary>;
		private static var dictCounter:uint;
		
		// Reference storages for collective disposal.
		private static var allSubpools:Array;
		private static var availableSubpools:Vector.<ReferenceStorage>;
		private static var poolCounter:uint;
		private static var currentPool:ReferenceStorage;
		
		public static function init(maxPoolSize:uint, growthSize:uint):void
		{
			MAX_SIZE = maxPoolSize;
			GROW_SIZE = growthSize;
			dictCounter = maxPoolSize;
			
			var i:uint = maxPoolSize
			dictPool = new Vector.<Dictionary> (MAX_SIZE, (GROW_SIZE == 0) ? true : false);
			
			while (--i > -1)
				dictPool[i] = new Dictionary (true);
				
				
			initSubpools();
		}
		
		public static function getDict():Dictionary
		{
			if (dictCounter > 0)
			{
				return dictPool[--dictCounter];
			}
			
			if (GROW_SIZE == 0)
				throw new Error ("Fixed Pools require additional objects. Please check vorox pooling configuration.");
			
			numGrowth++;
			
			var i:uint = GROW_SIZE;
			while (--i > -1)
				dictPool.unshift (new Dictionary (true))
				
			dictCounter = GROW_SIZE;
			return getDict ();
		}
		
		[Inline]
		public static function disposeDict(d:Dictionary, clearDict:Boolean = false):void
		{
			if (clearDict)
				for (var name:String in d) 
					delete d[name];
			
			dictPool[dictCounter++] = d;
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
		public static function getDictFromSubpool():Dictionary
		{
			return currentPool.store (getDict ());
		}
		
	}

}
import com.luketramps.vorox.data.DictionaryPool;
import flash.utils.Dictionary;
/*
 * Utility class that stores references for disposal.
 */
class ReferenceStorage
{
	public var references:Vector.<Dictionary>;
	public var numRefs:uint;
	public var id:uint;
	
	public function ReferenceStorage(size:uint, index:uint):void
	{
		references = new Vector.<Dictionary> (size);
		numRefs = 0;
		id = index;
	}
	
	public final function store (p:Dictionary):Dictionary
	{
		return references[numRefs++] = p;
	}
	
	public final function dispose():ReferenceStorage
	{
		for (var i:int = 0; i < numRefs; i++) 
			DictionaryPool.disposeDict (references[i]);
		
		numRefs = 0;
		
		return this;
	}
	
	public function isClear():Boolean
	{
		return numRefs == 0;
	}
}