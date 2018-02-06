package buttons 
{
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import silin.filters.ColorAdjust;
	
	
	public class PageButton extends Button
	{
		public static const WIDTH:int = 33;
		public static const HEIGHT:int = 33;
		
		public var page:int = 0;
		
		public function PageButton(settings:Object = null) 
		{
			if (settings == null)
				settings = new Object();
			
			settings["width"] 					= settings.width || PageButton.WIDTH;	
			settings["height"] 					= settings.height || PageButton.HEIGHT;	
			settings["radius"] 					= 60;					//Радиус скругления
			settings["fontSize"]				= 18;					//Размер шрифта
			settings["bevelColor"] 				= [0x4a94bf, 0x235985];
			settings["bgColor"] 				= [0xd0f9ff, 0x68a7c5];
			settings["borderColor"] 			= [0xffefdc, 0xbf7946];
			settings["fontColor"]	 			= 0xfffdf4;
			settings["fontBorderColor"] 		= 0x536e6a;
			
			settings['active'] = {
				bgColor:				[0x65bdca,0x5295b4],
				borderColor:			[0xc37a47,0xf9bd77],	//Цвета градиента
				bevelColor:				[0x458ab1,0x356ea0],	
				fontColor:				0xffffff,				//Цвет шрифта
				fontBorderColor:		0x536e6a				//Цвет обводки шрифта		
			}
			
			settings["textAlign"]				= "center";	
			settings["caption"]					= settings.caption || "1";
			settings["shadow"]					= true;
			
			super(settings);
		}
	}
}