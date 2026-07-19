// Unit tests for age_proof circuit
// Run: nargo test

use crate::main;

#[test]
fn test_age_26_passes() {
    // birth_year=2000, current_year=2026 -> age 26 > 18
    let result = main(2000, 2026);
    assert(result == 1);
}

#[test(should_fail)]
fn test_age_exactly_18_fails() {
    // birth_year=2008, current_year=2026 -> age 18, NOT > 18
    // Expected: constraint failure (panic)
    main(2008, 2026);
}

#[test(should_fail)]
fn test_age_16_fails() {
    // birth_year=2010, current_year=2026 -> age 16
    // Expected: constraint failure (panic)
    main(2010, 2026);
}

#[test]
fn test_boundary_age_19_passes() {
    // birth_year=2007, current_year=2026 -> age 19 > 18
    let result = main(2007, 2026);
    assert(result == 1);
}

#[test]
fn test_centenarian_passes() {
    // Edge: birth_year=1920, current_year=2026 -> age 106
    let result = main(1920, 2026);
    assert(result == 1);
}

#[test(should_fail)]
fn test_future_birth_fails() {
    // Edge: birth_year=2030, current_year=2026 -> underflow
    main(2030, 2026);
}
