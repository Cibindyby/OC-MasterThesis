using Base: @kwdef

@enum NodeType begin
    InputNode
    ComputationalNode
    OutputNode
end

# Implementierung der Display-Funktionalität
function Base.show(io::IO, node_type::NodeType)
    if node_type == InputNode
        print(io, "Input_Node")
    elseif node_type == ComputationalNode
        print(io, "Computational_Node")
    elseif node_type == OutputNode
        print(io, "Output_Node")
    end
end

# Implementierung der string Konvertierung
Base.string(node_type::NodeType) = sprint(show, node_type)