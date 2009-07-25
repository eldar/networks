module Serialize;

import Global, Layer, Neuron, Network;

import tango.text.xml.Document,
       tango.text.xml.DocPrinter,
       tango.io.stream.TextFile,
       tango.io.device.File,
       Float = tango.text.convert.Float,
       Int = tango.text.convert.Integer;

alias Document!(char) XmlDoc;
alias XmlDoc.Node XNode;

const int DEC = 10;

class NetworkSaver
{
private:
    int[Neuron] _neuronID;
    int _count = 0;
    
    XmlDoc _doc;
    
public:
    this()
    {
        _doc = new XmlDoc;
        _doc.header;
    }
    
    NetworkSaver opCall(Neuron neuron, string name = null, XmlDoc.Node parent = null)
    {
        int neurID = _count++;
        _neuronID[neuron] = neurID;

        if(parent is null)
            parent = _doc.tree;
        
        auto neurNode = parent.element   (null, "neuron")
                              .attribute (null, "id", Int.toString(neurID))
                              .attribute (null, "bias", Float.toString(neuron.bias, DEC));

        if (name !is null)
            neurNode.attribute (null, "name", name);

        foreach (w; neuron.weights) {
            neurNode.element   (null, "weight")
                    .attribute (null, "input", Int.toString(_neuronID[w.input]))
                    .attribute (null, "value", Float.toString(w.value, DEC));
        }
        
        return this;
    }
    
    NetworkSaver opCall(Layer layer, string name = "")
    {
        auto parent = _doc.tree;
        
        auto layerNode = parent.element   (null, "layer")
                               .attribute (null, "name", name);
              
        foreach (Neuron neuron; layer.base)
            opCall(neuron, null, layerNode);
        
        return this;
    }
    
    string output()
    {
        auto print = new DocPrinter!(char);
        return print(_doc);
    }
    
    void write(string fileName)
    {
         scope outFile = new TextFileOutput(fileName, File.WriteCreate);
         outFile(output());
    }
}

import tango.io.Stdout;

class NetworkLoader
{
private:
    XmlDoc _doc;
    XmlDoc.Node _root;
    Neuron[int] _neuron;

public:
    this(string fileName)
    {
        auto xml = cast(string) File.get(fileName);

        _doc = new XmlDoc;
        _doc.parse(xml);
        
        _root = _doc.tree;
    }
    
    Network traverseNetwork()
    {
        auto input = traverseLayer(_root, "input");
        auto hidden = traverseLayer(_root, "hidden");
        auto outputNode = _root.query.child("neuron").filter((_doc.Node node)
                               { auto attr = node.attributes.name(null, "name");
                                 return attr && attr.value == "output"; }).first.nodes[0];
                                 
        auto output = traverseNeuron(outputNode);
        
        return new Network(input, hidden, output);
    }
    
    Layer traverseLayer(XNode node, string layerName)
    {
        auto inputLayer = node.query.child("layer").filter((_doc.Node node)
                              { auto attr = node.attributes.name(null, "name");
                                return attr && attr.value == layerName; }).first.nodes[0];
        auto layer = new Layer;
        auto inputNeurons = inputLayer.query.child("neuron").dup;
        foreach(elem; inputNeurons)
            layer ~= traverseNeuron(elem);
        
        return layer;
    }
    
    Neuron traverseNeuron(XNode node)
    {
        int id = Int.toInt(node.attributes.name(null, "id").value);
        auto neuron = new Neuron;
        _neuron[id] = neuron;
        neuron.bias = Float.toFloat(node.attributes.name(null, "bias").value);
//        Stdout(id).newline;
            
        auto weightsQuery = node.query.child("weight");
        foreach(weightElem; weightsQuery) {
            auto w = new Weight;
            int inputId = Int.toInt(weightElem.attributes.name(null, "input").value);
            double value = Float.toFloat(weightElem.attributes.name(null, "value").value);
            w.input = _neuron[inputId];
            w.value = value;
//            Stdout.formatln("weight input={}, value={}", inputId, Float.toString(w.value, DEC));
            neuron ~= w;
        }
        
        return neuron;
    }
}