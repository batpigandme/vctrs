context("test-type-bare")


test_that("ptype2 base methods are not inherited", {
  for (ptype in base_empty_types[-1]) {
    x <- new_vctr(ptype, class = "foobar", inherit_base_type = TRUE)
    expect_is(vec_ptype2(x, x), "foobar")
    expect_error(vec_ptype2(x, ptype), class = "vctrs_error_incompatible_type")
    expect_error(vec_ptype2(ptype, x), class = "vctrs_error_incompatible_type")
  }
})


# shape_match -------------------------------------------------------------

test_that("array dimensions are preserved", {
  mat1 <- matrix(lgl(), nrow = 1, ncol = 1)
  mat2 <- matrix(lgl(), nrow = 2, ncol = 2)
  mat3 <- matrix(lgl(), nrow = 2, ncol = 3)

  expect_equal(vec_ptype2(mat1, mat1), matrix(lgl(), nrow = 0, ncol = 1))
  expect_equal(vec_ptype2(mat1, mat2), matrix(lgl(), nrow = 0, ncol = 2))
  expect_error(vec_ptype2(mat2, mat3), "Incompatible")
})

test_that("shape_match()", {
  int <- function(...) array(NA_integer_, c(...))

  expect_identical(shape_match(integer(), int(5), int(10)), new_shape(integer()))
  expect_identical(shape_match(integer(), int(5, 1), int(10, 1)), new_shape(integer(), 1))
  expect_identical(shape_match(integer(), int(5, 1, 2), int(10, 1, 2)), new_shape(integer(), 1:2))
})

# vec_cast() --------------------------------------------------------------

# NULL

test_that("NULL is idempotent", {
  expect_equal(vec_cast(NULL, NULL), NULL)
  expect_equal(vec_cast(list(1:3), NULL), list(1:3))
})


# Logical

test_that("safe casts work as expected", {
  exp <- lgl(TRUE, FALSE)
  expect_equal(vec_cast(NULL, logical()), NULL)
  expect_equal(vec_cast(lgl(TRUE, FALSE), logical()), exp)
  expect_equal(vec_cast(int(1L, 0L), logical()), exp)
  expect_equal(vec_cast(dbl(1, 0), logical()), exp)
  expect_equal(vec_cast(chr("T", "F"), logical()), exp)
  expect_equal(vec_cast(chr("TRUE", "FALSE"), logical()), exp)
  expect_equal(vec_cast(chr("true", "false"), logical()), exp)
  expect_equal(vec_cast(list(1, 0), logical()), exp)
})

test_that("NA casts work as expected", {
  exp <- lgl(NA)
  to <- lgl()

  expect_equal(vec_cast(lgl(NA), to), exp)
  expect_equal(vec_cast(int(NA), to), exp)
  expect_equal(vec_cast(dbl(NA), to), exp)
  expect_equal(vec_cast(chr(NA), to), exp)
  expect_equal(vec_cast(list(NA), to), exp)
})

