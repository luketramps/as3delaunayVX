package com.nodename.geom
{
	import com.luketramps.vorox.data.PointVX;

	// Lukes Mod. Using Polygon2 instead.
	public final class Polygon
	{
		private var _vertices:Vector.<PointVX>;

		public function Polygon(vertices:Vector.<PointVX>)
		{
			_vertices = vertices;
		}

		public function area():Number
		{
			return Math.abs(signedDoubleArea() * 0.5);
		}

		public function winding():Winding
		{
			var signedDoubleArea:Number = this.signedDoubleArea();
			if (signedDoubleArea < 0)
			{
				return Winding.CLOCKWISE;
			}
			if (signedDoubleArea > 0)
			{
				return Winding.COUNTERCLOCKWISE;
			}
			return Winding.NONE;
		}

		private function signedDoubleArea():Number
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