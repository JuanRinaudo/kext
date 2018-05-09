package kext.platform;

typedef ServiceResponse = Dynamic -> Void;
typedef ScoreListResponse = ScoreListData -> Void;

typedef PlatformConfig = {
	client_id:String,
};

typedef PlayerScore = {
	value:Int,
	score:String,
	rank:Int,
	rankLabel:String,
	playerName:String
}

typedef ScoreListData = {
	scoreCount:Int,
	scoreList:Array<PlayerScore>,
	playerScore:PlayerScore
};

interface IPlatformServices {
	public var serviceInited:Bool;
	public var isSignedIn(get, null):Bool;

	public function init(initCallback:ServiceResponse):Void;
	public function authenticate(config:PlatformConfig, signInCallback:ServiceResponse):Void;

	public function getPlayerScoreAll(id:String, callback:ScoreListResponse):Void;
	public function getPlayerScoreAllTime(id:String, callback:ScoreListResponse):Void;
	public function getPlayerScoreWeekly(id:String, callback:ScoreListResponse):Void;
	public function getPlayerScoreDaily(id:String, callback:ScoreListResponse):Void;
	
	public function getAllTimePublicScores(id:String, callback:ScoreListResponse):Void;
	public function getWeeklyPublicScores(id:String, callback:ScoreListResponse):Void;
	public function getDailyPublicScores(id:String, callback:ScoreListResponse):Void;
	
	public function getAllTimeSocialScores(id:String, callback:ScoreListResponse):Void;
	public function getWeeklySocialScores(id:String, callback:ScoreListResponse):Void;
	public function getDailySocialScores(id:String, callback:ScoreListResponse):Void;

	public function submitScore(id:String, value:Int, callback:ServiceResponse):Void;
}