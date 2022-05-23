//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected

const chai = require("chai");
const path = require("path");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;


describe("Mastermind Variation Correct Guess", function () {
    this.timeout(100000000);
    
    it("Correct Input", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();

        const INPUT = {
            "pubGuessA": 2,
            "pubGuessB": 1,
            "pubGuessC": 3,
            "pubNumBlacks": 4,
            "pubNumWhites": 0,
            "pubSolnHash": "5885711880443712861938822289305308801105819719183039626666051781988343445031",
            "privSolnA": 2,
            "privSolnB": 1,
            "privSolnC": 3,
            "privSaltedSoln": "6789"
        }
        
        const witness = await circuit.calculateWitness(INPUT, true);
        await circuit.checkConstraints(witness);
        //console.log(witness);

        
        await circuit.assertOut(witness, {
            solnHashOut: 5885711880443712861938822289305308801105819719183039626666051781988343445031n,
            guessHashOut: 5885711880443712861938822289305308801105819719183039626666051781988343445031n
        });
        
    });
});


describe("Mastermind Variation Partially Correct Guess", function () {
    this.timeout(100000000);

  
    it("Partially Correct Input", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();

        const INPUT = {
            "pubGuessA": 3,
            "pubGuessB": 1,
            "pubGuessC": 5,
            "pubNumBlacks": 1,
            "pubNumWhites": 1,
            "pubSolnHash": "5885711880443712861938822289305308801105819719183039626666051781988343445031",
            "privSolnA": 2,
            "privSolnB": 1,
            "privSolnC": 3,
            "privSaltedSoln": "6789"
        }
    
        const witness = await circuit.calculateWitness(INPUT, true);
        await circuit.checkConstraints(witness);
        //console.log(witness);

    
        await circuit.assertOut(witness, {
            solnHashOut: 5885711880443712861938822289305308801105819719183039626666051781988343445031n,
            guessHashOut: 17413710990542007845646782935115683977566747373993342455546679261574374618151n
        });
    
    });

});



describe("Mastermind Variation Incorrect Guess", function () {
    this.timeout(100000000);
    
    it("Incorrect Input", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();

        const INPUT = {
            "pubGuessA": 0,
            "pubGuessB": 4,
            "pubGuessC": 5,
            "pubNumBlacks": 0,
            "pubNumWhites": 0,
            "pubSolnHash": "5885711880443712861938822289305308801105819719183039626666051781988343445031",
            "privSolnA": 2,
            "privSolnB": 1,
            "privSolnC": 3,
            "privSaltedSoln": "6789"
        }
    
        const witness = await circuit.calculateWitness(INPUT, true);
        await circuit.checkConstraints(witness);
        //console.log(witness);

    
        await circuit.assertOut(witness, {
            solnHashOut: 5885711880443712861938822289305308801105819719183039626666051781988343445031n,
            guessHashOut: 2431082266065734470156376413379106677693913032281019349640716171504824368648n
        });

    });

});