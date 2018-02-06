package units 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class Anime2Golden extends Anime2 
	{
		
		private var index:int;
		private var preIndex:int = -1;
		private var stopCount:int = 5;
		public function Anime2Golden(swf:*, params:Object=null) 
		{
			super(swf, params);
		}
		
		override protected function updateAnim(e:Event = null):void 
		{
			var animFrame:Object;
			if (index > -1) 
			{
				if (animes.length <= index) return;
				
				animInfo[frameTypes[index]].show = animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame];
				if (animInfo[frameTypes[index]].show == undefined) animInfo[frameTypes[index]].show = 0;
				
				if (params.animal || params.type == 'Walkgolden' || params.type == 'Walkhero'|| params.type == 'Animal'|| params.type == 'Picker') {
					animFrame = textures.animation.animations[frameTypes[index]].frames[0][animInfo[frameTypes[index]].show];
				}else {
					animFrame = textures.animation.animations[frameTypes[index]].frames[animInfo[frameTypes[index]].show];
				}
				if (preIndex != -1)
				{
					animes[preIndex].bitmapData = null;
					preIndex = -1;
				}
				animes[index].bitmapData = animFrame.bmd;
				animes[index].smoothing = true;
				animes[index].x = animFrame.ox + ax - bounds.x;
				animes[index].y = animFrame.oy + ay - bounds.y;
				
				animInfo[frameTypes[index]].frame++;
				if (animInfo[frameTypes[index]].frame >= animInfo[frameTypes[index]].chain.length-1)
				{
					animInfo[frameTypes[index]].frame = 0;
					getAnimType();
				}
			}
		}
		
		private function getAnimType():void
		{
			if (frameTypes.indexOf('walk') == index && frameTypes.indexOf('stop_pause') != -1)
			{
				preIndex = index;
				index = frameTypes.indexOf('stop_pause');
				stopCount = 3 + Math.random() * 5;
				return;
			}
			
			if (frameTypes.indexOf('stop_pause') == index && frameTypes.indexOf('rest') != -1)
			{
				stopCount--;
				if (stopCount <= 0)
				{
					preIndex = index;
					index = frameTypes.indexOf('rest');
					stopCount = 3+Math.random()*5;
				}
				return;
			}
			
			if (frameTypes.indexOf('rest') == index)
			{
				preIndex = index;
				index = frameTypes.indexOf('stop_pause');
				return;
			}
		}
		
	}

}