/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2010
 * http://flintparticles.org
 * 
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.flintparticles.twoD.particles 
{
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.common.particles.ParticleFactory;	
	

	/**
	 * The ParticleCreator is used by the Emitter class to manage the creation and reuse of particles.
	 * To speed up the particle system, the ParticleCreator class maintains a pool of dead particles 
	 * and reuses them when a new particle is needed, rather than creating a whole new particle.
	 */

	public class ParticleCreator2D implements ParticleFactory
	{
		private var _particles:Array;
		/*
		private var particleCounterTotal:int = 0;
		private var particleCounterActive:int = 0;
		private var particleCounterStored:int = 0;
		*/
		private var particleStates:Array = new Array(); //index 0 is total, 1 is active, 2 is stored
		
		/**
		 * The constructor creates a ParticleCreator object.
		 */
		public function ParticleCreator2D()
		{
			_particles = new Array();
			particleStates[0] = 0;
			particleStates[1] = 0;
			particleStates[2] = 0;
		}
		
		/*
		*CCJ Here: I'd like to be able to poll this particle array such that I can
		*throttle the particle fountains 'manually' from code-- this way, I can ensure there
		*won't be more than 40 (two fountains worth) of particles created, AND I can
		*ensure that when something is hit and is supposed to shoot sparks it will shoot at least
		*a few!  End result is the user doesn't know anything is different from a naive
		*and greedy (put pretty) implementation, and his phone doesn't FUCKING BREAK due
		*to excessive memory allocation
		*/
		public function pollPool():int{
			return _particles.length; //preferred
		}
		public function pollPoolActive():int{
			return 0;
		}
		public function getPool():Array{
			return _particles; //may be used, but unlikely to be needed -- DO NOT CATCH THIS REFERENCE IN A NEW ARRAY OR YOU WILL DUPLICATE THE POOL!
		}
		public function getParticleState(i:int):int{
			return particleStates[i];
		}
		public function setParticleState(i:int,a:int):void{
			particleStates[i] = a;
		}
		public function setEachParticleState(a:int,b:int,c:int):void{
			particleStates[0] = a;
			particleStates[1] = b;
			particleStates[2] = c;
		}
		/*
		public function getParticleCounterTotal():int{
			return particleCounter;
		}
		public function setParticleCounterTotal(i:int){
			this.particleCounter = i;
		}
		public function getParticleCounterActive():int{
			return particleCounter;
		}
		public function setParticleCounterActive(i:int){
			this.particleCounter = i;
		}
		public function getParticleCounterStored():int{
			return particleCounter;
		}
		public function setParticleCounterStored(i:int){
			this.particleCounter = i;
		}
		*/
		/**
		 * Obtains a new Particle object. The createParticle method will return
		 * a dead particle from the poll of dead particles or create a new particle if none are
		 * available.
		 * 
		 * @return a Particle object.
		 */
		public function createParticle():Particle
		{
			trace("total particles: " + particleStates[0] + "active particles: " + particleStates[1] + "stored particles: " + particleStates[2]);
			if ( _particles.length )
			{
				//particleCounterActive++;
				particleStates[1]++;
				return _particles.pop();
			}
			else
			{
				//particleCounterTotal++;
				particleStates[0]++;
				return new Particle2D();
			}
		}
		
		/**
		 * Returns a particle to the particle pool for reuse
		 * 
		 * @param particle The particle to return for reuse.
		 */
		public function disposeParticle( particle:Particle ):void
		{
			if( particle is Particle2D )
			{
				particle.initialize();
				_particles.push( particle );
				particleStates[2]++;
			}
		}

		/**
		 * Empties the particle pool.
		 */
		public function clearAllParticles():void
		{
			/*
			particleCounterTotal = 0;
			particleCounterActive = 0;
			particleCounterStored = 0;
			*/
			particleStates[0] = 0;
			particleStates[1] = 0;
			particleStates[2] = 0;
			_particles = new Array();
		}
	}
}
