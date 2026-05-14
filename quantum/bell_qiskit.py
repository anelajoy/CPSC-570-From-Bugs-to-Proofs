"""Starter template for the Qiskit part of the quantum homework.

Run with:
    python3 bell_qiskit.py
"""

from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator


SHOTS = 1024


def build_bell_circuit(measure: bool = True) -> QuantumCircuit:
    """Build the standard two-qubit Bell-state circuit."""
    circuit = QuantumCircuit(2, 2 if measure else 0)

    # TODO Q1: create (|00> + |11>) / sqrt(2).
    # Hint: apply H to qubit 0, then CX from qubit 0 to qubit 1.

    if measure:
        circuit.measure([0, 1], [0, 1])

    return circuit


def build_phase_modified_circuit(measure: bool = True) -> QuantumCircuit:
    """Build the Bell circuit with an added phase change before measurement."""
    circuit = QuantumCircuit(2, 2 if measure else 0)

    # TODO Q2: build the Bell state, then apply Z to qubit 0.
    # Hint: the Z gate changes phase, but computational-basis counts may match.

    if measure:
        circuit.measure([0, 1], [0, 1])

    return circuit


def build_equivalent_bell_circuit(measure: bool = True) -> QuantumCircuit:
    """Build a different-looking circuit intended to produce the same Bell state."""
    circuit = QuantumCircuit(2, 2 if measure else 0)

    # TODO Q3: create the same Bell state using a different gate sequence.
    # You may add gate pairs that cancel, or use another valid decomposition.

    if measure:
        circuit.measure([0, 1], [0, 1])

    return circuit


def simulate(circuit: QuantumCircuit, shots: int = SHOTS) -> dict[str, int]:
    """Run a measured circuit on the Aer simulator and return measurement counts."""
    simulator = AerSimulator()
    compiled = transpile(circuit, simulator)
    result = simulator.run(compiled, shots=shots).result()
    return result.get_counts()


def main() -> None:
    bell = build_bell_circuit()
    phase_modified = build_phase_modified_circuit()
    equivalent = build_equivalent_bell_circuit()

    print("=== Bell circuit ===")
    print(bell)
    print(simulate(bell))

    print("\n=== Phase-modified circuit ===")
    print(phase_modified)
    print(simulate(phase_modified))

    print("\n=== Candidate equivalent Bell circuit ===")
    print(equivalent)
    print(simulate(equivalent))


if __name__ == "__main__":
    main()
