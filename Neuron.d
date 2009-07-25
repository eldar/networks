module Neuron;

import Global, Layer;

import tango.math.Math;


public class Neuron
{
    private double _bias = 0;                       // Bias value.
    private double _error = 0;                      // Sum of error.
    private double _input = 0;                      // Sum of inputs.
    private double _lambda = 3;                // Steepness of sigmoid curve.
    private double _learnRate = 0.025;            // Learning rate.
    private double _output = double.min;   // Preset value of neuron.
    private Weight[] _weights;              // Collection of weights to inputs.
    
    private uint learnCorr;
    
    public this() { }
 
    public this(Layer inputs, Random rnd)
    {
        foreach (Neuron input; inputs.base)
        {
            auto w = new Weight();
            w.input = input;
            w.value = rnd.uniform!(double) * 2 - 1;
            _weights ~= w;
        }
        
        learnCorr = 0;
    }
 
    public void Activate()
    {
        _input = 0;
        foreach (w; _weights)
            _input += w.value * w.input.output;
    }
 
    public double ErrorFeedback(Neuron input)
    {
//        Weight w = _weights.Find(delegate(Weight t) { return t.input == input; });
        Weight w;
        foreach(wi; _weights)
            if(wi.input is input)
                w = wi;
        return _error * derivative() * w.value;
    }
 
    public void AdjustWeights(double value)
    {
        _error = value;
        for (int i = 0; i < _weights.length; i++)
            _weights[i].value += _error * derivative() * _learnRate * _weights[i].input.output;

        _bias += _error * derivative() * _learnRate;
        
//        learnCorr++;
//s        _learnRate -= 0.000000001/learnCorr;
    }
 
    private double derivative()
    {
        double activation = output;
        return activation * (1 - activation);
    }
 
    public double output()
    {
        if (_output != double.min)
            return _output;
        
        return 1 / (1 + exp(-_lambda * (_input + _bias)));
    }
    
    public void output(double value)
    {
        _output = value;
    }

    public double bias() { return _bias; }
    
    public void bias(double value) { _bias = value; }
    
    public Weight[] weights() { return _weights; }
    
    typeof(this) opCatAssign(Weight w)
    {
        _weights ~= w;
        return this;
    }
}

public class Weight
{
    public Neuron input;
    public double value = 0;
    this()
    {
        value = 0;
    }
}