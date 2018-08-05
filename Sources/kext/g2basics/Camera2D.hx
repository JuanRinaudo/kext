package kext.g2basics;

import kha.Image;

class Layer {

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

    public var defaultLayer:Layer;
    private var layers:Array<Layer>;

    public function new(x:Float, y:Float)
    {
        super();

        transform = Transform2D.fromFloats(0, 0);

        defaultLayer = new Layer(this);
        layers = [defaultLayer];
    }

    public function createLayer(layerIndex:Int = -1):Layer
    {
        var layer:Layer = new Layer(this);
        layers.insert(layerIndex, layer);
        return layer;
    }

    public function add(sprite:Basic, layer:Layer = null)
    {
        if(layer == null) { layer = defaultLayer; }
        layer.add(sprite);
    }

    public function remove(sprite:BasicSprite, layer:Layer = null)
    {
        if(layer == null) {
            for(searchLayer in layers) { 
                if(searchLayer.elements.indexOf(sprite) != -1) {
                    searchLayer.remove(sprite);
                    return;
                }
            }
        } else {
            layer.remove(sprite);
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