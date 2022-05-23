pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit

/*

      Game	              | Year | Animals | Holes | Comments
      Mastermind for kids | 1996 |   6	   |   3   | Animal theme

      Animal Options:
      0--> arara
      1--> butterfly
      2--> camel
      3--> dog
      4--> elephant
      5--> fish    

*/

template MastermindVariation() {

    // Public inputs
    signal input pubGuessA;
    signal input pubGuessB;
    signal input pubGuessC;
    signal input pubNumBlacks;
    signal input pubNumWhites;
    signal input pubSolnHash;

    // Private inputs
    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;

    //Private Salt for avoidance of Brute force/rainbow table attack 
    signal input privSaltedSoln;

    // Output
    signal output solnHashOut;
    signal output guessHashOut;
    signal output numberofBlack;
    signal output numberofWhite;


    //Arrays to facilitate signals manipulation for constraint checking
    var guess[3] = [pubGuessA, pubGuessB, pubGuessC];
    var soln[3] =  [privSolnA, privSolnB, privSolnC];

    //Components to support and endorse constraint  
    component lessThan[6];
    component equalGuess[4];
    component equalSoln[4];
    var equalIdx = 0;

    //Create a constraint that the solution and guess digits are all 
    //less than 6, an allegory of the animals options from 0 to 5 
    //described on top.
    for (var j=0; j<3; j++) {
        lessThan[j] = LessThan(4);
        lessThan[j].in[0] <== guess[j];
        lessThan[j].in[1] <== 6;
        lessThan[j].out === 1;
        lessThan[j+3] = LessThan(4);
        lessThan[j+3].in[0] <== soln[j];
        lessThan[j+3].in[1] <== 6;
        lessThan[j+3].out === 1;
        for (var k=j+1; k<3; k++) {
            //Create a constraint that the solution and guess digits are unique. no duplication.
            equalGuess[equalIdx] = IsEqual();
            equalGuess[equalIdx].in[0] <== guess[j];
            equalGuess[equalIdx].in[1] <== guess[k];
            equalGuess[equalIdx].out === 0;
            equalSoln[equalIdx] = IsEqual();
            equalSoln[equalIdx].in[0] <== soln[j];
            equalSoln[equalIdx].in[1] <== soln[k];
            equalSoln[equalIdx].out === 0;
            equalIdx += 1;
        }
    }

    //Matchs Verification where correct and wrong position guesses are counted

    var nb = 0; //Black pegs counter

    // Count black pegs(Demonstrate match between guess & solution)
    for (var i=0; i<3; i++) {
        if (guess[i] == soln[i]) {
            nb += 1;
            // Set matching pegs to 0
            guess[i] = 0;
            soln[i] = 0;
        }
    }

    var nw = 0; //White pegs counter

    var k = 0;
    var j = 0;
    // Count white pegs (Demonstrate right guess at wrong position)
    for (j=0; j<3; j++) {
        for (k=0; k<3; k++) {
            // If guess position is not equal soln position
            // AND &&
            // guess value is equal to soln value
            // We have an existing guess in wrong position
            // the && operator doesn't work
            if (j != k) {
                if (guess[j] == soln[k]) {
                    if (guess[j] > 0) {
                        nw += 1;
                        // Set matching pegs to 0
                        guess[j] = 0;
                        soln[k] = 0;
                    }
                }
            }
                
        }
    }
    
    // Assert that counters are not bigger than holes
    assert( nb+nw < 4);
    
    //Provide hint for code breaker
    numberofBlack <-- nb;
    numberofWhite <-- nw;
    
    log(numberofBlack);
    log(numberofWhite);
    
    // Verify that the hash of the public solution
    component poseidonGuess = Poseidon(4);
    poseidonGuess.inputs[0] <== privSaltedSoln;
    poseidonGuess.inputs[1] <== pubGuessA;
    poseidonGuess.inputs[2] <== pubGuessB;
    poseidonGuess.inputs[3] <== pubGuessC;
    
    guessHashOut <== poseidonGuess.out;
  
    //Verify that the hash of the private solution matches pubSolnHash
    component poseidon = Poseidon(4);
    poseidon.inputs[0] <== privSaltedSoln;
    poseidon.inputs[1] <== privSolnA;
    poseidon.inputs[2] <== privSolnB;
    poseidon.inputs[3] <== privSolnC;
    
    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;
   
}

component main = MastermindVariation();