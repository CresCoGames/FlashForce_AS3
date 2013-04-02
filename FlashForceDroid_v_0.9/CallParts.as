/*

//DisplayObjectsPool2D Class:
package
{
import flash.display.DisplayObject;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;
import org.flintparticles.common.particles.Particle;
import org.flintparticles.twoD.particles.Particle2D;
import org.flintparticles.twoD.particles.ParticleCreator2D;


// Factory for creating Image for particles from pool.
// @author MihaPro

public class DisplayObjectsPool2D extends ParticleCreator2D
{
public var dict:Dictionary = new Dictionary;

public function DisplayObjectsPool2D()
{
}

override public function disposeParticle(particle:Particle):void
{
// ?????? ???????? ? ???
RecycleImage(Particle2D(particle));

super.disposeParticle(particle);
}

private function RecycleImage(p:Particle2D):void
{
var image_class:Class = p.image.constructor as Class;
var v:Vector.<*> = dict[image_class];
if (!v)
{
v = new Vector.<*>();
dict[image_class] = v;
}
v.push(p.image);
p.image = null;
}

public function GetImage(for_class:Class):*
{
var v:Vector.<*> = dict[for_class];
if (v && v.length) return v.pop();
return null;
}

public function Clear():void
{
dict = new Dictionary();
}
}

}

//PooledImageClass2D class:
package
{
import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.common.initializers.InitializerBase;
import org.flintparticles.common.particles.Particle;
import org.flintparticles.common.utils.construct;
import org.flintparticles.twoD.emitters.Emitter2D;


// Pooled image class.
// @author MihaPro

public class PooledImageClass2D extends InitializerBase
{
private var _imageClass:Class;
private var _parameters:Array;
protected var pool:DisplayObjectsPool2D;

public function PooledImageClass2D(_pool:DisplayObjectsPool2D, imageClass:Class, ...parameters)
{
pool = _pool;
_imageClass = imageClass;
_parameters = parameters;
}

override public function addedToEmitter(emitter:Emitter):void
{
super.addedToEmitter(emitter);
Emitter2D(emitter).particleFactory = pool;
}

override public function initialize(emitter:Emitter, particle:Particle):void
{
particle.image = pool.GetImage(_imageClass);
if(!particle.image) // if not in pool
particle.image = construct( _imageClass, _parameters );
}
}
}



//Usage:
var pool:DisplayObjectsPool2D = new DisplayObjectsPool2D();
...
emitter1.addInitializer(new PooledImageClass2D(pool, Dot, 1,16777215,"normal"));
...
emitter2.addInitializer(new PooledImageClass2D(pool, RadialDot));

*/


package
{
   import org.flintparticles.twoD.emitters.Emitter2D;
  import org.flintparticles.twoD.renderers.BitmapRenderer;

  import flash.display.Sprite;
  import flash.filters.BlurFilter;
  import flash.filters.ColorMatrixFilter;
  import flash.geom.Rectangle;
  import flash.events.TimerEvent;
  import flash.utils.Timer;




  //[SWF(width='400', height='400', frameRate='61', backgroundColor='#000000')]
  
  public class CallParts extends Sprite
  {
    private var emitter:Emitter2D;
	var shortTimer:Timer = new Timer(2000,1);
	var renderer:BitmapRenderer;
    
    public function CallParts(xHit:Number,yHit:Number) //CallParts will need to take in the coordinates of the ball's collision as parameters
    {

      emitter = new Particles(yHit);
      
      //var renderer:BitmapRenderer = new BitmapRenderer( new Rectangle( 0, 0, 500, 400 ) );
	  renderer = new BitmapRenderer( new Rectangle( 0, 50, 550, 450 ) );
      renderer.addFilter( new BlurFilter( 2, 2, 1 ) );
      renderer.addFilter( new ColorMatrixFilter( [ 1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.95,0 ] ) );
      renderer.addEmitter( emitter );
      addChild( renderer );
      
      emitter.x = xHit;
      emitter.y = yHit;
      emitter.start();
	  shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dieParts);
	  shortTimer.start();

    }
	public function dieParts(event:TimerEvent){
			this.removeChild(renderer)
			this.emitter = null;
			//shortTimer.reset();
			//shortTimer.start();
			this.parent.removeChild(this);
		}
  }
}
