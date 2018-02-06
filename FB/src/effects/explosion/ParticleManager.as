package effects.explosion
{
	import idv.cjcat.stardust.twoD.zones.CircleZone;
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.counters.Blast;
	import org.flintparticles.common.easing.Quadratic;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.twoD.actions.TweenToZone;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.Position;
	import org.flintparticles.twoD.renderers.PixelRenderer;	
	import org.flintparticles.twoD.zones.BitmapDataZone;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.utils.setTimeout;
	import flash.filters.BlurFilter;
	import org.flintparticles.common.actions.*;
	import org.flintparticles.common.counters.*;
	import org.flintparticles.common.easing.Quadratic;
	import org.flintparticles.common.events.EmitterEvent;
	import org.flintparticles.common.initializers.*;
	import org.flintparticles.twoD.actions.*;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.*;
	import org.flintparticles.twoD.renderers.*;
	import org.flintparticles.twoD.zones.*;
	import flash.geom.ColorTransform;
	import org.flintparticles.common.displayObjects.Rect;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	public class ParticleManager{
	
		public static const OUT:uint = 0;
		public static const IN:uint = 1;
		public var flintImage:BitmapData;
		public var startEmitter:Emitter2D = new Emitter2D();
		public var renderer:PixelRenderer;
		public var flintTarget:*;
		public var defaultParams:Object = {
			colors:[0xFFFFFF00, 0xCC6600],
			direction:OUT
		}
		
		public function ParticleManager(target:*,params:Object = null){
			if (params) {
				for (var itm:* in params) {
					defaultParams[itm] = params[itm];
				}
			}
			flintTarget = target;
			var colors:Array = defaultParams.colors;
			//[0xFFFFFF00, 0xCC6600];
			if (target.hasOwnProperty('type') && target.type == 'Animal') {
				colors = [0xFF0000, 0xDD9900];
			}
			if (target.hasOwnProperty('type') && target.type == 'Box') {
				colors = [0x3a53a3, 0xcc66ff];
			}
			flintImage = new BitmapData(flintTarget.width, flintTarget.height, true, 0xffffff);
			var rct:Rectangle = flintTarget.parent.getRect(flintTarget);
			flintImage.draw(flintTarget,new Matrix( 1,0,0, 1,-target.dx,-target.dy));
			var wd:int = flintImage.width;
			var ht:int = flintImage.height;

			startEmitter = new Emitter2D();
			startEmitter.counter = new Blast( 1000 );

			var fbd:BitmapData = new BitmapData(wd,ht,true,0xffffff);
			fbd.draw(new Bitmap(flintImage));
			var scale:Number = 0.3;
			var matrix:Matrix = new Matrix( 1, 0, 0, 1, target.dx * scale, target.dy * scale);
			matrix.scale(scale, scale);
			var smallBMD:BitmapData = new BitmapData(fbd.width * scale, fbd.height * scale, true, 0x000000);
			smallBMD.draw(fbd, matrix, null, null, null, true);
			
			startEmitter.addInitializer( new ColorInit( colors[0], colors[1] ) );
			startEmitter.addInitializer( new Lifetime( 1.8 ) );
			if(defaultParams.direction == OUT){
				startEmitter.addInitializer( new Position( new BitmapDataZone( flintImage, 0,0)));
				startEmitter.addInitializer( new Velocity( new BitmapDataZone( smallBMD, 0, 0 )));
			}
			
			if (defaultParams.direction == IN) {
				startEmitter.addInitializer(new Position(new DiscZone( new Point(0, 0), 100, 5)));
				//startEmitter.addInitializer( new Velocity( new BitmapDataZone( smallBMD, 0, 0)));
				startEmitter.addAction(new TweenToZone(new BitmapDataZone(flintImage,40,60)));
			}
			//startEmitter.addInitializer(new Velocity(new DiscZone( new Point(0,0),200,50)));

			startEmitter.addAction( new Age( Quadratic.easeIn ) );
			startEmitter.addAction(new TargetScale(1, 1) );
			startEmitter.addAction(new Move());
			startEmitter.addAction(new Fade());
			startEmitter.addAction(new LinearDrag(0.8)); 
			if (defaultParams.direction == IN) {
				startEmitter.addAction(new Accelerate(5,5));
			}else {
				
				startEmitter.addAction(new Accelerate(0,10));
			}
			var renderer:PixelRenderer = new PixelRenderer( new Rectangle(-200,-200,400,500 /*-2*wd, -ht, 3*wd, 3*ht*/) );
			renderer.name = 'rend';
			renderer.addFilter( new BlurFilter( 8.0, 8.0, 3 ) );
			renderer.addFilter( new ColorMatrixFilter( [ 1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.97,0 ] ) );
			renderer.addEmitter( startEmitter );
			var crds:Point;
			//crds = new Point(flintTarget.x + flintTarget.dx, flintTarget.y + flintTarget.dy);
			crds = new Point(flintTarget.dx,flintTarget.dy);
			renderer.x = crds.x;
			renderer.y = crds.y;
			flintTarget.addChild( renderer );
		}
		
		public function explosion(lightEffect:Boolean, callback:Function = null):void {
			flintTarget.mouseEnabled = false;
			if (flintTarget['clickable']) {
				flintTarget['clickable'] = false;
			}
			if (flintTarget['touchable']) {
				flintTarget['touchable'] = false;
			}
			flintTarget.filters = [];
			var cb:Function = function():void{
				flintTarget.parent.removeChild(flintTarget);
			}
			if(callback!=null){
				cb = callback;
			}
			var maxVal:int = 8;
			var stepVal:Number = 0.1;
			var i:int = 0;
			var ftarg:* = flintTarget;
			var ch:int = 0;
			var chItem:*;
			if(lightEffect){

				var iId:int = setInterval(function():void{
						var vl:Number = 1+(stepVal*i*i)/maxVal;
						if(vl>maxVal){
							clearInterval(iId);
							startEmitter.start();
							flintTarget.mouseEnabled = false;
							for (ch = 0; ch < flintTarget.numChildren; ch++) {
								chItem = flintTarget.getChildAt(ch);
								if(chItem.name != 'rend')
								chItem.visible = false;
							}
							startEmitter.addEventListener( EmitterEvent.EMITTER_EMPTY,
								function():void{
									startEmitter.stop();
									if(ftarg.getChildByName('rend'))
									ftarg.removeChild(ftarg.getChildByName('rend'));
									startEmitter = null;
									renderer = null;
									cb();
								},false, 0, true );
						}else{
							flintTarget.transform.colorTransform = new ColorTransform(vl,vl,vl/3);
							i++;
						}
					},30);
			}else {
				startEmitter.start();
				
				for (ch = 0; ch < flintTarget.numChildren; ch++) {
					chItem = flintTarget.getChildAt(ch);
					if(chItem.name != 'rend')
					chItem.visible = false;
				}
				startEmitter.addEventListener( EmitterEvent.EMITTER_EMPTY,
				function():void {
					startEmitter.stop();
					if(ftarg.getChildByName('rend'))
					flintTarget.removeChild(ftarg.getChildByName('rend'));
					startEmitter = null;
					renderer = null;
					cb();
				},false, 0, true );
			}
		}
	}
}