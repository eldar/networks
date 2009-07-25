module Patter;

import Global;

import tango.text.Util,
       tango.text.convert.Float;

import tango.io.Stdout;
public class Pattern
{
    private double[] _inputs;
    private double _output;
 
    public this(string value, int inputSize)
    {
        string[] line = value.split(SPLITTER);

        if (line.length == inputSize)
            line ~= "0";
        else if (line.length - 1 == inputSize)
            {}
        else
            throw new Exception("input does not match network configuration");
        
        _inputs = new double[inputSize];
        for (int i = 0; i < inputSize; i++)
            _inputs[i] = toFloat(line[i]);
        _output = toFloat(line[inputSize]);
    }
 
    public double[] inputs()
    {
        return _inputs;
    }
 
    public double output()
    {
        return _output;
    }
}