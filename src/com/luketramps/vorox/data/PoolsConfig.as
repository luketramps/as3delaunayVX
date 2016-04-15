package com.luketramps.vorox.data 
{
	/**
	 * Used to initialise Pools.
	 * @author Lukas Damian Opacki
	 */
	public class PoolsConfig 
	{
		
		/**
		 * Vorox only.
		 */
		public function get fixed():Boolean
		{
			return false;
		}
		
		/**
		 * Max amount of PointVX instances.
		 */
		public var pointPoolSize:uint = 200;
		
		/**
		 * Max amount of Vector.<PointVX> instances.
		 */
		public var vecPointPoolSize:uint = 10;
		
		/**
		 * Max amount of Vector.<Edge> instances.
		 */
		public var vecEdgePoolSize:uint = 10;
		
		/**
		 * Max amount of Vector.<Boolean> instances.
		 */
		public var vecBoolPoolSize:uint = 10;
		
		/**
		 * Max amount of Edge instances.
		 */
		public var edgePoolSize:uint = 10;
		
		/**
		 * Max amount of Dictionary instances.
		 */
		public var dictPoolSize:uint = 10;
		
		/**
		 * Max amount of Vector.<LR> instances.
		 */
		public var vecLrPoolSize:uint = 10;
		
		/**
		 * Max amount of Halfedge instances.
		 */
		public var halfeedgePoolSize:uint = 10;
		
		/**
		 * Max amount of Vector.<Halfedge> instances.
		 */
		public var vecHalfedgePoolSize:uint = 10;
		
		/**
		 * Max amount of Vector.<Vertex> instances.
		 */
		public var vecVertexPoolSize:uint = 10;
		
		public function PoolsConfig() 
		{
		}
		
	}

}