using SignedDistanceFields
using Base.Test

T = true
F = false

@test_throws ArgumentError edf([])
@test_throws ArgumentError edf([T])

@test edf([T T]) == [0.0 0.0]
@test edf([T T F F F F]) == [0.0 0.0 1.0 2.0 3.0 4.0]
@test edf([F F T T F F]) == [2.0 1.0 0.0 0.0 1.0 2.0]
@test edf([F F F F T T]) == [4.0 3.0 2.0 1.0 0.0 0.0]
@test edf([F T F F T F]) == [1.0 0.0 1.0 1.0 0.0 1.0]

@test sdf([T T F F F F]) == [-2.0 -1.0   1.0  2.0  3.0  4.0]
@test sdf([F F T T F F]) == [ 2.0  1.0  -1.0 -1.0  1.0  2.0]
@test sdf([F F F F T T]) == [ 4.0  3.0   2.0  1.0 -1.0 -2.0]
@test sdf([F T F F T F]) == [ 1.0 -1.0   1.0  1.0 -1.0  1.0]

@test sdf([
	T F F;
	F F F;
	F F F
]) == [
	-1.0  1.0          2.0;
	 1.0  sqrt(2)      sqrt(1 + 4);
	 2.0  sqrt(1 + 4)  sqrt(4 + 4)
]

if VERSION < v"0.4.0-dev"
    bitrand(x...) = randbool(x...)
end


a = sdf(bitrand(20,20), 10, 10)
@test size(a) == (10,10)
a = edf(bitrand(20,20), 10, 10)
@test size(a) == (10,10)

if VERSION < v"0.4.0-dev"
	@test_throws ErrorException sdf(bitrand(20,20), 12, 10)
	@test_throws ErrorException edf(bitrand(20,20), 10, 12)
else
	@test_throws AssertionError sdf(bitrand(20,20), 12, 10)
	@test_throws AssertionError edf(bitrand(20,20), 10, 12)
end