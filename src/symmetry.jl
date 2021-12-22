#helper functions to handle array types
_mattype(::Array{T}) where {T} = Matrix
_mattype(::CuArray{T}) where {T} = CuMatrix
_mattype(::Adjoint{T, CuArray{T, 2 ,B}}) where {T,B} = CuMatrix
_mattype(::Symmetric{T, CuArray{T, 2, B}}) where {T,B} = CuMatrix

_arraytype(::Array{T}) where {T} = Array
_arraytype(::CuArray{T}) where {T} = CuArray
_arraytype(::Diagonal{T, Vector{T}}) where {T} = Array
_arraytype(::Diagonal{T, CuArray{T, 1, B}}) where {T, B} = CuArray
_arraytype(::Z2tensor{T}) where {T} = Z2tensor
_arraytype(::Adjoint{T, Matrix{T}}) where {T} = Matrix
_arraytype(::Adjoint{T, CuArray{T, 2, B}}) where {T,B} = CuArray

getsymmetry(::AbstractArray) = Val(:none)
getsymmetry(::AbstractZ2Array) = Val(:Z2)

randinitial(::Val{:none}, atype, dtype, a...) = atype(rand(dtype, a...))
randinitial(::Val{:Z2}, atype, dtype, a...) = randZ2(atype, dtype, a...)
function randinitial(A::AbstractArray{T, N}, a...) where {T, N}
    atype = typeof(A) <: Union{Array, CuArray} ? _arraytype(A) : _arraytype(A.tensor[1])
    randinitial(getsymmetry(A), atype, T, a...)
end

Iinitial(::Val{:none}, atype, dtype, D) = atype{dtype}(I, D, D)
Iinitial(::Val{:Z2}, atype, dtype, D) = IZ2(atype, dtype, D)
function Iinitial(A::AbstractArray{T, N}, D) where {T, N}
    atype = typeof(A) <: Union{Array, CuArray} ? _arraytype(A) : _arraytype(A.tensor[1])
    Iinitial(getsymmetry(A), atype, ComplexF64, D)
end