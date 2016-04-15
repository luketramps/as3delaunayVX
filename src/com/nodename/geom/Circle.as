package com.nodename.geom
{
	import com.luketramps.vorox.data.PointVX;
	
	public final class Circle extends Object
	{
		public var center:PointVX;
		public var radius:Number;
		
		public function Circle(centerX:Number, centerY:Number, radius:Number)
		{
			super();
			this.center = new PointVX(centerX, centerY);
			this.radius = radius;
		}
		
		public function toString():String
		{
			return "Circle (center: " + center + "; radius: " + radius + ")";
		}

	}
}