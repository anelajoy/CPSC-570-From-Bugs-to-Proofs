# Quantum Homework: Qiskit and PyZX

## Overview

This assignment introduces two complementary tools for quantum programs:

- **Qiskit** for building, simulating, and inspecting quantum circuits.
- **PyZX** for simplifying circuits and checking equivalence using ZX-calculus rewrites.

You will first complete a Qiskit starter file to implement and test a small circuit. Then you will complete a PyZX starter file to recreate the circuit, simplify it, and explain what the simplification preserves.

## Setup

Start from the provided templates:

- `bell_qiskit.py`
- `bell_pyzx.py`

The templates contain function stubs and TODO comments for the questions below. Create a Python environment and install the required packages:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install qiskit qiskit-aer pyzx matplotlib
```

If your machine has trouble installing optional drawing dependencies, you may skip circuit diagrams and submit text output instead.

## Part 1: Qiskit Circuit Construction and Simulation

### Q1: Build a Bell-state circuit

Complete `build_bell_circuit` in `bell_qiskit.py` so that it constructs a two-qubit Bell-state circuit:

1. Apply a Hadamard gate to qubit 0.
2. Apply a CNOT gate with qubit 0 as the control and qubit 1 as the target.
3. Measure both qubits.

Run the circuit on a simulator for at least 1024 shots. Submit the circuit drawing or printed circuit, the measurement counts, and a short explanation of why the counts should be concentrated on `00` and `11`.

### Q2: Add a phase change

Complete `build_phase_modified_circuit` in `bell_qiskit.py` by inserting a `Z` gate on qubit 0 before measurement. Run the modified circuit on the simulator.

Answer:

1. Do the measurement counts change in the computational basis?
2. What changed about the quantum state even if the measurement counts look the same?
3. Why is this an example of information that can be hidden from a single measurement basis?

### Q3: Compare two circuits

Complete `build_equivalent_bell_circuit` in `bell_qiskit.py` with a second circuit that creates the same Bell state using a different gate sequence. For example, you may use identities such as pairs of inverse gates or a different decomposition of a controlled operation.

Submit both circuits and explain whether your simulator results are enough to prove the circuits are equivalent. If not, explain what kind of evidence or tool would make the equivalence claim stronger.

## Part 2: PyZX Simplification and Equivalence

### Q4: Load or recreate the circuit in PyZX

Complete `build_bell_circuit` in `bell_pyzx.py` so that it represents your Bell-state circuit in PyZX. You may either:

- Convert from a Qiskit circuit if your installed versions support it, or
- Recreate the circuit directly using PyZX's circuit API.

Print the circuit's basic statistics, such as gate count and two-qubit gate count.

### Q5: Simplify the circuit

Use the `simplify` helper in `bell_pyzx.py` to convert the circuit to a ZX graph, run PyZX simplification, and extract a circuit back from the simplified graph.

Submit:

1. The original circuit statistics.
2. The simplified circuit statistics.
3. The simplified circuit, printed as text or saved as an image.
4. A brief explanation of which gates or structures were simplified.

### Q6: Check equivalence

Use `check_equivalent` in `bell_pyzx.py` to compare your original circuit and simplified circuit. If PyZX reports them as equivalent, explain what that means mathematically. If it does not, describe what failed and what additional debugging you performed.

Then compare the original Bell-state circuit with the phase-modified circuit from Q2. Explain why these circuits may have similar measurement counts but should not be considered the same circuit.

## Submission

Submit:

- `bell_qiskit.py`
- `bell_pyzx.py`
- A short write-up as `README.md` or PDF with your answers to Q1-Q6
- Any generated images you reference in the write-up

Your write-up should include enough command output that the grader can see what you ran, but it does not need to include full package installation logs.
