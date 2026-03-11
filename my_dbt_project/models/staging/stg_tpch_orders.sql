select 
    o_orderkey as orderkey,
    o_custkey as custkey,
    o_orderstatus as orderstatus,
    o_totalprice as totalprice,
    o_orderdate as orderdate
from 
    {{ source('tpch', 'orders') }}