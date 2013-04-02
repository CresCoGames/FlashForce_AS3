package  
{
	import flash.display.Sprite;
	
	import de.polygonal.core.ObjectPool;	

	public class Example extends Sprite
	{
		public function Example()
		{
			var i:int;
			
			var pool:ObjectPool = new ObjectPool(false);
			
			pool.allocate(100, MyClass);
			pool.initialze("init", []);
			
			var activeObjects:Array = [];
			
			//read the first object
			var o:MyClass = pool.object;
			
			activeObjects[0] = o;
			
			var k:int = pool.wasteCount; //99
			
			//read the remaining 99 objects
			for (i = 0; i < k; i++)
				activeObjects.push(pool.object);
			
			//wasteCount is now zero, but usageCount reports 100
			trace(pool.usageCount);
			
			try
			{
				//this will fail because the pool is now empty
				activeObjects.push(pool.object);
			}
			catch (e:Error)
			{
				trace(e);
			}
			
			k = pool.size;
			
			//give all objects back to the pool
			for (i = 0; i < k; i++)
				pool.object = activeObjects.shift();
				
			//usage count is zero
			trace(pool.usageCount);	
			
			//if you also assign a custom object factory
			pool.setFactory(new MyFactory());
			pool.allocate(100);
			
			trace(pool.object);
			
			//...same as above
		}
	}
}

internal class MyClass
{
	public function init(...args):void
	{
	}
}

import flash.geom.Point;

import de.polygonal.core.ObjectPoolFactory;

internal class MyFactory implements ObjectPoolFactory
{
	public function create():*
	{
		return new Point(); 
	}
}