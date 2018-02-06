package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import buttons.SimpleButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import wins.elements.OutItem;
	import wins.elements.SimpleItem;
	import wins.elements.UnlockItem;
	
	public class OpenZoneWindow extends Window
	{
		public static const OPEN_ZONE:uint = 1;
		public static const OPEN_WORLD:uint = 2;
		
		private var _items:Array = [];
		
		private var onUpgradeZoneGuide:Function;
		private var onBoostZoneGuide:Function;
		private var _applyBttn:Button;
		private var _whiteShape:Shape;
		
		public function OpenZoneWindow(settings:Object = null):void
		{
			if (settings == null)
				settings = new Object();
			
			settings["width"] = 510;
			settings["height"] = 420;
			settings["popup"] = true;
			settings["exitTexture"] = 'closeBttnMetal';
			settings['hasPaper'] = true;
			
			settings["title"] = Locale.__e("flash:1478095847335");
			settings["fontSize"] = 34;
			settings["fontColor"] = 0xffffff;
			settings["fontBorderColor"] = 0x156111;
			
			settings["hasPaginator"] = false;
			
			settings['sID'] = settings.sID || 0;
			
			settings["callback"] = settings["callback"] || null;
			settings["level"] = settings.level;
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onUpdateOutMaterial);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onUpdateOutMaterial);
		}
		
		override public function drawBody():void 
		{
			
			drawRibbon();
			drawBttn();
			contentChange();
			drawDescription();	
			onUpdateOutMaterial();
			build();
		}
		
		private function build():void 
		{
			
			exit.y -= 30;
			titleLabel.y += 12;
			
			contentContainer.x = (settings.width - contentContainer.width) / 2;
			//contentContainer.y = _whiteShape.y + (_whiteShape.height - _items[0].HEIGHT) / 2;
			contentContainer.y = 150;
		}
		
		override public function drawBackground():void
		{
			super.drawBackground();
			
			_whiteShape = new Shape();
			_whiteShape.graphics.beginFill(0xffffff,1);
			_whiteShape.graphics.drawRect(0, 0, settings.width - 160, 190);
			_whiteShape.graphics.endFill();
			_whiteShape.alpha = 0.5;
			_whiteShape.filters = [new BlurFilter(40, 0, 1)];
			
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 210, true, true, false, 1, 1, bodyContainer);
			var snailBitmap:Bitmap = new Bitmap(Window.textures.banksSnail);
			
			_whiteShape.x = (settings.width - _whiteShape.width) / 2;
			_whiteShape.y = 90;
			
			snailBitmap.x = - 60;
			snailBitmap.y = settings.height - snailBitmap.height - 20;
			
			bodyContainer.addChild(_whiteShape);
			bodyContainer.addChild(snailBitmap);
		}
		public function drawDescription():void {
			
			var descriptionLabel:TextField = Window.drawText(Locale.__e('flash:1382952380234'), {
				width		:settings.width - 150,
				fontSize	:28,
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x451c00,
				multiline	:true,
				wrap		:true
			});
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 20;
			
			bodyContainer.addChild(descriptionLabel);
		}
		
		
		override public function contentChange():void
		{	
			var offsetX:int = 0;
			var dX:int = 15;
			var count:int = 0;
			
			for (var sID:* in settings.require) 
			{
				if (App.data.storage[sID].type == "Zones") continue;
				var inItem:SimpleItem = new SimpleItem(sID, {
					count:{need:settings.require[sID]},
					//bg:{hasBg: false},
					item:{width:120, height:120},
					window:this
				});
				//inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				_items.push(inItem);
				
				inItem.x = offsetX;
				offsetX += inItem.WIDTH + dX;
				contentContainer.addChild(inItem);
				count++;
				
				//Window.showBorders(inItem);
			}
			
			if (App.user.quests.tutorial)
			{
				_applyBttn.showGlowing();
				_applyBttn.showPointing('bottom', 150, 55, _applyBttn.parent, '', null, false, true);
			}
			
			
			
			if (App.user.level < App.data.storage[settings.sID].level) {
				_applyBttn.mode = Button.ACTIVE;
			}
			if(inItem)
				inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
			bodyContainer.addChild(contentContainer);
		}
		
		private function drawBttn():void
		{
			_applyBttn = new Button({
				caption				:Locale.__e('flash:1382952379890'),
				width				:176,
				height				:56 ,
				fontSize			:32,
				radius				:20,
				bgColor				:[0xf5cf57, 0xeeb431],
				borderColor			:[0xbcbaa6,0xbcbaa6],
				bevelColor			:[0xfeee7b,0xbf7e1a],	
				fontColor			:0xffffff,
				fontBorderColor		:0x7f3d0e, 
				active: {
					bgColor			:[0xad9765,0xd1be88],
					borderColor		:[0x8b7a51,0x8b7a51],
					bevelColor		:[0x8b7a51,0xded4bf],	
					fontColor		:0xffffff,
					fontBorderColor :0x7a683c		
					}
			});
			_applyBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			_applyBttn.name = 'mission';
			_applyBttn.addEventListener(MouseEvent.CLICK, onOpenPlace);
			
			_applyBttn.x = (settings.width - _applyBttn.width) / 2;
			_applyBttn.y = settings.height - _applyBttn.height - 30;
			
			bodyContainer.addChild(_applyBttn);
		}
		
		private function removeItems():void 
		{
			for (var i:int = 0; i < _items.length; i ++ ) {
				var item:SimpleItem = _items[i];
				item.dispose();
				item.parent.removeChild(item);
				item = null;
			}
			_items.splice(0, _items.length);
		}
		
		private function onOpenPlace(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (onUpgradeZoneGuide != null)
			{
				onUpgradeZoneGuide();
				close();
				return
			}
			
			App.user.world.openZone(settings.sID, true);
			close();
		}
		
		public function onUpdateOutMaterial(e:* = null):void {
			if (App.user.stock.checkAll(settings.require))
				_applyBttn.state = Button.NORMAL
			else
				_applyBttn.state = Button.DISABLED
			
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onUpdateOutMaterial);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onUpdateOutMaterial);
			
			if (_applyBttn) {
				_applyBttn.removeEventListener(MouseEvent.CLICK, onOpenPlace);
				_applyBttn.dispose();
				_applyBttn = null;
			}
			
			removeItems();
			super.dispose();
		}
	}		
}