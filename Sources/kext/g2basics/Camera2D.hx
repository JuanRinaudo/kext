package kext.g2basics;

import kha.Image;

class CameraLayer {

    public var elements:Array<Basic>;
    public var camera:Camera2D;

    public function new(camera:Camera2D) {
        elements = [];
        this.camera = camera;
    }

    public function add(sprite:Basic) {
        elements.push(sprite);
    }

    public function remove(sprite:Basic) {
        elements.remove(sprite);
    }

	public function iterator()
	{
		return elements.iterator();
	}

}

class Camera2D extends Basic {

    public var transform:Transform2D;

    public var defaultLayer:CameraLayer;
    private var layers:Array<CameraLayer>;

    public function new(x:Float, y:Float)
    {
        super();

        transform = Transform2D.fromFloats(0, 0);

        defaultLayer = new CameraLayer(this);
        layers = [defaultLayer];
    }

    public function createLayer(layerIndex:Int = -1):CameraLayer
    {
        var layer:CameraLayer = new CameraLayer(this);
        layers.insert(layerIndex, layer);
        return layer;
    }

    public function moveLayer(layer:CameraLayer, layerIndex:Int) {
        layers.remove(layer);
        layers.insert(layerIndex, layer);
    }

    public function add(basic:Basic, layer:CameraLayer = null)
    {
        if(layer == null) { layer = defaultLayer; }
        layer.add(basic);
    }

    public function remove(basic:Basic, layer:CameraLayer = null)
    {
        if(layer == null) {
            for(searchLayer in layers) { 
                if(searchLayer.elements.indexOf(basic) != -1) {
                    searchLayer.remove(basic);
                    return;
                }
            }
        } else {
            layer.remove(basic);
        }
    }

    override public function update(delta:Float)
    {
        for(layer in layers) {
            for(element in layer) {
                element.update(delta);
            }
        }
    }

    override public function render(backbuffer:Image)
    {
        backbuffer.g2.pushTransformation(transform.getMatrix());
        for(layer in layers) {
            for(element in layer) {
                element.render(backbuffer);
            }
        }
        backbuffer.g2.popTransformation();
    }

}