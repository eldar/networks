module Layer;

import Global, Neuron;

public class Layer
{
    Neuron[] base;
    
    public this(int size = 0)
    {
        for (int i = 0; i < size; i++)
            base ~= new Neuron();
    }
 
    public this(int size, Layer layer, Random rnd)
    {
        for (int i = 0; i < size; i++)
            base ~= new Neuron(layer, rnd);
    }
    
    typeof(this) opCatAssign(Neuron neuron)
    {
        base ~= neuron;
        return this;
    }
}