// types.h
#ifndef TYPES_H
#define TYPES_H

#include <string>
#include <vector>

typedef char* CharPtr;

enum Types { MISMATCH, INT_TYPE, CHAR_TYPE, NONE, REAL_TYPE };

// Prototypes for your type checking functions
void checkAssignment(Types lValue, Types rValue, std::string message);
Types checkWhen(Types true_, Types false_);
Types checkSwitch(Types case_, Types when, Types other);
Types checkCases(Types left, Types right);
Types checkArithmetic(Types left, Types right);
Types checkListTypes(const std::vector<Types>& elements);

#endif // TYPES_H