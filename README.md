
---

# Compiler

## Overview

This project implements a parser with semantic actions for a custom programming language.
It is designed to detect **syntax** and **semantic errors** such as:

* Undeclared variables
* Duplicate variable declarations
* Type mismatches in assignments, expressions, and conditional statements
* Illegal narrowing conversions
* Invalid list operations
* Incorrect usage of `if-elsif-else` constructs
* Invalid `fold` operations
* Mixed numeric/character relational comparisons

The parser is built using **Bison** for grammar parsing and **Flex** for lexical analysis.
Semantic checks are handled via C++ helper functions integrated into grammar rules.

---

## Files

* `parser.y` – Bison grammar file with semantic actions
* `scanner.l` – Flex lexical scanner
* `types.h` – Type definitions and semantic checking function declarations
* `symbols.h` – Symbol table template class
* `listing.h` / `listing.cc` – Error listing utilities
* `makefile` – Build instructions
* `semantic_test.txt` – Sample test program
* `README.md` – This file

---

## Compilation

To build the project:

```bash
make
```

This generates the executable:

```
compile
```

---

## Running

To test with an input file:

```bash
./compile < semantic_test.txt
```

The compiler will print:

* **Lexical Errors**
* **Syntax Errors**
* **Semantic Errors**

---

## Example Test Input

```plaintext
function main returns integer;
    a: integer is 5;
    b: real is 3.14;
    c: integer is b;       // Illegal narrowing
    a: integer is 10;      // Duplicate variable
    nums: list of integer is (1, 2, 3);
    nums2: list of real is (1, 2, 'x');  // Type mismatch
begin
    if a > 0 then
        fold left + nums endfold;
    elsif b < 5.0 then
        fold right * nums2 endfold;
    else
        3.5;
    endif;
end;
```

---

## Lessons Learned

* **Integration of Syntax & Semantics**: Adding semantic checks directly to grammar rules ensures early detection of type mismatches and undeclared variables.
* **Symbol Table Management**: A generic `Symbols<T>` template allows reuse for different variable types (scalars, lists, functions).
* **Error Propagation**: Returning a `MISMATCH` type when errors occur prevents cascading compiler failures.
* **Testing Early**: Building test cases incrementally avoids complex debugging late in the project.

---

## Possible Improvements

* Add **function call** type checking with parameter lists.
* Expand **error recovery** to allow more parsing after an error.
* Implement **constant folding** for minor optimizations.
* Support **more data types** like booleans and strings.

---
