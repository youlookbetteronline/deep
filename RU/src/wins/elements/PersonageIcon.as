package wins.elements 
{
	import buttons.SimpleButton;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class PersonageIcon extends SimpleButton
	{
		public var bg:Bitmap;
		
		public var sid:int;
		
		private var bitmap:Bitmap;
		
		private var progressCircle:Bitmap;
		private var maskProgress:Sprite;
		
		public var isBusy:Boolean = false;
		
		public var roomId:int;
		public var instanceId:int;
		
		public var isFocused:Boolean = false;
		
		private var attantion:Bitmap = null;
		private var attantionCont:Sprite = null;
		
		public function PersonageIcon(sid:int, settings:Object = null) 
		{
			this.sid = sid;
			
			setIds();
			
			drawBody();
			
			this.tip = function():Object {
				return {
					title:App.data.storage[sid].title
				}
			}
		}
		
		private function setIds():void
		{
			for (var ind:* in App.user.rooms ) {
				for (var pers:* in App.user.rooms[ind].pers) {
					
					/*for (var _sid:* in App.user.rooms[key].pers) {
							String(App.user.rooms[key].pers[_sid]).slice(0,String(App.user.rooms[key].pers[_sid]).search(":"));
							arrHeroesSids[String(App.user.rooms[key].pers[_sid]).slice(0, String(App.user.rooms[key].pers[_sid]).search(":"))] = uint(String(App.user.rooms[key].pers[_sid]).slice(String(App.user.rooms[key].pers[_sid]).search(":")+1,String(App.user.rooms[key].pers[_sid]).length ));
						App.user.countTechInInst++;
						}*/
					
					if (sid == App.user.rooms[ind].pers[pers]) {
						isBusy = true;
						roomId = ind;
						if (App.ui.upPanel) App.ui.upPanel.updatePersIcons();
						
						startTime = App.user.rooms[ind].time;
						endTime = App.data.storage[ind].time;
						//progress();
						App.self.setOnTimer(progress);
						break;
					}
				}
			}
			
			for (ind in App.data.storage) {
				if (App.data.storage[ind].type == 'Missionhouse') {
					for (var rm:* in App.data.storage[ind].rooms) {
						if (roomId == App.data.storage[ind].rooms[rm]) {
							instanceId = ind;
						}
					}
				}
			}
			
			if(instanceId > 0 && App.data.storage[instanceId].land != App.user.worldID){
				Post.send({
					ctr:'missionhouse',
					act:'lookin',
					uID:App.user.id,
					rID:roomId
				}, function(error:int, data:Object, params:Object):void
				{
					if (error) {
						Errors.show(error, data);
						return;
					}
					var friendsData:Object = data.friends;
					var count:int = 0;
					for (var fr:* in friendsData) {
						count++;
					}
					endTime -= App.data.storage[roomId].term * count;
				});
			}
			
		}
		
		public function update():void
		{
			isBusy = false;
			startTime = 0;
			endTime = 0;
			
			setIds();
			
			clearBody();
			
			drawBody();
		}
		
		private function drawBody():void 
		{
			
			bg = new Bitmap(Window.textures.charsStatusBacking);
			addChild(bg);
			
			if(isBusy){
				progressCircle = new Bitmap(Window.textures.characterProgressBar);
				addChild(progressCircle);
			}
			switch(App.data.storage[sid].preview) {
			case "boy":
				bitmap =  new Bitmap(Window.textures.charBoyIco);
				bitmap.scaleX = bitmap.scaleY = 0.5;
					bitmap.x = 12;
					bitmap.y = 1;
			break;
			case "girl":
			
			//this.filters = [mtrx.filter];
				bitmap =  new Bitmap(Window.textures.charGirlIco);
				bitmap.scaleX = bitmap.scaleY = 0.5;
					bitmap.x = 12;
					bitmap.y =2;
			break;
			case "slave":
				bitmap =  new Bitmap(Window.textures.charGirlIco);
				
				bitmap.scaleX *= -0.6;
					bitmap.scaleY = 0.6;
					bitmap.x = 48;
					bitmap.y = -7;
			break;
			default:
				bitmap =  new Bitmap(Window.textures.charGirlIco);
				bitmap.scaleX = bitmap.scaleY = 0.6;
					bitmap.x = 10;
					bitmap.y = 6;
		}
		
			bitmap.smoothing = true;
			//bitmap.scaleX = bitmap.scaleY = 0.9;
			addChild(bitmap);
			
			attantionCont = new Sprite();
			addChild(attantionCont);
			attantionCont.x = 42;
			attantionCont.y = 50;
			attantionCont.visible = false;
			
			attantion = new Bitmap(UserInterface.textures.attantion);
			attantion.smoothing = true;
			attantion.x = -attantion.width/2;
			attantion.y = -attantion.height;
			attantionCont.addChild(attantion);
		}
		
		public function drawSegment(startAngle:Number, endAngle:Number, segmentRadius:Number, xpos:Number, ypos:Number, step:Number, lineColor:Number, fillColor:Number):Sprite {
			var holder:Sprite = new Sprite();

			holder.graphics.lineStyle(2, lineColor);
			holder.graphics.beginFill(fillColor);

			var originalEnd:Number = -1;
			if(startAngle > endAngle){
				originalEnd = endAngle;
				endAngle = 360;
			}
			var degreesPerRadian:Number = Math.PI / 180;
			var theta:Number;
			startAngle *= degreesPerRadian;
			endAngle *= degreesPerRadian;
			step *= degreesPerRadian;


			holder.graphics.moveTo(xpos, ypos);
			for (theta = startAngle; theta < endAngle; theta += Math.min(step, (endAngle - theta))) {
				holder.graphics.lineTo(xpos + segmentRadius * Math.cos(theta), ypos + segmentRadius * Math.sin(theta));
			}
			holder.graphics.lineTo(xpos + segmentRadius * Math.cos(endAngle), ypos + segmentRadius * Math.sin(endAngle));

			if(originalEnd > -1){ 
				startAngle = 0;
				endAngle = originalEnd * degreesPerRadian;
				for (theta = startAngle; theta < endAngle; theta += Math.min(step, endAngle - theta)) {
				   holder.graphics.lineTo(xpos + segmentRadius * Math.cos(theta), ypos + segmentRadius * Math.sin(theta));
				}
				holder.graphics.lineTo(xpos + segmentRadius * Math.cos(endAngle), ypos + segmentRadius * Math.sin(endAngle));
			}
			holder.graphics.lineTo(xpos, ypos);
			holder.graphics.endFill();

			return holder;
		}
		
		public var startTime:int = 0;
		public var endTime:int = 0;
		public function updateTime(startTime:int, endTime:int):void
		{
			this.startTime = startTime;
			this.endTime = endTime;
		}
		
		public function startWork():void
		{
			
			App.self.setOffTimer(progress);
			progress();
			//App.ui.bottomPanel.removeTresure(instanceId);
			App.self.setOnTimer(progress);
		}
		
		public function progress():void
		{
			if (startTime == 0)
				return;
			
			if (maskProgress && contains(maskProgress)) removeChild(maskProgress);
			
			var percent:int = 0;
			
			var leftTime:int = startTime + endTime - App.time;
			if (leftTime < 0) leftTime = 0;
			
			percent = (endTime - leftTime) / endTime * 100;
			
			if (percent >= 100 || endTime == 0) {
				percent = 100;
			}else if (percent < 0) {
				percent = 0;
				return;
			}
			
			var posRadius:int = 270 - Math.round(3.6 * percent);
			
			if(bg){
				maskProgress = drawSegment(posRadius, 270, bg.height / 2 + 5, bg.width / 2, bg.width / 2, 2, 0xEEEEEE, 0x003da8);
				addChild(maskProgress);
				addChild(attantionCont);
			}
			if (progressCircle) {
				progressCircle.mask = maskProgress;
				progressCircle.visible = true;
			}
		}
		
		private var tweenAttantion:TweenLite;
		private var tweenAttantion2:TweenLite;
		private var tweenAttantion3:TweenLite;
		private var tweenCount:int = 0
		private function doAttantionEff():void 
		{
			tweenAttantion = TweenLite.to(attantionCont, 0.2, { rotation:10, /*ease:Elastic.easeIn,*/ onComplete:function():void {
			tweenAttantion2 = TweenLite.to(attantionCont, 0.4, { rotation:-10, /*ease:Back.easeInOut,*/ onComplete:function():void {
			tweenAttantion3 = TweenLite.to(attantionCont, 0.2, { rotation:0, /*ease:Elastic.easeOut,*/ onComplete:function():void {
				
				if (tweenCount == 0){
					doAttantionEff();
					tweenCount ++;
				}
				else {
					tweenCount = 0;
					setTimeout(doAttantionEff, 2000);
				}
			}} )}})}});
		}
		
		private function clearBody():void
		{
			if (tweenAttantion) tweenAttantion.kill();
			if (tweenAttantion2) tweenAttantion2.kill();
			if (tweenAttantion3) tweenAttantion3.kill();
			tweenAttantion = null;
			tweenAttantion2 = null;
			tweenAttantion3 = null;
			
			if (bg && contains(bg)) removeChild(bg);
			bg = null;
			
			if (progressCircle && contains(progressCircle)) removeChild(progressCircle);
			progressCircle = null;
			
			if (bitmap && contains(bitmap)) removeChild(bitmap);
			bitmap = null;
		}
		
		override public function dispose():void
		{
			App.self.setOffTimer(progress);
			
			if (tweenAttantion) tweenAttantion.kill();
			if (tweenAttantion2) tweenAttantion2.kill();
			if (tweenAttantion3) tweenAttantion3.kill();
			tweenAttantion = null;
			tweenAttantion2 = null;
			tweenAttantion3 = null;
			
			super.dispose();
		}
		
	}

}