/*
 *  	VoroX - Voronoi Animation Framework
 *  	http://www.luketramps.com/vorox
 *  	Copyright 2016 Lukas Damian Opacki. All rights reserved.
 *  	MIT License https://github.com/luketramps/VoroX/blob/master/LICENSE
 */
package com.luketramps.vorox.data 
{
	import flash.geom.Point;
	/**
	 * A more lightweight replacement for traditional <code>flash.geom.Point</class>, that holds the automaticly updated index of site.
	 * @author Lukas Damian Opacki
	 */
	public class PointVX
	{
		
		public static function fromPoint (p:Point):PointVX
		{
			return new PointVX (p.x, p.y);
		}
		
		public static function distanceFromOrigin (p : PointVX):Number 
		{
			return Math.sqrt(p.x * p.x + p.y * p.y);
		}
		
		public static function distance (a:PointVX, b:PointVX):Number 
		{
			return Math.sqrt ( (  Math.pow ((a.x - b.x), 2)
								+ Math.pow ((a.y - b.y), 2)));
		}
		
		[Inline]
		public static function interpolate(pt1:PointVX, pt2:PointVX, f:Number):PointVX 
		{
			return new PointVX ((pt1.x - pt2.x) * f + pt2.x, (pt1.y - pt2.y) * f + pt2.y );
		}
		
		[Inline]
		public static function interpolate2(pt1:PointVX, pt2:PointVX, f:Number, result:PointVX):void 
		{
			result.x = (pt1.x - pt2.x) * f + pt2.x;
			result.y = (pt1.y - pt2.y) * f + pt2.y;
		}
		
		public static function normalize( p : PointVX, thickness : Number) : void {
			if (p.x==0 && p.y==0)
				p.x = thickness;
			else {
				var norm:Number = thickness / Math.sqrt (p.x * p.x + p.y * p.y);
				p.x *= norm;
				p.y *= norm;
			}
		}
		
		public static function add( p1 : PointVX, p2 : PointVX) : PointVX {
			return new PointVX (p2.x + p1.x, p2.y + p1.y);
		}
		
		/**
		 * X coordinate.
		 */
		public var x:Number;
		
		/**
		 * Y coordinate.
		 */
		public var y:Number;
		
		/**
		 * Site index. If the instance of <code>PointVX</code> represents a site, than this is the index to look it up.
		 */
		public var index:uint;
		
		/**
		 * Creates a new PointVX instance.
		 * @param	x  X coordinate.
		 * @param	y  Y coordinate
		 * @param	index  Index of the site, if this instance represents a site.
		 */
		public function PointVX(x:Number = 0, y:Number = 0, index:uint = 0) 
		{
			this.x = x;
			this.y = y;
			this.index = index;
		}
		
		/**
		 * Creates and returns a new PointVX instance with same coodridnates and index as the current one.
		 * @return New PointVX.
		 */
		public function clone():PointVX
		{
			return new PointVX (x, y, index);
		}
		
		public function toString():String
		{
			return "PointVX";
		}
	}

}