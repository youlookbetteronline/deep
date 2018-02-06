package buttons 
{
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import silin.filters.ColorAdjust;	
	
	public class MenuButton extends Button
	{
		public var _selected:Boolean = false;
		public var type:* = "";
		public var additionalBitmap:Bitmap
		/**
		 * Конструктор
		 * @param	settings	пользовательские настройки кнопки
		 */
		public function MenuButton(settings:Object = null)
		{
			settings['widthPlus'] = settings.widthPlus || 40;
			settings['width'] = settings.width || String(settings.title).length * 8 + settings.widthPlus//26;
			//settings['width'] = 110;
			settings['fontSize'] = settings.fontSize || 22;
			settings['height'] = settings.height || 42;
			settings['caption'] = settings.title;
			settings['textAlign'] = "center";			
			
			settings["bgColor"] = settings.bgColor || [0xade7f1, 0x91c8d5];
			settings["borderColor"] = settings.borderColor || [0xc2e2f4, 0x3384b2];
			settings["bevelColor"] = settings.bevelColor || [0xdbf3f3, 0x739dac];
			settings["fontColor"] = settings.fontColor || 0xfbfdfc;		
			settings["fontBorderColor"] = settings.fontBorderColor || 0x53828f;
			settings['active'] = settings.active || {
				bgColor:				[0x73a9b6,0x82cad6],
				bevelColor:				[0x739dac, 0xdbf3f3],
				borderColor:			[0xc27b45, 0xffc285],
				fontColor:				0xfbfdfc,
				fontBorderColor:		0x53828f				//Цвет обводки шрифта		
			}

		/*	if (settings.type == "all") {
				settings["bgColor"] = [0x80ea99, 0x6ba066];
				settings["borderColor"] = [0xffdad3, 0xc25c62];
				settings["bevelColor"] = [0xd5f2fa, 0x5790ad];
				settings["fontColor"] = 0xffffff;			
				settings["fontBorderColor"] = 0x3e7496;
			
				settings['active'] = {
					bgColor:				[0xace6f1, 0x92c7d5],
					borderColor:			[0x749eac, 0x92c7d5],
					bevelColor:				[0xe1f3f3, 0x749eac],
					fontColor:				0xfbfdfc,			
					fontBorderColor:		0x3e7496	
				}
			}*/	
			
			this.order = settings.order;
			this.type = settings.type;
			super(settings);
		}
		
		public function set selected(value:Boolean):void {		
			_selected = value;
			if (_selected)
				state = Button.ACTIVE;
			else
				state = Button.NORMAL;
		}
		
		public function glow():void{
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.inner = false;
			myGlow.color = 0xFFFFFF;
			myGlow.blurX = 10;
			myGlow.blurY = 10;
			myGlow.strength = 10;
			myGlow.alpha = 0.5;
			this.filters = [myGlow];
		}
	}
}
