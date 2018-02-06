package utils 
{
	import astar.AStarNodeVO;
	import core.Load;
	import units.Resource;
	import units.Unit;
	/**
	 * ...
	 * @author 
	 */
	public class MapPresets 
	{
		
		public function MapPresets() 
		{
			
		}
		//
		//public static var PRESET_1:String = '{"size":10, "data":[{"z":0,"x":0,"rotate":false,"sid":231},{"z":4,"x":1,"rotate":false,"sid":257},{"z":6,"x":4,"rotate":false,"sid":328},{"z":4,"x":5,"rotate":false,"sid":1238},{"z":0,"x":7,"rotate":true,"sid":1239},{"z":4,"x":7,"rotate":false,"sid":293}]}';
		//public static var PRESET_2:String = '{"size":10, "data":[{"z":2,"x":1,"rotate":false,"sid":812},{"z":7,"x":1,"rotate":false,"sid":212},{"z":2,"x":2,"rotate":false,"sid":258},{"z":2,"x":5,"rotate":false,"sid":295},{"z":4,"x":6,"rotate":false,"sid":812},{"z":8,"x":6,"rotate":false,"sid":812},{"z":6,"x":7,"rotate":false,"sid":882},{"z":2,"x":8,"rotate":false,"sid":881},{"z":5,"x":9,"rotate":false,"sid":750}]}';
		//public static var PRESET_3:String = '{"size":10, "data":[{"z":0,"x":1,"rotate":false,"sid":295},{"z":3,"x":2,"rotate":false,"sid":749},{"z":10,"x":2,"rotate":false,"sid":249},{"z":4,"x":3,"rotate":false,"sid":276},{"z":5,"x":3,"rotate":false,"sid":274},{"z":7,"x":3,"rotate":false,"sid":275},{"z":3,"x":5,"rotate":false,"sid":750},{"z":4,"x":5,"rotate":false,"sid":616},{"z":8,"x":5,"rotate":false,"sid":812},{"z":3,"x":6,"rotate":false,"sid":812}]}';
		//public static var PRESET_4:String = '{"size":10, "data":[{"z":9,"x":0,"rotate":false,"sid":200},{"z":3,"x":1,"rotate":false,"sid":244},{"z":6,"x":1,"rotate":false,"sid":425},{"z":9,"x":1,"rotate":false,"sid":200},{"z":8,"x":2,"rotate":false,"sid":200},{"z":5,"x":3,"rotate":false,"sid":200},{"z":6,"x":3,"rotate":false,"sid":204},{"z":4,"x":4,"rotate":false,"sid":744}]}';
		//public static var PRESET_5:String = '{"size":10, "data":[{"z":1,"x":0,"rotate":false,"sid":280},{"z":5,"x":2,"rotate":false,"sid":750},{"z":2,"x":6,"rotate":false,"sid":426},{"z":7,"x":6,"rotate":false,"sid":493},{"z":7,"x":9,"rotate":false,"sid":449},{"z":10,"x":9,"rotate":false,"sid":426}]}';
		//public static var PRESET_6:String = '{"size":10, "data":[{ "z":5, "x":0, "sid":276, "rotate":false }, { "z":10, "x":0, "sid":332, "rotate":false }, { "z":7, "x":1, "sid":280, "rotate":false }, { "z":1, "x":2, "sid":259, "rotate":false }, { "z":4, "x":4, "sid":746, "rotate":false }, { "z":1, "x":5, "sid":746, "rotate":false }, { "z":4, "x":7, "sid":301, "rotate":false }, { "z":8, "x":7, "sid":426, "rotate":false }, { "z":2, "x":9, "sid":295, "rotate":false }]}'
		//public static var PRESET_7:String = '{"size":10, "data":[{ "z":5, "x":1, "sid":326, "rotate":false }, { "z":8, "x":1, "sid":429, "rotate":false }, { "z":2, "x":2, "sid":319, "rotate":false }, { "z":9, "x":2, "sid":747, "rotate":false }, { "z":2, "x":6, "sid":212, "rotate":false }, { "z":7, "x":6, "sid":749, "rotate":false }]}'
		//public static var PRESET_8:String = '{"size":10, "data":[{ "z":2, "x":3, "sid":196, "rotate":false }, { "z":5, "x":3, "sid":195, "rotate":false }, { "z":8, "x":8, "sid":447, "rotate":false }, { "z":3, "x":9, "sid":231, "rotate":false }]}'
		//public static var PRESET_9:String = '{"size":10, "data":[{ "z":0, "x":0, "sid":747, "rotate":false }, { "z":7, "x":2, "sid":335, "rotate":false }, { "z":6, "x":3, "sid":231, "rotate":false }, { "z":7, "x":4, "sid":317, "rotate":false }, { "z":1, "x":5, "sid":279, "rotate":false }, { "z":3, "x":5, "sid":744, "rotate":false }, { "z":5, "x":5, "sid":277, "rotate":false }, { "z":2, "x":7, "sid":748, "rotate":false }, { "z":7, "x":7, "sid":320, "rotate":false }]}'
		//public static var PRESET_10:String ='{"size":10, "data":[{ "z":5, "x":0, "sid":619, "rotate":false }, { "z":10, "x":1, "sid":749, "rotate":false }, { "z":10, "x":2, "sid":493, "rotate":false }, { "z":4, "x":4, "sid":598, "rotate":false }, { "z":6, "x":5, "sid":619, "rotate":false }, { "z":10, "x":5, "sid":618, "rotate":false }, { "z":3, "x":6, "sid":449, "rotate":false }]}'
		//public static var PRESET_11:String ='{"size":5,  "data":[{"z":2,"x":0,"rotate":false,"sid":259},{"z":5,"x":2,"rotate":false,"sid":259},{"z":1,"x":3,"rotate":false,"sid":746}]}';
		//public static var PRESET_12:String ='{"size":5,  "data":[{"z":2,"x":1,"rotate":false,"sid":231},{"z":0,"x":2,"rotate":false,"sid":230},{"z":4,"x":4,"rotate":false,"sid":231}]}';
		
		
		public static var PRESET_1:String = '{"size":10,"data":[{"z":4,"x":1,"sid":611,"rotate":false},{"z":7,"x":1,"sid":294,"rotate":false},{"z":2,"x":2,"sid":874,"rotate":false},{"z":7,"x":4,"sid":313,"rotate":false},{"z":0,"x":5,"sid":887,"rotate":false},{"z":5,"x":6,"sid":874,"rotate":false}]}';
		public static var PRESET_2:String = '{"size":10,"data":[{"z":6,"x":0,"sid":747,"rotate":false},{"z":1,"x":2,"sid":897,"rotate":false},{"z":6,"x":3,"sid":747,"rotate":false},{"z":6,"x":6,"sid":748,"rotate":false},{"z":3,"x":7,"sid":301,"rotate":false},{"z":1,"x":8,"sid":749,"rotate":false}]}';
		public static var PRESET_3:String = '{"size":10,"data":[{"z":4,"x":1,"sid":244,"rotate":true},{"z":8,"x":1,"sid":232,"rotate":false},{"z":1,"x":2,"sid":230,"rotate":false},{"z":7,"x":2,"sid":653,"rotate":false},{"z":6,"x":6,"sid":257,"rotate":false},{"z":2,"x":7,"sid":237,"rotate":false}]}';
		public static var PRESET_4:String = '{"size":10,"data":[{"z":6,"x":0,"sid":747,"rotate":false},{"z":1,"x":1,"sid":258,"rotate":false},{"z":4,"x":1,"sid":244,"rotate":false},{"z":5,"x":3,"sid":747,"rotate":false},{"z":0,"x":4,"sid":878,"rotate":false},{"z":3,"x":4,"sid":225,"rotate":false},{"z":0,"x":6,"sid":746,"rotate":false},{"z":3,"x":6,"sid":745,"rotate":false},{"z":6,"x":6,"sid":747,"rotate":false}]}';
		public static var PRESET_5:String = '{"size":10,"data":[{"z":2,"x":1,"sid":310,"rotate":false},{"z":6,"x":1,"sid":318,"rotate":false},{"z":6,"x":4,"sid":419,"rotate":false},{"z":1,"x":6,"sid":301,"rotate":false},{"z":6,"x":7,"sid":317,"rotate":false}]}';
		public static var PRESET_6:String = '{"size":10,"data":[{"z":4,"x":1,"sid":277,"rotate":false},{"z":6,"x":1,"sid":276,"rotate":false},{"z":8,"x":1,"sid":271,"rotate":false},{"z":2,"x":3,"sid":283,"rotate":false},{"z":7,"x":3,"sid":280,"rotate":true},{"z":2,"x":6,"sid":285,"rotate":true},{"z":8,"x":6,"sid":293,"rotate":false},{"z":1,"x":8,"sid":275,"rotate":false}]}';
		public static var PRESET_7:String = '{"size":20,"data":[{"z":7,"x":1,"sid":881,"rotate":false},{"z":2,"x":2,"sid":876,"rotate":false},{"z":11,"x":2,"sid":878,"rotate":false},{"z":14,"x":2,"sid":619,"rotate":false},{"z":1,"x":5,"sid":899,"rotate":false},{"z":6,"x":5,"sid":747,"rotate":false},{"z":9,"x":5,"sid":747,"rotate":false},{"z":12,"x":5,"sid":749,"rotate":false},{"z":12,"x":6,"sid":742,"rotate":false},{"z":6,"x":8,"sid":747,"rotate":false},{"z":9,"x":8,"sid":747,"rotate":false},{"z":1,"x":10,"sid":747,"rotate":false},{"z":5,"x":11,"sid":875,"rotate":false},{"z":8,"x":11,"sid":616,"rotate":false},{"z":1,"x":13,"sid":745,"rotate":false},{"z":13,"x":13,"sid":746,"rotate":false},{"z":16,"x":13,"sid":741,"rotate":false},{"z":6,"x":15,"sid":617,"rotate":false},{"z":1,"x":16,"sid":740,"rotate":false},{"z":11,"x":16,"sid":449,"rotate":false},{"z":15,"x":16,"sid":493,"rotate":false}]}';
		public static var PRESET_8:String = '{"size":20,"data":[{"z":1,"x":0,"sid":286,"rotate":false},{"z":5,"x":1,"sid":280,"rotate":false},{"z":11,"x":1,"sid":285,"rotate":true},{"z":16,"x":1,"sid":287,"rotate":false},{"z":8,"x":2,"sid":268,"rotate":false},{"z":7,"x":5,"sid":238,"rotate":false},{"z":13,"x":5,"sid":282,"rotate":false},{"z":17,"x":6,"sid":280,"rotate":false},{"z":2,"x":7,"sid":280,"rotate":false},{"z":11,"x":7,"sid":243,"rotate":false},{"z":5,"x":8,"sid":283,"rotate":false},{"z":16,"x":8,"sid":255,"rotate":false},{"z":2,"x":10,"sid":281,"rotate":false},{"z":9,"x":11,"sid":213,"rotate":false},{"z":5,"x":12,"sid":256,"rotate":false},{"z":17,"x":12,"sid":268,"rotate":false},{"z":2,"x":13,"sid":258,"rotate":false},{"z":15,"x":13,"sid":277,"rotate":false},{"z":1,"x":16,"sid":266,"rotate":false},{"z":5,"x":16,"sid":259,"rotate":false},{"z":11,"x":16,"sid":257,"rotate":false},{"z":16,"x":16,"sid":258,"rotate":false},{"z":8,"x":18,"sid":232,"rotate":false}]}';
		public static var PRESET_9:String = '{"size":20,"data":[{"z":5,"x":0,"sid":615,"rotate":false},{"z":1,"x":1,"sid":274,"rotate":false},{"z":9,"x":1,"sid":598,"rotate":false},{"z":13,"x":1,"sid":274,"rotate":false},{"z":15,"x":1,"sid":608,"rotate":false},{"z":2,"x":3,"sid":747,"rotate":false},{"z":12,"x":3,"sid":609,"rotate":false},{"z":9,"x":4,"sid":317,"rotate":false},{"z":16,"x":6,"sid":287,"rotate":false},{"z":1,"x":7,"sid":747,"rotate":false},{"z":4,"x":7,"sid":334,"rotate":false},{"z":7,"x":7,"sid":332,"rotate":false},{"z":13,"x":8,"sid":301,"rotate":false},{"z":1,"x":10,"sid":747,"rotate":false},{"z":4,"x":10,"sid":747,"rotate":false},{"z":8,"x":11,"sid":651,"rotate":false},{"z":9,"x":11,"sid":747,"rotate":false},{"z":15,"x":11,"sid":617,"rotate":false},{"z":13,"x":12,"sid":651,"rotate":false},{"z":0,"x":13,"sid":747,"rotate":false},{"z":3,"x":13,"sid":747,"rotate":false},{"z":6,"x":13,"sid":747,"rotate":false},{"z":12,"x":13,"sid":747,"rotate":false},{"z":4,"x":16,"sid":747,"rotate":false},{"z":7,"x":16,"sid":747,"rotate":false},{"z":11,"x":16,"sid":449,"rotate":false},{"z":15,"x":16,"sid":275,"rotate":false},{"z":17,"x":16,"sid":436,"rotate":false},{"z":14,"x":17,"sid":275,"rotate":false},{"z":3,"x":18,"sid":652,"rotate":false},{"z":17,"x":18,"sid":275,"rotate":false}]}';
		public static var PRESET_10:String = '{"size":20,"data":[{"z":5,"x":1,"sid":474,"rotate":false},{"z":9,"x":1,"sid":1142,"rotate":false},{"z":13,"x":1,"sid":747,"rotate":false},{"z":16,"x":1,"sid":747,"rotate":false},{"z":1,"x":2,"sid":447,"rotate":false},{"z":3,"x":2,"sid":448,"rotate":false},{"z":0,"x":4,"sid":749,"rotate":false},{"z":1,"x":4,"sid":491,"rotate":false},{"z":14,"x":4,"sid":747,"rotate":false},{"z":6,"x":5,"sid":617,"rotate":false},{"z":11,"x":5,"sid":618,"rotate":false},{"z":17,"x":5,"sid":749,"rotate":false},{"z":15,"x":7,"sid":741,"rotate":false},{"z":5,"x":9,"sid":747,"rotate":false},{"z":8,"x":9,"sid":747,"rotate":false},{"z":11,"x":9,"sid":740,"rotate":false},{"z":0,"x":10,"sid":747,"rotate":false},{"z":3,"x":10,"sid":748,"rotate":false},{"z":7,"x":12,"sid":746,"rotate":false},{"z":10,"x":12,"sid":746,"rotate":false},{"z":13,"x":12,"sid":746,"rotate":false},{"z":16,"x":12,"sid":875,"rotate":false},{"z":0,"x":13,"sid":746,"rotate":false},{"z":16,"x":14,"sid":747,"rotate":false},{"z":6,"x":15,"sid":875,"rotate":false},{"z":10,"x":15,"sid":747,"rotate":false},{"z":13,"x":15,"sid":747,"rotate":false},{"z":3,"x":16,"sid":746,"rotate":false},{"z":1,"x":17,"sid":790,"rotate":false},{"z":16,"x":17,"sid":653,"rotate":false}]}';
		public static var PRESET_11:String = '{"size":20,"data":[{"z":14,"x":1,"sid":209,"rotate":false},{"z":18,"x":1,"sid":200,"rotate":false},{"z":2,"x":2,"sid":212,"rotate":false},{"z":7,"x":2,"sid":238,"rotate":false},{"z":10,"x":3,"sid":237,"rotate":false},{"z":18,"x":3,"sid":269,"rotate":false},{"z":14,"x":5,"sid":203,"rotate":false},{"z":16,"x":5,"sid":191,"rotate":false},{"z":0,"x":6,"sid":211,"rotate":false},{"z":7,"x":6,"sid":257,"rotate":false},{"z":11,"x":7,"sid":200,"rotate":false},{"z":13,"x":7,"sid":187,"rotate":false},{"z":10,"x":8,"sid":207,"rotate":false},{"z":6,"x":9,"sid":245,"rotate":false},{"z":9,"x":10,"sid":269,"rotate":false},{"z":13,"x":11,"sid":257,"rotate":false},{"z":16,"x":11,"sid":194,"rotate":false},{"z":2,"x":12,"sid":201,"rotate":false},{"z":5,"x":12,"sid":269,"rotate":false},{"z":6,"x":12,"sid":218,"rotate":false},{"z":2,"x":14,"sid":200,"rotate":false},{"z":4,"x":14,"sid":221,"rotate":false},{"z":15,"x":15,"sid":272,"rotate":false},{"z":17,"x":15,"sid":295,"rotate":false},{"z":2,"x":16,"sid":190,"rotate":false},{"z":13,"x":17,"sid":237,"rotate":false},{"z":15,"x":17,"sid":411,"rotate":false}]}';
		
		public static var PRESET_12:String = '{"size":10,"data":[{"rotate":false,"x":4,"sid":417,"z":2},{"rotate":false,"x":4,"sid":311,"z":3},{"rotate":false,"x":4,"sid":749,"z":6},{"rotate":false,"x":4,"sid":296,"z":8},{"rotate":false,"x":5,"sid":417,"z":1},{"rotate":false,"x":5,"sid":922,"z":5},{"rotate":false,"x":6,"sid":616,"z":0},{"rotate":false,"x":7,"sid":296,"z":4},{"rotate":false,"x":9,"sid":747,"z":5},{"rotate":false,"x":9,"sid":749,"z":8}]}';
		public static var PRESET_13:String = '{"size":10,"data":[{"rotate":false,"x":0,"sid":417,"z":9},{"rotate":false,"x":1,"sid":741,"z":3},{"rotate":false,"x":1,"sid":747,"z":7},{"rotate":false,"x":2,"sid":296,"z":2},{"rotate":false,"x":3,"sid":749,"z":1},{"rotate":false,"x":4,"sid":745,"z":4},{"rotate":false,"x":4,"sid":296,"z":8},{"rotate":false,"x":5,"sid":417,"z":1},{"rotate":false,"x":6,"sid":616,"z":0},{"rotate":false,"x":7,"sid":744,"z":4},{"rotate":false,"x":7,"sid":745,"z":6},{"rotate":false,"x":9,"sid":749,"z":9}]}';
		public static var PRESET_14:String = '{"size":10,"data":[{"rotate":true,"x":0,"z":3,"sid":748},{"rotate":false,"x":0,"z":6,"sid":744},{"rotate":false,"x":1,"z":2,"sid":268},{"rotate":false,"x":2,"z":3,"sid":218},{"rotate":false,"x":3,"z":1,"sid":748},{"rotate":false,"x":7,"z":1,"sid":272}]}';
		public static var PRESET_15:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":6,"sid":744},{"rotate":false,"x":1,"z":2,"sid":268},{"rotate":false,"x":1,"z":3,"sid":740},{"rotate":false,"x":2,"z":7,"sid":741},{"rotate":false,"x":3,"z":1,"sid":748},{"rotate":false,"x":4,"z":4,"sid":272},{"rotate":false,"x":6,"z":0,"sid":745},{"rotate":false,"x":6,"z":3,"sid":745},{"rotate":false,"x":6,"z":6,"sid":749},{"rotate":true,"x":7,"z":6,"sid":748}]}';
		public static var PRESET_16:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":0,"sid":749},{"rotate":false,"x":1,"z":3,"sid":279},{"rotate":false,"x":1,"z":5,"sid":744},{"rotate":false,"x":1,"z":8,"sid":296},{"rotate":false,"x":2,"z":0,"sid":745},{"rotate":false,"x":2,"z":7,"sid":745},{"rotate":false,"x":3,"z":5,"sid":417},{"rotate":false,"x":5,"z":3,"sid":250},{"rotate":false,"x":5,"z":5,"sid":1142},{"rotate":false,"x":6,"z":1,"sid":312},{"rotate":false,"x":8,"z":1,"sid":279}]}';
		public static var PRESET_17:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":0,"sid":749},{"rotate":false,"x":0,"z":5,"sid":616},{"rotate":false,"x":1,"z":1,"sid":225},{"rotate":false,"x":1,"z":4,"sid":231},{"rotate":false,"x":2,"z":4,"sid":296},{"rotate":false,"x":3,"z":0,"sid":231},{"rotate":false,"x":4,"z":1,"sid":279},{"rotate":false,"x":4,"z":5,"sid":250},{"rotate":false,"x":6,"z":3,"sid":194},{"rotate":false,"x":8,"z":2,"sid":231},{"rotate":false,"x":8,"z":9,"sid":296}]}';
		public static var PRESET_18:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":0,"sid":749},{"rotate":false,"x":0,"z":7,"sid":748},{"rotate":false,"x":1,"z":1,"sid":618},{"rotate":false,"x":1,"z":4,"sid":231},{"rotate":false,"x":2,"z":4,"sid":618},{"rotate":false,"x":3,"z":0,"sid":231},{"rotate":false,"x":3,"z":8,"sid":225},{"rotate":false,"x":5,"z":0,"sid":741},{"rotate":false,"x":5,"z":4,"sid":231},{"rotate":false,"x":5,"z":5,"sid":616},{"rotate":false,"x":8,"z":1,"sid":279}]}';
		public static var PRESET_19:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":4,"sid":747},{"rotate":false,"x":0,"z":7,"sid":745},{"rotate":false,"x":1,"z":1,"sid":618},{"rotate":false,"x":3,"z":0,"sid":231},{"rotate":false,"x":3,"z":5,"sid":741},{"rotate":false,"x":4,"z":4,"sid":749},{"rotate":false,"x":6,"z":5,"sid":618},{"rotate":false,"x":7,"z":3,"sid":312}]}';
		public static var PRESET_20:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":1,"sid":745},{"rotate":false,"x":0,"z":4,"sid":747},{"rotate":false,"x":2,"z":8,"sid":279},{"rotate":false,"x":3,"z":0,"sid":298},{"rotate":false,"x":5,"z":7,"sid":275},{"rotate":false,"x":7,"z":7,"sid":745}]}';
		public static var PRESET_21:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":1,"sid":745},{"rotate":true,"x":1,"z":8,"sid":749},{"rotate":false,"x":2,"z":4,"sid":747},{"rotate":false,"x":3,"z":1,"sid":279},{"rotate":false,"x":3,"z":7,"sid":749},{"rotate":false,"x":4,"z":7,"sid":740},{"rotate":false,"x":5,"z":3,"sid":900},{"rotate":false,"x":7,"z":1,"sid":275},{"rotate":false,"x":7,"z":7,"sid":745},{"rotate":false,"x":8,"z":1,"sid":749}]}';
		public static var PRESET_22:String = '{"size":10,"data":[{"rotate":false,"x":1,"z":3,"sid":427},{"rotate":false,"x":1,"z":5,"sid":618},{"rotate":true,"x":1,"z":8,"sid":749},{"rotate":false,"x":2,"z":1,"sid":618},{"rotate":false,"x":4,"z":4,"sid":897},{"rotate":false,"x":6,"z":2,"sid":427},{"rotate":false,"x":7,"z":1,"sid":275},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":9,"z":3,"sid":417},{"rotate":false,"x":9,"z":8,"sid":427}]}';
		public static var PRESET_23:String = '{"size":10,"data":[{"rotate":false,"x":1,"z":2,"sid":231},{"rotate":false,"x":1,"z":3,"sid":427},{"rotate":false,"x":1,"z":5,"sid":747},{"rotate":false,"x":1,"z":8,"sid":279},{"rotate":false,"x":2,"z":1,"sid":618},{"rotate":false,"x":4,"z":4,"sid":740},{"rotate":false,"x":4,"z":7,"sid":741},{"rotate":false,"x":6,"z":2,"sid":427},{"rotate":false,"x":7,"z":1,"sid":275},{"rotate":false,"x":7,"z":7,"sid":745},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":8,"z":6,"sid":231},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		public static var PRESET_24:String = '{"size":10,"data":[{"rotate":false,"x":1,"z":2,"sid":231},{"rotate":false,"x":1,"z":3,"sid":427},{"rotate":false,"x":1,"z":5,"sid":747},{"rotate":false,"x":1,"z":8,"sid":279},{"rotate":false,"x":3,"z":2,"sid":296},{"rotate":false,"x":3,"z":8,"sid":749},{"rotate":false,"x":4,"z":7,"sid":741},{"rotate":false,"x":5,"z":1,"sid":231},{"rotate":false,"x":6,"z":2,"sid":427},{"rotate":false,"x":7,"z":1,"sid":275},{"rotate":false,"x":7,"z":7,"sid":745},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":8,"z":3,"sid":231},{"rotate":false,"x":8,"z":5,"sid":744},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		public static var PRESET_25:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":4,"sid":745},{"rotate":false,"x":1,"z":1,"sid":232},{"rotate":false,"x":1,"z":8,"sid":279},{"rotate":false,"x":2,"z":3,"sid":231},{"rotate":false,"x":2,"z":7,"sid":232},{"rotate":false,"x":3,"z":1,"sid":279},{"rotate":false,"x":3,"z":3,"sid":476},{"rotate":false,"x":5,"z":1,"sid":231},{"rotate":false,"x":7,"z":1,"sid":275},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		public static var PRESET_26:String = '{"size":10,"data":[{"rotate":false,"x":1,"z":1,"sid":232},{"rotate":true,"x":1,"z":2,"sid":748},{"rotate":false,"x":1,"z":8,"sid":279},{"rotate":false,"x":2,"z":5,"sid":231},{"rotate":false,"x":3,"z":1,"sid":279},{"rotate":false,"x":3,"z":5,"sid":745},{"rotate":false,"x":6,"z":3,"sid":231},{"rotate":false,"x":6,"z":5,"sid":740},{"rotate":false,"x":7,"z":1,"sid":275},{"rotate":false,"x":7,"z":8,"sid":232},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		public static var PRESET_27:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":3,"sid":1142},{"rotate":false,"x":1,"z":1,"sid":231},{"rotate":false,"x":1,"z":7,"sid":231},{"rotate":false,"x":1,"z":8,"sid":279},{"rotate":false,"x":2,"z":0,"sid":618},{"rotate":false,"x":3,"z":7,"sid":745},{"rotate":false,"x":4,"z":3,"sid":745},{"rotate":false,"x":6,"z":6,"sid":275},{"rotate":false,"x":7,"z":4,"sid":312},{"rotate":false,"x":7,"z":6,"sid":740},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":8,"z":9,"sid":232},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		public static var PRESET_28:String = '{"size":10,"data":[{"rotate":false,"x":1,"z":1,"sid":231},{"rotate":false,"x":1,"z":7,"sid":231},{"rotate":false,"x":1,"z":8,"sid":279},{"rotate":false,"x":2,"z":0,"sid":618},{"rotate":false,"x":3,"z":6,"sid":618},{"rotate":false,"x":5,"z":3,"sid":740},{"rotate":false,"x":6,"z":6,"sid":275},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":8,"z":9,"sid":232},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		public static var PRESET_29:String = '{"size":10,"data":[{"rotate":false,"x":1,"z":1,"sid":231},{"rotate":false,"x":1,"z":7,"sid":231},{"rotate":false,"x":1,"z":8,"sid":279},{"rotate":false,"x":3,"z":4,"sid":616},{"rotate":false,"x":5,"z":2,"sid":232},{"rotate":false,"x":6,"z":1,"sid":281},{"rotate":false,"x":7,"z":5,"sid":740},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":8,"z":8,"sid":275},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		public static var PRESET_30:String = '{"size":10,"data":[{"rotate":false,"x":1,"z":1,"sid":231},{"rotate":false,"x":1,"z":2,"sid":212},{"rotate":false,"x":1,"z":7,"sid":231},{"rotate":false,"x":1,"z":8,"sid":279},{"rotate":false,"x":4,"z":7,"sid":745},{"rotate":false,"x":5,"z":2,"sid":232},{"rotate":false,"x":5,"z":3,"sid":744},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":8,"z":8,"sid":275},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		public static var PRESET_31:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":3,"sid":268},{"rotate":false,"x":0,"z":4,"sid":745},{"rotate":false,"x":0,"z":7,"sid":285},{"rotate":false,"x":1,"z":1,"sid":429},{"rotate":false,"x":4,"z":0,"sid":745},{"rotate":false,"x":5,"z":3,"sid":272},{"rotate":false,"x":5,"z":8,"sid":427},{"rotate":false,"x":6,"z":7,"sid":618},{"rotate":false,"x":7,"z":3,"sid":744},{"rotate":false,"x":8,"z":1,"sid":749},{"rotate":false,"x":9,"z":3,"sid":417}]}';
		
		//Synoptik
		public static var PRESET_32:String = '{"size":20,"data":[{"rotate":false,"x":3,"z":15,"sid":617},{"rotate":false,"x":4,"z":3,"sid":274},{"rotate":false,"x":4,"z":13,"sid":269},{"rotate":false,"x":5,"z":5,"sid":194},{"rotate":false,"x":5,"z":9,"sid":231},{"rotate":false,"x":7,"z":9,"sid":238},{"rotate":false,"x":8,"z":5,"sid":238},{"rotate":false,"x":8,"z":6,"sid":743},{"rotate":false,"x":8,"z":8,"sid":317},{"rotate":true,"x":10,"z":15,"sid":748},{"rotate":false,"x":11,"z":6,"sid":745},{"rotate":false,"x":11,"z":10,"sid":275},{"rotate":false,"x":12,"z":14,"sid":745},{"rotate":true,"x":15,"z":5,"sid":269},{"rotate":false,"x":15,"z":10,"sid":237},{"rotate":false,"x":16,"z":7,"sid":748},{"rotate":false,"x":17,"z":6,"sid":231}]}'
		public static var PRESET_33:String = '{"size":20,"data":[{"rotate":false,"x":2,"z":6,"sid":410},{"rotate":false,"x":4,"z":4,"sid":310},{"rotate":false,"x":4,"z":8,"sid":191},{"rotate":false,"x":4,"z":12,"sid":296},{"rotate":false,"x":5,"z":16,"sid":258},{"rotate":false,"x":8,"z":15,"sid":654},{"rotate":false,"x":9,"z":3,"sid":1073},{"rotate":false,"x":12,"z":16,"sid":1073},{"rotate":false,"x":13,"z":7,"sid":296},{"rotate":false,"x":13,"z":9,"sid":258},{"rotate":false,"x":14,"z":6,"sid":748},{"rotate":false,"x":17,"z":18,"sid":296},{"rotate":false,"x":18,"z":16,"sid":426}]}'
		public static var PRESET_34:String = '{"size":20,"data":[{"rotate":false,"x":1,"z":2,"sid":748},{"rotate":false,"x":2,"z":1,"sid":231},{"rotate":false,"x":2,"z":5,"sid":275},{"rotate":false,"x":2,"z":6,"sid":745},{"rotate":false,"x":2,"z":12,"sid":1142},{"rotate":false,"x":3,"z":16,"sid":277},{"rotate":false,"x":4,"z":2,"sid":741},{"rotate":false,"x":4,"z":5,"sid":296},{"rotate":false,"x":10,"z":10,"sid":493},{"rotate":false,"x":12,"z":14,"sid":275},{"rotate":false,"x":12,"z":15,"sid":749},{"rotate":false,"x":13,"z":12,"sid":318},{"rotate":false,"x":14,"z":2,"sid":230},{"rotate":false,"x":14,"z":11,"sid":749},{"rotate":false,"x":16,"z":6,"sid":745},{"rotate":false,"x":17,"z":3,"sid":275},{"rotate":false,"x":18,"z":2,"sid":749},{"rotate":false,"x":18,"z":16,"sid":426}]}'
		public static var PRESET_35:String = '{"size":20,"data":[{"rotate":false,"x":2,"z":8,"sid":212},{"rotate":false,"x":3,"z":7,"sid":232},{"rotate":false,"x":4,"z":7,"sid":231},{"rotate":false,"x":4,"z":13,"sid":294},{"rotate":false,"x":6,"z":11,"sid":745},{"rotate":false,"x":6,"z":14,"sid":426},{"rotate":false,"x":7,"z":14,"sid":741},{"rotate":false,"x":8,"z":3,"sid":744},{"rotate":false,"x":9,"z":11,"sid":258},{"rotate":false,"x":10,"z":6,"sid":745},{"rotate":false,"x":10,"z":9,"sid":296},{"rotate":false,"x":12,"z":5,"sid":231},{"rotate":false,"x":13,"z":4,"sid":612},{"rotate":false,"x":13,"z":7,"sid":749},{"rotate":false,"x":15,"z":8,"sid":296},{"rotate":false,"x":15,"z":15,"sid":412},{"rotate":false,"x":16,"z":6,"sid":749},{"rotate":false,"x":16,"z":17,"sid":749}]}'
		
		public static var PRESET_36:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":0,"sid":749},{"rotate":false,"x":0,"z":7,"sid":748},{"rotate":false,"x":1,"z":1,"sid":618},{"rotate":false,"x":1,"z":4,"sid":231},{"rotate":false,"x":2,"z":4,"sid":618},{"rotate":false,"x":3,"z":0,"sid":231},{"rotate":false,"x":3,"z":8,"sid":225},{"rotate":false,"x":5,"z":0,"sid":741},{"rotate":false,"x":5,"z":4,"sid":231},{"rotate":false,"x":5,"z":5,"sid":616},{"rotate":false,"x":8,"z":1,"sid":279}]}'
		public static var PRESET_37:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":4,"sid":747},{"rotate":false,"x":0,"z":7,"sid":745},{"rotate":false,"x":1,"z":1,"sid":618},{"rotate":false,"x":3,"z":0,"sid":231},{"rotate":false,"x":3,"z":5,"sid":741},{"rotate":false,"x":4,"z":4,"sid":749},{"rotate":false,"x":6,"z":5,"sid":618},{"rotate":false,"x":7,"z":3,"sid":312}]}'
		public static var PRESET_38:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":1,"sid":745},{"rotate":false,"x":0,"z":4,"sid":747},{"rotate":false,"x":2,"z":8,"sid":279},{"rotate":false,"x":3,"z":0,"sid":298},{"rotate":false,"x":5,"z":7,"sid":275},{"rotate":false,"x":7,"z":7,"sid":745}]}'
		public static var PRESET_39:String = '{"size":10,"data":[{"rotate":false,"x":0,"z":1,"sid":745},{"rotate":true,"x":1,"z":8,"sid":749},{"rotate":false,"x":2,"z":4,"sid":747},{"rotate":false,"x":3,"z":1,"sid":279},{"rotate":false,"x":3,"z":7,"sid":749},{"rotate":false,"x":4,"z":7,"sid":740},{"rotate":false,"x":5,"z":3,"sid":900},{"rotate":false,"x":7,"z":1,"sid":275},{"rotate":false,"x":7,"z":7,"sid":745},{"rotate":false,"x":8,"z":1,"sid":749}]}'
		
		public static function getRandomPreset():String
		{
			//var _vars:Array = [PRESET_7, PRESET_8, PRESET_9, PRESET_10, PRESET_11];
			var _vars:Array = [PRESET_32, PRESET_33, PRESET_34, PRESET_35];
			
			var i:int = Math.random() * _vars.length;
			//trace('PRESET # ' + i);
			if (Math.random() > .6)
				return generateComponentsPreset();
				
			if (Math.random() < .3)
				return MapPresets.rotatePreset(_vars[i]);
				
			return _vars[i];
		}
		
		public static function getSmallPreset():String
		{
			//var _vars:Array = [PRESET_1, PRESET_2, PRESET_3, PRESET_4, PRESET_5, PRESET_6];//dafault
			var _vars:Array = [PRESET_36, PRESET_37, PRESET_38, PRESET_39];//dafault
			//var _vars:Array = [PRESET_12, PRESET_13, PRESET_14, PRESET_15, PRESET_16, PRESET_17, PRESET_18, PRESET_19, PRESET_20, PRESET_21, PRESET_22, PRESET_23, PRESET_24, PRESET_25, PRESET_26, PRESET_27, PRESET_28, PRESET_29, PRESET_30, PRESET_31];//simple 2
			
			var i:int = Math.random() * _vars.length;
			//trace('Small PRESET # ' + i);
			
				
			if (Math.random() > .5)
			{
				//trace('small rotated');
				return MapPresets.rotatePreset(_vars[i]);
			}
			//trace('small not rotated');
			return _vars[i];
		}
		
		public static function generateComponentsPreset(_presetSize:int = 20):String
		{
			var step:int = 10;
			var newPresetObject:Object = new Object();
			newPresetObject['size'] = int(_presetSize);
			newPresetObject['data'] = [];
			
			for (var i:int = 0; i <= _presetSize - step; i += step)
			{
				for (var j:int = 0; j <= _presetSize - step; j += step)
				{
					var presetObject:Object = JSON.parse(getSmallPreset());
					for (var _res:* in presetObject['data'])
					{
						newPresetObject['data'].push({
							'sid':presetObject['data'][_res]['sid'],
							'rotate':presetObject['data'][_res]['rotate'],
							'x':i + presetObject['data'][_res]['x'],
							'z':j + presetObject['data'][_res]['z']
							
						});
					}
				}
			}
			
			var presetString:String = JSON.stringify(newPresetObject)
			
			return presetString;
		}
		
		public static function rotatePreset(_preset:String):String
		{
			var newPresetObject:Object = new Object();
			var presetObject:Object = JSON.parse(_preset);
			newPresetObject['size'] = int(presetObject['size']);
			newPresetObject['data'] = [];
			for (var _res:* in presetObject['data'])
			{
				newPresetObject['data'][_res] = {
					'sid':presetObject['data'][_res]['sid'],
					'rotate':presetObject['data'][_res]['rotate'],
					'x':presetObject['size'] - presetObject['data'][_res]['x'],
					'z':presetObject['size'] - presetObject['data'][_res]['z']
					
				};
			}
			var presetString:String = JSON.stringify(newPresetObject)
			
			return presetString;
		}
		
		public static function generateMapResources(_callback:Function = null):void
		{
			var preset:Object;
				
			var mn:int = 0;
			var num:int = 1;
			var step:int = 20;
			while(mn < 8){
				for (var i:int = 0; i <= Map.cells - step; i += step)
				{
					for (var j:int = 0; j <= Map.rows - step; j += step)
					{
						preset = JSON.parse(MapPresets.getRandomPreset());
						for each(var _res:* in preset['data'])
						{
							if (App.map.inGrid({x:int(_res['x'] + i), z:int(_res['z'] + j)}) && App.map.inGrid({x:int(_res['x'] + i + App.data.storage[_res['sid']].area.w), z:int(_res['z'] + j + App.data.storage[_res['sid']].area.h)}))
							{
								var node:AStarNodeVO = App.map._aStarNodes[int(_res['x'] + i)][int(_res['z'] + j)];
								if (Unit.calcStateUnit({x:int(_res['x'] + i), z:int(_res['z'] + j)}, App.data.storage[_res['sid']].area.w, App.data.storage[_res['sid']].area.h))
								{
									if ((int(_res['x'] + i) == App.map.heroPosition.x) &&
									   (int(_res['z'] + j) == App.map.heroPosition.z))
										continue;
									var newRes:Resource = new Resource( { id:num, sid:_res['sid'], x:int(_res['x'] + i), z:int(_res['z'] + j)} );
									newRes.fake = true;
									App.map.sorted.push(newRes);
									newRes.take();
									num++;
								}
							}
						}
					}
				}
				mn++;
			}
			App.map.sorting();
			if (_callback != null)
				_callback();
			//Map.saveMap();
		}
		
		public static function onJSONLoad(_units:Object):void
		{
			for each(var item:Object in _units) 
			{
				var unit:Unit = Unit.add(item);
				unit.fake = true;
				unit.take();
				if (Map.resourcesID.hasOwnProperty(App.data.storage[unit.sid].type)){
					if (Map.resourcesID[App.data.storage[unit.sid].type] < unit['id'])
						Map.resourcesID[App.data.storage[unit.sid].type] = unit['id'];
				}else{
					Map.resourcesID[App.data.storage[unit.sid].type] = 1;
				}
				//if (unit.info.config)
				//{
					//var unitConfig:Array = String(unit.info.config).split('').reverse();
					//for (var configID:int = 0; configID < unitConfig.length; configID++ ) 
					//{
						//if (unitConfig[configID] == "1" && unit.hasOwnProperty(CONFIG_DATA[configID])) 
						//{
							//unit[CONFIG_DATA[configID]] = false;
						//}
					//}
				//}
				//
				//App.map.mainMap.push(unit);
			}
			Map.resourcesID;
			//trace();
			App.map.allSorting();
		}
		public static function loadJSONResources(landID:String):void
		{
			Load.loadText(Config.getLandData(landID), function(text:String):void 
			{
				//self.defaultJson = JSON.parse(text);
				MapPresets.onJSONLoad(JSON.parse(text));
			}, false);
			
		}
		
	}

}