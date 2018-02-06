package wins 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.utils.clearInterval;
	import units.Techno;
	
	/**
	 * ...
	 * @author 
	 */
	public class TechnoMaterialItem extends MaterialItem 
	{
		private var settings:Object = {};
		private var countColor:int;
		private var shadowColor:int;
		
		public function TechnoMaterialItem(settings:Object, bg:Bitmap=null) 
		{
			this.settings = settings;
			super(settings, bg);
			
			countColor = settings.countColor || 0xfef6e7;
			shadowColor = settings.shadowColor || 0x6d4115;
			
		}
		
		override protected function init():void
		{
			
			App.self.addEventListener(AppEvent.ON_CLOSE_BANK, onCloseBank);
			
			//background = Window.backing(150, 200, 10, "itemBacking");
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe6b685);
			backgroundShape.graphics.drawCircle(50, 50, 50);
			backgroundShape.graphics.endFill();
			
			background = new Bitmap(new BitmapData(100, 100, true, 0));
			background.bitmapData.draw(backgroundShape);
			//background = new Bitmap(Window.textures.bgItem);
			addChild(background);
			
			drawBitmap();
			//drawTitle();
			
			drawCount();
			//drawInfo();
			//drawBttns();
				
			
		}	
		
		override protected function drawTitle():void
		{
			title = Window.drawText(App.data.storage[sID].title, {
				color:titleColor,
				borderColor:titleBorderColor,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				color:0x000000,
				borderColor:0x000000,
				textLeading: -6,
				multiline:true
			});
			
			title.wordWrap = true;
			title.width = background.width - 4;
			title.y = background.y - title.height/2 + 10;
			title.x = (background.width - title.width) / 2;
			//Size.fitImtoTextField(title);
			addChild(title)
		}
		
		override public function changeOnREADY():void
		{
			clearInterval(intervalPluck);
			
			status = MaterialItem.READY;
			if(App.data.storage[sID].type == 'Techno'){
				count = Techno.freeTechnoBySID(sID).length;
			}
			setText("count", count);
			
			var filter:GlowFilter = new GlowFilter(shadowColor, 1, 4, 4, 2, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90, shadowColor,1,1,1,6,1);
			count_txt.filters 	= [filter,shadowFilter];
			vs_txt.filters 		= [filter,shadowFilter];
			need_txt.filters 	= [filter,shadowFilter];
			
			count_txt.textColor = countColor;
			vs_txt.textColor 	= countColor;
			need_txt.textColor 	= countColor;
			
			if(sID == Stock.FANTASY || sID == Stock.COINS || sID == Stock.FANT){
				count_txt.parent.removeChild(count_txt);
				vs_txt.parent.removeChild(vs_txt);
				need_txt.x = 0;
				countContainer.x = (background.width - countContainer.width) / 2;
			}
			
			countContainer.y = background.y + background.height;
		}
		
		override public function changeOnUNREADY():void
		{
			if(	App.data.storage[sID].type == 'Techno'){
				count = Techno.freeTechno().length;
			}
			setText("count", count);
			
			status = MaterialItem.UNREADY;
			var filter:GlowFilter = new GlowFilter(shadowColor, 1, 4, 4, 2, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1, 90, shadowColor, 1, 1, 1, 8, 1);
			
			if (!count_txt.parent || !vs_txt.parent) {
				countContainer.addChild(count_txt);
				countContainer.addChild(vs_txt);
				refreshCountPosition();
			}
			
			count_txt.filters 	= [filter, shadowFilter];
			vs_txt.filters 		= [filter, shadowFilter];
			need_txt.filters 	= [filter, shadowFilter];
			
			count_txt.textColor = countColor;
			vs_txt.textColor 	= countColor;
			need_txt.textColor 	= countColor;
			
			countContainer.y = background.y + background.height;
		}
		
		override public function drawCount():void
		{
			if (App.data.storage[sID].type != 'Techno') {
				count = App.user.stock.count(sID);
			}else {
				count = Techno.freeTechnoBySID(sID).length;
			}
			var textColor:int = 0;
			var borderColor:int = 0; 
			
			if (count >= need){
				textColor = 0xffffff;
				borderColor = 0x04497a;
			}else{
				textColor = 0xffffff;
				borderColor = 0xc42f07;
			}
			
			count_txt = Window.drawText(String(count),{
				fontSize		:26,
				color			:textColor,
				borderColor		:borderColor,
				autoSize:"left"
			});
			
			vs_txt = Window.drawText("/"+" ",{
				fontSize		:24,
				color			:textColor,
				borderColor		:borderColor,
				autoSize:"left"
			});
			
			need_txt = Window.drawText(String(need),{
				fontSize		:26,
				color			:textColor,
				borderColor		:borderColor,
				autoSize:"left"
			});							
			
			countContainer.addChild(count_txt);
			countContainer.addChild(vs_txt);
			countContainer.addChild(need_txt);
			
			countContainer.height = need_txt.textHeight;
			addChild(countContainer);
			refreshCountPosition()
		}
		
	}

}