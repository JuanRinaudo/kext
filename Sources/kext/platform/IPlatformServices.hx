package kext.platform;

typedef ServiceResponse = Dynamic -> Void;

interface IPlatformServices {
	public function init(initCallback:ServiceResponse):Void;

	public function getAllPlayerScore(id:String, callback:ServiceResponse):Void;
	public function getAllTimePlayerScore(id:String, callback:ServiceResponse):Void;
	public function getWeeklyPlayerScore(id:String, callback:ServiceResponse):Void;
	public function getDailyPlayerScore(id:String, callback:ServiceResponse):Void;
	
	public function getAllTimePublicScores(id:String, callback:ServiceResponse):Void;
	public function getWeeklyPublicScores(id:String, callback:ServiceResponse):Void;
	public function getDailyPublicScores(id:String, callback:ServiceResponse):Void;
	
	public function getAllTimeSocialScores(id:String, callback:ServiceResponse):Void;
	public function getWeeklySocialScores(id:String, callback:ServiceResponse):Void;
	public function getDailySocialScores(id:String, callback:ServiceResponse):Void;

	public function submitScore(id:String, value:Int, callback:ServiceResponse):Void;
}