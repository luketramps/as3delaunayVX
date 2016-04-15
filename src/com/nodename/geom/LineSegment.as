package com.nodename.geom
{
	import com.luketramps.vorox.data.PointVX;
	
	public final class LineSegment extends Object
	{
		public static function compareLengths_MAX(segment0:LineSegment, segment1:LineSegment):Number
		{
			var length0:Number = PointVX.distance(segment0.p0, segment0.p1);
			var length1:Number = PointVX.distance(segment1.p0, segment1.p1);
			if (length0 < length1)
			{
				return 1;
			}
			if (length0 > length1)
			{
				return -1;
			}
			return 0;
		}
		
		public static function compareLengths(edge0:LineSegment, edge1:LineSegment):Number
		{
			return - compareLengths_MAX(edge0, edge1);
		}

		public var p0:PointVX;
		public var p1:PointVX;
		
		public function LineSegment(p0:PointVX, p1:PointVX)
		{
			super();
			this.p0 = p0;
			this.p1 = p1;
		}
		
	}
}