package kext.g4basics;

class G4Constants {
    public static var VERTEX_DATA_POSITION:String = "position";
    public static var VERTEX_DATA_NORMAL:String = "normal";
    public static var VERTEX_DATA_TEXUV:String = "texuv";
    public static var VERTEX_DATA_COLOR:String = "color";
    public static var VERTEX_DATA_JOINT_INDEX:String = "jointIndex";
    public static var VERTEX_DATA_JOINT_WEIGHT:String = "jointWeight";

	public static var VERTEX_OFFSET:Int = 0;
	public static var NORMAL_OFFSET:Int = 3;
	public static var UV_OFFSET:Int = 6;
	public static var COLOR_OFFSET:Int = 8;
	public static var JOINT_INDEX_OFFSET:Int = 12;
	public static var JOINT_WEIGHT_OFFSET:Int = 16;

    public static var MAX_BONES:Int = 50;

    public static var MVP_MATRIX:String = "MVP_MATRIX";
    public static var MODEL_MATRIX:String = "MODEL_MATRIX";
    public static var VIEW_MATRIX:String = "VIEW_MATRIX";
    public static var PROJECTION_MATRIX:String = "PROJECTION_MATRIX";
    public static var PROJECTION_VIEW_MATRIX:String = "VP_MATRIX";
    public static var NORMAL_MATRIX:String = "NORMAL_MATRIX";
    public static var JOINT_TRANSFORMS:String = "JOINT_TRANSFORMS";

    public static var TEXTURE:String = "TEXTURE";
}