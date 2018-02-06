package ui
{
	import buttons.Button;
	import core.BDTransformer;
	import flash.events.MouseEvent;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import wins.Window;
	
	public class BoostTool extends LayerX
	{
		public static const PRODUCTION_BOOSTER:int = 1549;
		
		public var callBack:Function = null;
		public var itemsLeftLabel:TextField;
		public var sID:int = 0;
		public function BoostTool(sID:int,callBack:Function ):void
		{
			this.callBack = callBack;
			this.sID = sID;
			
			draw();
		}
		
		public function draw():void 
		{
			var bg:Bitmap = new Bitmap(Window.textures.questIconBacking);
			var item:Object = App.data.storage[App.data.storage[sID]['mboost']];
			var timeVal:String = TimeConverter.timeToCuts(item.time,true,true);
			var title:String = Locale.__e("flash:1445610117635") + "\n" + timeVal;//Сэкономить
			var titleParams:Object = {
					textAlign:'center',
					fontSize:20,
					width:90,
					color:0xfbee8e,
					borderColor:0x5b1b00,
					multiline:true,
					wordWrap:true
				};
			tip = function():Object {
				return {
					title:item.title,
					text:item.description
				};
			}
			var upLabel:TextField = Window.drawText(title, titleParams);
			upLabel.width = upLabel.textWidth + 5;
			upLabel.x = (bg.width - upLabel.width) / 2;
			upLabel.y = -upLabel.textHeight * 0.3;
			
			var boosterCount:int = App.user.stock.count(item.sID);
			var itemsLeft:String = Locale.__e('flash:1393581955601') + ": " + boosterCount;//Осталось:
			var leftParams:Object = {
					textAlign:'center',
					width:bg.width,
					fontSize:20,
					color:0xfffff3,
					borderColor:0x201766,
					multiline:true
				};
			
			itemsLeftLabel = Window.drawText(itemsLeft, leftParams);
			itemsLeftLabel.y = 135;
			updateCount();
			var useBttn:Button;
			var that:BoostTool = this;
			var bttnParams:Object = {
					caption:Locale.__e('flash:1445610244035'),//Активировать
					fontSize:20,
					width:110,
					height:40,
					radius:30
				};
			useBttn = new Button(bttnParams);
			useBttn.x = (bg.width - useBttn.width) / 2;
			useBttn.y = 97;
			
			addChild(bg);
			addChild(upLabel);
			addChild(itemsLeftLabel);
			
			useBttn.addEventListener(MouseEvent.CLICK, function():void {
						useBttn.state = Button.DISABLED;
						that.callBack(
							function():void {
								useBttn.state = Button.NORMAL;
							}
						);
					});
			addChild(useBttn);
			
			Load.loading(Config.getIcon(item.type, item.view), function(data:Bitmap):void {
				var dataBm:Bitmap = new Bitmap(BDTransformer.fitIn(data.bitmapData,75,75));
				addChild(dataBm);
				dataBm.x = (bg.width - dataBm.width) / 2;
				dataBm.y = (bg.height - dataBm.height) / 2;
			});
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, function(e:AppEvent):void {
				if (!that.parent) {
					App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, arguments.callee);
					return;
				}
				updateCount();
			});
		}
		
		private function get boosterSid():int 
		{
			var item:Object = App.data.storage[App.data.storage[sID]['mboost']];
			return item['sID'];
		}
		
		private function updateCount():void 
		{
			var boosterCount:int = App.user.stock.count(boosterSid);
			var fStyle:TextFormat = itemsLeftLabel.getTextFormat();
			var f:*;
			var flt:Array = [];
			var tempClowfilter:*;
			var filtColor:int;
			if (!boosterCount) {
				fStyle.color = 0xcc0000;
				filtColor = 0x440000;
			}else {
				fStyle.color = 0xfffff3;
				filtColor = 0x201766;
			}
			
			if (itemsLeftLabel.filters.length) {
				flt = itemsLeftLabel.filters;
				itemsLeftLabel.filters = [];
				for each(f in flt){
					if(f is GlowFilter){
						tempClowfilter = f;
						tempClowfilter.color = filtColor;
					}
				}
				itemsLeftLabel.filters = flt;
			}
			var itemsLeft:String = Locale.__e('flash:1445610387468',String(boosterCount));//Осталось: %s
			itemsLeftLabel.text = itemsLeft;
			itemsLeftLabel.setTextFormat(fStyle);
		}
	}	
}