test_that("Shaped NA casts work as expected", {
  mat <- matrix
  exp_mat <- mat(lgl(NA))
  to_mat <- matrix(lgl())

  expect_equal(vec_cast(mat(lgl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(int(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(dbl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(chr(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(list(NA)), to_mat), exp_mat)
})

test_that("lossy casts generate warning", {
  expect_lossy(vec_cast(int(2L, 1L), lgl()),                lgl(TRUE, TRUE), x = int(),  to = lgl())
  expect_lossy(vec_cast(dbl(2, 1), lgl()),                  lgl(TRUE, TRUE), x = dbl(),  to = lgl())
  expect_lossy(vec_cast(chr("x", "TRUE"), lgl()),           lgl(NA, TRUE),   x = chr(),  to = lgl())
  expect_lossy(vec_cast(chr("t", "T"), lgl()),              lgl(NA, TRUE),   x = chr(),  to = lgl())
  expect_lossy(vec_cast(chr("f", "F"), lgl()),              lgl(NA, FALSE),  x = chr(),  to = lgl())
  expect_lossy(vec_cast(list(c(TRUE, FALSE), TRUE), lgl()), lgl(TRUE, TRUE), x = list(), to = lgl())
})

test_that("invalid casts generate error", {
  expect_error(vec_cast(factor("a"), logical()), class = "vctrs_error_incompatible_cast")
})

test_that("dimensionality matches output" ,{
  x1 <- matrix(TRUE, nrow = 1, ncol = 1)
  x2 <- matrix(1, nrow = 0, ncol = 2)
  expect_dim(vec_cast(x1, x2), c(1, 2))
  expect_dim(vec_cast(TRUE, x2), c(1, 2))

  x <- matrix(1, nrow = 2, ncol = 2)
  expect_error(vec_cast(x, logical()), class = "vctrs_error_incompatible_cast")
})


# Integer

test_that("safe casts work as expected", {
  expect_equal(vec_cast(NULL, integer()), NULL)
  expect_equal(vec_cast(lgl(TRUE, FALSE), integer()), int(1L, 0L))
  expect_equal(vec_cast(int(1L, 2L), integer()), int(1L, 2L))
  expect_equal(vec_cast(dbl(1, 2), integer()), int(1L, 2L))
  expect_equal(vec_cast(chr("1", "2"), integer()), int(1L, 2L))
  expect_equal(vec_cast(list(1L, 2L), integer()), int(1L, 2L))
})

test_that("NA casts work as expected", {
  exp <- int(NA)
  to <- int()

  expect_equal(vec_cast(lgl(NA), to), exp)
  expect_equal(vec_cast(int(NA), to), exp)
  expect_equal(vec_cast(dbl(NA), to), exp)
  expect_equal(vec_cast(chr(NA), to), exp)
  expect_equal(vec_cast(list(NA), to), exp)
})

test_that("Shaped NA casts work as expected", {
  mat <- matrix
  exp_mat <- mat(int(NA))
  to_mat <- matrix(int())

  expect_equal(vec_cast(mat(lgl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(int(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(dbl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(chr(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(list(NA)), to_mat), exp_mat)
})

test_that("lossy casts generate error", {
  expect_lossy(vec_cast(c(2.5, 2), int()),     int(2, 2), x = dbl(), to = int())
  expect_lossy(vec_cast(c("2.5", "2"), int()), int(2, 2), x = chr(), to = int())

  expect_lossy(vec_cast(c(.Machine$integer.max + 1, 1), int()),  int(NA, 1L), x = dbl(), to = int())
  expect_lossy(vec_cast(c(-.Machine$integer.max - 1, 1), int()), int(NA, 1L), x = dbl(), to = int())
})

test_that("invalid casts generate error", {
  expect_error(vec_cast(factor("a"), integer()), class = "vctrs_error_incompatible_cast")
})


# Double

test_that("safe casts work as expected", {
  expect_equal(vec_cast(NULL, double()), NULL)
  expect_equal(vec_cast(lgl(TRUE, FALSE), double()), dbl(1, 0))
  expect_equal(vec_cast(int(1, 0), double()), dbl(1, 0))
  expect_equal(vec_cast(dbl(1, 1.5), double()), dbl(1, 1.5))
  expect_equal(vec_cast(chr("1", "1.5"), double()), dbl(1, 1.5))
  expect_equal(vec_cast(list(1, 1.5), double()), dbl(1, 1.5))
})

test_that("NA casts work as expected", {
  exp <- dbl(NA)
  to <- dbl()

  expect_equal(vec_cast(lgl(NA), to), exp)
  expect_equal(vec_cast(int(NA), to), exp)
  expect_equal(vec_cast(dbl(NA), to), exp)
  expect_equal(vec_cast(chr(NA), to), exp)
  expect_equal(vec_cast(list(NA), to), exp)
})

test_that("Shaped NA casts work as expected", {
  mat <- matrix
  exp_mat <- mat(dbl(NA))
  to_mat <- matrix(dbl())

  expect_equal(vec_cast(mat(lgl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(int(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(dbl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(chr(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(list(NA)), to_mat), exp_mat)
})

test_that("lossy casts generate warning", {
  expect_lossy(vec_cast(c("2.5", "x"), dbl()), dbl(2.5, NA), x = chr(), to = dbl())
})

test_that("invalid casts generate error", {
  expect_error(vec_cast(factor("a"), double()), class = "vctrs_error_incompatible_cast")
})


# Complex

test_that("safe casts to complex works", {
  expect_identical(vec_cast(NULL, cpl()), NULL)
  expect_identical(vec_cast(lgl(TRUE, FALSE), cpl()), cpl(1, 0))
  expect_identical(vec_cast(int(1, 0), cpl()), cpl(1, 0))
  expect_identical(vec_cast(dbl(1, 1.5), cpl()), cpl(1, 1.5))
  expect_identical(vec_cast(list(1, 1.5), cpl()), cpl(1, 1.5))
})

test_that("NA casts work as expected", {
  exp <- cpl(NA)
  to <- cpl()

  expect_equal(vec_cast(lgl(NA), to), exp)
  expect_equal(vec_cast(int(NA), to), exp)
  expect_equal(vec_cast(dbl(NA), to), exp)
  expect_equal(vec_cast(list(NA), to), exp)
})

test_that("Shaped NA casts work as expected", {
  mat <- matrix
  exp_mat <- mat(cpl(NA))
  to_mat <- matrix(cpl())

  expect_equal(vec_cast(mat(lgl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(int(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(dbl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(list(NA)), to_mat), exp_mat)
})

test_that("complex is coercible to numeric types", {
  expect_identical(vec_ptype2(cpl(), NULL), cpl())
  expect_identical(vec_ptype2(NULL, cpl()), cpl())

  expect_identical(vec_ptype2(cpl(), int()), cpl())
  expect_identical(vec_ptype2(int(), cpl()), cpl())

  expect_identical(vec_ptype2(cpl(), dbl()), cpl())
  expect_identical(vec_ptype2(dbl(), cpl()), cpl())

  expect_identical(vec_ptype2(cpl(), cpl()), cpl())

  expect_identical(vec_c(0, 1i), cpl(0i, 1i))
})

test_that("complex is not coercible to logical", {
  expect_error(vec_ptype2(cpl(), lgl()), class = "vctrs_error_incompatible_type")
  expect_error(vec_ptype2(lgl(), cpl()), class = "vctrs_error_incompatible_type")
})


# Character

test_that("safe casts work as expected", {
  expect_equal(vec_cast(NULL, character()), NULL)
  expect_equal(vec_cast(NA, character()), NA_character_)
  expect_equal(vec_cast(lgl(TRUE, FALSE), character()), chr("TRUE", "FALSE"))
  expect_equal(vec_cast(list("x", "y"), character()), chr("x", "y"))
})

test_that("NA casts work as expected", {
  exp <- chr(NA)
  to <- chr()

  expect_equal(vec_cast(lgl(NA), to), exp)
  expect_equal(vec_cast(int(NA), to), exp)
  expect_equal(vec_cast(dbl(NA), to), exp)
  expect_equal(vec_cast(chr(NA), to), exp)
  expect_equal(vec_cast(list(NA), to), exp)
})

test_that("Shaped NA casts work as expected", {
  mat <- matrix
  exp_mat <- mat(chr(NA))
  to_mat <- matrix(chr())

  expect_equal(vec_cast(mat(lgl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(int(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(dbl(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(chr(NA)), to_mat), exp_mat)
  expect_equal(vec_cast(mat(list(NA)), to_mat), exp_mat)
})

test_that("difftime gets special treatment", {
  dt1 <- as.difftime(600, units = "secs")

  expect_equal(vec_cast(dt1, character()), "600 secs")
})


# Raw

test_that("safe casts work as expected", {
  expect_equal(vec_cast(NULL, raw()), NULL)
  expect_equal(vec_cast(list(raw(1)), raw()), raw(1))
})

test_that("invalid casts generate error", {
  expect_error(vec_cast(raw(1), double()), class = "vctrs_error_incompatible_cast")
  expect_error(vec_cast(double(1), raw()), class = "vctrs_error_incompatible_cast")
})

test_that("can sort raw", {
  x <- as.raw(c(3, 1, 2, 4))
  expect_identical(vec_order(x), int(2, 3, 1, 4))
  expect_identical(x[vec_order(x)], as.raw(1:4))
})


# Lists

test_that("safe casts work as expected", {
  expect_equal(vec_cast(NULL, list()), NULL)
  expect_equal(vec_cast(NA, list()), list(NULL))
  expect_equal(vec_cast(1:2, list()), list(1L, 2L))
  expect_equal(vec_cast(list(1L, 2L), list()), list(1L, 2L))
})

test_that("dimensionality matches to" ,{
  x1 <- matrix(TRUE, nrow = 1, ncol = 1)
  x2 <- matrix(list(), nrow = 0, ncol = 2)
  expect_dim(vec_cast(x1, x2), c(1, 2))
  expect_dim(vec_cast(TRUE, x2), c(1, 2))
})

test_that("data frames are cast to list row wise (#639)", {
  x <- data.frame(x = 1:2, row.names = c("a", "b"))
  expect <- list(data.frame(x = 1L), data.frame(x = 2L))
  expect_equal(vec_cast(x, list()), expect)
})

test_that("data frames can be cast to shaped lists", {
  to <- array(list(), dim = c(0, 2, 1))
  x <- data.frame(x = 1:2, y = 3:4)

  expect <- list(vec_slice(x, 1), vec_slice(x, 2))
  expect <- array(expect, dim = c(2, 2, 1))

  expect_equal(vec_cast(x, to), expect)
})

test_that("Casting atomic `NA` values to list results in a `NULL`", {
  x <- c(NA, 1)
  expect <- list(NULL, 1)
  expect_equal(vec_cast(x, list()), expect)
})

test_that("Casting data frame `NA` rows to list results in a `NULL`", {
  x <- data.frame(x = c(NA, NA, 1), y = c(NA, 1, 2))
  expect <- list(NULL, vec_slice(x, 2), vec_slice(x, 3))
  expect_equal(vec_cast(x, list()), expect)
})


# Unspecified

test_that("unspecified can be cast to bare methods", {
  for (x in vectors[-4]) {
    expect_identical(vec_cast(unspecified(3), x), vec_init(x, 3))
  }
})
