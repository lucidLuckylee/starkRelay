from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

from stark_verifier.air.stark_proof import (
    ParsedOodFrame,
    Queries,
    StarkProof,
)
from stark_verifier.air.air_instance import AirInstance
from stark_verifier.air.transitions.frame import EvaluationFrame
from stark_verifier.utils import Vec

struct TraceOodFrame {
    main_frame: EvaluationFrame,
    aux_frame: EvaluationFrame,
}

struct Channel {
    // Trace queries
    trace_roots: Uint256*,
    // Constraint queries
    constraint_root: Uint256,
    // FRI proof
    fri_roots: Uint256*,
    // OOD frame
    ood_trace_frame: TraceOodFrame,
    ood_constraint_evaluations: Vec,
    // Query PoW nonce
    pow_nonce: felt,
}

struct Table {
    data: felt*,
    row_width: felt,
}

func channel_new{
    bitwise_ptr: BitwiseBuiltin*,
}(
    air: AirInstance,
    proof: StarkProof,
) -> (channel: Channel) {
    // Parsed commitments
    tempvar trace_roots = proof.commitments.trace_roots;
    tempvar constraint_root = proof.commitments.constraint_root;
    tempvar fri_roots = proof.commitments.fri_roots;

    // Parsed ood_frame
    tempvar ood_constraint_evaluations = proof.ood_frame.evaluations;
    tempvar ood_trace_frame = TraceOodFrame(
        main_frame=proof.ood_frame.main_frame,
        aux_frame=proof.ood_frame.aux_frame,
    );

    tempvar channel = Channel(
        trace_roots=trace_roots,
        constraint_root=constraint_root,
        fri_roots=fri_roots,
        ood_trace_frame=ood_trace_frame,
        ood_constraint_evaluations=ood_constraint_evaluations,
        pow_nonce=proof.pow_nonce,
    );
    return (channel=channel);
}

func read_trace_commitments{channel: Channel}() -> (res: Uint256*) {
    return (res=channel.trace_roots);
}

func read_constraint_commitment{channel: Channel}() -> (res: Uint256) {
    return (res=channel.constraint_root);
}

func read_ood_trace_frame{
    channel: Channel
}() -> (res1: EvaluationFrame, res2: EvaluationFrame) {
    return (
        res1=channel.ood_trace_frame.main_frame,
        res2=channel.ood_trace_frame.aux_frame,
    );
}

func read_ood_constraint_evaluations{channel: Channel}() -> (res: Vec) {
    return (res=channel.ood_constraint_evaluations);
}

func read_pow_nonce{channel: Channel}() -> (res: felt) {
    return (res=channel.pow_nonce);
}

func read_queried_trace_states{
    channel: Channel,
}(
    positions: felt*,
) -> (main_states: Table, aux_states: Table) {
    alloc_locals;
    local trace_queries : felt*;
    local paths : felt*;
    local main_states : Table;
    local aux_states : Table;
    %{
        # TODO: Load trace queries and proof paths
    %}
    // TODO: Authenticate proof paths

    return (main_states, aux_states);
}

func read_constraint_evaluations{
    channel: Channel
}(
    positions: felt*,
) -> (evaluations: Table) {
    alloc_locals;
    local constraint_queries : felt*;
    local paths : felt*;
    local evaluations : Table;
    %{
        # TODO: Load constraint queries and proof paths
    %}
    // TODO: Authenticate proof paths

    return (evaluations=evaluations);
}