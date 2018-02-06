package wins.elements 
{
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import silin.filters.ColorAdjust;
	import ui.UserInterface;
	import wins.Window;
	
	public class WorldItem extends LayerX 
	{
		public var container:LayerX;
		public var bg:Bitmap;
		public var bitmap:Bitmap;
		public var underTxt:Bitmap;
		public var title:TextField;
		public var sID:*;
		public var window:*;
		public var info:Object;
		public var scale:Number = 0;
		public var preloader:Preloader;
		public var available:Boolean = true;
		public var defFilters:Array;
		
		public var params:Object = {
			hasBacking:	false,
			hasTitle:	true,
			scale:		1,
			fontSize:	22,
			align:		'none',
			hasTitle:	true,
			jump:		true,
			info:		'',
			closed:		true,
			clickable:	true
		}
		public function get link():String {
			if (params.hasOwnProperty('link') && params.link.length > 0) {
				return params.link;
			}
			
			return Config.getIcon(info.type, info.preview);
		}
		
		public function WorldItem(params:Object) 
		{
			for (var s:String in params)
				this.params[s] = params[s];
			
			sID = this.params.sID;
			window = this.params.window;
			scale = this.params.scale;
			
			if (!App.data.storage.hasOwnProperty(sID)) return;
			
			draw();
		}
		public function draw():void {
			
			info = App.data.storage[sID];
			this.params.info = info.title;
			
			container = new LayerX();
			addChild(container);
			
			bg = new Bitmap(Window.textures.instCharBackingDisabled, 'auto', true);
			bg.scaleX = bg.scaleY = scale;
			bg.visible = this.params.hasBacking;
			container.addChild(bg);
			
			if (this.params.align == 'center') {
				bg.x = -bg.width / 2;
				bg.y = -bg.height / 2;
			}
			
			preloader = new Preloader();
			preloader.scaleX = preloader.scaleY = 0.5;
			preloader.x = bg.x + bg.width / 2;
			preloader.y = bg.y + bg.height / 2;
			addChild(preloader);
			
			bitmap = new Bitmap();
			container.addChild(bitmap);
			Load.loading(link, onLoad);
			
			if (!this.params.clickable) alpha = 0.5;
			if (this.params.hasTitle) drawDesc();
			defFilters = this.filters;
			container.addEventListener(MouseEvent.CLICK, onClick);
			container.addEventListener(MouseEvent.ROLL_OVER, onOver);
			container.addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		
		public function onClick(e:MouseEvent = null):void 
		{
			if (params.clickable == false) return;
			
			if (params.jump) jump();
			
			if (App.user.mode == User.OWNER && sID != App.map.id && App.user.worlds.hasOwnProperty(sID)) 
			{
				Travel.goTo(sID);
			}else if (App.user.mode == User.GUEST) 
			{
				Travel.friend = Travel.currentFriend;
				Travel.onVisitEvent(sID);
			}
		}
		public function onOver(e:MouseEvent):void {
			if (available) effect(0.1);
		}
		public function onOut(e:MouseEvent):void {
			if (available) effect();
		}
		public function effect(count:Number = 0, saturation:Number = 1):void 
		{
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(count);
			var filters:Array = defFilters.concat([mtrx.filter]);
			
			this.filters = filters;
		}
		
		public function onLoad(data:Bitmap):void {
			if (preloader && contains(preloader)) removeChild(preloader);
			
			bitmap.scaleX = bitmap.scaleY = scale * 0.98;
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = bg.x + (bg.width - bitmap.width) / 2;
			bitmap.y = bg.y + (bg.height - bitmap.height) / 2;
			bitmap.filters = [new DropShadowFilter(2, 90, 0, .5, 6, 6, 2)];
		}
		
		public function drawDesc(descParams:Object = null):void {
			
			if (!descParams) descParams = { };
			descParams['backingWidth'] = descParams['backingWidth'] || 160;
			
			title = Window.drawText(params.info, {
				fontSize	:params.fontSize,
				color		:0x7e3e13,
				border		:false,
				multiline	:true,
				wrap		:true,
				textAlign	:"center",
				width		:115
			});
			
			addChild(title);
			title.x = (bg.width - title.width) / 2;
			title.y = (bg.height - title.textHeight) / 2 - 3;
		}
		
		public function jump():void {
			var item:WorldItem = this;
			TweenLite.to(item, 0.4, { scaleX:1.1, scaleY:1.1, ease:Cubic.easeOut, onComplete:function():void {
				TweenLite.to(item, 0.4, { scaleX:1, scaleY:1, ease:Bounce.easeOut } );
			}} );
		}
		
		public function clearVariables():void {
			var self:* = this;
			var description:XML = describeType(this);
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
					continue;
				}
				var classType:Class
				try{
					classType = getDefinitionByName(variable.@type) as Class;
				}catch (e:Error){
					self[variable.@name] = null;
					continue;
				}
				switch(classType){
					case Sprite:
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						break;
					default:
						self[variable.@name] = null;
				}
			}
		}
		
		public function dispose():void {
			if (container) {
				container.removeEventListener(MouseEvent.CLICK, onClick);
				container.removeEventListener(MouseEvent.ROLL_OVER, onOver);
				container.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			}
			
			if (parent) parent.removeChild(this);
			//clearVariables();
		}
	}

}