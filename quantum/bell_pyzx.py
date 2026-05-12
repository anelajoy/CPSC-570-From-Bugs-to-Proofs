"""Starter template for the PyZX part of the quantum homework.

Run with:
    python3 bell_pyzx.py
"""

import pyzx as zx


def build_bell_circuit() -> zx.Circuit:
    """Represent the standard Bell-state circuit in PyZX."""
    circuit = zx.Circuit(2)

    # TODO Q4: recreate the Qiskit Bell circuit in PyZX.
    # Hint: add an H gate on qubit 0 and a CNOT from qubit 0 to qubit 1.
    # Example form:
    # circuit.add_gate(...)


    return circuit


def build_phase_modified_circuit() -> zx.Circuit:
    """Represent the phase-modified Bell circuit from Qiskit Q2."""
    circuit = zx.Circuit(2)

    # TODO Q6: recreate the Bell circuit, then add a Z gate on qubit 0.

    return circuit


def print_stats(label: str, circuit: zx.Circuit) -> None:
    """Print basic circuit information for the write-up."""
    print(f"=== {label} ===")
    print(circuit)
    print(f"qubits: {circuit.qubits}")
    print(f"gates: {len(circuit.gates)}")
    print(f"two-qubit gates: {circuit.twoqubitcount()}")
    print()


def simplify(circuit: zx.Circuit) -> zx.Circuit:
    """Convert a PyZX circuit to a graph, simplify it, and extract a circuit."""
    graph = circuit.to_graph()

    # TODO Q5: try one or more PyZX simplification routines.
    # full_reduce is a good starting point.

    return zx.extract_circuit(graph)


def check_equivalent(left: zx.Circuit, right: zx.Circuit) -> bool:
    """Return True when PyZX can show that two circuits are equivalent."""
    # TODO Q6: use a PyZX equivalence or tensor-comparison helper here.
    # The arguments are kept so the intended interface is clear.
    raise NotImplementedError("complete check_equivalent for Q6")


def main() -> None:
    original = build_bell_circuit()
    phase_modified = build_phase_modified_circuit()
    simplified = simplify(original)

    print_stats("Original Bell circuit", original)
    print_stats("Simplified Bell circuit", simplified)
    print_stats("Phase-modified Bell circuit", phase_modified)

    print("original equivalent to simplified:")
    print(check_equivalent(original, simplified))

    print("\noriginal equivalent to phase-modified:")
    print(check_equivalent(original, phase_modified))


if __name__ == "__main__":
    main()
