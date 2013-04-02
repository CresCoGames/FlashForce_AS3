package 
{
	 import org.flintparticles.common.actions.Age;
  import org.flintparticles.common.actions.Fade;
  import org.flintparticles.common.counters.Blast;
  import org.flintparticles.common.displayObjects.Dot;
  import org.flintparticles.common.energyEasing.Quadratic;
  import org.flintparticles.common.events.EmitterEvent;
  import org.flintparticles.common.initializers.ColorInit;
  import org.flintparticles.common.initializers.Lifetime;
  import org.flintparticles.common.initializers.SharedImage;
  import org.flintparticles.twoD.actions.Accelerate;
  import org.flintparticles.twoD.actions.LinearDrag;
  import org.flintparticles.twoD.actions.Move;
  import org.flintparticles.twoD.emitters.Emitter2D;
  import org.flintparticles.twoD.initializers.Velocity;
  import org.flintparticles.twoD.zones.DiscZone;
  import org.flintparticles.twoD.zones.DiscSectorZone;
 
  import flash.geom.Point;
  



	public class Particles extends Emitter2D

	{
		

		public function Particles(yHit:Number)//renderer:DisplayObject,xHit:Number,yHit:Number)
		{
			 counter = new Blast( 50 );
      
      		addInitializer( new SharedImage( new Dot( 2 ) ) );
			if (yHit > 50){
     			addInitializer( new ColorInit( 0xFFFFFF00, 0xFFFF6600 ) );
				addInitializer( new Velocity( new DiscSectorZone( new Point( 0, 0 ), 100, 20,-3,0 ) ) );
			}
			else{
				addInitializer( new ColorInit( 0x000000FF, 0x009900FF ) );
				addInitializer( new Velocity( new DiscSectorZone( new Point( 0, 0 ), 100, 20,0,3 ) ) );
			}
      		//addInitializer( new Velocity( new DiscSectorZone( new Point( 0, 0 ), 100, 20,0,3 ) ) );
      		addInitializer( new Lifetime( 1 ) );
      
      		addAction( new Age( Quadratic.easeIn ) );
      		addAction( new Move() );
      		addAction( new Fade() );
      		addAction( new Accelerate( 0, 50 ) );
      		addAction( new LinearDrag( 0.5 ) );
			
		}
		
		
	}

}