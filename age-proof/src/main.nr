mod tests;
// age_proof: Prove age > 18 without revealing birth_year
// Constraint budget: minimal. Memory target: <10MB witness.

fn main(birth_year: Field, current_year: pub Field) -> pub Field {
    // --- UNPACKING ---
    // Convert Field to u32 for arithmetic comparison.
    // Field to u32 is safe here because years are bounded [1900, 2100].
    let birth: u32 = birth_year as u32;
    let current: u32 = current_year as u32;

    // --- ARITHMETIC ---
    // age = current - birth
    // u32 subtraction: if birth > current, underflow panics (constraint failure)
    let age: u32 = current - birth;

    // --- THRESHOLD ASSERTION ---
    // Prove age > 18, i.e., age >= 19
    // assert(age >= 19) compiles to range-check + comparison constraints
    assert(age >= 19);

    // --- RETURN ---
    // 1 = proven over-18. Circuit fails entirely if assertion false.
    // Returning Field preserves type consistency with caller expectations.
    1
}
