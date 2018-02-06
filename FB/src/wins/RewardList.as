package wins
{
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	
	/**
	 * ...
	 * @author 
	 */
	public class RewardList extends Sprite 
	{
		public var bonus:Object;
		public var itemsSprite:Sprite = new Sprite();
		
		private  var marginX:int = 90;
		
		public var bg:Bitmap;
		
		private var bgAlpha:Number;
		
		private var arrItems:Array = [];
		private var numItems:int = 0;
		
		public function RewardList(bonus:Object, hasBacking:Boolean = true, widthBacking:int = 0, text:String = "", _alpha:Number = 1, _fontSze:int = 44, _titleY:int = 16, itemTxtSize:int = 56, preTxtItem:String = "", itemScale:Number = 0.74, marginItemTxtX:int = 0, marginItemTxtY:int = 0, colorText:uint = 0x5d3c03)
		{
			bgAlpha = _alpha;
			
			var title:TextField = Window.drawText(
				Locale.__e(text), 
				{
					fontSize	:_fontSze,
					color		:0xffffff,
					borderColor	:0x5d3c03,
					autoSize	:"left"
				}
			);
			
			for (var itm:* in bonus) {
				numItems++;
			}
			
			bg = Window.backingShort(475, "yellowRibbon");
			//bg.alpha = 0.5;
			if(hasBacking){
				addChildAt(bg, 0);
				bg.y = title.height + 5;
			}
			
			var i:int = 0;
			
			for (var sID:* in bonus) {
				var item:RewardItem = new RewardItem(sID, bonus[sID], setPosItems, itemTxtSize, preTxtItem, itemScale, marginItemTxtX, marginItemTxtY, colorText);
				itemsSprite.addChild(item);
				Size.size(item, 40,40);
				//item.scaleX = item.scaleY = 0.55;
				//item.x = (prevWidth) + xPos;
				//prevWidth = 60 + item.text.textWidth + 8;
				//xPos = item.x;
				i++;
				arrItems.push(item);
			}
			
			
			if (widthBacking == 0) {
				widthBacking = 10 + 100 * i;
			}
			
			addChild(itemsSprite);
			
			//itemsSprite.y = bg.y + (bg.height - itemsSprite.height) / 2 - 10;
			itemsSprite.y = bg.y + (bg.height - 50) / 2 - 10;
				
			title.x = (bg.width - title.width)/2;
			title.y = _titleY-5;
			addChild(title);
		}
		
		private var counter:int = 0;
		private function setPosItems():void 
		{
			counter += 1;
			if (counter < numItems) return;
			
			if (counter > arrItems.length) {
				counter -= 1;
				setTimeout(setPosItems, 100);
				return;
			}
			
			var xPos:int = 0;
			var prevWidth:int = 0;
			for (var i:int = 0; i < arrItems.length; i++ ) {
				arrItems[i].x = (prevWidth) + xPos;
				prevWidth = arrItems[i].width + 8;
				xPos = arrItems[i].x;
			}
			itemsSprite.x = (bg.width - itemsSprite.width) / 2;
		}
		
		private var rewardW:Bitmap;
		private function wauEffect():void {
			if (rewardW.bitmapData != null) {
				var rewardCont:Sprite = new Sprite();
				App.self.contextContainer.addChild(rewardCont);
				
				var glowCont:Sprite = new Sprite();
				glowCont.alpha = 0.6;
				glowCont.scaleX = glowCont.scaleY = 0.5;
				rewardCont.addChild(glowCont);
				
				var glow:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow.x = -glow.width / 2;
				glow.y = -glow.height + 90;
				glowCont.addChild(glow);
				
				var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow2.scaleY = -1;
				glow2.x = -glow2.width / 2;
				glow2.y = glow.height - 90;
				glowCont.addChild(glow2);
				
				var bitmap:Bitmap = new Bitmap(new BitmapData(rewardW.width, rewardW.height, true, 0));
				bitmap.bitmapData = rewardW.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				rewardCont.addChild(bitmap);
				
				//rewardCont.x = layer.x + bodyContainer.x /*+ this.rewardCont.x*/;
				//rewardCont.y = layer.y + bodyContainer.y /*+ this.rewardCont.y*/;
				
				function rotate():void {
					glowCont.rotation += 1.5;
				}
				
				App.self.setOnEnterFrame(rotate);
				
				TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
					setTimeout(function():void {
						App.self.setOffEnterFrame(rotate);
						glowCont.alpha = 0;
						var bttn:* = App.ui.bottomPanel.bttnMainStock;
						var _p:Object = { x:bttn.x + App.ui.bottomPanel.mainPanel.x, y:bttn.y + App.ui.bottomPanel.mainPanel.y};
						SoundsManager.instance.playSFX('takeResource');
						TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
							TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {}} );
						}} );
					}, 3000)
				}} );
			}
		}
		
		
		public function take():void{
			var childs:int = itemsSprite.numChildren;
			if (User.inExpedition) {
				return
			}
			
			for (var k:int = arrItems.length-1; k >= 0; k--) {
					
				if (AmuletWindow.checkAmuletPart(arrItems[k].sID)) {
					Load.loading(Config.getIcon(App.data.storage[arrItems[k].sID].type, App.data.storage[arrItems[k].sID].preview), function(data:Bitmap):void {
						//rewardCont.removeChild(preloader);
						//preloader = null;
						rewardW = new Bitmap;
						rewardW.bitmapData = data.bitmapData;
						
						/*if (reward.width > rewardBacking.width - 20) {
							reward.width = rewardBacking.width - 20;
							reward.scaleY = reward.scaleX;
						}
						if (reward.height > rewardBacking.height - 20) {
							reward.height = rewardBacking.height - 20;
							reward.scaleX = reward.scaleY;
						}*/
						wauEffect()
						arrItems.splice(k, 1);
						k--;
					});	
				}
			}
			
			//while (childs--) {
			for (var i:int = 0; i < arrItems.length; i++ ) {
				
				var reward:RewardItem = arrItems[i];//itemsSprite.getChildAt(childs) as RewardItem;
				
				if (App.data.storage[reward.sID].type == 'Animal' && App.user.stock.check(reward.sID, reward.count)) {
					var rel:Object = { };
					rel[reward.sID] = reward.sID;
					for (var j:int = 0; j < reward.count; j++ ) {
						var position:Object = App.map.heroPosition;
							var unit:Unit = Unit.add( { sid:reward.sID, id:0, x:position.x, z:position.z, rel:rel } );
								(unit as WorkerUnit).born();
								
							unit.stockAction( { sid:reward.sID } );
					}
				}else{
					var item:BonusItem = new BonusItem(reward.sID, reward.count);
					var point:Point = Window.localToGlobal(reward);
					item.cashMove(point, App.self.windowContainer);
				}
			}
		}
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class RewardItem extends Sprite
{
	private var icon:Bitmap;
	public var text:TextField;
	public var sID:uint;
	public var count:int;
	public var bg:Bitmap;
	
	public var sprTip:LayerX = new LayerX();
	
	private var callBack:Function;
	
	private var iconScale:Number;
	private var marginTxtX:int;
	private var marginTxtY:int;
	private var colorText:uint;
	
	public function RewardItem(sID:uint, count:int, _callBack:Function, _size:int = 56, _preText:String = "", iconScale:Number = 0.74, marginTxtX:int = 0, marginTxtY:int = 0, colorText:uint = 0x5d3c03)
	{
		this.marginTxtX = marginTxtX;
		this.marginTxtY = marginTxtY;
		this.iconScale = iconScale;
		this.colorText = colorText;
		
		icon = new Bitmap();
		this.sID = sID;
		this.count = count;
		callBack = _callBack;
		
		bg = Window.backing(90, 90, 12, "bonusBacking");
		addChild(bg);
		bg.visible = false;
		
		text = Window.drawText(_preText + String(count),{
			fontSize:_size,
			color	:0xffffff,
			borderColor	:colorText,
			autoSize:"left"
		});
			
		text.height = text.textHeight;
		text.width = text.textWidth;
			
		if (contains(sprTip)) {
			removeChild(sprTip);
			sprTip = new LayerX();
		}
		
		sprTip.addChild(icon);
		addChild(sprTip);
		
		sprTip.tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].text
			}
		}
		
		text.visible = false;
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
	}
	
	private function onLoad(data:Bitmap):void
	{
		icon.bitmapData = data.bitmapData;
		icon.scaleX = icon.scaleY = iconScale;
		icon.smoothing = true;
		
		
		
		if (icon.width > bg.height) {
			icon.scaleX = icon.scaleY = 100/(icon.width);
		}
			
		if (icon.height > bg.height + 25 ) {
			icon.height =  bg.height + 25;
			icon.scaleX = icon.scaleY;
		}
		
		
		//icon.x = (bg.width - icon.width) / 2;
		icon.y = (bg.height - icon.height) / 2;
		
		text.y = (bg.height - text.height) / 2 + marginTxtY;
		text.x = icon.x + icon.width + 8 + marginTxtX;
		text.visible = true;
		
		//addChild(icon);
		addChild(text);
		
		callBack();
	}
}