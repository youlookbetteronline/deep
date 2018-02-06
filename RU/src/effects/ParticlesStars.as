package effects
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class ParticlesStars extends Sprite
	{
		public var deleted:Boolean = false;
		//
		private var timeToLive:Number;
		private var timeElapsed:Number;
		private var particles:Array;
		private var onComplete:Function;
		private var completed:Boolean;
		
		// Variable params
		private var starsCount:int = 20;
		private var vector:Point = new Point(20, -13);
		private var gravity:Number =1.2;
		private var friction:Number = .85;
		private var lifeTime:Number = 3;
		private var completeTime:Number = 0.3;
		private var rotationDecr:Number = 20;
		private var alphaDecr:Number = 0.02;
		private var scaleDecr:Number = 0.04;
		private var startScale:Number = 1.5;
		
		private var elTime:Number = 0.1;
		private var moveY:Number = -28;
		
		private var color:Object = { 
			0:0x2d5f2d,
			1:0xffffff,
			2:0x9d9bf4,
			3:0x3bf4e5,
			4:0x0bd45b,
			5:0xa3fe71,
			6:0xfff665,
			7:0xff4359,
			8:0x67dde4,
			9:0xf4724a,
			10:0x0d08d4
		};
		
		//
		public function ParticlesStars(xx:Number,yy:Number, onCompleteLoc:Function = null, _params:Object = null) 
		{
			x = xx; y = yy; onComplete = onCompleteLoc;
			timeToLive = Number(1);
			mouseEnabled = false; // not interact with mouse
			mouseChildren = false; // not interact with mouse
			var particlesArray:Array = ['particle_b1', 'particle_b2', 'particle_b1', 'particle_b2', 'particle_s1', 'particle_s2', 'particle_s3'];
			if (_params && _params.hasOwnProperty('particleTextures'))
				particlesArray = _params['particleTextures'];
			
			particles = new Array();
			for (var i:int = 0; i < starsCount; i++) 
			{
				var numm:int = Math.random() * particlesArray.length;
				
				var tmpObj:Bitmap; 
				if (_params && _params.hasOwnProperty('particleTextures'))
					tmpObj = new Bitmap(particlesArray[numm]);
				else
					tmpObj = new Bitmap(Window.textures[particlesArray[numm]]);
				//var tmpObj:Bitmap = new spark();
				
				var circle:Sprite = new Sprite();
				var rnd:int = Math.random() * 10;
				var colorT:int = color[rnd];
				
				circle.graphics.beginFill(colorT);
				var radius:int = Math.random() * 6 + 6;
				circle.graphics.drawCircle(radius, radius, radius);
				circle.graphics.endFill();
				//addChild(circle);
				
				
				var sp:Sprite = new Sprite();
				sp.addChild(tmpObj);
				circle.x = -circle.width / 2;
				circle.y = -circle.height / 2;
				sp.scaleX = startScale;
				sp.scaleY = startScale;
				addChild(sp);
				var tmpPoint:Point = new Point(Math.floor(Math.random() * (20 - ( -20) + 1)) + ( -20), Math.random() *-10 - 15 );
				particles.push( { vx:tmpPoint.x, vy:tmpPoint.y, object:sp, live:0.0 } );
			}
		}
		
		private var counter:int = 0;
		private var countStars:int = 1;
		public function update():void {
			timeElapsed += elTime;
			updateFirst();
		}

		//----------------------------- Updaters ----------------------------//
		private function updateFirst():void 
		{
			for (var i:int = 0; i < particles.length; i++) 
			{
				particles[i].live += elTime;
				particles[i].object.x += particles[i].vx;
				particles[i].object.y += particles[i].vy;
				particles[i].vx *= friction;
				particles[i].vy += gravity;
				
				//moveY += 0.1;
				particles[i].vy += 0.5;
				//
				//particles[i].object.rotation += rotationDecr;
				//particles[i].object.alpha -= alphaDecr;
				particles[i].object.scaleX -= scaleDecr;
				particles[i].object.scaleY -= scaleDecr;
				// Check for die
				if (particles[i].live >= lifeTime) {
					if(particles[i].object.parent) removeChild(particles[i].object);
					particles.splice(i,1);
				}
			}
			if (!completed && timeElapsed >= completeTime) {
				if (onComplete != null) {
					onComplete();
				}
				completed = true;
			}
			if (!deleted && particles.length == 0) {
				del();
			}
		}
		///////////////////////////////////////////////////////////
		public function del():void {
			if (parent) 
				parent.removeChild(this);
			deleted = true;
		}
	}
}