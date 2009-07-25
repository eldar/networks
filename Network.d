module Network;

import Global, Pattern, Layer, Neuron, Serialize;

import tango.io.Stdout,
       tango.math.Math,
       tango.io.device.File,
       tango.io.stream.Lines,
       tango.io.stream.TextFile,
       Float = tango.text.convert.Float,
       tango.text.Util;

      
public class Network
{
    private int _hiddenDims = 10;        // Number of hidden neurons.
    private int _inputDims = 10;        // Number of input neurons.
    private int _iteration;            // Current training iteration.
    private int _numOfIterations = 100_000;   // Restart training if iterations exceed this.
    private Layer _hidden;              // Collection of hidden neurons.
    private Layer _inputs;              // Collection of input neurons.
    private Pattern[] _patterns, _testPatterns;    // Collection of training patterns.
    private Neuron _output;            // output neuron.
    private Random _rnd; // Global random number generator.

    private bool _inTrainFile = true;

    public this()
    {
        _rnd = new Random;
    }
    
    public this(string trainFile, int iterations = 0)
    {
        this();
        if(iterations > 0)
            _numOfIterations = iterations;
        
        findDimensions(trainFile);
        _patterns = loadPatterns(trainFile);

        initialise();
        train();
        save();
    }
    
    public this(Layer input, Layer hidden, Neuron output)
    {
        _inputs = input;
        _hidden = hidden;
        _output = output;
        
        _inputDims = input.base.length;
    }
    
    void findDimensions(string fileName)
    {
        auto file = new File (fileName);
        auto lines = new Lines!(char) (file);
        string line;
        lines.readln(line);
        string[] values = line.split(SPLITTER);
        _inputDims = values.length - 1;
        file.close();
    }

    private void train()
    {
        double error, normError;
//        do
//        {
for(_iteration = 0; _iteration < _numOfIterations; _iteration++) {
            error = 0;
            foreach (pattern; _patterns)
            {
                double delta = pattern.output - Activate(pattern);
                AdjustWeights(delta);
                error += abs(delta); // error += delta ^ 2
            }
            normError = error/_patterns.length;
            Stdout.formatln("Iteration {0}\tError {1} %", _iteration, normError*100);
}
//            _iteration++;
//            if (_iteration > _restartAfter)
//                Initialise();
//        } while (normError > 0.0310);
        
        Stdout.formatln("Number of iterations {0}", _iteration);
            foreach (pattern; _patterns)
            {
                double pred = Activate(pattern);
                double delta = pattern.output - pred;
                error += abs(delta);
                Stdout(pattern.output, pred, delta).newline;
            }        
    }

    public void test(string testFile = null)
    {
        if (testFile != null) {
            _inTrainFile = false;
            _testPatterns = loadPatterns(testFile);
        }

        scope outFile = new TextFileOutput("output.txt", File.WriteCreate);
        Pattern[] patterns;
        if (_inTrainFile)
            patterns = _patterns;
        else
            patterns = _testPatterns;
            
        foreach (pattern; patterns)
        {
            double prediction = Activate(pattern);
            outFile(Float.toString(prediction, 4)).newline;
        }
    }
    
    private double Activate(Pattern pattern)
    {
        for (int i = 0; i < pattern.inputs.length; i++)
            _inputs.base[i].output = pattern.inputs[i];

        foreach (Neuron neuron; _hidden.base)
            neuron.Activate();

        _output.Activate();
        return _output.output;
    }
 
    private void AdjustWeights(double delta)
    {
        _output.AdjustWeights(delta);
        foreach (Neuron neuron; _hidden.base)
            neuron.AdjustWeights(_output.ErrorFeedback(neuron));
    }
 
    private void initialise()
    {
        _inputs = new Layer(_inputDims);
        _hidden = new Layer(2, _inputs, _rnd);
        _output = new Neuron(_hidden, _rnd);
        _iteration = 0;
        Stdout.formatln("Network Initialised");
    }
 
    private Pattern[] loadPatterns(string fileName)
    {
        auto file = new File (fileName);
        Pattern[] patterns;
        foreach (line; new Lines!(char) (file)) {
            if (line.length == 0)
                continue;

            patterns ~= new Pattern(line, _inputDims);
        }
        
        file.close();
        
        return patterns;
    }
    
    void save(string fileName = "output.nnc")
    {
        auto saver = new NetworkSaver;
        saver(_inputs, "input");
        saver(_hidden, "hidden");
        saver(_output, "output");
        
//        Stdout(saver.output).newline;
        saver.write(fileName);
    }
}

/* 
    private void Test()
    {
        Stdout.formatln("\nBegin network testing\nPress Ctrl C to exit\n");
        try
        {
            Stdout("input x, y: ").newline;
//            string values = Console.ReadLine() + ",0";
            string values = "0.1, 0.7, 0";
            Stdout.formatln("{0:0}\n", Activate(new Pattern(values, _inputDims)));
        }
        catch (Exception e)
        {
            Stdout.formatln(e.msg);
        }
    }
*/