package
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	public class TextSettings extends Sprite
	{
		public static var itemTitle:Object = {
			color:0xffffff,
			borderColor:0x6a211b,
			textAlign:"center",
			autoSize:"center",
			fontSize:21,
			textLeading:-6,
			multiline:true,
			wrap: true,
			distShadow:0
		}
		
		public static var itemTitle2:Object = {
			color:0x6a211b,
			borderColor:0xffffff,
			textAlign:"center",
			autoSize:"center",
			fontSize:21,
			textLeading:-6,
			multiline:true,
			wrap: true,
			distShadow:0
		}
		
		public static var itemCount:Object = {
			color:0xfcf6e4,
			borderColor:0x75480d,
			textAlign:"center",
			autoSize:"center",
			fontSize:30,
			textLeading:-6
			//multiline:true
		}
		
		public static var description:Object = {
			textAlign:		'center',
			autoSize:		'center',
			fontSize:		24,
			color:			0x6b401a,
			borderColor:	0xf0e6da,
			multiline: true,
			wrap: true,
			distShadow:		0
		}
		
		public static var description3:Object = {
			textAlign:		'center',
			autoSize:		'center',
			fontSize:		29,
			color:			0x803a18,
			borderColor:	0xfffafd,
			multiline: true,
			wrap: true,
			distShadow:		0
		}
		
		public static var title:Object = {
			color:0xFCF5EF, 
			borderColor:0xC58732,
			fontSize:39,
			multiline:true,
			wrap:true,
			textAlign:"center",
			shadowSize:3,
			shadowColor:0x662112
		}
		
		public static var description2:Object = {
			textAlign:		'center',
			autoSize:		'center',
			fontSize:		22,
			color:			0xfffdf4,
			borderColor:	0x6b4226,
			multiline:		true,
			wrap:			true
		}
		
		public static var steps:Object = {			//этапы 1/1
			textAlign:		'center',
			fontSize:		29,
			color:			0xfffcff,
			borderColor:	0x5b3300
		}
		
		
		public static var rewardTitle:Object = {
			textAlign:		'center',
			fontSize:		21,
			color:			0x783c17,
			borderColor:	0xffffff,
			multiline:		true,
			wrap:			true,
			distShadow:		0
		}
		
		public static var timer:Object = {
			color:0xfee435,
			borderColor:0x85541a,
			fontSize:34,
			//borderSize:2,
			textAlign:"center",
			width:320
			//filters: [new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
		}
		
		public static var itemMini:Object = {
			fontSize:		16,
			color:0x593306,
			borderColor:0xdfe0db,
			autoSize:		'center'
		}
		
		//New 
		public static var moneyBttnGreen:Object = {
				width:		180,
				height:		44,
				fontSize: 	25,
				fontColor:	0x668534,
				fontBorderColor: 0xdbf99c
		}
		
		public static var description_Fair:Object = {
			textAlign:		'center',
			autoSize:		'center',
			fontSize:		24,
			color:			0x7d3818,
			borderColor:	0xfbf4ed,
			multiline: true,
			wrap: true,
			distShadow:		0
		}
		
		public function TextSettings() {
			
		}
		
		
	
}
}