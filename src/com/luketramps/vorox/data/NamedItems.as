/*
 *  	VoroX - Voronoi Animation Framework
 *  	http://www.luketramps.com/vorox
 *  	Copyright 2016 Lukas Damian Opacki. All rights reserved.
 *  	MIT License https://github.com/luketramps/VoroX/blob/master/LICENSE
 */
package com.luketramps.vorox.data 
{
	/**
	 * @author Lukas Damian Opacki
	 */
	public class NamedItems 
	{
		// Data
		private var itemsArr:Array;
		private var itemNames:Array;
		private var itemsObj:Object;
		
		// Iteration
		private var _cursor:uint;
		private var _length:uint;
		
		// Errors
		public var returnNullError:Error = new Error ("Item does not exist.");
		public var returnNullErrorMethod:Function;
		public var overrideExistingItemError:Error = new Error ("Item already exists.");
		public var overrideExistingItemErrorMethod:Function;
		
		// Constructor.
		public function NamedItems() 
		{
			clear ();
		}
		
		public function add(name:String, object:*, preventOverride:Boolean = false):uint
		{
			if (preventOverride && containsName (name))
				if (overrideExistingItemErrorMethod) 
					overrideExistingItemErrorMethod (name);
				else throw overrideExistingItemError;
				
			itemNames.push (name);
			itemsArr.push (object);
			itemsObj[name] = object;
			return ++_length;
		}
		
		public function remove(name:String):*
		{
			var index:uint = itemNames.indexOf (name);
			
			if (index != -1)
			{
				itemNames.splice (index, 1);
				itemsArr.splice (index, 1);
				delete itemsObj[name];
			}
		}
		
		/* INTERFACE com.luketramps.corex.data.Iterable */
		
		public function get index():uint
		{
			return _cursor;
		}
		
		public function get name():String
		{
			return itemNames [_cursor];
		}
		
		public function get data():* 
		{
			return itemsArr[_cursor];
		}
		
		public function set data(value:*):void 
		{
			itemsArr[_cursor] = value;
		}
		
		public function next():* 
		{
			return itemsArr[++_cursor]
		}
		
		public function hasNext():Boolean 
		{
			return itemsArr[_cursor+1] != null;
		}
		
		public function reset():void 
		{
			_cursor = 0;
		}
		
		public function clear():void
		{
			this.itemNames = [];
			this.itemsArr = [];
			this.itemsObj = { };
			
			this._length = 0;
			this._cursor = 0;
		}
		
		public function contains(item:*):Boolean
		{
			return itemsArr.indexOf (item) != -1;
		}
		
		public function containsName(name:String):Boolean
		{
			return itemsObj[name] != null;
		}
		
		public function getItemByName(name:String, throwReturnNullError:Boolean = false):*
		{
			if (!throwReturnNullError)
				return itemsObj[name];
			
			if (!itemsObj[name])
				if (!returnNullErrorMethod) throw returnNullError;
				else returnNullErrorMethod (name);
			
			return itemsObj[name];
		}
		
		public function get length():uint
		{
			return _length;
		}
	}

}