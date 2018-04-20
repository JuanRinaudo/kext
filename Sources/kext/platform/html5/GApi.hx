package kext.platform.html5;

@:enum
abstract TimeSpan(String) {
	public static var ALL = "ALL";
	public static var ALL_TIME = "ALL_TIME";
	public static var DAILY = "DAILY";
	public static var WEEKLY = "WEEKLY";
}

@:enum
abstract Collection(String) {
	public static var PUBLIC = "PUBLIC";
	public static var SOCIAL = "SOCIAL";
	public static var SOCIAL_1P = "SOCIAL_1P";
}

typedef GApiCallback = Dynamic -> Void;
extern class GApiRequest {
	public function execute(callback:GApiCallback):Void;
	public function then(onFulfilled:GApiCallback, ?onRejected:GApiCallback, ?context:Dynamic):Void;
}

@:native("gapi") extern class GApi {
	public static function load(name:String, callback:GApiCallback):Void;
}

typedef AuthInitParams = {
	client_id:String
}

@:native("gapi.auth2") extern class GApiAuth2 {
	public static function init(params:AuthInitParams):GApiRequest;
}

@:native("gapi.client") extern class GApiClient {
	public static function load(name:String, version:String, callback:GApiCallback):Void;
}

@:native("gapi.client.games") extern class GApiGames {

}

typedef GetScoreParameters = {
	leaderboardId:String,
	playerId:String,
	timeSpan:String,
	?consistencyToken:Int,
	?includeRankType:String,
	?language:String,
	?maxResults:Int,
	?pageToken:String
}

typedef ListScoreParameters = {
	collection:String,
	leaderboardId:String,
	timeSpan:String,
	?consistencyToken:Int,
	?language:String,
	?maxResults:Int,
	?pageToken:String
}

typedef ListWindowScoreParameters = {
	collection:String,
	leaderboardId:String,
	timeSpan:String,
	?consistencyToken:Int,
	?language:String,
	?maxResults:Int,
	?pageToken:String,
	?resultsAbove:Int,
	?returnTopIfAbsent:Bool
}

typedef SubmitScoreParameters = {
	leaderboardId:String,
	score:Int,
	?consistencyToken:Int,
	?language:String,
	?scoreTag:String
}

// typedef SubmitMultipleScoreParameters = {
//
// }

@:native("gapi.client.games.scores") extern class GApiScores {
	public static function get(params:GetScoreParameters):GApiRequest;
	public static function list(params:ListScoreParameters):GApiRequest;
	public static function listWindow(params:ListWindowScoreParameters):GApiRequest;
	public static function submit(params:SubmitScoreParameters):GApiRequest;
	// public static function submitMultiple(params:):GApiRequest;
}

typedef GetLeaderboardsParameters = {
	leaderboardId:String,
	consistencyToken:Int,
	language:String
}

typedef ListLeaderboardsParameters = {
	consistencyToken:Int,
	language:String,
	maxResults:Int,
	pageToken:String
}

@:native("gapi.client.games.leaderboards") extern class GApiLeaderboards {
	public static function get(params:GetLeaderboardsParameters):GApiRequest;
	public static function list(params:ListLeaderboardsParameters):GApiRequest;
}