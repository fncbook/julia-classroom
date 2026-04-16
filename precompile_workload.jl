using BoundaryValueDiffEq, FNCFunctions, LaTeXStrings, LinearAlgebra, NLsolve, OrdinaryDiffEq, Plots, Polynomials, PrettyTables, SciMLBase, SparseArrays

A = rand(10, 10)
B = A[:, 1:4]
cholesky(A'*A)
cond(A)
diag(A)
diagm(0 => rand(10))
dot(rand(10), rand(10))
eigen(A)
eigvals(A)
lu(A)
norm(rand(4))
norm(A)
normalize(rand(4))
opnorm(A)
qr(B)
rank(A)
svd(B)
svdvals(B)

FNC.backsub(triu(A), randn(10))
FNC.forwardsub(tril(A), rand(10))
FNC.lufact(A)
FNC.plufact(A)
FNC.horner([1., 2, 3], 0.)
FNC.lsqrfact(B, rand(10))

FNC.newton(x->x^2 - 2, x->2x, 1.0)
FNC.secant(x->x^2 - 2, 1.0, 2.0)
f(x) = [x[1]^2 - 3, x[2]^2 - 2]
FNC.newtonsys(f, x->[2x[1] 0; 0 2x[2]], [1.0, 1.0])
FNC.levenberg(f, [1.0, 1.0])
nlsolve(f, [1.0, 1.0])

FNC.fdweights(-2:1, 2)
FNC.hatfun(-2:1, 2)
FNC.trapezoid(exp, 0.0, 1.0, 50)
FNC.intadapt(exp, 0.0, 1.0, 1e-5)
# quadgk(exp, 0.0, 1.0, rtol=1e-5)
FNC.plinterp(1:4, rand(4))(2)
FNC.spinterp(1:4, rand(4))(1)
# Spline1D(1:4, rand(4))(2)

plot(1:4, rand(4))
plot!(5:8, rand(4))
scatter(1:10, rand(10))
scatter!(1:10, rand(10))
annotate!([(7,3,L"(7,3)"),(3,7,text("hey", 14, :left, :top, :green))])
xlims!(0, 10)
ylims!(0, 10)

p = Polynomial([1., 2, 3])
coeffs(p)
p(0.0)
fromroots([1, 2, 3])
Polynomials.roots(p)
Polynomials.fit([1, 2, 3], [4, 5, 6], 1)

pretty_table((n=1:5, err2=rand(5), err4=rand(5)),;
    column_labels=["n", "IE2 error", "RK4 error"], backend=:html)

ivp = ODEProblem((u, p, t) -> -u, 1.0, (0.0, 1.0))
for sol in [FNC.ab4, FNC.am2, FNC.euler, FNC.ie2, FNC.rk4]
    sol(ivp, 10)
end
FNC.rk23(ivp, 1e-5)
solve(ivp)

A = diagm(1 .+ rand(10))
FNC.arnoldi(A, rand(10), 4)
FNC.poweriter(A, 4)
FNC.inviter(A, 0, 4)
# gmres(A, rand(10))
# minres(A, rand(10))
# cg(A, rand(10))
# eigs(A)
nnz(sparse(A))
spy(sparse(A))

FNC.ccint(exp, 10)
FNC.glint(exp, 10)
FNC.intinf(x->exp(-x^2), 1e-4)
FNC.intsing(x->1/sqrt(x), 1e-4)
FNC.polyinterp(1:4, rand(4))(2)
FNC.triginterp(1:4, rand(4))(2)


function ode!(f, y, λ, r)
    f[1] = y[2]
    f[2] = λ / y[1]^2 - y[2] / r
    return nothing
end;
function bc!(g, y, λ, r)    # output, solution vector, parameter, indep. var.
    g[1] = y[1][2]          # first node, second component = 0
    g[2] = y[end][1] - 1    # last node, first component = 1
    return nothing
end;
bvp = BVProblem(ode!, bc!, [1, 0], (1e-15, 1.0), 0.6)
y = solve(bvp, Shooting(Tsit5()))

λ = 0.6
ϕ = (r, w, dwdr) -> λ / w^2 - dwdr / r;
a, b = eps(), 1.0;
gg₁(w, dw) = dw       # w' = 0 at left
gg₂(w, dw) = w - 1    # w = 1 at right
r, w, dw_dx = FNC.shoot(ϕ, (a, b), gg₁, gg₂, [0.8, 0])

p = x -> -cos(x);
q = sin;
r = x -> 0;      # function, not value
x, u = FNC.bvplin(p, q, r, [0, 3π / 2], 1, exp(-1), 30);

ϕ = (t, θ, ω) -> -0.05 * ω - sin(θ);
gg₁(u, du) = u - 2.5
gg₂(u, du) = u + 2;
init = collect(range(2.5, -2, length = 101));
t, θ = FNC.bvp(ϕ, [0, 5], gg₁, gg₂, init)

c = x -> x^2;
q = x -> 4;
x, u = FNC.fem(c, q, sinpi, 0, 1, 50)

FNC.diffcheb(4, [-1, 1])
FNC.diffmat2(4, [-1, 1])

FNC.diffper(10, [0, 1])
ϕ = (t, x, u, uₓ, uₓₓ) -> uₓₓ
g₁ = (u, uₓ) -> u
g₂ = (u, uₓ) -> u - 2;
init = x -> 1 + sinpi(x/2) + 3 * (1-x^2) * exp(-4x^2);
x, u = FNC.parabolic(ϕ, (-1, 1), 60, g₁, g₂, (0, 0.75), init);

m, n = (20, 15)
x, Dx, Dxx = FNC.diffper(m, [-1, 1])
y, Dy, Dyy = FNC.diffper(n, [-1, 1])
mtx, X, Y, unvec, _ = FNC.tensorgrid(x, y);

ff = (x, y) -> -sin(3x * y - 4y) * (9y^2 + (3x - 4)^2);
gg = (x, y) -> sin(3x * y - 4y);
xspan = [0, 1];
yspan = [0, 2];
FNC.poissonfd(ff, gg, 40, xspan, 60, yspan);

λ = 1.5
ϕ = (X, Y, U, Ux, Uxx, Uy, Uyy) -> @. Uxx + Uyy - λ / (U + 1)^2;
gg = (x, y) -> 0;
FNC.elliptic(ϕ, gg, 15, [0, 2.5], 8, [0, 1]);
