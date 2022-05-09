pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib-matrix/circuits/matMul.circom";

template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    // populate matMul component with a=A(coefficients matrix of n*n size) and b= x(variables of n size)
    component axmamul = matMul(n, n, 1);
    for (var i=0; i<n; i++) {
        for (var j=0; j<n; j++) {
            axmamul.a[i][j] <== A[i][j];
        }
        axmamul.b[i][0] <== x[i];
    }

    // Check axmamul output, wich is AX( coefficients multiply variables result matrix ) equals b for each matrix element,
    signal outarr[n+1]; // a(xn)+a(xn-1)+....+c , output need n+1 elements
    outarr[0] <== 1; // set the first element
    component iseql[n];

    for (var i=0; i<n; i++) {
        iseql[i] = IsEqual();
        iseql[i].in[0] <== axmamul.out[i][0];
        iseql[i].in[1] <== b[i];
        //  accumolate next array element value by multiplying previous element to make verify all elemets are equal
        outarr[i+1] <== outarr[i] * iseql[i].out;
    }
    out <== outarr[n];// last value of outarr is result of all equal verification
}

component main {public [A, b]} = SystemOfEquations(3);