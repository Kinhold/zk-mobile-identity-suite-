#!/data/data/com.termux/files/usr/bin/bash
# benchmark.sh — On-device UltraHonk proving benchmark
# Requires: nargo 1.0.0-beta.21, bb 5.0.0-nightly.20260324
# Run from: zk-mobile-identity-suite-/age-proof/

set -euo pipefail

CIRCUIT_NAME="age_proof"
TARGET_DIR="./target"
WITNESS_DIR="${TARGET_DIR}/${CIRCUIT_NAME}"
PROOF_FILE="${TARGET_DIR}/proof"
VK_FILE="${TARGET_DIR}/vk"
BENCH_LOG="${TARGET_DIR}/benchmark.log"

# Ensure clean target
rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

echo "=== ZK MOBILE IDENTITY SUITE — Phase 1 Benchmark ===" | tee "${BENCH_LOG}"
echo "Device: $(getprop ro.product.model)" | tee -a "${BENCH_LOG}"
echo "Timestamp: $(date -Iseconds)" | tee -a "${BENCH_LOG}"
echo "" | tee -a "${BENCH_LOG}"
# --- Step 1: Compile ---
echo "[1/4] Compiling circuit..." | tee -a "${BENCH_LOG}"
COMPILE_START=$(date +%s%N)
nargo compile
COMPILE_END=$(date +%s%N)
COMPILE_MS=$(( (COMPILE_END - COMPILE_START) / 1000000 ))
echo "  compile_time_ms: ${COMPILE_MS}" | tee -a "${BENCH_LOG}"

# --- Step 2: Witness Generation ---
echo "[2/4] Generating witness (birth_year=2000, current_year=2026)..." | tee -a "${BENCH_LOG}"
WITNESS_START=$(date +%s%N)
nargo execute witness
WITNESS_END=$(date +%s%N)
WITNESS_MS=$(( (WITNESS_END - WITNESS_START) / 1000000 ))
echo "  witness_gen_time_ms: ${WITNESS_MS}" | tee -a "${BENCH_LOG}"

# --- Step 3: Proving ---
echo "[3/4] Proving..." | tee -a "${BENCH_LOG}"
PROVE_START=$(date +%s%N)
bb prove --scheme ultra_honk -b "${TARGET_DIR}/${CIRCUIT_NAME}.json" -w "${WITNESS_DIR}.gz" -o "${PROOF_FILE}" -k "${VK_FILE}"
PROVE_END=$(date +%s%N)
PROVE_MS=$(( (PROVE_END - PROVE_START) / 1000000 ))
echo "  prove_time_ms: ${PROVE_MS}" | tee -a "${BENCH_LOG}"

# --- Step 4: Verify ---
echo "[4/4] Verifying proof..." | tee -a "${BENCH_LOG}"
VERIFY_START=$(date +%s%N)
bb verify --scheme ultra_honk -p "${PROOF_FILE}" -k "${VK_FILE}"
VERIFY_END=$(date +%s%N)
VERIFY_MS=$(( (VERIFY_END - VERIFY_START) / 1000000 ))
echo "  verify_time_ms: ${VERIFY_MS}" | tee -a "${BENCH_LOG}"

# --- Memory Sampling (best-effort via /proc) ---
echo "" | tee -a "${BENCH_LOG}"
echo "[Memory] Peak RSS estimates (kB):" | tee -a "${BENCH_LOG}"
echo "  (Run 'time -v' prefix for accurate maxrss if available)" | tee -a "${BENCH_LOG}"

# --- Summary ---
echo "" | tee -a "${BENCH_LOG}"
echo "=== BENCHMARK SUMMARY ===" | tee -a "${BENCH_LOG}"
echo "compile_time_ms: ${COMPILE_MS}" | tee -a "${BENCH_LOG}"
echo "witness_gen_time_ms: ${WITNESS_MS}" | tee -a "${BENCH_LOG}"
echo "prove_time_ms: ${PROVE_MS}" | tee -a "${BENCH_LOG}"
echo "verify_time_ms: ${VERIFY_MS}" | tee -a "${BENCH_LOG}"
echo "" | tee -a "${BENCH_LOG}"
echo "Artifacts:" | tee -a "${BENCH_LOG}"
echo "  Circuit JSON: ${TARGET_DIR}/${CIRCUIT_NAME}.json" | tee -a "${BENCH_LOG}"
echo "  Witness: ${WITNESS_DIR}.gz" | tee -a "${BENCH_LOG}"
echo "  Proof: ${PROOF_FILE}" | tee -a "${BENCH_LOG}"
echo "  VK: ${VK_FILE}" | tee -a "${BENCH_LOG}"
echo "  Log: ${BENCH_LOG}" | tee -a "${BENCH_LOG}"

echo ""
echo "Benchmark complete. Log saved to ${BENCH_LOG}"
