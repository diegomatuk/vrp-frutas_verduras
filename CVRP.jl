
using JuMP, Cbc, MathOptInterface
const MOI= MathOptInterface
const MOIU = MathOptInterface.Utilities
using CSV
using Combinatorics
using MathOptInterface

modelo=Model(with_optimizer(Cbc.Optimizer))

A=CSV.read("/home/diegomatuk/snap/julia/Pruebas/distance_matrix_vrp_bodegas_sa.csv")

vehiculos=2
n=620
capacidad=[3500 12000]
demanda=CSV.read("/home/diegomatuk/snap/julia/Pruebas/demanda_bodegas.csv")[!,4]
demanda=vcat([0],demanda)

A

@variable(modelo,x[1:n,1:n,1:vehiculos],Bin)

@objective(modelo,Min,sum(A[i,j]*x[i,j,r] for i=1:n,j=1:n,r=1:vehiculos))


for j =2:n
            @constraint(modelo,sum(x[i,j,r] for i=1:n,r=1:vehiculos if i!=j)==1)
        end


for r=1:vehiculos
    @constraint(modelo,sum(x[1,j,r] for j=2:n)==1)
end
    

for j=1:n
    for r=1:vehiculos
        @constraint(modelo,sum(x[i,j,r]-x[j,i,r] for i=1:n if i!=j)==0)
    end
end

for r=1:vehiculos
    @constraint(modelo,sum(demanda[j]*x[i,j,r] for i=1:n,j=2:n if i!=j)<=capacidad[r])
end
    

s=[1:n;]
S=collect(powerset(s))



#  for s in S
#     @constraint(modelo,sum(x[i,j,r] for r=1:vehiculos, i in s, j in s)<=size(S)[1])
# end

for k=2:size(S,1)
    
@constraint(modelo,sum(x[i,j,r] for i in size(S[k],1), j in size(S[k],1),r=1:vehiculos if i!=j)<=size(S[k])[1]-1)
end

optimize!(modelo)

MathOptInterface.ResultStatusCode




