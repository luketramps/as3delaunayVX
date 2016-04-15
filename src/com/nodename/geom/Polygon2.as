package com.nodename.geom
{
	import com.luketramps.vorox.data.PointVX;

	public final class Polygon2
	{
		private static var _vertices:Vector.<PointVX>;

		public static function area():Number
		{
			return Math.abs(signedDoubleArea() * 0.5);
		}

		public static function winding(vertices:Vector.<PointVX>):Winding
		{
			_vertices = vertices;
			
			var signedDoubleA:Number = signedDoubleArea();
			if (signedDoubleA < 0)
			{
				return Winding.CLOCKWISE;
			}
			if (signedDoubleA > 0)
			{
				return Winding.COUNTERCLOCKWISE;
			}
			return Winding.NONE;
		}
		
		private static function signedDoubleArea():Number
		{
			var index:uint, nextIndex:uint;
			var n:uint = _vertices.length;
			var point:PointVX, next:PointVX;
			var signedDoubleArea:Number = 0;
			for (index = 0; index < n; ++index)
			{
				nextIndex = (index + 1) % n;
				point = _vertices[index] as PointVX;
				next = _vertices[nextIndex] as PointVX;
				signedDoubleArea += point.x * next.y - next.x * point.y;
			}
			return signedDoubleArea;
		}
	}
}