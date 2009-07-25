module main;

import
        Network, Global;

import
        Serialize;

import
        tango.io.Stdout,
        Int = tango.text.convert.Integer,
        tango.util.ArgParser;

void main(string[] args)
{
    if(args.length == 1)
        Stdout("Please specify input files").newline;
    else
    {
        auto parser = new ArgParser;
        string trainFile, testFile, networkFile;
        int iterations = 0;
        
        parser.bind("-", "tr=", (string value) {
            trainFile = value;
        });
        
        parser.bind("-", "ts=", (string value) {
            testFile = value;
        });
        
        parser.bind("-", "nw=", (string value) {
            networkFile = value;
        });
        
        parser.bind("-", "it=", (string value) {
            iterations = Int.toInt(value);
        });
        
        parser.parse(args[1..$]);

        Network network;
        
        if (networkFile !is null)
            network = (new NetworkLoader(networkFile)).traverseNetwork;
        else if (trainFile !is null)
            network = new Network(trainFile, iterations);
       
        if (network !is null)
            network.test(testFile);
    }
}