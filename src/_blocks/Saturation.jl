export Saturation

mutable struct Saturation <: AbstractBlock
    inport::AbstractInPort
    outport::AbstractOutPort
    upperlimit::Parameter
    lowerlimit::Parameter

    function Saturation(; inport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort(),
        upperlimit = Float64(0),
        lowerlimit = Float64(0))
        blk = new()
        blk.upperlimit = upperlimit
        blk.lowerlimit = lowerlimit
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::Saturation)
    i = expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))

    x = expr_refvalue(blk.inport.var)
    upperlimit = expr_refvalue(blk.upperlimit)
    lowerlimit = expr_refvalue(blk.lowerlimit)

    b = expr_setvalue(blk.outport.var, quote
        if $x <= $lowerlimit
            $lowerlimit
        elseif $x >= $upperlimit
            $upperlimit
        else
            $x
        end
    end)

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i, b, o...)
end

function next(blk::Saturation)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::Saturation)
    blk.inport
end

function defaultOutPort(blk::Saturation)
    blk.outport
end

